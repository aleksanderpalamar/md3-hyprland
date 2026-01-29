#!/usr/bin/env python3
# License: GPLv3
# Author: Aleksander Palamar
# Description: A simple GTK3 file manager styled with Wallust CSS to match Hyprland/MD3 theme.

import os
import sys
import subprocess
import gi

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Gio, Pango, GLib, GdkPixbuf

CSS_FILE = os.path.expanduser("~/.config/hypr/scripts/style.css")
HOME_DIR = os.path.expanduser("~")

class FileManagerWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="File Manager")
        self.set_default_size(1000, 650)
        self.set_border_width(0)
        
        self.load_css()
        
        header = Gtk.HeaderBar()
        header.set_show_close_button(True)
        header.set_title("File Manager")
        self.set_titlebar(header)
        
        self.btn_up = Gtk.Button()
        icon_up = Gtk.Image.new_from_icon_name("go-up-symbolic", Gtk.IconSize.BUTTON)
        self.btn_up.add(icon_up)
        self.btn_up.connect("clicked", self.on_up_clicked)
        header.pack_start(self.btn_up)
        
        self.btn_home = Gtk.Button()
        icon_home = Gtk.Image.new_from_icon_name("user-home-symbolic", Gtk.IconSize.BUTTON)
        self.btn_home.add(icon_home)
        self.btn_home.connect("clicked", self.on_home_clicked)
        header.pack_start(self.btn_home)

        self.path_entry = Gtk.Entry()
        self.path_entry.set_width_chars(50)
        self.path_entry.connect("activate", self.on_path_entered)
        header.set_custom_title(self.path_entry)

        self.paned = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
        self.add(self.paned)

        self.sidebar_scrolled = Gtk.ScrolledWindow()
        self.sidebar_scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.sidebar_scrolled.set_min_content_width(200)
        self.sidebar_scrolled.get_style_context().add_class("sidebar")
        
        self.sidebar_list = Gtk.ListBox()
        self.sidebar_list.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.sidebar_list.connect("row-activated", self.on_sidebar_row_activated)
        self.sidebar_scrolled.add(self.sidebar_list)
        
        self.paned.pack1(self.sidebar_scrolled, False, False)

        # Main Content (Right)
        self.content_scrolled = Gtk.ScrolledWindow()
        self.content_scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        self.paned.pack2(self.content_scrolled, True, False)
        
        # Icon View (Grid)
        self.liststore = Gtk.ListStore(str, GdkPixbuf.Pixbuf, str, bool) # Filename, Icon, FullPath, IsDir
        self.iconview = Gtk.IconView.new_with_model(self.liststore)
        self.iconview.set_text_column(0)
        self.iconview.set_pixbuf_column(1)
        self.iconview.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.iconview.connect("item-activated", self.on_item_activated)
        
        self.content_scrolled.add(self.iconview)
        
        self.monitor = Gio.VolumeMonitor.get()
        self.monitor.connect("mount-added", self.on_mount_changed)
        self.monitor.connect("mount-removed", self.on_mount_changed)

        self.populate_sidebar()
        self.current_path = HOME_DIR
        self.refresh_directory()

        
    def load_css(self):
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(CSS_FILE)
            screen = Gdk.Screen.get_default()
            style_context = Gtk.StyleContext()
            style_context.add_provider_for_screen(
                screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
        except Exception as e:
            print(f"Failed to load CSS: {e}")

    def populate_sidebar(self):
        for child in self.sidebar_list.get_children():
            self.sidebar_list.remove(child)

        def add_item(label, icon_name, target_path):
            row = Gtk.ListBoxRow()
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            img = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.MENU)
            lbl = Gtk.Label(label=label, xalign=0)
            box.pack_start(img, False, False, 0)
            box.pack_start(lbl, True, True, 0)
            row.add(box)
            row.target_path = target_path # Store path in the row object
            self.sidebar_list.add(row)

        add_item("Home", "user-home-symbolic", HOME_DIR)

        xdg_dirs = [
            (GLib.UserDirectory.DIRECTORY_DOCUMENTS, "Documents", "folder-documents-symbolic"),
            (GLib.UserDirectory.DIRECTORY_MUSIC, "Music", "folder-music-symbolic"),
            (GLib.UserDirectory.DIRECTORY_PICTURES, "Pictures", "folder-pictures-symbolic"),
            (GLib.UserDirectory.DIRECTORY_VIDEOS, "Videos", "folder-videos-symbolic"),
            (GLib.UserDirectory.DIRECTORY_DOWNLOAD, "Downloads", "folder-download-symbolic"),
        ]
        
        for xdg_enum, name, icon in xdg_dirs:
            path = GLib.get_user_special_dir(xdg_enum)
            if path:
                add_item(name, icon, path)

        trash_path = os.path.join(HOME_DIR, ".local/share/Trash/files")
        add_item("Trash", "user-trash-symbolic", trash_path)
        
        # Devices / Mounts
        mounts = self.monitor.get_mounts()
        for mount in mounts:
            root = mount.get_root()
            path = root.get_path()
            if path:
                add_item(mount.get_name(), "drive-removable-media-symbolic", path)

        self.sidebar_list.show_all()

    def on_mount_changed(self, monitor, mount):
        self.populate_sidebar()

    def on_sidebar_row_activated(self, listbox, row):
        if row and hasattr(row, 'target_path'):
            self.current_path = row.target_path
            self.refresh_directory()

    def get_icon(self, file_info, is_dir):
        icon_theme = Gtk.IconTheme.get_default()

        if is_dir:
            return icon_theme.load_icon("folder", 64, 0)
            
        icon = file_info.get_icon()
        if icon:
            try:
                info = icon_theme.lookup_by_gicon(icon, 64, Gtk.IconLookupFlags.FORCE_SIZE)
                if info:
                    return info.load_icon()
            except:
                pass
        return icon_theme.load_icon("text-x-generic", 64, 0)

    def refresh_directory(self):
        self.liststore.clear()
        self.path_entry.set_text(self.current_path)
        
        f = Gio.File.new_for_path(self.current_path)
        
        try:
            enumerator = f.enumerate_children(
                "standard::*,standard::icon", 
                Gio.FileQueryInfoFlags.NONE, 
                None
            )
        except Exception as e:
            self.show_error(f"Cannot access location: {e}")
            return

        dirs = []
        files = []

        for info in enumerator:
            name = info.get_name()
            if name.startswith("."): continue
            
            is_dir = info.get_file_type() == Gio.FileType.DIRECTORY
            full_path = os.path.join(self.current_path, name)
            
            if is_dir:
                dirs.append((name, full_path, info))
            else:
                files.append((name, full_path, info))

        def safe_get_icon(info, is_d):
            try:
                return self.get_icon(info, is_d)
            except:
                return None

        dirs.sort(key=lambda x: x[0].lower())
        files.sort(key=lambda x: x[0].lower())

        for name, path, info in dirs:
            self.liststore.append([name, safe_get_icon(info, True), path, True])
            
        for name, path, info in files:
            self.liststore.append([name, safe_get_icon(info, False), path, False])

    def on_item_activated(self, iconview, path):
        model = iconview.get_model()
        iter_ = model.get_iter(path)
        full_path = model.get_value(iter_, 2)
        is_dir = model.get_value(iter_, 3)
        
        if is_dir:
            self.current_path = full_path
            self.refresh_directory()
        else:
            subprocess.Popen(["xdg-open", full_path])

    def on_up_clicked(self, widget):
        parent = os.path.dirname(self.current_path)
        if parent and parent != self.current_path:
            self.current_path = parent
            self.refresh_directory()
            
    def on_home_clicked(self, widget):
        self.current_path = HOME_DIR
        self.refresh_directory()
            
    def on_path_entered(self, entry):
        path = entry.get_text()
        if os.path.isdir(path):
            self.current_path = path
            self.refresh_directory()
        else:
            self.show_error("Invalid Directory")
            
    def show_error(self, message):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=message,
        )
        dialog.run()
        dialog.destroy()

if __name__ == "__main__":
    win = FileManagerWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()