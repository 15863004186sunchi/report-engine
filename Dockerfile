# ==========================================
# Phase 1: 构建 Vue3 前端
# ==========================================
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
# 利用 Docker 缓存层，独立拉取依赖
COPY frontend/package*.json ./
RUN npm install
# 拷贝全部前端代码并打包
COPY frontend/ ./
RUN npm run build

# ==========================================
# Phase 2: 后端打包 (并将前端置入静态资源)
# ==========================================
FROM maven:3.9.6-eclipse-temurin-17 AS backend-builder
WORKDIR /app
# 拷贝主工程 pom 及 java 源码
COPY pom.xml ./
COPY src ./src
# 把前一个阶段 node 打包出的 dist 目录里的资源，复制到 Spring Boot 识别的 static 下面！
COPY --from=frontend-builder /app/frontend/dist/ ./src/main/resources/static/
# 彻底在相对隔离的镜像环境内打成最终集成的 fat-jar
RUN mvn clean package -DskipTests

# ==========================================
# Phase 3: 最小化运行时环境
# ==========================================
FROM eclipse-temurin:17-jre-alpine
LABEL maintainer="antigravity_report_engine"
WORKDIR /app

# 设置容器标准时间为上海
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 从第二个 maven 阶段的 target 目录，提取最终打好包的 jar (干净无污染)
COPY --from=backend-builder /app/target/report-engine-*.jar /app/report-engine.jar

EXPOSE 8080

ENV JAVA_OPTS="-Xms512m -Xmx512m -Djava.security.egd=file:/dev/./urandom"
ENV SPRING_PROFILES_ACTIVE="prod"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/report-engine.jar"]
