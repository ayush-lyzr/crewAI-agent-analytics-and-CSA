#!/bin/bash
# Script to start A2A server with ngrok URL

cd /Users/ayushkumar/Documents/Lyzr2/DAMAC

# Check if ngrok is running
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python3.12 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tunnels = data.get('tunnels', [])
    for t in tunnels:
        if 'public_url' in t and '10001' in t.get('config', {}).get('addr', ''):
            print(t['public_url'])
            break
except:
    pass
" 2>/dev/null)

if [ -z "$NGROK_URL" ]; then
    echo "❌ Ngrok not found or not tunneling to port 10001"
    echo "Please start ngrok first:"
    echo "  ngrok http 10001"
    exit 1
fi

echo "=========================================="
echo "🚀 Starting A2A Server with Ngrok"
echo "=========================================="
echo "Ngrok URL: $NGROK_URL"
echo ""

# Stop existing server
lsof -ti:10001 | xargs kill 2>/dev/null
sleep 2

# Set HOST_OVERRIDE and start server
export HOST_OVERRIDE="$NGROK_URL"
echo "✅ HOST_OVERRIDE set to: $HOST_OVERRIDE"
echo ""

# Start server with logging
python3.12 -m app.main --host 0.0.0.0 --port 10001 > /tmp/a2a_live_logs.log 2>&1 &
SERVER_PID=$!

sleep 4

# Verify server started
if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "✅ Server started (PID: $SERVER_PID)"
    echo ""
    echo "Agent Card URL:"
    curl -s http://localhost:10001/.well-known/agent-card.json | python3.12 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(f'  {d[\"url\"]}')
    if 'ngrok' in d['url']:
        print('  ✅ Correctly configured for ngrok!')
    else:
        print('  ⚠️  Warning: URL does not contain ngrok')
except Exception as e:
    print(f'  ❌ Error: {e}')
" 2>/dev/null

    echo ""
    echo "=========================================="
    echo "📋 To watch live logs:"
    echo "  ./live_logs.sh"
    echo "  or"
    echo "  tail -f /tmp/a2a_live_logs.log"
    echo "=========================================="
else
    echo "❌ Server failed to start"
    echo "Check logs:"
    tail -20 /tmp/a2a_live_logs.log
    exit 1
fi

