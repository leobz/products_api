require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'sequel'
require 'database_cleaner/sequel'
require_relative '../app'

#***************************************** Setup *****************************************
# Setup rank-test
ENV["RACK_ENV"]  = "test"
class Minitest::Spec
  include Rack::Test::Methods

  def app
    Cuba.app
  end
end

# Setup database cleaner
# TODO: Implement :transition strategy, which is faster
DatabaseCleaner[:sequel].strategy = :truncation
DatabaseCleaner[:sequel].db = Sequel.connect(ENV['DATABASE_URL'])

class Minitest::Spec
  before :each do
    DatabaseCleaner[:sequel].start
  end

  after :each do
    DatabaseCleaner[:sequel].clean
  end
end

ENV['JWT_ISSUER'] = "fudo"
ENV['JWT_SECRET'] = "bG9uZyBzZWNyZXQgdXNlZCBmb3IgS29zdG8"

#***************************************** Helper Methods ********************************
def create_rand_user_and_token()
  user_attrs = { username: "user_#{rand(1000)}", password: "password" }
  user = UserRepository.save(user_attrs)
  token = AuthenticationService.token(user.username)

  [user, token]
end