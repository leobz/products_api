require "cuba"
require 'sidekiq/web'

require_relative "./services/product_service"
require_relative "./services/authentication_service"
require_relative "./middlewares/authentication"
require_relative "./app/routes/private_routes"
require_relative "./app/routes/public_routes"

# Enable mounting routes
class Cuba
  def mount(app)
    result = app.call(req.env)
    halt result if result[0] != 404
  end
end

# Enable compression
Cuba.use Rack::Deflater

Cuba.define do
  on default do
    mount PublicRoutes

    PrivateRoutes.use Authentication
    mount PrivateRoutes
  end
end