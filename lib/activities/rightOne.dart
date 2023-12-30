import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/dataUtils.dart' as utils;
import '../utils/svgUtils.dart';
import '../utils/utils.dart';

class RightOne extends StatefulWidget {
  const RightOne({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<RightOne> createState() => _RightOneState();
}

Tween<Offset> _getTween(i, isDone) => Tween<Offset>(
      begin: isDone ? Offset.zero : Offset(1.5 * (i / 2 + 1), 0),
      end: isDone ? Offset(-1.5 * (2.5 - i / 2), 0) : Offset.zero,
    );

class _RightOneState extends State<RightOne> with TickerProviderStateMixin {
  int index = 0;
  bool isDone = false;
  bool answered = false;
  late List list;
  List response = [];
  late AudioPlayer player;
  int audioOffset = 0;
  int audioWidth = 2;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );

  @override
  void initState() {
    response = widget.data['saved'] ?? [];
    index = widget.data['saved'] != null ? widget.data['saved'].length : 0;
    var random = new Math.Random();
    if (widget.data['type'] == 'math') {
    } else if (['words', 'image', 'letters'].contains(widget.data['type'])) {
      audioOffset = widget.data['audioOffset'] ?? 0;
      audioWidth = widget.data['audioWidth'] ?? 2;
      list = utils.inputStrToArr(widget.data['text'] ?? widget.data['words']);
      list = list.asMap().entries.map((entry) {
        List words = [entry.value];
        while (words.length < 4) {
          String temp = list[(random.nextDouble() * list.length).floor()];
          if (words.indexOf(temp) == -1) {
            words.add(temp);
          }
        }
        List randArr = new List<int>.generate(4, (i) => i);
        randArr.sort((a, b) => random.nextDouble() > 0.5 ? 1 : -1);
        return {
          'words': words,
          'randArr': randArr,
          'audio': audioOffset + entry.key * audioWidth
        };
      }).toList();
      list.sort((a, b) => random.nextDouble() > 0.5 ? 1 : -1);
    } else {
      List arr = widget.data['text'].split('\n').map((e) => e.trim()).toList();
      final reg = RegExp(r'\s*\,\s*');
      List temp = arr
          .map((item) => item.split(reg))
          // .map((e) => ({'img': e[0].trim(), 'text': e[1].trim()})))
          .toList();
      // list = list.sublist(0, 8);

      list = temp.map((options) {
        int length = options.length;
        if (widget.data['hasHint'] == true) {
          length -= 1;
        }
        List randArr = new List<int>.generate(length, (i) => i);
        var random = new Math.Random();
        randArr.sort((a, b) => random.nextDouble() > 0.5 ? 1 : -1);
        if (widget.data['hasHint'] == true) {
          return {
            'hint': options[0],
            'words': options.sublist(1),
            'randArr': randArr,
          };
        } else {
          return {
            'words': options,
            'randArr': randArr,
          };
        }
      }).toList();
    }
    if (widget.data['audio'] != null) {
      player = AudioPlayer();
      String audio = widget.data['audio']; //.replaceAll('.mp3', '.aac');
      player.setAsset('assets/sound/${audio}');
      playaudio();
    }
    _controller.forward(from: 0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isDone) {
          setState(() {
            index = index + 1;
            isDone = false;
            answered = false;
            _controller.forward(from: 0);
            if (index < list.length) {
              if (widget.data['audio'] != null) {
                playaudio();
              }
            }
          });
        }
      }
    });
    super.initState();
  }

  void playaudio() async {
    if (player.processingState != ProcessingState.idle &&
        player.processingState != ProcessingState.completed) {
      //return;
    }
    int offset = list[index]['audio'];
    try {
      await player.setClip(
          start: Duration(seconds: offset), // + ),
          end: Duration(seconds: offset + audioWidth));
      await player.play();
    } catch (e) {
      print("Error : setClip : $e");
    }
  }

  BoxDecoration getBoxDecoration(ans) {
    bool isImage = widget.data['type'] == 'image';
    Color color =
        isImage ? Colors.white : Theme.of(context).colorScheme.tertiary;
    if (answered) {
      Map cur = response[response.length - 1];
      if (cur['ans'] == ans) {
        if (cur['right'] == true) {
          color = Colors.green.shade300;
        } else {
          color = Colors.red.shade300;
        }
      } else {
        if (ans == list[index]['words'][0]) {
          color = Colors.green.shade300;
        }
      }
    }

    return new BoxDecoration(
        color: isImage ? Colors.white : color,
        border: isImage ? Border.all(color: color, width: 7) : null,
        boxShadow: [
          new BoxShadow(
            offset: const Offset(
              2.0,
              2.0,
            ),
            color: Color.fromARGB(100, 150, 150, 150),
            blurRadius: 2.0,
            spreadRadius: 2.0,
          ),
        ]);
  }

  List<Widget> getOptions(words) {
    List ra = list[index]['randArr'];
    List words = list[index]['words'];
    bool isImage = widget.data['type'] == 'image';
    bool isSquare =
        (widget.data['type'] == 'image' || widget.data['type'] == 'letters');
    return [
      for (int i = 0; i < words.length; i++)
        SlideTransition(
            //position: _offsetAnimation,
            position: _getTween(i, isDone).animate(_controller),
            child: GestureDetector(
                onTap: () {
                  if (answered) {
                    return;
                  }
                  bool right = list[index]['randArr'][i] == 0;

                  setState(() {
                    response = [
                      ...response,
                      {'ans': words[ra[i]], 'right': right}
                    ];
                    answered = true;
                  });
                  widget.activityCallback({
                    'type': 'progress',
                    'progress': ((index + 1) / list.length * 100).ceil()
                  });
                },
                child: Container(
                    width: isSquare ? 130 : 280,
                    height: isSquare ? 130 : null,
                    margin:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    decoration: getBoxDecoration(words[ra[i]]),
                    child: Center(
                        child: isImage == true
                            ? (widget.data['imageType'] == 'svg'
                                ? (Transform.scale(
                                    scale: 130 / 310,
                                    origin: const Offset(-65, -65),
                                    child: CustomPaint(
                                        //size: const Size(double.infinity, double.infinity),
                                        size: const Size(310, 310),
                                        painter:
                                            SVGImg(svgList: [words[ra[i]]]))))
                                : Image.asset(
                                    'assets/stockimg/${words[ra[i]]}.jpg',
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.contain))
                            : (Text(words[ra[i]],
                                style: TextStyle(
                                    fontSize: widget.data['type'] == 'letters'
                                        ? parseNum(
                                            widget.data['fontSize'] ?? '3rem')
                                        : 20)))))))
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (index >= list.length) {
      return Padding(
          padding: EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You have completed this activity.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25)),
            if (widget.data['type'] != 'image')
              for (int i = 0; i < response.length; i++)
                Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${i + 1}. ${response[i]['ans']}',
                      style: TextStyle(
                          color:
                              response[i]['right'] ? Colors.green : Colors.red),
                    )),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                        'Score : ${response.where((item) => item['right'] == true).length} / ${response.length}',
                        style: TextStyle(fontSize: 16))),
                ElevatedButton(
                    onPressed: () {
                      widget.activityCallback(
                          {'type': 'complete', 'response': response});
                    },
                    child: Text('Next'))
              ],
            )
          ]));
    }
    List words = list[index]['words'];
    String type = widget.data['type'] ?? '';
    bool isImage = type == 'image';
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.data['title'] ??
                'Pick the word that has the correct spelling.'),
            SizedBox(height: 20),
            if (widget.data['audio'] != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: playaudio,
                      child: Row(children: [
                        Text('Repeat'),
                        Icon(
                          Icons.volume_up,
                          color: Colors.black,
                          size: 20.0,
                        )
                      ])),
                ],
              ),
            if (list[index]['hint'] != null)
              Text(list[index]['hint'], style: TextStyle(fontSize: 22)),
            Container(
                width: double.infinity,
                child: (isImage || type == 'letters')
                    ? (Center(
                        child: Wrap(
                        children: getOptions(words),
                      )))
                    : (Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // width: double.infinity,
                        children: getOptions(words),
                      ))),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Text(
                        'Score : ${response.where((item) => item['right'] == true).length} / ${response.length}',
                        style: TextStyle(fontSize: 16))),
                if (answered == true)
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDone = true;
                          _controller.forward(from: 0);
                        });
                      },
                      child: Text('Next'))
              ],
            )
          ]),
          if (answered)
            response[response.length - 1]['right'] == true
                ? (new Positioned(
                    right: 0,
                    top: 100,
                    child: const Icon(Icons.check_rounded,
                        size: 60, color: Colors.green)))
                : (new Positioned(
                    right: 0,
                    top: 100,
                    child: const Icon(Icons.close_rounded,
                        size: 60, color: Colors.red)))
        ]));
  }
}
/*
double delayedProgress(double animationValue, int i) =>
      ((animationValue * completedExercises.length.toDouble()) -
              (i / completedExercises.length))
          .clamp(0, 1)
          .toDouble();*/


