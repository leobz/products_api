class AuthorizationService
  def self.validate_scope(req, scope)
    scopes = req.env[:scopes]
  
    if scopes.include?(scope)
      yield req
    else
      res.status = 403
      res.headers['content-type'] = 'text/plain'
      res.write('Not Authorized')
    end
  end
end