import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../../utils/dataUtils.dart' as utils;
import '../comps/numInput.dart';
import '../comps/footer.dart';
import '../comps/actComplete.dart';

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

Widget _inputBox(input, isCorrect, onActive, pos, active) {
  return Stack(clipBehavior: Clip.none, children: [
    GestureDetector(
        onTap: () => onActive(pos),
        child: Container(
            padding: const EdgeInsets.all(5),
            width: 70,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: isCorrect == null
                    ? (active == pos ? Color(0xffbcdbf7) : Colors.white)
                    : (isCorrect ? Colors.green : Colors.red)),
            child: Text(input[pos] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                )))),
  ]);
}

class NumberLine extends StatefulWidget {
  const NumberLine(
      {Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<NumberLine> createState() => _NumberLineState();
}

class _NumberLineState extends State<NumberLine> {
  int index = 0;
  late List<Map> list;
  int audioOffset = 0;
  int audioWidth = 2;
  late Timer timer;
  late List colors;
  List response = [];
  bool answered = false;
  bool done = false;
  late List input;
  int active = 0;
  double unit = 50;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    list = [
      /* [5, 5],
      [7, 3],
      [6, 4],
      [10, 2],
      [4, 6]*/
    ];
    /*
    try {
      list = utils.inputStrToArr(widget.data['steps'][0]);
    } catch (e) {
      list = ['Dummy Text'];
      print('Slides2 Error! $e');
    }
    */
    var random = new Math.Random();
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
    colors = [...allColors];
    String str = widget.data['pattern'];
    int counter = 0;
    num range = 10;

    while (list.length < 10) {
      counter++;
      if (str.indexOf('misc') != 0) {
        List arr = str.split('~');
        num a = utils.getFormatedRandom(arr[1]);
        num b = utils.getFormatedRandom(arr[2]);
        num? c;
        String symbol = '×';
        range = a * b + 4;

        if (str.indexOf('div') == 0) {
          c = a;
          a = a * b;
          symbol = '÷';
          c = a / b;
        } else {
          c = a * b;
        }

        Map? exists =
            list.firstWhere((item) => item['a'] == a && item['b'] == b);
        if (exists != null && counter < 1000) {
          continue;
        }
        list.add({
          'display': [a, symbol, b, '=', c],
          'range': range
        });
      } else {
        String exp = str.split('~')[1];
        exp = exp.split('+').join(',+,');
        exp = exp.split('-').join(',−,');
        List<dynamic> arr = exp.split(',');
        num ans = 0;
        List points = [0];
        for (int i = 0; i < arr.length; i = i + 2) {
          print('arr[i] = ${arr[i]}');
          arr[i] = utils.getFormatedRandom(arr[i]).toString();
          if (i != 0) {
            if (arr[i - 1] == '+') {
              ans = ans + num.parse(arr[i]);
            } else {
              ans = ans - num.parse(arr[i]);
            }
          } else {
            ans = num.parse(arr[i]);
          }
          points.add(ans);
          range = Math.max(range, ans + 4);
        }
        arr = arr
            .map(
                (item) => (item != '+' && item != '−') ? num.parse(item) : item)
            .toList();
        list.add({
          'display': [...arr, '=', ans],
          'range': range,
          'points': points
        });
      }
    }
    unit = Math.max(20, 1000 / list[index]['range']);
    unit = Math.min(unit, 50);
    print('input list: $list');
    input = List.filled(((list[0]['display'].length + 1) / 2).round(), null,
        growable: false);
    colors.sort((a, b) => random.nextDouble() > 0.5 ? -1 : 1);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('addPostFrameCallback ${widget.data['hasNegative'] == true}');
      _scrollController.animateTo(
          widget.data['hasNegative'] == true
              ? unit * 10
              : 0, //_scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease);
    });
  }

