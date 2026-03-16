package com.report.engine.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.report.engine.entity.RepDepartmentMonthlySummary;
import com.report.engine.mapper.RepDepartmentMonthlySummaryMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/report")
@RequiredArgsConstructor
public class ReportController {

    private final RepDepartmentMonthlySummaryMapper deptSummaryMapper;

    /**
     * 获取指定年份和部门的月度趋势比对数据 (支持ECharts格式)
     * GET /api/report/trend/monthly?year=2024&deptId=1
     */
    @GetMapping("/trend/monthly")
    public Result<ChartData> getMonthlyTrend(@RequestParam Integer year, 
                                             @RequestParam Long deptId) {
        
        QueryWrapper<RepDepartmentMonthlySummary> query = new QueryWrapper<>();
        query.eq("data_year", year)
             .eq("dept_id", deptId)
             .orderByAsc("data_month");
             
        List<RepDepartmentMonthlySummary> records = deptSummaryMapper.selectList(query);
        
        // 组装供ECharts使用的结构
        ChartData chartData = new ChartData();
        List<String> xAxis = new ArrayList<>();
        List<BigDecimal> actualGaapSeries = new ArrayList<>();
        List<BigDecimal> estGaapSeries = new ArrayList<>();
        
        for (RepDepartmentMonthlySummary r : records) {
            xAxis.add(r.getDataMonth() + "月");
            actualGaapSeries.add(r.getMonthlyGaapAmount() != null ? r.getMonthlyGaapAmount() : BigDecimal.ZERO);
            // 这里为了示例，预估值先写死或者复用
            estGaapSeries.add(r.getEstMonthlyDeliveryCost() != null ? r.getEstMonthlyDeliveryCost() : BigDecimal.ZERO);
        }
        
        chartData.setXAxis(xAxis);
        
        List<ChartSeries> seriesList = new ArrayList<>();
        seriesList.add(new ChartSeries("预估收入", "bar", estGaapSeries));
        seriesList.add(new ChartSeries("实际收入", "bar", actualGaapSeries));
        chartData.setSeries(seriesList);

        return Result.success(chartData);
    }

    /**
     * 获取横向多部门比对折线图数据
     * GET /api/report/compare/departments?year=2024&metric=gaap
     */
    @GetMapping("/compare/departments")
    public Result<ChartData> getDepartmentCompare(@RequestParam Integer year,
                                                  @RequestParam String metric) {
        // 示例：此处可基于业务动态去查多个部门，然后给每个部门构建一条线(Series)
        return Result.success(new ChartData());
    }
    
    // --- 通用返回结果封装体 ---
    
    @Data
    public static class ChartData {
        private List<String> xAxis;
        private List<ChartSeries> series;
    }
    
    @Data
    public static class ChartSeries {
        private String name;
        private String type;
        private List<BigDecimal> data;
        
        public ChartSeries(String name, String type, List<BigDecimal> data) {
            this.name = name;
            this.type = type;
            this.data = data;
        }
    }

    @Data
    public static class Result<T> {
        private Integer code;
        private String msg;
        private T data;

        public static <T> Result<T> success(T data) {
            Result<T> r = new Result<>();
            r.setCode(200);
            r.setMsg("success");
            r.setData(data);
            return r;
        }
    }
}
