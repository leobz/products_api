# Docker compose backward compatibility to older versions
# More info: https://docs.docker.com/compose/#compose-v2-and-the-new-docker-compose-command
define DOCKER_COMPOSE
	@if which docker-compose  >/dev/null ; then docker-compose  $1; \
	else docker compose $1; fi;
endef

# Default variables
DATABASE_URL = postgres://postgres:postgres@localhost:15432/dev_db
TEST_DATABASE_URL = postgres://postgres:postgres@localhost:5432/test_db
PROD_DATABASE_URL = postgres://postgres:postgres@localhost:15432/prod_db
REDIS_URL=redis://localhost:6379/0
JWT_ISSUER = fudo
JWT_SECRET = bG9uZyBzZWNyZXQgdXNlZCBmb3IgS29zdG8=
VEGETA_DURATION = 5s
VEGETA_RATE = 0
VEGETA_MAX_WORKERS = 1000

# Load variables from .env file if exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Makefile Commands
default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: build
build: # Build ruby app image
	docker build . -t products_api-app

.PHONY: dev
dev: # Run app local and databases in docker
	$(call DOCKER_COMPOSE, -f docker-compose.yml up -d db)
	$(call DOCKER_COMPOSE, -f docker-compose.yml exec db bash -c "until pg_isready -U postgres; do echo 'Waiting for PostgreSQL to be ready...'; sleep 3; done")
	DATABASE_URL=$(DATABASE_URL) rake db:migrate
	DATABASE_URL=$(DATABASE_URL) rake db:seed
	$(call DOCKER_COMPOSE, up -d)
	JWT_ISSUER=$(JWT_ISSUER) \
	JWT_SECRET=$(JWT_SECRET) \
	REDIS_URL=$(REDIS_URL) \
	DATABASE_URL=$(DATABASE_URL) sh start_app.sh

.PHONY: prod
prod: # Run Nginx, 3 app instances, postgresql and redis in docker
	$(call DOCKER_COMPOSE, -f docker-compose-prod.yml up -d db)
	$(call DOCKER_COMPOSE, -f docker-compose-prod.yml exec db bash -c "until pg_isready -U postgres; do echo 'Waiting for PostgreSQL to be ready...'; sleep 3; done")
	DATABASE_URL=$(PROD_DATABASE_URL) rake db:migrate
	DATABASE_URL=$(PROD_DATABASE_URL) rake db:seed
	$(call DOCKER_COMPOSE, -f docker-compose-prod.yml up)

.PHONY: test
test: # Run test db and run tests
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml up -d)
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml exec test-db bash -c "until pg_isready -U postgres; do echo 'Waiting for PostgreSQL to be ready...'; sleep 3; done")
	DATABASE_URL=$(TEST_DATABASE_URL) rake db:migrate
	REDIS_URL=$(REDIS_URL) DATABASE_URL=$(TEST_DATABASE_URL) rake test

.PHONY: dc-down
dc-down: # Stops containers and removes containers, networks, volumes, and images of this project
	$(call DOCKER_COMPOSE, -f docker-compose-test.yml down)
	$(call DOCKER_COMPOSE, -f docker-compose-prod.yml down)
	$(call DOCKER_COMPOSE, down)

.PHONY: db-migrate
db-migrate: # Run db migrations
	DATABASE_URL=$(DATABASE_URL) rake db:migrate

.PHONY: db-seed
db-seed: # Run db seeds
	DATABASE_URL=$(DATABASE_URL) rake db:seed

.PHONY: db-console
db-console: # Run db console with sequel
	sequel $(DATABASE_URL)

.PHONY: lt-products-list
lt-products-list: # lt-products-list token=<jwt-token>. HTTP load test of GET '/products' endpoint
	@if [ -z $(token) ];\
	then \
		echo "Token not provided!\n   Usage: make lt-products-list token=<jwt-token>" ;\
	else \
		docker run --network=host --rm -i peterevans/vegeta sh -c \
		"echo 'GET http://localhost:9292/products' | vegeta attack -header 'Authorization: Bearer $(token)' -duration=$(VEGETA_DURATION) -rate=$(VEGETA_RATE) -max-workers=$(VEGETA_MAX_WORKERS) | tee results.bin | vegeta report" ; \
	fi

.PHONY: lt-products-create
lt-products-create: # lt-products-create token=<jwt-token>. HTTP load test of POST '/products' endpoint
	@if [ -z $(token) ];\
	then \
		echo "Token not provided!\n   Usage: make lt-products-create token=<jwt-token>" ;\
	else \
		rake sidekiq:clean	# Clear sidekiq jobs before running the test to avoid side effects  && \
		docker run --network=host --rm -i peterevans/vegeta sh -c \
		"printf 'POST http://localhost:9292/products\n@./body.json' > target.txt && \
		echo '{ \"name\": \"test\" }' > body.json && \
		vegeta attack -targets=target.txt \
	  -header 'Authorization: Bearer $(token)' \
		-header 'Content-Type: application/json' \
		-format=http -duration=$(VEGETA_DURATION) -rate=$(VEGETA_RATE) -max-workers=$(VEGETA_MAX_WORKERS) \
		| tee results.bin | vegeta report \
		&& rm body.json && rm target.txt && rm results.bin ";\
	fi

.PHONY: lt-openapi-cache
lt-openapi-cache: # HTTP load test of GET '/openapi.yml'
	docker run --network=host --rm -i peterevans/vegeta sh -c \
	"echo 'GET http://localhost:9292/openapi.yml' | vegeta attack \
	-duration=$(VEGETA_DURATION) -rate=$(VEGETA_RATE) -max-workers=$(VEGETA_MAX_WORKERS) | tee results.bin | vegeta report" ; \

.PHONY: lt-openapi-not-cache
lt-openapi-not-cache: # HTTP load test of GET '/openapi.yml' endpoint with past If-Modified-Since
	docker run --network=host --rm -i peterevans/vegeta sh -c \
	"echo 'GET http://localhost:9292/openapi.yml' | vegeta attack \
	-header 'If-Modified-Since: Thu, 01 Jan 1970 00:00:00 GMT' \
	-duration=$(VEGETA_DURATION) -rate=$(VEGETA_RATE) -max-workers=$(VEGETA_MAX_WORKERS) | tee results.bin | vegeta report" ; \
