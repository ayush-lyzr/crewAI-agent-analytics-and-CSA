#!/bin/bash
# Script to watch live A2A server logs

LOG_FILE="/tmp/a2a_live_logs.log"
PID=$(lsof -ti:10001 | head -1)

if [ -z "$PID" ]; then
    echo "❌ Server is not running on port 10001"
    echo "Starting server..."
    cd /Users/ayushkumar/Documents/Lyzr2/DAMAC
    python3.12 -m app.main --host 0.0.0.0 --port 10001 2>&1 | tee "$LOG_FILE" &
    sleep 3
    PID=$(lsof -ti:10001 | head -1)
fi

if [ -z "$PID" ]; then
    echo "❌ Failed to start server"
    exit 1
fi

echo "=========================================="
echo "📋 LIVE A2A SERVER LOGS"
echo "=========================================="
echo "Server PID: $PID"
echo "Port: 10001"
echo "Log File: $LOG_FILE"
echo ""
echo "Press Ctrl+C to stop watching (server will continue running)"
echo "=========================================="
echo ""

# Show recent logs first
if [ -f "$LOG_FILE" ]; then
    echo "Recent logs:"
    tail -20 "$LOG_FILE"
    echo ""
    echo "--- Following new logs (live) ---"
    echo ""
fi

# Follow the log file
tail -f "$LOG_FILE" 2>/dev/null || {
    echo "Log file not found. Showing server output directly..."
    # If log file doesn't exist, try to attach to the process
    strace -p "$PID" 2>&1 | grep -E "(read|write|connect)" || echo "Cannot attach to process. Server may be running in background."
}

