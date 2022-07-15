require 'rubygems'
require 'geminabox'

class ServerAuthMiddleware < Rack::Auth::Basic
  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when '/healthcheck'
      @app.call(env)
    else
      super
    end
  end
end

class Server < Geminabox::Server
  get '/healthcheck' do
    content_type 'application/json'
    status 200

    { message: "I'm fine. Thanks for asking!" }.to_json
  end
end

Geminabox.data = "/var/geminabox-data" # ... or wherever

Geminabox.rubygems_proxy = true

# Use Rack::Protection to prevent XSS and CSRF vulnerability if your geminabox server is open public.
# Rack::Protection requires a session middleware, choose your favorite one such as Rack::Session::Memcache.
# This example uses Rack::Session::Pool for simplicity, but please note that:
# 1) Rack::Session::Pool is not available for multiprocess servers such as unicorn
# 2) Rack::Session::Pool causes memory leak (it does not expire stored `@pool` hash)
use Rack::Session::Pool, expire_after: 1000 # sec
use Rack::Protection

use ServerAuthMiddleware, "GEMBOX 1.0" do |username, password|
  Rack::Utils.secure_compare(ENV.fetch('RACK_AUTH_USERNAME', 'username'), username)
  Rack::Utils.secure_compare(ENV.fetch('RACK_AUTH_PASSWORD'), password)
end

run Server
