require "cuba"
require "json"
require 'sidekiq/web'

require_relative "./services/product_service"

# Enable compression
Cuba.use Rack::Deflater

Cuba.define do
  on get do
    on "products" do
      products = ProductService.list_products

      res.headers["content-type"] = "application/json"
      res.write products.map(&:as_json).to_json
    end
  end

  on post do
    on "products" do
      body = JSON.parse(req.body.read)
      name = body["name"]

      ProductService.create_product_with_delay(name, 5)

      res.headers["content-type"] = "application/json"
      res.write({message: "Product will be created asynchronously."}.to_json)
    end
  end
end