require './app.rb'
require 'sidekiq/web'
require 'securerandom'


secure_key = SecureRandom.hex(64)
use Rack::Session::Cookie, secret: secure_key, same_site: true, max_age: 86400

run Rack::URLMap.new('/' => Cuba, '/sidekiq' => Sidekiq::Web)