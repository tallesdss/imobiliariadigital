import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alert_model.dart';
import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'alert_settings_screen.dart';

/// Tela de gerenciamento de alertas do usuário
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<PropertyAlert> _alerts = [];
  List<AlertHistory> _history = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;

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

  /// Carrega dados dos alertas
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user == null) {
        setState(() {
          _error = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }
      
      // Carregar alertas e histórico usando AlertService
      final alerts = await AlertService.getUserAlerts();
      final history = await AlertService.getAlertHistory();
      final stats = await AlertService.getAlertStats();
      
      setState(() {
        _alerts = alerts;
        _history = history;
        _stats = {
          'totalAlerts': alerts.length,
          'activeAlerts': alerts.where((a) => a.isActive).length,
          'totalTriggers': stats['totalTriggers'] ?? history.length,
          'unreadAlerts': stats['unreadAlerts'] ?? history.where((h) => !h.wasRead).length,
          'alertsByType': _groupAlertsByType(alerts),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Cria um novo alerta
  Future<void> _createAlert() async {
    _showCreateAlertDialog();
  }

  /// Mostra diálogo para criar alerta
  void _showCreateAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAlertDialog(
        onAlertCreated: (alert) {
          _loadData();
          _showSnackBar('Alerta criado com sucesso!');
        },
      ),
    );
  }

  /// Cria alerta de redução de preço
  Future<void> _createPriceDropAlert({
    required String propertyId,
    required String propertyTitle,
    required double targetPrice,
  }) async {
    try {
      await AlertService.createPriceDropAlert(
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        targetPrice: targetPrice,
      );
      _loadData();
      _showSnackBar('Alerta de redução de preço criado!');
    } catch (e) {
      _showSnackBar('Erro ao criar alerta: $e');
    }
  }

  /// Cria alerta de imóvel vendido
  Future<void> _createSoldAlert({
    required String propertyId,
    required String propertyTitle,
  }) async {
    try {
      await AlertService.createSoldAlert(
        propertyId: propertyId,
        propertyTitle: propertyTitle,
      );
      _loadData();
      _showSnackBar('Alerta de imóvel vendido criado!');
    } catch (e) {
      _showSnackBar('Erro ao criar alerta: $e');
    }
  }

  /// Cria alerta de imóvel similar
  Future<void> _createSimilarPropertyAlert({
    required String propertyId,
    required String propertyTitle,
    double? targetPrice,
  }) async {
    try {
      await AlertService.createSimilarPropertyAlert(
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        targetPrice: targetPrice,
      );
      _loadData();
      _showSnackBar('Alerta de imóvel similar criado!');
    } catch (e) {
      _showSnackBar('Erro ao criar alerta: $e');
    }
  }

  /// Edita um alerta existente
  Future<void> _editAlert(PropertyAlert alert) async {
    // TODO: Implementar tela de edição de alertas
    _showSnackBar('Funcionalidade de edição em desenvolvimento');
  }

  /// Remove um alerta
  Future<void> _deleteAlert(PropertyAlert alert) async {
    final confirmed = await _showDeleteConfirmation(alert);
    if (confirmed == true) {
      try {
        await AlertService.deleteAlert(alert.id);
        _loadData();
        _showSnackBar('Alerta removido com sucesso');
      } catch (e) {
        _showSnackBar('Erro ao remover alerta: $e');
      }
    }
  }

  /// Alterna status ativo/inativo do alerta
  Future<void> _toggleAlertStatus(PropertyAlert alert) async {
    try {
      await AlertService.updateAlert(
        alert.id,
        isActive: !alert.isActive,
      );
      _loadData();
      _showSnackBar(
        alert.isActive ? 'Alerta pausado' : 'Alerta ativado',
      );
    } catch (e) {
      _showSnackBar('Erro ao atualizar alerta: $e');
    }
  }

  /// Marca um item do histórico como lido
  Future<void> _markHistoryAsRead(AlertHistory history) async {
    try {
      await AlertService.markHistoryAsRead(history.id);
      _loadData();
      _showSnackBar('Marcado como lido');
    } catch (e) {
      _showSnackBar('Erro ao marcar como lido: $e');
    }
  }

  /// Marca todos os itens do histórico como lidos
  Future<void> _markAllHistoryAsRead() async {
    try {
      await AlertService.markAllHistoryAsRead();
      _loadData();
      _showSnackBar('Todos marcados como lidos');
    } catch (e) {
      _showSnackBar('Erro ao marcar todos como lidos: $e');
    }
  }


  /// Mostra confirmação de exclusão
  Future<bool?> _showDeleteConfirmation(PropertyAlert alert) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Alerta'),
        content: Text(
          'Tem certeza que deseja remover este alerta?\n\n'
          'Tipo: ${_getAlertTypeName(alert.type)}\n'
          'Criado em: ${_formatDate(alert.createdAt)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  /// Mostra snackbar com mensagem
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Obtém nome do tipo de alerta
  String _getAlertTypeName(AlertType type) {
    switch (type) {
      case AlertType.priceDrop:
      case AlertType.priceReduction:
        return 'Redução de Preço';
      case AlertType.statusChange:
      case AlertType.sold:
        return 'Imóvel Vendido';
      case AlertType.newProperty:
      case AlertType.newSimilar:
        return 'Imóvel Similar';
      case AlertType.custom:
        return 'Alerta Personalizado';
    }
  }

  /// Formata data
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Alertas'),
        actions: [
          IconButton(
            onPressed: _createAlert,
            icon: const Icon(Icons.add),
            tooltip: 'Criar Alerta',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlertSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ativos', icon: Icon(Icons.notifications_active)),
            Tab(text: 'Histórico', icon: Icon(Icons.history)),
            Tab(text: 'Estatísticas', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveAlertsTab(),
                    _buildHistoryTab(),
                    _buildStatsTab(),
                  ],
                ),
    );
  }

  /// Constrói aba de alertas ativos
  Widget _buildActiveAlertsTab() {
    final activeAlerts = _alerts.where((a) => a.isActive).toList();
    final inactiveAlerts = _alerts.where((a) => !a.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeAlerts.isNotEmpty) ...[
            const Text(
              'Alertas Ativos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...activeAlerts.map((alert) => _buildAlertCard(alert)),
            const SizedBox(height: 24),
          ],
          
          if (inactiveAlerts.isNotEmpty) ...[
            const Text(
              'Alertas Pausados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...inactiveAlerts.map((alert) => _buildAlertCard(alert)),
          ],

          if (_alerts.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  /// Constrói aba de histórico
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _history.isEmpty
          ? _buildEmptyHistoryState()
          : Column(
              children: [
                if (_history.any((h) => !h.wasRead)) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _markAllHistoryAsRead,
                      icon: const Icon(Icons.mark_email_read),
                      label: const Text('Marcar Todos como Lidos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final history = _history[index];
                      return _buildHistoryCard(history);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// Constrói aba de estatísticas
  Widget _buildStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildAlertsByTypeCard(),
        ],
      ),
    );
  }

  /// Constrói card de alerta
  Widget _buildAlertCard(PropertyAlert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alert.isActive ? Colors.green : Colors.grey,
          child: Icon(
            _getAlertTypeIcon(alert.type),
            color: Colors.white,
          ),
        ),
        title: Text(_getAlertTypeName(alert.type)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Criado em: ${_formatDate(alert.createdAt)}'),
            Text('Imóvel: ${alert.propertyTitle}'),
            if (alert.targetPrice != null)
              Text('Preço alvo: R\$ ${alert.targetPrice!.toStringAsFixed(2)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editAlert(alert);
                break;
              case 'toggle':
                _toggleAlertStatus(alert);
                break;
              case 'delete':
                _deleteAlert(alert);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  alert.isActive ? Icons.pause : Icons.play_arrow,
                ),
                title: Text(alert.isActive ? 'Pausar' : 'Ativar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remover', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _editAlert(alert),
      ),
    );
  }

  /// Constrói card de histórico
  Widget _buildHistoryCard(AlertHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: history.wasRead ? Colors.grey : _getAlertTypeColor(history.type.name),
          child: Icon(
            _getAlertTypeIcon(history.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          history.message,
          style: TextStyle(
            fontWeight: history.wasRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${history.typeDisplayName}'),
            Text('Há ${history.timeAgo}'),
            if (history.metadata != null && history.metadata!['propertyTitle'] != null)
              Text('Imóvel: ${history.metadata!['propertyTitle']}'),
          ],
        ),
        trailing: history.wasRead
            ? null
            : IconButton(
                onPressed: () => _markHistoryAsRead(history),
                icon: const Icon(Icons.mark_email_read),
                tooltip: 'Marcar como lido',
              ),
        onTap: () {
          if (!history.wasRead) {
            _markHistoryAsRead(history);
          }
        },
      ),
    );
  }

  /// Constrói card de estatísticas
  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas Gerais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total de Alertas',
                    '${_stats['totalAlerts'] ?? 0}',
                    Icons.notifications,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Alertas Ativos',
                    '${_stats['activeAlerts'] ?? 0}',
                    Icons.notifications_active,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total de Disparos',
                    '${_stats['totalTriggers'] ?? 0}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Não Lidos',
                    '${_stats['unreadAlerts'] ?? 0}',
                    Icons.mark_email_unread,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói card de alertas por tipo
  Widget _buildAlertsByTypeCard() {
    final alertsByType = _stats['alertsByType'] as Map<String, int>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas por Tipo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (alertsByType.isEmpty)
              const Text('Nenhum alerta criado ainda')
            else
              ...alertsByType.entries.map((entry) {
                final type = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getAlertTypeNameFromString(type)),
                      Chip(
                        label: Text('$count'),
                        backgroundColor: _getAlertTypeColor(type),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Constrói item de estatística
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Constrói estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum alerta criado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie alertas para ser notificado sobre\nimóveis que atendem seus critérios',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createAlert,
            icon: const Icon(Icons.add),
            label: const Text('Criar Primeiro Alerta'),
          ),
        ],
      ),
    );
  }

  /// Constrói estado vazio do histórico
  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum histórico de alertas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quando seus alertas forem disparados,\naparecerão aqui',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Obtém ícone do tipo de alerta
  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.priceDrop:
      case AlertType.priceReduction:
        return Icons.trending_down;
      case AlertType.statusChange:
      case AlertType.sold:
        return Icons.verified;
      case AlertType.newProperty:
      case AlertType.newSimilar:
        return Icons.search;
      case AlertType.custom:
        return Icons.notifications;
    }
  }

  /// Obtém nome do tipo de alerta a partir da string
  String _getAlertTypeNameFromString(String type) {
    switch (type) {
      case 'priceDrop':
      case 'priceReduction':
        return 'Redução de Preço';
      case 'statusChange':
      case 'sold':
        return 'Imóvel Vendido';
      case 'newProperty':
      case 'newSimilar':
        return 'Imóvel Similar';
      case 'custom':
        return 'Alerta Personalizado';
      default:
        return type;
    }
  }

  /// Obtém cor do tipo de alerta
  Color _getAlertTypeColor(String type) {
    switch (type) {
      case 'priceDrop':
      case 'priceReduction':
        return Colors.red[100]!;
      case 'statusChange':
      case 'sold':
        return Colors.blue[100]!;
      case 'newProperty':
      case 'newSimilar':
        return Colors.green[100]!;
      case 'custom':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  /// Agrupa alertas por tipo
  Map<String, int> _groupAlertsByType(List<PropertyAlert> alerts) {
    final Map<String, int> grouped = {};
    for (final alert in alerts) {
      final type = alert.type.name;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }
}

/// Diálogo para criar alertas
class CreateAlertDialog extends StatefulWidget {
  final Function(PropertyAlert) onAlertCreated;

  const CreateAlertDialog({
    super.key,
    required this.onAlertCreated,
  });

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetPriceController = TextEditingController();
  final _propertyTitleController = TextEditingController();
  final _propertyIdController = TextEditingController();
  
  AlertType _selectedType = AlertType.priceReduction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Alerta'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de Alerta
              Text(
                'Tipo de Alerta',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AlertType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  AlertType.priceReduction,
                  AlertType.sold,
                  AlertType.newSimilar,
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAlertDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ID do Imóvel
              Text(
                'ID do Imóvel',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _propertyIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Ex: prop123',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o ID do imóvel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Título do Imóvel
              Text(
                'Título do Imóvel',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _propertyTitleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Ex: Apartamento 3 quartos',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o título do imóvel';
                  }
                  return null;
                },
              ),

              // Preço Alvo (apenas para redução de preço)
              if (_selectedType == AlertType.priceReduction) ...[
                const SizedBox(height: 16),
                Text(
                  'Preço Alvo (R\$)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetPriceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Ex: 800000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o preço alvo';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Digite um valor válido';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createAlert,
          child: const Text('Criar Alerta'),
        ),
      ],
    );
  }

  String _getAlertDisplayName(AlertType type) {
    switch (type) {
      case AlertType.priceReduction:
        return 'Redução de Preço';
      case AlertType.sold:
        return 'Imóvel Vendido';
      case AlertType.newSimilar:
        return 'Imóvel Similar';
      default:
        return type.name;
    }
  }

  void _createAlert() {
    if (_formKey.currentState!.validate()) {
      final alert = PropertyAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // TODO: Obter do AuthService
        propertyId: _propertyIdController.text,
        propertyTitle: _propertyTitleController.text,
        type: _selectedType,
        targetPrice: _selectedType == AlertType.priceReduction
            ? double.tryParse(_targetPriceController.text)
            : null,
        createdAt: DateTime.now(),
        criteria: AlertCriteria(),
        notificationSettings: NotificationSettings(),
      );

      widget.onAlertCreated(alert);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    _propertyTitleController.dispose();
    _propertyIdController.dispose();
    super.dispose();
  }
}