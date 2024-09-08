require 'bcrypt'
require_relative '../repositories/user_repository'
class PublicRoutes < Cuba
  define do
    on post do
      on "login" do
        body = JSON.parse(req.body.read)
        username = body["username"]
        password = body["password"]

        user = UserRepository.find_by_username(username)

        res.headers["content-type"] = "application/json"

        if user && user.password == password
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


