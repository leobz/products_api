require 'sidekiq/testing'
require_relative './test_helper.rb'
require_relative '../app/services/product_service.rb'
require_relative '../app/repositories/product_repository.rb'
require_relative '../app/repositories/user_repository'

describe 'App' do
  describe 'Static Files' do
    it 'serves the AUTHORS file' do
      response = get '/AUTHORS'
      _(response.status).must_equal 200
      _(response.body).must_include "Leonel Bazan"
    end

    it 'sets cache-control no-store for AUTHORS' do
      response = get '/AUTHORS'
      _(response.headers['Cache-Control']).must_equal 'no-store, private'
    end

    it 'serves the openapi.yml file' do
      response = get '/openapi.yml'
      _(response.status).must_equal 200
      _(response.body).must_include "openapi"
    end

    it 'sets cache-control during 24 hours for /openapi.yml' do
      response = get '/openapi.yml'
      _(response.headers['Cache-Control']).must_equal 'public, max-age=86400'
    end
  end

  describe 'Sidekiq Web' do
    describe 'GET /sidekiq' do
      it 'returns unauthorized if token is invalid' do
        header 'Authorization', 'Bearer INVALID'
        response = get '/sidekiq'
        _(response.status).must_equal 401
      end

      it 'allows access if token is valid' do
        _user, token = create_rand_user_and_token()
        header 'Authorization', "Bearer #{token}"
        response = get '/sidekiq'
        _(response.status).must_equal 200
        _(response.body).must_include "Sidekiq"
      end
    end
  end

  describe 'Compress response' do
    it 'when header is set to gzip' do
      header 'Accept-Encoding', 'gzip'
      response = get '/products'
      _(response.headers['Content-Encoding']).must_equal 'gzip'
    end

    it 'does not compress when header is not set' do
      response = get '/products'
      _(response.headers['Content-Encoding']).must_be_nil
    end
  end

  describe 'GET /products' do
    it 'returns unauthorized if token is invalid' do
      header 'Authorization', "Bearer INVALID"
      response = get '/products'
      _(response.status).must_equal 401
    end

    it 'returns a list of products' do
      ProductService.create_product('Product 1')
      ProductService.create_product('Product 2')

      auth_request
      response = get '/products'
      _(response.status).must_equal 200

      products = JSON.parse(response.body)
      assert_equal 'Product 1', products[0]["name"]
      assert_equal 'Product 2', products[1]["name"]
    end
  end

  describe 'POST /products' do
    it 'returns unauthorized if token is invalid' do
      header 'Authorization', "Bearer INVALID"
      response = post '/products', {}
      _(response.status).must_equal 401
    end

    it 'creates a product asynchronously' do
      auth_request
      response = post '/products', { name: "Product 1" }.to_json, { "CONTENT_TYPE" => "application/json" }
      _(response.status).must_equal 200
      assert_equal "Product will be created asynchronously.", JSON.parse(response.body)["message"]

      Sidekiq::Worker.drain_all

      products = ProductRepository.all
      _(products.size).must_equal 1
      assert_equal 'Product 1', products.first.name
    end
  end

  describe 'POST /login' do
    it 'returns a token' do
      UserRepository.save(username: "some_username", password: "some_password")

      response = post '/login', { username: "some_username", password: "some_password" }.to_json, { "CONTENT_TYPE" => "application/json" }
      _(response.status).must_equal 200
      _(response.headers["Content-Type"]).must_equal "application/json"

      token = JSON.parse(response.body)["token"]
      _(token).wont_be_nil
    end
  end
end

def auth_request
  _user, token = create_rand_user_and_token()
  header 'Authorization', "Bearer #{token}"
end
