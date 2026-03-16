package com.report.engine.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("sys_project")
public class SysProject {
    private String sysProject;

    /**
     * 项目ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 项目名称
     */
    private String name;

    /**
     * 项目属性类型: 0交付项目/1售前项目/2内部项目/3运营类项目
     */
    private Integer type;

    /**
     * 项目税率 (如0.0600代表6%)
     */
    private BigDecimal taxRate;

    /**
     * 所属主责部门ID
     */
    private Long deptId;

    /**
     * 项目状态: 0结束/1进行中
     */
    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

}
