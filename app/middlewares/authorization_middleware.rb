class AuthorizationMiddleware
  def initialize(app, scope)
    @app = app
    @scope = scope
  end

  def call(env)
    if env[:scopes] && env[:scopes].include?(@scope)
      @app.call(env)
    else
      [403, { 'content-type' => 'text/plain' }, ['Not Authorized.']]
    end
  end
end