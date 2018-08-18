import 'package:flutter/material.dart';
import 'package:tawlbwrdd/db/gamedata.dart';
import 'package:tawlbwrdd/model/fuseduserprofile.dart';

class UserNameWidget extends StatelessWidget {
  final GameData data;
  final String uid;
  final TextStyle style;

  UserNameWidget({this.data, this.uid, this.style});

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: data.getProfile(uid),
      builder: (BuildContext context, AsyncSnapshot<FusedUserProfile> val) {
        if (val.hasData) {
          if (val.data == null || val.data.displayName == null) {
            return Text("Unknown", style: style);
          }
          return Text(
            val.data.displayName,
            style: style,
          );
        }
        return Text(
          "Loading...",
          style: style,
        );
      },
    );
  }
}
