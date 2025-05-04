## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## api/run: runs api binary
.PHONY: api/run
api/run:
	go run ./cmd/api

## api/build: builds api binary
current_time = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'
.PHONY: api/build
api/build:
	go build -ldflags=${linker_flags} -o api ./cmd/api

## api/audit: audits code for common issues
.PHONY: audit
api/audit:
	go mod tidy
	go mod verify
	go vet ./...

## api/publish: builds an image and publishes it to ECR based on $env (default: dev)
env ?= dev
git_description = $(shell git describe --always --tags --long)
aws_account_id = $(shell aws sts get-caller-identity | jq .Account | xargs)
ecr_base = ${aws_account_id}.dkr.ecr.us-east-1.amazonaws.com
repo = ${ecr_base}/app-api-${env}
.PHONY: api/publish
api/publish:
	docker build . -t ${repo}:${git_description} -t ${repo}:latest --platform=linux/amd64
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ecr_base}
	docker push ${repo}:${git_description}
	docker push ${repo}:latest

## db/psql: establish a session with the db specified in $APP_DB_URL
.PHONY: db/plsql
db/plsql:
	psql ${APP_DB_URL}

## db/migration/up: apply migration to the db specified in $APP_DB_URL
.PHONY: db/migrations/up
db/migration/up:
	migrate -path ./migrations/postgres -database ${APP_DB_URL} -verbose up

## db/migration/down: remove migration from the db specified in $APP_DB_URL
.PHONY: db/migrations/down
db/migration/down:
	migrate -path ./migrations/postgres -database ${APP_DB_URL} -verbose down

## db/migration/create: create migration specified in $migration_name
.PHONY: db/migrations/create
db/migration/create:
	migrate create -seq -ext=.sql -dir=./migrations/postgres ${migration_name}

## local/psql: establish a session with local db in container
.PHONY: local/psql
local/psql:
	psql postgres://username:password@localhost:5432/app?sslmode=disable

## local/up: starts api in container alongside the db container
.PHONY: local/up
local/up:
	touch ./local/application.log
	docker compose -f ./local/docker-compose.yaml build
	docker compose -f ./local/docker-compose.yaml up -d
	sleep 5
	migrate -path ./migrations/postgres -database "postgres://username:password@localhost:5432/app?sslmode=disable"  -verbose up

## local/reset: deletes all data in the local db container
.PHONY: local/reset
local/reset:
	rm ./local/application.log
	migrate -path ./migrations/postgres -database "postgres://username:password@localhost:5432/app?sslmode=disable" -verbose down
	docker compose -f ./local/docker-compose.yaml down

## codegen/models: generates go models based on open api spec
.PHONY: codegen/models
codegen/models:
	swagger-codegen generate -i ./spec/build/api.yaml -l go -o ./tmp
	mkdir -p ./internal/swagger
	mv ./tmp/model_* ./internal/swagger
	rm -rf tmp

## codegen/tests: generates python client for testing the api
.PHONY: codegen/tests
codegen/tests:
	rm -rf ./integration/swagger/swagger_client
	swagger-codegen generate -i ./spec/build/api.yaml -l python -o ./integration/swagger
	mv ./integration/swagger/swagger_client ./integration
	rm -rf ./integration/swagger
