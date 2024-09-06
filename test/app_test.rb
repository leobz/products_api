require_relative './test_helper.rb'

describe 'App' do
  describe 'GET /products' do
    it 'returns status 200' do
      response = get '/products'
      response.status.must_equal 200
    end

    # TODO: Implement the rest of the tests
  end

  # TODO: Implement the rest of the tests
end