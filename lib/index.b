import .error { * }
import .request { * }
import .response { * }
import .client { * }
import .server { * }


def open(endpoint, options) {
  return JsonRPCClient(endpoint, options)
}
