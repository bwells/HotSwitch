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
./build.sh
```

This builds the app, creates the `HotSwitch.app` bundle, and code signs it.

## Running

```bash
open HotSwitch.app
```

Or build and run in one command:

```bash
./build.sh && open HotSwitch.app
```

## Usage

### Initial Setup

1. **Launch the app** - A menu bar icon (stacked cards) will appear
2. **Grant Accessibility Permission** - The app will prompt you to grant permission in System Settings > Privacy & Security > Accessibility. This is required for global hotkey capture.
3. **Restart the app** after granting permission

### Configuring Hot Apps

Click the menu bar icon to open the configuration panel:
- Running apps are listed with a flame icon
- Click the flame to toggle an app as "hot"
- Hot apps appear in a separate section at the top
- Hot apps will always appear first in the switcher, in the order listed

### Switching Apps

| Key | Action |
|-----|--------|
| **Option+Tab** | Open the switcher (first hot app selected) |
| **Tab** | Move to next app |
| **Shift+Tab** | Move to previous app |
| **Right Arrow** | Move to next app |
| **Left Arrow** | Move to previous app |
| **Release Option** | Switch to selected app |
| **Escape** | Cancel and close switcher |

## How It Works

Hot apps always appear first in the switcher (in the order you configured them). Other running apps appear after, sorted by how recently they were used.

The app runs without a Dock icon (menu bar only) and uses a global event tap to capture the Option+Tab hotkey.

## Project Structure

```
HotSwitch/
├── Package.swift
├── build.sh                         # Build and sign script
├── LICENSE                          # GPL 3.0
├── Sources/
│   └── HotSwitch/
│       ├── HotSwitchApp.swift       # Main app entry point
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
    ├── Info.plist
    └── AppIcon.icns
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
