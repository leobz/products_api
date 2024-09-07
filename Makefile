## Docker compose backward compatibility to older versions
## More info: https://docs.docker.com/compose/#compose-v2-and-the-new-docker-compose-command
define DOCKER_COMPOSE
	@if which docker-compose  >/dev/null ; then docker-compose  $1; \
	else docker compose $1; fi;
endef

DATABASE_URL = postgres://postgres:postgres@localhost:15432/dev_db
TEST_DATABASE_URL = postgres://postgres:postgres@localhost:5432/test_db

default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: start
start: # Run app local and databases in docker
	$(call DOCKER_COMPOSE, up -d)
	DATABASE_URL=$(DATABASE_URL) sh start_app.sh

.PHONY: dc-down
dc-down: # Stops containers and removes containers, networks, volumes, and images of this project
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml down)
	$(call DOCKER_COMPOSE, down)

.PHONY: db-migrate
db-migrate: # Run db migrations
	DATABASE_URL=$(DATABASE_URL) rake db:migrate

.PHONY: db-console
db-console: # Run db console with sequel
	sequel $(DATABASE_URL)

.PHONY: db-setup
db-setup: ## Setup database for development mode
	$(call DOCKER_COMPOSE, -f docker-compose.yml up -d)
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml exec db bash -c "until pg_isready -U postgres; do echo 'Waiting for PostgreSQL to be ready...'; sleep 3; done")
	DATABASE_URL=$(DATABASE_URL) rake db:migrate

.PHONY: test
test: # Run test db and run tests
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml up -d)
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml exec test-db bash -c "until pg_isready -U postgres; do echo 'Waiting for PostgreSQL to be ready...'; sleep 3; done")
	DATABASE_URL=$(TEST_DATABASE_URL) rake db:migrate
	DATABASE_URL=$(TEST_DATABASE_URL) rake test
