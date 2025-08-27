# Django + React + MySQL Docker Application

A full-stack web application with Django REST API backend, React frontend, and MySQL database, all containerized with Docker.

## 🏗️ Architecture

- **Frontend**: React + TypeScript + Vite (Port 3000)
- **Backend**: Django + Django REST Framework (Port 8000)
- **Database**: MySQL 8.0 (Port 3306)
- **Caching**: Redis (Port 6379)
- **Web Server**: Nginx (Production)
- **WSGI Server**: Gunicorn (Production)

## 🚀 Quick Start (Development)

### Prerequisites

- Docker and Docker Compose
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

# Start development environment
docker-compose up --build -d

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Access the application
# Frontend: http://localhost:3000
# API: http://localhost:8000
# Admin: http://localhost:8000/admin/
```

## 🌐 Production Deployment

### VPS Requirements

- Ubuntu 20.04+ or similar Linux distribution
- Docker and Docker Compose installed
- Domain with SSL certificates configured
- Nginx installed

### Automated Deployment

1. **Push code to GitHub**:

   ```bash
   git add .
   git commit -m "Ready for production deployment"
   git push origin main
   ```

2. **Run deployment script on VPS**:

   ```bash
   # SSH into your VPS
   ssh root@your-vps-ip

   # Download and run deployment script
   wget https://raw.githubusercontent.com/yourusername/your-repo-name/main/deploy.sh
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Configure environment variables**:
   Edit `/var/www/my-practice-app/.env.production` with your production values.

### Manual Deployment Steps

1. **Clone repository on VPS**:

   ```bash
   cd /var/www
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

2. **Setup environment**:

   ```bash
   cp .env.production.example .env.production
   # Edit .env.production with your values
   ```

3. **Deploy with Docker**:

   ```bash
   docker-compose -f docker-compose.production.yml up --build -d
   docker-compose -f docker-compose.production.yml exec backend python manage.py migrate
   docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
   ```

4. **Configure Nginx**:

   ```bash
   # Copy nginx configurations
   cp nginx/testingonvps.online.conf /etc/nginx/sites-available/
   cp nginx/api.testingonvps.online.conf /etc/nginx/sites-available/

   # Enable sites
   ln -s /etc/nginx/sites-available/testingonvps.online.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/api.testingonvps.online.conf /etc/nginx/sites-enabled/

   # Test and restart nginx
   nginx -t
   systemctl restart nginx
   ```

## 🔧 Configuration

### Environment Variables

**Development (.env)**:

- `DEBUG=True`
- `DB_HOST=mysql`
- `VITE_API_URL=http://localhost:8000`

**Production (.env.production)**:

- `DEBUG=False`
- `ALLOWED_HOSTS=api.testingonvps.online,testingonvps.online`
- `VITE_API_URL=https://api.testingonvps.online`
- Strong passwords for all services

### SSL Configuration

Ensure your SSL certificates are properly configured:

- Main site: `/etc/ssl/certs/testingonvps.online.crt`
- API subdomain: `/etc/ssl/certs/api.testingonvps.online.crt`

## 📝 API Endpoints

- `GET /api/hello/` - Simple hello world endpoint
- `GET /api/hello-list/` - List all hello world messages
- `POST /api/hello-list/` - Create new hello world message
- `GET /api/health/` - Health check endpoint

## 🔍 Monitoring

### Health Checks

- Frontend: `https://testingonvps.online`
- API: `https://api.testingonvps.online/api/health/`

### Logs

```bash
# View all container logs
docker-compose -f docker-compose.production.yml logs -f

# View specific service logs
docker-compose -f docker-compose.production.yml logs -f backend
docker-compose -f docker-compose.production.yml logs -f frontend
```

### Container Status

```bash
docker-compose -f docker-compose.production.yml ps
```

## 🛠️ Maintenance

### Updates

```bash
cd /var/www/my-practice-app
git pull origin main
docker-compose -f docker-compose.production.yml up --build -d
```

### Backups

Automated daily backups are configured via cron:

```bash
# Manual backup
/usr/local/bin/backup-app.sh

# View backup files
ls -la /var/backups/myapp/
```

### Database Management

```bash
# Access database
docker-compose -f docker-compose.production.yml exec mysql mysql -u root -p

# Run migrations
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Create superuser
docker-compose -f docker-compose.production.yml exec backend python manage.py createsuperuser
```

## 🔒 Security

### Best Practices Implemented

- Non-root Docker containers
- SSL/TLS encryption
- Security headers
- Firewall configuration
- Strong password requirements
- Regular security updates

### Security Checklist

- [ ] Change default admin password
- [ ] Update all default passwords in `.env.production`
- [ ] Configure fail2ban (optional)
- [ ] Setup monitoring and alerting
- [ ] Regular security updates

## 🐛 Troubleshooting

### Common Issues

**Container won't start**:

```bash
docker-compose -f docker-compose.production.yml logs [service-name]
```

**Database connection errors**:

- Check environment variables
- Ensure MySQL container is healthy
- Verify network connectivity

**Static files not loading**:

```bash
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
```

**SSL certificate errors**:

- Verify certificate paths in Nginx config
- Check certificate validity
- Ensure proper permissions

### Useful Commands

```bash
# Restart all services
docker-compose -f docker-compose.production.yml restart

# Rebuild and restart specific service
docker-compose -f docker-compose.production.yml up --build -d backend

# Access container shell
docker-compose -f docker-compose.production.yml exec backend bash

# Check resource usage
docker stats
```

## 📞 Support

For issues and questions:

1. Check the logs first
2. Review this documentation
3. Check GitHub issues
4. Create a new issue with detailed information

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
