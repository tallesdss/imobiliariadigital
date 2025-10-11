import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class InteractiveTutorialScreen extends StatefulWidget {
  const InteractiveTutorialScreen({super.key});

  @override
  State<InteractiveTutorialScreen> createState() => _InteractiveTutorialScreenState();
}

class _InteractiveTutorialScreenState extends State<InteractiveTutorialScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Bem-vindo à Imobiliária Digital!',
      description: 'Vamos te guiar pelos principais recursos da plataforma para maximizar suas vendas.',
      icon: Icons.home,
      content: const WelcomeStep(),
    ),
    TutorialStep(
      title: 'Cadastrando seu Primeiro Imóvel',
      description: 'Aprenda como cadastrar imóveis de forma eficiente e atrativa.',
      icon: Icons.add_home,
      content: const PropertyRegistrationStep(),
    ),
    TutorialStep(
      title: 'Gerenciando seus Imóveis',
      description: 'Saiba como organizar e atualizar seus imóveis cadastrados.',
      icon: Icons.manage_accounts,
      content: const PropertyManagementStep(),
    ),
    TutorialStep(
      title: 'Acompanhando Leads',
      description: 'Entenda como gerenciar interessados e converter em vendas.',
      icon: Icons.people,
      content: const LeadsManagementStep(),
    ),
    TutorialStep(
      title: 'Relatórios e Performance',
      description: 'Monitore seu desempenho e identifique oportunidades.',
      icon: Icons.analytics,
      content: const ReportsStep(),
    ),
    TutorialStep(
      title: 'Configurações e Perfil',
      description: 'Personalize sua conta e configure notificações.',
      icon: Icons.settings,
      content: const SettingsStep(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tutorial Interativo',
          style: AppTypography.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _skipTutorial,
              child: const Text(
                'Pular',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepContent(_steps[index]);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Passo ${_currentStep + 1} de ${_steps.length}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / _steps.length * 100).round()}%',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(step),
          const SizedBox(height: AppSpacing.lg),
          step.content,
        ],
      ),
    );
  }

  Widget _buildStepHeader(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            step.icon,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            step.title,
            style: AppTypography.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            step.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Anterior'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == _steps.length - 1 ? _finishTutorial : _nextStep,
              child: Text(_currentStep == _steps.length - 1 ? 'Finalizar' : 'Próximo'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pular Tutorial'),
        content: const Text('Tem certeza que deseja pular o tutorial? Você pode acessá-lo novamente a qualquer momento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Pular'),
          ),
        ],
      ),
    );
  }

  void _finishTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Concluído!'),
        content: const Text('Parabéns! Você completou o tutorial. Agora você está pronto para usar a plataforma com eficiência.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Começar a Usar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Widget content;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
  });
}

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que você vai aprender:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFeatureItem(
          Icons.add_home,
          'Cadastro de Imóveis',
          'Como cadastrar imóveis de forma eficiente com fotos e descrições atrativas',
        ),
        _buildFeatureItem(
          Icons.people,
          'Gestão de Leads',
          'Como gerenciar interessados e converter em vendas',
        ),
        _buildFeatureItem(
          Icons.analytics,
          'Relatórios',
          'Como acompanhar seu desempenho e identificar oportunidades',
        ),
        _buildFeatureItem(
          Icons.settings,
          'Configurações',
          'Como personalizar sua conta e otimizar seu trabalho',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Dica: Você pode pular o tutorial a qualquer momento e acessá-lo novamente no menu de ajuda.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyRegistrationStep extends StatelessWidget {
  const PropertyRegistrationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passos para cadastrar um imóvel:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStepItem('1', 'Informações Básicas', 'Preencha tipo, localização, preço e descrição'),
        _buildStepItem('2', 'Características', 'Adicione quartos, banheiros, área e outras características'),
        _buildStepItem('3', 'Fotos e Vídeos', 'Faça upload de imagens atrativas e vídeos do imóvel'),
        _buildStepItem('4', 'Configurações', 'Defina se o imóvel está em destaque e aceita propostas'),
        _buildStepItem('5', 'Publicar', 'Revise as informações e publique o imóvel'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.green),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Dica: Imóveis com fotos de qualidade e descrições detalhadas recebem 3x mais visualizações!',
                  style: AppTypography.bodySmall.copyWith(color: Colors.green.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyManagementStep extends StatelessWidget {
  const PropertyManagementStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gerenciando seus imóveis:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildManagementItem(
          Icons.edit,
          'Editar Imóveis',
          'Atualize informações, preços e características a qualquer momento',
        ),
        _buildManagementItem(
          Icons.visibility,
          'Visualizações',
          'Acompanhe quantas pessoas visualizaram cada imóvel',
        ),
        _buildManagementItem(
          Icons.archive,
          'Arquivar',
          'Arquive imóveis vendidos ou indisponíveis',
        ),
        _buildManagementItem(
          Icons.star,
          'Destaque',
          'Destaque seus melhores imóveis para mais visibilidade',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Lembrete: Atualize regularmente as informações dos seus imóveis para manter os interessados engajados.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagementItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeadsManagementStep extends StatelessWidget {
  const LeadsManagementStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Convertendo leads em vendas:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLeadItem(
          Icons.message,
          'Responda Rapidamente',
          'Leads respondidos em até 5 minutos têm 9x mais chances de conversão',
        ),
        _buildLeadItem(
          Icons.info,
          'Seja Informativo',
          'Forneça todas as informações solicitadas de forma clara e objetiva',
        ),
        _buildLeadItem(
          Icons.phone,
          'Agende Visitas',
          'Proponha visitas presenciais para fechar negócios',
        ),
        _buildLeadItem(
          Icons.follow_the_signs,
          'Acompanhe o Processo',
          'Mantenha contato regular até a conclusão da venda',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.purple),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Estatística: Corretores que respondem leads em até 5 minutos vendem 50% mais!',
                  style: AppTypography.bodySmall.copyWith(color: Colors.purple.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeadItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsStep extends StatelessWidget {
  const ReportsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acompanhando seu desempenho:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildReportItem(
          Icons.analytics,
          'Métricas Principais',
          'Visualizações, leads, conversões e faturamento',
        ),
        _buildReportItem(
          Icons.trending_up,
          'Gráficos de Performance',
          'Acompanhe sua evolução ao longo do tempo',
        ),
        _buildReportItem(
          Icons.flag,
          'Metas e Objetivos',
          'Defina e acompanhe suas metas de vendas',
        ),
        _buildReportItem(
          Icons.download,
          'Exportação',
          'Exporte relatórios em PDF ou Excel',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insights, color: Colors.teal),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Dica: Analise seus relatórios semanalmente para identificar padrões e oportunidades de melhoria.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsStep extends StatelessWidget {
  const SettingsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurando sua conta:',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSettingItem(
          Icons.person,
          'Perfil Profissional',
          'Mantenha suas informações atualizadas e profissionais',
        ),
        _buildSettingItem(
          Icons.notifications,
          'Notificações',
          'Configure alertas para novos leads e mensagens',
        ),
        _buildSettingItem(
          Icons.security,
          'Segurança',
          'Mantenha sua senha segura e atualizada',
        ),
        _buildSettingItem(
          Icons.help,
          'Suporte',
          'Acesse nossa base de conhecimento e suporte técnico',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.red),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Importante: Mantenha sempre seus dados atualizados para receber leads qualificados.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
