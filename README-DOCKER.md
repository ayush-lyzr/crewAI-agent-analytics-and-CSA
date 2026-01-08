# Docker Deployment Guide for EC2

This guide explains how to deploy the A2A Payments Intelligence Agent on AWS EC2 using Docker.

## Prerequisites

- AWS EC2 instance (Ubuntu 20.04+ recommended)
- Docker and Docker Compose installed
- Port 10001 open in EC2 security group

## Quick Start

### 1. Install Docker on EC2

```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose-plugin -y

# Add user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone and Setup

```bash
# Clone your repository
git clone <your-repo-url>
cd DAMAC

# Copy environment file
cp .env.example .env

# Edit .env with your values
nano .env
```

### 3. Configure .env

```env
OPENAI_API_KEY=sk-your-key-here
PAYMENTS_API_BASE_URL=https://your-payments-api.ngrok-free.app
HOST_OVERRIDE=http://YOUR_EC2_PUBLIC_IP:10001
```

**Important**: Replace `YOUR_EC2_PUBLIC_IP` with your actual EC2 public IP address.

### 4. Start the Server

```bash
# Option 1: Use the startup script
./docker-start.sh

# Option 2: Manual docker-compose
docker-compose up -d
```

### 5. Verify Deployment

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Test agent card
curl http://YOUR_EC2_PUBLIC_IP:10001/.well-known/agent-card.json
```

## EC2 Security Group Configuration

Ensure your EC2 security group allows inbound traffic on port 10001:

```
Type: Custom TCP
Port: 10001
Source: 0.0.0.0/0 (or your specific IPs)
```

## Using a Domain Name (Optional)

If you have a domain name, you can:

1. Point your domain to EC2 IP
2. Use a reverse proxy (nginx) with SSL
3. Update `HOST_OVERRIDE` to use your domain

Example nginx config:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:10001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Docker Commands

```bash
# Start server
docker-compose up -d

# Stop server
docker-compose down

# View logs
docker-compose logs -f

# Restart server
docker-compose restart

# Rebuild after code changes
docker-compose up -d --build

# View container status
docker-compose ps

# Execute commands in container
docker-compose exec a2a-server bash
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs

# Check if port is in use
sudo lsof -i :10001

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Can't access from outside EC2

1. Check EC2 security group allows port 10001
2. Verify `HOST_OVERRIDE` in .env matches your EC2 public IP
3. Check EC2 instance firewall: `sudo ufw status`

### Environment variables not loading

- Ensure `.env` file exists in project root
- Check file permissions: `chmod 644 .env`
- Verify variables are set: `docker-compose exec a2a-server env`

## Production Considerations

1. **Use HTTPS**: Set up nginx with Let's Encrypt SSL
2. **Process Manager**: Use systemd or supervisor to auto-restart
3. **Logging**: Configure log rotation
4. **Monitoring**: Set up CloudWatch or similar
5. **Backups**: Regular backups of `.env` and configuration

## Systemd Service (Optional)

Create `/etc/systemd/system/a2a-agent.service`:

```ini
[Unit]
Description=A2A Payments Intelligence Agent
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/DAMAC
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable a2a-agent
sudo systemctl start a2a-agent
```

