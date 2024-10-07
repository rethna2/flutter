import 'package:flutter/material.dart';
import 'dart:math';
import '../../../utils/svgUtils.dart';
import 'dart:ui';

class Tutor extends StatefulWidget {
  const Tutor(
      {Key? key,
      required this.pathList,
      required this.data,
      required this.size,
      required this.width,
      this.yGuides,
      required this.scale})
      : super(key: key);
  final List<List> pathList;
  final Map data;
  final num scale;
  final Size size;
  final List? yGuides;
  final int width;
  @override
  State<Tutor> createState() => _TutorState();
}

class _TutorState extends State<Tutor> with TickerProviderStateMixin {
  int step = 0;
  late Animation<double> animation;
  late AnimationController controller;
  late List<List> pathList;
  @override
  void initState() {
    super.initState();
    pathList = widget.pathList;
    controller = AnimationController(
        duration: Duration(
            milliseconds: 400), // max(400, widget.data['lengths'][step] * 5)),
        vsync: this);
    // #docregion addListener
    animation = Tween<double>(begin: 0, end: widget.data['lengths'][step])
        .animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
    // #enddocregion addListener
    controller.addStatusListener((status) {
      print('completeState = $step');

      if (status == AnimationStatus.completed) {
        int nextStep = step + 1;
        if (nextStep >= pathList.length) {
          nextStep = 0;
          Future.delayed(Duration(milliseconds: 4000), () {
            if (mounted) {
              setAnimation(nextStep);
            }
          });
        } else {
          setAnimation(nextStep);
        }
      }
    });
    controller.forward(from: 0);
  }

  void setAnimation(nextStep) {
    controller.duration = Duration(
        milliseconds: max(400, widget.data['lengths'][nextStep].toInt() * 5));
    animation = Tween<double>(begin: 0, end: widget.data['lengths'][nextStep])
        .animate(controller);
    setState(() {
      step = nextStep;
    });
    controller.forward(from: 0);
  }

  @protected
  @mustCallSuper
  void didUpdateWidget(old) {
    setState(() {
      pathList = widget.pathList;
      step = 0;
    });
    super.didUpdateWidget(old);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      new Center(
          child: CustomPaint(
        //size: const Size(double.infinity, double.infinity),
        //size: Size(widget.size.width, widget.size.height - 160),
        size: Size(widget.width.toDouble() + 30, widget.size.height - 160),
        // The width offset was added to avoid going out.
        painter: TutorPainter(
          pathList: [...pathList],
          step: step,
          yGuides: (widget.yGuides ?? [])
              .map((no) => no * widget.scale as double)
              .toList(),
          animValue: animation.value,
        ),
      )),
    ]);
  }
}

class TutorPainter extends CustomPainter {
  TutorPainter({
    required this.pathList,
    required this.step,
    required this.yGuides,
    required this.animValue,
  });
  List<List> pathList;
  int step;
  List yGuides;
  double animValue;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8.0;
    Path path = new Path();
    Path path2 = new Path();
    Path supportLine = new Path();

    for (int i = 0; i < yGuides.length; i++) {
      supportLine.moveTo(-400, yGuides[i]);
      supportLine.lineTo(800, yGuides[i]);
    }
    canvas.drawPath(supportLine, _getPaint(Colors.blue, false, 1.0));
    try {
      for (int i = 0; i < pathList.length; i++) {
        // paintSvgData(path, pathList[i]);

        if (i == step) {
          paintSvgData(path2, pathList[i]);
        } else if (i < step) {
          paintSvgData(path, pathList[i]);
        }
      }
    } catch (e) {
      print('Error : $e');
    }

    //canvas.clipRect(Rect.fromLTWH(0, 0, 400, 400));
    canvas.drawPath(path, paint);
    List<PathMetric> pm = path2.computeMetrics().toList();
    double current = animValue;
    Tangent? tangent = pm[0].getTangentForOffset(current);
    //drawArrow(canvas, tangent);
    canvas.drawPath(pm[0].extractPath(0, current), paint);
    if (tangent != null) {
      /*
      Offset? off = tangent?.position;
      Paint paint3 = new Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill
        ..strokeWidth = 8.0;

      Path path3 = new Path();
      path3.addOval(
          Rect.fromLTWH((off?.dx ?? 0) - 10, (off?.dy ?? 20) - 10, 20, 20));
      canvas.drawPath(path3, paint3);
      */
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

void drawArrow(canvas, tangent) {
  Paint paint4 = new Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8.0;
  Path path4 = new Path();
  Offset? pos = tangent?.position;
  Offset? vector = tangent?.vector;
  if (pos != null && vector != null) {
    path4.moveTo(pos.dx, pos.dy);
    path4.lineTo(pos.dx + vector.dx * 40, pos.dy + vector.dy * 40);
  }
  canvas.drawPath(path4, paint4);
}

Paint _getPaint(color, [isFill, strokeWidth]) {
  return Paint()
    ..color = color
    ..style = isFill == true ? PaintingStyle.fill : PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = strokeWidth ?? 8.0;
}
