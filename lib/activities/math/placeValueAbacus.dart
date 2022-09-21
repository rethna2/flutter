import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../comps/numInput.dart';
import '../comps/footer.dart';
import '../comps/actComplete.dart';
import '../../utils/dataUtils.dart' as utils;

class PlaceValueAbacus extends StatefulWidget {
  const PlaceValueAbacus(
      {Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<PlaceValueAbacus> createState() => _PlaceValueAbacusState();
}

List allColors = [
  0xff21b0df,
  0xffffa858,
  0xffddc800,
  0xff9494ff,
  0xffd165ff,
  0xffff6bdd,
  0xffa0a0a0,
  0xffafea30
];

class _PlaceValueAbacusState extends State<PlaceValueAbacus> {
  int index = 0;
  late List list;
  List response = [];
  bool answered = false;
  bool done = false;
  String input = '';
  late List colors;
  late Timer timer;
  @override
  void initState() {
    var random = new Math.Random();
    list = [];
    String str = widget.data['pattern'];
    num no = 9;
    for (int i = 0; i < str.length - 1; i++) {
      no = no * 10;
    }
    print('initState $no');
    while (list.length < 10) {
      num number = utils.getFormatedRandom(str);
      if (list.indexOf(number) == -1) {
        list.add(number);
      }
    }
    print('initState list: $list');
    colors = [...allColors];
    colors.sort((a, b) => random.nextDouble() > 0.5 ? -1 : 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      return ActComplete(
          onNext: (response) {
            widget.activityCallback({'type': 'complete', 'response': response});
          },
          response: response,
          children:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int i = 0; i < response.length; i++)
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${i + 1}. ${response[i]['ans']}',
                    style: TextStyle(
                        color:
                            response[i]['right'] ? Colors.green : Colors.red),
                  ))
          ]));
    }
    double width = list[index] < 10000 ? 75 : 50;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text("Write the number shown on the abacus"),
      Center(
          child: Container(
              child: CustomPaint(
                  size: Size(width * list[index].toString().length, 300),
                  painter: Painter(value: list[index], colors: colors)))),
      Stack(clipBehavior: Clip.none, children: [
        Container(
            padding: const EdgeInsets.all(5),
            width: 150,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Text(input,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ))),
        if (answered)
          Positioned(
              right: -20,
              top: -20,
              child: Image.asset(
                  response[response.length - 1]['right']
                      ? 'assets/tick.png'
                      : 'assets/cross.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain)),
      ]),
      NumInput(onInput: (no) {
        if (answered) {
          return;
        }
        setState(() {
          if (no == 'x') {
            if (input.length > 0) {
              input = input.substring(0, input.length - 1);
            }
          } else {
            if (input.length < 8) {
              input = input + no;
            }
          }
        });
      }),
      Footer(
        onNext: () {
          if (index >= list.length - 1) {
            setState(() {
              done = true;
            });
            widget
                .activityCallback({'type': 'resultView', 'response': response});
          } else {
            setState(() {
              index++;
              answered = false;
              input = "";
            });
          }
        },
        response: response,
        showNext: answered,
        children: answered
            ? const SizedBox.shrink()
            : ElevatedButton(
                onPressed: () {
                  bool right = false;
                  int ans = int.parse(input);
                  if (ans == list[index]) {
                    right = true;
                  }
                  setState(() {
                    answered = true;
                    response = [
                      ...response,
                      {'right': right, 'ans': ans}
                    ];
                  });
                  int prog = ((index + 1) / list.length * 100).ceil();
                  widget
                      .activityCallback({'type': 'progress', 'progress': prog});
                },
                child: Text('Submit')),
      )
    ]);
  }
}

class Painter extends CustomPainter {
  Painter({required this.value, required this.colors});
  int value;
  List colors;
  @override
  void paint(Canvas canvas, Size size) {
    print('value = $value');
    Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Path path = Path();

    double xoffset = 5;
    var strArr = value.toString().split('');
    num width = strArr.length < 5 ? 75.0 : 50.0;
    List arr = ['O', 'T', 'H', 'Th', 'T Th', 'L', 'TL'];
    arr = arr.sublist(0, strArr.length);
    arr = new List.from(arr.reversed);
    for (int i = 0; i < strArr.length; i++) {
      double w = i * width + 0.0;
      path.addRect(Rect.fromLTWH(xoffset + w + 8, 50, 5, 200));

      final TextPainter textPainter = TextPainter(
          text: TextSpan(
              text: arr[i],
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              )),
          maxLines: 1,
          textDirection: TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
      textPainter.paint(
          canvas, Offset(w + xoffset + 10 - textPainter.width / 2, 250));
    }
    path.addRect(
        Rect.fromLTWH(xoffset - 5, 250, (strArr.length - 1) * width + 25, 20));
    canvas.drawPath(path, paint);
    for (int i = 0; i < strArr.length; i++) {
      double w = 20.0 + i * width;
      int val = int.parse(strArr[i]);
      Paint paint2 = Paint()
        ..color = new Color(colors[i])
        ..style = PaintingStyle.fill;
      Path path2 = Path();
      for (int j = 0; j < val; j++) {
        path2.addOval(Rect.fromLTWH(w + xoffset - 20, 230 - j * 21, 20, 20));
      }
      canvas.drawPath(path2, paint2);
      //canvas.clipRect(Rect.fromLTWH(0, 0, 400, 400));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
