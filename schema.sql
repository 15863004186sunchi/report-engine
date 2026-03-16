-- --------------------------------------------------------
-- 部门报表数据引擎数据库构建脚本 (schema.sql)
-- 包含：维度表、基础流水表(模拟)、运营手工录入表、汇总宽表
-- --------------------------------------------------------

-- 1. 维度配置表
DROP TABLE IF EXISTS `sys_department`;
CREATE TABLE `sys_department` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `name` VARCHAR(100) NOT NULL COMMENT '部门名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父级部门ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门字典表';

DROP TABLE IF EXISTS `sys_project`;
CREATE TABLE `sys_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `name` VARCHAR(255) NOT NULL COMMENT '项目名称',
  `type` TINYINT NOT NULL COMMENT '项目属性类型: 0交付项目/1售前项目/2内部项目/3运营类项目',
  `tax_rate` DECIMAL(5,4) DEFAULT 0.0000 COMMENT '项目税率 (如0.0600代表6%)',
  `dept_id` BIGINT NOT NULL COMMENT '所属主责部门ID',
  `status` TINYINT DEFAULT 1 COMMENT '项目状态: 0结束/1进行中',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目信息表';

-- 2. 运营手工录入表 (Plan等指标)
DROP TABLE IF EXISTS `rep_manual_target`;
CREATE TABLE `rep_manual_target` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `dept_id` BIGINT NOT NULL COMMENT '部门ID',
  `data_year` INT NOT NULL COMMENT '年份 (如 2024)',
  `data_month` INT NOT NULL COMMENT '月份 (1-12)',
  `gaap_target` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'GAAP 收入目标',
  `gross_margin_target` DECIMAL(5,4) DEFAULT 0.0000 COMMENT '目标毛利率',
  `est_gaap_revenue` DECIMAL(15,2) DEFAULT 0.00 COMMENT '预估 GAAP 收入',
  `annual_contract_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年度已签约合同额',
  `annual_performance_target` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年度签约绩效目标',
  `plan_adjusted_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '最新调整的 PLAN 成本总额',
  `plan_formal_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '最新调整的 PLAN 正式人力成本',
  `plan_outsource_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '最新调整的 PLAN 外包人力成本',
  `plan_operation_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '最新调整的 PLAN 运营成本',
  `plan_expense_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '最新调整的 PLAN 报销费用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dept_year_month` (`dept_id`, `data_year`, `data_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运营手工录入目标表';

-- 3. 基础明细流水表 (模拟业务侧提供的数据)
DROP TABLE IF EXISTS `biz_timesheet_detail`;
CREATE TABLE `biz_timesheet_detail` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `dept_id` BIGINT NOT NULL COMMENT '产生工时人员的归属部门ID',
  `project_id` BIGINT NOT NULL COMMENT '记入的项目ID',
  `work_date` DATE NOT NULL COMMENT '工时发生日期',
  `work_hours` DECIMAL(5,2) NOT NULL COMMENT '投入工时',
  `user_type` TINYINT NOT NULL COMMENT '人员类型: 0正式员工/1外包员工',
  `daily_rate` DECIMAL(15,2) NOT NULL COMMENT '人员单价费率(月薪/21.75 或 外包单价/当月工作日)',
  `is_estimated` TINYINT DEFAULT 0 COMMENT '是否为预估工时: 0实际/1预估(用于计算ETC)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_project_date` (`project_id`, `work_date`),
  KEY `idx_dept_date` (`dept_id`, `work_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人员工时及费率明细流水表';

DROP TABLE IF EXISTS `biz_expense_detail`;
CREATE TABLE `biz_expense_detail` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `project_id` BIGINT NOT NULL,
  `expense_date` DATE NOT NULL COMMENT '费用发生/归属日期',
  `expense_amount` DECIMAL(15,2) NOT NULL COMMENT '报销或运营成本金额',
  `expense_category` TINYINT NOT NULL COMMENT '费用分类: 1报销费用/2其他运营成本',
  `is_estimated` TINYINT DEFAULT 0 COMMENT '是否为预估费用: 0实际/1预估(用于计算ETC)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_project_date` (`project_id`, `expense_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目报销及其它费用流水表';

DROP TABLE IF EXISTS `biz_invoice_detail`;
CREATE TABLE `biz_invoice_detail` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `project_id` BIGINT NOT NULL,
  `dept_id` BIGINT NOT NULL COMMENT '开票归属部门',
  `invoice_date` DATE NOT NULL COMMENT '开票日期/入账日期',
  `invoice_amount` DECIMAL(15,2) NOT NULL COMMENT '含税开票金额',
  `gaap_amount` DECIMAL(15,2) NOT NULL COMMENT 'GAAP 确认确认结转收入',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_project_date` (`project_id`, `invoice_date`),
  KEY `idx_dept_date` (`dept_id`, `invoice_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目开票及GAAP收入明细';


-- 4. 核心：报表聚合宽表 (ETL产出目标库表)

-- 4.1 项目月度汇总宽表
DROP TABLE IF EXISTS `rep_project_monthly_summary`;
CREATE TABLE `rep_project_monthly_summary` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `project_id` BIGINT NOT NULL,
  `data_year` INT NOT NULL,
  `data_month` INT NOT NULL,
  `project_type` TINYINT NOT NULL COMMENT '冗余: 项目类型',
  `tax_rate` DECIMAL(5,4) NOT NULL COMMENT '冗余: 当月结算税率',
  -- 收入类
  `monthly_invoice_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月开票收入',
  `monthly_tax_free_invoice` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月不含税开票收入',
  `monthly_gaap_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月GAAP收入',
  -- 成本类 (本月发生)
  `monthly_formal_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月正式人力成本',
  `monthly_outsource_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月外包人力成本',
  `monthly_operation_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月运营成本分摊',
  `monthly_expense_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月报销费用',
  `monthly_total_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月总成本 (人力+运营+报销)',
  -- 累计类 (ITD 截至当前月末累计)
  `itd_formal_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ITD正式人力成本',
  `itd_outsource_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ITD外包人力成本',
  `itd_operation_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ITD运营成本',
  `itd_expense_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ITD报销费用',
  `itd_total_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ITD总成本',
  -- 预测类 (ETC)
  `etc_formal_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ETC正式人力成本',
  `etc_outsource_hr_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ETC外包人力成本',
  `etc_operation_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ETC运营成本',
  `etc_expense_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ETC报销费用',
  `etc_total_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'ETC总成本',
  -- EAC (ITD + ETC)
  `eac_total_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'EAC总成本',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_project_year_month` (`project_id`, `data_year`, `data_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目月度汇总宽表 (ETL产物)';

-- 4.2 部门核心指标汇总宽表 (含当年与去年同期累计，极大便利前端直接查图)
DROP TABLE IF EXISTS `rep_department_monthly_summary`;
CREATE TABLE `rep_department_monthly_summary` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `dept_id` BIGINT NOT NULL,
  `data_year` INT NOT NULL,
  `data_month` INT NOT NULL,
  -- 月度当月发生指标
  `monthly_invoice_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门开票收入汇总',
  `monthly_tax_free_invoice` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门不含税开票收入汇总',
  `monthly_gaap_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门GAAP收入汇总',
  `monthly_delivery_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门实施成本(交付类型项目)',
  `monthly_presales_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门售前成本(售前类型项目)',
  `monthly_other_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '当月部门其它成本(内部/运营类型项目中属本部门人员产生)',
  -- 月度利润率
  `monthly_gross_margin_a_invoice` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '当月毛利率A(基于不含税开票)',
  `monthly_gross_margin_a_gaap` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '当月毛利率A(基于GAAP)',
  `monthly_gross_margin_b_invoice` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '当月毛利率B(基于不含税开票)',
  `monthly_gross_margin_b_gaap` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '当月毛利率B(基于GAAP)',
  -- 本年累计(ITD)核心指标
  `ytd_invoice_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计开票收入(Year-to-date ITD)',
  `ytd_tax_free_invoice` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计不含税开票收入',
  `ytd_gaap_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计GAAP收入',
  `ytd_delivery_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计实施成本',
  `ytd_presales_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计售前成本',
  `ytd_other_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '本年累计其他成本',
  `ytd_gross_margin_a_invoice` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '本年ITD毛利率A(开票)',
  `ytd_gross_margin_a_gaap` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '本年ITD毛利率A(GAAP)',
  `ytd_gross_margin_b_invoice` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '本年ITD毛利率B(开票)',
  `ytd_gross_margin_b_gaap` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '本年ITD毛利率B(GAAP)',
  -- 去年累计(Last YTD)核心指标 (用于算同比)
  `lytd_invoice_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '去年同期累计开票',
  `lytd_gaap_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '去年同期累计GAAP',
  `lytd_delivery_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '去年同期累计实施成本',
  -- 预估类汇总
  `est_monthly_delivery_cost` DECIMAL(15,2) DEFAULT 0.00 COMMENT '预估实施成本汇总(ETC转化)',
  `est_monthly_gross_margin_a_gaap` DECIMAL(7,4) DEFAULT 0.0000 COMMENT '预估毛利率A(基于预估GAAP及预估实施成本)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dept_year_month` (`dept_id`, `data_year`, `data_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门核心指标汇总月度宽表 (给Dashboard查图用)';

-- 初始化一些测试数据
INSERT INTO `sys_department` (`id`, `name`) VALUES (1, '智慧金融事业部'), (2, '创新发展部'), (3, 'SAAS平台技术部'), (4, 'SAAS平台业务部');
