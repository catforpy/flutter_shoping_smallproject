#!/bin/bash
# Flutter 超大型项目 - 自动化搭建脚本
# 创建时间: 2026-02-24

set -e  # 遇到错误立即停止

echo "=========================================="
echo "🚀 开始搭建 Flutter 超大型项目"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取当前目录
PROJECT_ROOT=$(pwd)
echo "📁 项目根目录: $PROJECT_ROOT"
echo ""

# ============================================
# Phase 1: 基础设施层 Package（零依赖）
# ============================================
echo -e "${BLUE}📦 Phase 1: 创建基础设施层 Package（零依赖）${NC}"
echo ""

cd packages/core

echo -e "${YELLOW}创建 core_base（基础类型）...${NC}"
flutter create --template=package core_base > /dev/null 2>&1
echo -e "${GREEN}✅ core_base 创建成功${NC}"

echo -e "${YELLOW}创建 core_utils（工具函数）...${NC}"
flutter create --template=package core_utils > /dev/null 2>&1
echo -e "${GREEN}✅ core_utils 创建成功${NC}"

echo -e "${YELLOW}创建 core_constants（常量定义）...${NC}"
flutter create --template=package core_constants > /dev/null 2>&1
echo -e "${GREEN}✅ core_constants 创建成功${NC}"

echo -e "${YELLOW}创建 core_exceptions（异常处理）...${NC}"
flutter create --template=package core_exceptions > /dev/null 2>&1
echo -e "${GREEN}✅ core_exceptions 创建成功${NC}"

echo -e "${YELLOW}创建 core_logging（日志系统）...${NC}"
flutter create --template=package core_logging > /dev/null 2>&1
echo -e "${GREEN}✅ core_logging 创建成功${NC}"

echo ""
echo -e "${BLUE}✅ 基础设施层 Package 创建完成！${NC}"
echo ""

# ============================================
# Phase 2: 核心能力层 Package
# ============================================
echo -e "${BLUE}📦 Phase 2: 创建核心能力层 Package${NC}"
echo ""

echo -e "${YELLOW}创建 core_network（网络请求）...${NC}"
flutter create --template=package core_network > /dev/null 2>&1
echo -e "${GREEN}✅ core_network 创建成功${NC}"

echo -e "${YELLOW}创建 core_database（数据库）...${NC}"
flutter create --template=package core_database > /dev/null 2>&1
echo -e "${GREEN}✅ core_database 创建成功${NC}"

echo -e "${YELLOW}创建 core_cache（缓存系统）...${NC}"
flutter create --template=package core_cache > /dev/null 2>&1
echo -e "${GREEN}✅ core_cache 创建成功${NC}"

echo -e "${YELLOW}创建 core_state（状态管理）...${NC}"
flutter create --template=package core_state > /dev/null 2>&1
echo -e "${GREEN}✅ core_state 创建成功${NC}"

echo -e "${YELLOW}创建 core_router（路由管理）...${NC}"
flutter create --template=package core_router > /dev/null 2>&1
echo -e "${GREEN}✅ core_router 创建成功${NC}"

echo -e "${YELLOW}创建 core_ui（UI组件库）...${NC}"
flutter create --template=package core_ui > /dev/null 2>&1
echo -e "${GREEN}✅ core_ui 创建成功${NC}"

echo -e "${YELLOW}创建 core_media（媒体处理）...${NC}"
flutter create --template=package core_media > /dev/null 2>&1
echo -e "${GREEN}✅ core_media 创建成功${NC}"

echo ""
echo -e "${BLUE}✅ 核心能力层 Package 创建完成！${NC}"
echo ""

# ============================================
# Phase 3: 业务服务层 Package
# ============================================
echo -e "${BLUE}📦 Phase 3: 创建业务服务层 Package${NC}"
echo ""

cd ../services

echo -e "${YELLOW}创建 service_user（用户服务）...${NC}"
flutter create --template=package service_user > /dev/null 2>&1
echo -e "${GREEN}✅ service_user 创建成功${NC}"

echo -e "${YELLOW}创建 service_auth（认证服务）...${NC}"
flutter create --template=package service_auth > /dev/null 2>&1
echo -e "${GREEN}✅ service_auth 创建成功${NC}"

echo -e "${YELLOW}创建 service_content（内容服务）...${NC}"
flutter create --template=package service_content > /dev/null 2>&1
echo -e "${GREEN}✅ service_content 创建成功${NC}"

echo ""
echo -e "${BLUE}✅ 业务服务层 Package 创建完成！${NC}"
echo ""

# ============================================
# Phase 4: 业务模块层 Package
# ============================================
echo -e "${BLUE}📦 Phase 4: 创建业务模块层 Package${NC}"
echo ""

cd ../modules

echo -e "${YELLOW}创建 module_common（公共模块）...${NC}"
flutter create --template=package module_common > /dev/null 2>&1
echo -e "${GREEN}✅ module_common 创建成功${NC}"

echo -e "${YELLOW}创建 module_shop（电商模块）...${NC}"
flutter create --template=package module_shop > /dev/null 2>&1
echo -e "${GREEN}✅ module_shop 创建成功${NC}"

echo -e "${YELLOW}创建 module_live（直播模块）...${NC}"
flutter create --template=package module_live > /dev/null 2>&1
echo -e "${GREEN}✅ module_live 创建成功${NC}"

echo ""
echo -e "${BLUE}✅ 业务模块层 Package 创建完成！${NC}"
echo ""

# ============================================
# Phase 5: 应用层 Package
# ============================================
echo -e "${BLUE}📦 Phase 5: 创建应用层 Package${NC}"
echo ""

cd ../apps

echo -e "${YELLOW}创建 app_main（主应用）...${NC}"
flutter create app_main > /dev/null 2>&1
echo -e "${GREEN}✅ app_main 创建成功${NC}"

echo ""
echo -e "${BLUE}✅ 应用层 Package 创建完成！${NC}"
echo ""

# 返回根目录
cd "$PROJECT_ROOT"

echo "=========================================="
echo -e "${GREEN}🎉 所有 Package 创建完成！${NC}"
echo "=========================================="
echo ""
echo "📊 创建统计："
echo "  - 基础设施层: 5 个 Package"
echo "  - 核心能力层: 8 个 Package"
echo "  - 业务服务层: 3 个 Package"
echo "  - 业务模块层: 3 个 Package"
echo "  - 应用层: 1 个 Package"
echo "  - 总计: 20 个 Package"
echo ""
echo "📋 下一步操作："
echo "  1. 运行: melos init"
echo "  2. 运行: melos bootstrap"
echo "  3. 查看 README.md 了解每个 Package 的作用"
echo ""
