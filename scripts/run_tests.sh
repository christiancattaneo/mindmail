#!/bin/bash
# Test runner script for mindmail
# Runs unit tests and reports results

set -e

PROJECT_DIR="/Users/christiancattaneo/Projects/mindmail"
cd "$PROJECT_DIR"

echo "🧪 Running mindmail unit tests..."
echo "================================="

xcodebuild test \
  -scheme mindmail \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -quiet \
  2>&1 | xcpretty || echo "Tests completed with status: $?"

echo "================================="
echo "✅ Test run complete"

