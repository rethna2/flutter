import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../../../utils/svgUtils.dart';
import 'dart:ui';

class Tracer extends StatefulWidget {
  const Tracer(
      {Key? key,
      this.yGuides,
      required this.pathList,
      required this.data,
      required this.scale,
      required this.width,
      required this.size,
      required this.done})
      : super(key: key);
  final List<List> pathList;
  final Function done;
  final Map data;
  final num scale;
  final Size size;
  final int width;
  final List? yGuides;
  @override
  State<Tracer> createState() => _TracerState();
}

class _TracerState extends State<Tracer> with TickerProviderStateMixin {
  int step = 0;
  late List<List> pathList;
  late Offset offset;
  double length = 0;
  bool isPanning = false;
  bool nextSwitch = false;
  bool doneLetter = false;
  GlobalKey _paintKey = new GlobalKey();

  @override
  void initState() {
    pathList = widget.pathList;
    offset = Offset(pathList[step][0]['x'], pathList[step][0]['y']);
    super.initState();
  }

  @protected
  @mustCallSuper
  void didUpdateWidget(old) {
    setState(() {
      pathList = widget.pathList;
      offset = Offset(pathList[step][0]['x'], pathList[step][0]['y']);
      step = 0;
      length = 0;
    });
    super.didUpdateWidget(old);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Offset getOffset(event, _paintKey) {
    RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
    Offset temp = referenceBox.globalToLocal(event.globalPosition);
    return temp;
  }

  void _onPanStart(DragStartDetails start) {
    Offset pos = getOffset(start, _paintKey);
    double dist = (pos - offset).distance;
    print('onPanStart $dist, $offset, $pos');
    if (dist < 40) {
      setState(() {
        isPanning = true;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails update) {
    if (isPanning == false) {
      return;
    }

    if (nextSwitch) {
      setState(() {
        length = 0;
        nextSwitch = false;
      });
      return;
    }

    Offset pos = getOffset(update, _paintKey);
    double dist = (pos - offset).distance;
    if (dist < 20) {
      setState(() {
        // length = length + sqrt(x * x + y * y).toInt();
        //length += 2;
        Map? temp = getNextPos(length, pos, offset, pathList[step]);
        if (temp == null) {
          return;
        }
        if (temp['val'] >= 0) {
          length += temp['val'];
          offset = temp['offset'];
        } else {
          return;
        }
        //print('length = ${length * widget.scale}, ${widget.data['lengths'][step]}');
        print('length = ${widget.data['lengths']}');
        if (length >= widget.data['lengths'][step] - 10) {
          if (step >= pathList.length - 1) {
            doneLetter = true;
          } else {
            step = step + 1;
            // isPanning = false;
            offset = Offset(pathList[step][0]['x'], pathList[step][0]['y']);
            length = 0;
            nextSwitch = true;
          }
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails end) {
    if (isPanning) {
      setState(() {
        isPanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
          child: Stack(children: [
        Container(
            //decoration: BoxDecoration(color: Colors.lightBlue),
            width: widget.width.toDouble() * widget.scale,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                key: _paintKey,
                // size: const Size(double.infinity, double.infinity),
                size: Size(widget.size.width, widget.size.height - 160),
                painter: TracerPainter(
                    pathList: pathList,
                    step: step,
                    length: length,
                    yGuides: (widget.yGuides ?? [])
                        .map((no) => no * widget.scale as double)
                        .toList(),
                    cb: (offset2) {}),
              ),
            )),
        if (doneLetter)
          Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.done(-1);
                          length = 0;
                          doneLetter = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff4fa7f7)),
                      child: Text('Repeat')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.done();
                          length = 0;
                          doneLetter = false;
                        });
                      },
                      child: Text('Next'))
                ],
              ))
      ])),
    ]);
  }
}

