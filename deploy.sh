#!/bin/bash

# =========================================================================
# Report Engine 部门报表数据引擎 一键拉取与部署脚本 (基于 Docker 多阶段构建)
# =========================================================================

# 开启严格模式，遇到错误立即退出
set -e

REPO_URL="https://github.com/15863004186sunchi/report-engine.git"
PROJECT_DIR="report-engine"

echo "=========================================="
echo "    >>> 准备开始构建 Report Engine <<<"
echo "=========================================="

# 1. 前置环境检查及自动安装
echo ""
echo "---> [1/3] 检查并尝试安装极简前置依赖 (Git/Docker) ..."

# 获取包管理器类型
PKG_MANAGER=""
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo "警告: 无法识别系统包管理器 (非 apt/yum)，如果是 MacOS 等，请手动安装依赖。"
fi

install_pkg() {
    local cmd=$1
    local pkg=$2
    if ! command -v $cmd &> /dev/null; then
        echo "未检测到 $cmd，正在尝试自动安装..."
        if [ "$PKG_MANAGER" == "apt-get" ]; then
            sudo apt-get update -y || true
            sudo apt-get install -y $pkg
        elif [ "$PKG_MANAGER" == "yum" ]; then
            sudo yum install -y $pkg
        else
            echo "错误: 缺少 $cmd 且无法自动安装，请手动安装！"
            exit 1
        fi
    fi
}

# 基础命令安装 (因为已经使用了多阶段构建，此处抛弃了 maven 和 nodejs)
install_pkg "wget" "wget"
install_pkg "git" "git"

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "未检测到 docker，正在尝试安装 Docker..."
    if [ "$PKG_MANAGER" == "yum" ]; then
        # 兼容旧版 CentOS 7，判断是否拥有 dnf 命令
        YUM_CMD="yum"
        if command -v dnf &> /dev/null; then
            YUM_CMD="dnf"
        fi
        
        echo "检测到 RedHat/CentOS 系，尝试使用 ${YUM_CMD} 官方仓库执行安装..."
        
        # 移除旧版本（忽略报错）
        sudo ${YUM_CMD} remove -y docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine 2>/dev/null || true

        # 添加 Docker 官方 repo (如果是国外云服务器，可直接用 download.docker.com；国内可替换为 aliyun 镜像)
        if [ "$YUM_CMD" == "dnf" ]; then
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        else
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        fi

        # 安装 Docker Engine
        sudo ${YUM_CMD} install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # 启动并设置开机自启
        sudo systemctl enable --now docker
        echo "Docker 已启动并设置为开机自启"

        # 将当前登录用户加入 docker 组
        REAL_USER="${SUDO_USER:-$USER}"
        if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
            sudo usermod -aG docker "$REAL_USER"
            echo "警告: 已将用户 '${REAL_USER}' 加入 docker 组。重新登录后生效，或执行: newgrp docker"
        fi
    else
        echo "检测到 Debian/Ubuntu 或其他系统，使用官方便捷脚本安装..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm -f get-docker.sh
        sudo systemctl enable docker || true
        sudo systemctl start docker || true
    fi
fi

# 安装 Docker-Compose
if ! command -v docker-compose &> /dev/null; then
    echo "未检测到 docker-compose，正在尝试安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose || true
fi

echo "前置依赖检查完成！机器现已具备运行引擎。"

# ==================================
# 配置 Docker 国内镜像加速 (规避 i/o timeout)
# ==================================
echo ""
echo "---> [配置] 注入 Docker 镜像加速器配置以解决国内拉取超时..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://mirror.baidubce.com",
    "https://docker.nju.edu.cn",
    "https://dockerproxy.com"
  ]
}
EOF
sudo systemctl daemon-reload || true
sudo systemctl restart docker || true

# 2. 从 GitHub 拉取或更新源码
echo ""
echo "---> [2/3] 正在从 GitHub 检查/拉取源码 ..."

if [ -d ".git" ] && [ -f "pom.xml" ]; then
    echo "当前已在项目根目录，尝试执行 git pull 更新代码..."
    git pull origin main || echo "Git Pull 出现冲突，忽略..."
else
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "未检测到项目目录，正在全局拉取代码..."
        git clone "$REPO_URL" "$PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        echo "检测到现有目录 $PROJECT_DIR，进入目录拉取最新代码..."
        cd "$PROJECT_DIR"
        git pull origin main || echo "Git Pull 取消"
    fi
fi

# 3. 剥离了手工繁琐编译，直接交由 Docker Engine 接管编排
echo ""
echo "---> [3/3] 正在执行 Docker 微服务总装编排 (内部自动编译 Node 与 Java 产物) ..."
# 停止旧的容器
docker-compose down
# 强制启动：Docker在构建镜像时，会启动独立容器链去帮你编译前端和后台包
docker-compose up -d --build

echo ""
echo "=========================================="
echo "  Report Engine 云端一键统属部署完成！"
echo "  由于采用了镜像内多阶段分离编译，您的主机环境始终保持极简无污染。"
echo ""
echo "  服务已上线列表："
echo "  - Report 数据大屏及 API 接口 : http://localhost:8080"
echo "  - XXL-JOB 任务调度中心       : http://localhost:8085/xxl-job-admin"
echo "  - MySQL DB                   : localhost:3306"
echo "=========================================="
