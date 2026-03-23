.PHONY: db-up db-down db-console db-logs db-restart api-dev api-queue api-dev-all

# Start PostgreSQL database container
db-up:
	docker compose up -d db

# Stop PostgreSQL database container
db-down:
	docker compose down db

# Open PostgreSQL console for queries
db-console:
	docker compose exec db psql -U postgres -d omni_ludum_development

# View database logs
db-logs:
	docker compose logs -f db

# Restart database container
db-restart:
	docker compose restart db

# Start Rails development server
api-dev:
	cd api && bin/rails server

# Start Solid Queue worker
api-queue:
	cd api && bin/rails solid_queue:start

# Start Rails server and Solid Queue worker (requires foreman)
api-dev-all:
	cd api && foreman start -f Procfile.dev
