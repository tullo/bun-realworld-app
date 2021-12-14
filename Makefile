SHELL := /bin/bash -eo pipefail

.DEFAULT_GOAL := db_reset

clean:
	@rm -rfv cockroach-data

single-node-db: clean
	@cockroach start-single-node --insecure --listen-addr=localhost

db_reset:
	cockroach sql --insecure -e "DROP DATABASE IF EXISTS realworld_test"
	cockroach sql --insecure -e "CREATE DATABASE realworld_test"

	make db_migrate

db_migrate:
	go run cmd/bun/main.go -env=test db init
	go run cmd/bun/main.go -env=test db migrate

test:
	TZ= go test ./org
	TZ= go test ./blog

api_test:
	TZ= go run cmd/bun/main.go -env=test api &
	APIURL=http://localhost:8000/api ./scripts/run-api-tests.sh
