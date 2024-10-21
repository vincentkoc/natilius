.PHONY: all precommit test lint install-deps

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

# Run tests
test: install-deps
	@echo "Running tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests

# Run linting
lint: install-deps
	@echo "Running shellcheck..."
	@shellcheck -x natilius.sh modules/**/*.sh lib/*.sh

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf .pre-commit-cache
