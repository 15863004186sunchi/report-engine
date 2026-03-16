#!/bin/bash

# =========================================================================
# Report Engine 部门报表数据引擎 一键部署脚本
# =========================================================================

# 开启严格模式，遇到错误立即退出
set -e

echo "=========================================="
echo "    >>> 准备开始构建 Report Engine <<<"
echo "=========================================="

# 1. 前置环境检查
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到 maven (mvn) 命令！请先安装 Maven。"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo "错误: 未找到 npm 命令！请先安装 Node.js。"
    exit 1
fi
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到 docker 命令！请先安装 Docker。"
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 未找到 docker-compose 命令！请确认 Docker Compose 已安装。"
    exit 1
fi

# 2. 编译前端 Vue 项目
echo ""
echo "---> [1/4] 正在编译前端 Vue 项目 (这可能需要几分钟) ..."
cd frontend
npm install
npm run build
cd ..

# 3. 集成前端静态文件到后端
echo ""
echo "---> [2/4] 正在将前端构建产物集成到 Spring Boot 静态资源中 ..."
# 清理旧的 static 资源
rm -rf src/main/resources/static/*
mkdir -p src/main/resources/static
# 将 Vue 的 dist 目录内容复制到资源目录中
cp -r frontend/dist/* src/main/resources/static/

# 4. 编译后端 Java 项目
echo ""
echo "---> [3/4] 正在执行 Maven 打包后端工程 (跳过单元测试) ..."
mvn clean package -DskipTests

# 5. Docker 容器化编排启动
echo ""
echo "---> [4/4] 正在执行 Docker-Compose 重装部署 ..."
# 停止旧的容器
docker-compose down
# 强制重新构建并后台启动容器栈
docker-compose up -d --build

echo ""
echo "=========================================="
echo "  Report Engine 部署成功！"
echo "  服务端口列表："
echo "  - Report 数据大屏及 API 接口 : http://localhost:8080"
echo "  - XXL-JOB 任务调度中心       : http://localhost:8085/xxl-job-admin"
echo "  - MySQL 数据库               : localhost:3306"
echo "  (首次启动 MySQL 数据导入及 Spring Boot 启动可能需要 30 秒左右，请耐心等待)"
echo "=========================================="
