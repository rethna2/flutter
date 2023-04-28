import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'comps/CoolSwiper.dart';

class Slides extends StatefulWidget {
  const Slides({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Slides> createState() => _SlidesState();
}

class _SlidesState extends State<Slides> with TickerProviderStateMixin {
  int index = 0;
  late List list;

  @override
  void initState() {
    String str = widget.data['text'];
    List arr;
    if (str.indexOf('\n') != -1) {
      arr = str.split('\n').map((e) => e.trim()).toList();
    } else {
      arr = str.split(',').map((e) => e.trim()).toList();
    }

    final reg = RegExp(r'\s*\|\s*');
    list = arr
        .map((item) => item.split(reg))
        // .map((e) => ({'img': e[0].trim(), 'text': e[1].trim()})))
        .toList();
    list = list
        .map((item) => item.length == 1 ? [item[0], item[0]] : item)
        .toList();
    // list = list.sublist(0, 8);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: CoolSwiper(
              activityCallback: widget.activityCallback,
              audio: widget.data['audio'],
              audioOffset: widget.data['audioOffset'] ?? 0,
              audioWidth: widget.data['audioWidth'] ?? 2,
              children: List.generate(
                list.length,
                (index) => CardContent(
                    color: Data.colors[index % Data.colors.length],
                    children: [
                      Image.asset('assets/stockimg/${list[index][0]}.jpg',
                          width: 160, height: 160, fit: BoxFit.contain),
                      const SizedBox(height: 40),
                      Center(
                          child: Text(list[index][1].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 25)))
                    ]),
              ),
            )),
      ),
    );
  }
}

// borrowed code - begin
