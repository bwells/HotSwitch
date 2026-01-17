#!/bin/bash
set -e

cd "$(dirname "$0")"

# Kill existing instance
pkill -9 -f "HotSwitch.app" 2>/dev/null || true

# Build
swift build

# Ensure app bundle exists
mkdir -p HotSwitch.app/Contents/MacOS
mkdir -p HotSwitch.app/Contents/Resources

# Copy executable and Info.plist
cp .build/debug/HotSwitch HotSwitch.app/Contents/MacOS/
cp Resources/Info.plist HotSwitch.app/Contents/

# Copy icon if it exists in the bundle (preserve across rebuilds)
if [ -f "HotSwitch.app/Contents/Resources/AppIcon.icns" ]; then
    echo "Icon already present"
fi

# Re-sign to maintain consistent identity
codesign --force --deep --sign - HotSwitch.app

echo "Build complete: HotSwitch.app"
