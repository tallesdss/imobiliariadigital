import 'package:flutter/material.dart';
import '../../models/alert_model.dart' as alert_models;
import '../../services/notification_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'create_alert_screen.dart';
import 'alert_settings_screen.dart';

/// Tela de gerenciamento de alertas do usuário
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  
  List<alert_models.PropertyAlert> _alerts = [];
  List<alert_models.AlertHistory> _history = [];
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
      // Simular userId - em produção viria do AuthService
      const userId = 'current_user_id';
      
      final results = await Future.wait([
        _notificationService.getUserAlerts(userId),
        _notificationService.getAlertHistory(userId),
        _notificationService.getAlertStats(userId),
      ]);

      setState(() {
        _alerts = results[0] as List<alert_models.PropertyAlert>;
        _history = results[1] as List<alert_models.AlertHistory>;
        _stats = results[2] as Map<String, dynamic>;
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAlertScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Edita um alerta existente
  Future<void> _editAlert(alert_models.PropertyAlert alert) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAlertScreen(alert: alert),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Remove um alerta
  Future<void> _deleteAlert(alert_models.PropertyAlert alert) async {
    final confirmed = await _showDeleteConfirmation(alert);
    if (confirmed == true) {
      final success = await _notificationService.deleteAlert(alert.id);
      if (success) {
        _loadData();
        _showSnackBar('Alerta removido com sucesso');
      } else {
        _showSnackBar('Erro ao remover alerta');
      }
    }
  }

  /// Alterna status ativo/inativo do alerta
  Future<void> _toggleAlertStatus(alert_models.PropertyAlert alert) async {
    final updatedAlert = alert.copyWith(isActive: !alert.isActive);
    final success = await _notificationService.updateAlert(updatedAlert);
    
    if (success) {
      _loadData();
      _showSnackBar(
        alert.isActive ? 'Alerta pausado' : 'Alerta ativado',
      );
    } else {
      _showSnackBar('Erro ao atualizar alerta');
    }
  }

  /// Marca alerta como lido
  Future<void> _markAsRead(alert_models.AlertHistory history) async {
    final success = await _notificationService.markAlertAsRead(history.id);
    if (success) {
      _loadData();
    }
  }

  /// Mostra confirmação de exclusão
  Future<bool?> _showDeleteConfirmation(alert_models.PropertyAlert alert) {
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
  String _getAlertTypeName(alert_models.AlertType type) {
    switch (type) {
      case alert_models.AlertType.priceDrop:
        return 'Redução de Preço';
      case alert_models.AlertType.statusChange:
        return 'Mudança de Status';
      case alert_models.AlertType.newProperty:
        return 'Novo Imóvel';
      case alert_models.AlertType.custom:
        return 'Personalizado';
    }
  }

  /// Formata data
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formata data e hora
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final history = _history[index];
          return _buildHistoryCard(history);
        },
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
  Widget _buildAlertCard(alert_models.PropertyAlert alert) {
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
            if (alert.triggerCount > 0)
              Text('Disparado ${alert.triggerCount} vezes'),
            if (alert.lastTriggered != null)
              Text('Último disparo: ${_formatDateTime(alert.lastTriggered!)}'),
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
  Widget _buildHistoryCard(alert_models.AlertHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: history.wasRead ? Colors.grey : Colors.blue,
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
        subtitle: Text(_formatDateTime(history.triggeredAt)),
        trailing: history.wasRead
            ? null
            : IconButton(
                onPressed: () => _markAsRead(history),
                icon: const Icon(Icons.mark_email_read),
                tooltip: 'Marcar como lido',
              ),
        onTap: () {
          // Navegar para detalhes do imóvel
          // NavigationService.navigateToPropertyDetail(history.propertyId);
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

  /// Obtém ícone do tipo de alerta
  IconData _getAlertTypeIcon(alert_models.AlertType type) {
    switch (type) {
      case alert_models.AlertType.priceDrop:
        return Icons.trending_down;
      case alert_models.AlertType.statusChange:
        return Icons.swap_horiz;
      case alert_models.AlertType.newProperty:
        return Icons.home_work;
      case alert_models.AlertType.custom:
        return Icons.tune;
    }
  }

  /// Obtém nome do tipo de alerta a partir da string
  String _getAlertTypeNameFromString(String type) {
    switch (type) {
      case 'priceDrop':
        return 'Redução de Preço';
      case 'statusChange':
        return 'Mudança de Status';
      case 'newProperty':
        return 'Novo Imóvel';
      case 'custom':
        return 'Personalizado';
      default:
        return type;
    }
  }

  /// Obtém cor do tipo de alerta
  Color _getAlertTypeColor(String type) {
    switch (type) {
      case 'priceDrop':
        return Colors.red[100]!;
      case 'statusChange':
        return Colors.blue[100]!;
      case 'newProperty':
        return Colors.green[100]!;
      case 'custom':
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}