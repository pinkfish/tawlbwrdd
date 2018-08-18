import 'package:flutter/material.dart';

class RulesScreen extends StatefulWidget {
  @override
  State createState() {
    return new _RulesScreenState();
  }
}

class _RulesScreenState extends State<RulesScreen> {
  static const String rules = """
These rules were taken from the account of Robert ap Ifan in 1587. There are many omissions from that source, so the gaps have been filled by borrowing rules from Tablut, a game more fully described by its contemporary observers.


""";
  static const List<String> steps = [
    "Tawlbwrdd is played on a board of 11 squares by 11, with a king and twelve defenders against twenty-four attackers.", // Alternatively a board of 9 rows of 9 squares can be used, with a king and eight defenders against sixteen attackers.\n",
    "The king is placed in the centre of the board, with his defenders around him and the attackers at the edge of the board.",
    "The attackers make the first move.",
    "In his turn a player may move a piece across the board by any number of spaces in a straight line, horizontally or vertically.",
    "A piece may not land on another, nor may it leap over a piece.",
    "The king moves in the same way as the other pieces.",
    "An enemy piece is captured by surrounding it on two opposite sides, horizontally or vertically. That piece is removed from the board.",
    "It is possible to capture two or three pieces at once by so surrounding them.",
    "It is not possible to capture a row of pieces.",
    "The defending player wins the game by moving the king to any square on the edge of the board.",
    "The attacking player wins by capturing the king.",
  ];

  List<Widget> _buildSteps() {
    List<Widget> spans = [];
    spans.add(
      RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.body1,
          text: rules,
        ),
      ),
    );
    for (int i = 0; i < steps.length; i++) {
      spans.add(
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 25.0,
                height: 25.0,
                child: Text(
                  "${i + 1}",
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              new SizedBox(width: 5.0),
              Flexible(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: steps[i],
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text("Tawlbwrdd - Rules"),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _buildSteps(),
            ),
          ),
        )

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
