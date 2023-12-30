import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'comps/keyboard.dart';
import '../utils/dataUtils.dart' as utils;

class Dictation extends StatefulWidget {
  const Dictation(
      {Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Dictation> createState() => _DictationState();
}

class _DictationState extends State<Dictation> with TickerProviderStateMixin {
  int index = 0;
  String typeInProg = '';
  bool done = false;
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
    print('Dictation = ${widget.data}');
    response = widget.data['saved'] ?? [];
    done = response.isNotEmpty;
    index = widget.data['saved'] != null ? widget.data['saved'].length : 0;
    audioOffset = widget.data['audioOffset'] ?? 0;
    audioWidth = widget.data['audioWidth'] ?? 2;
    list = utils.inputStrToArr(widget.data['text'] ?? widget.data['words']);
    print('list = $list');
    if (widget.data['audio'] != null) {
      player = AudioPlayer();
      String audio = widget.data['audio']; //.replaceAll('.mp3', '.aac');
      player.setAsset('assets/sound/${audio}');
      playaudio();
    }
    super.initState();
  }

  void playaudio() async {
    if (done) {
      return;
    }
    if (player.processingState != ProcessingState.idle &&
        player.processingState != ProcessingState.completed) {
      //return;
    }
    int offset = audioOffset + audioWidth * index;
    try {
      await player.setClip(
          start: Duration(seconds: offset), // + ),
          end: Duration(seconds: offset + audioWidth));
      await player.play();
    } catch (e) {
      print("Error : setClip : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build = ${widget.data}');

    if (done) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('You have completed this activity.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25)),
        for (int i = 0; i < response.length; i++)
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              Text(
                '${i + 1}. ${response[i]['ans']} ',
                style: TextStyle(
                    color: response[i]['right'] ? Colors.green : Colors.red),
              ),
              if (response[i]['right'] == false)
                Text(
                  '( ${list[i]})',
                  style: TextStyle(color: Colors.green),
                )
            ]),
          ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                decoration: BoxDecoration(color: Colors.white),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      ]);
    }

    return Stack(children: [
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
        Container(
          height: 100,
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              child: Text(typeInProg,
                  style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
            ),
            if (answered == true &&
                response[response.length - 1]['right'] == false)
              SizedBox(
                width: double.infinity,
                child: Text(list[index].toUpperCase(),
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center),
              ),
          ]),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                decoration: BoxDecoration(color: Colors.white),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text(
                    'Score : ${response.where((item) => item['right'] == true).length} / ${response.length}',
                    style: TextStyle(fontSize: 16))),
            if (answered == true)
              ElevatedButton(
                  onPressed: () {
                    print("Next Pressed");
                    setState(() {
                      answered = false;
                      index = index + 1;
                      typeInProg = '';
                      if (index >= list.length) {
                        done = true;
                      }
                      playaudio();
                    });
                  },
                  child: Text('Next'))
          ],
        ),
        Keyboard(
            lang: widget.data['lang'] ?? 'en',
            onPick: (key) {
              print('key = $key');
              if (answered) {
                return;
              }
              String cur = typeInProg;
              if (key == 'Space') {
                cur += ' ';
              } else if (key == "DEL") {
                if (cur.length > 0) {
                  cur = cur.substring(0, cur.length - 1);
                }
              } else if (key == 'Done') {
                if (cur.length != 0) {
                  setState(() {
                    String ans = cur.split(' ').join('').toLowerCase();
                    bool right = ans == list[index].toLowerCase();
                    response = [
                      ...response,
                      {'ans': ans, 'right': right}
                    ];
                    answered = true;
                  });
                }
                return;
              } else {
                cur += key;
              }
              setState(() {
                typeInProg = cur;
              });
            })
      ]),
      if (answered)
        response[response.length - 1]['right'] == true
            ? (new Positioned(
                right: 50,
                top: 75,
                child: const Icon(Icons.check_rounded,
                    size: 60, color: Colors.green)))
            : (new Positioned(
                right: 50,
                top: 75,
                child: const Icon(Icons.close_rounded,
                    size: 60, color: Colors.red)))
    ]);
  }
}
