require 'jwt'
class AuthenticationService

  def self.valid_user?(username, password)
    user = UserRepository.find_by_username(username)
    user && user.password == password
  end

  def self.token(username)
    JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
  end

  private

  def self.payload(username)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: ['products'],
      user: {
        username: username
      }
    }
  end
end