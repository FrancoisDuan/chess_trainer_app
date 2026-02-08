import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/analysis.dart';
import '../models/mistake.dart';
import '../services/chess_trainer_api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/chess_board.dart';

/// Screen with tabbed navigation showing Mistakes and Games List
class TabbedAnalysisScreen extends StatefulWidget {
  final String username;

  const TabbedAnalysisScreen({super.key, required this.username});

  @override
  State<TabbedAnalysisScreen> createState() => _TabbedAnalysisScreenState();
}

class _TabbedAnalysisScreenState extends State<TabbedAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChessTrainerApiService _apiService = ChessTrainerApiService();
  
  List<Game>? _games;
  Analysis? _currentAnalysis;
  int _currentMistakeIndex = 0;
  bool _isLoadingGames = true;
  bool _isLoadingAnalysis = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoadingGames = true;
      _errorMessage = null;
    });

    try {
      final games = await _apiService.getUserGames(widget.username);
      setState(() {
        _games = games;
        _isLoadingGames = false;
      });
      
      // Load first game's analysis automatically
      if (games.isNotEmpty) {
        _loadGameAnalysis(games.first.id);
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoadingGames = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoadingGames = false;
      });
    }
  }

  Future<void> _loadGameAnalysis(String gameId) async {
    setState(() {
      _isLoadingAnalysis = true;
      _currentMistakeIndex = 0;
    });

    try {
      final analysis = await _apiService.getGameAnalysis(gameId);
      setState(() {
        _currentAnalysis = analysis;
        _isLoadingAnalysis = false;
        // Switch to mistakes tab when a game is selected
        _tabController.animateTo(0);
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoadingAnalysis = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analysis: $e';
        _isLoadingAnalysis = false;
      });
    }
  }

  void _nextMistake() {
    if (_currentAnalysis != null && 
        _currentMistakeIndex < _currentAnalysis!.mistakes.length - 1) {
      setState(() {
        _currentMistakeIndex++;
      });
    }
  }

  void _previousMistake() {
    if (_currentMistakeIndex > 0) {
      setState(() {
        _currentMistakeIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Analysis'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Mistakes',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Games',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMistakesTab(),
          _buildGamesTab(),
        ],
      ),
    );
  }

  Widget _buildMistakesTab() {
    if (_isLoadingAnalysis) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentAnalysis == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 60,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No Game Selected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a game from the Games tab',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final mistakes = _currentAnalysis!.mistakes;
    
    if (mistakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Perfect Game!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No mistakes found in this game',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    final currentMistake = mistakes[_currentMistakeIndex];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Game info header
          _buildGameInfoHeader(),
          
          // Chess board placeholder
          _buildChessBoard(currentMistake),
          
          // Mistake navigation
          _buildMistakeNavigation(),
          
          // Current mistake details
          _buildMistakeDetails(currentMistake),
        ],
      ),
    );
  }

  Widget _buildGameInfoHeader() {
    final game = _currentAnalysis!.game;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          game.whitePlayer,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          game.blackPlayer,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    game.resultDisplay,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDate(game.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChessBoard(Mistake mistake) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Interactive chess board
            Center(
              child: ChessBoard(
                fenNotation: mistake.positionFenBefore,
                size: MediaQuery.of(context).size.width - 48, // Responsive sizing
              ),
            ),
            const SizedBox(height: 8),
            // Move info
            Text(
              'Position at move ${mistake.moveNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeNavigation() {
    final mistakes = _currentAnalysis!.mistakes;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentMistakeIndex > 0 ? _previousMistake : null,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              disabledBackgroundColor: theme.colorScheme.surface,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Mistake ${_currentMistakeIndex + 1} of ${mistakes.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentMistakeIndex < mistakes.length - 1 ? _nextMistake : null,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              disabledBackgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeDetails(Mistake mistake) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Move ${mistake.moveNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Loss: ${mistake.evaluationDifference.abs().toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMoveComparison(
              'Your Move',
              mistake.playerMove,
              mistake.formatEvaluation(mistake.evaluationAfter),
              theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            _buildMoveComparison(
              'Best Move',
              mistake.bestMove,
              mistake.formatEvaluation(mistake.evaluationBefore),
              theme.colorScheme.primary,
            ),
          ],
        ),
      ),
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
        color: color.withOpacity(0.1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              move,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              evaluation,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    if (_isLoadingGames) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadGames,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_games == null || _games!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 60,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              const Text(
                'No games found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try analyzing games first',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      child: ListView.builder(
        itemCount: _games!.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final game = _games![index];
          final isSelected = _currentAnalysis?.gameId == game.id;
          return _buildGameCard(game, isSelected);
        },
      ),
    );
  }

  Widget _buildGameCard(Game game, bool isSelected) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isSelected 
          ? theme.colorScheme.primary.withOpacity(0.15)
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: () => _loadGameAnalysis(game.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                game.whitePlayer,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                game.blackPlayer,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      game.resultDisplay,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.timer, game.timeControl),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.calendar_today, DateFormatter.formatDate(game.date)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
