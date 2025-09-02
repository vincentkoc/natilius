.PHONY: all precommit test lint install-deps integration-test test-config test-all clean help dev-setup coverage check-version release-check format

# Default target
all: precommit

# Help target
help:
	@echo "Natilius Development Commands:"
	@echo ""
	@echo "Testing:"
	@echo "  test              Run unit tests"
	@echo "  test-cli          Run CLI feature tests"
	@echo "  test-modules      Run module tests"
	@echo "  integration-test  Run integration tests"
	@echo "  test-config       Run config validator tests"
	@echo "  test-all          Run all tests + precommit hooks"
	@echo "  coverage          Generate test coverage report"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint              Run shellcheck linting"
	@echo "  format            Format shell scripts"
	@echo "  precommit         Run pre-commit hooks"
	@echo ""
	@echo "Development:"
	@echo "  install-deps      Install development dependencies"
	@echo "  dev-setup         Setup development environment"
	@echo "  check-version     Check version consistency"
	@echo "  release-check     Check if ready for release"
	@echo ""
	@echo "Utility:"
	@echo "  clean             Clean up temporary files"
	@echo "  help              Show this help message"

# Install dependencies
install-deps:
	@echo "📦 Installing dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		HOMEBREW_NO_AUTO_UPDATE=1 brew install bats-core shellcheck || true; \
	else \
		echo "Homebrew not found. Installing with package manager..."; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y shellcheck bats; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y ShellCheck; \
		fi; \
	fi
	@command -v pre-commit >/dev/null 2>&1 || pip3 install --user pre-commit
	@if [ -f ".pre-commit-config.yaml" ]; then pre-commit install; fi

# Development environment setup
dev-setup: install-deps
	@echo "🛠️  Setting up development environment..."
	@mkdir -p logs
	@if [ ! -f ".natiliusrc.dev" ]; then cp .natiliusrc.example .natiliusrc.dev; fi
	@chmod +x natilius.sh install.sh
	@find modules -name "*.sh" -exec chmod +x {} \;
	@find lib -name "*.sh" -exec chmod +x {} \;
	@echo "✅ Development environment ready!"

# Run pre-commit hooks
precommit: install-deps
	@echo "🔧 Running pre-commit hooks..."
	@pre-commit run --all-files

# Run unit tests
test: install-deps
	@echo "🧪 Running unit tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests/test_natilius.bats

# Run CLI feature tests
test-cli: install-deps
	@echo "🖥️  Running CLI feature tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests/test_cli_features.bats

# Run module tests
test-modules: install-deps
	@echo "📦 Running module tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests/test_modules.bats

# Run integration tests
integration-test: install-deps
	@echo "🔗 Running integration tests..."
	@BATS_LIB_PATH="$(pwd)/lib" bats tests/integration_tests.bats

# Run config validator test
test-config: install-deps
	@echo "⚙️  Running config validator test..."
	@bash tests/test_config_validator.sh

# Run all tests
test-all: test test-cli test-modules test-config integration-test precommit
	@echo "✅ All tests completed!"

# Generate coverage report
coverage: install-deps
	@echo "📊 Generating coverage report..."
	@mkdir -p coverage
	@echo "Test Coverage Report" > coverage/report.txt
	@echo "===================" >> coverage/report.txt
	@echo "Generated: $$(date)" >> coverage/report.txt
	@echo "" >> coverage/report.txt
	@echo "Test Files:" >> coverage/report.txt
	@find tests -name "*.bats" -o -name "*.sh" | wc -l | xargs echo "  BATS/Shell tests:" >> coverage/report.txt
	@echo "" >> coverage/report.txt
	@echo "Source Files:" >> coverage/report.txt
	@find . -name "*.sh" -not -path "./tests/*" -not -path "./.devcontainer/*" | wc -l | xargs echo "  Shell scripts:" >> coverage/report.txt
	@echo "" >> coverage/report.txt
	@echo "Module Coverage:" >> coverage/report.txt
	@find modules -name "*.sh" | while read -r module; do \
		module_name=$$(basename "$$module" .sh); \
		if grep -q "$$module_name" tests/*.bats 2>/dev/null; then \
			echo "  ✅ $$module - tested"; \
		else \
			echo "  ❌ $$module - needs tests"; \
		fi; \
	done >> coverage/report.txt
	@cat coverage/report.txt

# Run linting
lint: install-deps
	@echo "🔍 Running shellcheck..."
	@shellcheck -x natilius.sh modules/**/*.sh lib/*.sh tests/*.sh .devcontainer/setup.sh

# Format shell scripts
format:
	@echo "🎨 Formatting shell scripts..."
	@if command -v shfmt >/dev/null 2>&1; then \
		find . -name "*.sh" -not -path "./.*" | xargs shfmt -w -i 4; \
		echo "✅ Formatting complete!"; \
	else \
		echo "⚠️  shfmt not found. Install with: brew install shfmt"; \
	fi

# Check version consistency
check-version:
	@echo "📋 Checking version consistency..."
	@version=$$(grep 'NATILIUS_VERSION=' natilius.sh | cut -d'"' -f2); \
	echo "Current version: $$version"; \
	if git describe --tags >/dev/null 2>&1; then \
		git_version=$$(git describe --tags --abbrev=0 | sed 's/v//'); \
		echo "Latest git tag: v$$git_version"; \
		if [ "$$version" != "$$git_version" ]; then \
			echo "⚠️  Version mismatch detected!"; \
			echo "Update NATILIUS_VERSION in natilius.sh to match git tag"; \
		else \
			echo "✅ Version is consistent"; \
		fi; \
	else \
		echo "No git tags found"; \
	fi

# Check if ready for release
release-check: test-all lint
	@echo "🚀 Checking release readiness..."
	@uncommitted=$$(git status --porcelain | wc -l); \
	if [ $$uncommitted -gt 0 ]; then \
		echo "❌ Uncommitted changes detected"; \
		git status --short; \
	else \
		echo "✅ No uncommitted changes"; \
	fi
	@if git describe --exact-match --tags HEAD >/dev/null 2>&1; then \
		echo "✅ Current commit is tagged for release"; \
	else \
		echo "ℹ️  Current commit is not tagged"; \
	fi
	@echo "📊 Recent commits:"
	@git log --oneline -5

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf .pre-commit-cache
	@rm -rf logs/*.log
	@rm -rf coverage/
	@rm -rf *.tar.gz
	@rm -rf *.sha256
	@echo "✅ Cleanup complete!"
