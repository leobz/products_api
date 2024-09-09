require_relative '../models/product'
require_relative '../repositories/product_repository'
require_relative '../workers/create_product_worker'

class ProductService
  def self.list_products()
    ProductRepository.all()
  end

  def self.create_product_with_delay(name, delay_in_seconds)
    CreateProductWorker.perform_in(delay_in_seconds, name)
  end

  def self.create_product(name)
    attrs = { name: name }
    ProductRepository.save(attrs)
  end
end