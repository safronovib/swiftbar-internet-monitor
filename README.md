# SwiftBar Internet Monitor

A small [SwiftBar](https://github.com/swiftbar/SwiftBar) plugin for macOS that shows internet connectivity and the current external IP address in the menu bar.

Developer: Igor Safronov

## What it does

- Shows online/offline status in the menu bar.
- Displays the current external IP address when online.
- Logs startup, status changes, and IP changes.
- Plays a macOS system sound when the connection goes offline or comes back online.
- Lets you toggle sounds from the SwiftBar menu.
- Supports English and Russian menu labels.

## Installation

1. Install SwiftBar.
2. Create a local SwiftBar plugin folder outside iCloud, for example:

   ```bash
   mkdir -p "$HOME/Library/Application Support/SwiftBarPlugins"
   ```

3. Copy only `internet.5s.sh` into that folder.
4. Make the script executable:

   ```bash
   chmod +x internet.5s.sh
   ```

5. Set SwiftBar to use that plugin folder.

Avoid using an iCloud-synced `Documents` folder as the active SwiftBar plugin folder. macOS can evict small files during startup, which may prevent plugins from running reliably.

The plugin refreshes every 5 seconds because of the `.5s.` part in the filename.

## Folder Policy

Keep three locations separate:

```text
Source repository: any development folder, for example ~/Documents/SwiftBar
Active SwiftBar plugin folder: ~/Library/Application Support/SwiftBarPlugins
Runtime data folder: ~/Library/Application Support/SwiftBarInternetMonitor
```

The active SwiftBar plugin folder should contain only executable SwiftBar plugins. For this project, that means:

```text
internet.5s.sh
```

Do not put these files in the active SwiftBar plugin folder:

- `README.md`
- `LICENSE`
- `.git`
- `.gitignore`
- `internet.log`
- `internet_status.txt`
- `internet_ip.txt`
- `internet_boot.txt`
- `internet_sound.txt`
- `internet_language.txt`

SwiftBar scans the plugin folder. If extra files become executable, SwiftBar may show confusing duplicate or broken menu items. The plugin never writes runtime files into its own plugin folder.

## Data Location

Runtime data is stored outside the plugin folder:

```text
~/Library/Application Support/SwiftBarInternetMonitor
```

This keeps SwiftBar from treating log and state files as plugins, and avoids iCloud evicting small state files from `Documents` during startup. The folder is created automatically and stores:

- `internet.log`
- `internet_status.txt`
- `internet_ip.txt`
- `internet_boot.txt`
- `internet_sound.txt`
- `internet_language.txt`

English is used by default. You can switch between English and Russian from the SwiftBar menu.

## Quick Checks

Check the active SwiftBar plugin folder:

```bash
defaults read com.ameba.SwiftBar PluginDirectory
```

Check that only the plugin script is executable:

```bash
find "$HOME/Library/Application Support/SwiftBarPlugins" -maxdepth 1 -type f -perm +111 -print
```

The expected output is:

```text
/Users/your-name/Library/Application Support/SwiftBarPlugins/internet.5s.sh
```

If SwiftBar starts showing unexpected menu items, remove non-plugin files from the active plugin folder and disable SwiftBar's automatic executable permission setting.

## Notes

The external IP check uses:

```text
https://api.ipify.org
```

If the request fails within 4 seconds, the plugin treats the connection as offline.
