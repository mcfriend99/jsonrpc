import json
import .error

def _verify_id(id) {
  # - An identifier established by the Client that MUST contain a String, Number, 
  #   or NULL value if included.
  # - Numbers SHOULD NOT contain fractional parts.
  if !is_string(id) and !(is_number(id) and is_int(id)) and id != nil
    raise error.InvalidRequest()
}

def _verify_params(params) {
  # If present, parameters for the rpc call MUST be provided as a Structured 
  # value. Either by-position through an Array or by-name through an Object.
  #   - by-position: params MUST be an Array, containing the values in the 
  #     Server expected order.
  #   - by-name: params MUST be an Object, with member names that match the 
  #     Server expected parameter names. The absence of expected names MAY 
  #     result in an error being generated. The names MUST match exactly, 
  #     including case, to the method's expected parameters.
  if params != nil and !is_dict(params) and !is_list(params)
    raise error.InvalidRequest()
}

def _process_request(d) {
  # jsonrpc
  #   A String specifying the version of the JSON-RPC protocol.
  #   MUST be exactly "2.0".
  if !d.contains('jsonrpc') or d.jsonrpc != '2.0'
    return false

  var id = d.get('id', nil)
  # Verify the ID.
  _verify_id(id)
    
  var method = d.method

  # params MAY be omitted
  var params = d.get('params', nil)
  # Verify the params.
  _verify_params(params)
  
  return JsonRPCRequest(id, method, params, id == nil)
}

class JsonRPCRequest {
  var id
  var method
  var params
  var is_notification = false

  JsonRPCRequest(id, method, params, is_notification) {
    # Verify the ID.
    _verify_id(id)

    if !is_string(method)
      raise error.InvalidRequest()

    _verify_params(params)

    self.id = id
    self.method = method
    self.params = params
    self.is_notification = id == nil
  }

  @to_json() {
    var d = {
      jsonrpc: '2.0',
      method: self.method,
      params: self.params,
    }

    if !self.is_notification
      d['id'] = self.id

    return d
  }

  static fromJson(data) {
    if !is_list(data) and !is_dict(data)
      raise Exception('list or dictionary expected')

    if is_list(data) {
      var r = []

      for x in data {
        if !is_dict(x) {
          r.append(error.InvalidRequest())
        } else {
          var rep = _process_request(x)
          if rep {
            r.append(rep)
          } else {
            r.append(error.InvalidRequest())
          }
        }
      }

      if r.is_empty()
        raise error.InvalidRequest()

      return r
    } else {
      if !is_dict(data)
        raise error.InvalidRequest()

      var rep = _process_request(data)
      if !rep
        raise error.InvalidRequest()

      return rep
    }
  }
}
