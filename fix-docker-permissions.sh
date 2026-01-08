#!/bin/bash
# Fix Docker permissions on EC2

echo "=========================================="
echo "🔧 Fixing Docker Permissions"
echo "=========================================="

# Add current user to docker group
echo "Adding $USER to docker group..."
sudo usermod -aG docker $USER

echo ""
echo "✅ User added to docker group!"
echo ""
echo "⚠️  IMPORTANT: You need to logout and login again for changes to take effect."
echo ""
echo "Or run this command to apply immediately:"
echo "  newgrp docker"
echo ""
echo "Then try running docker-start.sh again:"
echo "  ./docker-start.sh"

