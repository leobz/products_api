require 'bcrypt'

class User
  include BCrypt

  attr_accessor :username, :password_hash

  def initialize(attrs = {})
    @username = attrs[:username]
    @password_hash = attrs[:password_hash] || Password.create(attrs[:password])
  end

  def password
    @password ||= Password.new(password_hash)
  end
end