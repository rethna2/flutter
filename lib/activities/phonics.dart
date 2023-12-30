import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:grapheme_splitter/grapheme_splitter.dart';

String taUnits = """அ , ஆ , இ , ஈ , உ , ஊ , எ , ஏ , ஐ , ஒ , ஓ , ஔ
க், ங், ச், ஞ், ட், ண், த், ந், ப், ம், ய், ர், ல், வ், ழ், ள், ற், ன்
க, கா, கி, கீ, கு, கூ, கெ, கே, கை, கொ, கோ, கௌ
ச, சா, சி, சீ, சு, சூ, செ, சே, சை, சொ, சோ, சௌ
ட, டா, டி, டீ, டு, டூ, டெ, டே, டை, டொ, டோ, டௌ
ண, ணா, ணி, ணீ, ணு, ணூ, ணெ, ணே, ணை, ணொ, ணோ, ணௌ
த, தா, தி, தீ, து, தூ, தெ, தே, தை, தொ, தோ, தௌ
ந, நா, நி, நீ, நு, நூ, நெ, நே, நை, நொ, நோ, நௌ
ப, பா, பி, பீ, பு, பூ, பெ, பே, பை, பொ, போ, பௌ
ம, மா, மி, மீ, மு, மூ, மெ, மே, மை, மொ, மோ, மௌ
ய, யா, யி, யீ, யு, யூ, யெ, யே, யை, யொ, யோ, யௌ
ர, ரா, ரி, ரீ, ரு, ரூ, ரெ, ரே, ரை, ரொ, ரோ, ரௌ
ல, லா, லி, லீ, லு, லூ, லெ, லே, லை, லொ, லோ, லௌ
வ, வா, வி, வீ, வு, வூ, வெ, வே, வை, வொ, வோ, வௌ
ழ, ழா, ழி, ழீ, ழு, ழூ, ழெ, ழே, ழை, ழொ, ழோ, ழௌ
ள, ளா, ளி, ளீ, ளு, ளூ, ளெ, ளே, ளை, ளொ, ளோ, ளௌ
ற, றா, றி, றீ, று, றூ, றெ, றே, றை, றொ, றோ, றௌ
ன, னா, னி, னீ, னு, னூ, னெ, னே, னை, னொ, னோ, னௌ""";

String enUnits = """s, a, t, i, p, n, c, e
h, r, m, d, g, o, u, l, f
b, ai, j, oa, ie, ee, or
z, w, ng, v, oo, OO, y, x
ch, sh, th, TH, qu, ou, oi, ue
er, ar, ay, oy, aw, ow, ur, ir""";

class Phonics extends StatefulWidget {
  const Phonics({Key? key, required this.data, required this.activityCallback})
      : super(key: key);
  final Map data;
  final Function activityCallback;
  @override
  State<Phonics> createState() => _PhonicsState();
}

class _PhonicsState extends State<Phonics> with TickerProviderStateMixin {
  int selectedIndex = 0;
  bool playing = false;
  late List list;
  late List unitsPos;
  late List units;
  late int totalCount;
  int audioOffset = 0;
  int audioWidth = 2;
  List wordToChars = [];
  int substep = 0;
  late AudioPlayer player;
  late AudioPlayer player2;
  late List words;
  @override
  void initState() {
    String str = widget.data['text'];
    String temp = '';
    String mainAudio = '';
    if (widget.data['lang'] == 'ta') {
      temp = taUnits;
      mainAudio = 'ta/ta-all-letters.aac';
    } else {
      temp = enUnits;
      if (widget.data['audio'] != null) {
        temp = widget.data['text'];
      } else {
        temp = enUnits;
        mainAudio = 'kg-5/phonics.mp3';
      }
    }
    units = temp.split('\n').join(',').split(',').map((e) => e.trim()).toList();
    if (widget.data['type'] == 'words') {
      list = str.split(',').map((unit) => unit.trim()).toList();
      player2 = AudioPlayer();
      player2.setAsset('assets/sound/${mainAudio}');
    } else {
      audioWidth = 1;
      if (widget.data['text'] != null) {
        list = widget.data['text']
            .split('\n')
            .map((line) => line.split(',').map((u) => u.trim()).toList())
            .toList();
      } else {
        list = [units];
      }
    }
    if (list[0].runtimeType == String) {
      list = [list];
    }
    totalCount = list
        .map((row) => row.length)
        .reduce((value, element) => value + element);
    audioOffset = widget.data['audioOffset'] ?? 0;
    audioWidth = widget.data['audioWidth'] ?? 2;

    player = AudioPlayer();
    String audio = widget.data['audio'] ??
        widget.data['wordsAudio']; //.replaceAll('.mp3', '.aac');
    player.setAsset('assets/sound/${audio}');
    super.initState();
    playaudio(0);
  }

