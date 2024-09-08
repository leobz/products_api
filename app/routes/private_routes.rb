class PrivateRoutes < Cuba
  define do
    on get do
      on "products" do
        validate_scope req, "products" do |req|
          products = ProductService.list_products

          res.headers["content-type"] = "application/json"
          res.write products.to_json
        end
      end
    end

    on post do
      on "products" do
        validate_scope req, "products" do |req|
          body = JSON.parse(req.body.read)
          name = body["name"]

          ProductService.create_product_with_delay(name, 5)

          res.headers["content-type"] = "application/json"
          res.write({message: "Product will be created asynchronously."}.to_json)
        end
      end
    end
  end
end


def validate_scope req, scope
  scopes = req.env[:scopes]

  if scopes.include?(scope)
    yield req
  else
    res.status = 403
    res.headers['content-type'] = 'text/plain'
    res.write('Not Authorized')
  end
end