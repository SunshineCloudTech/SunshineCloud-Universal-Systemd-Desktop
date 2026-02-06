#!/bin/bash

# Docker Entrypoint Script for SunshineCloud Universal Development Environment
# This script initializes various services for development workloads

set -e

echo "Starting SunshineCloud Universal Development Environment container..."

# Set environment variables for services
export HOME=/home/matrix0523
export USER=matrix0523
export SHELL=/usr/bin/bash

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to ensure directory exists with proper permissions
ensure_dir() {
    local dir=$1
    local owner=${2:-root:root}
    local perms=${3:-755}
    
    if [ ! -d "$dir" ]; then
        sudo mkdir -vp "$dir"
        log "Created directory: $dir"
    fi
    sudo chown "$owner" "$dir" 2>/dev/null || true
    sudo chmod "$perms" "$dir" 2>/dev/null || true
}

# Function to cleanup PID files and stop services gracefully
cleanup() {
    log "Received termination signal, cleaning up..."
    
    # Stop services gracefully
    log "Stopping services..."
    sudo service supervisor stop 2>/dev/null || true
    sudo service mysql stop 2>/dev/null || true
    sudo service redis-server stop 2>/dev/null || true
    
    # Remove PID files
    log "Cleaning up PID files..."
    sudo rm -f /var/run/supervisor.pid 2>/dev/null || true
    sudo rm -f /var/run/mysqld/mysqld.pid 2>/dev/null || true
    sudo rm -f /var/run/redis/redis-server.pid 2>/dev/null || true
    
    log "Cleanup completed"
    exit 0
}

# Function to clean stale PID files and processes
clean_stale_resources() {
    log "Cleaning stale PID files and processes..."
    
    # Clean service PID files
    local service_pids=("/var/run/supervisor.pid" "/var/run/mysqld/mysqld.pid" "/var/run/redis/redis-server.pid")
    for pid_file in "${service_pids[@]}"; do
        if [ -f "$pid_file" ]; then
            local pid=$(cat "$pid_file" 2>/dev/null || echo "")
            if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
                log "Removing stale PID file: $pid_file"
                sudo rm -f "$pid_file" 2>/dev/null || true
            fi
        fi
    done
    
    log "Stale resource cleanup completed"
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGTERM SIGINT SIGQUIT

# Clean stale resources before starting services
clean_stale_resources

# Initialize SSH
log "Initializing SSH service..."
if [ -f "/usr/local/share/ssh-init.sh" ]; then
    /usr/local/share/ssh-init.sh
    log "SSH initialization completed"
else
    log "Warning: SSH init script not found"
fi

# Initialize Docker
log "Initializing Docker service..."
if [ -f "/usr/local/share/docker-init.sh" ]; then
    /usr/local/share/docker-init.sh
    log "Docker initialization completed"
else
    log "Warning: Docker init script not found"
fi

# Start supervisor service
log "Starting supervisor service..."
sudo service supervisor start || log "Warning: Failed to start supervisor"

# Restart D-Bus service
log "Restarting D-Bus service..."
sudo service dbus restart || log "Warning: Failed to restart D-Bus"

# Ensure required directories exist with proper permissions
ensure_dir "/var/run" "root:root" "755"
ensure_dir "/run" "root:root" "755"

log "All development services have been initialized"
log "Development container is ready for use"

# Function to monitor services and restart if needed
monitor_services() {
    while true; do
        sleep 60
        
        # Check if supervisor is running
        if ! pgrep -f "supervisord" > /dev/null 2>&1; then
            log "Supervisor process not found, attempting to restart..."
            sudo service supervisor start || log "Warning: Failed to restart supervisor"
        fi
        
        # Check if dbus is running
        if ! pgrep -f "dbus" > /dev/null 2>&1; then
            log "D-Bus process not found, attempting to restart..."
            sudo service dbus restart || log "Warning: Failed to restart D-Bus"
        fi
    done
}

# Enhanced cleanup function that also kills monitor process
enhanced_cleanup() {
    log "Enhanced cleanup: stopping monitor and services..."
    
    # Kill monitor process if it exists
    if [ -n "$MONITOR_PID" ]; then
        kill "$MONITOR_PID" 2>/dev/null || true
    fi
    
    # Call original cleanup
    cleanup
}

# Update signal handler to use enhanced cleanup
trap enhanced_cleanup SIGTERM SIGINT SIGQUIT

# Start service monitor in background
monitor_services &
MONITOR_PID=$!

log "Service monitoring started (PID: $MONITOR_PID)"

# Keep the container running with an interactive bash shell
# Handle the case where we want to keep the container running but responsive to signals
if [ $# -eq 0 ]; then
    # No arguments provided, start interactive bash session
    log "Starting interactive development environment..."
    sudo -u matrix0523 bash 
else
    # Arguments provided, execute them
    log "Executing provided command: $*"
    bash "$@"
fi
