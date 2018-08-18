import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/ui/widgets/login.dart';
import 'package:tawlbwrdd/model/fuseduserprofile.dart';

class LoginScreen extends StatefulWidget {
  final GameData data;

  LoginScreen({this.data});

  @override
  State createState() {
    return new _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // Get the games and setup the callback.
    widget.data.currentProfileChanged.listen((FusedUserProfile user) {
      setState(() {});
    });
    super.initState();
  }

  Widget _buildBody() {
    if (widget.data.currentFirebaseUser == null) {
      return LoginWidget(data: widget.data);
    }
    return Column(
      children: <Widget>[
        Text("Hello " + widget.data.currentProfile.displayName),
        FlatButton(
          child: Text("Show Games"),
          onPressed: () => Navigator.pushNamed(context, "/Home"),
          textTheme: Theme.of(context).buttonTheme.textTheme,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Tawlbwrdd - Games"),
      ),
      body: _buildBody(),
    );
  }
}
