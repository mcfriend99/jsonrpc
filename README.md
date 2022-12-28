# json-rpc

`json-rpc` is a JSON-RPC 2.0 library for Blade programming language. JSON-RPC is a stateless, light-weight remote procedure call (RPC) protocol that is used by many application include the Solana and Ethereum blockchain network.

### Features

- Lightweight
- JSON-RPC Server
- JSON-RPC Client

### Example

The following example demonstrates how to the library to get the balance of a Solana wallet address:

```
import jsonrpc

var solana = jsonrpc.open('https://api.mainnet-beta.solana.com')
echo solana.call('getBalance', '83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri')
```

You should see an output looking like this: `{context: {slot: 128847428}, value: 0}` if you are connected to the internet.

See the `examples` directory for more examples and documentation on how to use.
