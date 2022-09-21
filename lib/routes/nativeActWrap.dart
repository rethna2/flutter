import 'package:flutter/material.dart';

import '../activities/slides.dart';
import '../activities/rightOne.dart';
import '../activities/tracing/tracing.dart';
import '../activities/slides2.dart';
import '../activities/math/placeValueAbacus.dart';
import '../activities/math/numberLine.dart';

Widget getActivity(Map data, Size size, Function activityCallback) {
  switch (data['type']) {
    case 'slides':
      return Slides(data: data['data'], activityCallback: activityCallback);
    case 'slides2':
      return Slides2(data: data['data'], activityCallback: activityCallback);
    case 'rightOne':
      return RightOne(data: data['data'], activityCallback: activityCallback);
    case 'placeValueAbacus':
      return PlaceValueAbacus(
          data: data['data'], activityCallback: activityCallback);
    case 'numberLine':
      print('nativeActWrap: ${data['data']}');
      return NumberLine(data: data['data'], activityCallback: activityCallback);
    case 'tracing':
    default:
      return Tracing(
          data: data['data'], size: size, activityCallback: activityCallback);
  }
}
