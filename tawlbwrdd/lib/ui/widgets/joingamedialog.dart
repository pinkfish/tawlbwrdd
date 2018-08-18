import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'gamelistwidget.dart';

Future<bool> joinGameDialog(
    BuildContext context, Game g, GameData gameData) async {
  String attacker = "attacker";
  if (g.playerUidDefender == null) {
    attacker = "defender";
  }
  bool ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text("Join Game"),
          content: Column(
            children: <Widget>[
              Text("Do you want to join the game as a " + attacker + "?"),
              GameListWidget(
                game: g,
                data: gameData,
              ),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      });
  if (ret != null && ret == true) {
    if (g.playerUidDefender == null) {
      g.playerUidDefender = gameData.currentFirebaseUser.uid;
    } else {
      g.playerUidAttacker = gameData.currentFirebaseUser.uid;
    }
    print('Updating... $g');
    await gameData.updateGame(g);
  }
  return ret;
}
