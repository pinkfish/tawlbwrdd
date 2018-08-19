import 'package:flutter/foundation.dart';

///
/// The piece in the board.
///
enum Piece {
  King,
  Defender,
  Attacker,
  Empty,
}

///
/// Specific point in the board.
///
class Point {
  final int x;
  final int y;

  Point({@required this.x, @required this.y});

  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

///
/// The board itself.
///
class Board {
  List<List<Piece>> pieces;

  static const int BOARD_SIZE = 11;

  Board.empty()
      : pieces = new List<List<Piece>>.generate(BOARD_SIZE,
            (int pos) => new List<Piece>.filled(BOARD_SIZE, Piece.Empty));
  Board.copy(Board b)
      : pieces = new List<List<Piece>>.generate(
            BOARD_SIZE,
            (int y) => new List<Piece>.generate(
                BOARD_SIZE, (int x) => b.pieces[y][x]));

  ///
  /// Creates the basic layout for the board.
  ///
  void setupBasicLayout() {
    for (int i = 0; i < 5; i++) {
      pieces[0][i + 3] = Piece.Attacker;
      pieces[10][i + 3] = Piece.Attacker;
      pieces[i + 3][0] = Piece.Attacker;
      pieces[i + 3][10] = Piece.Attacker;
    }
    pieces[5][5] = Piece.King;

    pieces[1][5] = Piece.Attacker;
    pieces[9][5] = Piece.Attacker;
    pieces[5][9] = Piece.Attacker;
    pieces[5][1] = Piece.Attacker;

    for (int i = 0; i < 3; i++) {
      pieces[5][i + 2] = Piece.Defender;
      pieces[5][i + 6] = Piece.Defender;
      pieces[i + 2][5] = Piece.Defender;
      pieces[i + 6][5] = Piece.Defender;
    }
  }

  static const String PIECE = "PIECE";

  ///
  /// Figure out if two pieces are the same.
  ///
  bool isPieceEquivilant(Piece p1, Piece p2) {
    return p1 == p2 ||
        p1 == Piece.King && p2 == Piece.Defender ||
        p2 == Piece.King && p1 == Piece.Defender;
  }

  ///
  /// Create the board from the json representation.
  ///
  Board.fromJSON(Map<dynamic, dynamic> data) {
    // Start with an empty board.
    pieces = new List<List<Piece>>.generate(data.length,
        (int pos) => new List<Piece>.filled(data.length, Piece.Empty));
    data.forEach((dynamic key, dynamic dataRow) {
      int index = int.parse(key);
      Map<dynamic, dynamic> row = dataRow;
      row.forEach((dynamic key, dynamic colData) {
        int rowIndex = int.parse(key);
        pieces[index][rowIndex] = Piece.values
            .firstWhere((Piece p) => p.toString() == colData[PIECE]);
      });
    });
  }

  ///
  /// Turn the board into json.
  ///
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {};
    int y = 0;
    for (List<Piece> row in pieces) {
      data[y.toString()] = {};
      int x = 0;
      for (Piece col in row) {
        data[y.toString()][x.toString()] = {
          PIECE: col.toString(),
        };
        x++;
      }
      y++;
    }
    return data;
  }
}
