# Products API

## Documentation

See the available endpoints using the [Swagger UI deployed in Github pages](https://leobz.github.io/products_api). You can run the examples by copying and executing the curl commands provided in it.

## Issue Tracking

For completed tasks, please refer to [this link](https://github.com/leobz/products_api/issues?q=is%3Aissue+is%3Aclosed).

For pending tasks that are yet to be implemented, please visit the [open issues](https://github.com/leobz/products_api/issues?q=is%3Aopen+is%3Aissue).

## Setup

1. Install requirements:

- Ruby Version: 3.3.4
- Docker Compose

2. Install dependencies

```bash
bundle install
```

3. Set up the database

```bash
# Clean old containers
make dc-down

# Create the database, and run migrations
make db-setup
```

4. Optional: Set up your custom variables creating the `.env` file

```
DATABASE_URL=<your_custom_dev_db_url>
TEST_DATABASE_URL=<your_custom_test_db_url>
JWT_ISSUER=<your_custom_issuer>
JWT_SECRET=<your_custom_secret>
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

## Run other tasks

Run the `make` command to see all the available tasks
