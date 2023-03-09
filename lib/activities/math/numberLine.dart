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
        child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 50),
            child: Container(
                padding: const EdgeInsets.all(5),
                // width: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: isCorrect == null
                        ? (active == pos ? Color(0xffbcdbf7) : Colors.white)
                        : (isCorrect ? Colors.green : Colors.red)),
                child: Text(input[pos],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ))))),
  ]);
}

class NumberLine extends StatefulWidget {
  const NumberLine(
      {Key? key,
      required this.data,
      required this.size,
      required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  final Size size;
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
    super.initState();
    //double screenWidth = MediaQuery.of(context).size.width;
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
    String? str = widget.data['pattern'];
    int counter = 0;
    num range = 10;
    List probs = [];
    if (str != null) {
      while (list.length < 3) {
        counter++;
        if (str.indexOf('misc') != 0) {
          List<dynamic> arr = str.split('~');
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

          list.add({
            'display': [a, symbol, b, '=', c],
            'range': range.toDouble(),
            'unit': widget.data['unit'] ?? 50.0,
            'start': 0,
          });
        } else {
          String exp = str.split('~')[1];
          exp = exp.split('+').join(',+,');
          exp = exp.split('-').join(',−,');
          List<dynamic> arr = exp.split(',');
          double ans = 0;
          List points = widget.data['from'] == null ? [] : [];
          for (int i = 0; i < arr.length; i = i + 2) {
            arr[i] = utils.getFormatedRandom(arr[i]).toString();
          }
          list.add(getDisplayPoints(arr));
        }
      }
    } else {
      List probs =
          widget.data['text'].split('\n').map((e) => e.trim()).toList();
      for (int i = 0; i < probs.length; i++) {
        String str = probs[i];
        str = str.split('+').join(',+,');
        str = str.split('-').join(',−,');
        List<dynamic> arr = str.split(',').toList();
        list.add(getDisplayPoints(arr));
      }
    }
    input = List.filled(((list[0]['display'].length + 1) / 2).round(), '',
        growable: false);
    colors.sort((a, b) => random.nextDouble() > 0.5 ? -1 : 1);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
    //getScale();
  }

  Map getDisplayPoints(a) {
    List<dynamic> arr = [...a];
    if (arr[0] == '') {
      arr = arr.sublist(2);
      arr[0] = '-${arr[0]}';
    }
    List points = [];
    double ans = 0;
    for (int i = 0; i < arr.length; i = i + 2) {
      arr[i] = arr[i].runtimeType == String ? double.parse(arr[i]) : arr[i];
      if (i != 0) {
        switch (arr[i - 1]) {
          case '+':
            ans = ans + arr[i];
            break;
          case '−':
            ans = ans - arr[i];
            break;
        }
      } else {
        ans = arr[i];
      }

      ans = (ans * 1000).round() / 1000;
      points.add(ans);
    }
    return {
      'points': points,
      'display': [...arr, '=', ans],
      ...getScale(points)
    };
  }

  Map getScale(points) {
    // List points = list[index]['points'];
    double min = points[0].toDouble();
    double max = points[0].toDouble();
    for (int i = 0; i < points.length; i++) {
      if (points[i] < min) {
        min = points[i].toDouble();
      }
      if (points[i] > max) {
        max = points[i].toDouble();
      }
    }
    double range = (max - min);
    double start = (min - range * 0.2).floor() * 1;

    double unit = widget.data['unit']?.toDouble() ?? Math.min(1300 / range, 50);
    double width = range * unit;
    return {
      'start': widget.data['start'] ??
          (widget.data['decimal'] == true ? start : start.toInt()),
      'unit': unit,
      'range': range
    };

    /*
    Offset off = const Offset(10, 200);
    path.moveTo(off.dx, off.dy);
    path.lineTo(width + off.dx, off.dy);
    */
    // end
  }

  void setActiveBox(pos) {
    setState(() {
      active = pos;
    });
  }

  void handleSubmit() {
    bool right = true;
    try {
      for (int i = 0; i < list[index]['display'].length; i = i + 2) {
        double val = double.parse(input[(i / 2).round()]);
        dynamic ansVal = list[index]['display'][i];
        if (list[index]['display'][i].runtimeType == String) {
          ansVal = double.parse(list[index]['display'][i]);
        }
        if (val != ansVal) {
          right = false;
          break;
        }
      }
    } catch (e) {
      print("Error!! : $e");
    }

    setState(() {
      answered = true;
      response = [
        ...response,
        {
          'right': right,
          'display': list[index]['display'],
          'ans': input.map((e) => double.parse(e))
        }
      ];
    });
    widget.activityCallback({
      'type': 'progress',
      'progress': ((index + 1) / list.length * 100).ceil()
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
      const Text("Find the Problem that represents the below image."),
      RichText(
          text:
              TextSpan(style: const TextStyle(color: Colors.black), children: [
        TextSpan(text: '('),
        TextSpan(
          text: 'o',
          style: new TextStyle(color: Colors.red),
        ),
        TextSpan(text: ' - starting point)')
      ])),
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
                          data: {...widget.data, ...list[index]},
                          colors: colors,
                          type: widget.data['pattern']?.split('~')[0] ?? 'misc',
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
                                double.parse(input[(i / 2).round()])
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
              if (input[active].length < 5) {
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
                0, //_scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);

            setState(() {
              index++;
              active = 0;
              answered = false;
              input = List.filled(
                  ((list[0]['display'].length + 1) / 2).round(), '',
                  growable: false);
            });
          }
        },
        response: response,
        showNext: answered,
        children: (answered || input.contains(''))
            ? const SizedBox.shrink()
            : ElevatedButton(
                onPressed: () {
                  handleSubmit();
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
      required this.unit});
  Map data;
  List colors;
  String type;
  dynamic unit;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Path path = Path();
    Offset off = const Offset(10, 200);
    double range = data['range'];
    unit = data['unit'] ?? 50.0;
    if (data['decimal'] == true) {
      range = Math.max(range, 2);
      range = range * 10;
    } else {
      range = Math.max(range, 15);
    }

    double factor = 1;
    if (data['decimal'] == true) {
      factor = 0.1;
    }

    Paint paint2 = Paint()
      ..color = const Color(0xff999999)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.0;
    Path path2 = Path();
    path2.moveTo(off.dx, off.dy);
    path2.lineTo(range * unit + 1000, off.dy);
    path2.moveTo(off.dx - data['start'] * unit, 10);
    path2.lineTo(off.dx - data['start'] * unit, off.dy);
    for (int i = 0; i <= range; i++) {
      path2.moveTo(off.dx + i * unit * factor, off.dy - 15);
      path2.lineTo(off.dx + i * unit * factor, off.dy);
      double xpos = off.dx + i * unit * factor;
      int minorLines = data['minorLines'] ?? 0;
      for (int j = 1; j < minorLines; j++) {
        path2.moveTo(xpos + unit / minorLines * j, off.dy - 8);
        path2.lineTo(xpos + unit / minorLines * j, off.dy);
      }
    }

    canvas.drawPath(path2, paint2);
    for (int j = 0; j <= range; j++) {
      if (unit < 30 && j % 2 == 0) {
        continue;
      }
      dynamic label = data['start'] + j * factor;
      if (data['decimal'] != true) {
        label = label.round();
      }
      final TextPainter textPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: '$label',
              style: TextStyle(fontSize: 14, color: Colors.black)),
          maxLines: 1,
          textDirection: TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
      num xpos = j * unit;
      textPainter.paint(canvas,
          Offset(off.dx + xpos * factor - textPainter.width / 2, off.dy + 5));
    }

    if (type == 'misc') {
      for (int i = 0; i < data['points'].length - 1; i++) {
        drawPath(
            path, data['points'][i], data['points'][i + 1], off, unit, data);
      }
    } else {
      num a = data['display'][0];
      num b = data['display'][2];
      num c = data['display'][4];
      if (type == 'mul') {
        for (int i = 0; i < b; i++) {
          drawPath(path, i * a, (i + 1) * a, off, unit, data);
        }
      } else {
        drawPath(path, 0, a, off, unit, data);
        for (num i = c; i > 0; i--) {
          drawPath(path, i * b, (i - 1) * b, off, unit, data);
        }
      }
    }
    canvas.drawPath(path, paint);
    //if (data['from'] != null) {
    drawStart(canvas, data['points'][0] - data['start'], off, unit);
    //}
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

void drawPath(path, start, end, off, unit, data) {
  double amp = end > start ? 100 : 70;
  double dx = off.dx; //+ data['start'] * unit;
  start = start - data['start'];
  end = end - data['start'];
  path.moveTo(dx + start * unit, off.dy);
  path.cubicTo(dx + start * unit, off.dy - amp, dx + end * unit, off.dy - amp,
      dx + end * unit, off.dy);
  double mid = dx + (start + (end - start) / 2) * unit;
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

void drawStart(canvas, start, off, unit) {
  Paint paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 4.0;
  double x = off.dx + start * unit;
  double y = off.dy;

  Path path = Path();
  path.addOval(Rect.fromLTWH(x - 5, y - 5, 10, 10));
  canvas.drawPath(path, paint);
}

  /*
void drawStartEnd(canvas, start, end, off, unit) {
  Paint paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 4.0;
  double x = off.dx + start * unit;
  double x2 = off.dx + end * unit;
  double y = off.dy;

  Path path = Path();
  path.addOval(Rect.fromLTWH(x - 5, y - 5, 10, 10));

  path.moveTo(x2 - 5, y - 5);
  path.lineTo(x2 + 5, y + 5);
  path.moveTo(x2 + 5, y - 5);
  path.lineTo(x2 - 5, y + 5);
  canvas.drawPath(path, paint);
}
*/
