#!/bin/bash

# ========== CONFIG ========== #
HUGO_PORT=1313
CMS_PORT=8081
HUGO_CMD="hugo server -D"
CMS_CMD="npx netlify-cms-proxy-server"
WORKDIR="$(pwd)"
# ============================ #

function check_and_kill_port() {
  local port=$1
  local pname=$2

  pid=$(lsof -ti :$port)
  if [ -n "$pid" ]; then
    echo "⚠️  Port $port đang bị chiếm bởi PID: $pid ($pname)"
    read -p "Bạn có muốn kill tiến trình này không? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
      kill -9 $pid
      echo "✅ Đã kill tiến trình trên port $port."
    else
      echo "❌ Không kill, script sẽ thoát."
      exit 1
    fi
  fi
}

echo "🔍 Kiểm tra port $HUGO_PORT (Hugo)..."
check_and_kill_port $HUGO_PORT "Hugo"

echo "🔍 Kiểm tra port $CMS_PORT (CMS Proxy)..."
check_and_kill_port $CMS_PORT "CMS Proxy"

echo "🚀 Đang chạy Hugo và Decap CMS local..."

osascript <<EOF
tell application "Terminal"
    do script "cd '$WORKDIR'; $HUGO_CMD"
end tell
tell application "Terminal"
    do script "cd '$WORKDIR'; $CMS_CMD"
end tell
EOF

echo "✅ Xong! Mở http://localhost:$HUGO_PORT/admin để dùng CMS."
