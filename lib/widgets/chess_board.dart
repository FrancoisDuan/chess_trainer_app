import 'package:flutter/material.dart';

/// Represents a chess piece
class ChessPiece {
  final String type; // K, Q, R, B, N, P (uppercase for white, lowercase for black)
  final bool isWhite;
  final int row;
  final int col;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.row,
    required this.col,
  });

  /// Get Unicode symbol for the piece
  String get symbol {
    final pieceSymbols = {
      'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
      'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
    };
    return pieceSymbols[type] ?? '';
  }

  ChessPiece copyWith({int? row, int? col}) {
    return ChessPiece(
      type: type,
      isWhite: isWhite,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}

/// Interactive chess board widget
class ChessBoard extends StatefulWidget {
  final String? fenNotation;
  final double size;

  const ChessBoard({
    super.key,
    this.fenNotation,
    this.size = 320,
  });

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with SingleTickerProviderStateMixin {
  List<ChessPiece> pieces = [];
  ChessPiece? selectedPiece;
  late AnimationController _animationController;
  Animation<Offset>? _moveAnimation;
  ChessPiece? _animatingPiece;
  Set<String> validMoves = {}; // Store valid move positions as "row,col"

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _parseFEN(widget.fenNotation);
  }

  @override
  void didUpdateWidget(ChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fenNotation != widget.fenNotation) {
      setState(() {
        selectedPiece = null;
        validMoves.clear();
        _parseFEN(widget.fenNotation);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Parse FEN notation to extract piece positions
  void _parseFEN(String? fen) {
    pieces.clear();
    if (fen == null || fen.isEmpty) return;

    // FEN format: board position / active color / castling / en passant / halfmove / fullmove
    // We only need the board position (first part)
    final parts = fen.split(' ');
    if (parts.isEmpty) return;

    final rows = parts[0].split('/');
    for (int rowIndex = 0; rowIndex < rows.length && rowIndex < 8; rowIndex++) {
      int colIndex = 0;
      for (final char in rows[rowIndex].split('')) {
        if (RegExp(r'[1-8]').hasMatch(char)) {
          // Empty squares
          colIndex += int.parse(char);
        } else if (RegExp(r'[pnbrqkPNBRQK]').hasMatch(char)) {
          // Piece
          final isWhite = char == char.toUpperCase();
          pieces.add(ChessPiece(
            type: char,
            isWhite: isWhite,
            row: rowIndex,
            col: colIndex,
          ));
          colIndex++;
        }
      }
    }
  }

  /// Handle piece selection or movement
  void _onSquareTap(int row, int col) {
    if (selectedPiece != null) {
      // Move selected piece to new position
      _movePiece(selectedPiece!, row, col);
    } else {
      // Select piece at this position
      final piece = _getPieceAt(row, col);
      if (piece != null) {
        setState(() {
          selectedPiece = piece;
          _calculateValidMoves(piece);
        });
      }
    }
  }

  /// Calculate valid moves for a piece (simplified - shows all empty squares and captures)
  void _calculateValidMoves(ChessPiece piece) {
    validMoves.clear();
    
    // For now, allow moves to any square (full chess rules would be complex)
    // In a real implementation, this would check piece-specific movement rules
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        // Skip the piece's current position
        if (row == piece.row && col == piece.col) continue;
        
        final targetPiece = _getPieceAt(row, col);
        // Allow moves to empty squares or capturing opponent pieces
        if (targetPiece == null || targetPiece.isWhite != piece.isWhite) {
          validMoves.add('$row,$col');
        }
      }
    }
  }

  /// Get piece at specific position
  ChessPiece? _getPieceAt(int row, int col) {
    for (final piece in pieces) {
      if (piece.row == row && piece.col == col) {
        return piece;
      }
    }
    return null;
  }

  /// Move piece with animation
  void _movePiece(ChessPiece piece, int toRow, int toCol) {
    final fromRow = piece.row;
    final fromCol = piece.col;

    // Remove any piece at destination
    pieces.removeWhere((p) => p.row == toRow && p.col == toCol);

    // Setup animation
    final squareSize = widget.size / 8;
    final fromOffset = Offset(fromCol * squareSize, fromRow * squareSize);
    final toOffset = Offset(toCol * squareSize, toRow * squareSize);

    _moveAnimation = Tween<Offset>(
      begin: fromOffset,
      end: toOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animatingPiece = piece;

    _animationController.forward(from: 0).then((_) {
      setState(() {
        // Update piece position
        final index = pieces.indexOf(piece);
        if (index != -1) {
          pieces[index] = piece.copyWith(row: toRow, col: toCol);
        }
        selectedPiece = null;
        validMoves.clear();
        _animatingPiece = null;
      });
    });

    setState(() {
      selectedPiece = null;
      validMoves.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final squareSize = widget.size / 8;

    // Chess.com inspired board colors
    final lightSquare = theme.colorScheme.secondary; // #B58863
    final darkSquare = const Color(0xFF8B6F47); // Complementary dark brown

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Chess board squares
            Column(
              children: List.generate(8, (row) {
                return Row(
                  children: List.generate(8, (col) {
                    final isLightSquare = (row + col) % 2 == 0;
                    final isSelected = selectedPiece != null &&
                        selectedPiece!.row == row &&
                        selectedPiece!.col == col;
                    final isValidMove = validMoves.contains('$row,$col');

                    return GestureDetector(
                      onTap: () => _onSquareTap(row, col),
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : (isLightSquare ? lightSquare : darkSquare),
                        ),
                        child: isValidMove
                            ? Center(
                                child: Container(
                                  width: squareSize * 0.3,
                                  height: squareSize * 0.3,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                );
              }),
            ),
            // Chess pieces
            ...pieces.where((piece) => piece != _animatingPiece).map((piece) {
              return Positioned(
                left: piece.col * squareSize,
                top: piece.row * squareSize,
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  alignment: Alignment.center,
                  child: Text(
                    piece.symbol,
                    style: TextStyle(
                      fontSize: squareSize * 0.7,
                      height: 1.0,
                    ),
                  ),
                ),
              );
            }),
            // Animating piece
            if (_animatingPiece != null && _moveAnimation != null)
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
                      child: Text(
                        _animatingPiece!.symbol,
                        style: TextStyle(
                          fontSize: squareSize * 0.7,
                          height: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
