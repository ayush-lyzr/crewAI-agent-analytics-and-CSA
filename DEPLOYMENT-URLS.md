# A2A Server URLs After Deployment

## Quick Reference

After deploying on EC2, your A2A server will be accessible at:

### Main Endpoints

1. **A2A Server Root**
   ```
   http://YOUR_EC2_PUBLIC_IP:10001/
   ```

2. **Agent Card (Discovery Endpoint)**
   ```
   http://YOUR_EC2_PUBLIC_IP:10001/.well-known/agent-card.json
   ```

## Finding Your EC2 Public IP

```bash
# On EC2 instance
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Or check AWS Console → EC2 → Instances → Your Instance → Public IPv4 address
```

## Configuration

### Step 1: Get Your EC2 Public IP

```bash
# Run this on your EC2 instance
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Your EC2 Public IP: $EC2_IP"
```

### Step 2: Update .env File

Edit your `.env` file:

```env
OPENAI_API_KEY=sk-your-key-here
PAYMENTS_API_BASE_URL=https://your-payments-api.ngrok-free.app
HOST_OVERRIDE=http://YOUR_EC2_PUBLIC_IP:10001
```

**Important**: Replace `YOUR_EC2_PUBLIC_IP` with your actual EC2 public IP address.

### Step 3: Verify

After deployment, test the agent card:

```bash
curl http://YOUR_EC2_PUBLIC_IP:10001/.well-known/agent-card.json
```

## Example

If your EC2 public IP is `54.123.45.67`:

- **Server URL**: `http://54.123.45.67:10001/`
- **Agent Card**: `http://54.123.45.67:10001/.well-known/agent-card.json`
- **HOST_OVERRIDE in .env**: `http://54.123.45.67:10001`

## Using a Domain Name (Optional)

If you have a domain name pointing to your EC2 instance:

1. Point your domain's A record to your EC2 public IP
2. Update `.env`:
   ```env
   HOST_OVERRIDE=http://your-domain.com:10001
   ```
3. Your URLs will be:
   - `http://your-domain.com:10001/`
   - `http://your-domain.com:10001/.well-known/agent-card.json`

## Using HTTPS (Production)

For production, set up HTTPS with nginx and Let's Encrypt:

1. Install nginx and certbot
2. Configure nginx to proxy to `localhost:10001`
3. Set up SSL certificate
4. Update `.env`:
   ```env
   HOST_OVERRIDE=https://your-domain.com
   ```

Then your URLs will be:
- `https://your-domain.com/`
- `https://your-domain.com/.well-known/agent-card.json`

## Manager Agent Configuration

When configuring your manager agent to call this A2A server, use:

```
http://YOUR_EC2_PUBLIC_IP:10001
```

Or if using a domain:

```
http://your-domain.com:10001
```

## Security Group Configuration

Ensure your EC2 security group allows inbound traffic:

- **Type**: Custom TCP
- **Port**: 10001
- **Source**:
  - `0.0.0.0/0` (public access)
  - Or specific IPs for restricted access

## Testing After Deployment

```bash
# 1. Test agent card
curl http://YOUR_EC2_PUBLIC_IP:10001/.well-known/agent-card.json

# 2. Check container logs
docker-compose logs -f

# 3. Test from another machine
curl -X POST http://YOUR_EC2_PUBLIC_IP:10001/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"task/create","params":{"message":{"role":"user","content":[{"type":"text","text":"test"}]}},"id":1}'
```

## Troubleshooting

### Can't access from outside EC2

1. Check security group allows port 10001
2. Verify EC2 instance firewall: `sudo ufw status`
3. Ensure `HOST_OVERRIDE` in `.env` matches your public IP
4. Check container is running: `docker-compose ps`

### Agent card shows wrong URL

- Verify `HOST_OVERRIDE` in `.env` is correct
- Restart container: `docker-compose restart`
- Check logs: `docker-compose logs a2a-server`

