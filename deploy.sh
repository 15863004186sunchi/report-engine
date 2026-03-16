#!/bin/bash

# =========================================================================
# Report Engine 部门报表数据引擎 一键拉取与部署脚本
# =========================================================================

# 开启严格模式，遇到错误立即退出
set -e

REPO_URL="https://github.com/15863004186sunchi/report-engine.git"
PROJECT_DIR="report-engine"

echo "=========================================="
echo "    >>> 准备开始构建 Report Engine <<<"
echo "=========================================="

# 1. 前置环境检查
for cmd in git mvn npm docker docker-compose; do
    if ! command -v $cmd &> /dev/null; then
        echo "错误: 未找到 $cmd 命令！请先安装相应的依赖环境。"
        exit 1
    fi
done

# 2. 从 GitHub 拉取或更新源码
echo ""
echo "---> [1/5] 正在从 GitHub 检查/拉取源码 ..."

# 判断是否已经在项目目录内 (比如用户本身就是在 clone 下来的 repo 里面执行)
if [ -d ".git" ] && [ -f "pom.xml" ]; then
    echo "当前已在项目根目录，尝试执行 git pull 更新代码..."
    git pull origin main
else
    # 用户在其他外层目录单独下载了并执行了本 deploy.sh
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "未检测到项目目录，正在执行全局 Clone: $REPO_URL ..."
        git clone "$REPO_URL" "$PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        echo "检测到现有目录 $PROJECT_DIR，进入目录拉取最新代码..."
        cd "$PROJECT_DIR"
        git pull origin main || echo "Git Pull 有冲突或受限，跳过更新..."
    fi
fi

# 3. 编译前端 Vue 项目
echo ""
echo "---> [2/5] 正在编译前端 Vue 项目 (这可能需要几分钟) ..."
cd frontend
npm install
npm run build
cd ..

# 4. 集成前端静态文件到后端
echo ""
echo "---> [3/5] 正在将前端构建产物集成到 Spring Boot 静态资源中 ..."
# 清理旧的 static 资源
rm -rf src/main/resources/static/*
mkdir -p src/main/resources/static
# 将 Vue 的 dist 目录内容复制到资源目录中
cp -r frontend/dist/* src/main/resources/static/

# 5. 编译后端 Java 项目
echo ""
echo "---> [4/5] 正在执行 Maven 打包后端工程 (跳过单元测试) ..."
mvn clean package -DskipTests

# 6. Docker 容器化编排启动
echo ""
echo "---> [5/5] 正在执行 Docker-Compose 重装部署 ..."
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
echo "  (首次启动 MySQL 数据导入及 Spring Boot 应用启动可能需 1~2 分钟，请耐心等待)"
echo "=========================================="
