# Omni Ludum - Project Context

## Project Overview

**Omni Ludum** is a full-stack web application with a decoupled architecture:

- **Backend API**: Ruby on Rails 7.2.3 (API-only pattern)
- **Frontend Client**: SvelteKit with TypeScript, Vite, and Tailwind CSS v4

The project follows a modern separation of concerns with the API serving as a JSON backend and the SvelteKit client handling the user interface.

## Directory Structure

```
omni-ludum/
├── api/                    # Rails backend
│   ├── app/               # Application code (models, controllers, views, etc.)
│   ├── config/            # Rails configuration
│   ├── db/                # Database migrations and seeds
│   ├── test/              # Rails test suite
│   └── ...
├── client/                # SvelteKit frontend
│   ├── src/
│   │   ├── lib/          # Shared libraries
│   │   └── routes/       # SvelteKit routes
│   ├── static/           # Static assets
│   └── ...
├── dockerfiles/           # Docker configuration files
│   └── Dockerfile.postgresql  # PostgreSQL 18+ container
├── docker-compose.yml     # Docker Compose configuration
├── Makefile               # Makefile for common Docker/database commands
├── QWEN.md               # This file
└── README.md
```

## Technologies

### Backend (API)
- **Framework**: Ruby on Rails 7.2.3
- **Ruby**: 3.4.8
- **Database**: PostgreSQL
- **Server**: Puma
- **Testing**: Rails default test framework (Minitest)
- **Code Quality**: RuboCop (rails-omakase), Brakeman

### Frontend (Client)
- **Framework**: SvelteKit 2.x with Svelte 5.x (runes mode)
- **Language**: TypeScript
- **Build Tool**: Vite 7.x
- **Styling**: Tailwind CSS v4
- **Testing**: Vitest (unit), Playwright (browser/E2E)
- **Linting**: ESLint v9

## Building and Running

### Prerequisites
- Ruby 3.4.8 (use rbenv/rvm for version management)
- Node.js (LTS recommended)
- PostgreSQL database server
- Docker and Docker Compose (optional, for containerized development)

### Docker Setup (Optional)

```bash
# Start PostgreSQL container
docker compose up -d

# View logs
docker compose logs db

# Stop container
docker compose down

# The database will be available at localhost:5432
# Credentials: postgres / postgres
# Database: omni_ludum_development
```

### Backend Setup

```bash
cd api

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Run development server
rails server
# or
bin/dev
```

### Frontend Setup

```bash
cd client

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Testing

### Backend Tests
```bash
cd api
rails test                 # Run all tests
rails test:channels        # Channel tests
rails test:controllers     # Controller tests
rails test:integration     # Integration tests
rails test:models          # Model tests
```

### Frontend Tests
```bash
cd client
npm run test              # Run all tests (unit + browser)
npm run test:unit         # Unit tests only
npm run check             # TypeScript type checking
npm run lint              # ESLint
```

## Development Commands

### Docker
| Command | Description |
|---------|-------------|
| `docker compose up -d` | Start all containers in background |
| `docker compose up --build` | Build and start containers |
| `docker compose down` | Stop and remove containers |
| `docker compose logs db` | View database logs |
| `docker compose ps` | List running containers |
| `docker compose exec db psql -U postgres -d omni_ludum_development` | Connect to DB |

### Makefile
| Command | Description |
|---------|-------------|
| `make db-up` | Start PostgreSQL container in background |
| `make db-down` | Stop PostgreSQL container |
| `make db-console` | Open psql console for database queries |
| `make db-logs` | View database logs (follow mode) |
| `make db-restart` | Restart PostgreSQL container |

### Backend
| Command | Description |
|---------|-------------|
| `rails server` | Start Rails development server |
| `rails console` | Open Rails console |
| `rails db:migrate` | Run database migrations |
| `rails db:seed` | Seed the database |
| `rails routes` | List all routes |
| `rails test` | Run test suite |
| `rubocop` | Run linter |
| `brakeman` | Security scan |
| `bin/rails solid_queue:start` | Start Solid Queue worker |

### Makefile
| Command | Description |
|---------|-------------|
| `make db-up` | Start PostgreSQL container in background |
| `make db-down` | Stop PostgreSQL container |
| `make db-console` | Open psql console for database queries |
| `make db-logs` | View database logs (follow mode) |
| `make db-restart` | Restart PostgreSQL container |
| `make api-dev` | Start Rails development server |
| `make api-queue` | Start Solid Queue worker |
| `make api-dev-all` | Start Rails server and Solid Queue (requires foreman) |

### Frontend
| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run test` | Run all tests |
| `npm run check` | TypeScript type check |
| `npm run check:watch` | Type check in watch mode |
| `npm run lint` | Run ESLint |

## Configuration Files

### Backend
- `api/Gemfile` - Ruby dependencies
- `api/config/database.yml` - Database configuration
- `api/config/routes.rb` - API routes
- `api/.rubocop.yml` - Ruby linting rules
- `api/.ruby-version` - Ruby version (3.4.8)
- `api/config/initializers/consts.rb` - Application constants (USER_ROLES, USER_THEMES, USER_LOCALES, LINK_TYPES, ASSET_TYPES, PUBLISHER_TYPES, AUDIT_ACTIONS, DEFAULT_PER_PAGE, DEFAULT_BATCH_SIZE, DEFAULT_CLEANUP_DAYS_OLD)

### Frontend
- `client/package.json` - Node dependencies and scripts
- `client/svelte.config.js` - SvelteKit configuration
- `client/vite.config.ts` - Vite and Vitest configuration
- `client/tsconfig.json` - TypeScript configuration
- `client/eslint.config.js` - ESLint configuration
- `client/.npmrc` - npm configuration

## Development Conventions

### Backend (Ruby/Rails)
- Follows Rails conventions and "Omakase" style via RuboCop
- Uses `ApplicationRecord` as base model class
- Test structure mirrors app structure (models, controllers, integration, etc.)

### Frontend (SvelteKit/TypeScript)
- Uses Svelte 5 runes mode for reactivity
- TypeScript strict mode enabled
- Tailwind CSS v4 for styling (Vite plugin)
- `$lib` alias for shared code imports
- File-based routing via `src/routes/`

## Current State

- **Backend**: Full CRUD API for User, Game, Platform, Publisher, PublisherText, Genre, GenreText, GameGenre, Review, UsersPlaytime, Link, and Asset models
- **Frontend**: Basic SvelteKit structure with Tailwind CSS
- **Documentation**: Swagger UI available at `/api-docs`
- **Background Jobs**: Solid Queue configured for async job processing (rating and playtime recalculation) with race condition protection
- **Seed Data**: Default users, platforms, publishers, publisher texts, genres, and genre texts
- **Audit Logging**: Complete audit logging system implemented with `AuditLog` model, `Auditable` concern, and `AuditLogService` for tracking all CREATE, UPDATE, DELETE operations on all models
- **Error Handling**: Standardized error handling via `Api::V1::BaseController` with consistent response formats and centralized exception handling using `rescue_from`
- **Constants**: Global application constants defined in `api/config/initializers/consts.rb` (USER_ROLES, USER_THEMES, DEFAULT_PER_PAGE, DEFAULT_BATCH_SIZE, DEFAULT_CLEANUP_DAYS_OLD, etc.)
- **Service Objects**: Business logic extracted into service classes for soft delete operations (UserDisableService, GameDisableService, PublisherDisableService, GenreDisableService, ReviewDeleteService, UsersPlaytimeDeleteService, LinkDeleteService)
- **Race Condition Fixes**: `GameRatingRecalculationService` and `UsersPlaytimeRecalculationService` use `find_or_create_by!` with unique partial indexes to prevent duplicate pending recalculations under high concurrency
- **JWT Security**: Access token blacklist implemented using PostgreSQL with automatic cleanup. Token versioning for bulk invalidation on security events (password change, account disable). Immediate token revocation on logout.
- **N+1 Query Optimization**: All controllers use eager loading (`.includes()`) to prevent N+1 query problems when rendering JSON responses with associations (platform, publisher, genres, game_texts, etc.). Background job services (GameRatingRecalculationService, UsersPlaytimeRecalculationService) use bulk loading (`Game.where(id: game_ids).index_by(&:id)`) to avoid N+1 when processing pending recalculations
- **Caching**: Rails.cache with MemoryStore in development. Cached data: active genres, platforms, publishers lists (1 hour TTL). Automatic cache invalidation on model save/destroy. Rake tasks for manual cache clear (`rails cache:clear_references`).

## User Entity

### Roles (`USER_ROLES`)

User roles are defined in `api/config/initializers/consts.rb`:

```ruby
USER_ROLES = {
  SUPER_ADMIN: 'SUPER_ADMIN',
  ADMIN: 'ADMIN',
  MODERATOR: 'MODERATOR',
  REGULAR: 'REGULAR'
}
```

Default role: `REGULAR`

### Themes (`USER_THEMES`)

```ruby
USER_THEMES = {
  LIGHT: 'light',
  DARK: 'dark'
}
```

Default theme: `LIGHT`

### Locales (`USER_LOCALES`)

```ruby
USER_LOCALES = {
  ENGLISH: 'en',
  RUSSIAN: 'ru'
}
```

Default locale: `ENGLISH`

### Model Fields

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `username` | string | Unique, min 3 chars, alphanumeric + spaces |
| `email` | string | Unique, valid email format |
| `password_digest` | string | BCrypt encrypted |
| `role` | string | One of USER_ROLES, default: REGULAR |
| `theme` | string | One of USER_THEMES, default: light |
| `locale` | string | One of USER_LOCALES, default: en |
| `is_disabled` | boolean | Default: false (soft delete flag) |
| `slug` | string | Unique, auto-generated from username |
| `created_at` | datetime | Auto-generated |
| `updated_at` | datetime | Auto-generated |

### Password Requirements

- Minimum 7 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character: `!@#$%^&*(),.?":{}|<>`

### Slug Generation

Auto-generated from username:
- Converted to lowercase
- Spaces replaced with underscores
- Special characters removed
- Example: `"Bob 22"` → `"bob_22"`

### Scopes

- `User.active` — returns users where `is_disabled: false`
- `User.disabled` — returns users where `is_disabled: true`
- `User.with_theme(theme)` — returns users with specified theme
- `User.with_locale(locale)` — returns users with specified locale

### Instance Methods

- `admin?` — true if role is SUPER_ADMIN or ADMIN
- `moderator?` — true if role is SUPER_ADMIN, ADMIN, or MODERATOR
- `regular?` — true if role is REGULAR
- `light_theme?` — true if theme is LIGHT
- `dark_theme?` — true if theme is DARK

### Class Methods

- `User.find_by_slug!(slug)` — find active user by slug (raises error if not found)
- `User.find_by_slug(slug)` — find active user by slug (returns nil if not found)

## Game Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique game ID |
| `name` | string | Required, indexed | Game name |
| `release_year` | integer | 1970-2100, indexed | Year of release |
| `rating_avg` | float | 0-10 | Average user rating (future: calculated) |
| `difficulty_avg` | float | 0-10 | Average difficulty rating (future: calculated) |
| `playtime_avg` | integer | >= 0 (minutes) | Average playtime (future: calculated) |
| `playtime_100_avg` | integer | >= 0 (minutes) | Average 100% completion time (future: calculated) |
| `is_dlc` | boolean | Default: false | DLC flag |
| `is_mod` | boolean | Default: false | Mod/room hack flag |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `base_game_id` | bigint | FK → games.id, nullable | Reference to original game |
| `platform_id` | bigint | FK → platforms.id, nullable | Reference to platform |
| `publisher_id` | bigint | FK → publishers.id, nullable | Reference to publisher |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :platform, optional: true` — associated platform (optional for backward compatibility)
- `belongs_to :base_game, class_name: "Game", optional: true` — associated base game
- `belongs_to :publisher, optional: true` — associated publisher
- `has_many :dlcs, class_name: "Game", foreign_key: :base_game_id` — DLCs for this game

### Self-Referencing Association

Games can reference other games via `base_game_id`:
- Used for DLCs, mods, and room hacks to link to their original game
- Foreign key constraint ensures referential integrity
- When base game is soft deleted, `base_game_id` should be set to NULL (manual handling)

### Platform Association

Games can be associated with a platform:
- Same game name can exist on different platforms (e.g., "The Witcher 3" on PC and PlayStation)
- `platform_id` is optional for backward compatibility with existing records
- When platform is soft deleted, `platform_id` is set to NULL (dependent: :nullify)

### Scopes

- `Game.active` — returns games where `is_disabled: false`
- `Game.disabled` — returns games where `is_disabled: true`
- `Game.with_base_game` — returns games with `base_game_id` present
- `Game.without_base_game` — returns games with `base_game_id` NULL
- `Game.dlcs` — returns games where `is_dlc: true`
- `Game.mods` — returns games where `is_mod: true`
- `Game.original_games` — returns games where both `is_dlc` and `is_mod` are false

### Instance Methods

- `dlc?` — true if `is_dlc` is true
- `mod?` — true if `is_mod` is true
- `original_game?` — true if both `is_dlc` and `is_mod` are false
- `base_game` — returns associated base game or self if no base_game_id

### Class Methods

- `Game.find_by_name!(name)` — find active game by name (raises error if not found)
- `Game.find_by_name(name)` — find active game by name (returns nil if not found)

## Platform Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique platform ID |
| `name` | string | Required | Platform name (e.g., "Nintendo Switch", "PC") |
| `slug` | string | Required, unique (case-insensitive) | URL-friendly identifier |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `has_many :games, dependent: :nullify` — games on this platform

### Scopes

- `Platform.active` — returns platforms where `is_disabled: false`
- `Platform.disabled` — returns platforms where `is_disabled: true`

### Instance Methods

- `games` — returns all games on this platform

### Class Methods

- `Platform.find_by_slug!(slug)` — find active platform by slug (raises error if not found)
- `Platform.find_by_slug(slug)` — find active platform by slug (returns nil if not found)

### Slug Generation

Auto-generated from name if not provided:
- Converted to lowercase
- Spaces replaced with hyphens
- Special characters removed
- Example: `"Nintendo Switch"` → `"nintendo-switch"`
- Example: `"Mobile (iOS)"` → `"mobile-ios"`

### Seed Data

The following platforms are seeded by default:
- Nintendo Switch, Sega MegaDrive, Super Nintendo, PC
- PlayStation, PlayStation 2, PlayStation 3, PlayStation 4, PlayStation 5
- Xbox, Xbox One, Xbox Series X/S
- Steam Deck, Mobile (iOS), Mobile (Android)
- Nintendo 3DS, Nintendo DS, PlayStation Vita, PSP, Game Boy Advance

## Publisher Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique publisher ID |
| `name` | string | Required, unique (case-insensitive) | Publisher name |
| `type` | string | Required, one of PUBLISHER_TYPES | Publisher type |
| `slug` | string | Required, unique (case-insensitive) | URL-friendly identifier |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Publisher Types (`PUBLISHER_TYPES`)

```ruby
PUBLISHER_TYPES = {
  PUBLISHER: 'PUBLISHER',   # Large publishing companies
  DEVELOPER: 'DEVELOPER',   # Developer studios
  PERSON: 'PERSON'          # Solo developers
}.freeze
```

### Associations

- `has_many :games, dependent: :nullify` — games published by this publisher

### Scopes

- `Publisher.active` — returns publishers where `is_disabled: false`
- `Publisher.disabled` — returns publishers where `is_disabled: true`
- `Publisher.publishers` — returns publishers with type PUBLISHER
- `Publisher.developers` — returns publishers with type DEVELOPER
- `Publisher.persons` — returns publishers with type PERSON

### Instance Methods

- `publisher?` — true if type is PUBLISHER
- `developer?` — true if type is DEVELOPER
- `person?` — true if type is PERSON
- `disable!` — soft deletes the publisher and nullifies associated games
- `restore!` — restores a soft-deleted publisher

### Class Methods

- `Publisher.find_by_slug!(slug)` — find active publisher by slug (raises error if not found)
- `Publisher.find_by_slug(slug)` — find active publisher by slug (returns nil if not found)

### Slug Generation

Auto-generated from name if not provided:
- Converted to lowercase
- Spaces replaced with hyphens
- Special characters removed
- Example: `"Nintendo"` → `"nintendo"`
- Example: `"CD Projekt Red"` → `"cd-projekt-red"`

### Seed Data

The following publishers are seeded by default:
- **PUBLISHER**: Nintendo, Sony Interactive Entertainment, Microsoft Studios, Valve
- **DEVELOPER**: CD Projekt Red, FromSoftware, Indie Studio
- **PERSON**: Toby Fox, Eric Barone, Lucas Pope

### Publisher Methods

- `description_for(locale)` — returns description for specified locale (e.g., "en", "ru")
- `all_descriptions` — returns all descriptions ordered by lang_code

## PublisherText Entity

### Overview

Localized descriptions for publishers. Each publisher can have multiple descriptions in different languages.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique publisher text ID |
| `publisher_id` | bigint | FK → publishers.id, required | Publisher this text belongs to |
| `lang_code` | string | Required, 2 chars, `[a-z]{2}` | Language code (ISO 639-1) |
| `description` | text | Max 10000 chars, optional | Publisher description |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :publisher` — associated publisher

### Scopes

- `PublisherText.active` — returns texts for active publishers only
- `PublisherText.by_lang(lang_code)` — filters by language code
- `PublisherText.for_publisher(publisher_id)` — filters by publisher

### Unique Constraint

Only one description per language per publisher (enforced by unique index on `[:publisher_id, :lang_code]`).

### Cascade Delete

When a publisher is destroyed, all its publisher_texts are destroyed automatically (`dependent: :destroy`).

### Seed Data

The following publisher texts are seeded by default (en + ru for each publisher):
- Nintendo, Sony Interactive Entertainment, Microsoft Studios, Valve
- CD Projekt Red, FromSoftware
- Toby Fox, Eric Barone

## GameText Entity

### Overview

Localized descriptions and trivia for games. Each game can have multiple texts in different languages.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique game text ID |
| `game_id` | bigint | FK → games.id, required | Game this text belongs to |
| `lang_code` | string | Required, 2 chars, `[a-z]{2}` | Language code (ISO 639-1) |
| `description` | text | Max 10000 chars, optional | Game description |
| `trivia` | text | Max 10000 chars, optional | Interesting facts about the game |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :game` — associated game

### Scopes

- `GameText.active` — returns texts for active games only
- `GameText.by_lang(lang_code)` — filters by language code
- `GameText.for_game(game_id)` — filters by game

### Unique Constraint

Only one description per language per game (enforced by unique index on `[:game_id, :lang_code]`).

### Cascade Delete

When a game is destroyed, all its game_texts are destroyed automatically (`dependent: :destroy`).

### Game Model Methods

- `description_for(locale)` — returns description for specified locale (e.g., "en", "ru")
- `trivia_for(locale)` — returns trivia for specified locale
- `all_texts` — returns all texts ordered by lang_code

## Genre Entity

### Overview

Genres for games. Each game can have multiple genres through the `game_genres` join table. Genres support localized descriptions.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique genre ID |
| `name` | string | Required, unique (case-insensitive) | Genre name in English (e.g., "RPG", "Action") |
| `slug` | string | Required, unique (case-insensitive) | URL-friendly identifier |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `has_many :genre_texts, dependent: :destroy` — localized descriptions
- `has_many :game_genres, dependent: :destroy` — game associations
- `has_many :games, through: :game_genres` — games with this genre

### Scopes

- `Genre.active` — returns genres where `is_disabled: false`
- `Genre.disabled` — returns genres where `is_disabled: true`

### Instance Methods

- `disable!` — soft deletes the genre and nullifies associated game_genres
- `restore!` — restores a soft-deleted genre
- `description_for(locale)` — returns description for specified locale (e.g., "en", "ru")
- `all_descriptions` — returns all descriptions ordered by lang_code

### Class Methods

- `Genre.find_by_slug!(slug)` — find active genre by slug (raises error if not found)
- `Genre.find_by_slug(slug)` — find active genre by slug (returns nil if not found)

### Slug Generation

Auto-generated from name if not provided:
- Converted to lowercase
- Spaces replaced with hyphens
- Special characters removed
- Example: `"Role Playing Game"` → `"role-playing-game"`
- Example: `"Hack & Slash"` → `"hack-slash"`

### Seed Data

The following genres are seeded by default:
- Action, Adventure, RPG, Strategy, Simulation
- Sports, Racing, Puzzle, Platformer, Fighting
- Horror, Stealth, Survival, MOBA, Battle Royale
- Souls-like, Metroidvania, Roguelike, Roguelite
- Visual Novel, Card Game, Board Game

## GenreText Entity

### Overview

Localized descriptions for genres. Each genre can have multiple descriptions in different languages.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique genre text ID |
| `genre_id` | bigint | FK → genres.id, required | Genre this text belongs to |
| `lang_code` | string | Required, 2 chars, `[a-z]{2}` | Language code (ISO 639-1) |
| `description` | text | Max 10000 chars, optional | Genre description |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :genre` — associated genre

### Scopes

- `GenreText.active` — returns texts for active genres only
- `GenreText.by_lang(lang_code)` — filters by language code
- `GenreText.for_genre(genre_id)` — filters by genre

### Unique Constraint

Only one description per language per genre (enforced by unique index on `[:genre_id, :lang_code]`).

### Cascade Delete

When a genre is destroyed, all its genre_texts are destroyed automatically (`dependent: :destroy`).

## GameGenre Entity

### Overview

Join table for many-to-many relationship between games and genres.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique game genre ID |
| `game_id` | bigint | FK → games.id, required | Game being associated |
| `genre_id` | bigint | FK → genres.id, required | Genre being associated |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :game` — associated game
- `belongs_to :genre` — associated genre

### Scopes

- `GameGenre.active` — returns game_genres where `is_disabled: false`
- `GameGenre.disabled` — returns game_genres where `is_disabled: true`

### Unique Constraint

A game can only have one active association per genre (enforced by unique partial index on `[:game_id, :genre_id]` where `is_disabled = false`).

### Instance Methods

- `disable!` — soft deletes the association
- `restore!` — restores a soft-deleted association

### Cascade Delete

When a game or genre is destroyed, all associated game_genres are destroyed automatically (`dependent: :destroy`).

## Review Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique review ID |
| `user_id` | bigint | FK → users.id, required, indexed | User who wrote the review |
| `game_id` | bigint | FK → games.id, required, indexed | Game being reviewed |
| `rating` | integer | 0-10, required | User's rating (0-10) |
| `difficulty` | integer | 0-10, required | User's difficulty rating (0-10) |
| `comment` | text | max 10000 chars, optional | Review comment |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :user` — associated user
- `belongs_to :game` — associated game

### Scopes

- `Review.active` — returns reviews where `is_disabled: false`
- `Review.disabled` — returns reviews where `is_disabled: true`

### Unique Constraint

A user can only have one active review per game (enforced by unique partial index on `[:user_id, :game_id]` where `is_disabled = false`).

### Callbacks

- `after_create` — automatically enqueues game rating recalculation job
- `after_update` — enqueues recalculation if rating, difficulty, or is_disabled changed
- `after_destroy` — enqueues recalculation job

## UsersPlaytime Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique users playtime ID |
| `user_id` | bigint | FK → users.id, required, indexed | User who recorded the playtime |
| `game_id` | bigint | FK → games.id, required, indexed | Game being recorded |
| `minutes_regular` | integer | >= 0, nullable | Time to complete the game in minutes |
| `minutes_100` | integer | >= 0, nullable | Time to 100% complete the game in minutes |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Associations

- `belongs_to :user` — associated user
- `belongs_to :game` — associated game

### Scopes

- `UsersPlaytime.active` — returns playtimes where `is_disabled: false`
- `UsersPlaytime.disabled` — returns playtimes where `is_disabled: true`

### Unique Constraint

A user can only have one active playtime record per game (enforced by unique partial index on `[:user_id, :game_id]` where `is_disabled = false`).

### Callbacks

- `after_create` — automatically enqueues game playtime recalculation job
- `after_update` — enqueues recalculation if minutes_regular, minutes_100, or is_disabled changed
- `after_destroy` — enqueues recalculation job

### Class Methods

- `UsersPlaytime.find_by_user_and_game(user_id, game_id)` — find active playtime by user and game (returns nil if not found)

## UsersPlaytimeRecalculation Entity

### Overview

Tracks pending playtime recalculation tasks for games. Used by `UsersPlaytimeRecalculationService` to prevent duplicate recalculation requests.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique recalculation ID |
| `game_id` | bigint | FK → games.id, required | Game to recalculate |
| `scheduled_at` | datetime | Required | When the recalculation was scheduled |
| `processed_at` | datetime | Nullable | When the recalculation was completed |
| `status` | string | Required: pending, processing, completed, failed | Current status |
| `error_message` | text | Nullable | Error message if failed |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Scopes

- `pending` — where `status: 'pending'`
- `processing` — where `status: 'processing'`
- `completed` — where `status: 'completed'`
- `failed` — where `status: 'failed'`
- `for_processing` — pending recalculations where `scheduled_at <= Time.current`

### Unique Constraint

Only one pending recalculation per game (enforced by unique partial index on `[:game_id, :status]` where `status = 'pending'`).

## AuditLog Entity

### Overview

Audit logging system that tracks all changes (CREATE, UPDATE, DELETE) to records in other tables. Provides a complete history of who changed what and when.

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique audit log ID |
| `user_id` | bigint | FK → users.id, nullable | User who made the change (nullable for system actions) |
| `table_name` | varchar | Required, indexed | Name of the table where change occurred |
| `record_id` | bigint | Required | ID of the record that was changed |
| `action` | varchar | Required, indexed: CREATE, UPDATE, DELETE | Type of action |
| `old_values` | jsonb | Default: {} | Old field values (for UPDATE and DELETE) |
| `new_values` | jsonb | Default: {} | New field values (for CREATE and UPDATE) |
| `created_at` | datetime | Auto-generated, indexed | When the change occurred |

### Associations

- `belongs_to :user, optional: true` — associated user (nullable)

### Scopes

- `AuditLog.by_action(action)` — filter by action type
- `AuditLog.by_table(table_name)` — filter by table name
- `AuditLog.by_user(user_id)` — filter by user ID
- `AuditLog.recent` — order by created_at DESC (newest first)

### Constants (`AUDIT_ACTIONS`)

```ruby
AUDIT_ACTIONS = {
  CREATE: 'CREATE',
  UPDATE: 'UPDATE',
  DELETE: 'DELETE'
}.freeze
```

### Database Indexes

- `index_audit_logs_on_user_id` — for filtering by user
- `index_audit_logs_on_table_name` — for filtering by table
- `index_audit_logs_on_action` — for filtering by action type
- `index_audit_logs_on_created_at` — for sorting by time
- `index_audit_logs_on_table_and_record` — composite index for fast lookups

### Constraints

- CHECK constraint on `action`: must be 'CREATE', 'UPDATE', or 'DELETE'
- Foreign key on `user_id` with `ON DELETE NULLIFY` (user deletion doesn't remove audit logs)

## AuditLogService

### Overview

Service class for creating and formatting audit log entries.

### Methods

- `AuditLogService.log_action(user_id:, table_name:, record_id:, action:, old_values:, new_values:)` — create audit log entry
- `AuditLogService.log_create(user_id:, table_name:, record_id:, new_values:)` — convenience method for CREATE actions
- `AuditLogService.log_update(user_id:, table_name:, record_id:, old_values:, new_values:)` — convenience method for UPDATE actions
- `AuditLogService.log_delete(user_id:, table_name:, record_id:, old_values:)` — convenience method for DELETE actions
- `AuditLogService.get_human_readable_table_name(table_name, locale)` — get localized table name
- `AuditLogService.get_human_readable_field_name(table_name, field_name, locale)` — get localized field name
- `AuditLogService.format_for_api(audit_log, locale)` — format audit log for API response with localization

### Localization

Table and field names are localized using I18n:
- English: `config/locales/en.yml` → `audit.tables.*` and `audit.fields.*`
- Russian: `config/locales/ru.yml` → `audit.tables.*` and `audit.fields.*`

## Auditable Concern

### Overview

Module that can be included in any ActiveRecord model to automatically create audit logs on CREATE, UPDATE, and DELETE operations.

### Usage

```ruby
class Game < ApplicationRecord
  include Auditable
  # ... rest of model
end
```

### Callbacks

- `after_create` — creates audit log with action CREATE
- `after_update` — creates audit log with action UPDATE (only if attributes changed)
- `before_destroy` — creates audit log with action DELETE (for soft delete)

### Current User Tracking

The concern uses `Thread.current[:current_user_id]` to track the current user. This is set by the `CurrentUserAudit` controller concern.

## CurrentUserAudit Concern

### Overview

Controller concern that sets the current user ID in `Thread.current[:current_user_id]` for audit logging.

### Usage

```ruby
class ApplicationController < ActionController::API
  include CurrentUserAudit
end
```

### How It Works

- `before_action :set_current_user_id` — sets `Thread.current[:current_user_id]` from `current_user.id`
- `after_action :clear_current_user_id` — clears the value after the request

## AuditLogJob

### Overview

Background job that creates audit log entries asynchronously using Solid Queue.

### Usage

```ruby
AuditLogJob.perform_later(
  user_id: 1,
  table_name: "games",
  record_id: 42,
  action: AUDIT_ACTIONS::UPDATE,
  old_values: { "name" => "Old Name" },
  new_values: { "name" => "New Name" }
)
```

## Link Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique link ID |
| `game_id` | bigint | FK → games.id, required, indexed | Game being linked |
| `link_type` | string | Required, one of LINK_TYPES | Type of link |
| `url` | text | Required | URL of the link |
| `title` | string | Required, 1-255 chars | Title of the link |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Link Types (`LINK_TYPES`)

```ruby
LINK_TYPES = {
  TRAILER: 'TRAILER',
  LONGPLAY: 'LONGPLAY',
  SPEEDRUN: 'SPEEDRUN',
  OTHER: 'OTHER'
}.freeze
```

### Associations

- `belongs_to :game` — associated game

### Scopes

- `Link.active` — returns links where `is_disabled: false`
- `Link.disabled` — returns links where `is_disabled: true`
- `Link.by_type(type)` — returns links with specified type

### Instance Methods

- `trailer?` — true if link_type is TRAILER
- `longplay?` — true if link_type is LONGPLAY
- `speedrun?` — true if link_type is SPEEDRUN
- `other?` — true if link_type is OTHER
- `type_label` — returns capitalized link type (e.g., "Trailer")
- `disable!` — soft deletes the link
- `restore!` — restores a soft-deleted link

### Callbacks

- `before_validation` — normalizes link_type to uppercase

### Game Model Integration

**`Game#links`**: Has-many association with dependent: :destroy

## Asset Entity

### Model Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | bigint | Primary key | Unique asset ID |
| `game_id` | bigint | FK → games.id, required, indexed | Game this asset belongs to |
| `asset_type` | string | Required, one of ASSET_TYPES | Type of asset |
| `storage_path` | string | Required | Path to file in Active Storage |
| `mime_type` | string | Required | MIME type of the file |
| `file_size` | integer | Required, > 0 | File size in bytes |
| `order_index` | integer | >= 0, nullable | Order index for sorting |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Asset Types (`ASSET_TYPES`)

```ruby
ASSET_TYPES = {
  COVER: 'COVER',
  SCREENSHOT: 'SCREENSHOT',
  MANUAL: 'MANUAL'
}.freeze
```

### Associations

- `belongs_to :game` — associated game

### Scopes

- `Asset.active` — returns assets where `is_disabled: false`
- `Asset.disabled` — returns assets where `is_disabled: true`
- `Asset.by_type(type)` — returns assets with specified type
- `Asset.ordered` — returns assets ordered by `order_index`

### Instance Methods

- `cover?` — true if asset_type is COVER
- `screenshot?` — true if asset_type is SCREENSHOT
- `manual?` — true if asset_type is MANUAL
- `type_label` — returns capitalized asset type (e.g., "Cover")
- `disable!` — soft deletes the asset
- `restore!` — restores a soft-deleted asset

### Callbacks

- `before_validation` — normalizes asset_type to uppercase

### Game Model Integration

**`Game#assets`**: Has-many association with dependent: :destroy

### File Upload Service

**AssetUploadService**: Service class that handles file uploads:
- `upload(game_id, file, asset_type, order_index: nil)` — uploads file and creates asset record
- `remove(asset_id)` — soft deletes asset and purges file from storage
- `replace(asset_id, new_file)` — replaces file and updates metadata
- `download_url(asset_id, expires_in: 5.minutes)` — generates temporary download URL

### File Restrictions

| Parameter | Value |
|-----------|-------|
| Max file size | 10 MB |
| Allowed MIME types | `image/jpeg`, `image/png`, `image/webp`, `application/pdf` |

### Storage Configuration

**Development**: Files stored in `api/tmp/storage/` via Active Storage Disk Service

**Production**: S3-compatible storage (configuration in `config/storage.yml`)

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/games/:game_id/assets` | List assets for a game (paginated) |
| POST | `/api/v1/games/:game_id/assets` | Upload new asset (multipart/form-data) |
| GET | `/api/v1/assets/:id` | Get asset metadata |
| PATCH | `/api/v1/assets/:id` | Update asset metadata (order_index) |
| DELETE | `/api/v1/assets/:id` | Soft delete asset |
| GET | `/api/v1/assets/:id/download` | Get temporary download URL |

### Query Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `page` | 1 | Page number for pagination |
| `per_page` | 20 | Items per page |
| `asset_type` | — | Filter by type (COVER, SCREENSHOT, MANUAL) |

## Service Objects

### Overview

Business logic for soft delete and restore operations is encapsulated in service objects. All services use transactions for atomicity and create audit logs automatically.

### Disable/Delete Services

**UserDisableService**: Handles user soft delete and restore:
- `UserDisableService.call(user, current_user: nil)` — soft deletes user and associated records (reviews, playtimes)
- `UserDisableService.restore(user, current_user: nil)` — restores a soft-deleted user
- Creates audit logs for all operations
- Raises `UserDisableService::UserDisableError` on errors

**GameDisableService**: Handles game soft delete and restore:
- `GameDisableService.call(game, current_user: nil)` — soft deletes game, nullifies DLCs, reviews, and playtimes
- `GameDisableService.restore(game, current_user: nil)` — restores a soft-deleted game
- Creates audit logs for all operations
- Raises `GameDisableService::GameDisableError` on errors

**PublisherDisableService**: Handles publisher soft delete and restore:
- `PublisherDisableService.call(publisher, current_user: nil)` — soft deletes publisher and nullifies associated games
- `PublisherDisableService.restore(publisher, current_user: nil)` — restores a soft-deleted publisher
- Creates audit logs for all operations
- Raises `PublisherDisableService::PublisherDisableError` on errors

**GenreDisableService**: Handles genre soft delete and restore:
- `GenreDisableService.call(genre, current_user: nil)` — soft deletes genre and associated game_genres
- `GenreDisableService.restore(genre, current_user: nil)` — restores a soft-deleted genre
- Creates audit logs for all operations
- Raises `GenreDisableService::GenreDisableError` on errors

**ReviewDeleteService**: Handles review soft delete:
- `ReviewDeleteService.call(review, current_user: nil)` — soft deletes review and enqueues rating recalculation
- Creates audit logs for all operations
- Raises `ReviewDeleteService::ReviewDeleteError` on errors

**UsersPlaytimeDeleteService**: Handles playtime record soft delete:
- `UsersPlaytimeDeleteService.call(users_playtime, current_user: nil)` — soft deletes playtime and enqueues recalculation
- Creates audit logs for all operations
- Raises `UsersPlaytimeDeleteService::UsersPlaytimeDeleteError` on errors

**LinkDeleteService**: Handles link soft delete and restore:
- `LinkDeleteService.call(link, current_user: nil)` — soft deletes link
- `LinkDeleteService.restore(link, current_user: nil)` — restores a soft-deleted link
- Creates audit logs for all operations
- Raises `LinkDeleteService::LinkDeleteError` on errors

### Base Service Class

**ApplicationService**: Base module for service objects:
- `ApplicationService::BaseError` — base error class for all services
- `ApplicationService::ValidationError` — validation error with errors array
- `ApplicationService::NotFoundError` — resource not found error
- `ApplicationService::UnauthorizedError` — authorization error

## Background Jobs: Playtime Recalculation

### Overview

Game playtime statistics (`playtime_avg` and `playtime_100_avg`) are recalculated asynchronously using Solid Queue. When a `UsersPlaytime` record is created, updated, or deleted, a recalculation task is enqueued.

### Components

**UsersPlaytimeRecalculationService**: Service class that handles:
- `enqueue(game_id)` — adds a game to the recalculation queue (prevents duplicates via `find_or_create_by!`)
- `enqueue_bulk(game_ids)` — adds multiple games to the queue (race condition safe)
- `process_pending` — processes all pending recalculations (up to 100 at a time)
- `process_recalculation(recalculation)` — processes a single recalculation task
- `cleanup_old(days_old: 7)` — removes old completed recalculation records

**Race Condition Protection**: The `enqueue` method uses `find_or_create_by!` with a unique partial index on `[game_id, status]` where `status = 'pending'` to prevent duplicate pending recalculations under high concurrency.

**UsersPlaytimeRecalculationJob**: Job that processes a single recalculation task by calling `UsersPlaytimeRecalculationService.process_recalculation`.

**ProcessPendingPlaytimeRecalculationsJob**: Scheduled job that runs every 5 minutes to process pending recalculations.

**CleanupOldPlaytimeRecalculationsJob**: Scheduled job that runs daily at 3 AM to clean up old records.

### Game Model Integration

**`Game#recalculate_playtime_avg`**: Instance method that recalculates `playtime_avg` and `playtime_100_avg` from active `UsersPlaytime` records:
- Calculates average `minutes_regular` for `playtime_avg`
- Calculates average `minutes_100` for `playtime_100_avg`
- Sets values to `nil` if no active playtimes exist
- Ignores disabled playtimes (`is_disabled: true`)

### Scheduled Tasks (config/recurring.yml)

```yaml
development:
  process_pending_playtime_recalculations:
    class: ProcessPendingPlaytimeRecalculationsJob
    queue: default
    schedule: every 5 minutes

  cleanup_old_playtime_recalculations:
    class: CleanupOldPlaytimeRecalculationsJob
    queue: default
    schedule: at 3am every day
```

### Running Background Jobs

**Start Solid Queue worker:**
```bash
cd api && bin/rails solid_queue:start
# or
make api-queue
```

**Start Rails server and Solid Queue together (requires foreman):**
```bash
cd api && foreman start -f Procfile.dev
# or from project root
make api-dev-all
```

**Install foreman:**
```bash
gem install foreman
```

## Background Jobs: Rating Recalculation

### Overview

Game ratings (`rating_avg` and `difficulty_avg`) are recalculated asynchronously using Solid Queue. When a review is created, updated, or deleted, a job is enqueued to recalculate the averages for the associated game.

### Components

**Solid Queue**: Official Rails background job processor using PostgreSQL as backend.

**GameRatingRecalculationService**: Service class that handles:
- `enqueue(game_id)` — adds a game to the recalculation queue (prevents duplicates via `find_or_create_by!`)
- `enqueue_bulk(game_ids)` — adds multiple games to the queue (race condition safe)
- `process_pending` — processes all pending recalculations
- `process_recalculation(recalculation)` — processes a single recalculation task
- `cleanup_old(days_old: 7)` — removes old completed recalculation records

**Race Condition Protection**: The `enqueue` method uses `find_or_create_by!` with a unique partial index on `[game_id, status]` where `status = 'pending'` to prevent duplicate pending recalculations under high concurrency.

**GameRatingRecalculationJob**: Job that performs the actual recalculation for a single game.

**ProcessPendingRecalculationsJob**: Scheduled job that runs every 5 minutes to process pending recalculations.

**CleanupOldRecalculationsJob**: Scheduled job that runs daily at 3 AM to clean up old records.

### Recalculation Table

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `game_id` | bigint | FK → games.id |
| `scheduled_at` | datetime | When the recalculation was scheduled |
| `processed_at` | datetime | When the recalculation was completed |
| `status` | string | pending, processing, completed, failed |
| `error_message` | text | Error message if failed |

### Scheduled Tasks (config/recurring.yml)

```yaml
development:
  process_pending_recalculations:
    class: ProcessPendingRecalculationsJob
    queue: default
    schedule: every 5 minutes

  cleanup_old_recalculations:
    class: CleanupOldRecalculationsJob
    queue: default
    schedule: at 3am every day
```

## Best Practices: `average()` Nil Handling

### Problem

PostgreSQL `AVG()` aggregate function returns `NULL` when:
1. The result set is empty
2. All values in the aggregated column are `NULL`

In Rails, `ActiveRecord#average()` returns `nil` in both cases. Calling `.to_f` or `.to_i` on `nil` silently converts it to `0.0` or `0`, which corrupts statistics data.

### Correct Pattern

```ruby
# ✅ Correct - preserves nil
rating_avg = records.average(:rating)&.to_f&.round(2)
playtime_avg = records.average(:minutes_regular)&.to_i

# ✅ Correct - explicit check
avg = records.average(:column)
value = avg ? avg.to_f.round(2) : nil

# ❌ Wrong - nil silently becomes 0.0
rating_avg = records.average(:rating).to_f.round(2)
playtime_avg = records.average(:minutes_regular).to_i
```

### Affected Files

| File | Method | Fields |
|------|--------|--------|
| `app/services/game_rating_recalculation_service.rb` | `process_recalculation_for_game`, `process_recalculation` | `rating_avg`, `difficulty_avg` |
| `app/services/users_playtime_recalculation_service.rb` | `process_recalculation` | `playtime_avg`, `playtime_100_avg` |
| `app/models/game.rb` | `recalculate_playtime_avg` | `playtime_avg`, `playtime_100_avg` |

### Testing Requirements

When writing tests for methods using `average()`, cover these scenarios:
- Records exist, all values are `NULL` → result should be `nil`
- Records exist, mixed `NULL` and numeric values → correct average of non-NULL values
- Records exist, all values are `0` → result should be `0` (valid data, not nil)
- No records exist → result should be `nil`

### API Response Schema

All average fields in API responses are nullable (`nullable: true` in OpenAPI spec):
- `rating_avg`, `difficulty_avg` — can be `null` when no active reviews exist or all reviews have `NULL` ratings
- `playtime_avg`, `playtime_100_avg` — can be `null` when no active playtimes exist or all playtimes have `NULL` minutes

## Error Handling

All API error responses follow a standardized format handled by `Api::V1::BaseController`.

### Standard Error Response Formats

| HTTP Status | Format | Description |
|-------------|--------|-------------|
| `422 Unprocessable Entity` | `{ errors: ["message1", "message2"] }` | Validation errors |
| `404 Not Found` | `{ error: "Resource not found" }` | Resource not found |
| `400 Bad Request` | `{ error: "Invalid request" }` | Bad request (e.g., invalid locale/theme) |
| `401 Unauthorized` | `{ error: "Authentication required" }` | Authentication required |
| `500 Internal Server Error` | `{ error: "Internal server error" }` | Unexpected server error |

### BaseController Features

**Centralized Exception Handling:**

```ruby
module Api
  module V1
    class BaseController < ApplicationController
      # Catches ActiveRecord::RecordNotFound and returns 404
      rescue_from ActiveRecord::RecordNotFound do |e|
        render_not_found(e.model.class.name.demodulize.humanize)
      end

      # Catches ActionController::ParameterMissing and returns 400
      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "Missing required parameter: #{e.param}" }, status: :bad_request
      end

      # Catches all other exceptions and returns 500
      rescue_from StandardError do |e|
        Rails.logger.error(e)
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
```

**Helper Methods:**

| Method | Description | Example |
|--------|-------------|---------|
| `render_validation_errors(model, status: :unprocessable_entity)` | Returns validation errors from model | `render_validation_errors(@user)` |
| `render_not_found(resource_name)` | Returns 404 with custom resource name | `render_not_found("User")` |
| `render_service_error(message, status: :unprocessable_entity)` | Returns service error with custom status | `render_service_error("Upload failed", :bad_request)` |

### Resource-Specific Error Handlers

Each controller inherits these helper methods from BaseController:

- `user_not_found` — returns 404 for User
- `game_not_found` — returns 404 for Game
- `asset_not_found` — returns 404 for Asset
- `publisher_not_found` — returns 404 for Publisher
- `genre_not_found` — returns 404 for Genre

### Service Exception Handling (AssetsController Example)

```ruby
class AssetsController < BaseController
  rescue_from AssetUploadService::InvalidFileSizeError,
              AssetUploadService::InvalidMimeTypeError do |e|
    render_service_error(e.message, :bad_request)
  end

  rescue_from AssetUploadService::ValidationError do |e|
    render json: { errors: [ e.message ] }, status: :unprocessable_entity
  end

  rescue_from AssetUploadService::UploadError do |e|
    render_service_error(e.message, :unprocessable_entity)
  end

  rescue_from AssetUploadService::Error do |e|
    render_service_error(e.message, :not_found)
  end
end
```

### Example Controller Usage

```ruby
module Api
  module V1
    class UsersController < BaseController
      def create
        @user = User.new(user_params)
        if @user.save
          render template: "api/v1/users/create", status: :created
        else
          render_validation_errors(@user)  # Returns 422 with { errors: [...] }
        end
      end

      def show
        @user = User.find_by_slug(params[:id])
        user_not_found unless @user  # Returns 404 with { error: "User not found" }
        render template: "api/v1/users/show", status: :ok
      end
    end
  end
end
```

## API Endpoints

All endpoints are under `/api/v1` namespace.

### Users API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users` | List active users (paginated) |
| GET | `/api/v1/users/:slug` | Get user by slug |
| POST | `/api/v1/users` | Create new user |
| PATCH | `/api/v1/users/:slug` | Update user |
| PATCH | `/api/v1/users/:id/disable` | Soft delete user |
| PATCH | `/api/v1/users/:id/update_theme` | Update user theme (light/dark) |
| PATCH | `/api/v1/users/:id/update_locale` | Update user locale (en/ru) |

### Games API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/games` | List active games (paginated) |
| GET | `/api/v1/games/:name` | Get game by name |
| POST | `/api/v1/games` | Create new game |
| PATCH | `/api/v1/games/:name` | Update game |
| PATCH | `/api/v1/games/:id/disable` | Soft delete game |

### Platforms API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/platforms` | List active platforms (paginated) |
| GET | `/api/v1/platforms/:slug` | Get platform by slug |

### Publishers API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/publishers` | List active publishers (paginated) |
| GET | `/api/v1/publishers/:slug` | Get publisher by slug |
| POST | `/api/v1/publishers` | Create new publisher |
| PATCH | `/api/v1/publishers/:slug` | Update publisher |
| PATCH | `/api/v1/publishers/:slug/disable` | Soft delete publisher |

### PublisherTexts API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/publisher_texts` | List all publisher texts (paginated) |
| GET | `/api/v1/publisher_texts/:id` | Get publisher text by ID |
| GET | `/api/v1/publishers/:slug/publisher_texts` | List texts for a publisher |
| POST | `/api/v1/publisher_texts` | Create new publisher text |
| POST | `/api/v1/publishers/:slug/publisher_texts` | Create text for a publisher |
| PATCH | `/api/v1/publisher_texts/:id` | Update publisher text |
| DELETE | `/api/v1/publisher_texts/:id` | Delete publisher text |

### GameTexts API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/game_texts` | List all game texts (paginated) |
| GET | `/api/v1/game_texts/:id` | Get game text by ID |
| GET | `/api/v1/games/:game_id/game_texts` | List texts for a game |
| POST | `/api/v1/game_texts` | Create new game text |
| POST | `/api/v1/games/:game_id/game_texts` | Create text for a game |
| PATCH | `/api/v1/game_texts/:id` | Update game text |
| DELETE | `/api/v1/game_texts/:id` | Delete game text |

### Genres API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/genres` | List all genres (paginated) |
| GET | `/api/v1/genres/:slug` | Get genre by slug |
| POST | `/api/v1/genres` | Create new genre |
| PATCH | `/api/v1/genres/:slug` | Update genre |
| PATCH | `/api/v1/genres/:slug/disable` | Soft delete genre |

### GenreTexts API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/genre_texts` | List all genre texts (paginated) |
| GET | `/api/v1/genre_texts/:id` | Get genre text by ID |
| GET | `/api/v1/genres/:genre_slug/genre_texts` | List texts for a genre |
| POST | `/api/v1/genre_texts` | Create new genre text |
| POST | `/api/v1/genres/:genre_slug/genre_texts` | Create text for a genre |
| PATCH | `/api/v1/genre_texts/:id` | Update genre text |
| DELETE | `/api/v1/genre_texts/:id` | Delete genre text |

### GameGenres API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/game_genres` | List all game genres (paginated) |
| POST | `/api/v1/game_genres` | Create game genre association |
| DELETE | `/api/v1/game_genres` | Delete game genre association |
| GET | `/api/v1/games/:game_id/game_genres` | List genres for a game (paginated) |
| POST | `/api/v1/games/:game_id/game_genres` | Add genre to a game |

### Reviews API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/reviews` | List all reviews (paginated) |
| GET | `/api/v1/reviews/:id` | Get review by ID |
| POST | `/api/v1/reviews` | Create new review |
| PATCH | `/api/v1/reviews/:id` | Update review |
| DELETE | `/api/v1/reviews/:id` | Soft delete review |
| GET | `/api/v1/games/:game_id/reviews` | List reviews for a game (paginated) |
| GET | `/api/v1/users/:user_id/reviews` | List reviews by a user (paginated) |

### Users Playtimes API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users_playtimes` | List all users playtimes (paginated) |
| GET | `/api/v1/users_playtimes/:id` | Get users playtime by ID |
| POST | `/api/v1/users_playtimes` | Create new users playtime |
| PATCH | `/api/v1/users_playtimes/:id` | Update users playtime |
| DELETE | `/api/v1/users_playtimes/:id` | Soft delete users playtime |
| GET | `/api/v1/games/:game_id/users_playtimes` | List users playtimes for a game (paginated) |
| GET | `/api/v1/users/:user_id/users_playtimes` | List users playtimes by a user (paginated) |

### Links API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/links` | List all links (paginated) |
| GET | `/api/v1/links/:id` | Get link by ID |
| POST | `/api/v1/links` | Create new link |
| PATCH | `/api/v1/links/:id` | Update link |
| DELETE | `/api/v1/links/:id` | Soft delete link |
| GET | `/api/v1/games/:game_id/links` | List links for a game (paginated) |
| POST | `/api/v1/games/:game_id/links` | Create new link for a game |

### Assets API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/assets` | List all assets (paginated) |
| GET | `/api/v1/assets/:id` | Get asset by ID |
| POST | `/api/v1/assets` | Create new asset |
| PATCH | `/api/v1/assets/:id` | Update asset |
| DELETE | `/api/v1/assets/:id` | Soft delete asset |
| GET | `/api/v1/assets/:id/download` | Get download URL for asset |
| GET | `/api/v1/games/:game_id/assets` | List assets for a game (paginated) |
| POST | `/api/v1/games/:game_id/assets` | Upload new asset for a game (multipart/form-data) |

### Query Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `page` | 1 | Page number for pagination |
| `per_page` | 20 | Items per page |

## API Documentation

Swagger UI is available at: **http://localhost:3000/api-docs**

OpenAPI specification: `api/swagger/v1/swagger.yaml`

## Swagger Documentation Rules

When modifying or extending the Swagger/OpenAPI documentation (`api/swagger/v1/swagger.yaml`), follow these rules:

### 1. Resource-Specific Error Schemas

**NEVER** use generic error schemas like `ErrorResponse` or `NotFoundError` for multiple resources.

**ALWAYS** create resource-specific error schemas:

```yaml
# ✅ Correct
UserErrorResponse:
  example: ["Email has already been taken", "Password is too short"]

GameErrorResponse:
  example: ["Name has already been taken", "Release year is out of valid range"]

UserNotFoundError:
  example: "User not found"

GameNotFoundError:
  example: "Game not found"
```

```yaml
# ❌ Wrong - generic schema used for all resources
ErrorResponse:
  example: ["Email has already been taken"]  # Wrong for games!

NotFoundError:
  example: "User not found"  # Wrong for games!
```

### 2. Schema Naming Convention

Use the pattern: `{Resource}{ErrorType}`

| Error Type | Schema Name Pattern | Example |
|------------|---------------------|---------|
| Validation errors (422) | `{Resource}ErrorResponse` | `UserErrorResponse`, `GameErrorResponse` |
| Not found errors (404) | `{Resource}NotFoundError` | `UserNotFoundError`, `GameNotFoundError` |
| Bad request errors (400) | `{Resource}BadRequestError` | `UserBadRequestError` |

### 3. Endpoint Response References

Each endpoint must reference its own resource-specific error schemas:

```yaml
# Users endpoints → User* schemas
/api/v1/users:
  post:
    responses:
      '422':
        schema:
          $ref: '#/components/schemas/UserErrorResponse'
      '404':
        schema:
          $ref: '#/components/schemas/UserNotFoundError'

# Games endpoints → Game* schemas
/api/v1/games:
  post:
    responses:
      '422':
        schema:
          $ref: '#/components/schemas/GameErrorResponse'
      '404':
        schema:
          $ref: '#/components/schemas/GameNotFoundError'
```

### 4. Error Message Examples

Error examples must be relevant to the resource's validation rules:

- **Users**: email, password, username validation
- **Games**: name, release_year, rating validation

### 5. Checklist Before Committing

- [ ] All error responses use resource-specific schemas
- [ ] Error examples match the resource's validation rules
- [ ] No generic `ErrorResponse` or `NotFoundError` schemas exist
- [ ] All endpoints reference the correct schemas
- [ ] Swagger UI displays correct examples for all endpoints

## Notes

- The project name "Omni Ludum" suggests this may be a game-related application (Latin: "omni" = all, "ludum" = game/play)
- Both backend and frontend are set up as boilerplate installations ready for development
- The architecture supports API-driven development with clear separation between concerns
- Soft delete pattern: records are never physically deleted, only marked as `is_disabled: true`
- Games use self-referencing foreign key for DLC/mod relationships
- Games are looked up by `name` (not slug) for simplicity

## JWT Security

### Token Structure

Access tokens are JWTs with the following payload:

```json
{
  "sub": 1,
  "email": "user@example.com",
  "role": "REGULAR",
  "jti": "uuid-string",
  "iat": 1234567890,
  "exp": 1234568790,
  "token_version": 0
}
```

| Field | Description |
|-------|-------------|
| `sub` | User ID |
| `email` | User email |
| `role` | User role |
| `jti` | Unique token identifier (for blacklist) |
| `iat` | Issued at timestamp |
| `exp` | Expiration timestamp (15 minutes) |
| `token_version` | User's token version (for bulk invalidation) |

### Token Blacklist

Access tokens can be revoked before expiration using PostgreSQL-backed blacklist:

**Model:** `AccessTokenBlacklist`
- `jti` — unique token identifier
- `expires_at` — token expiration time
- `reason` — revocation reason (logout, password_change, account_disable, compromised)
- `user_id` — optional user reference

**Cleanup:** Expired blacklist entries are automatically removed daily at 3 AM by `CleanupExpiredBlacklistJob`.

### Token Versioning

Each user has a `token_version` field (integer, default: 0). When security-sensitive events occur:
- Password change
- Account disable
- Logout from all devices

The `token_version` is incremented, invalidating all previously issued access tokens for that user.

### Revocation Scenarios

| Scenario | Access Token | Refresh Token | Mechanism |
|----------|--------------|---------------|-----------|
| Logout | ✅ Blacklisted | ✅ Revoked | JTI added to blacklist |
| Logout All | ✅ Invalidated | ✅ Revoked | `token_version` incremented |
| Password Change | ✅ Invalidated | ✅ Revoked | `token_version` incremented |
| Account Disabled | ✅ Invalidated | ✅ Revoked | `token_version` incremented |
| Token Compromised | ✅ Blacklisted | ✅ Revoked | JTI added to blacklist + `token_version` incremented |

### Security Best Practices

1. **Short-lived access tokens:** 15 minutes expiration
2. **Refresh token rotation:** New refresh token issued on each refresh
3. **Immediate revocation:** Logout adds access token to blacklist
4. **Bulk invalidation:** Token versioning for security events
5. **Automatic cleanup:** Expired blacklist entries removed daily

## Rate Limiting

### Overview

The API implements rate limiting using **Rack::Attack** with **Redis** as the backend store to prevent abuse, brute force attacks, and DoS attacks.

### Configuration Files

| File | Description |
|------|-------------|
| `api/config/initializers/rack_attack.rb` | Rate limiting rules and throttles |
| `api/config/initializers/rack_attack_store.rb` | Redis store configuration |
| `api/config/initializers/rack_attack_store.rb` | Uses Rails credentials for Redis connection |

### Redis Configuration

Redis connection is configured via Rails credentials:

```yaml
# Rails credentials (edit with: EDITOR="nano" bin/rails credentials:edit)
redis:
  url: redis://localhost:6379/1
  namespace: rack_attack
```

### Rate Limits

| Endpoint | Limit | Period | Key |
|----------|-------|--------|-----|
| POST /auth/login | 5 | 1 minute | IP |
| POST /auth/login | 3 | 1 minute | Email |
| POST /auth/refresh | 30 | 1 minute | IP |
| DELETE /auth/logout | 10 | 1 minute | IP |
| DELETE /auth/logout_all | 5 | 1 minute | IP |
| POST /users | 3 | 1 hour | IP |
| POST /users | 1 | 1 hour | Email |
| POST /assets | 10 | 1 minute | IP |
| POST /assets | 20 | 1 minute | User ID |
| GET * | 300 | 1 minute | IP |
| POST/PUT/PATCH * | 60 | 1 minute | IP |
| DELETE * | 30 | 1 minute | IP |
| All (authenticated) | 600 | 1 minute | User ID |

### 429 Too Many Requests Response

When rate limit is exceeded, the API returns:

**HTTP Status:** `429 Too Many Requests`

**Response Body:**
```json
{
  "error": "Too many requests",
  "retry_after": 60
}
```

**Headers:**
| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Maximum requests allowed in the time window |
| `X-RateLimit-Remaining` | Number of requests remaining |
| `X-RateLimit-Reset` | Unix timestamp when the limit resets |
| `Retry-After` | Seconds to wait before retrying |

### Redis Keys

Rate limit counters are stored in Redis with the following key format:

- `rack_attack:throttle:logins/ip:<ip_address>` — login attempts by IP
- `rack_attack:throttle:logins/email:<email>` — login attempts by email
- `rack_attack:throttle:api/ip:<ip_address>` — general API requests by IP
- `rack_attack:throttle:api/user:<user_id>` — authenticated user requests

TTL is automatically set based on the `period` parameter.

### Docker Setup (Development)

Redis runs in a Docker container using Yandex Container Registry mirror:

```bash
# Start Redis
make redis-up

# Stop Redis
make redis-down

# Redis CLI
make redis-console

# View logs
make redis-logs
```

### Allowlist

The following are exempt from rate limiting:
- Health check endpoint (`/up`)
- Internal IPs (if configured in credentials)

### Production Notes

- Use a dedicated Redis instance or cluster for production
- Consider increasing limits based on actual traffic patterns
- Monitor rate limit hits for security analysis

## Caching

### Overview

The API uses `Rails.cache` with MemoryStore backend in development for caching frequently requested static data.

### Configuration

**Development** (`config/environments/development.rb`):
```ruby
config.cache_store = :memory_store, { namespace: 'omni_ludum_dev' }
```

Caching is enabled when `tmp/caching-dev.txt` exists. Toggle with:
```bash
cd api && rails dev:cache
```

### Cached Data

| Data | Key Pattern | TTL |
|------|-------------|-----|
| Active Genres | `genres/v1/active_ordered` | 1 hour |
| Active Platforms | `platforms/v1/active_ordered` | 1 hour |
| Active Publishers | `publishers/v1/active_ordered` | 1 hour |

### Cache Invalidation

Automatic invalidation on model changes:
- `Genre` — `after_save` and `after_destroy` callbacks
- `Platform` — `after_save` and `after_destroy` callbacks
- `Publisher` — `after_save` and `after_destroy` callbacks

### Rake Tasks

```bash
# Clear all caches
rails cache:clear

# Clear specific caches
rails cache:clear_genres
rails cache:clear_platforms
rails cache:clear_publishers

# Clear all reference data caches
rails cache:clear_references
```

### Implementation Pattern

**Model** (`app/models/genre.rb`):
```ruby
def self.active_ordered
  Rails.cache.fetch("genres/v1/active_ordered", expires_in: 1.hour) do
    active.order(:name).to_a
  end
end

private

def invalidate_active_ordered_cache
  Rails.cache.delete("genres/v1/active_ordered")
end
```

**Controller** (`app/controllers/api/v1/genres_controller.rb`):
```ruby
def index
  @all_genres = Genre.active_ordered
  page = params[:page] || 1
  per_page = params[:per_page] || DEFAULT_PER_PAGE

  @genres = Kaminari.paginate_array(@all_genres).page(page).per(per_page)
  render template: "api/v1/genres/index", status: :ok
end
```

### Production Considerations

For production deployment, configure Redis-backed cache store:
```ruby
config.cache_store = :redis_cache_store, {
  url: ENV.fetch('REDIS_URL'),
  namespace: 'omni_ludum',
  expires_in: 1.hour
}
```
