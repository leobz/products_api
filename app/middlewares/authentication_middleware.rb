require_relative "../helpers/web_helper"

class AuthenticationMiddleware
  include WebHelper
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      payload, _header = JWT.decode(bearer, ENV['JWT_SECRET'], true, options)

      env[:scopes] = payload['scopes']
      env[:user] = payload['user']

      @app.call(env)

    rescue JWT::DecodeError
      json_error_response(401, 'A token must be passed.')
    rescue JWT::ExpiredSignature
      json_error_response(403, 'The token has expired.')
    rescue JWT::InvalidIssuerError
      json_error_response(403, 'The token does not have a valid issuer.')
    rescue JWT::InvalidIatError
      json_error_response(403, 'The token does not have a valid "issued at" time.')
    end
  end
end