require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'sequel'
require 'database_cleaner/sequel'
require_relative '../app'

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
