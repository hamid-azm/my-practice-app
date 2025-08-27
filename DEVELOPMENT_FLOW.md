# Django Docker Development Flow

This document outlines the step-by-step process to follow when setting up and working with this Django + React + MySQL Docker application.

## 🚀 Initial Setup Flow

### 1. Environment Setup

```bash
# Clone/setup your project
cd my-practice-app

# Create .env file if it doesn't exist
# Add necessary environment variables:
# DB_NAME=myapp_db
# DB_USER=root
# DB_PASSWORD=yourpassword
# DJANGO_SECRET_KEY=your-secret-key
```

### 2. Build and Start Services

```bash
# Build and start all services
docker-compose up --build -d

# Verify all containers are running
docker ps
```

### 3. Database Migration Flow (CRITICAL - Do this every time!)

```bash
# Step 1: Create migrations for your Django apps
docker-compose exec backend python manage.py makemigrations

# Step 2: If you have specific apps, create migrations for each
docker-compose exec backend python manage.py makemigrations api

# Step 3: Apply all migrations to create database tables
docker-compose exec backend python manage.py migrate

# Step 4: Verify migrations were applied
docker-compose exec backend python manage.py showmigrations
```

### 4. Populate Initial Data (Optional)

```bash
# Run your data population script
docker-compose exec backend python populate_data.py

# Or create a superuser for admin access
docker-compose exec backend python manage.py createsuperuser
```

### 5. Django Admin Setup (For Model Management)

```bash
# If you haven't created admin.py for your models, create it:
# backend/api/admin.py

# Example admin.py content:
# from django.contrib import admin
# from .models import HelloWorld
#
# @admin.register(HelloWorld)
# class HelloWorldAdmin(admin.ModelAdmin):
#     list_display = ['message', 'created_at']
#     list_filter = ['created_at']
#     search_fields = ['message']
#     readonly_fields = ['created_at']

# After creating/updating admin.py, restart backend to pick up changes
docker-compose restart backend

# Access Django admin at: http://localhost:8000/admin/
# Login with the superuser credentials you created above
```

## 🔄 Daily Development Flow

### Starting Work

```bash
# Start services
docker-compose up -d

# Check if all containers are healthy
docker ps

# If database schema changed, run migrations
docker-compose exec backend python manage.py makemigrations
docker-compose exec backend python manage.py migrate
```

### Making Model Changes

```bash
# 1. Edit your models in backend/api/models.py
# 2. Create migrations
docker-compose exec backend python manage.py makemigrations api

# 3. Apply migrations
docker-compose exec backend python manage.py migrate

# 4. If you have populate scripts, re-run them if needed
docker-compose exec backend python populate_data.py
```

### Testing Your API

```bash
# Check if backend is responding
curl http://localhost:8000/api/hello/

# Or visit in browser:
# Backend: http://localhost:8000
# Frontend: http://localhost:3000
# Django Admin: http://localhost:8000/admin (login with superuser credentials)
```

## 🛠️ Common Troubleshooting Commands

### Database Issues

```bash
# Reset database completely (WARNING: Deletes all data!)
docker-compose down
docker volume rm my-practice-app_mysql_data
docker-compose up -d
# Then follow migration steps again

# Check database connection
docker-compose exec backend python manage.py dbshell

# View migration status
docker-compose exec backend python manage.py showmigrations
```

### Container Issues

```bash
# View logs for specific service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mysql

# Restart specific service
docker-compose restart backend

# Rebuild and restart
docker-compose up --build backend
```

### Clean Restart

```bash
# Stop all services
docker-compose down

# Remove containers and volumes (keeps images)
docker-compose down -v

# Complete clean slate (removes everything)
docker-compose down -v --rmi all

# Start fresh
docker-compose up --build -d
```

## 📝 Checklist for New Models/Apps

- [ ] Add new app to `INSTALLED_APPS` in `backend/myproject/settings.py`
- [ ] Create models in `backend/[app_name]/models.py`
- [ ] Create/update `admin.py` to register models for Django admin
- [ ] Run `docker-compose exec backend python manage.py makemigrations [app_name]`
- [ ] Run `docker-compose exec backend python manage.py migrate`
- [ ] Restart backend: `docker-compose restart backend`
- [ ] Create serializers in `backend/[app_name]/serializers.py`
- [ ] Create views in `backend/[app_name]/views.py`
- [ ] Add URLs in `backend/[app_name]/urls.py`
- [ ] Include app URLs in `backend/myproject/urls.py`
- [ ] Test API endpoints
- [ ] Update populate scripts if needed

## 🚨 Common Errors and Solutions

### "Table doesn't exist" Error

**Problem**: Django migrations not applied
**Solution**:

```bash
docker-compose exec backend python manage.py makemigrations
docker-compose exec backend python manage.py migrate
```

### "No module named [app_name]" Error

**Problem**: App not in INSTALLED_APPS
**Solution**: Add app to `INSTALLED_APPS` in settings.py

### Database Connection Error

**Problem**: MySQL not ready or wrong credentials
**Solution**:

```bash
# Check MySQL logs
docker-compose logs mysql

# Verify .env file has correct DB credentials
# Wait for MySQL to be fully ready (30-60 seconds after startup)
```

### Port Already in Use

**Problem**: Ports 3000, 8000, or 3306 already taken
**Solution**:

```bash
# Find and kill processes using the ports
netstat -ano | findstr :8000
# Or change ports in docker-compose.yml
```

## 🏗️ Project Structure Reference

```
my-practice-app/
├── docker-compose.yml          # Container orchestration
├── .env                        # Environment variables
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── manage.py
│   ├── populate_data.py        # Data seeding script
│   ├── myproject/              # Main Django project
│   │   ├── settings.py         # Django configuration
│   │   ├── urls.py            # Main URL routing
│   │   └── ...
│   └── api/                    # Django app
│       ├── models.py          # Database models
│       ├── views.py           # API views
│       ├── serializers.py     # DRF serializers
│       ├── urls.py            # App URL routing
│       └── migrations/        # Database migrations
└── frontend/
    ├── Dockerfile
    ├── package.json
    └── src/
        └── ...
```

## 📚 Useful Docker Commands

```bash
# View all containers
docker ps -a

# Access container shell
docker-compose exec backend bash
docker-compose exec mysql bash

# View container logs in real-time
docker-compose logs -f backend

# Check resource usage
docker stats

# Clean up unused resources
docker system prune
```

---

**Remember**: Always run migrations after making model changes, and keep this flow document updated as your project evolves!
