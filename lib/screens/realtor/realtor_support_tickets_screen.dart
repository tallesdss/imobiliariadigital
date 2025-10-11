import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import '../../widgets/common/custom_drawer.dart';

class RealtorSupportTicketsScreen extends StatefulWidget {
  const RealtorSupportTicketsScreen({super.key});

  @override
  State<RealtorSupportTicketsScreen> createState() => _RealtorSupportTicketsScreenState();
}

class _RealtorSupportTicketsScreenState extends State<RealtorSupportTicketsScreen> {
  final String _realtorId = 'realtor1'; // Mock - usuário logado
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _tickets = await ReportService.getRealtorTickets(_realtorId);
    } catch (e) {
      _tickets = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<SupportTicket> get _filteredTickets {
    switch (_selectedFilter) {
      case 'open':
        return _tickets.where((t) => t.status == TicketStatus.open).toList();
      case 'in_progress':
        return _tickets.where((t) => t.status == TicketStatus.inProgress).toList();
      case 'resolved':
        return _tickets.where((t) => t.status == TicketStatus.resolved).toList();
      case 'closed':
        return _tickets.where((t) => t.status == TicketStatus.closed).toList();
      default:
        return _tickets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tickets de Suporte',
          style: AppTypography.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewTicket,
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.realtor,
        userName: 'Carlos Oliveira',
        userEmail: 'carlos@imobiliaria.com',
        currentRoute: '/realtor/support-tickets',
        userCreci: 'CRECI 12345-F',
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
                    ? _buildEmptyState()
                    : _buildTicketsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'all'),
            _buildFilterChip('Abertos', 'open'),
            _buildFilterChip('Em Andamento', 'in_progress'),
            _buildFilterChip('Resolvidos', 'resolved'),
            _buildFilterChip('Fechados', 'closed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum ticket encontrado',
            style: AppTypography.h3.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Crie seu primeiro ticket de suporte',
            style: AppTypography.bodyLarge.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: _createNewTicket,
            icon: const Icon(Icons.add),
            label: const Text('Criar Ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = _filteredTickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _openTicketDetails(ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(ticket.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ticket.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildCategoryChip(ticket.category),
                  const SizedBox(width: AppSpacing.sm),
                  _buildPriorityChip(ticket.priority),
                  const Spacer(),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (ticket.messages.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${ticket.messages.length} mensagens',
                      style: AppTypography.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TicketStatus status) {
    Color color;
    String label;

    switch (status) {
      case TicketStatus.open:
        color = Colors.orange;
        label = 'Aberto';
        break;
      case TicketStatus.inProgress:
        color = Colors.blue;
        label = 'Em Andamento';
        break;
      case TicketStatus.waitingForUser:
        color = Colors.purple;
        label = 'Aguardando';
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        label = 'Resolvido';
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        label = 'Fechado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(TicketCategory category) {
    String label;

    switch (category) {
      case TicketCategory.technical:
        label = 'Técnico';
        break;
      case TicketCategory.commercial:
        label = 'Comercial';
        break;
      case TicketCategory.financial:
        label = 'Financeiro';
        break;
      case TicketCategory.feature:
        label = 'Funcionalidade';
        break;
      case TicketCategory.bug:
        label = 'Bug';
        break;
      case TicketCategory.other:
        label = 'Outro';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TicketPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        label = 'Baixa';
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        label = 'Média';
        break;
      case TicketPriority.high:
        color = Colors.red;
        label = 'Alta';
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        label = 'Urgente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _createNewTicket() {
    showDialog(
      context: context,
      builder: (context) => _CreateTicketDialog(
        onTicketCreated: (ticket) {
          setState(() {
            _tickets.insert(0, ticket);
          });
        },
      ),
    );
  }

  void _openTicketDetails(SupportTicket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailsScreen(
          ticket: ticket,
          onTicketUpdated: (updatedTicket) {
            setState(() {
              final index = _tickets.indexWhere((t) => t.id == updatedTicket.id);
              if (index != -1) {
                _tickets[index] = updatedTicket;
              }
            });
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora';
    }
  }
}

class _CreateTicketDialog extends StatefulWidget {
  final Function(SupportTicket) onTicketCreated;

  const _CreateTicketDialog({required this.onTicketCreated});

  @override
  State<_CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<_CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategory _selectedCategory = TicketCategory.technical;
  TicketPriority _selectedPriority = TicketPriority.medium;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Novo Ticket'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<TicketCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: TicketCategory.values.map((category) {
                  String label;
                  switch (category) {
                    case TicketCategory.technical:
                      label = 'Técnico';
                      break;
                    case TicketCategory.commercial:
                      label = 'Comercial';
                      break;
                    case TicketCategory.financial:
                      label = 'Financeiro';
                      break;
                    case TicketCategory.feature:
                      label = 'Funcionalidade';
                      break;
                    case TicketCategory.bug:
                      label = 'Bug';
                      break;
                    case TicketCategory.other:
                      label = 'Outro';
                      break;
                  }
                  return DropdownMenuItem(
                    value: category,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<TicketPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: TicketPriority.values.map((priority) {
                  String label;
                  switch (priority) {
                    case TicketPriority.low:
                      label = 'Baixa';
                      break;
                    case TicketPriority.medium:
                      label = 'Média';
                      break;
                    case TicketPriority.high:
                      label = 'Alta';
                      break;
                    case TicketPriority.urgent:
                      label = 'Urgente';
                      break;
                  }
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
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
          onPressed: _createTicket,
          child: const Text('Criar Ticket'),
        ),
      ],
    );
  }

  void _createTicket() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ticket = SupportTicket(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          realtorId: 'realtor1',
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
          status: TicketStatus.open,
          createdAt: DateTime.now(),
        );

        await ReportService.createTicket(ticket);
        if (mounted) {
          widget.onTicketCreated(ticket);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar ticket: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class TicketDetailsScreen extends StatefulWidget {
  final SupportTicket ticket;
  final Function(SupportTicket) onTicketUpdated;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
    required this.onTicketUpdated,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final _messageController = TextEditingController();
  late SupportTicket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket #${_ticket.id}',
          style: AppTypography.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTicketInfo(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMessagesList(),
                ],
              ),
            ),
          ),
          if (_ticket.status != TicketStatus.closed) _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ticket.title,
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _ticket.description,
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildStatusChip(_ticket.status),
                const SizedBox(width: AppSpacing.sm),
                _buildCategoryChip(_ticket.category),
                const SizedBox(width: AppSpacing.sm),
                _buildPriorityChip(_ticket.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mensagens',
          style: AppTypography.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._ticket.messages.map((message) => _buildMessageCard(message)),
      ],
    );
  }

  Widget _buildMessageCard(TicketMessage message) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  message.senderName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(message.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message.message),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TicketStatus status) {
    Color color;
    String label;

    switch (status) {
      case TicketStatus.open:
        color = Colors.orange;
        label = 'Aberto';
        break;
      case TicketStatus.inProgress:
        color = Colors.blue;
        label = 'Em Andamento';
        break;
      case TicketStatus.waitingForUser:
        color = Colors.purple;
        label = 'Aguardando';
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        label = 'Resolvido';
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        label = 'Fechado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(TicketCategory category) {
    String label;

    switch (category) {
      case TicketCategory.technical:
        label = 'Técnico';
        break;
      case TicketCategory.commercial:
        label = 'Comercial';
        break;
      case TicketCategory.financial:
        label = 'Financeiro';
        break;
      case TicketCategory.feature:
        label = 'Funcionalidade';
        break;
      case TicketCategory.bug:
        label = 'Bug';
        break;
      case TicketCategory.other:
        label = 'Outro';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TicketPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        label = 'Baixa';
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        label = 'Média';
        break;
      case TicketPriority.high:
        color = Colors.red;
        label = 'Alta';
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        label = 'Urgente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final message = TicketMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ticketId: _ticket.id,
        senderId: 'realtor1',
        senderName: 'Carlos Oliveira',
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ReportService.addTicketMessage(message);
      
      setState(() {
        _ticket = _ticket.copyWith(
          messages: [..._ticket.messages, message],
          updatedAt: DateTime.now(),
        );
      });

      _messageController.clear();
      widget.onTicketUpdated(_ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar mensagem: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

extension SupportTicketExtension on SupportTicket {
  SupportTicket copyWith({
    String? id,
    String? realtorId,
    String? title,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TicketMessage>? messages,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      realtorId: realtorId ?? this.realtorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}
