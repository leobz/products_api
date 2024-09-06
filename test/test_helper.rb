require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'

ENV["RACK_ENV"]  = "test"

require_relative '../app'

class Minitest::Spec
  include Rack::Test::Methods

  def app
    Cuba.app
  end
end