  void playaudio(int index) async {
    if (playing) {
      return;
    }
    if (player.processingState != ProcessingState.idle &&
        player.processingState != ProcessingState.completed) {
      //return;
    }
    List chars = [];
    if (widget.data['type'] == 'words') {
      GraphemeSplitter splitter = GraphemeSplitter();
      chars = splitter
          .splitGraphemes(list[0][index])
          .toList()
          .where((char) => char.trim() != '')
          .toList();
    }
    setState(() {
      selectedIndex = index;
      playing = true;
      wordToChars = chars;
      substep = 0;
    });
    try {
      if (widget.data['type'] == 'words') {
        List pos = chars.map((char) => units.indexOf(char)).toList();
        for (int i = 0; i < pos.length; i++) {
          await player2.seek(Duration(milliseconds: pos[i] * 1000));
          player2.play();
          await Future.delayed(Duration(milliseconds: 900));
          player2.pause();
          if (i != pos.length - 1) {
            setState(() {
              substep = i + 1;
            });
          }

          /*
          await player2.setClip(
              start: Duration(milliseconds: (pos[i] * 1000).round()), // + ),
              end: Duration(milliseconds: (pos[i] * 1000 + 900).round()));
         await player2.play();
          await Future.delayed(Duration(seconds: 1));
          */
        }
      }
      int offset = audioOffset + index * audioWidth;
      await player.setClip(
          start: Duration(seconds: offset), // + ),
          end: Duration(seconds: offset + audioWidth));
      await player.play();
    } catch (e) {
      print("Error : setClip : $e");
      await player.pause();
      await player2.pause();
    }
    setState(() {
      playing = false;
    });
  }

  @override
  void dispose() {
    player.dispose();

    if (widget.data['type'] == 'words') {
      player2.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int counter = 0;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(
                  widget.data['title'] ??
                      'Click on the ${widget.data['type'] == 'words' ? 'word' : 'letter'} and listen to the sound.',
                  textAlign: TextAlign.start),
              const SizedBox(height: 20),
              Align(
                  alignment: Alignment.center,
                  child: Column(
                      children: List.generate(
                          list.length,
                          (i) => Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                  list[i].length,
                                  (j) => GestureDetector(
                                      onTap: (id) {
                                        return () {
                                          print('id = $id');
                                          playaudio(id);
                                        };
                                      }(counter++),
                                      child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(minWidth: 55),
                                              child: Container(
                                                  height: 55,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 2),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(
                                                          Radius.circular(4)),
                                                      color: selectedIndex ==
                                                              counter - 1
                                                          ? const Color(
                                                              0xff1b75b7)
                                                          : Colors.white),
                                                  child: Center(
                                                      child: Text(list[i][j],
                                                          style: TextStyle(fontSize: 20, color: selectedIndex == counter - 1 ? Colors.white : Colors.black))))))),
                                ),
                              )))),
              if (wordToChars.isNotEmpty)
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0; i < substep + 1; i++)
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: substep < 5 ? 5 : 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                color: const Color(0xffC45BFF),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4))),
                            child: Text(wordToChars[i],
                                style: TextStyle(
                                    fontSize: substep < 6 ? 28 : 20,
                                    color: Colors.white)))
                    ]),
              const SizedBox(height: 50),
              if (!playing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          print('onPress ${list[0].length}, $selectedIndex');
                          if (totalCount <= selectedIndex + 1) {
                            widget.activityCallback(
                                {'type': 'complete', 'response': {}});
                          } else {
                            playaudio(selectedIndex + 1);
                          }
                        },
                        child: Text('Next'))
                  ],
                )
            ]),
          ),
        ));
  }
}

List<T> flatten<T>(list) => [for (var sublist in list) ...sublist];

// borrowed code - begin
