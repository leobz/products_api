class Product
  attr_accessor :id, :name

  def initialize(name)
    @id = SecureRandom.uuid
    @name = name
  end

  def as_json
    { id: @id, name: @name }
  end
end