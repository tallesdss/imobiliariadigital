import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alert_model.dart' as alert_models;
import '../../services/notification_service.dart';

/// Tela para criar ou editar alertas
class CreateAlertScreen extends StatefulWidget {
  final alert_models.PropertyAlert? alert;

  const CreateAlertScreen({super.key, this.alert});

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  final NotificationService _notificationService = NotificationService();
  final _formKey = GlobalKey<FormState>();
  
  late alert_models.AlertType _selectedType;
  late alert_models.AlertCriteria _criteria;
  late alert_models.NotificationSettings _notificationSettings;
  
  // Controllers para os campos
  final _maxPriceController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _minBedroomsController = TextEditingController();
  final _maxBedroomsController = TextEditingController();
  final _minBathroomsController = TextEditingController();
  final _maxBathroomsController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();
  final _maxCondominiumController = TextEditingController();
  final _maxIptuController = TextEditingController();
  final _keywordsController = TextEditingController();

  bool _hasGarage = false;
  bool _acceptsProposal = false;
  bool _hasFinancing = false;
  alert_models.AlertPropertyType? _selectedPropertyType;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _maxPriceController.dispose();
    _minPriceController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _minBedroomsController.dispose();
    _maxBedroomsController.dispose();
    _minBathroomsController.dispose();
    _maxBathroomsController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    _maxCondominiumController.dispose();
    _maxIptuController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  /// Inicializa dados baseado no alerta existente (se editando)
  void _initializeData() {
    if (widget.alert != null) {
      final alert = widget.alert!;
      _selectedType = alert.type;
      _criteria = alert.criteria;
      _notificationSettings = alert.notificationSettings;

      // Preencher campos com dados existentes
      _maxPriceController.text = _criteria.maxPrice?.toString() ?? '';
      _minPriceController.text = _criteria.minPrice?.toString() ?? '';
      _cityController.text = _criteria.city ?? '';
      _neighborhoodController.text = _criteria.neighborhood ?? '';
      _minBedroomsController.text = _criteria.minBedrooms?.toString() ?? '';
      _maxBedroomsController.text = _criteria.maxBedrooms?.toString() ?? '';
      _minBathroomsController.text = _criteria.minBathrooms?.toString() ?? '';
      _maxBathroomsController.text = _criteria.maxBathrooms?.toString() ?? '';
      _minAreaController.text = _criteria.minArea?.toString() ?? '';
      _maxAreaController.text = _criteria.maxArea?.toString() ?? '';
      _maxCondominiumController.text = _criteria.maxCondominium?.toString() ?? '';
      _maxIptuController.text = _criteria.maxIptu?.toString() ?? '';
      _keywordsController.text = _criteria.keywords?.join(', ') ?? '';

      _hasGarage = _criteria.hasGarage ?? false;
      _acceptsProposal = _criteria.acceptsProposal ?? false;
      _hasFinancing = _criteria.hasFinancing ?? false;
      _selectedPropertyType = _criteria.propertyType;
    } else {
      _selectedType = alert_models.AlertType.newProperty;
      _criteria = alert_models.AlertCriteria();
      _notificationSettings = alert_models.NotificationSettings();
    }
  }

  /// Salva o alerta
  Future<void> _saveAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Construir critérios
      final criteria = alert_models.AlertCriteria(
        maxPrice: _maxPriceController.text.isNotEmpty 
            ? double.tryParse(_maxPriceController.text) 
            : null,
        minPrice: _minPriceController.text.isNotEmpty 
            ? double.tryParse(_minPriceController.text) 
            : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        neighborhood: _neighborhoodController.text.isNotEmpty 
            ? _neighborhoodController.text 
            : null,
        propertyType: _selectedPropertyType,
        minBedrooms: _minBedroomsController.text.isNotEmpty 
            ? int.tryParse(_minBedroomsController.text) 
            : null,
        maxBedrooms: _maxBedroomsController.text.isNotEmpty 
            ? int.tryParse(_maxBedroomsController.text) 
            : null,
        minBathrooms: _minBathroomsController.text.isNotEmpty 
            ? int.tryParse(_minBathroomsController.text) 
            : null,
        maxBathrooms: _maxBathroomsController.text.isNotEmpty 
            ? int.tryParse(_maxBathroomsController.text) 
            : null,
        minArea: _minAreaController.text.isNotEmpty 
            ? double.tryParse(_minAreaController.text) 
            : null,
        maxArea: _maxAreaController.text.isNotEmpty 
            ? double.tryParse(_maxAreaController.text) 
            : null,
        hasGarage: _hasGarage,
        acceptsProposal: _acceptsProposal,
        hasFinancing: _hasFinancing,
        maxCondominium: _maxCondominiumController.text.isNotEmpty 
            ? double.tryParse(_maxCondominiumController.text) 
            : null,
        maxIptu: _maxIptuController.text.isNotEmpty 
            ? double.tryParse(_maxIptuController.text) 
            : null,
        keywords: _keywordsController.text.isNotEmpty 
            ? _keywordsController.text.split(',').map((e) => e.trim()).toList()
            : null,
      );

      // Simular userId - em produção viria do AuthService
      const userId = 'current_user_id';

