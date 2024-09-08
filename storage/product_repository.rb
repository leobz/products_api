require_relative '../models/product.rb'

class ProductRepository
  def self.save(attrs)
    dataset.insert(name: attrs[:name])
  end

  def self.all()
    dataset.all
  end

  private

  def self.dataset
    Product.dataset
  end
end