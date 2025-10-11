import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/property_model.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

class ReportService {
  /// Gera relatório individual do corretor
  static Future<RealtorReport> generateRealtorReport({
    required String realtorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Buscar propriedades do corretor no período
      final propertiesResponse = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('*')
          .eq('realtor_id', realtorId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final properties = propertiesResponse
          .map((json) => Property.fromJson(json))
          .toList();

      // Calcular estatísticas básicas
      final totalProperties = properties.length;
      final activeProperties = properties.where((p) => p.status == PropertyStatus.active).length;
      final soldProperties = properties.where((p) => p.status == PropertyStatus.sold).length;
      final archivedProperties = properties.where((p) => p.status == PropertyStatus.archived).length;
      
      final conversionRate = totalProperties > 0 ? (soldProperties / totalProperties * 100) : 0.0;
      final totalRevenue = properties
          .where((p) => p.status == PropertyStatus.sold)
          .fold(0.0, (sum, p) => sum + p.price);
      final averagePrice = totalProperties > 0 
          ? properties.fold(0.0, (sum, p) => sum + p.price) / totalProperties 
          : 0.0;

      // Mock data para views e leads (em produção viria de analytics)
      final totalViews = properties.length * 15; // Mock: 15 views por imóvel
      final totalLeads = properties.length * 3; // Mock: 3 leads por imóvel
      final convertedLeads = soldProperties; // Simplificado
      final leadConversionRate = totalLeads > 0 ? (convertedLeads / totalLeads * 100) : 0.0;

      // Top propriedades por performance
      final topProperties = properties
          .map((p) => PropertyPerformance(
                propertyId: p.id,
                title: p.title,
                price: p.price,
                views: 15, // Mock: 15 views por imóvel
                leads: 3, // Mock: 3 leads por imóvel
                isSold: p.status == PropertyStatus.sold,
                soldDate: p.status == PropertyStatus.sold ? p.updatedAt : null,
                soldPrice: p.status == PropertyStatus.sold ? p.price : null,
              ))
          .toList()
        ..sort((a, b) => (b.views + b.leads).compareTo(a.views + a.leads));

      // Dados mensais (mock - em produção viria de consultas mais complexas)
      final monthlyData = _generateMonthlyData(startDate, endDate, properties);

      return RealtorReport(
        id: '${realtorId}_${startDate.millisecondsSinceEpoch}',
        realtorId: realtorId,
        periodStart: startDate,
        periodEnd: endDate,
        totalProperties: totalProperties,
        activeProperties: activeProperties,
        soldProperties: soldProperties,
        archivedProperties: archivedProperties,
        conversionRate: conversionRate,
        totalRevenue: totalRevenue,
        averagePrice: averagePrice,
        totalViews: totalViews,
        totalLeads: totalLeads,
        convertedLeads: convertedLeads,
        leadConversionRate: leadConversionRate,
        topProperties: topProperties.take(10).toList(),
        monthlyData: monthlyData,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao gerar relatório do corretor: $e');
      }
      throw Exception('Erro ao gerar relatório. Tente novamente.');
    }
  }

  /// Gera dados mensais para o gráfico
  static List<MonthlyPerformance> _generateMonthlyData(
    DateTime startDate,
    DateTime endDate,
    List<Property> properties,
  ) {
    final monthlyData = <MonthlyPerformance>[];
    var current = DateTime(startDate.year, startDate.month);
    final end = DateTime(endDate.year, endDate.month);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final monthProperties = properties.where((p) {
        final propertyDate = DateTime(p.createdAt.year, p.createdAt.month);
        return propertyDate.isAtSameMomentAs(current);
      }).toList();

      final propertiesAdded = monthProperties.length;
      final propertiesSold = monthProperties.where((p) => p.status == PropertyStatus.sold).length;
      final revenue = monthProperties
          .where((p) => p.status == PropertyStatus.sold)
          .fold(0.0, (sum, p) => sum + p.price);
      final views = monthProperties.length * 15; // Mock: 15 views por imóvel
      final leads = monthProperties.length * 3; // Mock: 3 leads por imóvel
      final conversionRate = propertiesAdded > 0 ? (propertiesSold / propertiesAdded * 100) : 0.0;

      monthlyData.add(MonthlyPerformance(
        year: current.year,
        month: current.month,
        propertiesAdded: propertiesAdded,
        propertiesSold: propertiesSold,
        revenue: revenue,
        views: views,
        leads: leads,
        conversionRate: conversionRate,
      ));

      current = DateTime(current.year, current.month + 1);
    }

    return monthlyData;
  }

  /// Busca metas do corretor
  static Future<List<Goal>> getRealtorGoals(String realtorId) async {
    try {
      final response = await SupabaseService.client
          .from('goals')
          .select('*')
          .eq('realtor_id', realtorId)
          .order('created_at', ascending: false);

      return response.map((json) => Goal.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar metas: $e');
      }
      // Retorna metas mock se não conseguir carregar
      return _getMockGoals(realtorId);
    }
  }

