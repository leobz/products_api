require "cuba"

Cuba.define do
  on get do
    on "products" do
      # TODO: Implement
      res.write "Hello world!"
    end
  end
end