#!/bin/bash
# Build script for .devcontainer Dockerfiles
# Builds each devcontainer image and stops on first failure

set -e  # Exit on any error

echo "=========================================="
echo "Building DevContainer Images"
echo "=========================================="
echo ""

# Array to track build results
declare -a BUILT_IMAGES=()
declare -a FAILED_IMAGES=()

# Find all .devcontainer directories
for DIST in debian-* ubuntu-*; do
    [ -d "$DIST" ] || continue
    
    DEVCONTAINER_DIR="$DIST/.devcontainer"
    DOCKERFILE="$DEVCONTAINER_DIR/Dockerfile"
    
    if [ ! -f "$DOCKERFILE" ]; then
        echo "⚠️  Skipping $DIST: No .devcontainer/Dockerfile found"
        echo ""
        continue
    fi
    
    CODENAME=${DIST##*-}
    IMAGE_NAME="sunshinecloud-devcontainer-${CODENAME}"
    
    echo "=========================================="
    echo "🔨 Building: $IMAGE_NAME"
    echo "📁 Directory: $DIST"
    echo "📄 Dockerfile: $DOCKERFILE"
    echo "=========================================="
    
    # Build the image
    if docker build --no-cache -t "$IMAGE_NAME" -f "$DOCKERFILE" .; then
        echo "✅ SUCCESS: $IMAGE_NAME built successfully"
        BUILT_IMAGES+=("$IMAGE_NAME")
        echo ""
    else
        echo "❌ FAILED: $IMAGE_NAME build failed"
        FAILED_IMAGES+=("$IMAGE_NAME")
        echo ""
        echo "=========================================="
        echo "Build stopped due to failure"
        echo "=========================================="
        exit 1
    fi
done

echo "=========================================="
echo "Build Summary"
echo "=========================================="
echo "✅ Successfully built ${#BUILT_IMAGES[@]} image(s):"
for img in "${BUILT_IMAGES[@]}"; do
    echo "   - $img"
done

if [ ${#FAILED_IMAGES[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed to build ${#FAILED_IMAGES[@]} image(s):"
    for img in "${FAILED_IMAGES[@]}"; do
        echo "   - $img"
    done
    exit 1
fi

echo ""
echo "🎉 All devcontainer images built successfully!"
