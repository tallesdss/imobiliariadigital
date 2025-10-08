import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../widgets/common/custom_drawer.dart';

class RealtorReportsScreen extends StatefulWidget {
  const RealtorReportsScreen({super.key});

  @override
  State<RealtorReportsScreen> createState() => _RealtorReportsScreenState();
}

class _RealtorReportsScreenState extends State<RealtorReportsScreen> {
  final String _realtorId = 'realtor1'; // Mock - usuário logado
  List<Property> _properties = [];
  bool _isLoading = true;

  // Mock data de estatísticas
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _properties = MockDataService.getPropertiesByRealtor(_realtorId);
        _calculateStats();
        _isLoading = false;
      });
    });
  }

  void _calculateStats() {
    final totalProperties = _properties.length;
        final activeProperties = _properties.where((p) => p.status == PropertyStatus.active).length;
        final soldProperties = _properties.where((p) => p.status == PropertyStatus.sold).length;
        final archivedProperties = _properties.where((p) => p.status == PropertyStatus.archived).length;

    _stats = {
      'totalProperties': totalProperties,
      'activeProperties': activeProperties,
      'soldProperties': soldProperties,
      'archivedProperties': archivedProperties,
      'conversionRate': totalProperties > 0 ? (soldProperties / totalProperties * 100) : 0.0,
      'avgPrice': _properties.isNotEmpty 
          ? _properties.map((p) => p.price).reduce((a, b) => a + b) / _properties.length 
          : 0.0,
    };
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPerformanceChart(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPropertiesByStatus(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
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
              _stats['totalProperties'].toString(),
              Icons.home,
              AppColors.primary,
            ),
            _buildStatCard(
              'Imóveis Ativos',
              _stats['activeProperties'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Imóveis Vendidos',
              _stats['soldProperties'].toString(),
              Icons.sell,
              Colors.orange,
            ),
            _buildStatCard(
              'Taxa de Conversão',
              '${_stats['conversionRate'].toStringAsFixed(1)}%',
              Icons.trending_up,
              AppColors.secondary,
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
            'Desempenho Mensal',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2),
                      const FlSpot(1, 3),
                      const FlSpot(2, 1),
                      const FlSpot(3, 4),
                      const FlSpot(4, 2),
                      const FlSpot(5, 5),
                      const FlSpot(6, 3),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
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
                    value: _stats['activeProperties'].toDouble(),
                    title: 'Ativos',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: _stats['soldProperties'].toDouble(),
                    title: 'Vendidos',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: _stats['archivedProperties'].toDouble(),
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

  Widget _buildRecentActivity() {
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
            'Atividade Recente',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(5, (index) {
            final activities = [
              'Imóvel "Casa Moderna" foi vendido',
              'Novo imóvel "Apartamento Luxo" cadastrado',
              'Imóvel "Casa Jardim" arquivado',
              'Imóvel "Loja Comercial" ativado',
              'Imóvel "Casa Família" recebeu nova mensagem',
            ];
            
            final dates = [
              '2 horas atrás',
              '1 dia atrás',
              '2 dias atrás',
              '3 dias atrás',
              '1 semana atrás',
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activities[index],
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          dates[index],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
