require_relative '../models/user.rb'

class UserRepository
  def self.save(attrs)
    User.create(username: attrs[:username], password: attrs[:password])
  end

  def self.all()
    dataset.all
  end

  def self.find_by_username(username)
    dataset.where(username: username).first
  end

  private

  def self.dataset
    User.dataset
  end
end