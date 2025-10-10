import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../services/notification_service.dart';
import '../../models/property_model.dart';
import '../../widgets/common/fixed_sidebar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/status_badge.dart';
import 'property_form_screen.dart';
import '../user/notifications_screen.dart';

class RealtorHomeScreen extends StatefulWidget {
  const RealtorHomeScreen({super.key});

  @override
  State<RealtorHomeScreen> createState() => _RealtorHomeScreenState();
}

class _RealtorHomeScreenState extends State<RealtorHomeScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;
  bool _sidebarVisible = true;
  final String _realtorId = 'realtor1'; // Mock - usuário logado
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadNotifications();
  }

  void _loadProperties() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _properties = MockDataService.getPropertiesByRealtor(_realtorId);
        _isLoading = false;
      });
    });
  }

  Future<void> _loadNotifications() async {
    try {
      await NotificationService.initialize();
      final unreadCount = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = unreadCount;
        });
      }
    } catch (e) {
      // Ignorar erros de notificações na inicialização
    }
  }

  void _navigateToPropertyForm({Property? property}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyFormScreen(property: property),
      ),
    ).then((_) => _loadProperties());
  }

  void _showPropertyActions(Property property) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PropertyActionsSheet(
        property: property,
        onEdit: () {
          Navigator.pop(context);
          _navigateToPropertyForm(property: property);
        },
        onArchive: () {
          Navigator.pop(context);
          _archiveProperty(property);
        },
        onReactivate: () {
          Navigator.pop(context);
          _reactivateProperty(property);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteProperty(property);
        },
      ),
    );
  }

  void _archiveProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar Imóvel'),
        content: Text('Tem certeza que deseja arquivar "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProperty = property.copyWith(
                status: PropertyStatus.archived,
              );
              MockDataService.updateProperty(updatedProperty);
              Navigator.pop(context);
              _loadProperties();
            },
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );
  }

  void _reactivateProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reativar Imóvel'),
        content: Text('Deseja reativar "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProperty = property.copyWith(
                status: PropertyStatus.active,
              );
              MockDataService.updateProperty(updatedProperty);
              Navigator.pop(context);
              _loadProperties();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Imóvel reativado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Reativar'),
          ),
        ],
      ),
    );
  }

  void _deleteProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Imóvel'),
        content: Text(
          'Tem certeza que deseja excluir "${property.title}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              MockDataService.deleteProperty(property.id);
              Navigator.pop(context);
              _loadProperties();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Imóveis'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          // Botão de notificações
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ).then((_) {
                // Recarregar contador de notificações quando voltar
                _loadNotifications();
              });
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Botão para alternar sidebar
          IconButton(
            onPressed: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
            icon: Icon(_sidebarVisible ? Icons.menu_open : Icons.menu),
            tooltip: _sidebarVisible ? 'Ocultar menu' : 'Mostrar menu',
          ),
          IconButton(
            onPressed: () => _navigateToPropertyForm(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar fixa de navegação
          FixedSidebar(
            type: SidebarType.navigation,
            userType: DrawerUserType.realtor,
            userName: 'Carlos Oliveira',
            userEmail: 'carlos@imobiliaria.com',
            userCreci: 'CRECI-SP 12345',
            currentRoute: '/realtor',
            isVisible: _sidebarVisible,
            onToggleVisibility: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
          ),
          
          // Conteúdo principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPropertyForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum imóvel cadastrado',
              style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Comece cadastrando seu primeiro imóvel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _navigateToPropertyForm(),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Imóvel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsHeader(),
        Expanded(child: _buildPropertiesList()),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final activeCount = _properties
        .where((p) => p.status == PropertyStatus.active)
        .length;
    final soldCount = _properties
        .where((p) => p.status == PropertyStatus.sold)
        .length;
    final archivedCount = _properties
        .where((p) => p.status == PropertyStatus.archived)
        .length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Ativos', activeCount, AppColors.success),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard('Vendidos', soldCount, AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              'Arquivados',
              archivedCount,
              AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTypography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildPropertiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        return _buildPropertyListItem(property);
      },
    );
  }

  Widget _buildPropertyListItem(Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
        children: [
          // Imagem do imóvel
          if (property.photos.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  property.photos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: AppColors.textHint,
                      ),
                    );
                  },
                ),
              ),
            ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusBadge(status: property.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  property.formattedPrice,
                  style: AppTypography.h6.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.city}, ${property.state}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _navigateToPropertyForm(property: property),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () => _showPropertyActions(property),
                      icon: const Icon(Icons.more_vert),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyActionsSheet extends StatelessWidget {
  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onReactivate;
  final VoidCallback onDelete;

  const PropertyActionsSheet({
    super.key,
    required this.property,
    required this.onEdit,
    required this.onArchive,
    required this.onReactivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: AppTypography.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Editar Imóvel'),
                  onTap: onEdit,
                  contentPadding: EdgeInsets.zero,
                ),
                if (property.status == PropertyStatus.active)
                  ListTile(
                    leading: const Icon(
                      Icons.archive,
                      color: AppColors.warning,
                    ),
                    title: const Text('Arquivar Imóvel'),
                    onTap: onArchive,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (property.status == PropertyStatus.archived)
                  ListTile(
                    leading: const Icon(
                      Icons.unarchive,
                      color: AppColors.success,
                    ),
                    title: const Text('Reativar Imóvel'),
                    onTap: onReactivate,
                    contentPadding: EdgeInsets.zero,
                  ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Excluir Imóvel'),
                  onTap: onDelete,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
