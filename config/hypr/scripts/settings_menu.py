#!/usr/bin/env python3
import json
import subprocess
import os
import glob

MONITOR_CONFIG_FILE = os.path.expanduser("~/.config/hypr/monitors.conf")
WALLPAPER_DIR = os.path.expanduser("~/Pictures/Wallpapers")
HYPRPAPER_CONFIG = os.path.expanduser("~/.config/hypr/hyprpaper.conf")

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, text=True, shell=False)
    except subprocess.CalledProcessError:
        return None

def rofi(options, prompt):
    proc = subprocess.Popen(
        ["rofi", "-dmenu", "-p", prompt, "-i", "-theme-str", "inputbar { enabled: false; } listview { border: 0px; lines: 10; } window { width: 50%; height: 35%; }"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    stdout, _ = proc.communicate(input="\n".join(options))
    return stdout.strip()

def get_monitors_data():
    try:
        output = run_cmd(["hyprctl", "-j", "monitors", "all"])
        if output:
            return json.loads(output)
    except Exception as e:
        print(f"Error parsing monitors: {e}")
    return []

def save_monitor_config(monitor_name, mode_str):
    new_conf_line = f"monitor={monitor_name},{mode_str},auto,1"
    
    lines = []
    if os.path.exists(MONITOR_CONFIG_FILE):
        with open(MONITOR_CONFIG_FILE, 'r') as f:
            lines = f.readlines()
    
    new_lines = []
    monitor_updated = False
    
    for line in lines:
        if line.strip().startswith(f"monitor={monitor_name}"):
            new_lines.append(new_conf_line + "\n")
            monitor_updated = True
        else:
            new_lines.append(line)
            
    if not monitor_updated:
        if new_lines and not new_lines[-1].endswith('\n'):
            new_lines[-1] += "\n"
        new_lines.append(new_conf_line + "\n")

    with open(MONITOR_CONFIG_FILE, 'w') as f:
        f.writelines(new_lines)
        
    return new_conf_line

def handle_monitor_settings():
    monitors = get_monitors_data()
    if not monitors:
        subprocess.run(["notify-send", "Error", "No monitors found"])
        return

    monitor_opts = []
    monitor_map = {}
    
    for m in monitors:
        name = m['name']
        w = m.get('width', 0)
        h = m.get('height', 0)
        r = m.get('refreshRate', 0)
        current = f"{w}x{h}@{r:.2f}Hz"
        
        label = f"{name} [{current}]"
        monitor_opts.append(label)
        monitor_map[label] = m

    selected_mon_label = rofi(monitor_opts, "Select Monitor")
    if not selected_mon_label or selected_mon_label not in monitor_map:
        return

    selected_mon = monitor_map[selected_mon_label]
    
    modes = selected_mon.get('availableModes', [])
    if not modes:
        subprocess.run(["notify-send", "Warning", "No modes reported by Hyprland"])
        return

    selected_mode = rofi(modes, "Select Mode")
    if not selected_mode:
        return

    try:
        new_config = save_monitor_config(selected_mon['name'], selected_mode)
        args = new_config.replace("monitor=", "").strip()
        subprocess.run(["hyprctl", "keyword", "monitor", args])
        subprocess.run(["notify-send", "Monitor Updated", f"{selected_mon['name']} -> {selected_mode}"])
    except Exception as e:
        subprocess.run(["notify-send", "Error", f"Failed to save: {e}"])

def get_wallpapers():
    extensions = ["*.jpg", "*.jpeg", "*.png", "*.webp"]
    files = []
    for ext in extensions:
        files.extend(glob.glob(os.path.join(WALLPAPER_DIR, ext)))
    return sorted(files)

def update_hyprpaper(wallpaper_path):
    content = f"""preload = {wallpaper_path}
wallpaper = ,{wallpaper_path}
"""
    try:
        with open(HYPRPAPER_CONFIG, "w") as f:
            f.write(content)
            
        subprocess.run(["hyprctl", "hyprpaper", "preload", wallpaper_path], check=False)
        
        monitors = get_monitors_data()
        if monitors:
            for m in monitors:
                mon_name = m['name']
                subprocess.run(["hyprctl", "hyprpaper", "wallpaper", f"{mon_name},{wallpaper_path}"], check=False)
        else:
            subprocess.run(["hyprctl", "hyprpaper", "wallpaper", f",{wallpaper_path}"], check=False)

        subprocess.run(["hyprctl", "hyprpaper", "unload", "all"], check=False)
        
        # Update Colors (Wallust)
        subprocess.run(["wallust", "run", wallpaper_path], check=False)
        subprocess.run(["pkill", "-SIGUSR2", "waybar"], check=False)
        subprocess.run(["swaync-client", "-rs"], check=False)
        subprocess.run(["hyprctl", "reload"], check=False)
        
        subprocess.run(["notify-send", "Wallpaper Updated", os.path.basename(wallpaper_path)], check=False)
        
    except Exception as e:
        subprocess.run(["notify-send", "Error", f"Failed to set wallpaper: {e}"], check=False)
def handle_wallpaper_settings():
    walls = get_wallpapers()
    if not walls:
        subprocess.run(["notify-send", "Error", f"No wallpapers found in {WALLPAPER_DIR}"])
        return

    wall_map = {os.path.basename(p): p for p in walls}
    options = list(wall_map.keys())
    
    selected_name = rofi(options, "Select Wallpaper")
    if not selected_name or selected_name not in wall_map:
        return
        
    selected_path = wall_map[selected_name]
    update_hyprpaper(selected_path)

def main():
    main_options = ["Monitor Settings", "Wallpaper Settings", "Exit"]
    choice = rofi(main_options, "Settings")
    
    if choice == "Monitor Settings":
        handle_monitor_settings()
    elif choice == "Wallpaper Settings":
        handle_wallpaper_settings()

if __name__ == "__main__":
    main()