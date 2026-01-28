#!/usr/bin/env python3
import subprocess
import os

def get_keybindings():
    config_path = os.path.expanduser("~/.config/hypr/keybindings.conf")
    bindings = []
    if not os.path.exists(config_path):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        local_path = os.path.abspath(os.path.join(current_dir, "../keybindings.conf"))
        if os.path.exists(local_path):
            config_path = local_path
        else:
            return ["Error: keybindings.conf not found"]

    try:
        with open(config_path, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        return [f"Error reading config: {e}"]

    for line in lines:
        line = line.strip()
        if line.startswith("bind ="):
            try:
                content = line.split('=', 1)[1].strip()
                segments = [s.strip() for s in content.split(',')]
                
                if len(segments) >= 2:
                    mods = segments[0].replace("$mainMod", "SUPER")
                    key = segments[1]
                    action = segments[2] if len(segments) > 2 else ""
                    args = ", ".join(segments[3:]) if len(segments) > 3 else ""
                    shortcut = f"{mods} + {key}"
                    description = f"{action} {args}".strip()
                    if action == "exec":
                        description = args
                        if ".config/hypr/scripts/" in description:
                            description = os.path.basename(description)
                    
                    bindings.append(f"{shortcut:<20} ➜  {description}")
            except:
                continue
                
    return bindings

def rofi(options):
    lines_count = min(len(options), 15)
    rofi_cmd = [
        "rofi", 
        "-dmenu", 
        "-p", "Keybindings", 
        "-i", 
        "-theme-str", 
        f"listview {{ lines: {lines_count}; }} window {{ width: 50%; }}"
    ]
    
    proc = subprocess.Popen(
        rofi_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    proc.communicate(input="\n".join(options))

def main():
    bindings = get_keybindings()
    if not bindings:
        bindings = ["No keybindings found or error parsing file."]
    rofi(bindings)

if __name__ == "__main__":
    main()
