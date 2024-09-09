require_relative '../repositories/user_repository'
require_relative "../services/authentication_service"

class PublicRoutes < Cuba
  define do
    on post do
      on "login" do
        body = JSON.parse(req.body.read)
        username = body["username"]
        password = body["password"]

        res.headers["content-type"] = "application/json"

        if AuthenticationService.valid_user?(username, password)
          token = AuthenticationService.token(username)

          res.write({token: token}.to_json)
        else
          res.status = 401
          res.write({error: "Invalid username or password"}.to_json)
        end
      end
    end
  end
end


