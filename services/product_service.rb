require_relative '../models/product'
require_relative '../storage/product_repository'

class ProductService
  def self.list_products()
    ProductRepository.all()
  end

  def self.create_product_with_delay(name, delay_in_seconds)
    # TODO: Implement delay with sidekiq
    create_product(name)
  end

  def self.create_product(name)
    product = Product.new(name)
    ProductRepository.save(product)
  end
end