import 'board.dart';

enum GameStatus { WaitingForPlayer, Started, AttackerWon, DefenderWon }

class Game {
  Board board;

  String playerUidDefender;
  String playerUidAttacker;
  int turnNumber;

  GameStatus status;
  String _uid;

  String get uid => _uid;

  Game.empty()
      : board = new Board.empty(),
        playerUidAttacker = null,
        playerUidDefender = null,
        turnNumber = 0,
        _uid = null,
        status = GameStatus.WaitingForPlayer;

  Game.copyWith(String uid, Game g)
      : _uid = uid,
        board = new Board.copy(g.board),
        playerUidAttacker = g.playerUidAttacker,
        playerUidDefender = g.playerUidDefender,
        turnNumber = g.turnNumber,
        status = g.status;

  void start() {
    status = GameStatus.Started;
    board.setupBasicLayout();
  }

  bool isAttackerTurn() {
    return turnNumber % 2 == 0;
  }

  bool isUserTurn(String userUid) {
    if (status != GameStatus.Started) {
      return false;
    }
    if (userUid == playerUidAttacker && isAttackerTurn()) {
      return true;
    }
    return userUid == playerUidDefender && !isAttackerTurn();
  }

  bool isMoveValid(Point from, Point to) {
    if (status != GameStatus.Started) {
      return false;
    }
    if (from.x == to.x || from.y == to.y) {
      if (board.pieces[from.y][from.x] != Piece.Empty &&
          board.pieces[to.y][to.x] == Piece.Empty) {
        // if the turn number is odd then it is the attackers
        // move.
        if (isAttackerTurn()) {
          if (board.pieces[from.y][from.x] != Piece.Attacker) {
            print('Not right turn');
            return false;
          }
        } else {
          if (board.pieces[from.y][from.x] != Piece.King &&
              board.pieces[from.y][from.x] != Piece.Defender) {
            print('Not right turn');
            return false;
          }
        }
        // Now see if anything is in the way
        if (from.x == to.x) {
          int offset = to.y < from.y ? -1 : 1;
          for (int i = from.y + offset;
              offset < 0 ? i > to.y : i < to.y;
              i += offset) {
            if (board.pieces[i][from.x] != Piece.Empty) {
              return false;
            }
            print('${board.pieces[i][from.x]} $i $from.x');
          }
          print('Valid! $from $to');
          return true;
        } else {
          int offset = to.x < from.x ? -1 : 1;
          for (int i = from.x + offset;
              offset < 0 ? i > to.x : i < to.x;
              i += offset) {
            if (board.pieces[from.y][i] != Piece.Empty) {
              return false;
            }
          }
          print('Valid! $from $to');
          return true;
        }
      }
    }
    return false;
  }

  bool checkCapture(Point p, int x, int y) {
    int newXEnd = p.x + x * 2;
    int newYEnd = p.y + y * 2;
    int newXMid = p.x + x;
    int newYMid = p.y + y;
    if (newYEnd >= 0 && newYEnd < board.pieces.length) {
      if (newXEnd >= 0 && newXEnd < board.pieces[newYEnd].length) {
        if (board.isPieceEquivilant(
            board.pieces[newYEnd][newXEnd], board.pieces[p.y][p.x])) {
          if (!board.isPieceEquivilant(
              board.pieces[newYMid][newXMid], board.pieces[p.y][p.x])) {
            if (board.pieces[newYMid][newXMid] == Piece.King) {
              status = GameStatus.AttackerWon;
            }
            board.pieces[newYMid][newXMid] = Piece.Empty;
            return true;
          }
        }
      }
    }
    return false;
  }

  bool makeMove(Point from, Point to) {
    if (!isMoveValid(from, to)) {
      return false;
    }
    board.pieces[to.y][to.x] = board.pieces[from.y][from.x];
    board.pieces[from.y][from.x] = Piece.Empty;

    // Check for captures.
    checkCapture(to, -1, 0);
    checkCapture(to, 1, 0);
    checkCapture(to, 0, -1);
    checkCapture(to, 0, 1);
    if (board.pieces[to.y][to.x] == Piece.King) {
      if (to.y == 0 ||
          to.y == board.pieces.length - 1 ||
          to.x == 0 ||
          to.y == board.pieces[0].length - 1) {
        status = GameStatus.DefenderWon;
      }
    }
    if (status == GameStatus.WaitingForPlayer) {
      status = GameStatus.Started;
    }
    turnNumber++;
  }

  static const String BOARD = "board";
  static const String PLAYER = "player";
  static const String ADDED = "added";
  static const String DEFENDER = "defender";
  static const String STATUS = "status";
  static const String TURN = "turn";

  Game.fromJSON(String uid, Map<String, dynamic> data) {
    _uid = uid;
    Map<dynamic, dynamic> playerData = data[PLAYER];
    playerData.forEach((dynamic key, dynamic details) {
      if (details[DEFENDER]) {
        playerUidDefender = key;
      } else {
        playerUidAttacker = key;
      }
    });
    status = GameStatus.values
        .firstWhere((GameStatus status) => status.toString() == data[STATUS]);
    turnNumber = int.tryParse(data[TURN]) ?? 0;

    board = new Board.fromJSON(data[BOARD]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {};
    data[STATUS] = status.toString();
    data[TURN] = turnNumber.toString();
    data[BOARD] = board.toJSON();
    data[PLAYER] = new Map<String, Map<String, dynamic>>();
    if (playerUidDefender != null) {
      data[PLAYER][playerUidDefender] = new Map<String, dynamic>();
      data[PLAYER][playerUidDefender][ADDED] = true;
      data[PLAYER][playerUidDefender][DEFENDER] = true;
    }
    if (playerUidAttacker != null) {
      data[PLAYER][playerUidAttacker] = new Map<String, dynamic>();
      data[PLAYER][playerUidAttacker][ADDED] = true;
      data[PLAYER][playerUidAttacker][DEFENDER] = false;
    }
    return data;
  }

  @override
  String toString() {
    return 'Game{board: $board, playerUidDefender: $playerUidDefender, playerUidAttacker: $playerUidAttacker, turnNumber: $turnNumber, status: $status, _uid: $_uid}';
  }


}
