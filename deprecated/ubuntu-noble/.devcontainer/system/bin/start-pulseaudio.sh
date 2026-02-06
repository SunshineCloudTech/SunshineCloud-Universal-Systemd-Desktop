#!/bin/bash
# PulseAudio initialization script for XFCE desktop with XRDP support

echo "Initializing PulseAudio for SunshineCloud Desktop..."

# Remove any existing PulseAudio socket that might cause conflicts
rm -f /tmp/pulseaudio.socket

# Check if PulseAudio is already running
if ! pgrep -x "pulseaudio" > /dev/null; then
    echo "Starting PulseAudio..."
    
    # Create user pulse directory if it doesn't exist
    mkdir -p ~/.pulse
    
    # Copy XRDP modules from SunshineCloud directory if they exist
    if [ -d "/SunshineCloud/SunshineCloud-PulseAudio-Modules" ]; then
        PULSE_MODULE_DIR=$(pulseaudio --dump-modules 2>/dev/null | grep -o '/usr/lib/[^/]*/pulse-[0-9.]*/modules' | head -1)
        if [ -n "$PULSE_MODULE_DIR" ] && [ -d "$PULSE_MODULE_DIR" ]; then
            sudo cp /SunshineCloud/SunshineCloud-PulseAudio-Modules/*.so "$PULSE_MODULE_DIR/" 2>/dev/null
            echo "SunshineCloud XRDP PulseAudio modules copied to $PULSE_MODULE_DIR"
        else
            echo "PulseAudio module directory not found, modules will be loaded from absolute path"
        fi
    else
        echo "SunshineCloud PulseAudio modules directory not found at /SunshineCloud/SunshineCloud-PulseAudio-Modules"
    fi
    
    # Clear any user-specific PulseAudio configuration that might conflict
    if [ -f ~/.pulse/client.conf ]; then
        mv ~/.pulse/client.conf ~/.pulse/client.conf.backup
        echo "Backed up user client.conf to avoid conflicts"
    fi
    
    # Start PulseAudio with proper configuration
    # Use --start to allow proper daemon management
    echo "Starting PulseAudio daemon..."
    pulseaudio --start --log-target=syslog --system=false
    
    # Wait for PulseAudio to be ready
    sleep 3
    
    # Verify PulseAudio started successfully
    if pgrep -x "pulseaudio" > /dev/null; then
        echo "PulseAudio started successfully"
        
        # Wait a bit more for modules to load
        sleep 2
        
        # Check if the XRDP socket was created
        if [ -S "/tmp/pulseaudio.socket" ]; then
            echo "XRDP PulseAudio socket created at /tmp/pulseaudio.socket"
        else
            echo "Warning: XRDP socket not found, but PulseAudio is running"
        fi
        
        # Try to set XRDP sinks/sources as default if available
        echo "Configuring audio devices..."
        
        # Find XRDP sink (may have different naming patterns)
        XRDP_SINK=$(pactl list sinks short 2>/dev/null | grep -E "(xrdp|rdp)" | head -1 | cut -f2)
        if [ -n "$XRDP_SINK" ]; then
            pactl set-default-sink "$XRDP_SINK" 2>/dev/null && echo "Set $XRDP_SINK as default sink"
        else
            echo "No XRDP sink found, keeping default sink"
        fi
        
        # Find XRDP source (may have different naming patterns)
        XRDP_SOURCE=$(pactl list sources short 2>/dev/null | grep -E "(xrdp|rdp)" | head -1 | cut -f2)
        if [ -n "$XRDP_SOURCE" ]; then
            pactl set-default-source "$XRDP_SOURCE" 2>/dev/null && echo "Set $XRDP_SOURCE as default source"
        else
            echo "No XRDP source found, keeping default source"
        fi
        
        # Configure XFCE mixer if available
        if command -v xfconf-query > /dev/null 2>&1; then
            DEFAULT_SINK=$(pactl info 2>/dev/null | grep 'Default Sink:' | cut -d' ' -f3)
            if [ -n "$DEFAULT_SINK" ]; then
                xfconf-query -c xfce4-mixer -p /active-card -s "$DEFAULT_SINK" 2>/dev/null || true
                echo "XFCE mixer configured with sink: $DEFAULT_SINK"
            fi
        fi
        
        # List available audio devices for debugging
        echo "Available audio sinks:"
        pactl list sinks short 2>/dev/null || echo "  No sinks available"
        echo "Available audio sources:"
        pactl list sources short 2>/dev/null || echo "  No sources available"
        
    else
        echo "Failed to start PulseAudio"
        echo "Checking PulseAudio logs..."
        journalctl --user -u pulseaudio --no-pager --lines=10 2>/dev/null || echo "Could not retrieve logs"
        return 1
    fi
else
    echo "PulseAudio is already running"
    
    # Check if socket exists and recreate if needed
    if [ ! -S "/tmp/pulseaudio.socket" ]; then
        echo "XRDP socket missing, attempting to load module..."
        pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket auth-anonymous=1 2>/dev/null || true
    fi    
    # Still try to configure defaults if already running
    XRDP_SINK=$(pactl list sinks short 2>/dev/null | grep -E "(xrdp|rdp)" | head -1 | cut -f2)
    if [ -n "$XRDP_SINK" ]; then
        pactl set-default-sink "$XRDP_SINK" 2>/dev/null && echo "Set $XRDP_SINK as default sink"
    fi
    
    XRDP_SOURCE=$(pactl list sources short 2>/dev/null | grep -E "(xrdp|rdp)" | head -1 | cut -f2)
    if [ -n "$XRDP_SOURCE" ]; then
        pactl set-default-source "$XRDP_SOURCE" 2>/dev/null && echo "Set $XRDP_SOURCE as default source"
    fi
fi

echo "PulseAudio initialization completed"
