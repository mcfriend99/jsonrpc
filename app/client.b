import http
import json
import .request { JsonRPCRequest }
import .response { JsonRPCResponse }
import .error { JsonRPCException }

class JsonRPCClient {
  var last_id = 0
  var _methods = {}

  JsonRPCClient(endpoint, options) {
    self.endpoint = endpoint
    self.client = http.HttpClient()

    self.client.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }

    if options {
      self.client.connect_timeout = options.get('connect_timeout', 2000)
      self.client.receive_timeout = options.get('receive_timeout', 2000)
    }

    self.client.follow_redirect = false
  }

  _call(id, method, params) {
    var request = JsonRPCRequest(id, method, params)
    var response = self.client.send_request(self.endpoint, 'POST', json.encode(request))
            
    if response.status == http.OK {
      if !request.is_notification {
        var data = JsonRPCResponse.fromString(response.body.to_string())
        if data.error {
          data.error.message = '${method}(): ${data.error.message}'
          die JsonRPCException(data.error)
        }
        else return data.result
      }
      return nil
    } else if response.status == http.NO_CONTENT and request.is_notification {
      # Do nothing. It is a notification response
    } else {
      die Exception(response.error)
    }
  }

  _clean_args(__args__) {
    if __args__.length() == 1 and is_dict(__args__[0])
      __args__ = __args__[0]
    return __args__
  }

  call(method, ...) {
    if !is_string(method)
      die Exception('method must be string')

    # Increment ID so we can reconcile when feedback come.
    self.last_id++
    return self._call(self.last_id, method, self._clean_args(__args__))
  }

  notify(method, ...) {
    if !is_string(method)
      die Exception('method must be string')
    
    return self._call(nil, method, self._clean_args(__args__))
  }
}
