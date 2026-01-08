#!/bin/bash
# Docker startup script for A2A Payments Intelligence Agent

set -e

echo "=========================================="
echo "🚀 Starting A2A Payments Intelligence Agent"
echo "=========================================="

# Check if user has Docker permissions
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker permission issue detected!"
    echo ""
    echo "You need to either:"
    echo "  1. Run with sudo: sudo ./docker-start.sh"
    echo "  2. Add user to docker group: sudo usermod -aG docker $USER"
    echo "     Then logout and login again, or run: newgrp docker"
    echo ""
    echo "Attempting with sudo..."
    exec sudo "$0" "$@"
fi

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

# Detect docker-compose command (docker compose or docker-compose)
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo "❌ docker-compose not found. Please install docker-compose."
    exit 1
fi

# Build and start with docker-compose
echo ""
echo "Building Docker image..."
$DOCKER_COMPOSE_CMD build

echo ""
echo "Starting container..."
$DOCKER_COMPOSE_CMD up -d

echo ""
echo "=========================================="
echo "✅ Server started!"
echo "=========================================="
echo ""
echo "Container status:"
$DOCKER_COMPOSE_CMD ps

echo ""
echo "View logs:"
echo "  $DOCKER_COMPOSE_CMD logs -f"

echo ""
echo "Stop server:"
echo "  $DOCKER_COMPOSE_CMD down"

echo ""
echo "Agent card URL:"
if [ -n "$HOST_OVERRIDE" ]; then
    echo "  $HOST_OVERRIDE/.well-known/agent-card.json"
else
    echo "  http://localhost:10001/.well-known/agent-card.json"
fi

