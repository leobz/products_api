require "cuba"
require "sequel"
require 'sidekiq/web'
require 'rack/cache'
require_relative "./app/middlewares/authentication_middleware"
require_relative "./app/middlewares/authorization_middleware"

require_relative "./app/routes/private_routes"
require_relative "./app/routes/public_routes"

# Connect to DB
DB = Sequel.connect(ENV['DATABASE_URL'])

# Enable mounting routes
class Cuba
  def mount(app)
    result = app.call(req.env)
    halt result if result[0] != 404
  end
end

# Enable session management for CSRF protection in Sidekiq Web
Cuba.use Rack::Session::Cookie,
         secret: File.read(".session.key"),
         same_site: true,
         max_age: 86400

# Enable gzip compression
Cuba.use Rack::Deflater

# In-memory cache for development, use memcached for production
# Note: For more performance in static files, you can use Varnish or Nginx cache.
Cuba.use Rack::Cache,
         verbose: true,
         metastore: 'heap:/',
         entitystore: 'heap:/'

# Serve static files
Cuba.use Rack::Static,
        root: "public",
        urls: ["/AUTHORS", "/openapi.yml"],
        cascade: true,
        header_rules: [
          ["/AUTHORS", {'cache-control' => 'no-store'}],
          ["/openapi.yml", {'cache-control' => 'public, max-age=86400'}]
        ]

Cuba.define do
  on default do
    mount PublicRoutes

    on "sidekiq" do
      Sidekiq::Web.use AuthenticationMiddleware
      run Sidekiq::Web
    end

    PrivateRoutes.use AuthenticationMiddleware
    PrivateRoutes.use AuthorizationMiddleware, "products"
    mount PrivateRoutes
  end
end