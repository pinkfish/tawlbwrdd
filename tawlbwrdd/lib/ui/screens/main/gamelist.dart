import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/ui/widgets/gamelistwidget.dart';
import 'package:tawlbwrdd/model/fuseduserprofile.dart';

import 'dart:async';

class GameList extends StatefulWidget {
  final GameData data;

  GameList({this.data});

  @override
  State createState() {
    return new _GameListState();
  }
}

class _GameListState extends State<GameList> {
  List<Game> games;
  StreamSubscription<List<Game>> stream;
  bool loading;

  @override
  void initState() {
    // Get the games and setup the callback.
    loading = true;
    try {
      widget.data
          .getGames(widget.data.currentFirebaseUser.uid)
          .then((GameListSetup data) {
        // Sort them first
        _filterAndSetGames(data.games);
        stream = data.stream.listen((List<Game> games) {
          _filterAndSetGames(data.games);
        });
        loading = false;
      });
    } catch (e, s) {
      print(s);
    }
    widget.data.currentProfileChanged.listen((FusedUserProfile user) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  void _filterAndSetGames(List<Game> games) {
    String userId = widget.data.currentFirebaseUser.uid;
    games.sort((Game g1, Game g2) {
      if (g1.isUserTurn(userId)) {
        if (!g2.isUserTurn(userId)) {
          return -1;
        }
        return g1.hashCode - g2.hashCode;
      }
      return g1.hashCode - g2.hashCode;
    });
    setState(() {
      this.games = games;
    });
  }

  Widget _buildGames() {
    if (loading) {
      return Center(child: Text("Loading..."));
    }
    if (games.length == 0) {
      return Center(child: Text("No games"));
    }
    List<Widget> gameList = [];
    for (Game g in games) {
      gameList.add(GameListWidget(
          game: g,
          data: widget.data,
          onTap: () => Navigator.pushNamed(context, "Game/" + g.uid)));
    }
    return SingleChildScrollView(
      child: Column(
        children: gameList,
      ),
    );
  }

  void _newGame() {
    Navigator.pushNamed(context, "/AddGame");
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text("Hello " + widget.data.currentProfile.displayName),
        _buildGames(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Tawlbwrdd - Games"),
      ),
      body: _buildBody(),
      floatingActionButton: new FloatingActionButton(
          child: const Icon(Icons.add), onPressed: _newGame),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
