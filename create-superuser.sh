#!/bin/bash

# Script to create QFieldCloud superuser after deployment

# Configuration
DOMAIN="qfieldcloud.example.com"

echo "🔐 Creating QFieldCloud superuser..."

# Get the app pod name
APP_POD=$(kubectl get pods -n qfieldcloud -l app.kubernetes.io/name=qfieldcloud -o jsonpath='{.items[0].metadata.name}')

if [ -z "$APP_POD" ]; then
    echo "❌ No QFieldCloud app pod found. Make sure the deployment is running."
    exit 1
fi

echo "📱 Found app pod: $APP_POD"

# Create superuser interactively
echo "🚀 Creating superuser (you'll be prompted for username, email, and password)..."
kubectl exec -it $APP_POD -n qfieldcloud -- python manage.py createsuperuser

echo "✅ Superuser created! You can now login to QFieldCloud."
echo "🌐 Login at: https://${DOMAIN}/accounts/login/"