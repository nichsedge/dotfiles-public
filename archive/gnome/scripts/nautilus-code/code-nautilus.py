from gi.repository import Nautilus, GObject
from subprocess import call
import os

VSCODE = os.environ.get("VSCODE_BIN", "code")
VSCODENAME = os.environ.get("VSCODE_NAME", "Code")
NEWWINDOW = os.environ.get("VSCODE_NEW_WINDOW", "0") == "1"


class VSCodeExtension(GObject.GObject, Nautilus.MenuProvider):
    def launch_vscode(self, menu, files):
        safepaths = ""
        args = ""
        for file in files:
            filepath = file.get_location().get_path()
            safepaths += '"' + filepath + '" '
            if os.path.isdir(filepath) and os.path.exists(filepath):
                args = "--new-window "
        if NEWWINDOW:
            args = "--new-window "
        call(VSCODE + " " + args + safepaths + "&", shell=True)

    def get_file_items(self, *args):
        files = args[-1]
        item = Nautilus.MenuItem(
            name="VSCodeOpen",
            label="Open in " + VSCODENAME,
            tip="Opens the selected files with " + VSCODENAME,
        )
        item.connect("activate", self.launch_vscode, files)
        return [item]

    def get_background_items(self, *args):
        file_ = args[-1]
        item = Nautilus.MenuItem(
            name="VSCodeOpenBackground",
            label="Open in " + VSCODENAME,
            tip="Opens the current directory in " + VSCODENAME,
        )
        item.connect("activate", self.launch_vscode, [file_])
        return [item]
