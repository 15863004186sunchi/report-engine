<template>
  <div class="dashboard">
    <!-- 头部：部门选择切换区 -->
    <div class="header">
      <div class="title">部门数据</div>
      <div class="search-bar">
        <input type="text" placeholder="搜索部门名称" />
        <button class="search-btn">搜索</button>
      </div>
    </div>
    
    <div class="dept-tabs">
      <div class="tab active">智慧金融事业部</div>
      <div class="tab">创新发展部</div>
      <div class="tab">SAAS平台技术部</div>
      <div class="tab">SAAS平台业务部</div>
      <div class="tab">长安新生</div>
    </div>

    <!-- 顶部数据卡片区 -->
    <div class="top-cards">
      <div class="card card-wide">
        <div class="meta">本年度已签合同额</div>
        <div class="value contract-val">9,690,000.00</div>
        <div class="progress-bar-container">
          <div class="progress-info">
            <span>本年度签约绩效目标: 20,000,000.00</span>
            <span class="pct">48%</span>
          </div>
          <div class="progress-bg"><div class="progress-fill" style="width: 48%;"></div></div>
        </div>
      </div>
      
      <div class="card card-small">
        <div class="meta">售前成本使用率</div>
        <div class="value">15%</div>
        <div class="progress-bar-container mt-auto">
          <div class="progress-info"><span class="pct">15%</span></div>
          <div class="progress-bg"><div class="progress-fill" style="width: 15%;"></div></div>
        </div>
      </div>

      <div class="card card-small bg-blue-tint">
        <div class="badge">ITD</div>
        <div class="value">8,386,593.41</div>
        <div class="meta">ITD (累计开票收入)</div>
      </div>
    </div>

    <!-- 中部主分析区 -->
    <div class="main-analysis">
      <!-- 左侧指标列表 -->
      <div class="metric-menu">
        <div class="menu-item active">开票收入</div>
        <div class="menu-item">GAAP收入</div>
        <div class="menu-item">项目实施成本</div>
        <div class="menu-item">毛利率A (开票收入)</div>
        <div class="menu-item">毛利率A (GAAP收入)</div>
        <div class="menu-item">项目售前成本</div>
        <div class="menu-item">部门其他成本</div>
        <div class="menu-item">毛利率B (开票收入)</div>
        <div class="menu-item">毛利率B (GAAP收入)</div>
      </div>

      <!-- 右侧图表及明细数据表 -->
      <div class="chart-section">
        <div class="chart-header">
          <h3>月度开票收入趋势图</h3>
          <div class="legend-custom">
            <span class="dot light-blue"></span> 预收入
            <span class="dot dark-blue"></span> 实际收入
          </div>
        </div>
        <!-- ECharts 渲染容器 (模拟柱状趋势图) -->
        <div class="echarts-container" ref="trendChartRef"></div>
        <div class="chart-footer">
           <button class="toggle-btn active">图表模式</button>
           <button class="toggle-btn">表格模式</button>
        </div>
      </div>

      <!-- 最新数据快速列表栏 (模拟右侧列表) -->
      <div class="data-list-sidebar">
        <div class="list-header">
          <span class="col">月份</span>
          <span class="col">数额</span>
        </div>
        <div class="list-row"><span>2024年01月</span><span>97,924.53</span></div>
        <div class="list-row"><span>2024年02月</span><span>206,534.97</span></div>
        <div class="list-row highlight"><span>2024年03月</span><span>951,254.60</span></div>
        <div class="list-row"><span>2024年04月</span><span>1,696,393.58</span></div>
        <!-- 截断显示更多 -->
      </div>
    </div>

    <!-- 底部部门对比趋势图区 -->
    <div class="bottom-compare">
      <div class="compare-box">
        <h4>GAAP收入</h4>
        <div class="echarts-mini" ref="compareChart1Ref"></div>
      </div>
      <div class="compare-box">
        <h4>毛利率A</h4>
        <div class="echarts-mini" ref="compareChart2Ref"></div>
      </div>
      <div class="compare-box">
        <h4>毛利率B</h4>
        <div class="echarts-mini" ref="compareChart3Ref"></div>
      </div>
    </div>
    
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
// import axios from 'axios'

// Echarts 实例 ref
const trendChartRef = ref<HTMLElement | null>(null)
const compareChart1Ref = ref<HTMLElement | null>(null)
const compareChart2Ref = ref<HTMLElement | null>(null)
const compareChart3Ref = ref<HTMLElement | null>(null)

let trendChart: echarts.ECharts | null = null;
let cChart1: echarts.ECharts | null = null;
let cChart2: echarts.ECharts | null = null;
let cChart3: echarts.ECharts | null = null;

// 初始化主趋势图
const initTrendChart = () => {
  if (!trendChartRef.value) return;
  trendChart = echarts.init(trendChartRef.value);
  const option = {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: [
      {
        type: 'category',
        data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
        axisTick: { alignWithLabel: true }
      }
    ],
    yAxis: [{ type: 'value' }],
    series: [
      {
        name: '预收入',
        type: 'bar',
        barWidth: '20%',
        itemStyle: { color: '#bce1fc' },
        data: [45, 45, 55, 60, 48, 78, 60, 50, 48, 45, 50, 42]
      },
      {
        name: '实际收入',
        type: 'bar',
        barWidth: '20%',
        itemStyle: { color: '#0d89ef' },
        data: [40, 42, 75, 48, 55, 60, 50, 40, 45, 30, 62, 28] // 模拟数据
      }
    ]
  };
  trendChart.setOption(option);
}

