class Product
  attr_accessor :id, :name

  def initialize(attrs)
    @id = attrs[:id]
    @name = attrs[:name]
  end
end