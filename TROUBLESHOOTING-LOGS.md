# Troubleshooting: Not Seeing Executor Logs

## Issue

You see GET requests in logs but no POST requests or executor logs when manager agent calls.

## What the Logs Show

```
✅ GET /.well-known/agent-card.json - Working (agent discovery)
❌ GET / - Returns 405 - Wrong HTTP method
❌ No POST requests
❌ No app.agent_executor logs
```

## Root Cause

The manager agent may be:
1. **Using GET instead of POST** - A2A protocol requires POST
2. **Calling wrong endpoint** - Should call `/` with POST, not GET
3. **Request format incorrect** - Not following A2A JSON-RPC format

## A2A Protocol Requirements

### Correct Request Format

```http
POST / HTTP/1.1
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "task/create",
  "params": {
    "message": {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "What is the status of orderId 19233455"
        }
      ]
    }
  },
  "id": 1
}
```

### What You Should See in Logs

When a request is properly received, you'll see:

```
2026-01-08 12:14:16 - app.agent_executor - INFO - ============================================================
2026-01-08 12:14:16 - app.agent_executor - INFO - 🚀 NEW REQUEST RECEIVED
2026-01-08 12:14:16 - app.agent_executor - INFO - Task ID: abc-123-def
2026-01-08 12:14:16 - app.agent_executor - INFO - Context ID: xyz-456-ghi
2026-01-08 12:14:16 - app.agent_executor - INFO - User input: What is the status of orderId 19233455...
2026-01-08 12:14:16 - app.agent_executor - INFO - ============================================================
2026-01-08 12:14:16 - app.agent_executor - INFO - Executing CrewAI agent...
```

## Solutions

### 1. Check Manager Agent Configuration

Verify your manager agent is:
- Using **POST** method (not GET)
- Calling the correct URL: `http://98.89.5.176:10001/`
- Sending JSON-RPC 2.0 format
- Using `Content-Type: application/json` header

### 2. Test with curl

Test if the server accepts POST requests:

```bash
curl -X POST http://98.89.5.176:10001/ \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "task/create",
    "params": {
      "message": {
        "role": "user",
        "content": [{"type": "text", "text": "test"}]
      }
    },
    "id": 1
  }'
```

You should see executor logs appear.

### 3. Check Manager Agent Logs

Look at your manager agent logs to see:
- What HTTP method it's using
- What URL it's calling
- What request format it's sending

### 4. Verify A2A Client Configuration

If using an A2A client library, ensure:
- Transport is set to `JSONRPC` (not REST)
- Base URL is correct: `http://98.89.5.176:10001`
- Protocol version matches: `0.3.0`

## Enhanced Logging

The code has been updated to show more detailed logs. After rebuilding:

```bash
# On EC2
docker-compose up -d --build
docker-compose logs -f
```

You'll now see:
- Clear request markers
- Task/Context IDs
- Full user input
- All executor activity

## Common Issues

### Issue: GET / returns 405

**Cause**: Manager agent using GET instead of POST

**Fix**: Configure manager agent to use POST method

### Issue: No executor logs

**Cause**: Request not reaching executor (wrong format, wrong endpoint)

**Fix**:
1. Verify request format matches A2A JSON-RPC spec
2. Check manager agent is calling `/` (root), not another path
3. Ensure Content-Type header is set

### Issue: Connection timeout

**Cause**: Security group or firewall blocking

**Fix**: Verify EC2 security group allows port 10001

## Debugging Steps

1. **Test locally on EC2**:
   ```bash
   curl -X POST http://localhost:10001/ \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"task/create","params":{"message":{"role":"user","content":[{"type":"text","text":"test"}]}},"id":1}'
   ```

2. **Check if executor is called**:
   - Look for `app.agent_executor` logs
   - Should see "NEW REQUEST RECEIVED"

3. **Verify manager agent config**:
   - Check HTTP method (must be POST)
   - Check URL (must be `http://98.89.5.176:10001/`)
   - Check request format (must be JSON-RPC 2.0)

4. **Check network connectivity**:
   - From manager agent location, test: `curl http://98.89.5.176:10001/.well-known/agent-card.json`
   - Should return agent card JSON