// 模拟多折线图配置
const getCompareLineOption = () => {
  return {
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '5%', top: '10%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月'] },
    yAxis: { type: 'value', axisLabel: { fontSize: 10 } },
    series: [
      { name: '智慧金融', type: 'line', smooth: true, itemStyle: { color: '#0d89ef' }, data: [12, 18, 55, 40, 48, -12, 10, -5, -8] },
      { name: '创新发展', type: 'line', smooth: true, itemStyle: { color: '#fba525' }, data: [-15, -12, -2, 45, -8, 20, 48, 25, 12] },
      { name: '长安新生', type: 'line', smooth: true, itemStyle: { color: '#38c58f' }, data: [80, 75, 82, 80, 85, 75, 65, 68, 60] }
    ]
  }
}

const initCompareCharts = () => {
  if (compareChart1Ref.value) { cChart1 = echarts.init(compareChart1Ref.value); cChart1.setOption(getCompareLineOption()); }
  if (compareChart2Ref.value) { cChart2 = echarts.init(compareChart2Ref.value); cChart2.setOption(getCompareLineOption()); }
  if (compareChart3Ref.value) { cChart3 = echarts.init(compareChart3Ref.value); cChart3.setOption(getCompareLineOption()); }
}

onMounted(() => {
  // TODO: 后续接 Axios 的真实接口，如 /api/report/trend/monthly 替换上面的Mock数据
  initTrendChart();
  initCompareCharts();
  
  window.addEventListener('resize', handleResize);
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  trendChart?.dispose();
  cChart1?.dispose();
  cChart2?.dispose();
  cChart3?.dispose();
})

const handleResize = () => {
  trendChart?.resize();
  cChart1?.resize();
  cChart2?.resize();
  cChart3?.resize();
}
</script>

<style scoped>
/* 略加修饰，还原WPS截图布局感 */
.dashboard {
  max-width: 1400px;
  margin: 0 auto;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  padding: 24px;
}
.header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.title { font-size: 18px; color: #333; }
.search-bar input { padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px 0 0 4px; outline: none; }
.search-btn { padding: 7px 16px; background: #0d89ef; color: white; border: none; border-radius: 0 4px 4px 0; cursor: pointer; }

.dept-tabs { display: flex; gap: 10px; margin-bottom: 24px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
.tab { padding: 8px 20px; border-radius: 20px; font-size: 14px; color: #666; cursor: pointer; background: #f5f6fa; }
.tab.active { background: #0d89ef; color: #fff; }

.top-cards { display: flex; gap: 20px; margin-bottom: 24px; }
.card { background: #fff; border: 1px solid #eee; border-radius: 8px; padding: 20px; display: flex; flex-direction: column; }
.card-wide { flex: 2; }
.card-small { flex: 1; }
.bg-blue-tint { background: #f0f8ff; border: 1px solid #d0e7ff; position: relative; }
.meta { font-size: 13px; color: #888; margin-bottom: 8px; }
.value { font-size: 24px; font-weight: bold; color: #333; }
.contract-val { font-size: 28px; }
.badge { position: absolute; top: 15px; right: 15px; background: #5a5ce2; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }

.progress-bar-container { margin-top: 15px; }
.progress-info { display: flex; justify-content: space-between; font-size: 12px; color: #666; margin-bottom: 5px; }
.pct { color: #aaa; }
.progress-bg { height: 4px; background: #eee; border-radius: 2px; overflow: hidden; }
.progress-fill { height: 100%; background: #0d89ef; border-radius: 2px; }
.mt-auto { margin-top: auto; }

.main-analysis { display: flex; gap: 20px; margin-bottom: 24px; border: 1px solid #eee; border-radius: 8px; padding: 15px; }
.metric-menu { width: 180px; display: flex; flex-direction: column; gap: 5px; }
.menu-item { padding: 10px 15px; font-size: 14px; cursor: pointer; color: #555; border-radius: 4px; }
.menu-item.active { background: #f0f8ff; color: #0d89ef; font-weight: 500; }

.chart-section { flex: 1; display: flex; flex-direction: column; }
.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;}
.chart-header h3 { font-size: 15px; margin: 0; color: #333; }
.legend-custom { font-size: 12px; color: #666; display: flex; align-items: center; gap: 15px; }
.dot { width: 8px; height: 8px; display: inline-block; border-radius: 2px; }
.dot.light-blue { background: #bce1fc; }
.dot.dark-blue { background: #0d89ef; }

.echarts-container { height: 350px; width: 100%; }
.chart-footer { display: flex; justify-content: center; margin-top: 10px; }
.toggle-btn { padding: 4px 16px; border: 1px solid #ddd; background: #fff; cursor: pointer; font-size: 12px; }
.toggle-btn.active { background: #0d89ef; color: #fff; border-color: #0d89ef; }

.data-list-sidebar { width: 220px; border-left: 1px solid #eee; padding-left: 15px; display: flex; flex-direction: column; gap: 8px; }
.list-header { display: flex; justify-content: space-between; background: #0d89ef; color: white; padding: 8px 12px; border-radius: 4px 4px 0 0; font-size: 13px; }
.list-row { display: flex; justify-content: space-between; padding: 8px 12px; border-bottom: 1px solid #f5f5f5; font-size: 13px; color: #555; }
.list-row.highlight { background: #e6f7ff; color: #0d89ef; }

.bottom-compare { display: flex; gap: 20px; border-top: 1px solid #eee; padding-top: 24px; }
.compare-box { flex: 1; }
.compare-box h4 { margin: 0 0 10px 0; font-size: 15px; color: #333; text-align: center; }
.echarts-mini { height: 250px; width: 100%; }
</style>
