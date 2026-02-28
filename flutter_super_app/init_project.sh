#!/bin/bash
# Flutter 超大型项目 - 初始化脚本
# 创建时间: 2026-02-24

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "🔧 初始化 Flutter 超大型项目"
echo "=========================================="
echo ""

# ============================================
# Step 1: 安装 Melos
# ============================================
echo -e "${BLUE}📦 Step 1: 安装 Melos${NC}"
echo ""

if command -v melos &> /dev/null; then
    echo -e "${GREEN}✅ Melos 已安装${NC}"
    melos --version
else
    echo -e "${YELLOW}⏳ 正在安装 Melos...${NC}"
    dart pub global activate melos
    echo -e "${GREEN}✅ Melos 安装成功${NC}"
fi

echo ""

# ============================================
# Step 2: 初始化 Git 仓库
# ============================================
echo -e "${BLUE}📦 Step 2: 初始化 Git 仓库${NC}"
echo ""

if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git 仓库已初始化${NC}"
else
    echo -e "${YELLOW}⏳ 正在初始化 Git...${NC}"
    git init
    echo -e "${GREEN}✅ Git 初始化成功${NC}"
fi

# 配置 Git
echo -e "${YELLOW}⏳ 配置 Git 远程仓库...${NC}"
git remote add origin https://github.com/catforpy/flutter_super_app.git 2>/dev/null || true
git branch -M main
echo -e "${GREEN}✅ Git 远程仓库配置完成${NC}"

echo ""

# ============================================
# Step 3: 安装依赖
# ============================================
echo -e "${BLUE}📦 Step 3: 安装所有 Package 依赖${NC}"
echo ""

echo -e "${YELLOW}⏳ 正在运行 melos bootstrap...${NC}"
echo -e "${YELLOW}（这可能需要几分钟，请耐心等待）${NC}"
echo ""

melos bootstrap

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ 所有依赖安装成功！${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️ 依赖安装可能有问题，请检查上面的输出${NC}"
fi

echo ""

# ============================================
# Step 4: 创建 .gitignore
# ============================================
echo -e "${BLUE}📦 Step 4: 创建 .gitignore 文件${NC}"
echo ""

cat > .gitignore << 'EOF'
# Flutter 相关
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# IDE 相关
.idea/
.vscode/
*.iml
*.swp
*.swo
*~

# macOS 相关
.DS_Store
.profile

# Windows 相关
Thumbs.db

# 代码生成
*.g.dart
*.freezed.dart
*.mocks.dart

# 日志
*.log

# Melos
.melos/
EOF

echo -e "${GREEN}✅ .gitignore 创建成功${NC}"

echo ""

# ============================================
# Step 5: 创建根 README.md
# ============================================
echo -e "${BLUE}📦 Step 5: 创建项目说明文档${NC}"
echo ""

if [ ! -f "README.md" ]; then
    cat > README.md << 'EOF'
# Flutter 超大型项目

一个采用 Monorepo 架构的 Flutter 超大型项目，包含电商、直播、IM、视频等多个业务模块。

## 🏗️ 项目结构

```
flutter_super_app/
├── packages/              # 所有代码包
│   ├── core/             # 核心基础层
│   ├── services/         # 业务服务层
│   ├── modules/          # 业务模块层
│   └── apps/             # 应用层
├── tools/                # 开发工具
└── docs/                 # 项目文档
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.4.0
- Melos（自动安装）

### 安装依赖

```bash
# 安装 Melos
dart pub global activate melos

# 安装所有依赖
melos bootstrap
```

### 运行应用

```bash
# 启动主应用
melos run start

# 或者
cd apps/app_main
flutter run
```

## 📚 文档

详细文档请查看 `docs/` 目录。

## 🛠️ 开发命令

```bash
# 运行测试
melos run test

# 代码生成
melos run gen

# 格式化代码
melos run format

# 分析代码
melos run analyze

# 清理项目
melos run clean
```

## 📝 许可证

MIT
EOF
    echo -e "${GREEN}✅ README.md 创建成功${NC}"
else
    echo -e "${YELLOW}⚠️  README.md 已存在，跳过创建${NC}"
fi

echo ""

# ============================================
# 完成
# ============================================
echo "=========================================="
echo -e "${GREEN}🎉 项目初始化完成！${NC}"
echo "=========================================="
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 查看项目结构："
echo "   find packages/ -type d -maxdepth 2"
echo ""
echo "2. 查看某个 Package 的内容："
echo "   ls packages/core/core_base/"
echo ""
echo "3. 开始开发："
echo "   cd packages/core/core_base"
echo "   # 编辑代码"
echo ""
echo "4. 查看文档："
echo "   cat 项目搭建指南.md"
echo ""
