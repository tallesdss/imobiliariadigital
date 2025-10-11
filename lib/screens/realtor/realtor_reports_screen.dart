import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import '../../widgets/common/custom_drawer.dart';

class RealtorReportsScreen extends StatefulWidget {
  const RealtorReportsScreen({super.key});

  @override
  State<RealtorReportsScreen> createState() => _RealtorReportsScreenState();
}

class _RealtorReportsScreenState extends State<RealtorReportsScreen> with TickerProviderStateMixin {
  final String _realtorId = 'realtor1'; // Mock - usuário logado
  bool _isLoading = true;
  RealtorReport? _currentReport;
  List<Goal> _goals = [];
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar dados em paralelo
      await Future.wait([
        _loadReport(),
        _loadGoals(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _loadReport() async {
    try {
      _currentReport = await ReportService.generateRealtorReport(
        realtorId: _realtorId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      );
    } catch (e) {
      // Fallback para dados mock - em caso de erro, usar dados vazios
      _currentReport = null;
    }
  }

  Future<void> _loadGoals() async {
    try {
      _goals = await ReportService.getRealtorGoals(_realtorId);
    } catch (e) {
      _goals = [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios',
          style: AppTypography.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Visão Geral'),
            Tab(text: 'Análise de Leads'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.realtor,
        userName: 'Carlos Oliveira',
        userEmail: 'carlos@imobiliaria.com',
        currentRoute: '/realtor/reports',
        userCreci: 'CRECI 12345-F',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildLeadsTab(),
                _buildGoalsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsCards(),
          const SizedBox(height: AppSpacing.lg),
          _buildPerformanceChart(),
          const SizedBox(height: AppSpacing.lg),
          _buildPropertiesByStatus(),
          const SizedBox(height: AppSpacing.lg),
          _buildTopProperties(),
        ],
      ),
    );
  }

  Widget _buildLeadsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeadsStats(),
          const SizedBox(height: AppSpacing.lg),
          _buildLeadsChart(),
          const SizedBox(height: AppSpacing.lg),
          _buildConversionAnalysis(),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalsHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildGoalsList(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Período Selecionado',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_formatDate(_selectedStartDate)} - ${_formatDate(_selectedEndDate)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final report = _currentReport;
    if (report == null) {
      return const Center(child: Text('Carregando dados...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo Geral',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total de Imóveis',
              report.totalProperties.toString(),
              Icons.home,
              AppColors.primary,
            ),
            _buildStatCard(
              'Imóveis Vendidos',
              report.soldProperties.toString(),
              Icons.sell,
              Colors.orange,
            ),
            _buildStatCard(
              'Taxa de Conversão',
              '${report.conversionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              AppColors.secondary,
            ),
            _buildStatCard(
              'Faturamento',
              'R\$ ${_formatCurrency(report.totalRevenue)}',
              Icons.attach_money,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final report = _currentReport;
    if (report == null || report.monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('Dados insuficientes para o gráfico')),
      );
    }

    final spots = report.monthlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.propertiesSold.toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendas por Mês',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < report.monthlyData.length) {
                          return Text('${report.monthlyData[value.toInt()].month}');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesByStatus() {
    final report = _currentReport;
    if (report == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('Carregando dados...')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imóveis por Status',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: report.activeProperties.toDouble(),
                    title: 'Ativos',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: report.soldProperties.toDouble(),
                    title: 'Vendidos',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: report.archivedProperties.toDouble(),
                    title: 'Arquivados',
                    color: Colors.grey,
                    radius: 60,
                    titleStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProperties() {
    final report = _currentReport;
    if (report == null || report.topProperties.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('Nenhum imóvel encontrado')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Imóveis por Performance',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          ...report.topProperties.take(5).map((property) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(property.title),
                subtitle: Text('R\$ ${_formatCurrency(property.price)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${property.views} views'),
                    Text('${property.leads} leads'),
                  ],
                ),
                leading: Icon(
                  property.isSold ? Icons.check_circle : Icons.home,
                  color: property.isSold ? Colors.green : AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeadsStats() {
    final report = _currentReport;
    if (report == null) {
      return const Center(child: Text('Carregando dados...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análise de Leads',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total de Leads',
              report.totalLeads.toString(),
              Icons.people,
              AppColors.primary,
            ),
            _buildStatCard(
              'Leads Convertidos',
              report.convertedLeads.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Taxa de Conversão',
              '${report.leadConversionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              AppColors.secondary,
            ),
            _buildStatCard(
              'Total de Views',
              report.totalViews.toString(),
              Icons.visibility,
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeadsChart() {
    final report = _currentReport;
    if (report == null || report.monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('Dados insuficientes para o gráfico')),
      );
    }

    final leadsSpots = report.monthlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.leads.toDouble());
    }).toList();

    final viewsSpots = report.monthlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.views.toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leads e Views por Mês',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < report.monthlyData.length) {
                          return Text('${report.monthlyData[value.toInt()].month}');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: leadsSpots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: viewsSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionAnalysis() {
    final report = _currentReport;
    if (report == null) {
      return const Center(child: Text('Carregando dados...'));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análise de Conversão',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildConversionItem('Views para Leads', report.totalViews, report.totalLeads),
          _buildConversionItem('Leads para Vendas', report.totalLeads, report.convertedLeads),
          _buildConversionItem('Imóveis para Vendas', report.totalProperties, report.soldProperties),
        ],
      ),
    );
  }

  Widget _buildConversionItem(String title, int total, int converted) {
    final rate = total > 0 ? (converted / total * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge),
                Text('$converted de $total (${rate.toStringAsFixed(1)}%)'),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                rate > 10 ? Colors.green : rate > 5 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Metas e Objetivos',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _createNewGoal,
          icon: const Icon(Icons.add),
          label: const Text('Nova Meta'),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('Nenhuma meta definida. Crie sua primeira meta!'),
        ),
      );
    }

    return Column(
      children: _goals.map((goal) => _buildGoalCard(goal)).toList(),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                goal.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: goal.isCompleted ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progresso: ${goal.progressPercentage.toStringAsFixed(1)}%'),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: goal.progressPercentage / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.progressPercentage >= 100 ? Colors.green : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${_formatGoalValue(goal.currentValue)} / ${_formatGoalValue(goal.targetValue)}',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Métodos auxiliares
  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadData();
    }
  }

  void _exportReport() async {
    if (_currentReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum relatório disponível para exportar')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exportar Relatório',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar como PDF'),
              onTap: () async {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar como Excel'),
              onTap: () async {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF() async {
    try {
      final fileName = await ReportService.exportReportToPDF(_currentReport!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Relatório exportado: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar PDF: $e')),
        );
      }
    }
  }

  void _exportToExcel() async {
    try {
      final fileName = await ReportService.exportReportToExcel(_currentReport!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Relatório exportado: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar Excel: $e')),
        );
      }
    }
  }

  void _createNewGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Meta'),
        content: const Text('Funcionalidade em desenvolvimento!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatGoalValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
