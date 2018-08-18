import 'package:flutter/material.dart';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/ui/widgets/gamelistwidget.dart';
import 'package:tawlbwrdd/ui/widgets/savingoverlay.dart';
import 'package:tawlbwrdd/ui/widgets/joingamedialog.dart';

import 'dart:async';

class AddGameScreen extends StatefulWidget {
  final GameData gameData;

  AddGameScreen({this.gameData});

  @override
  State createState() {
    return new _AddGameScreenState();
  }
}

class _AddGameScreenState extends State<AddGameScreen> {
  bool _defender = false;
  bool _saving = false;
  List<Game> openGames;
  StreamSubscription<List<Game>> changeStream;

  @override
  void initState() {
    widget.gameData.getGamesNeedingPlayers().then((GameListSetup data) {
      setState(() {
        openGames = data.games;
      });
      changeStream = data.stream.listen((List<Game> data) {
        setState(() {
          openGames = data;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    changeStream?.cancel();
    super.dispose();
  }

  void _joinDialog(Game g) async {
    joinGameDialog(context, g, widget.gameData);
  }

  void _createGame() async {
    print('Creating');
    setState(() {
      _saving = true;
    });
    try {
      Game game = new Game.empty();
      if (_defender) {
        game.playerUidDefender = widget.gameData.currentFirebaseUser.uid;
      } else {
        game.playerUidAttacker = widget.gameData.currentFirebaseUser.uid;
      }
      print('About to add ${widget.gameData}');
      await widget.gameData.addGame(game);
      print('Did the add');
      Navigator.pushNamed(context, "/Home");
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Widget _buildWaitingForPlayers() {
    if (openGames == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Waiting for players",
            style: Theme.of(context).textTheme.subhead,
          ),
          Text("Loading..."),
        ],
      );
    }
    List<Widget> rows = [];
    rows.add(Text("Waiting for players",
        style: Theme.of(context).textTheme.subhead));
    for (Game g in openGames) {
      rows.add(new GameListWidget(
        game: g,
        data: widget.gameData,
        onTap: () => _joinDialog(g),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Waiting for players",
          style: Theme.of(context).textTheme.subhead,
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: rows,
          ),
        ),
      ],
    );
  }

  void _showRules() {
    Navigator.pushNamed(context, "/Rules");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Tawlbwrdd - Add Game"),
      ),
      body: SavingOverlay(
        saving: _saving,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    text: "This will create a new Tawlbwrdd game for you "
                        "to play.  You can set your initial position to be "
                        "an attacker or defender.  Attackers always go first."),
              ),
            ),
            new CheckboxListTile(
              title: const Text("Defender"),
              value: _defender,
              onChanged: (bool val) => _defender = val,
            ),
            new Row(
              children: <Widget>[
                new MaterialButton(
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: Text("CREATE"),
                  onPressed: _createGame,
                ),
                new SizedBox(
                  width: 10.0,
                ),
                new MaterialButton(
                  color: Theme.of(context).highlightColor,
                  textColor: Colors.white,
                  child: Text("RULES"),
                  onPressed: _showRules,
                ),
              ],
            ),
            new Divider(),
            _buildWaitingForPlayers()
          ],
        ),
      ),
    );
  }
}
