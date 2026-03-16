package com.report.engine.job;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.report.engine.entity.RepProjectMonthlySummary;
import com.report.engine.entity.RepDepartmentMonthlySummary;
import com.report.engine.mapper.RepProjectMonthlySummaryMapper;
import com.report.engine.mapper.RepDepartmentMonthlySummaryMapper;
import com.report.engine.service.DataLoaderService;
import com.report.engine.service.FormulaCalculator;
import com.xxl.job.core.context.XxlJobHelper;
import com.xxl.job.core.handler.annotation.XxlJob;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * XXL-JOB 定时任务处理器: 夜间核心报表及指标计算引擎
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class EtlJobHandler {

    private final DataLoaderService dataLoaderService;
    private final FormulaCalculator formulaCalculator;
    private final RepProjectMonthlySummaryMapper projectMonthlyMapper;
    private final RepDepartmentMonthlySummaryMapper departmentMonthlyMapper;

    /**
     * 每天凌晨执行，聚合生成项目及部门月度报表宽表数据
     * 可以在调度中心传入参数指定跑批日期范围，否则默认跑批 yesterday 的归属月份
     */
    @XxlJob("monthlyReportCalculateJob")
    public void calculateMonthlyReport() {
        String param = XxlJobHelper.getJobParam();
        LocalDate targetDate = LocalDate.now().minusDays(1); // 默认跑昨天
        if (param != null && !param.trim().isEmpty()) {
            try {
                targetDate = LocalDate.parse(param);
            } catch (Exception e) {
                XxlJobHelper.log("Param parsing error, fallback to yesterday: " + e.getMessage());
            }
        }
        
        int year = targetDate.getYear();
        int month = targetDate.getMonthValue();
        XxlJobHelper.log("=== Start ETL processing for Year: {}, Month: {} ===", year, month);

        try {
            // ==========================================
            // Step 1: 拉取底层变动明细数据
            // ==========================================
            XxlJobHelper.log("Step 1: Fetching raw data from Data Loader...");
            // (模拟拉取本月第一天到最后一天的流水数据，或根据业务仅增量拉取变动项目并重新核算整个项目ITD)
            LocalDate startDate = targetDate.withDayOfMonth(1);
            LocalDate endDate = targetDate.withDayOfMonth(targetDate.lengthOfMonth());
            
            // 为了防止 OOM，通常这里是查出本月有流水变动的 projectIds，然后分组循环处理
            // 因篇幅有限，此处仅演示核心结构与存储落地逻辑
            
            // ==========================================
            // Step 2: 计算项目维度宽表
            // ==========================================
            XxlJobHelper.log("Step 2: Calculating Project Level Summary...");
            List<RepProjectMonthlySummary> projSumList = new ArrayList<>();
            // (循环处理每个项目，通过 formulaCalculator 计算ITD, ETC, 毛利，并封装进集合)
            // projSumList.add(calcProj...)
            
            if (!projSumList.isEmpty()) {
                // TODO: 批量Upsert项目宽表 (可用预先配置好的批量插入服务)
                // mybatisPlusService.saveOrUpdateBatch(projSumList)
                XxlJobHelper.log("Saved {} project summary records.", projSumList.size());
            }

            // ==========================================
            // Step 3: 计算部门维度核心看板宽表 (基于图2需求)
            // ==========================================
            XxlJobHelper.log("Step 3: Calculating Department Level Summary...");
            List<RepDepartmentMonthlySummary> deptSumList = new ArrayList<>();
            // 部门的数据通常是在完成 Step 2 之后，利用项目的汇聚结果，再次按照 Dept_ID 分组汇总，
            // 加上 manual_target 表中运营手录的 GAAP 目标信息，最终计算部门毛利率 A、毛利率B
            
            if (!deptSumList.isEmpty()) {
                // TODO: 批量Upsert部门看板宽表
                // mybatisPlusService.saveOrUpdateBatch(deptSumList)
                XxlJobHelper.log("Saved {} department summary records.", deptSumList.size());
            }

            XxlJobHelper.log("=== ETL processing finished successfully! ===");
            XxlJobHelper.handleSuccess("Calculate Success.");
            
        } catch (Exception e) {
            log.error("ETL Job Failed", e);
            XxlJobHelper.log("Exception: " + e.getMessage());
            XxlJobHelper.handleFail("Calculate Failed: " + e.getMessage());
        }
    }
}
