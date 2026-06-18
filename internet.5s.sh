#!/bin/bash

PLUGIN_DIR="$HOME/Documents/SwiftBar"
DATA_DIR="$HOME/Documents/SwiftBarData"
REPOSITORY_URL="https://github.com/safronovib/swiftbar-internet-monitor"
VERSION="1.1.0"
LOGFILE="$DATA_DIR/internet.log"
STATUSFILE="$DATA_DIR/internet_status.txt"
IPFILE="$DATA_DIR/internet_ip.txt"
BOOTFILE="$DATA_DIR/internet_boot.txt"
SOUNDFILE="$DATA_DIR/internet_sound.txt"
LANGFILE="$DATA_DIR/internet_language.txt"

NOW=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$DATA_DIR"

# Sounds
SOUND_OFFLINE="/System/Library/Sounds/Sosumi.aiff"
SOUND_ONLINE="/System/Library/Sounds/Glass.aiff"

# If setting files do not exist, create sensible defaults.
if [ ! -f "$SOUNDFILE" ]; then
  echo "ON" > "$SOUNDFILE"
fi

if [ ! -f "$LANGFILE" ]; then
  echo "en" > "$LANGFILE"
fi

SOUND_STATUS=$(cat "$SOUNDFILE")
LANGUAGE=$(cat "$LANGFILE")

if [ "$LANGUAGE" != "ru" ]; then
  LANGUAGE="en"
fi

t() {
  KEY="$1"

  if [ "$LANGUAGE" = "ru" ]; then
    case "$KEY" in
      online_text) echo "Интернет есть" ;;
      offline_text) echo "Интернета нет" ;;
      status) echo "Статус" ;;
      ip) echo "IP" ;;
      sound_on) echo "Звук: включен" ;;
      sound_off) echo "Звук: выключен" ;;
      disable_sound) echo "Отключить звук" ;;
      enable_sound) echo "Включить звук" ;;
      language) echo "Язык" ;;
      english) echo "English" ;;
      russian) echo "Русский" ;;
      open_log) echo "Открыть лог" ;;
      open_data_folder) echo "Открыть папку данных" ;;
      open_plugin_folder) echo "Открыть папку плагина" ;;
      open_github) echo "Открыть GitHub" ;;
      about) echo "О программе" ;;
      about_message) echo "SwiftBar Internet Monitor\nВерсия: $VERSION\n\nПоказывает статус интернета и внешний IP в строке меню.\n\nДанные: $DATA_DIR\nGitHub: $REPOSITORY_URL" ;;
    esac
  else
    case "$KEY" in
      online_text) echo "Internet is available" ;;
      offline_text) echo "No internet connection" ;;
      status) echo "Status" ;;
      ip) echo "IP" ;;
      sound_on) echo "Sound: on" ;;
      sound_off) echo "Sound: off" ;;
      disable_sound) echo "Disable sound" ;;
      enable_sound) echo "Enable sound" ;;
      language) echo "Language" ;;
      english) echo "English" ;;
      russian) echo "Русский" ;;
      open_log) echo "Open log" ;;
      open_data_folder) echo "Open data folder" ;;
      open_plugin_folder) echo "Open plugin folder" ;;
      open_github) echo "Open GitHub" ;;
      about) echo "About" ;;
      about_message) echo "SwiftBar Internet Monitor\nVersion: $VERSION\n\nShows internet status and external IP in the menu bar.\n\nData: $DATA_DIR\nGitHub: $REPOSITORY_URL" ;;
    esac
  fi
}

play_sound() {
  if [ "$SOUND_STATUS" = "ON" ]; then
    afplay "$1" &
  fi
}

if [ "$1" = "--about" ]; then
  /usr/bin/osascript -e "display alert \"SwiftBar Internet Monitor\" message \"$(t about_message)\" as informational buttons {\"OK\"} default button \"OK\" giving up after 60"
  exit 0
fi

