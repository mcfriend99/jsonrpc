class JsonRPCError {
  var code
  var message
  var data

  JsonRPCError(exception) {
    if !instance_of(exception, JsonException)
      raise Exception('instance of JsonException expected')
    
    self.code = exception.code
    self.message = exception.message
    self.data = exception.stacktrace
  }

  @to_json() {
    var r = {
      code: self.code,
      message: self.message,
    }
    if self.data {
      r['data'] = self.data
    }
    return r
  }
}


class JsonException < Exception {
  JsonException(message) {
    parent(message)
    self.code = -1
    self.id = nil
  }
}


class InvalidJson < JsonException {
  InvalidJson() {
    parent('Parse error')
    self.code = -32700
  }
}


class InvalidRequest < JsonException {
  InvalidRequest() {
    parent('Invalid Request')
    self.code = -32600
  }
}


class MethodNotFound < JsonException {
  MethodNotFound(id) {
    parent('Method not found')
    self.code = -32601
    if id self.id = id
  }
}


class InvalidParams < JsonException {
  InvalidParams() {
    parent('Invalid params')
    self.code = -32602
  }
}


class InternalError < JsonException {
  InternalError(id) {
    parent('Internal error')
    self.code = -32602
    if id self.id = id
  }
}


class ServerError < JsonException {
  ServerError(id) {
    parent('Server error')
    self.code = -32000
    if id self.id = id
  }
}


class Error < JsonException {
  Error(message, data, code) {
    parent(message)
    if !code self.code = -36000
    else self.code = code
    self.data = data
  }
}

class JsonRPCException < Exception {
  JsonRPCException(error) {
    parent(error.message)
  }
}

