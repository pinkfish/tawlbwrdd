import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tawlbwrdd/model/board.dart';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/ui/widgets/piece.dart';
import 'package:tawlbwrdd/ui/widgets/joingamedialog.dart';
import 'package:tawlbwrdd/ui/widgets/username.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'dart:async';

class GameDetails extends StatefulWidget {
  final Future<SingleGameSetup> game;
  final String userUid;
  final GameData gameData;

  GameDetails({@required this.game, this.userUid, this.gameData});

  @override
  State createState() {
    return new _GameDetailsState();
  }
}

class _GameDetailsState extends State<GameDetails> {
  Point _tappedLoc;
  Game _realGame;
  StreamSubscription<Game> _stream;
  bool _theirTurn;

  void initState() {
    widget.game.then((SingleGameSetup single) {
      setState(() {
        _realGame = single.games;
      });
      _stream?.cancel();
      _stream = single.stream.listen((Game g) {
        print('Updated game $g');
        setState(() {
          _realGame = g;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  Widget _buildBoard() {
    if (_realGame == null) {
      return Center(child: Text("Loading..."));
    }
    if (_realGame.playerUidDefender != null &&
        _realGame.playerUidAttacker != null &&
        _realGame.status == GameStatus.WaitingForPlayer) {
      _realGame.status = GameStatus.Started;
    }
    int y = 0;

    Size size = MediaQuery.of(context).size;
    double boxSize;
    if (size.width > size.height) {
      boxSize = (size.height - 10.0) / _realGame.board.pieces.length;
    } else {
      boxSize = (size.width - 10.0) / _realGame.board.pieces.length;
    }

    List<Widget> rows = [];
    for (List<Piece> row in _realGame.board.pieces) {
      List<Widget> children = [];
      int x = 0;
      for (Piece piece in row) {
        Point to = new Point(x: x, y: y);

        children.add(
          new SizedBox(
            width: boxSize,
            height: boxSize,
            child: new PieceWidget(
              piece: piece,
              onTap: () => _tapPiece(to),
              selected: _tappedLoc != null
                  ? (_tappedLoc.x == to.x || _tappedLoc.y == to.y) &&
                      _realGame.isMoveValid(_tappedLoc, to)
                  : false,
            ),
          ),
        );
        x++;
      }
      rows.add(
        new Row(
          children: children,
        ),
      );
      y++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
            new Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                border: new Border(
                  top: BorderSide(
                    color: Colors.lightBlue.shade100,
                    width: 5.0,
                  ),
                  bottom: BorderSide(
                    color: Colors.lightBlue.shade100,
                    width: 10.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Expanded(
                    flex: 1,
                    child: UserNameWidget(
                      data: widget.gameData,
                      uid: _realGame.playerUidAttacker,
                      style: Theme.of(context).textTheme.headline,
                    ),
                  ),
                  new SizedBox(width: 30.0, child: Text("vs")),
                  new Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: UserNameWidget(
                        data: widget.gameData,
                        uid: _realGame.playerUidDefender,
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new SizedBox(height: 10.0),
            new Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Expanded(
                  flex: 1,
                  child: new Text(
                    _statusString(),
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: Container(
                    child: new Text(
                      _realGame.status != GameStatus.WaitingForPlayer
                          ? "Turn ${_realGame.turnNumber + 1}"
                          : "",
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                ),
              ],
            ),
            new SizedBox(height: 10.0),
            new Container(
              margin: EdgeInsets.all(5.0),
              child: new Column(
                children: rows,
              ),
            ),
          ] +
          (_realGame.status == GameStatus.WaitingForPlayer
              ? _realGame.playerUidAttacker ==
                          widget.gameData.currentFirebaseUser.uid ||
                      _realGame.playerUidDefender ==
                          widget.gameData.currentFirebaseUser.uid
                  ? [
                      SizedBox(
                        height: 10.0,
                      ),
                      Center(
                        child: Text(
                          "Waiting for player to join",
                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.orange.shade900),
                        ),
                      ),
                    ]
                  : [
                      MaterialButton(
                        child: Text("JOIN GAME"),
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        onPressed: () => _joinDialog(_realGame),
                      )
                    ]
              : _realGame.isUserTurn(widget.userUid)
                  ? [Expanded(child: Center(child: Text("Your Turn!")))]
                  : []),
    );
  }

  String _statusString() {
    switch (_realGame.status) {
      case GameStatus.Started:
        if (_realGame.isUserTurn(widget.gameData.currentFirebaseUser.uid)) {
          return "Your turn (" +
              (_realGame.isAttackerTurn() ? "attacker)" : "defender)");
        }
        return "Their turn (" +
            (_realGame.isAttackerTurn() ? "attacker)" : "defender)");
      case GameStatus.AttackerWon:
        return "Attacker Won!";
      case GameStatus.DefenderWon:
        return "Defender Won!";
      case GameStatus.WaitingForPlayer:
        return "Not started";
    }
  }

  void _joinDialog(Game g) async {
    joinGameDialog(context, g, widget.gameData);
  }

  void _tapPiece(Point to) {
    if (_realGame.status != GameStatus.Started) {
      return;
    }
    if (_realGame.isUserTurn(widget.gameData.currentFirebaseUser.uid)) {
      _theirTurn = true;
      return;
    }
    print('tapped $to $_tappedLoc ${_realGame.board.pieces[to.y][to.x]}');
    if (_tappedLoc != null && _tappedLoc.x == to.x && _tappedLoc.y == to.y) {
      setState(() {
        _tappedLoc = null;
      });
    }
    if (_tappedLoc != null &&
        _realGame.board.pieces[to.y][to.x] == Piece.Empty) {
      // See if we can move here.
      if (_realGame.isMoveValid(_tappedLoc, to)) {
        _realGame.makeMove(_tappedLoc, to);
        widget.gameData.updateGame(_realGame);
        setState(() {
          _tappedLoc = null;
        });
      }
    } else {
      setState(() {
        _tappedLoc = to;
      });
      print('Updating tap loc $_tappedLoc');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Tawlbwrdd"),
      ),
      body: _buildBoard(),

      floatingActionButton: new FloatingActionButton(onPressed: () {
        _realGame.start();
        setState(() {});
      }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
