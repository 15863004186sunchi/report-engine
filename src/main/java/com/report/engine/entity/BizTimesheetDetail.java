package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("biz_timesheet_detail")
public class BizTimesheetDetail {
    private String bizTimesheetDetail;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    /**
     * 产生工时人员的归属部门ID
     */
    private Long deptId;

    /**
     * 记入的项目ID
     */
    private Long projectId;

    /**
     * 工时发生日期
     */
    private LocalDateTime workDate;

    /**
     * 投入工时
     */
    private BigDecimal workHours;

    /**
     * 人员类型: 0正式员工/1外包员工
     */
    private Integer userType;

    /**
     * 人员单价费率(月薪/21.75 或 外包单价/当月工作日)
     */
    private BigDecimal dailyRate;

    /**
     * 是否为预估工时: 0实际/1预估(用于计算ETC)
     */
    private Integer isEstimated;

    private LocalDateTime createTime;

}
