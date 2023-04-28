import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../utils/svgUtils.dart';
import 'dart:ui';
import 'dart:math' as Math;
import 'Tracer.dart';
import 'Tutor.dart';
import 'package:just_audio/just_audio.dart';
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map actData = {};
  try {
    final String response =
        await rootBundle.loadString('assets/playlists/ta-letter.pschool');
    final data = await json.decode(response);
    actData = data['list'][0]['data'];
  } catch (e) {
    print("Error! ${e}");
  }

  return runApp(
    MaterialApp(
      home: Tracing(data: actData),
    ),
  );
}
*/

class Tracing extends StatefulWidget {
  const Tracing(
      {Key? key,
      required this.data,
      required this.size,
      required this.activityCallback})
      : super(key: key);
  final Map data;
  final Size size;
  final Function activityCallback;
  @override
  State<Tracing> createState() => _TracingState();
}

Tween<Offset> _beginSlide = Tween<Offset>(
  begin: const Offset(1.5, 0),
  //end: Offset.zero,
  end: Offset.zero,
);

Tween<Offset> _endSlide = Tween<Offset>(
  begin: Offset.zero,
  //end: Offset.zero,
  end: const Offset(-1.5, 0),
);

class _TracingState extends State<Tracing> with TickerProviderStateMixin {
  int index = 0;
  bool isDone = false;
  bool isTutor = false;
  bool pickLetterView = false;
  bool isComplete = false;
  late List<List> pathList;
  late List allPathLength;
  late num scale;
  late AudioPlayer player;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  late Animation<Offset> _offsetAnimation = _beginSlide.animate(_controller);

  @override
  void initState() {
    List paths = widget.data["source"][index]["paths"];
    allPathLength = getRealLengths(widget.data, widget.size);
    pathList = [];
    scale = getScale(widget.data["source"][index], widget.size);
    for (int i = 0; i < paths.length; i++) {
      List list = dataToObj(paths[i]);
      list = resize(list, 0, 0, scale, scale);
      pathList.add(list);
    }

    if (widget.data['audio'] != null) {
      player = AudioPlayer();
      String audio = widget.data['audio']; //.replaceAll('.mp3', '.aac');
      player.setAsset('assets/sound/${audio}');
      playaudio();
    }

    super.initState();
    _controller.forward(from: 0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isDone) {
          _offsetAnimation = _beginSlide.animate(_controller);
          _controller.forward(from: 0);
          setState(() {
            if (index >= widget.data["source"].length) {
              isComplete = true;
              return;
            }
            List paths = widget.data["source"][index]["paths"];
            pathList = [];
            scale = getScale(widget.data["source"][index], widget.size);
            for (int i = 0; i < paths.length; i++) {
              List list = dataToObj(paths[i]);
              list = resize(list, 0, 0, scale, scale);
              pathList.add(list);
            }
            isDone = false;
          });
          if (index < widget.data["source"].length) {
            if (widget.data['audio'] != null) {
              playaudio();
            }
          }
        }
      }
    });
  }

  void playaudio() async {
    int offset = widget.data["source"][index]['audio'];
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleNext([newIndex]) {
    setState(() {
      isDone = true;
      _offsetAnimation = _endSlide.animate(_controller);
      _controller.forward(from: 0);
      if (newIndex != null) {
        index = newIndex;
        pickLetterView = false;
      } else {
        index = index + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (index >= widget.data['source'].length) {
      return Column(children: [
        Text('You have completed this activity.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25)),
        ElevatedButton(
            onPressed: () {
              widget.activityCallback({
                'type': 'complete',
                'response': {'done': true}
              });
            },
            child: Text('Next'))
      ]);
    }

    var dataToPass = {
      ...widget.data['source'][index],
      'lengths': allPathLength[index]
    };
    return Scaffold(
        body: Column(children: [
      Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Trace it!'),
            if (pickLetterView == false && widget.data['noPicker'] != true)
              GestureDetector(
                  onTap: () {
                    setState(() {
                      pickLetterView = true;
                    });
                  },
                  child: Text('Pick Letter')),
            GestureDetector(
                onTap: () {
                  setState(() {
                    isTutor = !isTutor;
                  });
                },
                child: Wrap(children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.black,
                    size: 16.0,
                  ),
                  Text(isTutor ? 'Hide Tutor' : 'Show Tutor'),
                ])),

            //  ElevatedButton(onPressed: handleNext, child: Text('Next'))
          ])),
      SlideTransition(
          position: _offsetAnimation,
          child: Container(
            //  height: Math.min(400 * scale, widget.size.height - 80),
            height: widget.size.height - 160,
            width: widget.size.width,
            /* decoration: new BoxDecoration(
              color: Colors.yellowAccent,
            )*/
            child: pickLetterView == true
                ? getPickLetterView(widget.data["source"])
                : (isTutor == true
                    ? (Tutor(
                        data: dataToPass,
                        pathList: pathList,
                        scale: scale,
                        size: widget.size))
                    : (Tracer(
                        data: dataToPass,
                        pathList: pathList,
                        scale: scale,
                        width: Math.max(
                            widget.data["source"][index]['width'] ?? 300, 250),
                        size: widget.size,
                        done: handleNext))),
          )),
    ]));
  }

  Widget getPickLetterView(source) {
    return Column(children: [
      Text(
        "Pick a letter to trace",
        style: TextStyle(decoration: TextDecoration.underline),
      ),
      SizedBox(
        height: 40,
      ),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.start,
        children: (source as List)
            .map((item) => GestureDetector(
                onTap: () {
                  int newIndex = source
                      .indexWhere((element) => element['id'] == item['id']);
                  handleNext(newIndex);
                },
                child: Text(item['id'], style: TextStyle(fontSize: 20))))
            .toList(),
      )
      /* Wrap(
          children: (source as List).mapIndexed((j, unit) =>
              ElevatedButton(onPressed: () {}, child: Text('Temp')).toList()))*/
    ]);
  }
}
