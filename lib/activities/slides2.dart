import 'dart:math' as Math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/dataUtils.dart' as utils;
import 'comps/CoolSwiper.dart';
import '../utils/utils.dart';

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
  int subIndex = 0;
  bool isDone = false;
  bool answered = false;
  late List list;
  List response = [];
  late AudioPlayer player;
  int audioOffset = 0;
  int audioWidth = 2;
  late Timer timer;
  @override
  void initState() {
    try {
      if (widget.data['steps'][0] is String) {
        list = utils.inputStrToArr(widget.data['steps'][0]);
      } else {
        list = widget.data['steps'].map((item) {
          if (item is Map) {
            return item;
          } else if (item is List) {
            List temp = item.map((unit) {
              if (unit is String) {
                return unit;
              } else if (unit['type'] == 'reusable') {
                print('yes reusable');
                return widget.data['reusables'][unit['id']].toList();
              }
              return unit;
            }).toList();
            print('success till');
            List temp2 = [];
            temp.forEach((item) => item is List
                ? item.forEach((unit) => temp2.add(unit))
                : temp2.add(item));
            //temp = temp.expand((i) => i).toList();
            // temp = temp.reduce((value, element) => value + element);
            print('but failed here');
            return temp2;
          }
        }).toList();
      }
    } catch (e) {
      list = ['Dummy Text'];
      print('Slides2 Error! $e');
    }

    if (widget.data['displayType'] == 'steps' ||
        widget.data['displayType'] == 'custom') {
      return;
    }
    player = AudioPlayer();
    player.setAsset('assets/sound/${widget.data['audio']}');
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        timer.cancel();
      }
    });
    playaudio();

    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      num inSeconds = player.position.inSeconds;
      num offset = index == 0 ? 0 : widget.data['audioOffsets'][index - 1];
      for (int i = 0; i < widget.data['audioOffsets'].length; i++) {
        if (inSeconds <= widget.data['audioOffsets'][i]) {
          if (i != index) {
            setState(() {
              index = i;
            });
          }
          return;
        }
      }
      if (offset < inSeconds) {}
    });
    if (timer.isActive) {}
    super.initState();
  }

  void playaudio() async {
    num offset = index == 0 ? 0 : widget.data['audioOffsets'][index - 1];
    try {
      await player.setClip(
          start: Duration(milliseconds: (offset * 1000).round())); // + ),
      //end: Duration(seconds: offset + audioWidth));
      await player.play();
      if (timer.isActive == false) {
        timer.tick;
      }
    } catch (e) {
      print("Error : setClip : $e");
    }
  }

  @override
  void dispose() {
    if (widget.data['displayType'] != 'steps') {
      player.dispose();
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool noImage =
        widget.data['images'] == null && widget.data['imageArr'] == null;
    if (widget.data['displayType'] == 'steps') {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: CoolSwiper(
                activityCallback: widget.activityCallback,
                audio: widget.data['audio'] ?? 'none',
                audioOffset: widget.data['audioOffset'] ?? 0,
                audioWidth: widget.data['audioWidth'] ?? 2,
                audioOffsets: widget.data['audioOffsets'],
                images: widget.data['images'],
                imageArr: widget.data['imageArr'],
                title: 'Read and swipe the cards!',
                children: List.generate(
                  list.length,
                  (index) {
                    List data;
                    if (widget.data['imageArr'] != null) {
                      data = [
                        'assets/${widget.data['images']}/${widget.data['imageArr'][index]}.jpg',
                        list[index]
                      ];
                    } else if (list[index] is Map &&
                        list[index]['img'] != null) {
                      if (widget.data['images'] == 'inline') {
                        data = [list[index]['img'], list[index]['text']];
                      } else {
                        data = [
                          'assets/${widget.data['images']}/${list[index]['img']}.jpg',
                          list[index]['text']
                        ];
                      }
                    } else {
                      data = [
                        'assets/${widget.data['images']}/${index + 1}.jpg',
                        list[index]
                      ];
                    }
                    return CardContent(
                      color: Data.colors[index % Data.colors.length],
                      children: [
                        if (!noImage)
                          Image.asset(
                              data[0].indexOf('.') == -1
                                  ? 'assets/stockimg/${data[0]}.jpg'
                                  : data[0],
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain),
                        const SizedBox(height: 40),
                        Center(
                            child: Text(data[1].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: parseNum(
                                        widget.data['fontSize'] ?? '18'))))
                      ],
                    );
                  },
                ),
              )),
        ),
      );
    }

    if (widget.data['displayType'] == 'custom') {
      print('custom = $list');
      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: 300, minWidth: double.infinity),
                        child: Container(
                            color: const Color(0xf6f6f8ff),
                            child: Column(
                                children: List<Widget>.generate(
                                    subIndex + 1,
                                    (i) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Text(
                                            list[index][i] is Map
                                                ? list[index][i]['text']
                                                : list[index][i],
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize:
                                                    (list[index][i] is Map &&
                                                            list[index][i]
                                                                    ['type'] ==
                                                                'title')
                                                        ? 30
                                                        : 18)))).toList()))),
                    Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                            onPressed: () {
                              //onNext();

                              if (list[index].length - 1 == subIndex) {
                                if (index >= list.length - 1) {
                                  widget.activityCallback({
                                    'type': 'complete',
                                    'response': response
                                  });
                                } else {
                                  setState(() {
                                    index = index + 1;
                                    subIndex = 0;
                                  });
                                }
                              } else {
                                setState(() {
                                  subIndex = subIndex + 1;
                                });
                              }
                            },
                            child: Text('Next')))
                  ]))));
    }
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int i = 0; i < list.length; i++)
        GestureDetector(
            onTap: () {
              if (index != i) {
                setState(() {
                  index = i;
                  playaudio();
                });
              }
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(list[i],
                    style: TextStyle(
                        color: index == i ? Colors.red : Colors.black))))
    ]));
  }
}
/*
double delayedProgress(double animationValue, int i) =>
      ((animationValue * completedExercises.length.toDouble()) -
              (i / completedExercises.length))
          .clamp(0, 1)
          .toDouble();*/