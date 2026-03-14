# Getting Started with MD3 Hyprland

## Default Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + T` | Open terminal (Kitty) |
| `Super + B` | Open browser (Firefox) |
| `Super + F` | Open file manager (Dolphin) |
| `Super + Space` | App launcher (Rofi) |
| `Super + Q` | Close current window |
| `Super + V` | Toggle floating mode |
| `Super + J` | Toggle split |
| `Super + H` | Show keybindings help |
| `Super + P` | Power menu |
| `Super + 1-5` | Switch to workspace 1-5 |
| `Super + Shift + 1-5` | Move window to workspace 1-5 |
| `Super + Shift + H` | Reload Hyprland config |
| `Super + Shift + S` | Settings menu |
| `Super + Shift + M` | Exit Hyprland |

Press `Super + H` at any time to see all shortcuts in a Rofi menu.

## Changing Wallpaper

Two ways to change wallpaper:

1. **Settings Menu**: Press `Super + Shift + S` and select "Wallpaper Settings"
2. **SelectWallpaper script**: If bound, use the SelectWallpaper keybinding

Place your wallpapers in `~/Pictures/Wallpapers/` (supports `.jpg`, `.png`, `.webp`).

When you change a wallpaper, Matugen automatically generates a Material Design 3 color scheme from it and applies it to all UI components (Hyprland, Waybar, SwayNC, Kitty, Rofi).

## Switching Themes (Dark/Light)

Click the **Theme** button in the SwayNC control center, or bind `toggle_theme.sh` to a key. This toggles between dark and light Material Design 3 color schemes.

## Customization (UserConfigs)

User-specific configuration files are in `~/.config/hypr/UserConfigs/`:

| File | Purpose |
|------|---------|
| `MyPrograms.conf` | Default apps (terminal, browser, file manager, search engine) |
| `UserKeybinds.conf` | Custom keybindings (sources base + your overrides) |
| `UserInput.conf` | Keyboard layout and input settings |
| `UserDecorations.conf` | Gaps, borders, rounding, blur |
| `UserAnimations.conf` | Window animations |
| `WindowRules.conf` | Window rules (opacity, floating, etc.) |
| `ENVariables.conf` | Environment variables (cursor, locale) |
| `Startup_Apps.conf` | Apps launched on login |

These files are **not overwritten** by updates — your customizations persist.

## Changing Language

Set the `MD3_LOCALE` environment variable in `ENVariables.conf`:

```
env = MD3_LOCALE,pt_BR
```

Supported: `en_US` (English), `pt_BR` (Português). Then reload Hyprland (`Super + Shift + H`).

## Updating

From the project directory:

```bash
./scripts/update.sh
```

This pulls the latest changes, regenerates colors, and reloads the UI. Your UserConfigs are never overwritten.

## Uninstalling

```bash
./uninstall.sh
```

This removes symlinks and restores your original configs from backups. Installed packages are listed but not auto-removed.
