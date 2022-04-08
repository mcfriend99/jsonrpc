import .error { JsonRPCError, JsonException, Error }
import json

class JsonRPCResponse {
  var id
  var result
  var error

  JsonRPCResponse(id, result, error) {

    if error != nil and !instance_of(error, JsonException)
      die Exception('instance of JsonException expected as response error')

    self.id = id
    self.result = result
    self.error = error
  }

  @to_json() {
    var d = {
      jsonrpc: '2.0',
      id: self.id,
    }

    # result
    #   This member is REQUIRED on success.
    #   This member MUST NOT exist if there was an error invoking the method.
    #   The value of this member is determined by the method invoked on the Server.
    # error
    #   This member is REQUIRED on error.
    #   This member MUST NOT exist if there was no error triggered during invocation.
    #   The value for this member MUST be an Object as defined in section 5.1.
    if self.error != nil {
      var error = json.decode(json.encode(JsonRPCError(self.error)))
      if !instance_of(self.error, Error)
        error.remove('data')

      d['error'] = error
    } else {
      d['result'] = self.result
    }

    return d
  }

  static fromDict(dict) {
    if !is_dict(dict)
      die Exception('dictionary expected')

    if !dict.contains('jsonrpc') or dict.jsonrpc != '2.0'
      die Exception('Server is not an RPC server')

    if !dict.contains('id')
      die Exception('response id required')

    if !dict.contains('result') and !dict.contains('error')
      die Exception('response requires "result" when no error occurs')
    if !dict.contains('error') and !dict.contains('result')
      die Exception('response requires "error" when call fails')

    if dict.contains('error') and !instance_of(dict.error, JsonException)
      die Exception('instance of JsonException expected as response error')

    var result = dict.get('result', nil)
    var error = dict.get('error', nil)
    return JsonRPCResponse(dict.id, result, error)
  }

  static fromString(str) {
    if !is_string(str)
      die Exception('string expected')

    var d = json.decode(str)
    
    if d.contains('error') {
      d.error = Error(d.error.message, d.error.get('data', nil), d.error.code)
    }
  
    return JsonRPCResponse.fromDict(d)
  }
}
