import 'package:flutter/material.dart';

import '../activities/slides.dart';
import '../activities/dictation.dart';
import '../activities/rightOne.dart';
import '../activities/tracing/tracing.dart';
import '../activities/slides2.dart';
import '../activities/math/placeValueAbacus.dart';
import '../activities/math/numberLine.dart';
import '../activities/phonics.dart';

Widget getActivity(Map data, Size size, Function activityCallback) {
  switch (data['type']) {
    case 'slides':
      return Slides(data: data['data'], activityCallback: activityCallback);
    case 'slides2':
      return Slides2(data: data['data'], activityCallback: activityCallback);
    case 'rightOne':
      return RightOne(data: data['data'], activityCallback: activityCallback);
    case 'dictation':
      return Dictation(data: data['data'], activityCallback: activityCallback);
    case 'placeValueAbacus':
      return PlaceValueAbacus(
          data: data['data'], activityCallback: activityCallback);
    case 'numberLine':
      return NumberLine(
          data: data['data'], size: size, activityCallback: activityCallback);
    case 'phonics':
      return Phonics(data: data['data'], activityCallback: activityCallback);
    case 'tracing':
    default:
      return Tracing(
          data: data['data'], size: size, activityCallback: activityCallback);
  }
}
