#!/bin/bash

echo "🔧 修复 Gradle 问题..."
echo ""

# 1. 删除锁文件
echo "1️⃣ 删除 Gradle 锁文件..."
rm -f /Users/shiweijuan/.gradle/wrapper/dists/gradle-*/gradle-*.zip.lck
echo "   ✅ 完成"

# 2. 清理 Flutter 缓存
echo ""
echo "2️⃣ 清理 Flutter 缓存..."
flutter clean
echo "   ✅ 完成"

# 3. 清理 Gradle 缓存
echo ""
echo "3️⃣ 清理 Gradle 缓存..."
cd android && ./gradlew clean && cd ..
echo "   ✅ 完成"

# 4. 重新获取依赖
echo ""
echo "4️⃣ 重新获取依赖..."
flutter pub get
echo "   ✅ 完成"

echo ""
echo "✅ 修复完成！现在可以运行："
echo "   flutter run"
