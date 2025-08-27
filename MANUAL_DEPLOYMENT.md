# Quick Manual Deployment Guide

Since you're learning and testing, here's a simplified step-by-step manual deployment guide.

## 🎯 **Your Setup Status:**

- **GitHub Repository**: https://github.com/hamid-azm/my-practice-app.git ✅
- **Repository Status**: Public (perfect for deployment) ✅
- **SSL Certificates**: Let's Encrypt configured ✅
- **Nginx Configs**: Updated with correct SSL paths ✅

## ⚡ **Quick Deployment Summary:**

```bash
# On your VPS - Complete deployment in ~5 minutes
cd /var/www
git clone https://github.com/hamid-azm/my-practice-app.git
cd my-practice-app
nano .env.production  # Add your secure passwords
docker-compose -f docker-compose.production.yml up --build -d
sleep 30
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
cp nginx/*.conf /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
```

## 📋 **Detailed Manual VPS Deployment Steps**

### 1. **SSH into your VPS**

```bash
ssh root@your-vps-ip
```

### 2. **Clone your repository**

```bash
cd /var/www
git clone https://github.com/hamid-azm/my-practice-app.git
cd my-practice-app
```

### 3. **Create production environment file**

```bash
# Create the production environment file with your actual values
nano .env.production
```

**Copy this template and update with your secure passwords:**

```env
DB_NAME=myapp_production
DB_USER=app_user
DB_PASSWORD=your_secure_password_123
DB_HOST=mysql
DB_PORT=3306
DJANGO_SECRET_KEY=your_super_secure_secret_key_minimum_50_characters_long
DEBUG=False
ALLOWED_HOSTS=api.testingonvps.online,testingonvps.online,localhost
SECURE_SSL_REDIRECT=True
SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO,https
REDIS_PASSWORD=your_redis_password_123
VITE_API_URL=https://api.testingonvps.online
```

### 4. **Deploy with Docker**

```bash
# Build and start containers
docker-compose -f docker-compose.production.yml up --build -d

# Wait for containers to start (about 30 seconds)
sleep 30

# Check if containers are running
docker-compose -f docker-compose.production.yml ps
```

### 5. **Setup Database**

```bash
# Run migrations
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Collect static files
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput

# Create superuser (optional)
docker-compose -f docker-compose.production.yml exec backend python manage.py createsuperuser
```

### 6. **Configure Nginx (SSL certificates already configured)**

✅ **Note**: The nginx configurations already have the correct Let's Encrypt SSL certificate paths:

- `testingonvps.online`: `/etc/letsencrypt/live/testingonvps.online/`
- `api.testingonvps.online`: `/etc/letsencrypt/live/api.testingonvps.online/`

```bash
# Copy nginx configurations from your repository
cp nginx/testingonvps.online.conf /etc/nginx/sites-available/
cp nginx/api.testingonvps.online.conf /etc/nginx/sites-available/

# Enable the sites
ln -sf /etc/nginx/sites-available/testingonvps.online.conf /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/api.testingonvps.online.conf /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
nginx -t

# If test passes, restart nginx
systemctl restart nginx
```

### 7. **Configure Firewall (if needed)**

```bash
# Allow necessary ports
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw --force enable
```

### 8. **Test your deployment**

```bash
# Check container status
docker-compose -f docker-compose.production.yml ps

# Check logs if needed
docker-compose -f docker-compose.production.yml logs -f backend
docker-compose -f docker-compose.production.yml logs -f frontend

# Test API health
curl https://api.testingonvps.online/api/health/

# Test frontend
curl https://testingonvps.online
```

## ✅ **SSL Certificate Configuration**

✅ **Good News**: The SSL certificate paths are already correctly configured in your nginx files:

**For `testingonvps.online`:**

```nginx
ssl_certificate /etc/letsencrypt/live/testingonvps.online/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/testingonvps.online/privkey.pem;
```

**For `api.testingonvps.online`:**

```nginx
ssl_certificate /etc/letsencrypt/live/api.testingonvps.online/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/api.testingonvps.online/privkey.pem;
```

**No manual SSL configuration needed** - your Let's Encrypt certificates will work automatically!

## 🚨 **Common Issues & Solutions**

### **Containers not starting:**

```bash
# Check logs
docker-compose -f docker-compose.production.yml logs

# Restart specific container
docker-compose -f docker-compose.production.yml restart backend
```

### **Database connection errors:**

- Check your `.env.production` file
- Make sure MySQL container is running: `docker ps`

### **Nginx errors:**

```bash
# Check nginx error logs
tail -f /var/log/nginx/error.log

# Test nginx config
nginx -t
```

### **SSL issues:**

- Verify your SSL certificate paths
- Check certificate permissions: `ls -la /path/to/your/certificates/`

## 🔄 **Quick Update Process**

When you make changes to your code:

```bash
cd /var/www/my-practice-app
git pull origin main
docker-compose -f docker-compose.production.yml up --build -d
```

## 📍 **Your Application URLs**

After successful deployment:

- **Frontend**: https://testingonvps.online
- **API**: https://api.testingonvps.online
- **Admin Panel**: https://api.testingonvps.online/admin/
- **Health Check**: https://api.testingonvps.online/api/health/

## ✅ **Success Checklist**

- [ ] Repository cloned to `/var/www/my-practice-app`
- [ ] `.env.production` file created with actual values
- [ ] Docker containers running (check with `docker ps`)
- [ ] Database migrations completed
- [ ] Static files collected
- [ ] Nginx configuration updated and restarted
- [ ] SSL certificates properly configured
- [ ] Firewall configured
- [ ] Both domains accessible via HTTPS

Good luck with your deployment! This manual process will help you understand each step better.
