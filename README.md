# SwiftBar Internet Monitor

A small [SwiftBar](https://github.com/swiftbar/SwiftBar) plugin for macOS that shows internet connectivity and the current external IP address in the menu bar.

## What it does

- Shows online/offline status in the menu bar.
- Displays the current external IP address when online.
- Logs startup, status changes, and IP changes.
- Plays a macOS system sound when the connection goes offline or comes back online.
- Lets you toggle sounds from the SwiftBar menu.

## Installation

1. Install SwiftBar.
2. Copy `internet.5s.sh` into your SwiftBar plugin folder.
3. Make the script executable:

   ```bash
   chmod +x internet.5s.sh
   ```

4. Set SwiftBar to use that plugin folder.

The plugin refreshes every 5 seconds because of the `.5s.` part in the filename.

## Data Location

Runtime data is stored outside the plugin folder:

```text
~/Documents/SwiftBarData
```

This keeps SwiftBar from treating log and state files as plugins. The folder is created automatically and stores:

- `internet.log`
- `internet_status.txt`
- `internet_ip.txt`
- `internet_boot.txt`
- `internet_sound.txt`

## Notes

The external IP check uses:

```text
https://api.ipify.org
```

If the request fails within 4 seconds, the plugin treats the connection as offline.
