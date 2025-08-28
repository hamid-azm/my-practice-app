# VPS Deployment Guide - Simplified

## 🎯 **What You Have:**

- **GitHub Repository**: https://github.com/hamid-azm/my-practice-app.git ✅
- **3 Docker Services**: MySQL + Django Backend + React Frontend ✅
- **Nginx Config Files**: Ready to copy to your VPS ✅
- **SSL Certificates**: Let's Encrypt already configured ✅
- **Simplified Setup**: No health checks for easier deployment ✅
- **Environment File**: Simple `.env` file on VPS ✅

---

## 🚀 **FIRST TIME DEPLOYMENT**

### **Step 1: SSH into your VPS**

```bash
ssh root@your-vps-ip
```

### **Step 2: Clone your repository**

```bash
cd /var/www
git clone https://github.com/hamid-azm/my-practice-app.git
cd my-practice-app
```

### **Step 3: Create environment file**

```bash
nano .env
```

**Copy and paste this (testing values ready to use):**

```env
DB_NAME=myapp_production
DB_USER=app_user
DB_PASSWORD=testing_password_123
DB_HOST=mysql
DB_PORT=3306
DJANGO_SECRET_KEY=testing_django_secret_key_for_learning_purposes_minimum_50_characters_12345
DEBUG=False
ALLOWED_HOSTS=api.testingonvps.online,testingonvps.online,localhost
SECURE_SSL_REDIRECT=True
SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO,https
VITE_API_URL=https://api.testingonvps.online
```

### **Step 4: Start Docker containers**

```bash
# Build and start all 3 containers (MySQL, Backend, Frontend)
docker-compose -f docker-compose.production.yml up --build -d

# Wait for containers to start
sleep 30

# Check containers are running
docker-compose -f docker-compose.production.yml ps
```

### **Step 5: Setup database**

```bash
# Create database tables
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Collect static files for Django
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput

# Create admin user (optional)
docker-compose -f docker-compose.production.yml exec backend python manage.py createsuperuser
```

### **Step 6: Copy nginx configurations**

```bash
# Copy the nginx config files from your repository to nginx
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

### **Step 7: Test your deployment**

```bash
# Test API
curl https://api.testingonvps.online/api/health/

# Test frontend
curl https://testingonvps.online

# Check container status
docker ps
```

## ✅ **Success! Your app should now be live at:**

- **Frontend**: https://testingonvps.online
- **API**: https://api.testingonvps.online
- **Admin**: https://api.testingonvps.online/admin/

---

## 🔄 **SUBSEQUENT DEPLOYMENTS (Updates)**

When you make changes to your code and want to update:

### **On your local machine:**

```bash
git add .
git commit -m "Your changes"
git push origin main
```

### **On your VPS:**

```bash
# Navigate to project directory
cd /var/www/my-practice-app

# Pull latest changes
git pull origin main

# Rebuild and restart containers
docker-compose -f docker-compose.production.yml up --build -d

# Run migrations (if you changed models)
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate

# Collect static files (if you changed CSS/JS)
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput

# If you updated nginx configs, copy them again
cp nginx/*.conf /etc/nginx/sites-available/
nginx -t && systemctl restart nginx
```

---

## 🚨 **Troubleshooting**

### **Containers not starting:**

```bash
# Check logs
docker-compose -f docker-compose.production.yml logs -f
```

### **Database connection errors:**

```bash
# Check if MySQL container is running
docker ps
# Check environment variables
cat .env
```

### **Nginx errors:**

```bash
# Test nginx config
nginx -t
# Check nginx logs
tail -f /var/log/nginx/error.log
```

### **Port already in use:**

```bash
# Check what's using the ports
netstat -tulpn | grep ':3000\|:8000\|:3306'
# Stop conflicting services or containers
```

---

## 📝 **About the Nginx Files**

The `nginx/` folder contains 2 configuration files:

- `testingonvps.online.conf` - Routes traffic to your React frontend (port 3000)
- `api.testingonvps.online.conf` - Routes traffic to your Django API (port 8000)

**You copy these files to your VPS nginx configuration directory** during deployment. They're already configured with your Let's Encrypt SSL certificate paths.

---

## 🎯 **Quick Commands Summary**

**First time:**

```bash
cd /var/www && git clone https://github.com/hamid-azm/my-practice-app.git && cd my-practice-app
nano .env  # Add your testing passwords
docker-compose -f docker-compose.production.yml up --build -d
sleep 30 && docker-compose -f docker-compose.production.yml exec backend python manage.py migrate
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
cp nginx/*.conf /etc/nginx/sites-available/ && ln -sf /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default && nginx -t && systemctl restart nginx
```

**Updates:**

```bash
cd /var/www/my-practice-app && git pull origin main
docker-compose -f docker-compose.production.yml up --build -d
```
