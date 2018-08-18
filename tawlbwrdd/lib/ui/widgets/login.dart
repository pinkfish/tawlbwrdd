// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/ui/widgets/savingoverlay.dart';

class LoginWidget extends StatefulWidget {
  final GameData data;
  LoginWidget({Key key, this.data}) : super(key: key);

  @override
  _LoginWidgetState createState() => new _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool _loading;
  String name;
  TextEditingController _displayNameController = new TextEditingController();

  Future<void> _signInAnonymously() async {
    if (name == '') {
      return ;
    }
    setState(() {
      _loading = true;
    });
    print('Logging in with $name');
    await widget.data.signInAnonymously(name);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SavingOverlay(
      saving: _loading,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
              "assets/images/tawlbwrdd.jpg"
          ),
          new Container(
            margin: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: new TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
              onChanged: (String str) => name = str,
            ),
          ),
          new Row(
            children: <Widget>[
              new MaterialButton(
                  child: const Text('Start'),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  onPressed: () {
                    if (_displayNameController.text != null) {
                      setState(() {
                        _signInAnonymously();
                      });
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
