# 使用官方 Java 17 基础镜像
FROM openjdk:17-jdk-slim

# 作者/维护者信息
LABEL maintainer="antigravity_report_engine"

# 设置工作目录
WORKDIR /app

# 将构建好的 jar 包复制到镜像内部 (假设 maven build 输出为 target/report-engine-0.0.1-SNAPSHOT.jar)
COPY target/report-engine-*.jar /app/report-engine.jar

# 暴露端口，和 application.yml 保持一致
EXPOSE 8080

# 启动参数配置，可根据云主机内存调整 Xms 和 Xmx
ENV JAVA_OPTS="-Xms512m -Xmx512m -Djava.security.egd=file:/dev/./urandom"
ENV SPRING_PROFILES_ACTIVE="prod"

# 注意：生产环境下，应通过环境变量或 docker-compose 挂载方式传入实际的 datasource URL/username/password。
# 这里 ENTRYPOINT 保证容器启动时执行 jar。
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/report-engine.jar"]
