# VPS Deployment Guide

This guide will help you deploy your Django + React + MySQL application to your VPS using Docker containers with SSL certificates.

## Prerequisites

- VPS with Docker and Docker Compose installed
- Domain: `testingonvps.online` (main site)
- Subdomain: `api.testingonvps.online` (API)
- SSL certificates already installed
- GitHub account (for code repository)

## 🚀 Deployment Flow

### 1. Push Code to GitHub

First, create a GitHub repository and push your local code:

```bash
# Initialize git repository (if not already done)
git init
git add .
git commit -m "Initial commit - Django React MySQL app"

# Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/your-repo-name.git
git branch -M main
git push -u origin main
```

### 2. VPS Server Setup

SSH into your VPS and set up the deployment environment:

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Navigate to web directory
cd /var/www

# Clone your repository
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

# Create production environment file
cp .env.example .env.production
```

### 3. Production Configuration

Create production-ready configurations:

**Production Environment Variables (.env.production):**

```env
# Database Configuration
DB_NAME=myapp_production
DB_USER=app_user
DB_PASSWORD=secure_production_password
DB_HOST=mysql
DB_PORT=3306

# Django Configuration
DJANGO_SECRET_KEY=your-super-secure-production-secret-key
DEBUG=False
ALLOWED_HOSTS=api.testingonvps.online,testingonvps.online

# Security Settings
SECURE_SSL_REDIRECT=True
SECURE_PROXY_SSL_HEADER=('HTTP_X_FORWARDED_PROTO', 'https')
```

### 4. Nginx Configuration

Create Nginx configuration to serve both frontend and backend:

**For Main Site (testingonvps.online):**

```nginx
server {
    listen 80;
    server_name testingonvps.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name testingonvps.online;

    ssl_certificate /path/to/your/ssl/certificate.crt;
    ssl_certificate_key /path/to/your/ssl/private.key;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**For API Subdomain (api.testingonvps.online):**

```nginx
server {
    listen 80;
    server_name api.testingonvps.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name api.testingonvps.online;

    ssl_certificate /path/to/your/ssl/certificate.crt;
    ssl_certificate_key /path/to/your/ssl/private.key;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /static/ {
        alias /var/www/your-repo-name/backend/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /var/www/your-repo-name/backend/media/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 5. Production Deployment Commands

Run these commands on your VPS:

```bash
# Build and start production containers
docker-compose -f docker-compose.production.yml up --build -d

# Run database migrations
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Collect static files for Django
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput

# Create superuser (optional)
docker-compose -f docker-compose.production.yml exec backend python manage.py createsuperuser

# Restart Nginx to apply new configuration
sudo systemctl restart nginx
```

### 6. Domain Configuration

Update your frontend to use the correct API URL:

- Frontend will be served from: `https://testingonvps.online`
- API will be available at: `https://api.testingonvps.online`

### 7. Monitoring and Maintenance

```bash
# Check container status
docker ps

# View logs
docker-compose -f docker-compose.production.yml logs -f backend
docker-compose -f docker-compose.production.yml logs -f frontend

# Update deployment
git pull origin main
docker-compose -f docker-compose.production.yml up --build -d

# Backup database
docker-compose -f docker-compose.production.yml exec mysql mysqldump -u root -p myapp_production > backup_$(date +%Y%m%d).sql
```

### 8. Security Considerations

1. **Firewall Configuration:**

   ```bash
   # Only allow necessary ports
   ufw allow 22      # SSH
   ufw allow 80      # HTTP
   ufw allow 443     # HTTPS
   ufw enable
   ```

2. **Docker Security:**

   - Run containers as non-root users
   - Limit container resources
   - Use secrets for sensitive data

3. **Database Security:**
   - Use strong passwords
   - Limit database access to application containers only
   - Regular backups

### 9. Troubleshooting

**Common Issues:**

- **Static files not loading:** Run `collectstatic` command
- **Database connection errors:** Check environment variables
- **SSL issues:** Verify certificate paths in Nginx config
- **CORS errors:** Update Django CORS settings

**Useful Commands:**

```bash
# Enter container shell
docker-compose -f docker-compose.production.yml exec backend bash

# Check container resources
docker stats

# Clean up unused containers/images
docker system prune -a
```

## Next Steps

1. Set up automated backups
2. Configure monitoring (Prometheus/Grafana)
3. Set up log aggregation
4. Implement CI/CD pipeline for automatic deployments
5. Configure load balancing if needed

## Quick Reference

- **Frontend URL:** https://testingonvps.online
- **API URL:** https://api.testingonvps.online
- **Admin Panel:** https://api.testingonvps.online/admin/
- **Project Directory:** `/var/www/your-repo-name`
