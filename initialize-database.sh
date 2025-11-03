#!/bin/bash

# QFieldCloud Database Initialization Script
# This script initializes the QFieldCloud database with Django migrations and creates a superuser

# Configuration
DOMAIN="qfieldcloud.example.com"

set -e

echo "🗄️  Initializing QFieldCloud Database..."

# Get the app pod name
APP_POD=$(kubectl get pods -n qfieldcloud -l app.kubernetes.io/name=qfieldcloud -o jsonpath='{.items[0].metadata.name}')

if [ -z "$APP_POD" ]; then
    echo "❌ No QFieldCloud app pod found. Make sure the deployment is running."
    exit 1
fi

echo "📱 Found app pod: $APP_POD"

# Run Django migrations to set up database schema
echo "🔄 Running Django migrations..."
kubectl exec $APP_POD -n qfieldcloud -- python manage.py migrate

# Create cache table for Django
echo "🗃️  Creating cache table..."
kubectl exec $APP_POD -n qfieldcloud -- python manage.py createcachetable

# Collect static files
echo "📁 Collecting static files..."
kubectl exec $APP_POD -n qfieldcloud -- python manage.py collectstatic --noinput

# Create superuser interactively
echo "🔐 Creating superuser account..."
echo "You will be prompted to enter:"
echo "  - Username (e.g., admin)"
echo "  - Email address"
echo "  - Password (enter twice)"
echo ""
kubectl exec -it $APP_POD -n qfieldcloud -- python manage.py createsuperuser

echo "✅ Database initialization completed!"
echo ""
echo "🌐 Your QFieldCloud instance is now ready!"
echo "   Login at: https://${DOMAIN}/accounts/login/"
echo "   Admin at: https://${DOMAIN}/admin/"
echo ""
echo "📋 Next steps:"
echo "1. Test the application by visiting https://${DOMAIN}"
echo "2. Login with your newly created superuser credentials"
echo "3. Configure organization settings in the admin panel"