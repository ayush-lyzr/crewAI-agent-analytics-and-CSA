#!/bin/bash
# Continuous live logs viewer for A2A server

LOG_FILE="/tmp/a2a_live_logs.log"

echo "=========================================="
echo "📋 A2A SERVER - LIVE LOGS"
echo "=========================================="
echo ""
echo "Watching log file: $LOG_FILE"
echo "Press Ctrl+C to stop watching"
echo ""
echo "=========================================="
echo ""

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "⚠️  Log file not found. Server might not be running with logging."
    echo "Starting server with logging..."
    cd /Users/ayushkumar/Documents/Lyzr2/DAMAC
    python3.12 -m app.main --host 0.0.0.0 --port 10001 2>&1 | tee "$LOG_FILE" &
    sleep 2
fi

# Show recent logs first
if [ -f "$LOG_FILE" ]; then
    echo "Recent logs (last 30 lines):"
    echo "----------------------------------------"
    tail -30 "$LOG_FILE"
    echo ""
    echo "--- Now following new logs (live) ---"
    echo ""
    # Follow the log file
    tail -f "$LOG_FILE"
else
    echo "❌ Cannot access log file"
    exit 1
fi

