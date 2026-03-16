package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("rep_department_monthly_summary")
public class RepDepartmentMonthlySummary {
    private String repDepartmentMonthlySummary;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long deptId;

    private Integer dataYear;

    private Integer dataMonth;

    /**
     * 当月部门开票收入汇总
     */
    private BigDecimal monthlyInvoiceAmount;

    /**
     * 当月部门不含税开票收入汇总
     */
    private BigDecimal monthlyTaxFreeInvoice;

    /**
     * 当月部门GAAP收入汇总
     */
    private BigDecimal monthlyGaapAmount;

    /**
     * 当月部门实施成本(交付类型项目)
     */
    private BigDecimal monthlyDeliveryCost;

    /**
     * 当月部门售前成本(售前类型项目)
     */
    private BigDecimal monthlyPresalesCost;

    /**
     * 当月部门其它成本(内部/运营类型项目中属本部门人员产生)
     */
    private BigDecimal monthlyOtherCost;

    /**
     * 当月毛利率A(基于不含税开票)
     */
    private BigDecimal monthlyGrossMarginAInvoice;

    /**
     * 当月毛利率A(基于GAAP)
     */
    private BigDecimal monthlyGrossMarginAGaap;

    /**
     * 当月毛利率B(基于不含税开票)
     */
    private BigDecimal monthlyGrossMarginBInvoice;

    /**
     * 当月毛利率B(基于GAAP)
     */
    private BigDecimal monthlyGrossMarginBGaap;

    /**
     * 本年累计开票收入(Year-to-date ITD)
     */
    private BigDecimal ytdInvoiceAmount;

    /**
     * 本年累计不含税开票收入
     */
    private BigDecimal ytdTaxFreeInvoice;

    /**
     * 本年累计GAAP收入
     */
    private BigDecimal ytdGaapAmount;

    /**
     * 本年累计实施成本
     */
    private BigDecimal ytdDeliveryCost;

    /**
     * 本年累计售前成本
     */
    private BigDecimal ytdPresalesCost;

    /**
     * 本年累计其他成本
     */
    private BigDecimal ytdOtherCost;

    /**
     * 本年ITD毛利率A(开票)
     */
    private BigDecimal ytdGrossMarginAInvoice;

    /**
     * 本年ITD毛利率A(GAAP)
     */
    private BigDecimal ytdGrossMarginAGaap;

    /**
     * 本年ITD毛利率B(开票)
     */
    private BigDecimal ytdGrossMarginBInvoice;

    /**
     * 本年ITD毛利率B(GAAP)
     */
    private BigDecimal ytdGrossMarginBGaap;

    /**
     * 去年同期累计开票
     */
    private BigDecimal lytdInvoiceAmount;

    /**
     * 去年同期累计GAAP
     */
    private BigDecimal lytdGaapAmount;

    /**
     * 去年同期累计实施成本
     */
    private BigDecimal lytdDeliveryCost;

    /**
     * 预估实施成本汇总(ETC转化)
     */
    private BigDecimal estMonthlyDeliveryCost;

    /**
     * 预估毛利率A(基于预估GAAP及预估实施成本)
     */
    private BigDecimal estMonthlyGrossMarginAGaap;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

}
