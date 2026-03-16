# Report Engine 系统部署指南

本文档介绍如何在单节点服务器（如你的云主机）上快速使用 `docker-compose` 或常规方式将包含前后端的服务部署上线。

## 1. 部署架构说明

本项目采取通过 `docker-compose.yml` 统一部署以下三个核心组件服务的模式：
1. **MySQL 8.0 数据库**：存放基础流水明细及算好的聚合宽表。
2. **XXL-JOB Admin**：开源中国开源社区主流的任务调度管控台。
3. **Report Engine APP (Spring Boot)**：提供运算逻辑服务及前端 API 接口。

*(注：前端 Vue 项目在此架构中可以利用 Nginx 另行静态托管，也可打包进 Java 的 static 目录由 Spring 容器一并伺服)*

---

## 2. 准备工作

请确保您的云主机已经安装了基础环境：
- `Docker` (建议 20.10.x 及以上)
- `Docker Compose` (建议 2.x 版本)
- `Java 17` 及 `Maven 3.x`（若您要在云主机上就地编译后端代码）

## 3. 服务端一键容器化部署

### 3.1 前端代码编译集成 (可选选项A)

如果您不想单独起一个 Nginx，您可以把前端工程打包塞进 Java `resources/static` 目录中：

```bash
cd frontend
npm install
npm run build 
# 将打包出的 /dist 目录内的所有文件复制到后端项目的 src/main/resources/static/ 里
cp -r dist/* ../src/main/resources/static/
cd ..
```

### 3.2 编译后端生成 jar 包

请回到工程根目录执行 Maven 打包命令：
```bash
mvn clean package -DskipTests
```
成功后，在 `target/` 目录下会生成名为 `report-engine-*.jar` 的最终运行包。

### 3.3 拉起整个中间件+应用环境

确保目录下的 `schema.sql`、`Dockerfile`、`docker-compose.yml` 在同一级并完整。配置好数据库密码后，执行：

```bash
docker-compose up -d --build
```

此命令将会：
1. 自动拉取 MySQL 相关镜像。
2. 启动时执行 `schema.sql` 完成数据库及表结构的初始化。
3. 拉起 XXL-JOB-ADMIN 管理后台。
4. 基于 `Dockerfile`，将您编译好的 jar 包装入 Java 运行环境，并向容器内暴露 8080 端口。

如果需要查看后端启动日志是否报错：
```bash
docker-compose logs -f report-engine
```

## 4. 后续系统访问指引

*   **业务大屏访问**：直接在浏览器输入 `http://<云主机外网IP>:8080`（若配置了集成静态资源）即可查看 Vue Dashboard。
*   **后端 API 测试**: 可以调用 `http://<云主机外网IP>:8080/api/report/trend/monthly?year=2024&deptId=1` 体验 JSON 响应效果。
*   **定时任务调度后台**：访问 XXL-JOB 管理页：`http://<云主机外网IP>:8085/xxl-job-admin` 。

## 5. 高频故障排查
*   **启动时 JVM 报错 "UnsupportedClassVersionError"**: 核心原因是编译器 JDK 版本与运行环境不一致。本项目强依赖于 **Java 17**。请检查 `Dockerfile` 中的基础镜像以及 `pom.xml` 配置！
*   **首次启动报表无数据**: 夜间的定时任务还没有到触发时间。请登录 XXL-JOB Admin 后台，找到 `monthlyReportCalculateJob` 这个任务标识符（JobHandler），点击 "执行一次"。
