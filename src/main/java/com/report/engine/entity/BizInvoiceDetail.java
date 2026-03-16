package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("biz_invoice_detail")
public class BizInvoiceDetail {
    private String bizInvoiceDetail;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long projectId;

    /**
     * 开票归属部门
     */
    private Long deptId;

    /**
     * 开票日期/入账日期
     */
    private LocalDateTime invoiceDate;

    /**
     * 含税开票金额
     */
    private BigDecimal invoiceAmount;

    /**
     * GAAP 确认确认结转收入
     */
    private BigDecimal gaapAmount;

    private LocalDateTime createTime;

}
