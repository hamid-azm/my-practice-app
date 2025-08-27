#!/bin/bash

# Docker Compose ContainerConfig Error Fix Script

echo "🔧 Fixing Docker Compose ContainerConfig Error..."

# Stop all containers
echo "Stopping containers..."
docker-compose -f docker-compose.production.yml down

# Remove all containers and volumes
echo "Removing containers and volumes..."
docker-compose -f docker-compose.production.yml down -v

# Clean up Docker system
echo "Cleaning up Docker system..."
docker container prune -f
docker image prune -f
docker volume prune -f

# Remove any dangling images
echo "Removing dangling images..."
docker image prune -a -f

# Start fresh
echo "Starting containers fresh..."
docker-compose -f docker-compose.production.yml up --build -d

echo "✅ Done! Check container status:"
sleep 10
docker-compose -f docker-compose.production.yml ps
