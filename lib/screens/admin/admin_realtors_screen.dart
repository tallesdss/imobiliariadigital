import 'package:flutter/material.dart';
import '../../models/realtor_model.dart';
import '../../models/property_model.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminRealtorsScreen extends StatefulWidget {
  const AdminRealtorsScreen({super.key});

  @override
  State<AdminRealtorsScreen> createState() => _AdminRealtorsScreenState();
}

class _AdminRealtorsScreenState extends State<AdminRealtorsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Realtor> get _filteredRealtors {
    var realtors = MockDataService.realtors;
    
    if (_searchQuery.isNotEmpty) {
      realtors = realtors.where((r) =>
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.creci.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    return realtors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Corretores'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: () => _showAddRealtorDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar Corretor',
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.admin,
        userName: 'Administrador',
        userEmail: 'admin@imobiliaria.com',
        currentRoute: '/admin/realtors',
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _buildRealtorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar corretores...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRealtorsList() {
    final realtors = _filteredRealtors;
    
    if (realtors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum corretor encontrado',
              style: AppTypography.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar a busca ou adicionar um novo corretor',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: realtors.length,
      itemBuilder: (context, index) {
        final realtor = realtors[index];
        return _buildRealtorCard(realtor);
      },
    );
  }

  Widget _buildRealtorCard(Realtor realtor) {
    final realtorProperties = MockDataService.getPropertiesByRealtor(realtor.id);
    final activeProperties = realtorProperties.where((p) => p.status == PropertyStatus.active).length;
    final soldProperties = realtorProperties.where((p) => p.status == PropertyStatus.sold).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          _buildRealtorHeader(realtor),
          _buildRealtorContent(realtor, activeProperties, soldProperties),
          _buildRealtorActions(realtor),
        ],
      ),
    );
  }

  Widget _buildRealtorHeader(Realtor realtor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: realtor.photo != null 
                ? NetworkImage(realtor.photo!) 
                : null,
            child: realtor.photo == null
                ? Text(
                    realtor.name.substring(0, 1).toUpperCase(),
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Informações básicas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realtor.name,
                  style: AppTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  realtor.creci,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  realtor.email,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: realtor.isActive ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              realtor.isActive ? 'Ativo' : 'Inativo',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtorContent(Realtor realtor, int activeProperties, int soldProperties) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (realtor.bio != null && realtor.bio!.isNotEmpty) ...[
            Text(
              'Sobre',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              realtor.bio!,
              style: AppTypography.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          // Contato
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                realtor.phone,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Imóveis Ativos',
                  activeProperties.toString(),
                  Icons.home_work_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Vendidos',
                  soldProperties.toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  realtor.totalProperties.toString(),
                  Icons.inventory_2_outlined,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRealtorActions(Realtor realtor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editRealtor(realtor),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleRealtorStatus(realtor),
              icon: Icon(
                realtor.isActive ? Icons.block : Icons.check_circle,
                size: 18,
              ),
              label: Text(
                realtor.isActive ? 'Suspender' : 'Ativar',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: realtor.isActive ? AppColors.warning : AppColors.success,
                side: BorderSide(
                  color: realtor.isActive ? AppColors.warning : AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _deleteRealtor(realtor),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Excluir'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRealtorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Corretor'),
        content: const Text('Funcionalidade de cadastro será implementada em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editRealtor(Realtor realtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Corretor'),
        content: Text('Editar dados de ${realtor.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleRealtorStatus(Realtor realtor) {
    final updatedRealtor = realtor.copyWith(isActive: !realtor.isActive);
    MockDataService.updateRealtor(updatedRealtor);
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Corretor ${updatedRealtor.isActive ? 'ativado' : 'suspenso'} com sucesso!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteRealtor(Realtor realtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Corretor'),
        content: Text('Tem certeza que deseja excluir "${realtor.name}"?\n\nEsta ação também removerá todos os imóveis cadastrados por este corretor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              MockDataService.deleteRealtor(realtor.id);
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Corretor excluído com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
