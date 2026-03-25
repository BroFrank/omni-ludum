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

# Platforms
Platform.destroy_all

platforms = [
  { name: 'Nintendo Switch', slug: 'nintendo-switch' },
  { name: 'Sega MegaDrive', slug: 'sega-megadrive' },
  { name: 'Super Nintendo', slug: 'super-nintendo' },
  { name: 'PC', slug: 'pc' },
  { name: 'PlayStation', slug: 'playstation' },
  { name: 'PlayStation 5', slug: 'playstation-5' },
  { name: 'PlayStation 4', slug: 'playstation-4' },
  { name: 'PlayStation 3', slug: 'playstation-3' },
  { name: 'PlayStation 2', slug: 'playstation-2' },
  { name: 'Xbox', slug: 'xbox' },
  { name: 'Xbox Series X/S', slug: 'xbox-series-xs' },
  { name: 'Xbox One', slug: 'xbox-one' },
  { name: 'Steam Deck', slug: 'steam-deck' },
  { name: 'Mobile (iOS)', slug: 'mobile-ios' },
  { name: 'Mobile (Android)', slug: 'mobile-android' },
  { name: 'Nintendo 3DS', slug: 'nintendo-3ds' },
  { name: 'Nintendo DS', slug: 'nintendo-ds' },
  { name: 'PlayStation Vita', slug: 'playstation-vita' },
  { name: 'PSP', slug: 'psp' },
  { name: 'Game Boy Advance', slug: 'game-boy-advance' }
]

platforms.each do |platform_attrs|
  Platform.find_or_create_by!(slug: platform_attrs[:slug]) do |p|
    p.name = platform_attrs[:name]
  end
end
