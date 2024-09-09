require_relative '../models/product.rb'

class ProductRepository
  def self.save(attrs)
    dataset.insert(name: attrs[:name])
  end

  def self.all
    dataset.all.map { |attrs| parse(attrs) }
  end

  private

  def self.dataset
    DB[:products]
  end

  def self.parse(attrs)
    Product.new(attrs)
  end
end