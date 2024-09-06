require_relative './test_helper.rb'
require_relative '../services/product_service.rb'
require_relative '../storage/product_repository.rb'

describe 'App' do

  before do
    # Replace with sequel helpers / DB cleaner
    ProductRepository.delete_all
  end

  describe 'Compress response' do
    it 'only if required' do
      response = get '/products', {}, { 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      response.headers['Content-Encoding'].must_equal 'gzip'

      response = get '/products'
      response.headers['Content-Encoding'].must_equal nil
    end
  end

  describe 'GET /products' do
    it 'returns a list of products' do
      ProductService.create_product('Product 1')
      ProductService.create_product('Product 2')

      response = get '/products'

      response.status.must_equal 200

      p1, p2 = JSON.parse(response.body)
      assert_equal 'Product 1', p1["name"]
      assert_equal 'Product 2', p2["name"]
    end
  end

  describe 'POST /products' do
    it 'creates a product asynchronously' do
      response = post '/products', { name: 'Product 1' }

      # TODO: Add sideqik test (enqueued job)

      # Storage
      products = ProductRepository.all
      products.size.must_equal 1
      products.first.name.must_equal 'Product 1'

      # Response
      response.status.must_equal 200
      assert_equal("Product will be created asynchronously.", JSON.parse(response.body)["message"])
    end
  end

  # TODO: Implement the rest of the tests
end