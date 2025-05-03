.PHONY: run build local reset codegen publish

run:
	go run ./cmd/api

build:
	go build -o api ./cmd/api

local:
	touch ./local/application.log
	docker compose -f ./local/docker-compose.yaml build
	docker compose -f ./local/docker-compose.yaml up -d
	sleep 5
	migrate -path ./migrations/postgres -database "postgres://username:password@localhost:5432/app?sslmode=disable" -verbose up

reset:
	docker compose -f ./local/docker-compose.yaml down
	rm -rf ./local/postgres ./local/application.log

codegen-api:
	swagger-codegen generate -i ./spec/build/api.yaml -l go -o ./tmp
	mkdir -p ./internal/swagger
	mv ./tmp/model_* ./internal/swagger
	rm -rf tmp

codegen-test:
	rm -rf ./integration/swagger/swagger_client
	swagger-codegen generate -i ./spec/build/api.yaml -l python -o ./integration/swagger
	mv ./integration/swagger/swagger_client ./integration
	rm -rf ./integration/swagger


ENV ?= dev
IMAGE_TAG = 0.1.$(shell git rev-list --all | wc -l | xargs)
AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity | jq .Account | xargs)
ECR_BASE = ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
REPO = ${ECR_BASE}/app-api-${ENV}
publish:
	docker build . -t ${REPO}:${IMAGE_TAG} -t ${REPO}:latest --platform=linux/amd64
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_BASE}
	docker push ${REPO}:${IMAGE_TAG}
	docker push ${REPO}:latest
