import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../models/realtor_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = '30_days';
  String _selectedReportType = 'overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'Exportar Relatório',
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.admin,
        userName: 'Administrador',
        userEmail: 'admin@imobiliaria.com',
        currentRoute: '/admin/reports',
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportTypeSelector(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildReportContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child:             DropdownButtonFormField<String>(
              initialValue: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Período',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '7_days', child: Text('Últimos 7 dias')),
                DropdownMenuItem(value: '30_days', child: Text('Últimos 30 dias')),
                DropdownMenuItem(value: '90_days', child: Text('Últimos 90 dias')),
                DropdownMenuItem(value: '1_year', child: Text('Último ano')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child:             DropdownButtonFormField<String>(
              initialValue: _selectedReportType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Relatório',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'overview', child: Text('Visão Geral')),
                DropdownMenuItem(value: 'properties', child: Text('Imóveis')),
                DropdownMenuItem(value: 'realtors', child: Text('Corretores')),
                DropdownMenuItem(value: 'sales', child: Text('Vendas')),
                DropdownMenuItem(value: 'performance', child: Text('Performance')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReportType = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Relatório: ${_getReportTypeName()}',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Período: ${_getPeriodName()}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 'overview':
        return _buildOverviewReport();
      case 'properties':
        return _buildPropertiesReport();
      case 'realtors':
        return _buildRealtorsReport();
      case 'sales':
        return _buildSalesReport();
      case 'performance':
        return _buildPerformanceReport();
      default:
        return _buildOverviewReport();
    }
  }

  Widget _buildOverviewReport() {
    final properties = MockDataService.properties;
    final realtors = MockDataService.realtors;
    
    final activeProperties = properties.where((p) => p.status == PropertyStatus.active).length;
    final soldProperties = properties.where((p) => p.status == PropertyStatus.sold).length;
    final archivedProperties = properties.where((p) => p.status == PropertyStatus.archived).length;
    final totalValue = properties.fold<double>(0, (sum, p) => sum + p.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral da Plataforma',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildStatsGrid([
          _StatCard(
            title: 'Total de Imóveis',
            value: properties.length.toString(),
            icon: Icons.home_work,
            color: AppColors.primary,
          ),
          _StatCard(
            title: 'Imóveis Ativos',
            value: activeProperties.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
          _StatCard(
            title: 'Imóveis Vendidos',
            value: soldProperties.toString(),
            icon: Icons.sell,
            color: AppColors.warning,
          ),
          _StatCard(
            title: 'Imóveis Arquivados',
            value: archivedProperties.toString(),
            icon: Icons.archive,
            color: AppColors.textSecondary,
          ),
          _StatCard(
            title: 'Total de Corretores',
            value: realtors.length.toString(),
            icon: Icons.people,
            color: AppColors.info,
          ),
          _StatCard(
            title: 'Valor Total (R\$)',
            value: 'R\$ ${(totalValue / 1000000).toStringAsFixed(1)}M',
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        _buildPropertiesByTypeChart(),
        const SizedBox(height: AppSpacing.xl),
        _buildTopRealtorsSection(),
      ],
    );
  }

  Widget _buildPropertiesReport() {
    final properties = MockDataService.properties;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relatório de Imóveis',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildPropertiesTable(properties),
      ],
    );
  }

  Widget _buildRealtorsReport() {
    final realtors = MockDataService.realtors;
    final properties = MockDataService.properties;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relatório de Corretores',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildRealtorsTable(realtors, properties),
      ],
    );
  }

  Widget _buildSalesReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relatório de Vendas',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSalesChart(),
        const SizedBox(height: AppSpacing.xl),
        _buildSalesTable(),
      ],
    );
  }

  Widget _buildPerformanceReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relatório de Performance',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildPerformanceMetrics(),
        const SizedBox(height: AppSpacing.xl),
        _buildPerformanceChart(),
      ],
    );
  }

  Widget _buildStatsGrid(List<_StatCard> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(stat.icon, color: stat.color, size: 24),
                  const Spacer(),
                  Text(
                    stat.value,
                    style: AppTypography.h6.copyWith(
                      color: stat.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                stat.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertiesByTypeChart() {
    final properties = MockDataService.properties;
    final typeCounts = <PropertyType, int>{};
    
    for (final property in properties) {
      typeCounts[property.type] = (typeCounts[property.type] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imóveis por Tipo',
            style: AppTypography.h6.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final entry in typeCounts.entries) ...[
            Builder(
              builder: (context) {
                final percentage = (entry.value / properties.length * 100).round();
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getPropertyTypeDisplayName(entry.key)),
                          Text('${entry.value} ($percentage%)'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: entry.value / properties.length,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopRealtorsSection() {
    final realtors = MockDataService.realtors;
    final properties = MockDataService.properties;
    
    final realtorStats = realtors.map((realtor) {
      final realtorProperties = properties.where((p) => p.realtorId == realtor.id).toList();
      return {
        'realtor': realtor,
        'totalProperties': realtorProperties.length,
        'activeProperties': realtorProperties.where((p) => p.status == PropertyStatus.active).length,
        'soldProperties': realtorProperties.where((p) => p.status == PropertyStatus.sold).length,
      };
    }).toList();
    
    realtorStats.sort((a, b) => (b['totalProperties'] as int).compareTo(a['totalProperties'] as int));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Corretores',
            style: AppTypography.h6.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final stat in realtorStats.take(5)) ...[
            Builder(
              builder: (context) {
                final realtor = stat['realtor'] as Realtor;
                final totalProperties = stat['totalProperties'] as int;
                final activeProperties = stat['activeProperties'] as int;
                final soldProperties = stat['soldProperties'] as int;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          realtor.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              realtor.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'CRECI: ${realtor.creci}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$totalProperties imóveis',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$activeProperties ativos • $soldProperties vendidos',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertiesTable(List<Property> properties) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Título')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Preço')),
          DataColumn(label: Text('Corretor')),
        ],
        rows: properties.map((property) {
          return DataRow(
            cells: [
              DataCell(Text(property.title)),
              DataCell(Text(_getPropertyTypeDisplayName(property.type))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(property.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPropertyStatusDisplayName(property.status),
                    style: TextStyle(
                      color: _getStatusColor(property.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text('R\$ ${property.price.toStringAsFixed(0)}')),
              DataCell(Text(property.realtorName)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealtorsTable(List<Realtor> realtors, List<Property> properties) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('CRECI')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Imóveis')),
          DataColumn(label: Text('Status')),
        ],
        rows: realtors.map((realtor) {
          final realtorProperties = properties.where((p) => p.realtorId == realtor.id).length;
          return DataRow(
            cells: [
              DataCell(Text(realtor.name)),
              DataCell(Text(realtor.creci)),
              DataCell(Text(realtor.email)),
              DataCell(Text(realtorProperties.toString())),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ativo',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendas por Mês',
            style: AppTypography.h6.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Center(
            child: Text(
              '📊 Gráfico de Vendas\n(Implementação visual seria aqui)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Imóvel')),
          DataColumn(label: Text('Corretor')),
          DataColumn(label: Text('Preço')),
          DataColumn(label: Text('Data Venda')),
        ],
        rows: MockDataService.properties
            .where((p) => p.status == PropertyStatus.sold)
            .map((property) {
          return DataRow(
            cells: [
              DataCell(Text(property.title)),
              DataCell(Text(property.realtorName)),
              DataCell(Text('R\$ ${property.price.toStringAsFixed(0)}')),
              DataCell(Text('${property.updatedAt.day}/${property.updatedAt.month}/${property.updatedAt.year}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Performance',
            style: AppTypography.h6.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Taxa de Conversão',
                  '12.5%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricCard(
                  'Tempo Médio de Venda',
                  '45 dias',
                  Icons.schedule,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Satisfação do Cliente',
                  '4.8/5',
                  Icons.star,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricCard(
                  'Novos Leads',
                  '127',
                  Icons.person_add,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance dos Corretores',
            style: AppTypography.h6.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Center(
            child: Text(
              '📈 Gráfico de Performance\n(Implementação visual seria aqui)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTypeName() {
    switch (_selectedReportType) {
      case 'overview': return 'Visão Geral';
      case 'properties': return 'Imóveis';
      case 'realtors': return 'Corretores';
      case 'sales': return 'Vendas';
      case 'performance': return 'Performance';
      default: return 'Visão Geral';
    }
  }

  String _getPeriodName() {
    switch (_selectedPeriod) {
      case '7_days': return 'Últimos 7 dias';
      case '30_days': return 'Últimos 30 dias';
      case '90_days': return 'Últimos 90 dias';
      case '1_year': return 'Último ano';
      default: return 'Últimos 30 dias';
    }
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return AppColors.success;
      case PropertyStatus.sold:
        return AppColors.warning;
      case PropertyStatus.archived:
        return AppColors.textSecondary;
      case PropertyStatus.suspended:
        return AppColors.error;
    }
  }

  String _getPropertyTypeDisplayName(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'Casa';
      case PropertyType.apartment:
        return 'Apartamento';
      case PropertyType.commercial:
        return 'Comercial';
      case PropertyType.land:
        return 'Terreno';
    }
  }

  String _getPropertyStatusDisplayName(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return 'Ativo';
      case PropertyStatus.sold:
        return 'Vendido';
      case PropertyStatus.archived:
        return 'Arquivado';
      case PropertyStatus.suspended:
        return 'Suspenso';
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório exportado com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
