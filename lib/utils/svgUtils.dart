import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as Math;

List<Map> dataToObj(str) {
  // let str = 'M 100 100 L 100 200 L 200 200 Q 100 250 200 300 L 300 300 L 300 400 L 400 400 C 400 300 450 300 450 450';
  RegExp reg = new RegExp(r"[MLCQSTHVAZmlcqsthvaz][\-?0-9.\s]*");
  List arr = [];

  for (var match in reg.allMatches(str)) {
    arr.add(str.substring(match.start, match.end));
  }

  List<Map> data = [];
  for (int i = 0; i < arr.length; i++) {
    Map obj = dataToObjUnit(arr[i]);
    if (obj['type'] != null) {
      data.add(obj);
    }
  }
  return data;
}

Map dataToObjUnit(String str) {
  str = str.trim();
  //str = str.replace(/\s+/, ' ');
  //const a = str.split(' ');
  List a = str.split(new RegExp(r"\s+"));
  switch (a[0]) {
    case 'M':
    case 'L':
    case 'T':
    case 'm':
    case 'l':
    case 't':
      return {'type': a[0], 'x': double.parse(a[1]), 'y': double.parse(a[2])};
    case 'H':
    case 'V':
    case 'h':
    case 'v':
      return {'type': a[0], 'val': double.parse(a[1])};
    case 'C':
    case 'c':
      return {
        'type': a[0],
        'ctx': double.parse(a[1]),
        'cty': double.parse(a[2]),
        'ct2x': double.parse(a[3]),
        'ct2y': double.parse(a[4]),
        'x': double.parse(a[5]),
        'y': double.parse(a[6])
      };
    case 'Q':
    case 'S':
    case 'q':
    case 's':
      return {
        'type': a[0],
        'ctx': double.parse(a[1]),
        'cty': double.parse(a[2]),
        'x': double.parse(a[3]),
        'y': double.parse(a[4])
      };
    case 'Z':
    case 'z':
      return {'type': a[0]};
    case 'A':
    case 'a':
      return {
        'type': a[0],
        'rx': double.parse(a[1]),
        'ry': double.parse(a[2]),
        'rot': double.parse(a[3]),
        'largeArc': double.parse(a[4]),
        'otherSide': double.parse(a[5]),
        'x': double.parse(a[6]),
        'y': double.parse(a[7])
      };
    default:
      return {};
  }
}

List resize(List d, ox, oy, sx, sy) {
  List list = [];
  //d = replaceHV(d);
  for (int i = 0; i < d.length; i++) {
    Map obj = {...d[i]};
    switch (obj['type'].toUpperCase()) {
      case 'M':
      case 'L':
      case 'T':
        obj['x'] = ox + (obj['x'] - ox) * sx;
        obj['y'] = oy + (obj['y'] - oy) * sy;
        break;
      case 'C':
        obj['x'] = ox + (obj['x'] - ox) * sx;
        obj['ctx'] = ox + (obj['ctx'] - ox) * sx;
        obj['ct2x'] = ox + (obj['ct2x'] - ox) * sx;
        obj['y'] = oy + (obj['y'] - oy) * sy;
        obj['cty'] = oy + (obj['cty'] - oy) * sy;
        obj['ct2y'] = oy + (obj['ct2y'] - oy) * sy;
        break;
      case 'Q':
      case 'S':
        obj['x'] = ox + (obj['x'] - ox) * sx;
        obj['ctx'] = ox + (obj['ctx'] - ox) * sx;
        obj['y'] = oy + (obj['y'] - oy) * sy;
        obj['cty'] = oy + (obj['cty'] - oy) * sy;
        break;
      case 'H':
        obj['val'] = ox + (obj['val'] - ox) * sx;
        break;
      case 'V':
        obj['val'] = oy + (obj['val'] - oy) * sy;
        break;
      default:
        break;
    }
    list.add(obj);
  }
  return list;
}

void paintSvgData(Path path, List list) {
  for (int i = 0; i < list.length; i++) {
    switch (list[i]['type']) {
      case 'M':
        {
          path.moveTo(list[i]['x'], list[i]['y']);
        }
        break;
      case 'L':
        {
          path.lineTo(list[i]['x'], list[i]['y']);
        }
        break;
      case 'C':
        {
          path.cubicTo(list[i]['ctx'], list[i]['cty'], list[i]['ct2x'],
              list[i]['ct2y'], list[i]['x'], list[i]['y']);
        }
        break;
      case 'Q':
        {
          path.quadraticBezierTo(
              list[i]['ctx'], list[i]['cty'], list[i]['x'], list[i]['y']);
        }
        break;
      default:
        break;
    }
  }
}

List getRealLengths(data, Size size) {
  List list = [];
  for (int i = 0; i < data['source'].length; i++) {
    var paths = data["source"][i]["paths"];
    num scale = getScale(data["source"][i], size);
    var pathList = [];
    for (int i = 0; i < paths.length; i++) {
      List temp = dataToObj(paths[i]);
      temp = resize(temp, 0, 0, scale, scale);
      Path path = new Path();
      paintSvgData(path, temp);

      List<PathMetric> pm = path.computeMetrics().toList();
      try {
        pathList.add(pm[0].length);
      } catch (e) {
        print('svgUtils Error : $e');
        print('paths[i] = ${paths[i]}');
      }
    }
    list.add(pathList);
  }

  return list;
}

num getScale(canvasData, Size size) {
  int lineWidth = 100;
  if (canvasData['width'] != null) {
    lineWidth = Math.max(lineWidth, canvasData['width']);
  }
  print('calculatedScale = ${(size.width - 50) / lineWidth}');
  List<num> options = [
    (size.width - 50) / lineWidth,
    2,
    (size.height - 80) / 400
  ];
  print('getScale = $options');
  return options.reduce(Math.min);
}
