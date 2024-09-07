require 'sidekiq/web'
require 'securerandom'
require 'sequel'

require './app.rb'

DB = Sequel.connect(ENV['DATABASE_URL'])

secure_key = SecureRandom.hex(64)
use Rack::Session::Cookie, secret: secure_key, same_site: true, max_age: 86400

run Rack::URLMap.new('/' => Cuba, '/sidekiq' => Sidekiq::Web)