import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminHelpScreen extends StatefulWidget {
  const AdminHelpScreen({super.key});

  @override
  State<AdminHelpScreen> createState() => _AdminHelpScreenState();
}

class _AdminHelpScreenState extends State<AdminHelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<HelpCategory> _categories = [
    HelpCategory(
      id: 'all',
      title: 'Todos',
      icon: Icons.all_inclusive,
    ),
    HelpCategory(
      id: 'getting_started',
      title: 'Primeiros Passos',
      icon: Icons.play_arrow,
    ),
    HelpCategory(
      id: 'properties',
      title: 'Gestão de Imóveis',
      icon: Icons.home_work,
    ),
    HelpCategory(
      id: 'realtors',
      title: 'Gestão de Corretores',
      icon: Icons.people,
    ),
    HelpCategory(
      id: 'reports',
      title: 'Relatórios',
      icon: Icons.analytics,
    ),
    HelpCategory(
      id: 'settings',
      title: 'Configurações',
      icon: Icons.settings,
    ),
    HelpCategory(
      id: 'troubleshooting',
      title: 'Solução de Problemas',
      icon: Icons.build,
    ),
  ];

  final List<HelpArticle> _articles = [
    HelpArticle(
      id: '1',
      title: 'Como adicionar um novo imóvel',
      content: 'Para adicionar um novo imóvel na plataforma...',
      category: 'properties',
      tags: ['imóvel', 'cadastro', 'novo'],
    ),
    HelpArticle(
      id: '2',
      title: 'Como gerenciar corretores',
      content: 'Para gerenciar os corretores da plataforma...',
      category: 'realtors',
      tags: ['corretor', 'gestão', 'perfil'],
    ),
    HelpArticle(
      id: '3',
      title: 'Configurando notificações',
      content: 'Para configurar as notificações do sistema...',
      category: 'settings',
      tags: ['notificação', 'configuração', 'email'],
    ),
    HelpArticle(
      id: '4',
      title: 'Entendendo os relatórios',
      content: 'Os relatórios fornecem insights sobre...',
      category: 'reports',
      tags: ['relatório', 'análise', 'dados'],
    ),
    HelpArticle(
      id: '5',
      title: 'Primeiros passos como administrador',
      content: 'Bem-vindo à plataforma! Aqui está um guia...',
      category: 'getting_started',
      tags: ['início', 'tutorial', 'administrador'],
    ),
    HelpArticle(
      id: '6',
      title: 'Problemas com login',
      content: 'Se você está tendo problemas para fazer login...',
      category: 'troubleshooting',
      tags: ['login', 'problema', 'acesso'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: _contactSupport,
            icon: const Icon(Icons.support_agent),
            tooltip: 'Contatar Suporte',
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.admin,
        userName: 'Administrador',
        userEmail: 'admin@imobiliaria.com',
        currentRoute: '/admin/help',
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar na ajuda...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.id;
          
          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category.title),
              avatar: Icon(
                category.icon,
                size: 16,
                color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category.id;
                });
              },
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.textOnPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final filteredArticles = _getFilteredArticles();
    
    if (filteredArticles.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          const SizedBox(height: AppSpacing.xl),
          _buildArticlesList(filteredArticles),
          const SizedBox(height: AppSpacing.xl),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            _buildQuickActionCard(
              'Tutorial Inicial',
              Icons.play_circle_outline,
              () => _showTutorial(),
            ),
            _buildQuickActionCard(
              'Contatar Suporte',
              Icons.support_agent,
              _contactSupport,
            ),
            _buildQuickActionCard(
              'Reportar Bug',
              Icons.bug_report,
              _reportBug,
            ),
            _buildQuickActionCard(
              'Sugerir Melhoria',
              Icons.lightbulb_outline,
              _suggestImprovement,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<HelpArticle> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artigos de Ajuda',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
          for (final article in articles) ...[
            _buildArticleCard(article),
          ],
      ],
    );
  }

  Widget _buildArticleCard(HelpArticle article) {
    final category = _categories.firstWhere((c) => c.id == article.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _showArticle(article),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        article.content,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: article.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Precisa de Mais Ajuda?',
                style: AppTypography.h6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nossa equipe de suporte está sempre pronta para ajudar você.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.email),
                  label: const Text('Email'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openChat,
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nenhum resultado encontrado',
            style: AppTypography.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tente ajustar sua busca ou filtro',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<HelpArticle> _getFilteredArticles() {
    var articles = _articles;

    // Filtrar por categoria
    if (_selectedCategory != 'all') {
      articles = articles.where((article) => article.category == _selectedCategory).toList();
    }

    // Filtrar por busca
    if (_searchQuery.isNotEmpty) {
      articles = articles.where((article) {
        return article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               article.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               article.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return articles;
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Inicial'),
        content: const Text(
          'Bem-vindo à plataforma Imobiliária Digital!\n\n'
          'Este tutorial irá guiá-lo através das principais funcionalidades:\n\n'
          '1. Dashboard - Visão geral da plataforma\n'
          '2. Gestão de Imóveis - Cadastrar e gerenciar imóveis\n'
          '3. Gestão de Corretores - Administrar corretores\n'
          '4. Relatórios - Análises e métricas\n'
          '5. Configurações - Personalizar a plataforma\n\n'
          'Deseja iniciar o tutorial?',
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
                  content: Text('Iniciando tutorial...'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contatar Suporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: suporte@imobiliariadigital.com'),
            SizedBox(height: 8),
            Text('📞 Telefone: (11) 99999-9999'),
            SizedBox(height: 8),
            Text('💬 Chat: Disponível 24/7'),
            SizedBox(height: 8),
            Text('⏰ Horário: Segunda a Sexta, 8h às 18h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abrindo chat de suporte...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Abrir Chat'),
          ),
        ],
      ),
    );
  }

  void _reportBug() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Bug'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Descreva o problema encontrado',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
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
                  content: Text('Bug reportado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _suggestImprovement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sugerir Melhoria'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Descreva sua sugestão',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
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
                  content: Text('Sugestão enviada com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showArticle(HelpArticle article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(article.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(article.content),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Tags:',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: article.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Artigo marcado como útil!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Útil'),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo chat de suporte...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class HelpCategory {
  final String id;
  final String title;
  final IconData icon;

  HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class HelpArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;

  HelpArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
  });
}
