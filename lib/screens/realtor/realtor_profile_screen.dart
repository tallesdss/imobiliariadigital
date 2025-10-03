import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../widgets/cards/property_card.dart';
import 'realtor_profile_edit_screen.dart';

class RealtorProfileScreen extends StatefulWidget {
  const RealtorProfileScreen({super.key});

  @override
  State<RealtorProfileScreen> createState() => _RealtorProfileScreenState();
}

class _RealtorProfileScreenState extends State<RealtorProfileScreen> {
  final String _realtorId = 'realtor1'; // Mock - usuário logado
  List<Property> _properties = [];
  bool _isLoading = true;

  // Mock data do corretor
  final Map<String, dynamic> _realtorData = {
    'name': 'Carlos Oliveira',
    'email': 'carlos@imobiliaria.com',
    'phone': '(11) 99999-3333',
    'creci': 'CRECI 12345-F',
    'bio': 'Corretor imobiliário com mais de 10 anos de experiência no mercado. Especializado em imóveis residenciais e comerciais de alto padrão.',
    'photo': 'https://ui-avatars.com/api/?name=Carlos+Oliveira&size=200&background=2196F3&color=fff',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
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

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtorProfileEditScreen(
          realtorData: _realtorData,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: _navigateToEditProfile,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildStatsSection(),
                  _buildPropertiesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Foto do perfil
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary,
            backgroundImage: _realtorData['photo'] != null
                ? NetworkImage(_realtorData['photo']!)
                : null,
            child: _realtorData['photo'] == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Nome
          Text(
            _realtorData['name']!,
            style: AppTypography.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          // CRECI
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _realtorData['creci']!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Bio
          if (_realtorData['bio'] != null) ...[
            Text(
              _realtorData['bio']!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          // Contatos
          _buildContactRow(
            Icons.email_outlined,
            _realtorData['email']!,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildContactRow(
            Icons.phone_outlined,
            _realtorData['phone']!,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final activeCount = _properties
        .where((p) => p.status == PropertyStatus.active)
        .length;
    final soldCount = _properties
        .where((p) => p.status == PropertyStatus.sold)
        .length;
    final totalCount = _properties.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              totalCount.toString(),
              AppColors.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Ativos',
              activeCount.toString(),
              AppColors.success,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Vendidos',
              soldCount.toString(),
              AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Meus Imóveis',
                style: AppTypography.h6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_properties.length} ${_properties.length == 1 ? 'imóvel' : 'imóveis'}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_properties.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nenhum imóvel cadastrado',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _properties.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                return PropertyCard(property: _properties[index]);
              },
            ),
        ],
      ),
    );
  }
}
