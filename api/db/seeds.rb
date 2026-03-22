# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all

User.new(
  username: 'super admin',
  email: 'sadmin@g.com',
  password: '123',
  role: USER_ROLES::SUPER_ADMIN,
  is_disabled: false
).save(validate: false)

User.new(
  username: 'admin',
  email: 'admin@g.com',
  password: '123',
  role: USER_ROLES::ADMIN,
  is_disabled: false
).save(validate: false)

User.new(
  username: 'moder',
  email: 'moder@g.com',
  password: '123',
  role: USER_ROLES::MODERATOR,
  is_disabled: false
).save(validate: false)

User.new(
  username: 'reg one',
  email: 'regone@g.com',
  password: '123',
  role: USER_ROLES::REGULAR,
  is_disabled: false
).save(validate: false)

User.new(
  username: 'reg dis',
  email: 'regdis@g.com',
  password: '123',
  role: USER_ROLES::REGULAR,
  is_disabled: true
).save(validate: false)

User.all.each do |u|
  u.update_column(:slug, u.username.downcase.gsub(/\s+/, '_').gsub(/[^a-z0-9_]/, ''))
end
