# The `json-rpc` server servers a class over RPC. Below, we create our test class.
import ..app as jsonrpc

class Account {
  var name = 'Cardi B.'
  var email = 'test@sample.com'
  var account_number = 123456789
  var balance = 0

  get_account_number() {
    return self.account_number
  }

  deposit(amount) {
    self.balance += amount
  }

  get_details() {
    return {
      name: self.name,
      email: self.email,
      account_number: self.account_number,
      balance: self.balance,
    }
  }

  set_details(details) {
    if details.contains('name')
      self.name = details.name
    if details.contains('email')
      self.email = details.email
    if details.contains('account_number')
      self.balance = details.account_number

    return 'Details set successfully!'
  }

  get_balance() {
    return self.balance
  }
}


echo 'json-rpc server listening on localhost:8900...'
jsonrpc.serve(8900, Account())
