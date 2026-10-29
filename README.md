# Symgate - Ruby client for the Widgit symbolisation service

[![Build Status](https://travis-ci.org/symbols-worldwide/symgate-gem.svg?branch=master)](https://travis-ci.org/symbols-worldwide/symgate-gem)
[![Code Climate](https://codeclimate.com/github/symbols-worldwide/symgate-gem.svg)](https://codeclimate.com/github/symbols-worldwide/symgate-gem)
[![codecov.io](http://codecov.io/github/symbols-worldwide/symgate-gem/coverage.svg?branch=master)](http://codecov.io/github/symbols-worldwide/symgate-gem?branch=master)
[![Dependency Status](https://gemnasium.com/badges/github.com/symbols-worldwide/symgate-gem.svg)](https://gemnasium.com/github.com/symbols-worldwide/symgate-gem)
[![Gem Version](https://badge.fury.io/rb/symgate.svg)](https://badge.fury.io/rb/symgate)
[![Apache License](https://img.shields.io/github/license/symbols-worldwide/symgate-gem.svg)](https://www.apache.org/licenses/LICENSE-2.0)

This gem provides a wrapper around the [Symgate SOAP API](https://ws.widgitonline.com/schema/symboliser.wsdl),
providing a simple Ruby interface that matches the remote API as much as possible.

The API provides a client for each of the sections of API functionality. These are:

* `Symgate::Auth::Client` for authentication, user and group management
* `Symgate::Wordlist::Client` for per-user/group metadata storage
* `Symgate::Metadata::Client` for per-user/group wordlist management

Please note that a symbolisation client is scheduled for a future release.

## Prerequisites

This gem works with Ruby 3.1.7 and above

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

To act as another user, pass `impersonate`. It can follow an account and key, or a user with a password or token:

```ruby
auth_client = Symgate::Auth::Client.new(account: 'my_account',
                                        key: 'secret',
                                        impersonate: 'group/user')
```

#### User/password

```ruby
require 'symgate/wordlist'

wordlist_client = Symgate::Wordlist::Client.new(account: 'my_account',
                                                user: 'group/user',
                                                password: 'secret')
```

The same `impersonate` option works with a user and password:

```ruby
wordlist_client = Symgate::Wordlist::Client.new(account: 'my_account',
                                                user: 'group/admin',
                                                password: 'secret',
                                                impersonate: 'group/user')
```

#### User/token

You need to call the `authenticate` method in order to obtain a token:

```ruby
require 'symgate/auth'
require 'symgate/metadata'

# obtain a token from the authentication client

auth_client = Symgate::Auth::Client.new(account: 'my_account', 
                                        user: 'group/user',
                                        password: 'secret')

begin
  token = auth_client.authenticate
rescue Symgate::Error => e
  puts "Authentication failed with the following error: #{e.message}"
end

metadata_client = Symgate::Metadata::Client.new(account: 'my_account',
                                                user: 'group/user',
                                                token: token)
```

A stored session uses this form when it is impersonating another user:

```ruby
metadata_client = Symgate::Metadata::Client.new(account: 'my_account',
                                                user: 'group/admin',
                                                token: token,
                                                impersonate: 'group/user')
```

#### Other initialisation options

You can also initialise a client with the following options:

| Option      |     |
| ----------- | --- |
| :endpoint                    | Specifies the symbolisation SOAP endpoint to use, if not the public symbolisation server. |
| :savon_opts                  | Specifies options to pass to the underlying savon engine. e.g. `{ log_level: :debug }` |
| :data_required_error_retries | Total attempts, including the first request, when the response is 'Data required for operation'. Defaults to 3. |

### Errors

If any method call fails, it will raise a `Symgate::Error` exception. Examine the exception for further information
on what went wrong. A SOAP fault also exposes `fault_string`, `detail`, `request_xml`, and `response_xml`.
`message`, `detail`, and `original_error` keep their existing values.

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

Alternatively, in the highly unlikely event that the Vagrant stuff doesn't work, you can run the tests against some
other running symboliser by copying `test/config/local.example.yml` to `test/config/local.yml` and editing `local.yml`
to include the particulars of your symboliser endpoint, database and WSDL.

## License

This project is licensed under the Apache License 2.0.

## Contributing

1. Fork it ( https://github.com/symbols-worldwide/symgate-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
