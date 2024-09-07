require "sidekiq"

class CreateProductWorker
  include Sidekiq::Worker

  def perform(product_name)
    puts "Enqueued job to create product: #{product_name}"
    ProductService.create_product(product_name)
    puts "Created product: #{product_name}"
  end
end