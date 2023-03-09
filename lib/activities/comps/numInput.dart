import 'package:flutter/material.dart';

class NumInput extends StatelessWidget {
  final Function onInput;
  final bool singleNumber;
  final bool decimal;
  const NumInput(
      {Key? key,
      required this.onInput,
      this.singleNumber = false,
      this.decimal = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List r1, r2;
    if (singleNumber) {
      r1 = '12345'.split('');
      r2 = '67890'.split('');
    } else {
      r1 = '123456'.split('');
      r2 = decimal ? '7890.x'.split('') : '7890.−x'.split('');
    }

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (var i = 0; i < r1.length; i++)
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        onInput(r1[i]);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        decoration: BoxDecoration(
                            color: Color(0xff1b75b7),
                            border:
                                Border.all(color: Colors.white, width: 1.0)),
                        child: Text(
                          r1[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      )))
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (var i = 0; i < r2.length; i++)
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        var key = r2[i];
                        if (key == '−') {
                          key = '-';
                        }
                        onInput(key);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        decoration: BoxDecoration(
                            color:
                                r2[i] == 'x' ? Colors.red : Color(0xff1b75b7),
                            border:
                                Border.all(color: Colors.white, width: 1.0)),
                        child: Text(
                          r2[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      )))
          ])
        ],
      ),
    );
  }
}
