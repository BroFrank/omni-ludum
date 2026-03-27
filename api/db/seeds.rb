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

# Publishers
Publisher.destroy_all

publishers = [
  { name: 'Nintendo', type: PUBLISHER_TYPES::PUBLISHER },
  { name: 'Sony Interactive Entertainment', type: PUBLISHER_TYPES::PUBLISHER },
  { name: 'Microsoft Studios', type: PUBLISHER_TYPES::PUBLISHER },
  { name: 'Valve', type: PUBLISHER_TYPES::PUBLISHER },
  { name: 'CD Projekt Red', type: PUBLISHER_TYPES::DEVELOPER },
  { name: 'FromSoftware', type: PUBLISHER_TYPES::DEVELOPER },
  { name: 'Indie Studio', type: PUBLISHER_TYPES::DEVELOPER },
  { name: 'Toby Fox', type: PUBLISHER_TYPES::PERSON },
  { name: 'Eric Barone', type: PUBLISHER_TYPES::PERSON },
  { name: 'Lucas Pope', type: PUBLISHER_TYPES::PERSON }
]

publishers.each do |publisher_attrs|
  Publisher.find_or_create_by!(name: publisher_attrs[:name]) do |p|
    p.type = publisher_attrs[:type]
  end
end

# Publisher texts
PublisherText.destroy_all

publisher_texts = [
  { name: 'Nintendo', lang_code: 'en', description: 'Nintendo Co., Ltd. is a Japanese multinational video game company headquartered in Kyoto. It is one of the largest and most influential companies in the video game industry.' },
  { name: 'Nintendo', lang_code: 'ru', description: 'Nintendo Co., Ltd. — японская транснациональная компания по производству видеоигр, расположенная в Киото. Одна из крупнейших и наиболее влиятельных компаний в индустрии видеоигр.' },
  { name: 'Sony Interactive Entertainment', lang_code: 'en', description: 'Sony Interactive Entertainment LLC is a multinational video game and digital entertainment company owned by Sony.' },
  { name: 'Sony Interactive Entertainment', lang_code: 'ru', description: 'Sony Interactive Entertainment LLC — многонациональная компания по производству видеоигр и цифровых развлечений, принадлежащая Sony.' },
  { name: 'Microsoft Studios', lang_code: 'en', description: 'Microsoft Studios is the publishing division of Microsoft Gaming, responsible for developing and publishing video games for Xbox and Windows platforms.' },
  { name: 'Microsoft Studios', lang_code: 'ru', description: 'Microsoft Studios — издательское подразделение Microsoft Gaming, отвечающее за разработку и публикацию видеоигр для платформ Xbox и Windows.' },
  { name: 'Valve', lang_code: 'en', description: 'Valve Corporation is an American video game developer, publisher, and digital distribution company headquartered in Bellevue, Washington.' },
  { name: 'Valve', lang_code: 'ru', description: 'Valve Corporation — американский разработчик и издатель видеоигр, а также компания цифровой дистрибуции, расположенная в Белвью, штат Вашингтон.' },
  { name: 'CD Projekt Red', lang_code: 'en', description: 'CD Projekt Red is a Polish video game developer and publisher, known for The Witcher series and Cyberpunk 2077.' },
  { name: 'CD Projekt Red', lang_code: 'ru', description: 'CD Projekt Red — польский разработчик и издатель видеоигр, известный по серии The Witcher и Cyberpunk 2077.' },
  { name: 'FromSoftware', lang_code: 'en', description: 'FromSoftware, Inc. is a Japanese video game development company known for Dark Souls, Bloodborne, Sekiro, and Elden Ring.' },
  { name: 'FromSoftware', lang_code: 'ru', description: 'FromSoftware, Inc. — японская компания по разработке видеоигр, известная по сериям Dark Souls, Bloodborne, Sekiro и Elden Ring.' },
  { name: 'Toby Fox', lang_code: 'en', description: 'Toby Fox is an American video game developer and composer, best known for creating Undertale and Deltarune.' },
  { name: 'Toby Fox', lang_code: 'ru', description: 'Toby Fox — американский разработчик и композитор видеоигр, наиболее известный созданием Undertale и Deltarune.' },
  { name: 'Eric Barone', lang_code: 'en', description: 'Eric Barone, also known as ConcernedApe, is an American video game developer who created Stardew Valley.' },
  { name: 'Eric Barone', lang_code: 'ru', description: 'Eric Barone, также известный как ConcernedApe, — американский разработчик видеоигр, создавший Stardew Valley.' }
]

publisher_texts.each do |pt_attrs|
  publisher = Publisher.find_by(name: pt_attrs[:name])
  PublisherText.find_or_create_by!(
    publisher_id: publisher&.id,
    lang_code: pt_attrs[:lang_code]
  ) do |pt|
    pt.description = pt_attrs[:description]
  end
end

puts "Created #{PublisherText.count} publisher texts"
