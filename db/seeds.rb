require 'sequel'
require 'bcrypt'

DB = Sequel.connect(ENV['DATABASE_URL'])

return if DB[:users].count > 0

DB.transaction do
  begin
    user =  { username: 'admin', password_hash: BCrypt::Password.create('adminpass') }
    DB[:users].insert(user)

    puts "Seeds completed"
  rescue => e
    puts "Error in seeds: #{e.message}"
    raise Sequel::Rollback
  end
end