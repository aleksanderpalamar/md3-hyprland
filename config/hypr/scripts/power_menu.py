#!/usr/bin/env python3
import subprocess

def rofi(options, prompt):
    proc = subprocess.Popen(
        ["rofi", "-dmenu", "-p", prompt, "-i", "-theme-str", "inputbar { enabled: false; } listview { border: 0px; lines: 5; } window { width: 30%; height: 35%; }"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    stdout, _ = proc.communicate(input="\n".join(options))
    return stdout.strip()

def run_cmd(cmd_list):
    subprocess.run(cmd_list, check=False)

def main():
    options = {
        "⏻ Shutdown": ["systemctl", "poweroff"],
        " Reboot": ["systemctl", "reboot"],
        "⏾ Suspend": ["systemctl", "suspend"],
        "󰗽 Logout": ["hyprctl", "dispatch", "exit"],
        " Lock": ["loginctl", "lock-session"]
    }
    
    menu_items = [
        " Lock",
        "⏾ Suspend",
        "󰗽 Logout",
        " Reboot",
        "⏻ Shutdown"
    ]
    
    choice = rofi(menu_items, "Power Menu")
    
    if choice in options:
        run_cmd(options[choice])

if __name__ == "__main__":
    main()
