#!/bin/bash

# Clean script to remove all generated files and dependencies

set -e

echo "🧹 Cleaning AFL Data Capture Platform"
echo "====================================="

# Stop Docker containers
echo "🐳 Stopping Docker containers..."
docker-compose down -v 2>/dev/null || true

# Remove node_modules
echo "📦 Removing node_modules..."
find . -name "node_modules" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true

# Remove build artifacts
echo "🗑️ Removing build artifacts..."
find . -name "dist" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true
find . -name ".next" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true
find . -name ".turbo" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true
find . -name "coverage" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true

# Remove package-lock files
echo "🔒 Removing lock files..."
find . -name "package-lock.json" -exec rm -f '{}' + 2>/dev/null || true
find . -name "pnpm-lock.yaml" -exec rm -f '{}' + 2>/dev/null || true

# Remove .env files (keep examples)
echo "📄 Removing .env files (keeping examples)..."
find . -name ".env" -exec rm -f '{}' + 2>/dev/null || true
find . -name ".env.local" -exec rm -f '{}' + 2>/dev/null || true

echo ""
echo "✨ Clean complete!"
echo ""
echo "To set up the project again, run:"
echo "  ./scripts/setup-dev.sh"
echo ""