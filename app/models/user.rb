require 'sequel'
require 'bcrypt'

DB = Sequel.connect(ENV['DATABASE_URL'])
class User < Sequel::Model
  include BCrypt
  plugin :json_serializer

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end
end