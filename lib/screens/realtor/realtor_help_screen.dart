import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_drawer.dart';

class RealtorHelpScreen extends StatefulWidget {
  const RealtorHelpScreen({super.key});

  @override
  State<RealtorHelpScreen> createState() => _RealtorHelpScreenState();
}

class _RealtorHelpScreenState extends State<RealtorHelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Como cadastrar um novo imóvel?',
      'answer': 'Para cadastrar um novo imóvel, acesse o menu lateral e clique em "Cadastrar Imóvel". Preencha todas as informações solicitadas, incluindo fotos e vídeos, e clique em "Salvar".',
      'category': 'Cadastro',
    },
    {
      'question': 'Como editar um imóvel existente?',
      'answer': 'Na tela "Meus Imóveis", clique no imóvel que deseja editar e selecione a opção "Editar". Faça as alterações necessárias e salve.',
      'category': 'Edição',
    },
    {
      'question': 'Como arquivar um imóvel?',
      'answer': 'Imóveis arquivados ficam invisíveis para os usuários. Para arquivar, acesse o imóvel e clique em "Arquivar". Você pode reativá-lo a qualquer momento.',
      'category': 'Gestão',
    },
    {
      'question': 'Como responder mensagens de interessados?',
      'answer': 'Acesse a seção "Mensagens" no menu lateral. Lá você encontrará todas as conversas com usuários interessados nos seus imóveis.',
      'category': 'Comunicação',
    },
    {
      'question': 'Como visualizar meu desempenho?',
      'answer': 'Na seção "Relatórios" você pode acompanhar estatísticas como total de imóveis, taxa de conversão e gráficos de desempenho.',
      'category': 'Relatórios',
    },
    {
      'question': 'Como atualizar meus dados pessoais?',
      'answer': 'Acesse "Meu Perfil" no menu lateral e clique em "Editar Perfil" para atualizar suas informações pessoais e profissionais.',
      'category': 'Perfil',
    },
  ];

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'title': 'Suporte Técnico',
      'description': 'Problemas técnicos e bugs',
      'icon': Icons.bug_report,
      'contact': 'suporte@imobiliaria.com',
      'phone': '(11) 3000-0000',
    },
    {
      'title': 'Suporte Comercial',
      'description': 'Dúvidas sobre planos e funcionalidades',
      'icon': Icons.business,
      'contact': 'comercial@imobiliaria.com',
      'phone': '(11) 3000-0001',
    },
    {
      'title': 'Suporte Financeiro',
      'description': 'Questões sobre pagamentos e cobrança',
      'icon': Icons.account_balance,
      'contact': 'financeiro@imobiliaria.com',
      'phone': '(11) 3000-0002',
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqItems {
    if (_searchQuery.isEmpty) return _faqItems;
    
    return _faqItems.where((item) {
      return item['question'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item['answer'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item['category'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajuda e Suporte',
          style: AppTypography.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.realtor,
        userName: 'Carlos Oliveira',
        userEmail: 'carlos@imobiliaria.com',
        currentRoute: '/realtor/help',
        userCreci: 'CRECI 12345-F',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickActions(),
            const SizedBox(height: AppSpacing.lg),
            _buildFaqSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildContactSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildDocumentationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como podemos ajudar?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar na base de conhecimento...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {
        'title': 'Tutorial Inicial',
        'description': 'Aprenda a usar a plataforma',
        'icon': Icons.play_circle_outline,
        'action': () => _showTutorial(),
      },
      {
        'title': 'Vídeos Explicativos',
        'description': 'Assista aos tutoriais em vídeo',
        'icon': Icons.video_library,
        'action': () => _openVideoTutorials(),
      },
      {
        'title': 'Chat ao Vivo',
        'description': 'Fale com nosso suporte',
        'icon': Icons.chat,
        'action': () => _openLiveChat(),
      },
      {
        'title': 'Reportar Problema',
        'description': 'Informe bugs ou problemas',
        'icon': Icons.report_problem,
        'action': () => _reportProblem(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: quickActions.map<Widget>((action) {
            return GestureDetector(
              onTap: action['action'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      action['title'] as String,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      action['description'] as String,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Perguntas Frequentes',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
          const SizedBox(height: AppSpacing.md),
          ..._filteredFaqItems.map((item) {
            return ExpansionTile(
              title: Text(
                item['question'],
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item['category'],
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    item['answer'],
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Contato e Suporte',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
          const SizedBox(height: AppSpacing.md),
          ..._contactOptions.map((contact) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: Icon(
                  contact['icon'],
                  color: AppColors.primary,
                ),
                title: Text(
                  contact['title'],
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(contact['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.email),
                      onPressed: () => _sendEmail(contact['contact']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _makeCall(contact['phone']),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocumentationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Documentação',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
          const SizedBox(height: AppSpacing.md),
          _buildDocumentationItem(
            'Manual do Corretor',
            'Guia completo de uso da plataforma',
            Icons.book,
            () => _openDocumentation('manual'),
          ),
          _buildDocumentationItem(
            'Política de Privacidade',
            'Como protegemos seus dados',
            Icons.privacy_tip,
            () => _openDocumentation('privacy'),
          ),
          _buildDocumentationItem(
            'Termos de Uso',
            'Condições de uso da plataforma',
            Icons.description,
            () => _openDocumentation('terms'),
          ),
          _buildDocumentationItem(
            'FAQ Completo',
            'Lista completa de perguntas frequentes',
            Icons.help_outline,
            () => _openDocumentation('faq'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentationItem(String title, String description, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Inicial'),
        content: const Text('Em breve disponível!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openVideoTutorials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vídeos Explicativos'),
        content: const Text('Em breve disponível!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat ao Vivo'),
        content: const Text('Em breve disponível!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _reportProblem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: const Text('Em breve disponível!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Suporte - Imobiliária Digital',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o email: $email')),
        );
      }
    }
  }

  void _makeCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível fazer a ligação: $phone')),
        );
      }
    }
  }

  void _openDocumentation(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Documentação - ${type.toUpperCase()}'),
        content: const Text('Em breve disponível!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
