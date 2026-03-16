package com.report.engine.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.report.engine.entity.BizExpenseDetail;
import com.report.engine.entity.BizInvoiceDetail;
import com.report.engine.entity.BizTimesheetDetail;
import com.report.engine.entity.SysProject;
import com.report.engine.mapper.BizExpenseDetailMapper;
import com.report.engine.mapper.BizInvoiceDetailMapper;
import com.report.engine.mapper.BizTimesheetDetailMapper;
import com.report.engine.mapper.SysProjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 跨微服务/底层流水表的 数据抓取提取服务
 * 封装原始明细查询，提供给ETL Job使用
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DataLoaderService {

    private final BizTimesheetDetailMapper timesheetMapper;
    private final BizExpenseDetailMapper expenseMapper;
    private final BizInvoiceDetailMapper invoiceMapper;
    private final SysProjectMapper projectMapper;

    /**
     * 获取指定时间范围内的工时变动明细
     */
    public List<BizTimesheetDetail> fetchTimesheets(LocalDate startDate, LocalDate endDate) {
        log.info("Fetching timesheets between {} and {}", startDate, endDate);
        QueryWrapper<BizTimesheetDetail> query = new QueryWrapper<>();
        query.ge("work_date", startDate)
             .le("work_date", endDate);
        return timesheetMapper.selectList(query);
    }

    /**
     * 获取指定时间范围内的报销及运营成本明细
     */
    public List<BizExpenseDetail> fetchExpenses(LocalDate startDate, LocalDate endDate) {
        log.info("Fetching expenses between {} and {}", startDate, endDate);
        QueryWrapper<BizExpenseDetail> query = new QueryWrapper<>();
        query.ge("expense_date", startDate)
             .le("expense_date", endDate);
        return expenseMapper.selectList(query);
    }

    /**
     * 获取指定时间范围内的开票认款明细
     */
    public List<BizInvoiceDetail> fetchInvoices(LocalDate startDate, LocalDate endDate) {
        log.info("Fetching invoices between {} and {}", startDate, endDate);
        QueryWrapper<BizInvoiceDetail> query = new QueryWrapper<>();
        query.ge("invoice_date", startDate)
             .le("invoice_date", endDate);
        return invoiceMapper.selectList(query);
    }

    /**
     * 获取系统全量项目配置(通常项目量不大，可放本地缓存)
     */
    public List<SysProject> fetchAllProjects() {
        return projectMapper.selectList(null);
    }
}
