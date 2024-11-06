include .env

.PHONY: help create-migration migrate-up migrate-down migrate-force

help: ## Show help
	@echo "\n\033[1mAvailable commands:\033[0m\n"
	@@awk 'BEGIN {FS = ":.*##";} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

create-migration: ## Create an empty migration
	@read -p "Enter the sequence name: " SEQ; \
    docker run --rm -v ./database/migrations:/migrations migrate/migrate \
        create -ext sql -dir /migrations -seq $${SEQ}

migrate-up: ## Migration up
	@docker run --rm -v ./database/migrations:/migrations --network host migrate/migrate \
        -path=/migrations -database "mysql://${DATABASE_DSN}" up

migrate-down: ## Migration down
	@read -p "Number of migrations you want to rollback (default: 1): " NUM; NUM=$${NUM:-1}; \
	docker run --rm -it -v ./database/migrations:/migrations --network host migrate/migrate \
        -path=/migrations -database "mysql://${DATABASE_DSN}" down $${NUM}

migrate-force: ## Migration force version
	@read -p "Enter the version to force: " VERSION; \
	docker run --rm -it -v ./database/migrations:/migrations --network host migrate/migrate \
        -path=/migrations -database "mysql://${DATABASE_DSN}" force $${VERSION}