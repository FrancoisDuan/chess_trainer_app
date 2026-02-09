import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';


/// Interactive chess board widget with professional piece graphics
class ChessBoard extends StatefulWidget {
  final String? fenNotation;
  final double size;
  final String? bestMove; // Best move in algebraic notation (e.g., "e2e4")

  const ChessBoard({
    super.key,
    this.fenNotation,
    this.size = 320,
    this.bestMove,
  });

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with SingleTickerProviderStateMixin {
  late chess_lib.Chess _chess;
  String? _selectedSquare;
  List<String> _validMoves = [];
  late AnimationController _animationController;
  Animation<Offset>? _moveAnimation;
  String? _animatingFromSquare;
  bool _isPlayingBestMove = false;
  late double _currentSquareSize; // Track actual square size for animations

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentSquareSize = widget.size / 8; // Initialize with default calculation
    _initializeBoard();
  }

  @override
  void didUpdateWidget(ChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fenNotation != widget.fenNotation) {
      setState(() {
        _selectedSquare = null;
        _validMoves.clear();
        _initializeBoard();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize the chess board from FEN
  void _initializeBoard() {
    _chess = chess_lib.Chess();
    if (widget.fenNotation != null && widget.fenNotation!.isNotEmpty) {
      try {
        _chess.load(widget.fenNotation!);
      } catch (e) {
        // If FEN is invalid, use default position
        _chess.reset();
      }
    }
  }

  /// Convert row/col to algebraic notation (e.g., 0,0 -> "a8")
  String _positionToAlgebraic(int row, int col) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final rank = (8 - row).toString();
    return '${files[col]}$rank';
  }

  /// Convert algebraic notation to row/col
  Map<String, int> _algebraicToPosition(String algebraic) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final col = files.indexOf(algebraic[0]);
    final row = 8 - int.parse(algebraic[1]);
    return {'row': row, 'col': col};
  }

  /// Handle square tap
  void _onSquareTap(int row, int col) {
    if (_isPlayingBestMove || _animatingFromSquare != null) {
      return; // Don't allow interaction during animation
    }

    final square = _positionToAlgebraic(row, col);
    
    if (_selectedSquare != null) {
      // Try to make a move
      if (_validMoves.contains(square)) {
        _makeMove(_selectedSquare!, square);
      } else {
        // Select different piece or deselect
        _selectSquare(square);
      }
    } else {
      // Select a piece
      _selectSquare(square);
    }
  }

  /// Select a square and calculate valid moves
  void _selectSquare(String square) {
    final piece = _chess.get(square);
    
    if (piece == null) {
      setState(() {
        _selectedSquare = null;
        _validMoves.clear();
      });
      return;
    }

    // Only allow selecting pieces of the side to move
    if ((piece.color == chess_lib.Color.WHITE && _chess.turn == chess_lib.Color.WHITE) ||
        (piece.color == chess_lib.Color.BLACK && _chess.turn == chess_lib.Color.BLACK)) {
      setState(() {
        _selectedSquare = square;
        _validMoves = _chess
            .moves({'square': square})
            .map((move) => _extractDestination(move))
            .toList();
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _validMoves.clear();
      });
    }
  }

  /// Extract destination square from move string (handles various formats)
  String _extractDestination(String move) {
    // Remove check/checkmate symbols
    move = move.replaceAll('+', '').replaceAll('#', '');
    
    // Handle castling
    if (move == 'O-O') {
      return _chess.turn == chess_lib.Color.WHITE ? 'g1' : 'g8';
    }
    if (move == 'O-O-O') {
      return _chess.turn == chess_lib.Color.WHITE ? 'c1' : 'c8';
    }
    
    // Extract the last 2 characters (destination square)
    if (move.length >= 2) {
      return move.substring(move.length - 2);
    }
    
    return move;
  }

  /// Make a move and animate it
  void _makeMove(String from, String to) async {
    // Try to make the move
    final moveResult = _chess.move({'from': from, 'to': to, 'promotion': 'q'});
    
    if (moveResult == false) {
      // Invalid move
      setState(() {
        _selectedSquare = null;
        _validMoves.clear();
      });
      return;
    }

    // Animate the move
    await _animateMove(from, to);

    setState(() {
      _selectedSquare = null;
      _validMoves.clear();
    });

    // After user's move, play the best move if available
    if (widget.bestMove != null && widget.bestMove!.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 1500));
      _playBestMove();
    }
  }

  /// Animate a move
  Future<void> _animateMove(String from, String to) async {
    final fromPos = _algebraicToPosition(from);
    final toPos = _algebraicToPosition(to);
    
    final squareSize = _currentSquareSize;
    final fromOffset = Offset(fromPos['col']! * squareSize, fromPos['row']! * squareSize);
    final toOffset = Offset(toPos['col']! * squareSize, toPos['row']! * squareSize);

    setState(() {
      _animatingFromSquare = from;
      _moveAnimation = Tween<Offset>(
        begin: fromOffset,
        end: toOffset,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    });

    await _animationController.forward(from: 0);

    if (mounted) {
      setState(() {
        _animatingFromSquare = null;
      });
    }
  }

  /// Play the best move automatically
  void _playBestMove() async {
    if (_isPlayingBestMove || widget.bestMove == null || widget.bestMove!.isEmpty) {
      return;
    }

    setState(() {
      _isPlayingBestMove = true;
    });

    try {
      final bestMoveStr = widget.bestMove!;
      
      // Try to find the move in legal moves that matches the SAN or coordinate notation
      chess_lib.Move? matchedMove;
      String? fromSquare;
      String? toSquare;
      
      // First, try coordinate notation (e.g., "e2e4")
      if (bestMoveStr.length >= 4 && 
          RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(bestMoveStr)) {
        final from = bestMoveStr.substring(0, 2);
        final to = bestMoveStr.substring(2, 4);
        final promotion = bestMoveStr.length > 4 ? bestMoveStr[4] : null;
        
        final moveResult = _chess.move({
          'from': from,
          'to': to,
          'promotion': promotion,
        });
        
        if (moveResult != false) {
          fromSquare = from;
          toSquare = to;
          matchedMove = _chess.undo_move(); // Undo to get the Move object
          if (matchedMove != null) {
            _chess.make_move(matchedMove); // Re-apply
          }
        }
      }
      
      // If that didn't work, try SAN notation by checking all legal moves
      if (matchedMove == null) {
        final legalMoves = _chess.generate_moves();
        for (final legalMove in legalMoves) {
          final san = _chess.move_to_san(legalMove);
          // Remove check/checkmate symbols for comparison
          final cleanSan = san.replaceAll('+', '').replaceAll('#', '');
          final cleanBestMove = bestMoveStr.replaceAll('+', '').replaceAll('#', '');
          
          if (san == bestMoveStr || cleanSan == cleanBestMove) {
            matchedMove = legalMove;
            fromSquare = legalMove.fromAlgebraic;
            toSquare = legalMove.toAlgebraic;
            _chess.make_move(legalMove);
            break;
          }
        }
      }

      if (matchedMove != null && fromSquare != null && toSquare != null) {
        // Animate the best move
        await _animateMove(fromSquare, toSquare);
      }
    } catch (e) {
      // Log error in debug mode for troubleshooting
      assert(() {
        debugPrint('Error playing best move: $e');
        return true;
      }());
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingBestMove = false;
        });
      }
    }
  }

  /// Get the chess piece widget for a given square
  Widget? _getPieceWidget(String square, double size) {
    final piece = _chess.get(square);
    if (piece == null) return null;

    final isWhite = piece.color == chess_lib.Color.WHITE;
    
    switch (piece.type) {
      case chess_lib.PieceType.KING:
        return isWhite ? WhiteKing(size: size) : BlackKing(size: size);
      case chess_lib.PieceType.QUEEN:
        return isWhite ? WhiteQueen(size: size) : BlackQueen(size: size);
      case chess_lib.PieceType.ROOK:
        return isWhite ? WhiteRook(size: size) : BlackRook(size: size);
      case chess_lib.PieceType.BISHOP:
        return isWhite ? WhiteBishop(size: size) : BlackBishop(size: size);
      case chess_lib.PieceType.KNIGHT:
        return isWhite ? WhiteKnight(size: size) : BlackKnight(size: size);
      case chess_lib.PieceType.PAWN:
        return isWhite ? WhitePawn(size: size) : BlackPawn(size: size);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Chess.com inspired board colors
    final lightSquare = const Color(0xFFEEEED2); // Light squares
    final darkSquare = const Color(0xFF769656);  // Dark squares

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate actual board size from available constraints
        // Use the smaller of maxWidth or maxHeight to keep it square
        final availableSize = constraints.maxWidth.isFinite && constraints.maxHeight.isFinite
            ? (constraints.maxWidth < constraints.maxHeight 
                ? constraints.maxWidth 
                : constraints.maxHeight)
            : widget.size;
        
        // Ensure board doesn't exceed widget.size parameter
        final boardSize = availableSize < widget.size ? availableSize : widget.size;
        final squareSize = boardSize / 8;
        
        // Update current square size for animations only if it changed significantly
        // Avoid unnecessary setState calls by using a threshold
        if ((_currentSquareSize - squareSize).abs() > 0.1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (_currentSquareSize - squareSize).abs() > 0.1) {
              setState(() {
                _currentSquareSize = squareSize;
              });
            }
          });
        }

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withValues(alpha: 0.3), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                // Chess board squares
                Column(
                  children: List.generate(8, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(8, (col) {
                          final square = _positionToAlgebraic(row, col);
                          final isLightSquare = (row + col) % 2 == 0;
                          final isSelected = _selectedSquare == square;
                          final isValidMove = _validMoves.contains(square);
                          final isAnimating = _animatingFromSquare == square;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _onSquareTap(row, col),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                      : (isLightSquare ? lightSquare : darkSquare),
                                ),
                                child: Stack(
                                  children: [
                                    // Valid move indicator
                                    if (isValidMove)
                                      Center(
                                        child: Container(
                                          width: squareSize * 0.3,
                                          height: squareSize * 0.3,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    // Chess piece (if not animating)
                                    if (!isAnimating)
                                      Center(
                                        child: _getPieceWidget(square, squareSize * 0.85),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
                // Animating piece
                if (_animatingFromSquare != null && _moveAnimation != null)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final offset = _moveAnimation!.value;
                      return Positioned(
                        left: offset.dx,
                        top: offset.dy,
                        child: Container(
                          width: squareSize,
                          height: squareSize,
                          alignment: Alignment.center,
                          child: _getPieceWidget(_animatingFromSquare!, squareSize * 0.85),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
