#!/bin/bash

# VPS Deployment Script
# Run this script on your VPS to deploy the application

set -e  # Exit on any error

echo "🚀 Starting deployment..."

# Configuration
REPO_URL="https://github.com/yourusername/your-repo-name.git"  # Update this
APP_DIR="/var/www/my-practice-app"
ENV_FILE="$APP_DIR/.env.production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root (use sudo)"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    rm get-docker.sh
else
    print_status "Docker is already installed"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    print_status "Docker Compose is already installed"
fi

# Create application directory
print_status "Setting up application directory..."
mkdir -p $APP_DIR
cd $APP_DIR

# Clone or update repository
if [ -d ".git" ]; then
    print_status "Updating existing repository..."
    git pull origin main
else
    print_status "Cloning repository..."
    git clone $REPO_URL .
fi

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    print_warning "Environment file not found. Creating from template..."
    cp .env.production.example .env.production
    print_error "Please edit $ENV_FILE with your production values before continuing!"
    print_error "Required changes:"
    print_error "- Update database passwords"
    print_error "- Set Django secret key"
    print_error "- Configure domain names"
    print_error "- Set Redis password"
    exit 1
fi

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose -f docker-compose.production.yml down || true

# Build and start containers
print_status "Building and starting containers..."
docker-compose -f docker-compose.production.yml up --build -d

# Wait for database to be ready
print_status "Waiting for database to be ready..."
sleep 30

# Run database migrations
print_status "Running database migrations..."
docker-compose -f docker-compose.production.yml exec -T backend python manage.py migrate

# Collect static files
print_status "Collecting static files..."
docker-compose -f docker-compose.production.yml exec -T backend python manage.py collectstatic --noinput

# Create superuser if it doesn't exist
print_status "Creating superuser (if needed)..."
docker-compose -f docker-compose.production.yml exec -T backend python manage.py shell << 'EOF'
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("Superuser created: admin/admin123")
else:
    print("Superuser already exists")
EOF

# Setup Nginx configuration
print_status "Setting up Nginx configuration..."

# Main site configuration
cat > /etc/nginx/sites-available/testingonvps.online << 'EOF'
server {
    listen 80;
    server_name testingonvps.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name testingonvps.online;

    ssl_certificate /etc/ssl/certs/testingonvps.online.crt;
    ssl_certificate_key /etc/ssl/private/testingonvps.online.key;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://127.0.0.1:3000;
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
EOF

# API site configuration
cat > /etc/nginx/sites-available/api.testingonvps.online << 'EOF'
server {
    listen 80;
    server_name api.testingonvps.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name api.testingonvps.online;

    ssl_certificate /etc/ssl/certs/api.testingonvps.online.crt;
    ssl_certificate_key /etc/ssl/private/api.testingonvps.online.key;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Django API
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    }

    # Static files
    location /static/ {
        alias /var/www/my-practice-app/backend/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Media files
    location /media/ {
        alias /var/www/my-practice-app/backend/media/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable sites
ln -sf /etc/nginx/sites-available/testingonvps.online /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/api.testingonvps.online /etc/nginx/sites-enabled/

# Remove default nginx configuration
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
print_status "Testing Nginx configuration..."
nginx -t

# Restart nginx
print_status "Restarting Nginx..."
systemctl restart nginx

# Setup firewall
print_status "Configuring firewall..."
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443

# Setup log rotation for Docker
print_status "Setting up log rotation..."
cat > /etc/logrotate.d/docker << 'EOF'
/var/lib/docker/containers/*/*.log {
    rotate 5
    daily
    compress
    size 10M
    missingok
    delaycompress
    copytruncate
}
EOF

# Setup backup script
print_status "Setting up backup script..."
cat > /usr/local/bin/backup-app.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/myapp"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker-compose -f /var/www/my-practice-app/docker-compose.production.yml exec -T mysql mysqldump -u root -p$DB_PASSWORD myapp_production > $BACKUP_DIR/db_backup_$DATE.sql

# Backup media files
tar -czf $BACKUP_DIR/media_backup_$DATE.tar.gz -C /var/www/my-practice-app/backend media/

# Clean old backups (keep last 7 days)
find $BACKUP_DIR -name "*.sql" -type f -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /usr/local/bin/backup-app.sh

# Setup cron job for backups
print_status "Setting up daily backups..."
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-app.sh") | crontab -

# Check container status
print_status "Checking container status..."
docker-compose -f docker-compose.production.yml ps

# Final health check
print_status "Performing health checks..."
sleep 10

# Check frontend
if curl -f -s https://testingonvps.online > /dev/null; then
    print_status "✅ Frontend is accessible"
else
    print_warning "❌ Frontend health check failed"
fi

# Check API
if curl -f -s https://api.testingonvps.online/api/health/ > /dev/null; then
    print_status "✅ API is accessible"
else
    print_warning "❌ API health check failed"
fi

print_status "🎉 Deployment completed!"
print_status ""
print_status "Your application is now running:"
print_status "Frontend: https://testingonvps.online"
print_status "API: https://api.testingonvps.online"
print_status "Admin: https://api.testingonvps.online/admin/"
print_status ""
print_status "Default admin credentials: admin/admin123"
print_status "Please change the admin password immediately!"
print_status ""
print_status "To monitor your application:"
print_status "docker-compose -f docker-compose.production.yml logs -f"
print_status ""
print_status "To update your application:"
print_status "cd $APP_DIR && git pull && docker-compose -f docker-compose.production.yml up --build -d"
