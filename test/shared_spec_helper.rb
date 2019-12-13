def test_user_details
  { account: 'foo', user: 'foo/bar', password: 'baz' }
end

def test_second_user_details
  { account: 'foo', user: 'foo/baz', password: 'qux' }
end

def test_third_user_details
  { account: 'foo', user: 'foo/qux', password: 'quux' }
end

def test_user_group
  test_user_details[:user].split('/', 2)[0]
end

def test_user_password_creds
  user_details = test_user_details
  user_password_creds(user_details[:account], user_details[:user], user_details[:password])
end

def client_of_type(client_type, opts)
  config = SymboliserConfig.config
  client_type.new(opts.merge(:endpoint => config['soap_endpoint'], :wsdl => config['wsdl']))
end
