package com.report.engine.service;

import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 部门报表核心财务计算引擎
 * 封装各种复杂的利润率、指标计算逻辑
 */
@Service
public class FormulaCalculator {

    private static final int SCALE = 4; // 计算保留4位小数

    /**
     * 安全的加法
     */
    public BigDecimal safeAdd(BigDecimal a, BigDecimal b) {
        if (a == null) a = BigDecimal.ZERO;
        if (b == null) b = BigDecimal.ZERO;
        return a.add(b);
    }

    /**
     * 安全的减法: a - b
     */
    public BigDecimal safeSubtract(BigDecimal a, BigDecimal b) {
        if (a == null) a = BigDecimal.ZERO;
        if (b == null) b = BigDecimal.ZERO;
        return a.subtract(b);
    }

    /**
     * 安全的除法: a / b
     */
    public BigDecimal safeDivide(BigDecimal a, BigDecimal b) {
        if (a == null) a = BigDecimal.ZERO;
        if (b == null || b.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO; // 防止除0异常，业务上除0通常意味着基数为0，返回0即可
        }
        return a.divide(b, SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 计算 不含税金额
     * = 含税金额 / (1 + 税率)
     */
    public BigDecimal calcTaxFreeAmount(BigDecimal amount, BigDecimal taxRate) {
        if (taxRate == null) taxRate = BigDecimal.ZERO;
        BigDecimal divisor = BigDecimal.ONE.add(taxRate);
        return safeDivide(amount, divisor).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 计算 毛利率 A (开票收入维)
     * = 1 - (实施成本 / 不含税开票收入)
     */
    public BigDecimal calcGrossMarginAByInvoice(BigDecimal deliveryCost, BigDecimal taxFreeInvoiceSum) {
        if (taxFreeInvoiceSum == null || taxFreeInvoiceSum.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        BigDecimal costRatio = safeDivide(deliveryCost, taxFreeInvoiceSum);
        return BigDecimal.ONE.subtract(costRatio).setScale(SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 计算 毛利率 A (GAAP收入维)
     * = 1 - (实施成本 / GAAP收入)
     * 注意：需求中提到 "目标毛利率为运营手动录入", 但实际达成毛利率依旧依据公式计算
     */
    public BigDecimal calcGrossMarginAByGaap(BigDecimal deliveryCost, BigDecimal gaapSum) {
        if (gaapSum == null || gaapSum.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        BigDecimal costRatio = safeDivide(deliveryCost, gaapSum);
        return BigDecimal.ONE.subtract(costRatio).setScale(SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 计算 毛利率 B (开票收入维)
     * = 1 - ((实施成本 + 售前成本 + 部门其他成本) / 不含税开票收入)
     */
    public BigDecimal calcGrossMarginBByInvoice(BigDecimal deliveryCost, BigDecimal presalesCost, BigDecimal otherCost, BigDecimal taxFreeInvoiceSum) {
        if (taxFreeInvoiceSum == null || taxFreeInvoiceSum.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        BigDecimal totalCost = safeAdd(safeAdd(deliveryCost, presalesCost), otherCost);
        BigDecimal costRatio = safeDivide(totalCost, taxFreeInvoiceSum);
        return BigDecimal.ONE.subtract(costRatio).setScale(SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 计算 毛利率 B (GAAP收入维)
     * = 1 - ((实施成本 + 售前成本 + 部门其他成本) / GAAP收入)
     */
    public BigDecimal calcGrossMarginBByGaap(BigDecimal deliveryCost, BigDecimal presalesCost, BigDecimal otherCost, BigDecimal gaapSum) {
        if (gaapSum == null || gaapSum.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        BigDecimal totalCost = safeAdd(safeAdd(deliveryCost, presalesCost), otherCost);
        BigDecimal costRatio = safeDivide(totalCost, gaapSum);
        return BigDecimal.ONE.subtract(costRatio).setScale(SCALE, RoundingMode.HALF_UP);
    }
    
    /**
     * 计算 同比增长率
     * = (今年数据 - 去年数据) / |去年数据|
     */
    public BigDecimal calcYearOnYearGrowth(BigDecimal currentYear, BigDecimal lastYear) {
        if (currentYear == null) currentYear = BigDecimal.ZERO;
        if (lastYear == null || lastYear.compareTo(BigDecimal.ZERO) == 0) {
            return currentYear.compareTo(BigDecimal.ZERO) > 0 ? BigDecimal.ONE : BigDecimal.ZERO; 
            // 如果去年为0，今年有值则记为100%增长(或者可按业务需求定义)
        }
        BigDecimal diff = currentYear.subtract(lastYear);
        BigDecimal absLastYear = lastYear.abs();
        return safeDivide(diff, absLastYear).setScale(SCALE, RoundingMode.HALF_UP);
    }
}
