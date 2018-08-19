import 'package:fluro/fluro.dart';
import 'package:tawlbwrdd/ui/screens/main/game.dart';
import 'package:tawlbwrdd/ui/screens/main/gamelist.dart';
import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/ui/screens/login/loginscreen.dart';
import 'package:tawlbwrdd/ui/screens/main/addgame.dart';
import 'package:tawlbwrdd/ui/screens/main/rules.dart';
import 'package:tawlbwrdd/ui/screens/main/about.dart';

class AppRoutes {
  static GameData data;

  static Router myRouter;

  static Router get instance {
    if (myRouter == null) {
      myRouter = _setupRoutes();
    }
    return myRouter;
  }

  static Router _setupRoutes() {
    Router router = new Router();
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(
      "/Home",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new GameList(data: data);
      }),
    );
    router.define(
      "/AddGame",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new AddGameScreen(gameData: data);
      }),
    );
    router.define(
      "/About",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new AboutScreen();
      }),
    );
    router.define(
      "/Rules",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new RulesScreen();
      }),
    );
    router.define(
      "/Game/:id",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new GameDetails(
          game: data.getGame(params["id"][0]),
          gameData: data,
        );
      }),
    );
    router.define(
      "/Login",
      handler: new Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new LoginScreen(data: data);
      }),
    );
    return router;
  }
}
