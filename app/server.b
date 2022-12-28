import json
import reflect
import http
import .request { JsonRPCRequest }
import .response { JsonRPCResponse }
import .error { * }
import .call

def call_method(id, method, params) {
  try {
    var result
    if params == nil {
      result = method()
    } else {
      result = call.call_method(method, params)
    }

    return JsonRPCResponse(id, result, nil)
  } catch Exception e {
    return JsonRPCResponse(id, nil, Error(e.message, e.stacktrace))
  }
}

def request_processor(req, res, klass) {
  res.headers['Content-Type'] = 'application/json'

  try {
    var request = JsonRPCRequest.fromString(req.body.to_string())

    var result, error

    # ensure we are dealing with a real class
    if !is_instance(klass)
      die ServerError(request.id)

    if is_list(request) {
      if request.is_empty()
        die InvalidRequest()

      result = []

      for r in request {
        if !instance_of(r, Exception) {
          if !reflect.has_method(klass, r.method) {
            if !r.is_notification
              result.append(JsonRPCResponse(r.id, nil, MethodNotFound(r.id)))
          } else {
            var p = call_method(
              r.id,
              reflect.bind_method(klass, reflect.get_method(klass, r.method)), 
              r.params
            )
            if !r.is_notification
              result.append(p)
          }
        } else {
          result.append(JsonRPCResponse(nil, nil, r))
        }
      }

      if result == nil or result.is_empty() {
        result = ''
        res.status = http.NO_CONTENT
      }

    } else {
      if !reflect.has_method(klass, request.method) {
        if !request.is_notification {
          die MethodNotFound(request.id)
        } else {
          result = ''
          res.status = http.NO_CONTENT
        }
      } else {
        result = call_method(
          request.id,
          reflect.bind_method(klass, reflect.get_method(klass, request.method)), 
          request.params
        )
        if request.is_notification {
          result = ''
          res.status = http.NO_CONTENT
        }
      }
    }

    if result
      res.write(json.encode(result))
  } catch Exception e {
    var id = nil
    if instance_of(e, JsonException) and e.id != nil
      id = e.id
    else e = Error(e.message, e.stacktrace)
    res.write(json.encode(JsonRPCResponse(id, nil, e)))
  }
}

def serve(port, klass) {
  var server = http.server(port)
  server.on_receive(|req, res| {
    if !req.headers.contains('Content-Type') or
      req.headers['Content-Type'] != 'application/json' {
        res.status = http.UNSUPPORTED_MEDIA_TYPE
        res.write('415 Unsupported Media Type')
    } else if req.method.upper() != 'POST' {
      res.status = http.METHOD_NOT_ALLOWED
      res.write('405 Method Not Allowed')
    } else {
      request_processor(req, res, klass)
    }
  })
  server.on_error(|e, c| {
    echo 'Error occured: ${e.message}\n${e.stacktrace}'
  })
  server.listen()
}
