# Production Update Guide

This guide explains how to update your production deployment with new changes from your repository.

## Prerequisites

- SSH access to your VPS
- Git repository is already cloned on the VPS
- Docker and Docker Compose are installed
- Production environment is already running

## Step-by-Step Update Process

### 1. SSH into Your VPS

```bash
ssh username@your-vps-ip
# or
ssh username@testingonvps.online
```

### 2. Navigate to Your Project Directory

```bash
cd /var/www/my-practice-app
# or wherever your project is located
```

### 3. Backup Current State (Optional but Recommended)

```bash
# Create a backup of current running containers
docker-compose -f docker-compose.production.yml ps > backup-$(date +%Y%m%d-%H%M%S).txt

# Backup database (if needed)
docker-compose -f docker-compose.production.yml exec mysql mysqldump -u root -p${DB_PASSWORD} ${DB_NAME} > backup-db-$(date +%Y%m%d-%H%M%S).sql
```

### 4. Pull Latest Changes from Repository

```bash
# Pull the latest changes from your main branch
git pull origin main

# Or if you're working with a specific branch
git pull origin your-branch-name
```

### 5. Stop Current Services

```bash
# Stop all running containers
docker-compose -f docker-compose.production.yml down
```

### 6. Rebuild Images (if code changes were made)

```bash
# Rebuild images to include new changes
docker-compose -f docker-compose.production.yml build --no-cache

# Or rebuild specific services if only certain parts changed
docker-compose -f docker-compose.production.yml build --no-cache backend
docker-compose -f docker-compose.production.yml build --no-cache frontend
```

### 7. Start Services

```bash
# Start all services
docker-compose -f docker-compose.production.yml up -d
```

### 8. Run Database Migrations (if applicable)

```bash
# Run Django migrations for any database schema changes
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Collect static files (important after our recent volume changes)
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
```

### 9. Verify Deployment

```bash
# Check if all containers are running
docker-compose -f docker-compose.production.yml ps

# Check logs for any errors
docker-compose -f docker-compose.production.yml logs -f

# Check specific service logs if needed
docker-compose -f docker-compose.production.yml logs backend
docker-compose -f docker-compose.production.yml logs frontend
docker-compose -f docker-compose.production.yml logs mysql
```

### 10. Test Your Application

- Visit your website: `https://testingonvps.online`
- Test API endpoints: `https://api.testingonvps.online`
- Check that static files are loading correctly
- Verify database functionality

## Quick Update Script

You can create a script to automate this process:

```bash
#!/bin/bash
# save as update-production.sh

echo "🚀 Starting production update..."

# Navigate to project directory
cd /var/www/my-practice-app

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Stop services
echo "🛑 Stopping services..."
docker-compose -f docker-compose.production.yml down

# Rebuild images
echo "🔨 Rebuilding images..."
docker-compose -f docker-compose.production.yml build --no-cache

# Start services
echo "▶️ Starting services..."
docker-compose -f docker-compose.production.yml up -d

# Wait a moment for services to start
sleep 10

# Run migrations and collect static files
echo "🔄 Running migrations..."
docker-compose -f docker-compose.production.yml exec -T backend python manage.py migrate

echo "📁 Collecting static files..."
docker-compose -f docker-compose.production.yml exec -T backend python manage.py collectstatic --noinput

# Show status
echo "✅ Update complete! Checking status..."
docker-compose -f docker-compose.production.yml ps

echo "🎉 Production update finished!"
```

Make it executable and run:

```bash
chmod +x update-production.sh
./update-production.sh
```

## Troubleshooting

### If containers fail to start:

```bash
# Check logs for errors
docker-compose -f docker-compose.production.yml logs

# Check individual service logs
docker-compose -f docker-compose.production.yml logs backend
```

### If static files are not loading:

```bash
# Manually collect static files
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput

# Check if directories exist and have correct permissions
ls -la backend/staticfiles/
ls -la backend/media/
```

### If database connection fails:

```bash
# Check MySQL container
docker-compose -f docker-compose.production.yml logs mysql

# Restart MySQL if needed
docker-compose -f docker-compose.production.yml restart mysql
```

### Rolling back to previous version:

```bash
# If something goes wrong, you can rollback
git log --oneline -5  # See recent commits
git checkout <previous-commit-hash>

# Then rebuild and restart
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml build --no-cache
docker-compose -f docker-compose.production.yml up -d
```

## Important Notes

1. **Always test locally first** before deploying to production
2. **Backup your database** before major updates
3. **Monitor logs** after deployment to catch any issues early
4. **Update environment variables** in `.env` file if needed
5. **SSL certificates** should renew automatically, but monitor expiration
6. **Static files** now use bind mounts, so they persist on the host filesystem

## Environment Variables

Make sure your `.env` file on the VPS contains:

```env
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DJANGO_SECRET_KEY=your_secret_key
ALLOWED_HOSTS=testingonvps.online,api.testingonvps.online
SECURE_SSL_REDIRECT=True
SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO,https
```

## Maintenance Schedule

Consider setting up a regular maintenance schedule:

- **Weekly**: Check logs and system resources
- **Monthly**: Update Docker images and system packages
- **As needed**: Deploy new features and bug fixes

---

**Last Updated**: August 30, 2025
