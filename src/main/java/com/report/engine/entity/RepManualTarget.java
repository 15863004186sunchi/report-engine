package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("rep_manual_target")
public class RepManualTarget {
    private String repManualTarget;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 部门ID
     */
    private Long deptId;

    /**
     * 年份 (如 2024)
     */
    private Integer dataYear;

    /**
     * 月份 (1-12)
     */
    private Integer dataMonth;

    /**
     * GAAP 收入目标
     */
    private BigDecimal gaapTarget;

    /**
     * 目标毛利率
     */
    private BigDecimal grossMarginTarget;

    /**
     * 预估 GAAP 收入
     */
    private BigDecimal estGaapRevenue;

    /**
     * 本年度已签约合同额
     */
    private BigDecimal annualContractAmount;

    /**
     * 本年度签约绩效目标
     */
    private BigDecimal annualPerformanceTarget;

    /**
     * 最新调整的 PLAN 成本总额
     */
    private BigDecimal planAdjustedCost;

    /**
     * 最新调整的 PLAN 正式人力成本
     */
    private BigDecimal planFormalHrCost;

    /**
     * 最新调整的 PLAN 外包人力成本
     */
    private BigDecimal planOutsourceCost;

    /**
     * 最新调整的 PLAN 运营成本
     */
    private BigDecimal planOperationCost;

    /**
     * 最新调整的 PLAN 报销费用
     */
    private BigDecimal planExpenseCost;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

}