  /// Cria uma nova meta
  static Future<Goal> createGoal(Goal goal) async {
    try {
      final response = await SupabaseService.client
          .from('goals')
          .insert(goal.toJson())
          .select()
          .single();

      return Goal.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao criar meta: $e');
      }
      throw Exception('Erro ao criar meta. Tente novamente.');
    }
  }

  /// Atualiza uma meta existente
  static Future<Goal> updateGoal(Goal goal) async {
    try {
      final response = await SupabaseService.client
          .from('goals')
          .update(goal.toJson())
          .eq('id', goal.id)
          .select()
          .single();

      return Goal.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar meta: $e');
      }
      throw Exception('Erro ao atualizar meta. Tente novamente.');
    }
  }

  /// Deleta uma meta
  static Future<void> deleteGoal(String goalId) async {
    try {
      await SupabaseService.client
          .from('goals')
          .delete()
          .eq('id', goalId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar meta: $e');
      }
      throw Exception('Erro ao deletar meta. Tente novamente.');
    }
  }

  /// Busca tickets de suporte do corretor
  static Future<List<SupportTicket>> getRealtorTickets(String realtorId) async {
    try {
      final response = await SupabaseService.client
          .from('support_tickets')
          .select('*')
          .eq('realtor_id', realtorId)
          .order('created_at', ascending: false);

      return response.map((json) => SupportTicket.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar tickets: $e');
      }
      // Retorna tickets mock se não conseguir carregar
      return _getMockTickets(realtorId);
    }
  }

  /// Cria um novo ticket de suporte
  static Future<SupportTicket> createTicket(SupportTicket ticket) async {
    try {
      final response = await SupabaseService.client
          .from('support_tickets')
          .insert(ticket.toJson())
          .select()
          .single();

      return SupportTicket.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao criar ticket: $e');
      }
      throw Exception('Erro ao criar ticket. Tente novamente.');
    }
  }

  /// Atualiza um ticket existente
  static Future<SupportTicket> updateTicket(SupportTicket ticket) async {
    try {
      final response = await SupabaseService.client
          .from('support_tickets')
          .update(ticket.toJson())
          .eq('id', ticket.id)
          .select()
          .single();

      return SupportTicket.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar ticket: $e');
      }
      throw Exception('Erro ao atualizar ticket. Tente novamente.');
    }
  }

  /// Adiciona mensagem a um ticket
  static Future<TicketMessage> addTicketMessage(TicketMessage message) async {
    try {
      final response = await SupabaseService.client
          .from('ticket_messages')
          .insert(message.toJson())
          .select()
          .single();

      return TicketMessage.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao adicionar mensagem: $e');
      }
      throw Exception('Erro ao adicionar mensagem. Tente novamente.');
    }
  }

  /// Exporta relatório para PDF (mock)
  static Future<String> exportReportToPDF(RealtorReport report) async {
    // Em produção, usar biblioteca como pdf ou printing
    await Future.delayed(const Duration(seconds: 2));
    return 'relatorio_${report.realtorId}_${report.periodStart.millisecondsSinceEpoch}.pdf';
  }

  /// Exporta relatório para Excel (mock)
  static Future<String> exportReportToExcel(RealtorReport report) async {
    // Em produção, usar biblioteca como excel
    await Future.delayed(const Duration(seconds: 2));
    return 'relatorio_${report.realtorId}_${report.periodStart.millisecondsSinceEpoch}.xlsx';
  }

  /// Metas mock para desenvolvimento
  static List<Goal> _getMockGoals(String realtorId) {
    final now = DateTime.now();
    return [
      Goal(
        id: 'goal1',
        realtorId: realtorId,
        title: 'Vender 5 imóveis este mês',
        description: 'Meta de vendas para o mês atual',
        type: GoalType.propertiesSold,
        targetValue: 5,
        currentValue: 3,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      ),
      Goal(
        id: 'goal2',
        realtorId: realtorId,
        title: 'Gerar 50 leads',
        description: 'Meta de leads para o trimestre',
        type: GoalType.leads,
        targetValue: 50,
        currentValue: 32,
        startDate: DateTime(now.year, now.month - 2, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      ),
      Goal(
        id: 'goal3',
        realtorId: realtorId,
        title: 'Faturamento de R\$ 500.000',
        description: 'Meta de faturamento anual',
        type: GoalType.revenue,
        targetValue: 500000,
        currentValue: 320000,
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
      ),
    ];
  }

  /// Tickets mock para desenvolvimento
  static List<SupportTicket> _getMockTickets(String realtorId) {
    final now = DateTime.now();
    return [
      SupportTicket(
        id: 'ticket1',
        realtorId: realtorId,
        title: 'Problema ao fazer upload de fotos',
        description: 'Não consigo fazer upload de fotos maiores que 5MB',
        category: TicketCategory.technical,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: now.subtract(const Duration(days: 2)),
        messages: [
          TicketMessage(
            id: 'msg1',
            ticketId: 'ticket1',
            senderId: realtorId,
            senderName: 'Carlos Oliveira',
            message: 'Não consigo fazer upload de fotos maiores que 5MB. O sistema trava.',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      SupportTicket(
        id: 'ticket2',
        realtorId: realtorId,
        title: 'Dúvida sobre relatórios',
        description: 'Como posso exportar meus relatórios em PDF?',
        category: TicketCategory.feature,
        priority: TicketPriority.low,
        status: TicketStatus.resolved,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        messages: [
          TicketMessage(
            id: 'msg2',
            ticketId: 'ticket2',
            senderId: realtorId,
            senderName: 'Carlos Oliveira',
            message: 'Como posso exportar meus relatórios em PDF?',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
          TicketMessage(
            id: 'msg3',
            ticketId: 'ticket2',
            senderId: 'support',
            senderName: 'Suporte Técnico',
            message: 'Olá! Você pode exportar seus relatórios clicando no botão "Exportar" na tela de relatórios.',
            createdAt: now.subtract(const Duration(days: 1)),
            isFromSupport: true,
          ),
        ],
      ),
    ];
  }
}
