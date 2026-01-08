#!/bin/bash
# Docker startup script for A2A Payments Intelligence Agent

set -e

echo "=========================================="
echo "🚀 Starting A2A Payments Intelligence Agent"
echo "=========================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "Creating .env from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env file. Please update it with your values."
        echo "   Required variables:"
        echo "   - OPENAI_API_KEY"
        echo "   - PAYMENTS_API_BASE_URL"
        echo "   - HOST_OVERRIDE"
        exit 1
    else
        echo "❌ .env.example not found. Please create .env manually."
        exit 1
    fi
fi

# Check required environment variables
source .env
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY not set in .env"
    exit 1
fi

if [ -z "$PAYMENTS_API_BASE_URL" ]; then
    echo "❌ PAYMENTS_API_BASE_URL not set in .env"
    exit 1
fi

echo "✅ Environment variables validated"

# Build and start with docker-compose
echo ""
echo "Building Docker image..."
docker-compose build

echo ""
echo "Starting container..."
docker-compose up -d

echo ""
echo "=========================================="
echo "✅ Server started!"
echo "=========================================="
echo ""
echo "Container status:"
docker-compose ps

echo ""
echo "View logs:"
echo "  docker-compose logs -f"

echo ""
echo "Stop server:"
echo "  docker-compose down"

echo ""
echo "Agent card URL:"
if [ -n "$HOST_OVERRIDE" ]; then
    echo "  $HOST_OVERRIDE/.well-known/agent-card.json"
else
    echo "  http://localhost:10001/.well-known/agent-card.json"
fi

