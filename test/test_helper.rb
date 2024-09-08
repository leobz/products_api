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
DatabaseCleaner[:sequel].strategy = :truncation
DatabaseCleaner[:sequel].db = DB

class Minitest::Spec
  before :each do
    DatabaseCleaner[:sequel].start
  end

  after :each do
    DatabaseCleaner[:sequel].clean
  end
end

#***************************************** Helper Methods ********************************
def create_rand_user_and_token()
  user_attrs = { username: "user_#{rand(1000)}", password: "password" }
  user = UserRepository.save(user_attrs)
  token = AuthenticationService.token(user.username)

  [user, token]
end