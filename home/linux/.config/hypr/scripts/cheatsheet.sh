#!/usr/bin/env bash
# Show shortcuts cheatsheet via wofi — Mac (⌘) + Linux (Super/Win) notation
cat << 'SHEET' | wofi --dmenu --prompt "⌨️ Shortcuts (Mac ⌘ / Linux Super)" --width 800 --height 520
⌘ / Super + Space      Spotlight / Launcher
⌘⇧ / Super+Shift+Space  Clipboard History  (or ⌘⇧/Super+Shift+V)
⌘↩ / Super+Return      Terminal (Ghostty)
⌘T / Super+T            Terminal
⌘N / Super+N            File Manager (Nautilus)
⌘B / Super+B            Browser
⌘Q / Super+Q            Quit Window
⌘W / Super+W            Close Window
⌘⌥⎋ / Super+Alt+Esc    Force Quit / btop
⌘F / Super+F            Fullscreen
⌃⌘F / Ctrl+Super+F      Mac-style Fullscreen
⌘M / Super+M            Minimize / Scratchpad
⌘H / Super+H            Hide Window
⌘⇧M / Super+Shift+M     Toggle Scratchpad
⌘⇧H / Super+Shift+H     Toggle Scratchpad (alt)
⌘Tab / Super+Tab        Cycle Forward
⌥Tab / Alt+Tab          Cycle (Alt)
⌘⇧Tab / Super+Shift+Tab Cycle Backward
⌘, / Super+Comma        Edit Config
⌘L / Super+L            Lock Screen
⌘⇧Q / Super+Shift+Q     Power Menu
⌘⇧3 / Super+Shift+3     Screenshot Full
⌘⇧4 / Super+Shift+4     Screenshot Area
⌘⇧5 / Super+Shift+5     Screenshot Window
⌘⌥← / Super+Alt+Left    Focus Left
⌘⌥→ / Super+Alt+Right   Focus Right
⌘⌥↑ / Super+Alt+Up      Focus Up
⌘⌥↓ / Super+Alt+Down    Focus Down
⌘⇧← / Super+Shift+Left  Move Left
⌘⇧→ / Super+Shift+Right Move Right
⌘⇧↑ / Super+Shift+Up    Move Up
⌘⇧↓ / Super+Shift+Down  Move Down
⌃← / Ctrl+Left          Prev Workspace
⌃→ / Ctrl+Right         Next Workspace
⌃↑ / Ctrl+Up            Scratchpad / Mission Control
⌃↓ / Ctrl+Down          Scratchpad / Mission Control
⌘1..9 / Super+1..9      Workspace 1-9
⌘⇧1..9 / Super+Shift+1..9  Move to Workspace 1-9
⌘⌃1..9 / Super+Ctrl+1..9  Move Window to Workspace 1-9 (fixed)
3-Finger Swipe ↔         Swipe Workspaces
SHEET
