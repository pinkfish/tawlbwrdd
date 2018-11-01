import 'package:flutter/material.dart';
import 'package:tawlbwrdd/services/approutes.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/services/analytics.dart';
import 'package:tawlbwrdd/services/notifications.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:tawlbwrdd/services/loggingdata.dart';
import 'package:tawlbwrdd/ui/screens/splash/splashscreen.dart';

Notifications notification;

void main() async {
  Trace trace = Analytics.instance.newTrace("startup");
  trace.start();
  // Send error logs up to sentry.
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingData.instance.logFlutterError(details);
  };
  GameData data = new GameData();
  await data.currentUserAsync();
  notification = new Notifications(data);
  notification.init();

  trace.stop();
  runApp(new MyApp(
    gameData: data,
  ));
}

class MyApp extends StatelessWidget {
  final GameData gameData;
  MyApp({this.gameData});

  Route<dynamic> _buildRoute(RouteSettings routeSettings) {
    print("Building route... $routeSettings");
    return AppRoutes.instance.generator(routeSettings);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppRoutes.instance.printTree();
    AppRoutes.data = gameData;
    print('Running this bit');
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[
        new FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      home: SplashScreen(),
      initialRoute: gameData.currentFirebaseUser == null ? "/Login" : "/Home",
      onGenerateRoute: _buildRoute,
    );
  }
}
