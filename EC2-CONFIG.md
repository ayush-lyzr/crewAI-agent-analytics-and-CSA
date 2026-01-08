# EC2 Configuration for A2A Server

## Your Server URLs

**EC2 Public IP**: `98.89.5.176`

### Main Endpoints

1. **A2A Server Root**
   ```
   http://98.89.5.176:10001/
   ```

2. **Agent Card (Discovery Endpoint)**
   ```
   http://98.89.5.176:10001/.well-known/agent-card.json
   ```

## .env Configuration

Update your `.env` file on EC2 with:

```env
OPENAI_API_KEY=sk-your-key-here
PAYMENTS_API_BASE_URL=https://your-payments-api.ngrok-free.app
HOST_OVERRIDE=http://98.89.5.176:10001
```

## Manager Agent Configuration

When configuring your manager agent to call this A2A server, use:

```
http://98.89.5.176:10001
```

## EC2 Security Group Setup

Ensure your EC2 security group allows inbound traffic:

- **Type**: Custom TCP
- **Port**: 10001
- **Source**:
  - `0.0.0.0/0` (for public access)
  - Or specific IPs for restricted access

## Testing

After deployment, test from any machine:

```bash
# Test agent card
curl http://98.89.5.176:10001/.well-known/agent-card.json

# Should return JSON with agent card information
```

## Deployment Steps

1. **SSH into EC2**
   ```bash
   ssh ubuntu@98.89.5.176
   ```

2. **Update .env**
   ```bash
   nano .env
   # Set HOST_OVERRIDE=http://98.89.5.176:10001
   ```

3. **Start Server**
   ```bash
   sudo ./docker-start.sh
   ```

4. **Verify**
   ```bash
   curl http://98.89.5.176:10001/.well-known/agent-card.json
   ```

## Troubleshooting

### Can't access from outside

1. Check security group allows port 10001
2. Verify container is running: `docker-compose ps`
3. Check logs: `docker-compose logs -f`
4. Test locally on EC2: `curl http://localhost:10001/.well-known/agent-card.json`

### Agent card shows wrong URL

- Ensure `HOST_OVERRIDE=http://98.89.5.176:10001` in `.env`
- Restart container: `docker-compose restart`
- Check environment: `docker-compose exec a2a-server env | grep HOST_OVERRIDE`

