#!/bin/bash

PLUGIN_DIR="$HOME/Documents/SwiftBar"
DATA_DIR="$HOME/Documents/SwiftBarData"
LOGFILE="$DATA_DIR/internet.log"
STATUSFILE="$DATA_DIR/internet_status.txt"
IPFILE="$DATA_DIR/internet_ip.txt"
BOOTFILE="$DATA_DIR/internet_boot.txt"
SOUNDFILE="$DATA_DIR/internet_sound.txt"

NOW=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$DATA_DIR"

# Звуки
SOUND_OFFLINE="/System/Library/Sounds/Sosumi.aiff"
SOUND_ONLINE="/System/Library/Sounds/Glass.aiff"

# Если файла настройки звука нет, считаем, что звук включен
if [ ! -f "$SOUNDFILE" ]; then
  echo "ON" > "$SOUNDFILE"
fi

SOUND_STATUS=$(cat "$SOUNDFILE")

play_sound() {
  if [ "$SOUND_STATUS" = "ON" ]; then
    afplay "$1" &
  fi
}

# Время последнего запуска Mac
BOOT_TIME=$(sysctl -n kern.boottime | sed -E 's/.*sec = ([0-9]+).*/\1/')

# Проверяем внешний IP
CURRENT_IP=$(curl -s --max-time 4 https://api.ipify.org)

if [ -n "$CURRENT_IP" ]; then
  STATUS="ONLINE"
  ICON="🟢"
  TEXT="Интернет есть"
else
  STATUS="OFFLINE"
  ICON="🔴"
  TEXT="Интернета нет"
  CURRENT_IP="-"
fi

# Показываем статус в верхней строке
if [ "$STATUS" = "ONLINE" ]; then
  echo "$ICON $CURRENT_IP"
else
  echo "$ICON"
fi

echo "---"
echo "$TEXT"
echo "Статус: $STATUS"
echo "IP: $CURRENT_IP"

if [ "$SOUND_STATUS" = "ON" ]; then
  echo "Звук: включен"
  echo "Отключить звук | bash=/bin/bash param1=-c param2='echo OFF > \"$HOME/Documents/SwiftBarData/internet_sound.txt\"' terminal=false refresh=true"
else
  echo "Звук: выключен"
  echo "Включить звук | bash=/bin/bash param1=-c param2='echo ON > \"$HOME/Documents/SwiftBarData/internet_sound.txt\"' terminal=false refresh=true"
fi

echo "---"
echo "Открыть лог | bash='open' param1='$LOGFILE' terminal=false"
echo "Открыть папку данных | bash='open' param1='$DATA_DIR' terminal=false"
echo "Открыть папку плагина | bash='open' param1='$PLUGIN_DIR' terminal=false"

# Читаем прошлое состояние
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

# 1. Если компьютер был перезапущен
if [ "$BOOT_TIME" != "$LAST_BOOT" ]; then
  echo "$NOW START status=$STATUS ip=$CURRENT_IP" >> "$LOGFILE"
  echo "$BOOT_TIME" > "$BOOTFILE"

  if [ "$STATUS" = "OFFLINE" ]; then
    play_sound "$SOUND_OFFLINE"
  fi

# 2. Если изменился статус интернета
elif [ "$STATUS" != "$LAST_STATUS" ]; then
  echo "$NOW STATUS $LAST_STATUS -> $STATUS ip=$CURRENT_IP" >> "$LOGFILE"

  if [ "$STATUS" = "OFFLINE" ]; then
    play_sound "$SOUND_OFFLINE"
  fi

  if [ "$STATUS" = "ONLINE" ]; then
    play_sound "$SOUND_ONLINE"
  fi

# 3. Если изменился внешний IP
elif [ "$STATUS" = "ONLINE" ] && [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$NOW IP $LAST_IP -> $CURRENT_IP" >> "$LOGFILE"
fi

# Сохраняем текущее состояние
echo "$STATUS" > "$STATUSFILE"
echo "$CURRENT_IP" > "$IPFILE"
