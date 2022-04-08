import .lib as jsonrpc

var solana = jsonrpc.open('https://api.mainnet-beta.solana.com')
echo solana.call('getBalance', '83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri')