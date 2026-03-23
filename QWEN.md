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

- **Backend**: User and Game models implemented with full CRUD API
- **Frontend**: Basic SvelteKit structure with Tailwind CSS
- **Documentation**: Swagger UI available at `/api-docs`

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
| `name` | string | Required, unique (case-insensitive), indexed | Game name |
| `release_year` | integer | 1970-2100, indexed | Year of release |
| `rating_avg` | float | 0-10 | Average user rating (future: calculated) |
| `difficulty_avg` | float | 0-10 | Average difficulty rating (future: calculated) |
| `playtime_avg` | integer | >= 0 (minutes) | Average playtime (future: calculated) |
| `playtime_100_avg` | integer | >= 0 (minutes) | Average 100% completion time (future: calculated) |
| `is_dlc` | boolean | Default: false | DLC flag |
| `is_mod` | boolean | Default: false | Mod/room hack flag |
| `is_disabled` | boolean | Default: false | Soft delete flag |
| `base_game_id` | bigint | FK → games.id, nullable | Reference to original game |
| `created_at` | datetime | Auto-generated | Creation timestamp |
| `updated_at` | datetime | Auto-generated | Last update timestamp |

### Self-Referencing Association

Games can reference other games via `base_game_id`:
- Used for DLCs, mods, and room hacks to link to their original game
- Foreign key constraint ensures referential integrity
- When base game is soft deleted, `base_game_id` should be set to NULL (manual handling)

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
