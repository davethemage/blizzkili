# Blizzkili - WoW Rotation Helper Addon

A rotation helper addon for World of Warcraft 12.0.0 (Midnight Patch) based on Hekili and Single Button Assistant concepts.

## Features

- **Rotation Helper**: Shows recommended abilities based on the Single button Assistant
- **Single Button Assistant Integration**: Uses Single Button Assistant as rotation reference
- **Fully Customizable**: All aspects of the UI can be configured
- **Multiple Fonts**: Separate font configuration for keybinds
- **Button Management**: Customize the number of buttons, size, spacing, and layout
- **Display Options**: Toggle keybinds, main button glow, and positioning
- **Easy Configuration**: Use `/blizzkili` command to open the configuration panel
- **Position Management**: Unlock frames to reposition, then lock to protect settings

## Installation

1. Place the Blizzkili folder in your WoW AddOns directory:
   ```
   World of Warcraft\\_retail_\\Interface\\AddOns\\Blizzkili
   ```

2. Restart World of Warcraft or reload the UI

## Dependencies(embedded)

- **Ace3** - Addon framework and configuration
- **LibSharedMedia-3.0** - Font management library

## Commands

- `/blizzkili` or `/BK` - Open the configuration panel
- `/blizzkili lock` - Lock frames (prevent moving)
- `/blizzkili unlock` - Unlock frames (allow moving)

## Configuration Options

### General Settings
- **Growth Direction** - Direction to grow the list
- **Zoom Textures** - Removes the border from the button textures(square)
- **Show Out of Combat** - Hide/Show when out of combat
- **Glow Type** - Pick a glow type for the main button
- **Custom Glow Color** - Pick a custom glow color
- **Position X** - Overall X Position
- **Position Y** - Overall Y Position
- **Anchor** - Anchor point of the Main Blizzkili frame
- **Parent Anchor** - Anchor Point to the screen
- **Lock Frames** - Prevent frames from being moved
- **Show Move Frame** - Hide/Show the box to move the frame around

### Button Settings
- **Number of Buttons** - How many ability buttons to display (1-10)
- **Main Button Scale** - Scale the main button by a percentage
- **Button Size** - Base button size in pixels (1-150)
- **Button Spacing** - Space between buttons (0-20)
- **Show Swipe** - Show GCD/Swipe

### Keybind Settings
- **Enable Keybinds** Show/Hide Keybinds
- **Font** - For keybind text
- **Font Size** - Size of the Keybind Font (1-100)
- **Font Outline** - Outline of the Keybind
- **Font Color** - Color for the Keybind
- **Anchor** - Anchor point of the keybind text
- **Parent Anchor** - Anchor point of the button
- **X offset** - X offset for the Keybind
- **Y offset** - Y offset for the Keybind

### Keybind Overrides
- Ability to override spell keybinds

### Blacklist
- Ability to blacklist spells from the list

### Miscellaneous Settings
- **Debug Mode** - Debug printout verbosity(not in use)

## Known Limitations

- Rotation logic is simplified - only uses Blizzards Single Button Assistant API
- Keybind detection is basic and only works with default bars
- Secure Action buttons mean that they cannot be moved or hidden/shown while in combat

## Version

- Current: 1.0.8
- WoW Patch: 12.0.5 (Midnight)

## TODO/Future Plans

- Cooldown text fixes
- Cooldown Management(needs custom cooldown tracking)
