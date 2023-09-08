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
  final List<double>? yGuides;
  @override
  State<Tracer> createState() => _TracerState();
}

class _TracerState extends State<Tracer> with TickerProviderStateMixin {
  int step = 0;
  late List<List> pathList;
  late double currentx;
  late double currenty;
  double length = 0;
  bool isPanning = false;
  GlobalKey _paintKey = new GlobalKey();

  @override
  void initState() {
    print('widget.guides: ${widget.yGuides}');
    pathList = widget.pathList;
    currentx = pathList[step][0]['x'];
    currenty = pathList[step][0]['y'];
    super.initState();
  }

  @protected
  @mustCallSuper
  void didUpdateWidget(old) {
    setState(() {
      pathList = widget.pathList;
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
    Offset offset = referenceBox.globalToLocal(event.globalPosition);
    return offset;
  }

  void _onPanStart(DragStartDetails start) {
    Offset pos = getOffset(start, _paintKey);
    double diffX = currentx - pos.dx;
    double diffY = currenty - pos.dy;
    if (Math.sqrt(diffX * diffX + diffY * diffY) < 40) {
      setState(() {
        isPanning = true;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails update) {
    Offset pos = getOffset(update, _paintKey);
    double x = pos.dx - currentx;
    double y = pos.dy - currenty;
    if (isPanning == false) {
      return;
    }
    if (Math.sqrt(x * x + y * y) < 20) {
      setState(() {
        // length = length + sqrt(x * x + y * y).toInt();
        //length += 2;
        length +=
            getNextPos(length, pos, currentx, currenty, pathList[step]).ceil();
        if (length >= widget.data['lengths'][step] - 3) {
          if (step >= pathList.length - 1) {
            widget.done();
            length = 0;
          } else {
            step = step + 1;
            length = 0;
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
          child: Container(
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
                          .map((no) => no * widget.scale)
                          .toList(),
                      cb: (offset) {
                        currentx = offset.dx;
                        currenty = offset.dy;
                      }),
                ),
              ))),
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

double getNextPos(travel, p, currentx, currenty, pathData) {
  Path path = new Path();
  paintSvgData(path, pathData);
  List<PathMetric> metrics = path.computeMetrics().toList();
  const double bw = 50;
  double val = 50;
  // double tempTravel = 0;
  for (var i = bw / 2 * -1; i < bw; i = i + 3) {
    if (i == 0) {
      continue;
    }
    var fringe = travel + i;
    Tangent? tangent = metrics[0].getTangentForOffset(fringe);
    if (tangent != null) {
      Offset pos = tangent.position;
      double diffx = pos.dx - p.dx;
      double diffy = pos.dy - p.dy;
      double diff = Math.sqrt(diffx * diffx + diffy * diffy);
      if (diff < val && diff != 0) {
        //val = diff * i / i.abs();
        val = diff;
        //tempTravel = fringe;
      }
    }
  }
  if (val < bw) {
    return val;
  } else {
    return 0;
  }
}

Paint _getPaint(color, [isFill, strokeWidth]) {
  return Paint()
    ..color = color
    ..style = isFill == true ? PaintingStyle.fill : PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = strokeWidth ?? 8.0;
}
