# Products API

## Setup

Install gems

```bash
bundle install
```

Set up the database

```bash
# Clean old containers
make dc-down

# Create the database, and run migrations
make db-setup
```

Set up JWT variables creating a `.env` file with the following content

```
JWT_ISSUER=<some_secretkey>
JWT_SECRET=<some_issuer>
```

## Run

Execute the application in development mode with dockerized Redis and PostgreSQL databases

```bash
make start
```

The application runs at `localhost:9292`

Default user credentials are `username: "admin", "password": "adminpass"`

## Run Tests

Start PostgreSQL with the test database and execute automated tests

```bash
make test
```

## Other tasks and help

Run the `make` command to see all the available tasks

```
db-console: Run db console with sequel
db-migrate: Run db migrations
db-setup:# Setup database for development mode
dc-down: Stops containers and removes containers, networks, volumes, and images of this project
help: Show help for each of the Makefile recipes.
start: Run app local and databases in docker
test: Run test db and run tests
```
