import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class RealtorProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> realtorData;

  const RealtorProfileEditScreen({
    super.key,
    required this.realtorData,
  });

  @override
  State<RealtorProfileEditScreen> createState() =>
      _RealtorProfileEditScreenState();
}

class _RealtorProfileEditScreenState extends State<RealtorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _creciController;
  late TextEditingController _bioController;
  late TextEditingController _photoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.realtorData['name']);
    _emailController = TextEditingController(text: widget.realtorData['email']);
    _phoneController = TextEditingController(text: widget.realtorData['phone']);
    _creciController = TextEditingController(text: widget.realtorData['creci']);
    _bioController = TextEditingController(text: widget.realtorData['bio']);
    _photoController = TextEditingController(text: widget.realtorData['photo']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _creciController.dispose();
    _bioController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simular salvamento
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildPhotoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildPersonalInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildProfessionalInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Foto do Perfil', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary,
            backgroundImage: _photoController.text.isNotEmpty
                ? NetworkImage(_photoController.text)
                : null,
            child: _photoController.text.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _photoController,
            label: 'URL da Foto',
            hintText: 'https://exemplo.com/foto.jpg',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Insira a URL de uma foto ou deixe em branco para usar o avatar padrão',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações Pessoais', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _nameController,
            label: 'Nome Completo',
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _emailController,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Obrigatório';
              if (!value!.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _phoneController,
            label: 'Telefone',
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações Profissionais', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _creciController,
            label: 'CRECI',
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Biografia',
              hintText: 'Conte um pouco sobre sua experiência...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Salvar Alterações',
        onPressed: _saveProfile,
        isLoading: _isLoading,
      ),
    );
  }
}

