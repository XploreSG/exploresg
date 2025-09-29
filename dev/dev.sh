#!/bin/bash
set -e

echo "Starting Auth DB and Backend Service..."
(cd ../../exploresg-auth-service && docker compose up -d db)
sleep 10 # Allow DB to start up

(cd ../../exploresg-auth-service && docker compose up -d backend-auth-dev)
sleep 5

echo "Starting Frontend Service..."
(cd ../../exploresg-frontend-service && docker compose up -d frontend-dev)

echo "All services started."
docker ps --filter "name=dev-exploresg" # Show running containers with your naming pattern
