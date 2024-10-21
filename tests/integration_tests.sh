#!/bin/bash

set -e

# Setup test environment
TEST_DIR=$(mktemp -d)
cp -R . "$TEST_DIR"
cd "$TEST_DIR"

# Run natilius in test mode
./natilius.sh --test

# Check if critical files/directories exist
[ -d "/Applications/Homebrew" ] || (echo "Homebrew not installed" && exit 1)

# Add more checks for other expected outcomes

echo "All integration tests passed!"
