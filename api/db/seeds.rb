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

# Genres
Genre.destroy_all

genres = [
  { name: 'Action', slug: 'action' },
  { name: 'Adventure', slug: 'adventure' },
  { name: 'RPG', slug: 'rpg' },
  { name: 'Strategy', slug: 'strategy' },
  { name: 'Simulation', slug: 'simulation' },
  { name: 'Sports', slug: 'sports' },
  { name: 'Racing', slug: 'racing' },
  { name: 'Puzzle', slug: 'puzzle' },
  { name: 'Platformer', slug: 'platformer' },
  { name: 'Fighting', slug: 'fighting' },
  { name: 'Horror', slug: 'horror' },
  { name: 'Stealth', slug: 'stealth' },
  { name: 'Survival', slug: 'survival' },
  { name: 'MOBA', slug: 'moba' },
  { name: 'Battle Royale', slug: 'battle-royale' },
  { name: 'Souls-like', slug: 'souls-like' },
  { name: 'Metroidvania', slug: 'metroidvania' },
  { name: 'Roguelike', slug: 'roguelike' },
  { name: 'Roguelite', slug: 'roguelite' },
  { name: 'Visual Novel', slug: 'visual-novel' },
  { name: 'Card Game', slug: 'card-game' },
  { name: 'Board Game', slug: 'board-game' }
]

genres.each do |genre_attrs|
  Genre.find_or_create_by!(slug: genre_attrs[:slug]) do |g|
    g.name = genre_attrs[:name]
  end
end

# Genre texts
GenreText.destroy_all

genre_texts = [
  { name: 'Action', lang_code: 'en', description: 'Action games emphasize physical challenges, hand-eye coordination, and reflexes. Players typically engage in fast-paced combat or other action-oriented activities.' },
  { name: 'Action', lang_code: 'ru', description: 'Экшен-игры делают упор на физические испытания, зрительно-моторную координацию и рефлексы. Игроки обычно участвуют в быстрых боях или других действиях.' },
  { name: 'Adventure', lang_code: 'en', description: 'Adventure games focus on exploration, puzzle-solving, and narrative. Players interact with the game world and progress through a story.' },
  { name: 'Adventure', lang_code: 'ru', description: 'Приключенческие игры сосредоточены на исследовании, решении головоломок и повествовании. Игроки взаимодействуют с игровым миром и продвигаются по сюжету.' },
  { name: 'RPG', lang_code: 'en', description: 'Role-playing games where players control characters and make choices that affect the story. Features character progression, stats, and often turn-based or real-time combat.' },
  { name: 'RPG', lang_code: 'ru', description: 'Ролевые игры, в которых игроки управляют персонажами и делают выбор, влияющий на сюжет. Включают прогрессирование персонажа, характеристики и часто пошаговые или реального времени бои.' },
  { name: 'Strategy', lang_code: 'en', description: 'Strategy games require careful planning and decision-making to achieve victory. Includes real-time strategy (RTS) and turn-based strategy (TBS).' },
  { name: 'Strategy', lang_code: 'ru', description: 'Стратегические игры требуют тщательного планирования и принятия решений для достижения победы. Включают стратегии в реальном времени (RTS) и пошаговые стратегии (TBS).' },
  { name: 'Simulation', lang_code: 'en', description: 'Simulation games attempt to simulate real-world activities. Players manage resources, build structures, or control vehicles.' },
  { name: 'Simulation', lang_code: 'ru', description: 'Симуляторы пытаются имитировать реальные виды деятельности. Игроки управляют ресурсами, строят сооружения или контролируют транспортные средства.' },
  { name: 'Souls-like', lang_code: 'en', description: 'Games inspired by the Dark Souls series, featuring challenging combat, intricate level design, and deep lore. Known for high difficulty and rewarding gameplay.' },
  { name: 'Souls-like', lang_code: 'ru', description: 'Игры, вдохновленные серией Dark Souls, с сложными боями, запутанным дизайном уровней и глубоким лором. Известны высокой сложностью и захватывающим геймплеем.' },
  { name: 'Metroidvania', lang_code: 'en', description: 'Action-adventure games with interconnected maps and ability-gated progression. Players gain new abilities to access previously unreachable areas.' },
  { name: 'Metroidvania', lang_code: 'ru', description: 'Приключенческие экшен-игры с взаимосвязанными картами и прогрессированием через получение способностей. Игроки получают новые способности для доступа к ранее недоступным областям.' },
  { name: 'Roguelike', lang_code: 'en', description: 'Games featuring procedurally generated levels, permadeath, and turn-based gameplay. Each playthrough is unique and challenging.' },
  { name: 'Roguelike', lang_code: 'ru', description: 'Игры с процедурно генерируемыми уровнями, перманентной смертью и пошаговым геймплеем. Каждое прохождение уникально и сложно.' },
  { name: 'Roguelite', lang_code: 'en', description: 'Similar to roguelikes but with meta-progression. Death is not the end, as players can unlock permanent upgrades for future runs.' },
  { name: 'Roguelite', lang_code: 'ru', description: 'Похожи на рогалики, но с мета-прогрессированием. Смерть не является концом, так как игроки могут разблокировать постоянные улучшения для будущих запусков.' },
  { name: 'Visual Novel', lang_code: 'en', description: 'Interactive story-driven games with text-based narrative and static or animated visuals. Player choices may affect the story outcome.' },
  { name: 'Visual Novel', lang_code: 'ru', description: 'Интерактивные игры, основанные на истории, с текстовым повествованием и статичной или анимированной визуализацией. Выбор игрока может повлиять на исход истории.' }
]

genre_texts.each do |gt_attrs|
  genre = Genre.find_by(name: gt_attrs[:name])
  GenreText.find_or_create_by!(
    genre_id: genre&.id,
    lang_code: gt_attrs[:lang_code]
  ) do |gt|
    gt.description = gt_attrs[:description]
  end
end

puts "Created #{GenreText.count} genre texts"
