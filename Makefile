.PHONY: db-up db-down db-console db-logs db-restart

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
