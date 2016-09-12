# Symgate - Ruby client for the Widgit symbolisation service

This gem provides a wrapper around the [Symgate SOAP API](https://ws.widgitonline.com/schema/symboliser.wsdl),
providing a simple Ruby interface that matches the remote API as much as possible.

The API provides a client for each of the sections of API functionality. These are:

* `Symgate::Auth::Client` for authentication, user and group management
* `Symgate::Wordlist::Client` for per-user/group metadata storage
* `Symgate::Metadata::Client` for per-user/group wordlist management

Please note that a symbolisation client is scheduled for a future release.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'symgate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install symgate

## Usage

### Initialisation

To call any Symgate methods you must create a client of the relevant type. These can
be instantiated in the following ways:

#### Account/key

```ruby
require 'symgate/auth'

auth_client = Symgate::Auth::Client.new(account: 'my_account', key: 'secret')
```

#### User/password

```ruby
require 'symgate/wordlist'

wordlist_client = Symgate::Wordlist::Client.new(account: 'my_account', 
                                                user: 'group/user',
                                                password: 'secret)
```

#### User/token

You need to call the `authenticate` method in order to obtain a token:

```ruby
require 'symgate/auth'
require 'symgate/metadata'

# obtain a token from the authentication client

auth_client = Symgate::Auth::Client.new(account: 'my_account', 
                                        user: 'group/user',
                                        password: 'secret)

begin
  token = auth.authenticate
rescue Symgate::Error => e
  puts "Authentication failed with the following error: #{e.message}"
end

metadata_client = Symgate::Metadata::Client.new(account: 'my_account',
                                                user: 'group/user',
                                                token: token)
```

#### Other initialisation options

You can also initialise a client with the following options:

| Option      |     |
| ----------- | --- |
| :endpoint   | Specifies the symbolisation SOAP endpoint to use, if not the public symbolisation server. |
| :savon_opts | Specifies options to pass to the underlying savon engine. e.g. `{ log_level: :debug }` |

### Errors

If any method call fails, it will raise a `Symgate::Error` exception. Examine the exception for further information
on what went wrong.

### Further documentation

For more information, see the documentation at:

<http://www.rubydoc.info/github/symbols-worldwide/symgate-gem/>

## Development

After checking out the repository, run `bundle install` to obtain the necessary development gems.

Run `rake test` to run the tests, which consist of
* rubocop
* rspec (with coverage)

Successful PRs require 100% code coverage and all tests and cops passing. 

### Integration tests

If you want to run the integration tests (test the gem against a running server):
1. Install Vagrant 1.8 or later, if not already installed
2. Run `rake vagrant:up` to set up a local VM running the latest symboliser.
3. Run `rake spec:integration` to run the integration tests.

To pause testing until later, run `rake vagrant:halt` which will suspend your virtual machine. To resume testing run `rake vagrant:up` again.

To shut down and destroy the VM completely, run `rake vagrant:destroy`

Note that you need access to the Widgit CI server for this to work.

## License

This project is licensed under the Apache License 2.0.

## Contributing

1. Fork it ( https://github.com/symbols-worldwide/symgate-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
