# 🚀 Tofi Script Launcher

A lightweight, directory-specific application launcher for Wayland, powered by `tofi`. 

This script scans a target directory for executables (up to 3 levels deep by default), smartly identifies their names based on context, and presents them in a sleek menu. Perfect for game folders, script collections, or standalone binaries.

---

## ✨ Features

* **Smart Naming**: If a script is named `run.sh` or `start`, the launcher uses the parent folder's name instead. Much more civilised.
* **Deep Scan**: Searches up to 3 levels deep, ignoring hidden dot-files.
* **Pattern Matching**: Optionally filter by file patterns (e.g., only show `*.x86_64` or `*.sh`).
* **Notification Support**: Sends a `notify-send` alert when an application is engaged.
* **Environment Aware**: Uses `setsid` to ensure applications keep running even if the launcher or terminal closes.

## 🛠 Prerequisites

Ensure you have the following installed:
* `tofi` - The menu provider.
* `libnotify` (Optional) - For system notifications with a notification daemon of c.

## 🚀 Installation
Getting started is straightforward. Open your terminal and follow these steps:

### 1. Clone the repository
Use SSH to grab the source code:
```bash
git clone git@github.com:AceMinerOjal/tofi-script-launcher.git
cd tofi-script-launcher
```
### 2. Set Permissions
Make the script executable so it can actually do its job:
```bash
chmod +x launch.sh
```
### 3. Install Dependencies
On Arch Linux, ensure you have the necessary tools:
```bash
sudo pacman -S tofi libnotify
```

## Usage

```bash
./launch.sh /path/to/target_dir [pattern1 pattern2 ...]
```
* `/path/to/target_dir` — Required. The directory to scan for executable scripts or binaries.
* `pattern1 pattern2 ...` — Optional. File name patterns to filter which executables appear in the menu (e.g., *.sh, *.x86_64). By default, all executables are included.
**Examples:**
```bash
# Launch scripts from ~/Games folder
./launch.sh ~/Games

# Only show shell scripts
./launch.sh ~/Scripts '*.sh'

# Launch only 64-bit binaries
./launch.sh ~/Apps '*.x86_64'
```
After execution, a menu powered by `tofi` appears, listing the discovered scripts. Select an entry to run it. If a script has a generic name like `run` or `start`, the launcher will display its parent folder name instead.

## Configuration and Customization:

* Depth of Search: Currently hardcoded to 3 levels. Modify -maxdepth 3 in the find command to change this.
* Excluding Files: Hidden files/folders (.*) are ignored. You can adjust the -not -path '*/.*' filter if needed.
* Pattern Matching: Pass shell globs as additional arguments to limit displayed scripts.

## Integration(hyprland)

If you’re using a Wayland compositor like Hyprland, you can bind the launcher to a key. For example, open your `hyprland.conf` and add:
```Code Snippet
# Launch scripts from a specific folder with Super + G
bind = $mainMod, G, exec, ~/tofi-script-launcher/launch.sh ~/your/app/folder
```
