#!/bin/bash

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling function
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Print usage instructions
print_usage() {
    echo "Usage: $0 [--local|--docker] [--version VERSION]"
    echo "Options:"
    echo "  --local       Build Docker images locally (no upload)."
    echo "  --docker      Build Docker images and upload to Docker Hub."
    echo "  --version     Set the version tag for the Docker images (default: latest)."
    exit 1
}

# Update docker-compose.yml with the correct image names and tags
update_docker_compose() {
    local backend_image=$1
    local frontend_image=$2
    local version=$3

    log "Updating docker-compose.yml with image names and tags..."

    # Create a backup of the original docker-compose.yml
    cp docker-compose.yml docker-compose.yml.bak

    # Check if the system is macOS or Linux
    if [[ "$(uname)" == "Darwin" ]]; then
      # macOS (BSD sed)
      sed -i '' "s|image: ${backend_image}:.*|image: ${backend_image}:${version}|" docker-compose.yml
      sed -i '' "s|image: ${frontend_image}:.*|image: ${frontend_image}:${version}|" docker-compose.yml
    else
      # Linux (GNU sed)
      sed -i "s|image: ${backend_image}:.*|image: ${backend_image}:${version}|" docker-compose.yml
      sed -i "s|image: ${frontend_image}:.*|image: ${frontend_image}:${version}|" docker-compose.yml
    fi

    log "docker-compose.yml updated successfully!"
}

# Parse command-line arguments
BUILD_MODE=""
VERSION="latest"
DOCKER_REGISTRY=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)
            BUILD_MODE="local"
            shift
            ;;
        --docker)
            BUILD_MODE="docker"
            shift
            ;;
        --version)
            if [[ -n "$2" ]]; then
                VERSION="$2"
                shift 2
            else
                handle_error "Please provide a version after --version."
            fi
            ;;
        *)
            print_usage
            ;;
    esac
done

# Validate build mode
if [[ -z "$BUILD_MODE" ]]; then
    print_usage
fi

# Prompt for Docker registry if uploading to Docker Hub
if [[ "$BUILD_MODE" == "docker" ]]; then
    read -p "Enter your Docker Hub username (DOCKER_REGISTRY): " DOCKER_REGISTRY
    if [[ -z "$DOCKER_REGISTRY" ]]; then
        handle_error "DOCKER_REGISTRY cannot be empty."
    fi
fi

# Docker image names
BACKEND_IMAGE="backend-app"
FRONTEND_IMAGE="frontend-app"

# If building for Docker Hub, prepend the registry name
if [[ "$BUILD_MODE" == "docker" ]]; then
    BACKEND_IMAGE="$DOCKER_REGISTRY/$BACKEND_IMAGE"
    FRONTEND_IMAGE="$DOCKER_REGISTRY/$FRONTEND_IMAGE"
fi

# Build and tag the backend Docker image
log "Building and tagging the backend Docker image..."
docker build -t $BACKEND_IMAGE:$VERSION ./backend-app || handle_error "Failed to build the backend Docker image."

# Build and tag the frontend Docker image
log "Building and tagging the frontend Docker image..."
docker build -t $FRONTEND_IMAGE:$VERSION ./frontend-app || handle_error "Failed to build the frontend Docker image."

# If building for Docker Hub, push the images
if [[ "$BUILD_MODE" == "docker" ]]; then
    log "Pushing the backend Docker image to Docker Hub..."
    docker push $BACKEND_IMAGE:$VERSION || handle_error "Failed to push the backend Docker image."

    log "Pushing the frontend Docker image to Docker Hub..."
    docker push $FRONTEND_IMAGE:$VERSION || handle_error "Failed to push the frontend Docker image."
fi

# Update docker-compose.yml with the correct image names and tags
update_docker_compose "$BACKEND_IMAGE" "$FRONTEND_IMAGE" "$VERSION"

# Print instructions to run the application
log "Build process completed successfully!"
echo ""
echo "To run the application, use the following command:"
echo "  docker-compose up"
echo ""
echo "Access the application at:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:3003/api/hello"
