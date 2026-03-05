#!/bin/bash

echo "=========================================="
echo "Laravel 12 Upgrade Script"
echo "=========================================="
echo ""

# Check PHP version
echo "Checking PHP version..."
PHP_VERSION=$(php -r "echo PHP_VERSION;")
echo "Current PHP version: $PHP_VERSION"

if [[ $(echo "$PHP_VERSION 8.2" | awk '{print ($1 < $2)}') -eq 1 ]]; then
    echo "❌ Error: PHP 8.2 or higher is required for Laravel 12"
    echo "Please upgrade PHP first"
    exit 1
fi
echo "✅ PHP version is compatible"
echo ""

# Backup check
echo "⚠️  IMPORTANT: Have you backed up your database and files?"
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled"
    exit 1
fi
echo ""

# Remove old files
echo "Removing old vendor and lock files..."
rm -rf vendor composer.lock
echo "✅ Old files removed"
echo ""

# Install dependencies
echo "Installing new dependencies..."
composer install
if [ $? -ne 0 ]; then
    echo "❌ Composer install failed"
    exit 1
fi
echo "✅ Dependencies installed"
echo ""

# Clear caches
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
echo "✅ Caches cleared"
echo ""

# Generate autoload
echo "Generating autoload files..."
composer dump-autoload
echo "✅ Autoload generated"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found"
    read -p "Copy from .env.example? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env.example .env
        php artisan key:generate
        echo "✅ .env file created and key generated"
    fi
fi
echo ""

# Update .env for Vite
echo "Checking .env for Vite configuration..."
if grep -q "MIX_PUSHER_APP_KEY" .env; then
    echo "⚠️  Found MIX_ variables in .env"
    echo "Laravel 12 uses Vite instead of Mix"
    echo "Please update MIX_ variables to VITE_ manually in your .env file"
fi
echo ""

# Run migrations
echo "Do you want to run migrations?"
read -p "Run migrations? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    php artisan migrate
    echo "✅ Migrations completed"
fi
echo ""

echo "=========================================="
echo "Upgrade completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update your .env file (check MIX_ to VITE_ variables)"
echo "2. Test your application: php artisan serve"
echo "3. Review UPGRADE_LARAVEL_12.md for detailed changes"
echo "4. Check for deprecated code in your application"
echo ""
echo "Happy coding! 🚀"
