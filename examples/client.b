# This example connects to the example server in `examples/server.b` and does a many RPC calls

import ..app as jsonrpc

var app = jsonrpc.open('localhost:8900')

# The example calls the `get_account_number` function.
# This function takes no parameter so none will be given.
echo app.call('get_account_number')

# This example calls the `deposit` function. 
# The deposit function requires one number parameter.
# Because this is a notification, no response will be gotten from the server.
app.notify('deposit', 200)

# We are retrieving our account details
echo app.call('get_details')

# The `set_details` function expects a dictionary. 
# We call this to update our account details.
echo app.call('set_details', {
  name: 'John Does',
  email: 'example@someone.com',
})

# Lets add some 800 units to our account.
app.notify('deposit', 800)

# Let's get our account balance.
echo app.call('get_balance')


# We are retrieving our details as set earlier.
echo app.call('get_details')
