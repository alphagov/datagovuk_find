.DEFAULT_GOAL := help

## DEVELOPMENT

.PHONY: build
build: ## Set up everything to run the app
	docker build -t datagovuk_find -f docker/Dockerfile .

.PHONY: dev-build
dev-build: ## Set up everything to run the app in development mode
	./docker/local-build.sh

.PHONY: local-run
local-run: ## Run the app in development mode
	./docker/local-run.sh

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'