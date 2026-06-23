SHELL := /bin/bash
.DEFAULT_GOAL := help

RELEASE_NAME ?= zigbee2mqtt
NAMESPACE    ?= zigbee2mqtt

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: lint
lint: ## Lint chart with example values
	helm lint . -f values.yaml.example

.PHONY: template
template: ## Render templates with example values
	helm template $(RELEASE_NAME) . -f values.yaml.example --namespace $(NAMESPACE)

.PHONY: package
package: ## Package chart into .tgz
	helm package .

.PHONY: test
test: ## Run helm-unittest suites
	helm unittest -f 'tests/units/*_test.yaml' .

.PHONY: docs
docs: ## Regenerate README from docs/README.md.gotmpl (requires helm-docs or Docker)
	bash scripts/helm-docs.sh
