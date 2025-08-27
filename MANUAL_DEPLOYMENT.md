# Quick Manual Deployment Guide

Since you're learning and testing, here's a simplified step-by-step manual deployment guide.

## 🎯 **Your GitHub Repository:**

- **URL**: https://github.com/hamid-azm/my-practice-app.git
- **Status**: ✅ Public repository (perfect for deployment)

## 📋 **Manual VPS Deployment Steps**

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
# Copy the template (since you already created .env.production)
cp .env.production.example .env.production

# Or create it manually with your actual values:
nano .env.production
```

**Your `.env.production` should contain:**

```env
DB_NAME=myapp_production
DB_USER=app_user
DB_PASSWORD=your_secure_password_here
DB_HOST=mysql
DB_PORT=3306
DJANGO_SECRET_KEY=your_super_secure_secret_key_minimum_50_characters
DEBUG=False
ALLOWED_HOSTS=api.testingonvps.online,testingonvps.online,localhost
SECURE_SSL_REDIRECT=True
SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO,https
REDIS_PASSWORD=your_redis_password
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

### 6. **Configure Nginx**

```bash
# Copy nginx configurations from your repository
cp /var/www/my-practice-app/nginx/testingonvps.online.conf /etc/nginx/sites-available/
cp /var/www/my-practice-app/nginx/api.testingonvps.online.conf /etc/nginx/sites-available/

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
curl -k https://api.testingonvps.online/api/health/

# Test frontend
curl -k https://testingonvps.online
```

## 🔧 **Important SSL Certificate Paths**

Make sure to update the SSL certificate paths in the nginx configuration files:

**In `/etc/nginx/sites-available/testingonvps.online.conf`:**

```nginx
ssl_certificate /path/to/your/actual/testingonvps.online.crt;
ssl_certificate_key /path/to/your/actual/testingonvps.online.key;
```

**In `/etc/nginx/sites-available/api.testingonvps.online.conf`:**

```nginx
ssl_certificate /path/to/your/actual/api.testingonvps.online.crt;
ssl_certificate_key /path/to/your/actual/api.testingonvps.online.key;
```

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
