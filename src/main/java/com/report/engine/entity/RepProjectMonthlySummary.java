package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("rep_project_monthly_summary")
public class RepProjectMonthlySummary {
    private String repProjectMonthlySummary;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long projectId;

    private Integer dataYear;

    private Integer dataMonth;

    /**
     * 冗余: 项目类型
     */
    private Integer projectType;

    /**
     * 冗余: 当月结算税率
     */
    private BigDecimal taxRate;

    /**
     * 当月开票收入
     */
    private BigDecimal monthlyInvoiceAmount;

    /**
     * 当月不含税开票收入
     */
    private BigDecimal monthlyTaxFreeInvoice;

    /**
     * 当月GAAP收入
     */
    private BigDecimal monthlyGaapAmount;

    /**
     * 当月正式人力成本
     */
    private BigDecimal monthlyFormalHrCost;

    /**
     * 当月外包人力成本
     */
    private BigDecimal monthlyOutsourceHrCost;

    /**
     * 当月运营成本分摊
     */
    private BigDecimal monthlyOperationCost;

    /**
     * 当月报销费用
     */
    private BigDecimal monthlyExpenseCost;

    /**
     * 当月总成本 (人力+运营+报销)
     */
    private BigDecimal monthlyTotalCost;

    /**
     * ITD正式人力成本
     */
    private BigDecimal itdFormalHrCost;

    /**
     * ITD外包人力成本
     */
    private BigDecimal itdOutsourceHrCost;

    /**
     * ITD运营成本
     */
    private BigDecimal itdOperationCost;

    /**
     * ITD报销费用
     */
    private BigDecimal itdExpenseCost;

    /**
     * ITD总成本
     */
    private BigDecimal itdTotalCost;

    /**
     * ETC正式人力成本
     */
    private BigDecimal etcFormalHrCost;

    /**
     * ETC外包人力成本
     */
    private BigDecimal etcOutsourceHrCost;

    /**
     * ETC运营成本
     */
    private BigDecimal etcOperationCost;

    /**
     * ETC报销费用
     */
    private BigDecimal etcExpenseCost;

    /**
     * ETC总成本
     */
    private BigDecimal etcTotalCost;

    /**
     * EAC总成本
     */
    private BigDecimal eacTotalCost;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

}
