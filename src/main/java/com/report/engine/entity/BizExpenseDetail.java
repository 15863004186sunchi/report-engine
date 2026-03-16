package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("biz_expense_detail")
public class BizExpenseDetail {
    private String bizExpenseDetail;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long projectId;

    /**
     * 费用发生/归属日期
     */
    private LocalDateTime expenseDate;

    /**
     * 报销或运营成本金额
     */
    private BigDecimal expenseAmount;

    /**
     * 费用分类: 1报销费用/2其他运营成本
     */
    private Integer expenseCategory;

    /**
     * 是否为预估费用: 0实际/1预估(用于计算ETC)
     */
    private Integer isEstimated;

    private LocalDateTime createTime;

}
