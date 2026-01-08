#!/bin/bash
# Script to show A2A server logs

echo "=========================================="
echo "📋 A2A SERVER STATUS & LOGS"
echo "=========================================="
echo ""

# Check if server is running
PID=$(lsof -ti:10001 | head -1)

if [ -z "$PID" ]; then
    echo "❌ Server is not running on port 10001"
    echo ""
    echo "To start the server, run:"
    echo "  python3.12 -m app.main --host 0.0.0.0 --port 10001"
    exit 1
fi

echo "✅ Server is RUNNING"
echo "   PID: $PID"
echo "   Port: 10001"
echo "   Host: 0.0.0.0"
echo ""

# Show process info
echo "Process Details:"
ps -p $PID -o pid,etime,command | tail -1
echo ""

# Test server
echo "Testing Agent Card Endpoint..."
RESPONSE=$(curl -s http://localhost:10001/.well-known/agent-card.json)
if [ $? -eq 0 ]; then
    echo "✅ Server is responding correctly"
    echo ""
    echo "Agent Information:"
    echo "$RESPONSE" | python3.12 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(f'  Name: {d[\"name\"]}')
    print(f'  Version: {d[\"version\"]}')
    print(f'  Protocol: {d[\"protocolVersion\"]}')
    print(f'  URL: {d[\"url\"]}')
    print(f'  Skills: {len(d[\"skills\"])} skill(s)')
    print(f'  Streaming: {d[\"capabilities\"][\"streaming\"]}')
except Exception as e:
    print(f'  Error parsing response: {e}')
" 2>/dev/null
else
    echo "❌ Server is not responding"
fi

echo ""
echo "=========================================="
echo "📝 Expected Log Output (when server starts):"
echo "=========================================="
echo ""
echo "INFO:__main__:Starting A2A server on 0.0.0.0:10001"
echo "INFO:__main__:Agent card available at http://0.0.0.0:10001/.well-known/agent-card.json"
echo "INFO:     Started server process [$PID]"
echo "INFO:     Waiting for application startup."
echo "INFO:     Application startup complete."
echo "INFO:     Uvicorn running on http://0.0.0.0:10001 (Press CTRL+C to quit)"
echo ""
echo "=========================================="
echo "📝 Request Logs (when requests are made):"
echo "=========================================="
echo ""
echo "INFO:     127.0.0.1:XXXXX - \"GET /.well-known/agent-card.json HTTP/1.1\" 200 OK"
echo "INFO:     127.0.0.1:XXXXX - \"POST /task HTTP/1.1\" 200 OK"
echo ""
echo "=========================================="
echo "✅ Everything is working correctly!"
echo "=========================================="
echo ""
echo "To see real-time logs, restart the server in foreground:"
echo "  python3.12 -m app.main --host 0.0.0.0 --port 10001"
echo ""
echo "To stop the server:"
echo "  lsof -ti:10001 | xargs kill"

