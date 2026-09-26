#!/usr/bin/env python3
"""
Interactive Categorized Hotkey Cheatsheet for Workstation (Niri & GNOME)
Built with GTK4 & Libadwaita. Supports live search, categorized cards,
keyboard navigation, and instant toggle with Escape / Super+/.
"""

import sys
import os
import signal
import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GLib, Gdk, Gio

CATEGORIES = [
    {
        "name": "🚀 Applications & Launchers",
        "description": "Quick system entry points",
        "items": [
            ("App Launcher (DMS)", ["Super", "Space"]),
            ("Terminal (Ghostty)", ["Super", "Return"]),
            ("Web Browser (Chrome)", ["Super", "B"]),
            ("File Manager (Nautilus)", ["Super", "E"]),
            ("Clipboard History", ["Super", "V"]),
            ("Control Center", ["Super", "N"]),
            ("Tailscale VPN Menu", ["Super", "Shift", "T"]),
        ]
    },
    {
        "name": "🪟 Window Focus & 2D Grid",
        "description": "Spatial navigation across columns and rows",
        "items": [
            ("Focus Column Left / Right", ["Super", "Left / Right"]),
            ("Focus Window Up / Down (in column)", ["Super", "Up / Down"]),
            ("Move Column Left / Right", ["Super", "Ctrl", "Left / Right"]),
            ("Move Window Up / Down (in column)", ["Super", "Ctrl", "Up / Down"]),
            ("Focus First / Last Column", ["Super", "Home / End"]),
            ("Switch Windows (Universal Alt-Tab)", ["Alt", "Tab"]),
            ("Switch Windows of Same App", ["Super", "`"]),
        ]
    },
    {
        "name": "📐 Window Sizing & Layout Modes",
        "description": "Tiling ribbon, tabs, and dimensions",
        "items": [
            ("Close Active Window", ["Super", "Q", "or", "Alt", "F4"]),
            ("Maximize Column", ["Super", "F"]),
            ("Fullscreen Window", ["Super", "Shift", "F"]),
            ("Maximize to Edges", ["Super", "M"]),
            ("Center Focused Column", ["Super", "C"]),
            ("Cycle Preset Width", ["Super", "R"]),
            ("Adjust Width (±10%)", ["Super", "- / ="]),
            ("Toggle Window Floating", ["Super", "Shift", "V"]),
            ("Toggle Column Tabbed Mode", ["Super", "W"]),
            ("Consume / Expel Window", ["Super", "[ / ]"]),
        ]
    },
    {
        "name": "🧭 Workspaces & Monitors",
        "description": "Multi-desktop and display routing",
        "items": [
            ("Workspace Overview", ["Super", "O"]),
            ("Jump to Workspace (1-9)", ["Super", "1 .. 9"]),
            ("Move Column to Workspace (1-9)", ["Super", "Ctrl", "1 .. 9"]),
            ("Next / Prev Workspace", ["Super", "Page Down / Up"]),
            ("Focus Monitor Left / Right", ["Super", "Shift", "Left / Right"]),
            ("Move Column to Monitor", ["Super", "Shift", "Ctrl", "Left / Right"]),
        ]
    },
    {
        "name": "📸 Screenshots & Media",
        "description": "Universal 3/4/5 capture mapping",
        "items": [
            ("Screenshot: Entire Screen", ["Super", "Shift", "3"]),
            ("Screenshot: Selection Area", ["Super", "Shift", "4"]),
            ("Screenshot: Active Window", ["Super", "Shift", "5"]),
            ("Audio Volume (±10%)", ["Volume Up / Down"]),
            ("Mute Output / Mic", ["Mute / Mic Mute"]),
            ("Media Play / Pause / Skip", ["Media Play / Prev / Next"]),
        ]
    },
    {
        "name": "🔒 System & Session",
        "description": "Lock, power, and compositor controls",
        "items": [
            ("Lock Screen (DMS)", ["Super", "Alt", "L"]),
            ("Power & Session Menu (DMS)", ["Super", "Shift", "Q"]),
            ("Power Off Monitors", ["Super", "Shift", "P"]),
            ("Quit Niri Compositor", ["Super", "Shift", "E"]),
            ("Toggle Shortcuts Inhibit", ["Super", "Escape"]),
            ("Toggle This Cheatsheet", ["Super", "/"]),
        ]
    },
]

CSS = """
window {
    background-color: @window_bg_color;
}

.search-bar {
    padding: 12px 16px;
}

.category-title {
    font-weight: 800;
    font-size: 1.05rem;
    margin-bottom: 4px;
}

.category-desc {
    font-size: 0.8rem;
    opacity: 0.65;
    margin-bottom: 8px;
}

.hotkey-row {
    padding: 6px 12px;
    border-radius: 8px;
    transition: background-color 150ms ease;
}

.hotkey-row:hover {
    background-color: alpha(currentColor, 0.05);
}

.hotkey-desc {
    font-size: 0.9rem;
    font-weight: 500;
}

.kbd-badge {
    background-color: alpha(currentColor, 0.08);
    border: 1px solid alpha(currentColor, 0.18);
    border-radius: 6px;
    padding: 2px 7px;
    font-family: monospace;
    font-size: 0.8rem;
    font-weight: 700;
    box-shadow: 0 1px 2px alpha(black, 0.2);
}

.kbd-separator {
    opacity: 0.5;
    font-size: 0.8rem;
    margin: 0 2px;
}
"""

