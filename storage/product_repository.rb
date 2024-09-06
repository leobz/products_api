class ProductRepository
  @@products = {}

  def self.save(product)
    # TODO: Implement Sequel
    @@products[product.id] = product
  end

  def self.all()
    # TODO: Implement Sequel
    @@products.values
  end

  def self.delete_all
    # TODO: Implement Sequel
    @@products = {}
  end
end