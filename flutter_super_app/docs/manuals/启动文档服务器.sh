#!/bin/bash

# 文档服务器启动脚本

echo "🚀 启动文档服务器..."
echo "📍 文档目录: docs/manuals"
echo "🌐 服务地址: http://localhost:8000"
echo "📌 按 Ctrl+C 停止服务"
echo ""

# 进入文档目录
cd "$(dirname "$0")"

# 启动 Python HTTP 服务器
if command -v python3 &> /dev/null; then
  python3 -m http.server 8000
elif command -v python &> /dev/null; then
  python -m SimpleHTTPServer 8000
else
  echo "❌ 错误：未找到 Python"
  echo "请安装 Python 3 后重试"
  exit 1
fi
