import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/model/game.dart';

class VsLine extends StatelessWidget {
  final GameData data;
  final Game game;

  VsLine({this.data, this.game});

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: data.getGameVs(game),
      builder: (BuildContext context, AsyncSnapshot<String> val) {
        if (val.hasData) {
          return new Text(val.data);
        }
        return Text("Loading");
      },
    );
  }
}
