Rack Federated Authentication
=======

This gem is intended to provide a quick way to authenticate a Rack-based application using one of OmniAuth's
federated authentication strategies. The idea is to be able to quickly restrict access to a Rack app based on
and existing authentication system such as Google Apps. 

Install
------

Add it to your gemfile

    gem "rack-federated-auth"

To Use it in your Rack application

``` ruby
class MyApp < Sinatra::Base

  use Rack::Session::Cookie, :secret => ENV['SESSION_SECRET']

  use OmniAuth::Builder do
    provider :google_oauth2, ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], {:access_type => 'online', :approval_prompt => ''}
  end

  use RackFederatedAuth::Authentication do |config|
    config.email_filter = /yourdomain\.com$/
  end
end
```

To Use it in your Rails application, add the following to your config/application.rb

This example uses the google-openid provider, which also requires the 'omniauth-openid' gem 

``` ruby
require 'omniauth-openid'
require 'openid/store/filesystem'

config.middleware.insert_before(ActionDispatch::Static, Rack::Session::Cookie, :secret => ENV['SESSION_SECRET'])

config.middleware.insert_after(Rack::Session::Cookie, OmniAuth::Builder) do
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end

config.middleware.insert_after(OmniAuth::Builder, RackFederatedAuth::Authentication) do |config|
  config.email_filter = /yourdomain\.com$/
  config.auth_url = "/auth/open_id?openid_url=www.google.com/accounts/o8/id"
end
```


The gem handles forwarding users to the authentication URL if they haven't authenticated,
receiving the authentication callback, and setting the user's session so authentication isn't
required before each page request. 

Most federated login stragegies for OmniAuth should work - if you want to use something other than google-oauth2,
you can set the auth url accordingly:

```ruby
use RackFederatedAuth::Authentication do |config|
  config.auth_url = '/auth/yahoo?openid_url=https://me.yahoo.com'
end
```

You can restrict who can access the site based on email by setting `email_filter` to a regex which
will only match on users you'd like to allow to authenticate.  You can also specify a custom `failure_message`
to display on authentication failure (this can be useful if users need to auth with a specific email)



Copyright
---------

Copyright (c) 2012 Ryan Michael. See LICENSE.txt for
further details.

