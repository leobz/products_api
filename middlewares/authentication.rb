class Authentication
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
      [401, { 'content-type' => 'text/plain' }, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, { 'content-type' => 'text/plain' }, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, { 'content-type' => 'text/plain' }, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, { 'content-type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
    end
  end
end