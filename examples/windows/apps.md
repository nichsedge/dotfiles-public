# Windows App Checklist

Reference app list for a fresh Windows machine. Use winget, Chocolatey, or manual installers depending on the machine.

Browsers:

```text
firefox
google-chrome
microsoft-edge
```

Development:

```text
git
visual-studio-code
miniconda3
java
nvm
nodejs
```

Media and communication:

```text
vlc
obs-studio
zoom
```

Windows 11 classic context menu tweak:

```powershell
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```
