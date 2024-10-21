.PHONY: all precommit test lint install-deps integration-test

# Default target
all: precommit

# Install dependencies
install-deps:
	@echo "Installing dependencies..."
	@command -v pre-commit >/dev/null 2>&1 || pip install pre-commit
	@command -v bats >/dev/null 2>&1 || brew install bats-core
	@command -v shellcheck >/dev/null 2>&1 || brew install shellcheck
	@pre-commit install

# Run pre-commit hooks
precommit: install-deps
	@echo "Running pre-commit hooks..."
	@pre-commit run --all-files

# Run unit tests
test: install-deps
	@echo "Running unit tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests/test_natilius.bats

# Run integration tests
integration-test: install-deps
	@echo "Running integration tests..."
	@bash tests/integration_tests.sh

# Run all tests
test-all: test integration-test

# Run linting
lint: install-deps
	@echo "Running shellcheck..."
	@shellcheck -x natilius.sh modules/**/*.sh lib/*.sh tests/*.sh

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf .pre-commit-cache
