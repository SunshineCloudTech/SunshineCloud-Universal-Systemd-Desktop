#!/bin/bash
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Ensure /tmp directory has proper permissions
chmod 1777 /tmp 2>/dev/null || true

echo "=== Downloading PulseAudio XRDP Modules ==="
echo "Step 1: Fetching latest release information from GitHub API..."
RELEASE_INFO=$(curl -sL https://api.github.com/repos/SunshineCloudTech/SunshineCloud-Universal-Utils/releases/latest)

if echo "$RELEASE_INFO" | jq -e '.assets' > /dev/null 2>&1; then
    echo "✅ API response valid, parsing assets..."
    ASSET_COUNT=$(echo "$RELEASE_INFO" | jq '.assets | length')
    echo "Found $ASSET_COUNT asset(s) in latest release"
    
    LATEST_RELEASE_URL=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test("^pulseaudio-xrdp-utils-.*\\.tar\\.gz$")) | .browser_download_url' | head -1)
    
    if [ -n "$LATEST_RELEASE_URL" ] && [ "$LATEST_RELEASE_URL" != "null" ]; then
        echo "Step 2: Found matching asset"
        ASSET_NAME=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test("^pulseaudio-xrdp-utils-.*\\.tar\\.gz$")) | .name' | head -1)
        ASSET_SIZE=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test("^pulseaudio-xrdp-utils-.*\\.tar\\.gz$")) | .size' | head -1)
        echo "  File: $ASSET_NAME"
        echo "  Size: $ASSET_SIZE bytes"
        echo "  URL: $LATEST_RELEASE_URL"
        echo "Step 3: Downloading..."
        # Ensure /tmp directory has proper permissions
        chmod 1777 /tmp 2>/dev/null || true
        # Remove any existing file first
        rm -f /tmp/pulseaudio-xrdp-utils.tar.gz
        curl -fSL --retry 3 --retry-delay 2 "$LATEST_RELEASE_URL" -o /tmp/pulseaudio-xrdp-utils.tar.gz
        echo "✅ Download successful"
    else
        echo "❌ No matching asset found with pattern: pulseaudio-xrdp-utils-*.tar.gz"
        echo "Available assets:"
        echo "$RELEASE_INFO" | jq -r '.assets[].name'
        exit 1
    fi
else
    echo "❌ Invalid API response or no releases found"
    exit 1
fi

echo "Step 4: Validating downloaded file..."
FILE_SIZE=$(stat -c%s /tmp/pulseaudio-xrdp-utils.tar.gz 2>/dev/null || echo "0")
echo "Downloaded file size: $FILE_SIZE bytes"

if [ "$FILE_SIZE" -gt "10000" ]; then
    if tar -tzf /tmp/pulseaudio-xrdp-utils.tar.gz > /dev/null 2>&1; then
        echo "✅ Valid tar.gz file"
        echo "Step 5: Extracting archive..."
        mkdir -p /SunshineCloud/SunshineCloud-PulseAudio-Modules
        cd /tmp && tar -xzf pulseaudio-xrdp-utils.tar.gz
        
        echo "Step 6: Searching for module files..."
        find /tmp -type f -name "*.so" -ls
        
        echo "Step 7: Copying modules to destination..."
        MODULE_COUNT=0
        if find /tmp -type f -name "module-xrdp-source.so" -exec cp -v {} /SunshineCloud/SunshineCloud-PulseAudio-Modules/ \; | grep -q "module-xrdp-source.so"; then
            MODULE_COUNT=$((MODULE_COUNT + 1))
        fi
        if find /tmp -type f -name "module-xrdp-sink.so" -exec cp -v {} /SunshineCloud/SunshineCloud-PulseAudio-Modules/ \; | grep -q "module-xrdp-sink.so"; then
            MODULE_COUNT=$((MODULE_COUNT + 1))
        fi
        
        if [ "$MODULE_COUNT" -gt "0" ]; then
            echo "✅ Successfully copied $MODULE_COUNT module(s)"
            ls -lh /SunshineCloud/SunshineCloud-PulseAudio-Modules/
        else
            echo "⚠️  Warning: No PulseAudio modules found in archive"
        fi
    else
        echo "❌ Invalid tar.gz file"
        file /tmp/pulseaudio-xrdp-utils.tar.gz
        exit 1
    fi
else
    echo "❌ Downloaded file too small ($FILE_SIZE bytes)"
    exit 1
fi

echo "Step 8: Cleaning up..."
rm -rf /tmp/pulseaudio-xrdp-utils.tar.gz /tmp/pulseaudio-modules/ /tmp/SunshineCloud-Universal-Utils-main/ /tmp/pulseaudio-xrdp-utils-*/
apt-get clean
rm -rf /var/lib/apt/lists/*
echo "=== PulseAudio XRDP Module Installation Complete ==="
