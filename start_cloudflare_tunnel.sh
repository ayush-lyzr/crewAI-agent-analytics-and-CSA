#!/bin/bash
# Script to start Cloudflare Tunnel for A2A server

cd /Users/ayushkumar/Documents/Lyzr2/DAMAC

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared is not installed"
    echo ""
    echo "Install it with:"
    echo "  brew install cloudflare/cloudflare/cloudflared"
    echo ""
    echo "Or download from:"
    echo "  https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/"
    exit 1
fi

# Check if server is running
if ! lsof -ti:10001 > /dev/null 2>&1; then
    echo "⚠️  Server not running on port 10001"
    echo "Starting server first..."
    export HOST_OVERRIDE=https://placeholder.trycloudflare.com
    python3.12 -m app.main --host 0.0.0.0 --port 10001 > /tmp/a2a_live_logs.log 2>&1 &
    sleep 3
fi

# Kill existing cloudflared for port 10001 if any
pkill -f "cloudflared.*10001" 2>/dev/null
sleep 1

echo "=========================================="
echo "🚀 Starting Cloudflare Tunnel"
echo "=========================================="
echo ""

# Start cloudflared tunnel
cloudflared tunnel --url http://localhost:10001 > /tmp/cloudflared_10001.log 2>&1 &
CLOUDFLARE_PID=$!

echo "Cloudflare tunnel starting (PID: $CLOUDFLARE_PID)..."
echo "Waiting for tunnel to initialize..."
sleep 5

# Extract URL from logs
CLOUDFLARE_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cloudflared_10001.log 2>/dev/null | head -1)

if [ -n "$CLOUDFLARE_URL" ]; then
    echo ""
    echo "=========================================="
    echo "✅ TUNNEL ACTIVE"
    echo "=========================================="
    echo ""
    echo "Your A2A Server URL:"
    echo "  $CLOUDFLARE_URL"
    echo ""
    echo "Agent Card:"
    echo "  $CLOUDFLARE_URL/.well-known/agent-card.json"
    echo ""
    echo "✅ Update HOST_OVERRIDE:"
    echo "  export HOST_OVERRIDE=$CLOUDFLARE_URL"
    echo ""
    echo "=========================================="
    echo "📋 To stop tunnel:"
    echo "  kill $CLOUDFLARE_PID"
    echo "=========================================="
else
    echo ""
    echo "⚠️  URL not found yet. Check logs:"
    echo "  tail -f /tmp/cloudflared_10001.log"
    echo ""
    echo "Or wait a few seconds and run:"
    echo "  grep trycloudflare /tmp/cloudflared_10001.log"
fi

