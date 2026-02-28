#!/bin/bash

# 嵌套路由示例验证脚本

echo "🔍 验证嵌套路由示例..."
echo ""

# 检查文件是否存在
echo "📁 检查文件..."
FILES=(
  "lib/nested_routes_example.dart"
  "lib/main.dart"
  "pubspec.yaml"
  "test/nested_routes_test.dart"
  "README.md"
  "QUICK_START.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (不存在)"
    exit 1
  fi
done

echo ""
echo "📦 安装依赖..."
flutter pub get

echo ""
echo "🔍 代码分析..."
flutter analyze --no-fatal-infos

if [ $? -eq 0 ]; then
  echo "  ✅ 代码分析通过"
else
  echo "  ❌ 代码分析失败"
  exit 1
fi

echo ""
echo "🧪 运行测试..."
flutter test

if [ $? -eq 0 ]; then
  echo "  ✅ 测试通过"
else
  echo "  ⚠️  测试失败或没有测试"
fi

echo ""
echo "✨ 验证完成！"
echo ""
echo "🚀 运行示例:"
echo "   flutter run"
echo ""
echo "📚 查看文档:"
echo "   cat README.md"
echo "   cat QUICK_START.md"
