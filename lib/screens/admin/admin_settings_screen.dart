import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _autoBackup = true;
  bool _maintenanceMode = false;
  
  String _selectedLanguage = 'pt_BR';
  String _selectedTheme = 'light';
  String _backupFrequency = 'daily';
  
  final TextEditingController _companyNameController = TextEditingController(text: 'Imobiliária Digital');
  final TextEditingController _companyEmailController = TextEditingController(text: 'contato@imobiliariadigital.com');
  final TextEditingController _companyPhoneController = TextEditingController(text: '(11) 99999-9999');
  final TextEditingController _companyAddressController = TextEditingController(text: 'Rua das Flores, 123 - São Paulo/SP');

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Salvar',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.admin,
        userName: 'Administrador',
        userEmail: 'admin@imobiliaria.com',
        currentRoute: '/admin/settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyInfoSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildSystemSettingsSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildNotificationSettingsSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildBackupSettingsSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildSecuritySection(),
            const SizedBox(height: AppSpacing.xl),
            _buildDangerZoneSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoSection() {
    return _buildSection(
      title: 'Informações da Empresa',
      icon: Icons.business,
      children: [
        TextFormField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Nome da Empresa',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _companyEmailController,
          decoration: const InputDecoration(
            labelText: 'Email de Contato',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _companyPhoneController,
          decoration: const InputDecoration(
            labelText: 'Telefone de Contato',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _companyAddressController,
          decoration: const InputDecoration(
            labelText: 'Endereço da Empresa',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSystemSettingsSection() {
    return _buildSection(
      title: 'Configurações do Sistema',
      icon: Icons.settings,
      children: [
        Row(
          children: [
            Expanded(
              child:             DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Idioma',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pt_BR', child: Text('Português (Brasil)')),
                  DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
                  DropdownMenuItem(value: 'es_ES', child: Text('Español')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child:             DropdownButtonFormField<String>(
              initialValue: _selectedTheme,
                decoration: const InputDecoration(
                  labelText: 'Tema',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('Claro')),
                  DropdownMenuItem(value: 'dark', child: Text('Escuro')),
                  DropdownMenuItem(value: 'auto', child: Text('Automático')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          title: const Text('Modo de Manutenção'),
          subtitle: const Text('Desativa o acesso público à plataforma'),
          value: _maintenanceMode,
          onChanged: (value) {
            setState(() {
              _maintenanceMode = value;
            });
            if (value) {
              _showMaintenanceDialog();
            }
          },
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection() {
    return _buildSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('Notificações Gerais'),
          subtitle: const Text('Ativar/desativar todas as notificações'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) {
                _emailNotifications = false;
                _pushNotifications = false;
              }
            });
          },
          activeThumbColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Notificações por Email'),
          subtitle: const Text('Receber notificações por email'),
          value: _emailNotifications,
          onChanged: _notificationsEnabled ? (value) {
            setState(() {
              _emailNotifications = value;
            });
          } : null,
          activeThumbColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Notificações Push'),
          subtitle: const Text('Receber notificações push no dispositivo'),
          value: _pushNotifications,
          onChanged: _notificationsEnabled ? (value) {
            setState(() {
              _pushNotifications = value;
            });
          } : null,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildBackupSettingsSection() {
    return _buildSection(
      title: 'Backup e Segurança',
      icon: Icons.backup,
      children: [
        SwitchListTile(
          title: const Text('Backup Automático'),
          subtitle: const Text('Fazer backup automático dos dados'),
          value: _autoBackup,
          onChanged: (value) {
            setState(() {
              _autoBackup = value;
            });
          },
          activeThumbColor: AppColors.primary,
        ),
        if (_autoBackup) ...[
          const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _backupFrequency,
            decoration: const InputDecoration(
              labelText: 'Frequência do Backup',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Diário')),
              DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
              DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
            ],
            onChanged: (value) {
              setState(() {
                _backupFrequency = value!;
              });
            },
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _createBackup,
                icon: const Icon(Icons.backup),
                label: const Text('Criar Backup Agora'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restoreBackup,
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar Backup'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: 'Segurança',
      icon: Icons.security,
      children: [
        ListTile(
          leading: const Icon(Icons.lock, color: AppColors.primary),
          title: const Text('Alterar Senha'),
          subtitle: const Text('Alterar senha de administrador'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _changePassword,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.history, color: AppColors.primary),
          title: const Text('Log de Atividades'),
          subtitle: const Text('Visualizar histórico de atividades'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _viewActivityLog,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.devices, color: AppColors.primary),
          title: const Text('Dispositivos Conectados'),
          subtitle: const Text('Gerenciar sessões ativas'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _manageDevices,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.shield, color: AppColors.primary),
          title: const Text('Configurações de Segurança'),
          subtitle: const Text('Configurar autenticação e permissões'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _securitySettings,
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _buildSection(
      title: 'Zona de Perigo',
      icon: Icons.warning,
      color: AppColors.error,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ Ações Irreversíveis',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'As ações abaixo são permanentes e não podem ser desfeitas. Use com cuidado.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.clear_all, color: AppColors.warning),
                label: const Text('Limpar Cache'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.restore, color: AppColors.error),
                label: const Text('Resetar Configurações'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _deleteAllData,
            icon: const Icon(Icons.delete_forever, color: AppColors.error),
            label: const Text('Excluir Todos os Dados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo de Manutenção'),
        content: const Text(
          'O modo de manutenção foi ativado. Os usuários não conseguirão acessar a plataforma até que seja desativado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações salvas com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _createBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Backup'),
        content: const Text('Deseja criar um backup dos dados agora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup criado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: const Text('Deseja restaurar um backup? Todos os dados atuais serão substituídos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup restaurado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Senha alterada com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _viewActivityLog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo log de atividades...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _manageDevices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo gerenciamento de dispositivos...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _securitySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo configurações de segurança...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Cache'),
        content: const Text('Deseja limpar o cache da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache limpo com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configurações'),
        content: const Text('Deseja resetar todas as configurações para os valores padrão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações resetadas!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Excluir Todos os Dados'),
        content: const Text(
          'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\n'
          'Todos os dados da plataforma serão permanentemente excluídos, incluindo:\n'
          '• Todos os imóveis\n'
          '• Todos os corretores\n'
          '• Todas as conversas\n'
          '• Todas as configurações\n\n'
          'Tem certeza absoluta que deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os dados foram excluídos!'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('EXCLUIR TUDO'),
          ),
        ],
      ),
    );
  }
}
