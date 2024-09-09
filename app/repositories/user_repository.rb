require_relative '../models/user.rb'

class UserRepository
  def self.save(attrs)
    user = parse(attrs)
    dataset.insert(username: user.username, password_hash: user.password_hash)
    user
  end

  def self.find_by_username(username)
    record = dataset.where(username: username).first
    parse(record) if record
  end

  private

  def self.dataset
    DB[:users]
  end

  def self.parse(record)
    User.new(record)
  end
end