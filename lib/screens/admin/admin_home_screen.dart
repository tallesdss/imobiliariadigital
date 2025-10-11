import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/fixed_sidebar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../user/notifications_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  PropertyStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _sidebarVisible = true;
  int _unreadNotificationsCount = 0;
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadNotifications();
  }

  void _loadProperties() {
    setState(() {
      _allProperties = MockDataService.properties;
      _applyStatusFilter();
    });
  }

  void _applyStatusFilter() {
    if (_selectedStatus == null) {
      _filteredProperties = _allProperties;
    } else {
      _filteredProperties = _allProperties.where((property) => property.status == _selectedStatus).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      final unreadCount = await notificationService.getUnreadCount('admin_user_id');
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = unreadCount;
        });
      }
    } catch (e) {
      // Ignorar erros de notificações na inicialização
    }
  }

  List<Property> get _searchFilteredProperties {
    var properties = _filteredProperties;
    
    // Filtrar por busca
    if (_searchQuery.isNotEmpty) {
      properties = properties.where((p) =>
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.realtorName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    return properties;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Imóveis'),
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
            onPressed: () => _showAddPropertyDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Imóvel',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar fixa de navegação
          FixedSidebar(
            type: SidebarType.navigation,
            currentRoute: '/admin',
            userType: DrawerUserType.admin,
            userName: 'Administrador',
            userEmail: 'admin@imobiliaria.com',
            isVisible: _sidebarVisible,
            onToggleVisibility: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
          ),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                _buildFiltersSection(),
                Expanded(
                  child: _buildPropertiesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Barra de busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar imóveis...',
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
          const SizedBox(height: 12),
          // Filtros de status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('Todos', null),
                const SizedBox(width: 8),
                _buildStatusChip('Ativos', PropertyStatus.active),
                const SizedBox(width: 8),
                _buildStatusChip('Vendidos', PropertyStatus.sold),
                const SizedBox(width: 8),
                _buildStatusChip('Arquivados', PropertyStatus.archived),
                const SizedBox(width: 8),
                _buildStatusChip('Suspensos', PropertyStatus.suspended),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, PropertyStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
          _applyStatusFilter();
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surfaceVariant,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPropertiesList() {
    final properties = _searchFilteredProperties;
    
    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum imóvel encontrado',
              style: AppTypography.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou adicionar um novo imóvel',
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
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
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
          _buildPropertyImage(property),
          _buildPropertyContent(property),
          _buildPropertyActions(property),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              image: property.photos.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(property.photos.first),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
                  : null,
            ),
            child: property.photos.isEmpty
                ? const Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  )
                : null,
          ),
        ),
        // Status badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(property.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              property.statusDisplayName,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Código do imóvel
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Cód: ${property.id.substring(0, 5)}',
              style: AppTypography.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyContent(Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo do imóvel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              property.typeDisplayName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Título
          Text(
            property.title,
            style: AppTypography.h6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Localização
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
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Preço
          Text(property.formattedPrice, style: AppTypography.priceSecondary),
          const SizedBox(height: 8),
          // Corretor
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Corretor: ${property.realtorName}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyActions(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editProperty(property),
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
              onPressed: () => _togglePropertyStatus(property),
              icon: Icon(
                property.status == PropertyStatus.active
                    ? Icons.archive
                    : Icons.unarchive,
                size: 18,
              ),
              label: Text(
                property.status == PropertyStatus.active
                    ? 'Arquivar'
                    : 'Ativar',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _deleteProperty(property),
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

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return AppColors.statusActive;
      case PropertyStatus.sold:
        return AppColors.statusSold;
      case PropertyStatus.archived:
        return AppColors.statusArchived;
      case PropertyStatus.suspended:
        return AppColors.warning;
    }
  }

  void _showAddPropertyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Imóvel'),
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

  void _editProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Imóvel'),
        content: Text('Editar ${property.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _togglePropertyStatus(Property property) {
    final newStatus = property.status == PropertyStatus.active
        ? PropertyStatus.archived
        : PropertyStatus.active;
    
    final updatedProperty = property.copyWith(status: newStatus);
    MockDataService.updateProperty(updatedProperty);
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imóvel ${newStatus == PropertyStatus.active ? 'ativado' : 'arquivado'} com sucesso!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Imóvel'),
        content: Text('Tem certeza que deseja excluir "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              MockDataService.deleteProperty(property.id);
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Imóvel excluído com sucesso!'),
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