class CheatsheetWindow(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Workstation Hotkeys Cheatsheet")
        self.set_default_size(980, 680)

        # Style manager dark theme
        Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.PREFER_DARK)

        # CSS Provider
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(CSS.encode('utf-8'))
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Key controller for Escape / q
        key_ctrl = Gtk.EventControllerKey.new()
        key_ctrl.connect("key-pressed", self.on_key_pressed)
        self.add_controller(key_ctrl)

        # Main Layout Box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(main_box)

        # Header Bar
        header = Adw.HeaderBar()
        header.set_show_end_title_buttons(True)
        title_widget = Adw.WindowTitle(title="Workstation Hotkey Cheatsheet", subtitle="Super (Thumb) = OS & Windows | Ctrl = In-App")
        header.set_title_widget(title_widget)
        main_box.append(header)

        # Search Bar
        search_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        search_box.add_css_class("search-bar")
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_hexpand(True)
        self.search_entry.set_placeholder_text("Search shortcuts... (e.g. terminal, tile, workspace, screenshot)")
        self.search_entry.connect("search-changed", self.on_search_changed)
        search_box.append(self.search_entry)
        main_box.append(search_box)

        # Scrolled Window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        scrolled.set_hexpand(True)
        main_box.append(scrolled)

        # Grid Content Box
        self.cards_grid = Gtk.Grid()
        self.cards_grid.set_column_spacing(16)
        self.cards_grid.set_row_spacing(16)
        self.cards_grid.set_margin_start(16)
        self.cards_grid.set_margin_end(16)
        self.cards_grid.set_margin_top(8)
        self.cards_grid.set_margin_bottom(20)
        self.cards_grid.set_column_homogeneous(True)
        scrolled.set_child(self.cards_grid)

        self.row_widgets = []
        self.populate_categories()

    def create_kbd_pill(self, key_text):
        label = Gtk.Label(label=key_text)
        label.add_css_class("kbd-badge")
        return label

    def populate_categories(self):
        col = 0
        row = 0
        for cat in CATEGORIES:
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            card.add_css_class("card")
            card.set_margin_top(4)
            card.set_margin_bottom(4)

            # Category Header
            header_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            header_box.set_margin_start(12)
            header_box.set_margin_end(12)
            header_box.set_margin_top(12)
            header_box.set_margin_bottom(6)

            title_lbl = Gtk.Label(label=cat["name"], xalign=0)
            title_lbl.add_css_class("category-title")
            desc_lbl = Gtk.Label(label=cat["description"], xalign=0)
            desc_lbl.add_css_class("category-desc")

            header_box.append(title_lbl)
            header_box.append(desc_lbl)
            card.append(header_box)

            # Separator
            card.append(Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL))

            # Items List
            list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            list_box.set_margin_start(4)
            list_box.set_margin_end(4)
            list_box.set_margin_top(6)
            list_box.set_margin_bottom(8)

            for desc, keys in cat["items"]:
                row_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
                row_box.add_css_class("hotkey-row")
                row_box.set_hexpand(True)

                desc_label = Gtk.Label(label=desc, xalign=0)
                desc_label.add_css_class("hotkey-desc")
                desc_label.set_hexpand(True)
                row_box.append(desc_label)

                # Keys Box
                keys_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
                keys_box.set_spacing(4)
                for idx, k in enumerate(keys):
                    if k in ("or", "/"):
                        sep = Gtk.Label(label=k)
                        sep.add_css_class("kbd-separator")
                        keys_box.append(sep)
                    else:
                        keys_box.append(self.create_kbd_pill(k))

                row_box.append(keys_box)
                list_box.append(row_box)
                self.row_widgets.append((desc, " ".join(keys), cat["name"], row_box, card))

            card.append(list_box)
            self.cards_grid.attach(card, col, row, 1, 1)

            col += 1
            if col >= 2:
                col = 0
                row += 1

    def on_search_changed(self, entry):
        query = entry.get_text().strip().lower()
        card_visibility = {}

        for desc, keys_str, cat_name, row_box, card in self.row_widgets:
            match = (
                not query
                or query in desc.lower()
                or query in keys_str.lower()
                or query in cat_name.lower()
            )
            row_box.set_visible(match)
            if match:
                card_visibility[card] = True
            elif card not in card_visibility:
                card_visibility[card] = False

        for desc, keys_str, cat_name, row_box, card in self.row_widgets:
            if card_visibility.get(card, False):
                card.set_visible(True)
            else:
                card.set_visible(False)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval in (Gdk.KEY_Escape, Gdk.KEY_q, Gdk.KEY_Q):
            self.close()
            return True
        return False


def toggle_or_run():
    # Singleton check: if already running, kill existing instance and exit (toggle action)
    my_pid = os.getpid()
    import subprocess
    try:
        out = subprocess.run(["pgrep", "-f", "hotkey-cheatsheet.py"], capture_output=True, text=True)
        pids = [int(p) for p in out.stdout.strip().split() if p.isdigit() and int(p) != my_pid]
        if pids:
            for p in pids:
                try:
                    os.kill(p, signal.SIGTERM)
                except OSError:
                    pass
            sys.exit(0)
    except Exception:
        pass

    app = Adw.Application(application_id='com.nichsedge.cheatsheet', flags=Gio.ApplicationFlags.NON_UNIQUE)

    def on_activate(app):
        win = CheatsheetWindow(app)
        win.present()

    app.connect('activate', on_activate)
    app.run([])

if __name__ == '__main__':
    toggle_or_run()
