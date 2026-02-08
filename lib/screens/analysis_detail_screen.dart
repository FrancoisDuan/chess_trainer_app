import 'package:flutter/material.dart';
import '../models/analysis.dart';
import '../models/mistake.dart';
import '../services/chess_trainer_api_service.dart';
import '../utils/date_formatter.dart';

/// Screen displaying detailed analysis of a single game
class AnalysisDetailScreen extends StatefulWidget {
  final String gameId;

  const AnalysisDetailScreen({super.key, required this.gameId});

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  final ChessTrainerApiService _apiService = ChessTrainerApiService();
  Analysis? _analysis;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final analysis = await _apiService.getGameAnalysis(widget.gameId);
      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Analysis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAnalysis,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_analysis == null) {
      return const Center(child: Text('No analysis found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameMetadata(),
          _buildChessBoardPlaceholder(),
          _buildMistakesSection(),
        ],
      ),
    );
  }

  Widget _buildGameMetadata() {
    final game = _analysis!.game;
    
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetadataRow('White', game.whitePlayer, Icons.person),
            const SizedBox(height: 8),
            _buildMetadataRow('Black', game.blackPlayer, Icons.person),
            const SizedBox(height: 8),
            _buildMetadataRow('Result', game.resultDisplay, Icons.emoji_events),
            const SizedBox(height: 8),
            _buildMetadataRow('Time Control', game.timeControl, Icons.timer),
            const SizedBox(height: 8),
            _buildMetadataRow('Date', DateFormatter.formatDate(game.date), Icons.calendar_today),
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Total Mistakes',
              '${_analysis!.totalMistakes}',
              Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildChessBoardPlaceholder() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_on,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Chess Board',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Interactive board coming soon',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMistakesSection() {
    final mistakes = _analysis!.mistakes;

    if (mistakes.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Mistakes Found!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This was a perfectly played game',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mistakes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...mistakes.asMap().entries.map((entry) {
              final index = entry.key;
              final mistake = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  _buildMistakeCard(mistake),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeCard(Mistake mistake) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Move ${mistake.moveNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Loss: ${mistake.evaluationDifference.abs().toStringAsFixed(1)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMoveComparison(
          'Your Move',
          mistake.playerMove,
          mistake.formatEvaluation(mistake.evaluationAfter),
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildMoveComparison(
          'Best Move',
          mistake.bestMove,
          mistake.formatEvaluation(mistake.evaluationBefore),
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMoveComparison(
    String label,
    String move,
    String evaluation,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              move,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              evaluation,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
