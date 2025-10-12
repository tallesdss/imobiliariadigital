import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/favorite_model.dart';
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
  List<Map<String, dynamic>> _history = []; // TODO: Implementar modelo de histórico
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
      
      // Carregar alertas usando AlertService
      final alerts = await AlertService.getUserAlerts();
      
      setState(() {
        _alerts = alerts;
        _history = []; // TODO: Implementar histórico de alertas
        _stats = {
          'totalAlerts': alerts.length,
          'activeAlerts': alerts.where((a) => a.isActive).length,
          'totalTriggers': 0, // TODO: Implementar contagem de disparos
          'unreadAlerts': 0, // TODO: Implementar notificações não lidas
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
    // TODO: Implementar tela de criação de alertas
    _showSnackBar('Funcionalidade de criação em desenvolvimento');
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
      case AlertType.priceReduction:
        return 'Redução de Preço';
      case AlertType.sold:
        return 'Imóvel Vendido';
      case AlertType.newSimilar:
        return 'Imóvel Similar';
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
  Widget _buildHistoryCard(Map<String, dynamic> history) {
    // TODO: Implementar quando histórico estiver disponível
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          child: const Icon(
            Icons.history,
            color: Colors.white,
          ),
        ),
        title: const Text('Histórico não disponível'),
        subtitle: const Text('Funcionalidade em desenvolvimento'),
        onTap: () {
          // TODO: Implementar navegação quando histórico estiver disponível
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
  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.priceReduction:
        return Icons.trending_down;
      case AlertType.sold:
        return Icons.check_circle;
      case AlertType.newSimilar:
        return Icons.home_work;
    }
  }

  /// Obtém nome do tipo de alerta a partir da string
  String _getAlertTypeNameFromString(String type) {
    switch (type) {
      case 'priceReduction':
        return 'Redução de Preço';
      case 'sold':
        return 'Imóvel Vendido';
      case 'newSimilar':
        return 'Imóvel Similar';
      default:
        return type;
    }
  }

  /// Obtém cor do tipo de alerta
  Color _getAlertTypeColor(String type) {
    switch (type) {
      case 'priceReduction':
        return Colors.red[100]!;
      case 'sold':
        return Colors.blue[100]!;
      case 'newSimilar':
        return Colors.green[100]!;
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