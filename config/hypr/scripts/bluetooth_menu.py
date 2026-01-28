#!/usr/bin/env python3
# License: GPLv3
# Author: Aleksander Palamar
import subprocess
import time

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, text=True, shell=False).strip()
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

def notify(title, message):
    subprocess.run(["notify-send", title, message])

def get_power_status():
    output = run_cmd(["bluetoothctl", "show"])
    if output and "Powered: yes" in output:
        return True
    return False

def toggle_power():
    current = get_power_status()
    action = "off" if current else "on"
    run_cmd(["bluetoothctl", "power", action])
    notify("Bluetooth", f"Power turned {action}")

def get_devices():
    devices = []
    
    paired_raw = run_cmd(["bluetoothctl", "paired-devices"])
    all_raw = run_cmd(["bluetoothctl", "devices"])
    
    info_raw = run_cmd(["bluetoothctl", "info"])
    
    # Parse generic device list
    # Format: Device XX:XX:XX:XX:XX:XX Name
    device_map = {}
    
    if all_raw:
        for line in all_raw.split('\n'):
            parts = line.split(' ', 2)
            if len(parts) >= 3:
                mac = parts[1]
                name = parts[2]
                device_map[mac] = {'name': name, 'connected': False, 'paired': False}

    if paired_raw:
        for line in paired_raw.split('\n'):
            parts = line.split(' ', 2)
            if len(parts) >= 2:
                mac = parts[1]
                if mac in device_map:
                    device_map[mac]['paired'] = True

    return device_map

def scan_devices():
    notify("Bluetooth", "Scanning for 5 seconds...")
    try:
        proc = subprocess.Popen(["bluetoothctl", "scan", "on"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(5)
        proc.terminate()
        run_cmd(["bluetoothctl", "scan", "off"])
        notify("Bluetooth", "Scan complete")
    except Exception as e:
        notify("Error", str(e))

def device_menu(mac, name):
    while True:
        info = run_cmd(["bluetoothctl", "info", mac]) or ""
        is_connected = "Connected: yes" in info
        is_paired = "Paired: yes" in info
        is_trusted = "Trusted: yes" in info
        
        status_str = f"Status: {'Connected' if is_connected else 'Disconnected'}, {'Paired' if is_paired else 'Unpaired'}"
        
        opts = []
        if is_connected:
            opts.append("Disconnect")
        else:
            opts.append("Connect")
            
        if is_paired:
            opts.append("Remove (Unpair)")
        else:
            opts.append("Pair")
            
        if is_trusted:
            opts.append("Untrust")
        else:
            opts.append("Trust")
            
        opts.append("Back")
        
        choice = rofi(opts, f"{name} ({status_str})")
        
        if choice == "Back" or not choice:
            break
        elif choice == "Connect":
            run_cmd(["bluetoothctl", "connect", mac])
            notify("Bluetooth", f"Connecting to {name}...")
        elif choice == "Disconnect":
            run_cmd(["bluetoothctl", "disconnect", mac])
            notify("Bluetooth", f"Disconnected {name}")
        elif choice == "Pair":
            notify("Bluetooth", f"Pairing {name}...")
            res = run_cmd(["bluetoothctl", "pair", mac])
            notify("Bluetooth", "Pair command sent")
        elif choice == "Remove (Unpair)":
            run_cmd(["bluetoothctl", "remove", mac])
            notify("Bluetooth", f"Removed {name}")
            break
        elif choice == "Trust":
            run_cmd(["bluetoothctl", "trust", mac])
        elif choice == "Untrust":
            run_cmd(["bluetoothctl", "untrust", mac])

def main():
    while True:
        power = get_power_status()
        power_lbl = "Turn Off" if power else "Turn On"
        power_icon = "" if power else "󰂲"
        
        options = [f"{power_icon} Power {power_lbl}"]
        
        if power:
            options.append("󰂰 Scan for Devices")
            devs = get_devices()
            for mac, info in devs.items():
                icon = ""
                if info['paired']: icon = "🔗"
                options.append(f"{icon} {info['name']} | {mac}")
        
        options.append("Exit")
        
        choice = rofi(options, "Bluetooth")
        
        if not choice or choice == "Exit":
            break
        
        if "Power" in choice:
            toggle_power()
        elif "Scan" in choice:
            scan_devices()
        else:
            selected_mac = None
            for mac in devs.keys():
                if mac in choice:
                    selected_mac = mac
                    break
            
            if selected_mac:
                device_menu(selected_mac, devs[selected_mac]['name'])

if __name__ == "__main__":
    main()
