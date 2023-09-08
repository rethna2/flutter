import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  /*
  final List response;
  final bool showNext;
  final Widget children;
*/
  final Function onPick;
  static List keyEntries = [
    'QWERTYUIOP',
    'ASDFGHJKL',
    'ZXCVBNM',
    ['Space', 'DEL', 'Done']
  ];

  const Keyboard({
    Key? key,
    required this.onPick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < keyEntries.length; i++) ...[
                Container(
                    child: Row(children: [
                  for (int j = 0; j < keyEntries[i].length; j++) ...[
                    Expanded(
                        child: GestureDetector(
                            onTap: () => onPick(keyEntries[i][j]),
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.blueAccent)),
                                child: Text(keyEntries[i][j],
                                    textAlign: TextAlign.center))))
                  ]
                ])),
              ]
            ]));
  }
}
