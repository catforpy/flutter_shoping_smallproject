#!/bin/bash

echo "🔧 修复 Gradle 损坏的 zip 文件..."
echo ""

GRADLE_DIR="/Users/shiweijuan/.gradle/wrapper/dists/gradle-8.10.2-all/7iv73wktx1xtkvlq19urqw1wm"

echo "1️⃣ 删除损坏的 Gradle zip 文件..."
rm -f "$GRADLE_DIR/gradle-8.10.2-all.zip"
rm -f "$GRADLE_DIR/gradle-8.10.2-all.zip.lck"
echo "   ✅ 完成"

echo ""
echo "2️⃣ 清理 Flutter 缓存..."
flutter clean
echo "   ✅ 完成"

echo ""
echo "3️⃣ 重新运行 Flutter..."
echo "   Gradle 会自动重新下载正确的文件"
echo ""
echo "现在可以运行: flutter run"

