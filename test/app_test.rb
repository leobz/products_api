require 'sidekiq/testing'

require_relative './test_helper.rb'
require_relative '../services/product_service.rb'
require_relative '../storage/product_repository.rb'
require_relative '../storage/user_repository'

describe 'App' do
  describe 'Compress response' do
    it 'only if required' do
      response = get '/products', {}, { 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      response.headers['Content-Encoding'].must_equal 'gzip'

      response = get '/products'
      response.headers['Content-Encoding'].must_equal nil
    end
  end

  describe 'GET /products' do
    it 'returns unauthorized if token is invalid' do
      header 'Authorization', "Bearer INVALID"
      response = get '/products'

      response.status.must_equal 401
    end

    it 'returns a list of products' do
      ProductService.create_product('Product 1')
      ProductService.create_product('Product 2')

      auth_request
      response = get '/products'

      response.status.must_equal 200

      p1, p2 = JSON.parse(response.body)
      assert_equal 'Product 1', p1["name"]
      assert_equal 'Product 2', p2["name"]
    end
  end

  describe 'POST /products' do
    it 'returns unauthorized if token is invalid' do
      header 'Authorization', "Bearer INVALID"
      response = post '/products', {}

      response.status.must_equal 401
    end

    it 'creates a product asynchronously' do
      auth_request
      response = post '/products', { name: "Product 1" }.to_json, { "CONTENT_TYPE" => "application/json" }

      # Response
      response.status.must_equal 200
      assert_equal("Product will be created asynchronously.", JSON.parse(response.body)["message"])

      # Execute enqueue jobs
      Sidekiq::Worker.drain_all

      # Storage
      products = ProductRepository.all
      products.size.must_equal 1
      products.first.name.must_equal 'Product 1'
    end
  end

  describe 'POST /login' do
    it 'returns a token' do
      user = User.create(username: "some_username", password: "some_password")

      response = post '/login', { username: "some_username", password: "some_password" }.to_json, { "CONTENT_TYPE" => "application/json" }

      response.status.must_equal 200
      assert_equal "application/json", response.headers["Content-Type"]

      token = JSON.parse(response.body)["token"]
      token.wont_be_nil
    end
  end
end

#
# Helper methods
#

def auth_request
  _user, token = create_rand_user_and_token()
  header 'Authorization', "Bearer #{token}"
end