import 'package:flutter/material.dart';
import '../../services/voice_search_service.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'search_results_screen.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String? _recognizedText;
  String? _errorMessage;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
    _loadSuggestions();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeVoiceService() async {
    try {
      final isAvailable = await VoiceSearchService.isAvailable();
      setState(() {
        _isInitialized = isAvailable;
        if (!isAvailable) {
          _errorMessage = 'Reconhecimento de voz não disponível neste dispositivo';
        }
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _errorMessage = 'Erro ao inicializar reconhecimento de voz: $e';
      });
    }
  }

  void _loadSuggestions() {
    setState(() {
      _suggestions = VoiceSearchService.getVoiceCommandSuggestions();
    });
  }

  Future<void> _startListening() async {
    if (!_isInitialized || _isListening) return;

    setState(() {
      _isListening = true;
      _recognizedText = null;
      _errorMessage = null;
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    try {
      final result = await VoiceSearchService.startListening();
      
      setState(() {
        _isListening = false;
        _recognizedText = result;
      });

      _pulseController.stop();
      _waveController.stop();

      if (result != null && result.isNotEmpty) {
        _processVoiceCommand(result);
      } else {
        setState(() {
          _errorMessage = 'Não foi possível reconhecer o áudio. Tente falar mais claramente.';
        });
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _errorMessage = 'Erro no reconhecimento: $e';
      });
      _pulseController.stop();
      _waveController.stop();
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await VoiceSearchService.stopListening();
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    _waveController.stop();
  }

  Future<void> _processVoiceCommand(String command) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Validar comando
      if (!VoiceSearchService.isValidSearchCommand(command)) {
        setState(() {
          _errorMessage = VoiceSearchService.getRecognitionFeedback(command);
          _isProcessing = false;
        });
        return;
      }

      // Processar comando de voz
      final searchQuery = await VoiceSearchService.processVoiceCommand(command);
      
      // Atualizar sugestões (implementar se necessário)
      // await VoiceSearchService.updateSuggestions(command);

      // Realizar busca
      final results = await SearchService.searchProperties(searchQuery);

      setState(() {
        _isProcessing = false;
      });

      // Navegar para resultados
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchQuery: searchQuery,
              results: results,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Erro ao processar comando: $e';
      });
    }
  }

  void _useSuggestion(String suggestion) {
    setState(() {
      _recognizedText = suggestion;
    });
    _processVoiceCommand(suggestion);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: _isInitialized
                    ? _buildVoiceInterface()
                    : _buildErrorState(),
              ),
              const SizedBox(height: 24),
              _buildSuggestions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.mic,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Busca por Voz',
          style: AppTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fale o que você está procurando',
          style: AppTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVoiceInterface() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildVoiceButton(),
        const SizedBox(height: 32),
        _buildStatusText(),
        if (_recognizedText != null) ...[
          const SizedBox(height: 24),
          _buildRecognizedText(),
        ],
        if (_isProcessing) ...[
          const SizedBox(height: 24),
          const LoadingWidget(),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 24),
          CustomErrorWidget(message: _errorMessage!),
        ],
      ],
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening 
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: _isListening ? 20 : 10,
                    spreadRadius: _isListening ? 5 : 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening) _buildWaveAnimation(),
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: _isListening ? AppTheme.primaryColor : Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: WavePainter(
            animation: _waveAnimation.value,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    String statusText;
    Color statusColor;

    if (_isListening) {
      statusText = 'Ouvindo... Fale agora';
      statusColor = AppTheme.primaryColor;
    } else if (_isProcessing) {
      statusText = 'Processando comando...';
      statusColor = Colors.orange;
    } else if (_recognizedText != null) {
      statusText = 'Comando reconhecido!';
      statusColor = Colors.green;
    } else {
      statusText = 'Toque no microfone para começar';
      statusColor = Colors.grey[600]!;
    }

    return Text(
      statusText,
      style: AppTheme.titleMedium?.copyWith(
        color: statusColor,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecognizedText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Comando reconhecido:',
            style: AppTheme.bodySmall?.copyWith(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_recognizedText"',
            style: AppTheme.bodyLarge?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Reconhecimento de voz indisponível',
            style: AppTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: AppTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeVoiceService,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exemplos de comandos:',
          style: AppTheme.titleSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.take(4).map((suggestion) {
            return ActionChip(
              label: Text(
                suggestion,
                style: AppTheme.bodySmall,
              ),
              onPressed: () => _useSuggestion(suggestion),
              backgroundColor: Colors.grey[100],
              side: BorderSide(color: Colors.grey[300]!),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * (0.5 + animation * 0.5);

    canvas.drawCircle(center, radius, paint);
    
    if (animation > 0.5) {
      final secondRadius = (size.width / 2) * (0.3 + (animation - 0.5) * 0.4);
      canvas.drawCircle(center, secondRadius, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
