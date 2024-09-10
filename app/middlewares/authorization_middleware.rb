require_relative "../helpers/web_helper"

class AuthorizationMiddleware
  include WebHelper

  def initialize(app, scope)
    @app = app
    @scope = scope
  end

  def call(env)
    if env[:scopes] && env[:scopes].include?(@scope)
      @app.call(env)
    else
      json_error_response(403, 'Not Authorized.')
    end
  end
end