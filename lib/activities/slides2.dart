import 'dart:math' as Math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/dataUtils.dart' as utils;

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
      list = utils.inputStrToArr(widget.data['steps'][0]);
    } catch (e) {
      list = ['Dummy Text'];
      print('Slides2 Error! $e');
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
    player.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    ]);
  }
}
/*
double delayedProgress(double animationValue, int i) =>
      ((animationValue * completedExercises.length.toDouble()) -
              (i / completedExercises.length))
          .clamp(0, 1)
          .toDouble();*/