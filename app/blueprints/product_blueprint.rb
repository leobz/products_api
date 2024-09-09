require 'blueprinter'
class ProductBlueprint < Blueprinter::Base
  identifier :id
  fields :name
end