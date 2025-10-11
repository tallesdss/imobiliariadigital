import 'package:flutter/material.dart';
import '../../models/alert_model.dart' as alert_models;
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

/// Tela de configurações de alertas
class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  late alert_models.NotificationSettings _globalSettings;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Carrega configurações globais
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simular carregamento de configurações globais
      // Em produção, isso viria do banco de dados
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _globalSettings = alert_models.NotificationSettings();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Salva configurações
  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Simular salvamento de configurações
      // Em produção, isso salvaria no banco de dados
      await Future.delayed(const Duration(seconds: 1));
      
      _showSnackBar('Configurações salvas com sucesso');
    } catch (e) {
      _showSnackBar('Erro ao salvar configurações: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Mostra snackbar com mensagem
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Atualiza configuração
  void _updateSetting(String key, dynamic value) {
    setState(() {
      switch (key) {
        case 'pushEnabled':
          _globalSettings = _globalSettings.copyWith(pushEnabled: value);
          break;
        case 'emailEnabled':
          _globalSettings = _globalSettings.copyWith(emailEnabled: value);
          break;
        case 'smsEnabled':
          _globalSettings = _globalSettings.copyWith(smsEnabled: value);
          break;
        case 'quietMode':
          _globalSettings = _globalSettings.copyWith(quietMode: value);
          break;
        case 'maxNotificationsPerDay':
          _globalSettings = _globalSettings.copyWith(maxNotificationsPerDay: value);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Alertas'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveSettings,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar configurações',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSettings,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildNotificationTypesSection(),
                    const SizedBox(height: 24),
                    _buildTimingSection(),
                    const SizedBox(height: 24),
                    _buildLimitsSection(),
                    const SizedBox(height: 24),
                    _buildAdvancedSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
    );
  }

  /// Constrói seção de tipos de notificação
  Widget _buildNotificationTypesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipos de Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Notificações Push'),
              subtitle: const Text('Receber notificações no dispositivo'),
              value: _globalSettings.pushEnabled,
              onChanged: (value) => _updateSetting('pushEnabled', value),
              secondary: const Icon(Icons.notifications),
            ),
            
            SwitchListTile(
              title: const Text('Notificações por Email'),
              subtitle: const Text('Receber notificações por email'),
              value: _globalSettings.emailEnabled,
              onChanged: (value) => _updateSetting('emailEnabled', value),
              secondary: const Icon(Icons.email),
            ),
            
            SwitchListTile(
              title: const Text('Notificações por SMS'),
              subtitle: const Text('Receber notificações por SMS'),
              value: _globalSettings.smsEnabled,
              onChanged: (value) => _updateSetting('smsEnabled', value),
              secondary: const Icon(Icons.sms),
            ),
            
            SwitchListTile(
              title: const Text('Modo Silencioso'),
              subtitle: const Text('Pausar todas as notificações'),
              value: _globalSettings.quietMode,
              onChanged: (value) => _updateSetting('quietMode', value),
              secondary: const Icon(Icons.volume_off),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de horários
  Widget _buildTimingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horários de Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Horários Permitidos'),
              subtitle: Text(_formatAllowedHours()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHoursDialog(),
            ),
            
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Dias da Semana'),
              subtitle: Text(_formatAllowedDays()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDaysDialog(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de limites
  Widget _buildLimitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Limites de Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Máximo por Dia'),
              subtitle: Text('${_globalSettings.maxNotificationsPerDay} notificações'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_globalSettings.maxNotificationsPerDay > 1) {
                        _updateSetting('maxNotificationsPerDay', 
                            _globalSettings.maxNotificationsPerDay - 1);
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${_globalSettings.maxNotificationsPerDay}'),
                  IconButton(
                    onPressed: () {
                      if (_globalSettings.maxNotificationsPerDay < 50) {
                        _updateSetting('maxNotificationsPerDay', 
                            _globalSettings.maxNotificationsPerDay + 1);
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção avançada
  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações Avançadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: const Text('Limpar Histórico'),
              subtitle: const Text('Remover alertas antigos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCleanupDialog(),
            ),
            
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Estatísticas'),
              subtitle: const Text('Ver estatísticas de alertas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStatsDialog(),
            ),
            
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              subtitle: const Text('Como funcionam os alertas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHelpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói botão de salvar
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Salvando...'),
                ],
              )
            : const Text('Salvar Configurações'),
      ),
    );
  }

  /// Formata horários permitidos
  String _formatAllowedHours() {
    if (_globalSettings.allowedHours.isEmpty) {
      return 'Nenhum horário';
    }
    
    final hours = _globalSettings.allowedHours.toList()..sort();
    if (hours.length == 24) {
      return '24 horas por dia';
    }
    
    return '${hours.first}:00 - ${hours.last}:00';
  }

  /// Formata dias permitidos
  String _formatAllowedDays() {
    if (_globalSettings.allowedDays.length == 7) {
      return 'Todos os dias';
    }
    
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final selectedDays = _globalSettings.allowedDays
        .map((day) => dayNames[day - 1])
        .toList();
    
    return selectedDays.join(', ');
  }

  /// Mostra diálogo de horários
  void _showHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Horários Permitidos'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = index;
              final isSelected = _globalSettings.allowedHours.contains(hour);
              
              return CheckboxListTile(
                title: Text('${hour.toString().padLeft(2, '0')}:00'),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    final newHours = List<int>.from(_globalSettings.allowedHours);
                    if (value == true) {
                      newHours.add(hour);
                    } else {
                      newHours.remove(hour);
                    }
                    _globalSettings = _globalSettings.copyWith(allowedHours: newHours);
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de dias
  void _showDaysDialog() {
    final dayNames = [
      'Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira',
      'Quinta-feira', 'Sexta-feira', 'Sábado'
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dias da Semana'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = _globalSettings.allowedDays.contains(day);
              
              return CheckboxListTile(
                title: Text(dayNames[index]),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    final newDays = List<int>.from(_globalSettings.allowedDays);
                    if (value == true) {
                      newDays.add(day);
                    } else {
                      newDays.remove(day);
                    }
                    _globalSettings = _globalSettings.copyWith(allowedDays: newDays);
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de limpeza
  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text(
          'Isso irá remover alertas antigos do histórico. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cleanupHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  /// Limpa histórico
  Future<void> _cleanupHistory() async {
    try {
      await _notificationService.cleanupOldHistory();
      _showSnackBar('Histórico limpo com sucesso');
    } catch (e) {
      _showSnackBar('Erro ao limpar histórico: $e');
    }
  }

  /// Mostra diálogo de estatísticas
  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas de Alertas'),
        content: const Text(
          'Aqui você veria estatísticas detalhadas sobre seus alertas, '
          'como número de disparos, tipos mais comuns, etc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de ajuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como Funcionam os Alertas'),
        content: const SingleChildScrollView(
          child: Text(
            'Os alertas são notificações automáticas sobre imóveis que '
            'atendem aos critérios que você definiu.\n\n'
            'Tipos de alertas:\n'
            '• Redução de Preço: Quando o preço de um imóvel baixa\n'
            '• Mudança de Status: Quando o status muda (vendido, alugado)\n'
            '• Novo Imóvel: Quando um novo imóvel atende seus critérios\n'
            '• Personalizado: Alertas com critérios específicos\n\n'
            'Você pode configurar quando e como receber essas notificações.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
