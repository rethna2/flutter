import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'comps/CoolSwiper.dart';

class Phonics extends StatefulWidget {
  const Phonics({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Phonics> createState() => _PhonicsState();
}

class _PhonicsState extends State<Phonics> with TickerProviderStateMixin {
  int selectedIndex = -1;
  late List list;
  int audioOffset = 0;
  late AudioPlayer player;
  @override
  void initState() {
    String str = widget.data['text'];
    list = str.split(',').map((e) => e.trim()).toList();
    audioOffset = widget.data['audioOffset'] ?? 0;
    player = AudioPlayer();
    String audio = widget.data['audio']; //.replaceAll('.mp3', '.aac');
    player.setAsset('assets/sound/${audio}');
    super.initState();
  }

  void playaudio(int index) async {
    if (player.processingState != ProcessingState.idle &&
        player.processingState != ProcessingState.completed) {
      //return;
    }
    int offset = audioOffset + index * 2;
    try {
      await player.setClip(
          start: Duration(seconds: offset), // + ),
          end: Duration(seconds: offset + 2));
      await player.play();
    } catch (e) {
      print("Error : setClip : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(
                  widget.data['title'] ??
                      'Click on the letter and listen to the sound.',
                  textAlign: TextAlign.start),
              const SizedBox(height: 20),
              Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    list.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        playaudio(index);
                      },
                      child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 2),
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 0),
                          decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? const Color(0xff1b75b7)
                                  : Colors.white),
                          child: Center(
                              child: Text(list[index],
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: selectedIndex == index
                                          ? Colors.white
                                          : Colors.black)))),
                    ),
                  ))
            ]),
          ),
        ));
  }
}

// borrowed code - begin
