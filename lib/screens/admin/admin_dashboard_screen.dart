import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/realtor_model.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = MockDataService.properties;
    final realtors = MockDataService.realtors;
    
    // Estatísticas gerais
    final activeProperties = properties.where((p) => p.status == PropertyStatus.active).length;
    final soldProperties = properties.where((p) => p.status == PropertyStatus.sold).length;
    final archivedProperties = properties.where((p) => p.status == PropertyStatus.archived).length;
    final activeRealtors = realtors.where((r) => r.isActive).length;
    
    // Ranking de corretores
    final realtorRanking = _getRealtorRanking(realtors, properties);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrativo'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(activeProperties, soldProperties, archivedProperties, activeRealtors),
            const SizedBox(height: 24),
            _buildRealtorRankingSection(realtorRanking),
            const SizedBox(height: 24),
            _buildPerformanceChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(int activeProperties, int soldProperties, int archivedProperties, int activeRealtors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Imóveis Ativos',
                activeProperties.toString(),
                Icons.home_work_outlined,
                AppColors.primary,
                'Disponíveis para venda',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Vendidos',
                soldProperties.toString(),
                Icons.check_circle_outline,
                AppColors.success,
                'Negócios concluídos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Arquivados',
                archivedProperties.toString(),
                Icons.archive_outlined,
                AppColors.warning,
                'Fora de circulação',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Corretores Ativos',
                activeRealtors.toString(),
                Icons.people_outline,
                AppColors.info,
                'Profissionais ativos',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTypography.h4.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtorRankingSection(List<Map<String, dynamic>> realtorRanking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking de Corretores',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Top Performers',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: realtorRanking.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final realtor = realtorRanking[index];
                  return _buildRealtorRankingItem(realtor, index + 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealtorRankingItem(Map<String, dynamic> realtor, int position) {
    final realtorData = realtor['realtor'] as Realtor;
    final totalProperties = realtor['totalProperties'] as int;
    final soldProperties = realtor['soldProperties'] as int;
    final activeProperties = realtor['activeProperties'] as int;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Posição
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getPositionColor(position),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: realtorData.photo != null 
                ? NetworkImage(realtorData.photo!) 
                : null,
            child: realtorData.photo == null
                ? Text(
                    realtorData.name.substring(0, 1).toUpperCase(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realtorData.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  realtorData.creci,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Estatísticas
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniStat('Ativos', activeProperties, AppColors.primary),
                  const SizedBox(width: 8),
                  _buildMiniStat('Vendidos', soldProperties, AppColors.success),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Total: $totalProperties',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value $label',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPerformanceChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desempenho por Corretor',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'Gráfico de Desempenho',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualização em desenvolvimento',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Ouro
      case 2:
        return const Color(0xFFC0C0C0); // Prata
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

  List<Map<String, dynamic>> _getRealtorRanking(List<Realtor> realtors, List<Property> properties) {
    final ranking = <Map<String, dynamic>>[];
    
    for (final realtor in realtors) {
      final realtorProperties = properties.where((p) => p.realtorId == realtor.id).toList();
      final totalProperties = realtorProperties.length;
      final soldProperties = realtorProperties.where((p) => p.status == PropertyStatus.sold).length;
      final activeProperties = realtorProperties.where((p) => p.status == PropertyStatus.active).length;
      
      ranking.add({
        'realtor': realtor,
        'totalProperties': totalProperties,
        'soldProperties': soldProperties,
        'activeProperties': activeProperties,
        'score': soldProperties * 2 + activeProperties, // Pontuação: vendidos x2 + ativos
      });
    }
    
    // Ordenar por pontuação (vendidos x2 + ativos)
    ranking.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    return ranking.take(5).toList(); // Top 5
  }
}
