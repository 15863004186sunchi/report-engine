# Report Engine (部门报表与财务数据聚合引擎)

本项目基于现代化的前后端分离架构（Spring Boot 3 + Vue 3），旨在解决跨事业部项目全生命周期财务成本核算及数据可视化的需求。

## 🌟 核心功能

1. **复杂成本模型核算**：从海量底层流水（工时、报销、外包费用）中聚合计算出交付、售前及内部类型项目的 **ITD (至今实际值)**、**ETC (预估后续)** 和 **EAC (预估总额)** 成本。
2. **毛利率公式引擎**：支持动态计算以 GAAP（企业会计准则）和开票收入为基准的毛利率A、毛利率B对比。
3. **ETL调度中心集成**：深度集成 XXL-JOB 定时任务框架，实现夜间报表维表宽表跑批聚合，支持大数据量下的防 OOM 数据拆洗。
4. **BI数据大屏UI**：内置基于 ECharts 和 Vue3 的响应式分析看板，实现趋势柱状图与明细列表联动。

## 📁 工程目录结构

```text
report-engine/
├── src/main/java          # Spring Boot 后端源码
│   ├── controller         # API 接口入口
│   ├── entity             # MySQL 映射实体层
│   ├── job                # XXL-JOB 定时任务执行器
│   ├── mapper             # MyBatis-Plus 数据访问层
│   └── service            # 复杂公式引擎及数据拉取服务
├── src/main/resources     # Spring 配置文件 & Mapper XML
├── frontend/              # Vue3 前端工程
│   ├── src/views          # 报表大屏组件 (Dashboard.vue)
│   ├── package.json       # Node.js 依赖配置
│   └── vite.config.ts     # Vite 本地代理与打包配置
├── schema.sql             # 系统 MySQL 数据库建表 DDL
├── Dockerfile             # 后端应用镜像打包描述文件
└── docker-compose.yml     # 测试/生产环境容器化编排脚本文档
```

## 🛠️ 技术栈清单

*   **Backend**: Java 17, Spring Boot 3.2, MyBatis-Plus, Maven 3.x
*   **Database**: MySQL 8.0
*   **Scheduling**: XXL-JOB 2.4.0
*   **Frontend**: Vue.js 3, Vite, TypeScript, ECharts 5 
*   **DevOps**: Docker, Docker Compose

详细开发指导请参考内置的 `开发指导文档.md`，部署上线指南请查看 `DEPLOYMENT.md`。