      if (widget.alert != null) {
        // Atualizar alerta existente
        final updatedAlert = widget.alert!.copyWith(
          type: _selectedType,
          criteria: criteria,
          notificationSettings: _notificationSettings,
        );
        
        final success = await _notificationService.updateAlert(updatedAlert);
        if (mounted) {
          if (success) {
            Navigator.pop(context, true);
            _showSnackBar('Alerta atualizado com sucesso');
          } else {
            _showSnackBar('Erro ao atualizar alerta');
          }
        }
      } else {
        // Criar novo alerta
        final alertId = await _notificationService.createAlert(
          userId: userId,
          type: _selectedType,
          criteria: criteria,
          notificationSettings: _notificationSettings,
        );
        
        if (mounted) {
          if (alertId != null) {
            Navigator.pop(context, true);
            _showSnackBar('Alerta criado com sucesso');
          } else {
            _showSnackBar('Erro ao criar alerta');
          }
        }
      }
    } catch (e) {
      _showSnackBar('Erro: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  /// Obtém nome do tipo de propriedade
  String _getPropertyTypeName(alert_models.AlertPropertyType type) {
    switch (type) {
      case alert_models.AlertPropertyType.apartment:
        return 'Apartamento';
      case alert_models.AlertPropertyType.house:
        return 'Casa';
      case alert_models.AlertPropertyType.commercial:
        return 'Comercial';
      case alert_models.AlertPropertyType.land:
        return 'Terreno';
      case alert_models.AlertPropertyType.rural:
        return 'Rural';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alert != null ? 'Editar Alerta' : 'Criar Alerta'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAlert,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAlertTypeSection(),
            const SizedBox(height: 24),
            _buildCriteriaSection(),
            const SizedBox(height: 24),
            _buildNotificationSettingsSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de tipo de alerta
  Widget _buildAlertTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Alerta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...alert_models.AlertType.values.map((type) => RadioListTile<alert_models.AlertType>(
              title: Text(_getAlertTypeName(type)),
              subtitle: Text(_getAlertTypeDescription(type)),
              value: type,
              // ignore: deprecated_member_use
              groupValue: _selectedType,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de critérios
  Widget _buildCriteriaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Critérios do Alerta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Preço
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Mínimo (R\$)',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Máximo (R\$)',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Localização
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                hintText: 'Ex: São Paulo',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                hintText: 'Ex: Vila Madalena',
              ),
            ),
            const SizedBox(height: 16),

            // Tipo de propriedade
            DropdownButtonFormField<alert_models.AlertPropertyType>(
              initialValue: _selectedPropertyType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Imóvel',
              ),
              items: alert_models.AlertPropertyType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(_getPropertyTypeName(type)),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPropertyType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Quartos
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBedroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Mín. Quartos',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxBedroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. Quartos',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Banheiros
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBathroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Mín. Banheiros',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxBathroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. Banheiros',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Área
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Área Mínima (m²)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Área Máxima (m²)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Características especiais
            const Text(
              'Características Especiais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Tem Garagem'),
              value: _hasGarage,
              onChanged: (value) {
                setState(() {
                  _hasGarage = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Aceita Proposta'),
              value: _acceptsProposal,
              onChanged: (value) {
                setState(() {
                  _acceptsProposal = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Tem Financiamento'),
              value: _hasFinancing,
              onChanged: (value) {
                setState(() {
                  _hasFinancing = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),

            // Condomínio e IPTU
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxCondominiumController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. Condomínio (R\$)',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxIptuController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. IPTU (R\$)',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Palavras-chave
            TextFormField(
              controller: _keywordsController,
              decoration: const InputDecoration(
                labelText: 'Palavras-chave',
                hintText: 'Ex: piscina, varanda, sacada (separadas por vírgula)',
                helperText: 'Palavras que devem aparecer no título ou descrição',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de configurações de notificação
  Widget _buildNotificationSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações de Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Notificações Push'),
              subtitle: const Text('Receber notificações no dispositivo'),
              value: _notificationSettings.pushEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationSettings = _notificationSettings.copyWith(
                    pushEnabled: value ?? true,
                  );
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Notificações por Email'),
              subtitle: const Text('Receber notificações por email'),
              value: _notificationSettings.emailEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationSettings = _notificationSettings.copyWith(
                    emailEnabled: value ?? false,
                  );
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Notificações por SMS'),
              subtitle: const Text('Receber notificações por SMS'),
              value: _notificationSettings.smsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationSettings = _notificationSettings.copyWith(
                    smsEnabled: value ?? false,
                  );
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Modo Silencioso'),
              subtitle: const Text('Pausar todas as notificações'),
              value: _notificationSettings.quietMode,
              onChanged: (value) {
                setState(() {
                  _notificationSettings = _notificationSettings.copyWith(
                    quietMode: value ?? false,
                  );
                });
              },
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
        onPressed: _isLoading ? null : _saveAlert,
        child: _isLoading
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
            : Text(widget.alert != null ? 'Atualizar Alerta' : 'Criar Alerta'),
      ),
    );
  }

  /// Obtém descrição do tipo de alerta
  String _getAlertTypeDescription(alert_models.AlertType type) {
    switch (type) {
      case alert_models.AlertType.priceDrop:
        return 'Notificar quando o preço de um imóvel baixar';
      case alert_models.AlertType.statusChange:
        return 'Notificar quando o status de um imóvel mudar';
      case alert_models.AlertType.newProperty:
        return 'Notificar sobre novos imóveis que atendem seus critérios';
      case alert_models.AlertType.custom:
        return 'Alerta personalizado com critérios específicos';
    }
  }
}

/// Extensão para copiar NotificationSettings
extension NotificationSettingsCopyWith on alert_models.NotificationSettings {
  alert_models.NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    List<int>? allowedHours,
    List<int>? allowedDays,
    int? maxNotificationsPerDay,
    bool? quietMode,
  }) {
    return alert_models.NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      allowedHours: allowedHours ?? this.allowedHours,
      allowedDays: allowedDays ?? this.allowedDays,
      maxNotificationsPerDay: maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      quietMode: quietMode ?? this.quietMode,
    );
  }
}
