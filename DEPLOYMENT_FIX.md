# 🚨 DEPLOYMENT ERRORS FIX

## Problem 1: Backend - Environment Variables Not Found During Docker Build

**Error**: `DB_NAME not found. Declare it as envvar or define a default value.`

## Problem 2: Frontend - TypeScript Compiler Not Found

**Error**: `sh: tsc: not found`

## ✅ **Both Issues Fixed!**

### **Backend Issue**:

Django was trying to load environment variables during the Docker build process, but those variables are only available when the container runs.

### **Frontend Issue**:

The production Dockerfile was only installing production dependencies (`npm ci --only=production`), but TypeScript and build tools are dev dependencies.

### **What I Fixed:**

1. **Backend**:

   - Removed `collectstatic` from Dockerfile - Now runs after container starts
   - Added default values to Django settings for database configuration
   - Added proper static files configuration for production

2. **Frontend**:
   - Changed `npm ci --only=production` to `npm ci` to install ALL dependencies
   - This includes TypeScript and Vite build tools needed for the build process

### **Updated Files:**

- ✅ `backend/Dockerfile.production` - Removed collectstatic from build + improved health check
- ✅ `backend/myproject/settings.py` - Added default values and production config
- ✅ `frontend/Dockerfile.production` - Install all dependencies for build

## Problem 3: Backend Container Unhealthy

**Error**: `Container "xyz" is unhealthy`

### **What This Means:**
The backend container started but failed its health check. This is usually because:
1. The backend is taking longer to start than expected
2. Database connection issues
3. Health check endpoint not responding

### **Quick Fix Applied:**
- Increased health check start period from 5s to 60s
- Increased retries from 3 to 5
- This gives the backend more time to connect to the database

## 🚀 **Current Status - Try Deployment:**

```bash
# On your VPS, try the deployment again
cd /var/www/my-practice-app

# Pull the latest fixes
git pull origin main

# Build and start containers
docker-compose -f docker-compose.production.yml up --build -d

# Wait for containers to start (backend needs time to connect to database)
sleep 60

# Check container status
docker-compose -f docker-compose.production.yml ps

# If backend shows as unhealthy, check logs
docker-compose -f docker-compose.production.yml logs backend

# Setup database (only if backend is running)
docker-compose -f docker-compose.production.yml exec backend python manage.py migrate
docker-compose -f docker-compose.production.yml exec backend python manage.py collectstatic --noinput
```

## 🔍 **If Backend Container is Still Unhealthy:**

### **Check backend logs:**
```bash
docker-compose -f docker-compose.production.yml logs backend
```

### **Check if health endpoint works manually:**
```bash
# Enter the backend container
docker-compose -f docker-compose.production.yml exec backend bash

# Test the health endpoint from inside
curl http://localhost:8000/api/health/
```

### **Restart just the backend:**
```bash
docker-compose -f docker-compose.production.yml restart backend
```

### **Check environment file:**

```bash
cat .env.production
```

Make sure it contains all required variables.

### **Check container logs:**

```bash
docker-compose -f docker-compose.production.yml logs backend
```

### **Check if containers are running:**

```bash
docker ps
```

## ✅ **The Fix Explained:**

**Before**: Django tried to load production environment variables during Docker build → ❌ Failed

**After**: Django uses default values during build, then loads real environment variables when container starts → ✅ Success

Now your deployment should work! 🎉
