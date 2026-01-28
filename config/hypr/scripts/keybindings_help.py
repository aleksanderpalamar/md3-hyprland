#!/usr/bin/env python3
import subprocess
import os

def get_keybindings():
    # Attempt to read from the standard config location
    config_path = os.path.expanduser("~/.config/hypr/keybindings.conf")
    bindings = []
    
    # Fallback to local file if not installed yet (for testing in repo)
    if not os.path.exists(config_path):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        # ../../keybindings.conf from scripts/
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
        # Parse lines starting with "bind ="
        if line.startswith("bind ="):
            try:
                # Remove "bind =" and split by comma
                content = line.split('=', 1)[1].strip()
                segments = [s.strip() for s in content.split(',')]
                
                if len(segments) >= 2:
                    mods = segments[0].replace("$mainMod", "SUPER")
                    key = segments[1]
                    action = segments[2] if len(segments) > 2 else ""
                    args = ", ".join(segments[3:]) if len(segments) > 3 else ""
                    
                    # Formatting the output
                    # Make the keybinding prominent
                    shortcut = f"{mods} + {key}"
                    
                    # Clean up description
                    description = f"{action} {args}".strip()
                    if action == "exec":
                        # If it's a script, show the script name or command
                        description = args
                        # Simplify path display if it's a known script
                        if ".config/hypr/scripts/" in description:
                            description = os.path.basename(description)
                    
                    # Align text
                    bindings.append(f"{shortcut:<20} ➜  {description}")
            except:
                continue
                
    return bindings

def rofi(options):
    lines_count = min(len(options), 15)
    
    # Match the style of the project's other menus but slightly larger for text
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
    # We don't really care about the output selection for a help menu
    proc.communicate(input="\n".join(options))

def main():
    bindings = get_keybindings()
    if not bindings:
        bindings = ["No keybindings found or error parsing file."]
    rofi(bindings)

if __name__ == "__main__":
    main()
