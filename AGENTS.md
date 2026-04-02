# AGENTS.md — Omni Ludum

## Project Overview

Full-stack app: **Rails 7.2 API** (`api/`) + **SvelteKit 2 client** (`client/`). Ruby 3.4.8, TypeScript strict, Svelte 5 runes, Tailwind CSS v4, PostgreSQL.

## Commands

### Backend (Rails API) — run from `api/`

```
bundle install                  # install deps
bin/rails server                # dev server
bin/rails console               # Rails console
bin/rails db:create db:migrate  # setup DB
rails test                      # run all tests
rails test test/models/user_test.rb        # single test file
rails test test/models/user_test.rb:10     # single test by line
rails test:models               # model tests only
rails test:controllers          # controller tests only
rails test:integration          # integration tests only
rubocop                         # lint
rubocop -a                      # auto-fix
brakeman                        # security scan
```

### Frontend (SvelteKit) — run from `client/`

```
npm install                     # install deps
npm run dev                     # dev server
npm run build                   # production build
npm run preview                 # preview build
npm run test                    # all tests (unit + browser, headless)
npm run test:unit               # unit tests only (watch mode)
npm run test -- --run           # run tests once without watch
npx vitest run src/lib/foo.spec.ts       # single test file
npm run check                   # TypeScript type check
npm run lint                    # ESLint
npm run lint -- --fix           # ESLint auto-fix
```

### Docker / Makefile — run from project root

```
make db-up          # start PostgreSQL container
make db-down        # stop PostgreSQL container
make db-console     # open psql
make api-dev        # start Rails server
make api-queue      # start Solid Queue worker
make api-dev-all    # Rails + Solid Queue (requires foreman)
docker compose up -d            # all containers
docker compose down             # stop all
```

## Code Style — Backend (Ruby/Rails)

- **Linting**: RuboCop Rails Omakase (`api/.rubocop.yml`). Run `rubocop` before committing.
- **Naming**: snake_case for methods/variables, PascalCase for classes/modules.
- **Models**: inherit from `ApplicationRecord`. Use `ApplicationService` pattern for business logic.
- **Controllers**: inherit from `Api::V1::BaseController`. Use `rescue_from` for error handling. Standardized JSON error responses.
- **Soft deletes**: use `is_disabled` boolean flag. Service objects handle cascade soft-deletes and audit logging.
- **Eager loading**: always use `.includes()` for associations rendered in JSON to avoid N+1 queries.
- **Constants**: defined in `config/initializers/consts.rb` (USER_ROLES, USER_THEMES, LINK_TYPES, etc.). Use `.freeze`.
- **Audit logging**: include `Auditable` concern in models. Uses `Thread.current[:current_user_id]` set by `CurrentUserAudit` controller concern.
- **Background jobs**: Solid Queue. Use `find_or_create_by!` with unique partial indexes to prevent race conditions.
- **No comments** in code unless clarifying non-obvious logic. No `puts`/`p`/`Rails.logger.debug` in committed code.

## Code Style — Frontend (SvelteKit/TypeScript)

- **Linting**: ESLint v9 with `typescript-eslint` + `eslint-plugin-svelte` (`client/eslint.config.js`). Run `npm run lint` before committing.
- **TypeScript**: strict mode enabled (`tsconfig.json`). No `any` — use proper types. `moduleResolution: "bundler"`.
- **Svelte 5 runes**: all components use runes mode (`svelte.config.js`). Use `$state`, `$derived`, `$effect` instead of old reactivity.
- **Imports**: use `$lib/` alias for shared code. No relative paths crossing `src/lib` boundary.
- **File naming**:
  - Components: `PascalCase.svelte`
  - Routes: `+page.svelte`, `+page.server.ts`, `+layout.svelte`
  - Test files: `*.spec.ts` or `*.test.ts` alongside source or in `vitest-examples/`
  - Utility modules: `camelCase.ts`
- **Testing**: Vitest with two projects — `client` (browser/Playwright for `.svelte` tests) and `server` (node for `.ts` tests). Use `describe`/`it`/`expect` from `vitest`. Svelte component tests use `vitest-browser-svelte` with `render()` and `page` from `vitest/browser`.
- **Styling**: Tailwind CSS v4 via Vite plugin. Use utility classes, no custom CSS unless necessary.
- **Formatting**: 2-space tabs (see existing files). Use trailing commas. Single quotes for strings.
- **No `console.log`** in committed code. No emojis in code.

## Error Handling

- **Backend**: `BaseController` provides `render_validation_errors`, `render_not_found`, `render_service_error`. All responses are JSON with `{ errors: [...] }` or `{ error: "..." }` format.
- **Frontend**: handle API errors gracefully. Show user-friendly messages. No raw error objects in UI.

## Conventions

- No documentation comments in code.
- No `TODO` comments — implement or don't write.
- No `console.log`/`puts` debug code in commits.
- Follow existing file structure and naming patterns.
- Do not modify config files (`.gitignore`, `package.json`, `Gemfile`) without instruction.
- Do not commit — user handles commits.
- Do not start servers — user starts them.
- Answer in Russian when communicating with user.