  void setActiveBox(pos) {
    setState(() {
      active = pos;
    });
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
                    '${i + 1}. ${response[i]['display'].join(' ')}',
                    style: TextStyle(
                        color:
                            response[i]['right'] ? Colors.green : Colors.red),
                  ))
          ]));
    }
    double graphWidth = Math.max(unit * list[index]['range'], 1300);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
          "Find the Problem that represents the below image. (We have to start from zero)"),
      Center(
          child: Container(
              decoration: BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: CustomPaint(
                      size: Size(graphWidth, 240),
                      painter: Painter(
                          data: list[index],
                          colors: colors,
                          type: widget.data['pattern'].split('~')[0],
                          hasNegative: widget.data['hasNegative'] ?? false,
                          unit: unit))))),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < list[index]['display'].length; i++)
            i % 2 == 0
                ? _inputBox(
                    input,
                    answered
                        ? list[index]['display'][i] ==
                                int.parse(input[(i / 2).round()])
                            ? true
                            : false
                        : null,
                    setActiveBox,
                    (i / 2).round(),
                    active)
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(list[index]['display'][i],
                        style: const TextStyle(
                          fontSize: 20,
                        ))),
        ],
      ),
      NumInput(onInput: (no) {
        if (answered) {
          return;
        }
        setState(() {
          if (no == 'x') {
            if (input[active].length > 0) {
              input[active] =
                  input[active].substring(0, input[active].length - 1);
            }
          } else {
            if (input[active] == null) {
              input[active] = no;
            } else {
              if (input[active].length < 3) {
                input[active] = input[active] + no;
              }
            }
          }
        });
      }),
      Footer(
        onNext: () {
          if (index >= list.length - 1) {
            setState(() {
              done = true;
              widget.activityCallback(
                  {'type': 'resultView', 'response': response});
            });
          } else {
            _scrollController.animateTo(
                widget.data['hasNegative'] == true
                    ? unit * 10
                    : 0, //_scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);

            setState(() {
              index++;
              active = 0;
              answered = false;
              input = List.filled(
                  ((list[0]['display'].length + 1) / 2).round(), null,
                  growable: false);
            });
          }
        },
        response: response,
        showNext: answered,
        children: answered
            ? const SizedBox.shrink()
            : ElevatedButton(
                onPressed: () {
                  bool right = true;
                  int ans = int.parse(input[active]);
                  for (int i = 0;
                      i < list[index]['display'].length;
                      i = i + 2) {
                    num val = num.parse(input[(i / 2).round()]);
                    if (val != list[index]['display'][i]) {
                      right = false;
                      break;
                    }
                  }
                  setState(() {
                    answered = true;
                    response = [
                      ...response,
                      {
                        'right': right,
                        'display': list[index]['display'],
                        'ans': input.map((e) => int.parse(e))
                      }
                    ];
                  });
                  widget.activityCallback({
                    'type': 'progress',
                    'progress': ((index + 1) / list.length * 100).ceil()
                  });
                },
                child: Text('Submit')),
      )
    ]);
  }
}

class Painter extends CustomPainter {
  Painter(
      {required this.data,
      required this.colors,
      required this.type,
      required this.hasNegative,
      required this.unit});
  Map data;
  List colors;
  String type;
  double unit;
  bool hasNegative;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Path path = Path();
    Offset off = Offset(hasNegative ? 10 + unit * 10 : 10, 200);
    path.moveTo(off.dx, off.dy);
    path.lineTo(data['range'] * unit + 1000, off.dy);
    path.moveTo(off.dx, 10);
    path.lineTo(off.dx, off.dy);
    for (int i = 0; i <= data['range']; i++) {
      path.moveTo(off.dx + i * unit, off.dy - 5);
      path.lineTo(off.dx + i * unit, off.dy + 5);
    }
    for (int j = 0; j <= data['range']; j++) {
      if (unit < 30 && j % 2 == 0) {
        continue;
      }
      final TextPainter textPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: '${j}',
              style: TextStyle(fontSize: 14, color: Colors.black)),
          maxLines: 1,
          textDirection: TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
      textPainter.paint(canvas,
          Offset(off.dx + j * unit - textPainter.width / 2, off.dy + 5));
    }

    if (hasNegative) {
      path.moveTo(off.dx, off.dy);
      path.lineTo(10, off.dy);
      for (int i = 0; i < 10; i++) {
        path.moveTo(off.dx - i * unit, off.dy - 5);
        path.lineTo(off.dx - i * unit, off.dy + 5);
      }
      for (int j = 0; j <= 10; j++) {
        if (unit < 30 && j % 2 == 0) {
          continue;
        }
        final TextPainter textPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: '${j * -1}',
                style: TextStyle(fontSize: 14, color: Colors.black)),
            maxLines: 1,
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
        textPainter.paint(canvas,
            Offset(off.dx - j * unit - textPainter.width / 2, off.dy + 5));
      }
    }
    if (type == 'misc') {
      for (int i = 0; i < data['points'].length - 1; i++) {
        drawPath(path, data['points'][i], data['points'][i + 1], off, unit);
      }
    } else {
      num a = data['display'][0];
      num b = data['display'][2];
      num c = data['display'][4];
      if (type == 'mul') {
        for (int i = 0; i < b; i++) {
          drawPath(path, i * a, (i + 1) * a, off, unit);
        }
      } else {
        drawPath(path, 0, a, off, unit);
        for (num i = c; i > 0; i--) {
          drawPath(path, i * b, (i - 1) * b, off, unit);
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

void drawPath(path, start, end, off, unit) {
  double amp = end > start ? 100 : 70;
  path.moveTo(off.dx + start * unit, off.dy);
  path.cubicTo(off.dx + start * unit, off.dy - amp, off.dx + end * unit,
      off.dy - amp, off.dx + end * unit, off.dy);
  double mid = off.dx + (start + (end - start) / 2) * unit;
  double hei = amp * 0.75;
  if (end > start) {
    path.moveTo(mid - 5, off.dy - hei - 5);
    path.lineTo(mid, off.dy - hei);
    path.lineTo(mid - 5, off.dy - hei + 7);
  } else {
    path.moveTo(mid + 5, off.dy - hei - 5);
    path.lineTo(mid, off.dy - hei);
    path.lineTo(mid + 5, off.dy - hei + 7);
  }
}
