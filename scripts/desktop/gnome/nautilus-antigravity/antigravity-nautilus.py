from gi.repository import Nautilus, GObject
from subprocess import call
import os

ANTIGRAVITY = os.environ.get("ANTIGRAVITY_BIN", "antigravity-ide")
ANTIGRAVITYNAME = os.environ.get("ANTIGRAVITY_NAME", "Antigravity IDE")


class AntigravityExtension(GObject.GObject, Nautilus.MenuProvider):
    def launch_antigravity(self, menu, files):
        safepaths = ""
        for file in files:
            filepath = file.get_location().get_path()
            safepaths += '"' + filepath + '" '
        call(ANTIGRAVITY + " " + safepaths + "&", shell=True)

    def get_file_items(self, *args):
        files = args[-1]
        item = Nautilus.MenuItem(
            name="AntigravityOpen",
            label="Open in " + ANTIGRAVITYNAME,
            tip="Opens the selected files with " + ANTIGRAVITYNAME,
        )
        item.connect("activate", self.launch_antigravity, files)
        return [item]

    def get_background_items(self, *args):
        file_ = args[-1]
        item = Nautilus.MenuItem(
            name="AntigravityOpenBackground",
            label="Open in " + ANTIGRAVITYNAME,
            tip="Opens the current directory in " + ANTIGRAVITYNAME,
        )
        item.connect("activate", self.launch_antigravity, [file_])
        return [item]
