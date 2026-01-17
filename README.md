# HotSwitch

A macOS menu bar app that provides an alternative application switcher (Option+Tab) where user-configured "hot" apps always appear first, followed by other running apps in recency order.

## Features

- **Hot Apps**: Pin your favorite apps to always appear first in the switcher
- **Recency Sorting**: Non-hot apps are sorted by most recently used
- **Global Hotkey**: Option+Tab to activate (doesn't conflict with Cmd+Tab)
- **Menu Bar Interface**: Configure hot apps from the menu bar

## Requirements

- macOS 13.0 (Ventura) or later
- Accessibility permission (required for global hotkey capture)

## Building

```bash
cd HotSwitch
swift build
```

## Running

```bash
.build/debug/HotSwitch
```

Or build and run in one command:

```bash
swift build && .build/debug/HotSwitch
```

## Usage

1. **Grant Accessibility Permission**: On first launch, the app will prompt you to grant Accessibility permission in System Settings > Privacy & Security > Accessibility
2. **Configure Hot Apps**: Click the menu bar icon to see running apps. Click the flame icon next to any app to mark it as "hot"
3. **Switch Apps**: Press Option+Tab to show the switcher
   - Tab: Move to next app
   - Shift+Tab: Move to previous app
   - Release Option: Switch to selected app
   - Escape: Cancel

## How It Works

Hot apps always appear first in the switcher (in the order you configured them). Other running apps appear after, sorted by how recently they were used.

The app runs without a Dock icon (menu bar only) and uses a global event tap to capture the Option+Tab hotkey.

## Project Structure

```
HotSwitch/
├── Package.swift
├── Sources/
│   └── HotSwitch/
│       ├── HotSwitchApp.swift      # Main app entry point
│       ├── AppDelegate.swift        # App lifecycle management
│       ├── Managers/
│       │   ├── HotkeyManager.swift  # Global hotkey capture
│       │   └── AppManager.swift     # Running app tracking
│       ├── Views/
│       │   ├── SwitcherView.swift   # Switcher UI
│       │   ├── SwitcherWindow.swift # Floating panel
│       │   └── MenuBarView.swift    # Menu bar interface
│       └── Models/
│           └── HotAppsStore.swift   # Hot app persistence
└── Resources/
    └── Info.plist
```