class TracerPainter extends CustomPainter {
  TracerPainter(
      {required this.pathList,
      required this.step,
      required this.length,
      required this.cb,
      this.yGuides});
  List<List> pathList;
  int step;
  double length;
  Function cb;
  List<double>? yGuides;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = _getPaint(const Color(0xffbbbbbb));
    Paint donePaint = _getPaint(Colors.black);
    Paint paintRed = _getPaint(Colors.red);

    Path path = new Path();
    Path path2 = new Path();
    Path donePath = new Path();
    Path supportLine = new Path();

    /*
    supportLine.moveTo(-400, 30);
    supportLine.lineTo(800, 30);
    supportLine.moveTo(-400, 180);
    supportLine.lineTo(800, 180);
    supportLine.moveTo(-400, 330);
    supportLine.lineTo(800, 330);
    supportLine.moveTo(-400, 480);
    supportLine.lineTo(800, 480);
    
    */
    var guides = yGuides ?? [];
    for (int i = 0; i < guides.length; i++) {
      supportLine.moveTo(-400, guides[i]);
      supportLine.lineTo(800, guides[i]);
    }

    canvas.drawPath(supportLine, _getPaint(Colors.blue, false, 1.0));

    for (int i = 0; i < pathList.length; i++) {
      if (i == step) {
        paintSvgData(path2, pathList[i]);
      } else if (i < step) {
        paintSvgData(donePath, pathList[i]);
      } else {
        paintSvgData(path, pathList[i]);
      }
    }
    //  canvas.clipRect(Rect.fromLTWH(0, 0, 400, 400));
    canvas.drawPath(donePath, donePaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paintRed);
    cb(paintCursor(canvas, path2, length));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Offset? paintCursor(canvas, path, length) {
  List<PathMetric> pm = path.computeMetrics().toList();
  Tangent? tangent = pm[0].getTangentForOffset(length);
  Offset? off = tangent?.position;
  Paint cursorPaint = _getPaint(Colors.orange, true);
  Paint paintBlack = _getPaint(Colors.black);
  var cursorPath = new Path();
  canvas.drawPath(pm[0].extractPath(0, length), paintBlack);
  cursorPath.addOval(
      Rect.fromLTWH((off?.dx ?? 0) - 15, (off?.dy ?? 20) - 15, 30, 30));
  canvas.drawPath(cursorPath, cursorPaint);
  return off;
}

Map? getNextPos(travel, p, prevPt, pathData) {
  Path path = new Path();
  paintSvgData(path, pathData);
  List<PathMetric> metrics = path.computeMetrics().toList();
  const double bw = 30;
  double val = 30;
  // double tempTravel = 0;
  Offset? pos;
  List dists = [];
  List dists2 = [];
  for (var i = -15; i <= bw - 15; i = i + 2) {
    if (i == 0) {
      //continue;
    }
    var fringe = travel + i;
    if (fringe < 0) {
      continue;
    }
    Tangent? tangent = metrics[0].getTangentForOffset(fringe);

    if (tangent != null) {
      pos = tangent.position;
      double distance = (pos - p).distance;
      dists.add(pos);
      dists2.add(distance);
      if (distance < val) {
        //val = diff * i / i.abs();
        val = distance;
        //tempTravel = fringe;
      }
    }
  }
  if (pos != null) {
    double m1 = Math.atan2(p.dy - prevPt.dy, p.dx - prevPt.dx);
    double m2 = Math.atan2(pos.dy - prevPt.dy, pos.dx - prevPt.dx);
    double dist1 = (p - prevPt).distance;
    double dist2 = (pos - prevPt).distance;
    double diff = (m1 - m2).abs();
    print('m1 = $m1, $m2, $diff');

    if (diff > 3 && diff < 5) return null;
  }
  return {'val': val, 'offset': pos};
/*
  if (val < bw) {
    return val;
  } else {
    return 0;
  }*/
}

Paint _getPaint(color, [isFill, strokeWidth]) {
  return Paint()
    ..color = color
    ..style = isFill == true ? PaintingStyle.fill : PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = strokeWidth ?? 8.0;
}
