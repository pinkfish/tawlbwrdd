import 'package:flutter/material.dart';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'vsline.dart';

class GameListWidget extends StatelessWidget {
  final Game game;
  final GestureTapCallback onTap;
  final GameData data;

  GameListWidget({this.game, this.onTap, this.data});

  String _statusString() {
    switch (game.status) {
      case GameStatus.Started:
        if (game.isUserTurn(data.currentFirebaseUser.uid)) {
          return "In Progress\nYour turn!";
        }
        return "In Progress\nTheir turn.";
      case GameStatus.AttackerWon:
        return "Attacker Won!";
      case GameStatus.DefenderWon:
        return "Defender Won!";
      case GameStatus.WaitingForPlayer:
        if (game.playerUidAttacker == data.currentFirebaseUser.uid ||
            game.playerUidDefender == data.currentFirebaseUser.uid) {
          return "Waiting for player";
        }
        return "Join Game!";
    }
  }

  Widget _buildTrailing(BuildContext context) {
    switch (game.status) {
      case GameStatus.Started:
        if (game.isUserTurn(data.currentFirebaseUser.uid)) {
          return const Icon(Icons.flag);
        }
        return const Icon(Icons.check);
      case GameStatus.AttackerWon:
        if (game.playerUidAttacker == data.currentFirebaseUser.uid) {
          return Text("Won",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.green));
        }
        return Text("Lost",
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.red));
      case GameStatus.DefenderWon:
        if (game.playerUidDefender == data.currentFirebaseUser.uid) {
          return Text("Won",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.green));
        }
        return Text("Lost",
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.red));
      case GameStatus.WaitingForPlayer:
        if (game.playerUidAttacker == data.currentFirebaseUser.uid ||
            game.playerUidDefender == data.currentFirebaseUser.uid) {
          return const Icon(Icons.person_add);
        }

        return const Icon(Icons.people_outline);
    }
    return SizedBox(
      height: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color myColor = Colors.white;
    return new GestureDetector(
      onTap: () => onTap(),
      child: new AnimatedContainer(
        decoration: new BoxDecoration(
          color: myColor,
        ),
        duration: new Duration(milliseconds: 500),
        margin: EdgeInsets.all(0.0),
        child: new Card(
          child: new ListTile(
            leading: const Icon(Icons.gamepad),
            title: VsLine(data: data, game: game),
            subtitle: Text(_statusString()),
            trailing: _buildTrailing(context),
          ),
        ),
      ),
    );
  }
}
