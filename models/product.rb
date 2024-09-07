require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'])
class Product < Sequel::Model
  plugin :json_serializer
end