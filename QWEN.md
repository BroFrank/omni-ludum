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

As of this analysis:
- The API is a fresh Rails 7.2.3 setup with PostgreSQL
- No custom models or controllers have been implemented yet
- Routes are minimal (only health check endpoint)
- The client has basic SvelteKit structure with Tailwind CSS
- Test infrastructure is configured for both backend and frontend

## Notes

- The project name "Omni Ludum" suggests this may be a game-related application (Latin: "omni" = all, "ludum" = game/play)
- Both backend and frontend are set up as boilerplate installations ready for development
- The architecture supports API-driven development with clear separation between concerns
