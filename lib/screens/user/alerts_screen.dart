import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../models/favorite_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_button.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<PropertyAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _alerts = MockDataService.getUserAlerts('user1');
        _isLoading = false;
      });
    });
  }

  void _showCreateAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAlertDialog(
        onAlertCreated: (alert) {
          MockDataService.addAlert(alert);
          _loadAlerts();
        },
      ),
    );
  }

  void _removeAlert(String alertId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Alerta'),
        content: const Text('Tem certeza que deseja remover este alerta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              MockDataService.removeAlert(alertId);
              Navigator.pop(context);
              _loadAlerts();
            },
            child: const Text('Remover'),
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
        title: const Text('Meus Alertas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: _showCreateAlertDialog,
            icon: const Icon(Icons.add_alert),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlertDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    if (_alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: isTablet ? 100 : 80,
                color: AppColors.textHint,
              ),
              SizedBox(height: isTablet ? 32 : AppSpacing.lg),
              Text(
                'Nenhum alerta criado',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
              SizedBox(height: isTablet ? 16 : AppSpacing.sm),
              Text(
                'Crie alertas para ser notificado sobre\nmudanças nos imóveis de interesse',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 40 : AppSpacing.xl),
              CustomButton(
                text: 'Criar Primeiro Alerta',
                onPressed: _showCreateAlertDialog,
                type: ButtonType.filled,
                size: isTablet ? ButtonSize.large : ButtonSize.medium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : AppSpacing.lg),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(PropertyAlert alert) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : AppSpacing.md),
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
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.propertyTitle,
                    style: AppTypography.subtitle1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeAlert(alert.id),
                  icon: Icon(
                    Icons.close, 
                    color: AppColors.textHint,
                    size: isTablet ? 24 : 20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : AppSpacing.sm),
            Row(
              children: [
                Icon(
                  _getAlertIcon(alert.type),
                  size: isTablet ? 24 : 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: isTablet ? 12 : AppSpacing.sm),
                Text(
                  alert.typeDisplayName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
            if (alert.targetPrice != null) ...[
              SizedBox(height: isTablet ? 16 : AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: isTablet ? 24 : 20,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: isTablet ? 12 : AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Preço alvo: R\$ ${alert.targetPrice!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isTablet ? 20 : AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criado em ${_formatDate(alert.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                SimpleBadge(
                  text: alert.isActive ? 'Ativo' : 'Inativo',
                  backgroundColor: alert.isActive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.textHint.withValues(alpha: 0.1),
                  textColor: alert.isActive
                      ? AppColors.success
                      : AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.priceReduction:
        return Icons.trending_down;
      case AlertType.sold:
        return Icons.verified;
      case AlertType.newSimilar:
        return Icons.search;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class CreateAlertDialog extends StatefulWidget {
  final Function(PropertyAlert) onAlertCreated;

  const CreateAlertDialog({super.key, required this.onAlertCreated});

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetPriceController = TextEditingController();
  AlertType _selectedType = AlertType.priceReduction;
  String? _selectedPropertyId;

  @override
  Widget build(BuildContext context) {
    final properties = MockDataService.activeProperties;

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
              Text('Tipo de Alerta', style: AppTypography.subtitle2),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<AlertType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: AlertType.values.map((type) {
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
              const SizedBox(height: AppSpacing.md),
              Text('Imóvel', style: AppTypography.subtitle2),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _selectedPropertyId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                hint: const Text('Selecione um imóvel'),
                items: properties.map((property) {
                  return DropdownMenuItem(
                    value: property.id,
                    child: Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um imóvel';
                  }
                  return null;
                },
              ),
              if (_selectedType == AlertType.priceReduction) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Preço Alvo (R\$)', style: AppTypography.subtitle2),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _targetPriceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
    }
  }

  void _createAlert() {
    if (_formKey.currentState!.validate()) {
      final property = MockDataService.getPropertyById(_selectedPropertyId!);
      if (property != null) {
        final alert = PropertyAlert(
          id: '',
          userId: 'user1',
          propertyId: property.id,
          propertyTitle: property.title,
          type: _selectedType,
          targetPrice: _selectedType == AlertType.priceReduction
              ? double.tryParse(_targetPriceController.text)
              : null,
          createdAt: DateTime.now(),
        );

        widget.onAlertCreated(alert);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }
}
