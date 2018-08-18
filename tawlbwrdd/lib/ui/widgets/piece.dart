import 'package:flutter/material.dart';
import 'package:tawlbwrdd/model/board.dart';
import 'communityicons.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final GestureTapCallback onTap;
  final bool selected;

  PieceWidget({this.piece, this.onTap, this.selected});

  @override
  Widget build(BuildContext context) {
    Color myColor = Colors.blueAccent;
    Color iconColor = Colors.black;
    IconData icon;
    switch (piece) {
      case Piece.Defender:
        myColor = Colors.grey.shade200;
        icon = CommunityIcons.shield;
        iconColor = Colors.blueAccent;
        break;
      case Piece.Attacker:
        myColor = Colors.grey.shade200;
        icon = CommunityIcons.swordCross;
        break;
      case Piece.Empty:
        myColor = Colors.grey.shade200;
        icon = CommunityIcons.solid;
        iconColor = Colors.grey.shade200;
        break;
      case Piece.King:
        myColor = Colors.yellowAccent;
        icon = CommunityIcons.crown;
        iconColor = Colors.blueAccent;
        break;
    }
    return new GestureDetector(
      onTap: () => onTap(),
      child: new AnimatedContainer(
        decoration: new BoxDecoration(
          color: myColor,
          border: new Border.all(
            color: selected ? Colors.black : Colors.white,
            width: 1.0,
          ),
        ),
        duration: new Duration(milliseconds: 500),
        margin: EdgeInsets.all(0.0),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
