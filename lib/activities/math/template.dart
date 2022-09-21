import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/dataUtils.dart' as utils;

class Slides2 extends StatefulWidget {
  const Slides2({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Slides2> createState() => _Slides2State();
}

class _Slides2State extends State<Slides2> {
  int index = 0;
  late List list;
  int audioOffset = 0;
  int audioWidth = 2;
  late Timer timer;
  @override
  void initState() {
    try {
      list = utils.inputStrToArr(widget.data['steps'][0]);
    } catch (e) {
      list = ['Dummy Text'];
      print('Slides2 Error! $e');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int i = 0; i < list.length; i++)
        GestureDetector(
            onTap: () {},
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(list[i],
                    style: TextStyle(
                        color: index == i ? Colors.red : Colors.black))))
    ]);
  }
}
