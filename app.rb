require "cuba"
require 'sidekiq/web'
require 'rack/cache'

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

# in-memory cache for development, use memcached for production
# Note: For more performance, replace Rack::Cache for Varnish or Nginx cache.
Cuba.use Rack::Cache,
  verbose: true,
  metastore: 'heap:/',
  entitystore: 'heap:/'

# Serve static files
Cuba.use Rack::Static, :urls => ["/AUTHORS"], root: "public", cascade: true
Cuba.use Rack::Static, :urls => ["/openapi.yml"], root: "public", cascade: true,
  # Cache all static files in public caches (e.g. Rack::Cache) as well as in the browser
  :header_rules => [[:all, {'cache-control' => 'public, max-age=86400'}]]

Cuba.define do
  on default do
    mount PublicRoutes

    PrivateRoutes.use Authentication
    mount PrivateRoutes
  end
end