# Last Mac startup time
BOOT_TIME=$(sysctl -n kern.boottime | sed -E 's/.*sec = ([0-9]+).*/\1/')

# Check external IP
CURRENT_IP=$(curl -s --max-time 4 https://api.ipify.org)

if [ -n "$CURRENT_IP" ]; then
  STATUS="ONLINE"
  ICON="🟢"
  TEXT=$(t online_text)
else
  STATUS="OFFLINE"
  ICON="🔴"
  TEXT=$(t offline_text)
  CURRENT_IP="-"
fi

# Show status in the menu bar.
if [ "$STATUS" = "ONLINE" ]; then
  echo "$ICON $CURRENT_IP"
else
  echo "$ICON"
fi

echo "---"
echo "$TEXT"
echo "$(t status): $STATUS"
echo "$(t ip): $CURRENT_IP"

if [ "$SOUND_STATUS" = "ON" ]; then
  echo "$(t sound_on)"
  echo "$(t disable_sound) | bash=/bin/bash param1=-c param2='echo OFF > \"$HOME/Documents/SwiftBarData/internet_sound.txt\"' terminal=false refresh=true"
else
  echo "$(t sound_off)"
  echo "$(t enable_sound) | bash=/bin/bash param1=-c param2='echo ON > \"$HOME/Documents/SwiftBarData/internet_sound.txt\"' terminal=false refresh=true"
fi

echo "---"
echo "$(t language): $LANGUAGE"
echo "$(t english) | bash=/bin/bash param1=-c param2='echo en > \"$HOME/Documents/SwiftBarData/internet_language.txt\"' terminal=false refresh=true"
echo "$(t russian) | bash=/bin/bash param1=-c param2='echo ru > \"$HOME/Documents/SwiftBarData/internet_language.txt\"' terminal=false refresh=true"
echo "---"
echo "$(t open_log) | bash='open' param1='$LOGFILE' terminal=false"
echo "$(t open_data_folder) | bash='open' param1='$DATA_DIR' terminal=false"
echo "$(t open_plugin_folder) | bash='open' param1='$PLUGIN_DIR' terminal=false"
echo "$(t open_github) | href='$REPOSITORY_URL'"
echo "$(t about) | bash='$0' param1='--about' terminal=false"

# Read previous state.
LAST_STATUS=""
LAST_IP=""
LAST_BOOT=""

if [ -f "$STATUSFILE" ]; then
  LAST_STATUS=$(cat "$STATUSFILE")
fi

if [ -f "$IPFILE" ]; then
  LAST_IP=$(cat "$IPFILE")
fi

if [ -f "$BOOTFILE" ]; then
  LAST_BOOT=$(cat "$BOOTFILE")
fi

# 1. Computer was restarted.
if [ "$BOOT_TIME" != "$LAST_BOOT" ]; then
  echo "$NOW START status=$STATUS ip=$CURRENT_IP" >> "$LOGFILE"
  echo "$BOOT_TIME" > "$BOOTFILE"

  if [ "$STATUS" = "OFFLINE" ]; then
    play_sound "$SOUND_OFFLINE"
  fi

# 2. Internet status changed.
elif [ "$STATUS" != "$LAST_STATUS" ]; then
  echo "$NOW STATUS $LAST_STATUS -> $STATUS ip=$CURRENT_IP" >> "$LOGFILE"

  if [ "$STATUS" = "OFFLINE" ]; then
    play_sound "$SOUND_OFFLINE"
  fi

  if [ "$STATUS" = "ONLINE" ]; then
    play_sound "$SOUND_ONLINE"
  fi

# 3. External IP changed.
elif [ "$STATUS" = "ONLINE" ] && [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$NOW IP $LAST_IP -> $CURRENT_IP" >> "$LOGFILE"
fi

# Save current state.
echo "$STATUS" > "$STATUSFILE"
echo "$CURRENT_IP" > "$IPFILE"
