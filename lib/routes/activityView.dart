import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:confetti/confetti.dart';
import '../utils/filesystem.dart';
import 'comps/MyAppBar.dart';
import '../common/globalController.dart';
import './playlistView.dart';
import './nativeActWrap.dart';
//import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';

class ActivityPageArgs {
  final Map data;
  final String playlistId;
  final String activityId;
  ActivityPageArgs(this.data, this.playlistId, this.activityId);
}

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key}) : super(key: key);
  @override
  ActivityViewState createState() => ActivityViewState();
}

const nativeAct = [
  'slides',
  'slides2',
  'tracing',
  'rightOne',
  'placeValueAbacus',
  //'numberLine'
];

bool isNative(Map data) {
  switch (data["type"]) {
    case 'rightOne':
      return data["data"]["audio"] == null ? false : true;
    default:
      return nativeAct.contains(data["type"]);
  }
}

int? _calcScore(response) {
  try {
    if (response is List) {
      num score =
          response.where((item) => item['right'] == true).toList().length /
              response.length;
      return (score * 100).round();
    }

    //if (response is Map) {
    if (response['score'] != null) {
      return response['score'];
    }
    //  }
    return null;
  } catch (e) {
    return null;
  }
}

class ActivityViewState extends State<ActivityView> {
  late WebViewController webController;
  late ConfettiController _controllerCenter;
  GlobalKey stickyKey = GlobalKey();
  int progress = 0;
  bool _saved = false;
  double width = 400;
  late AudioPlayer player;
  late Map response;
  @override
  void initState() {
    super.initState();
    print("activityView initState");
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
    readFile().then((str) {
      if (str == '') {
        this.response = {};
      } else {
        this.response = json.decode(str);
      }
    });
    // Enable virtual display.
    // if (Platform.isAndroid) WebViewPlus.platform = AndroidWebView();
    WidgetsBinding.instance.addPostFrameCallback((_) => findWidth(context));
    player = AudioPlayer();
    player.setAsset('assets/applause-8.mp3');
  }

  void findWidth(context) {
    final keyContext = stickyKey.currentContext;
    if (keyContext != null) {
      // widget is visible
      final box = keyContext.findRenderObject() as RenderBox;
      width = box.size.width;
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    player.pause();
    super.dispose();
  }

  void activityCallback(payload, controller) {
    final args = ModalRoute.of(context)!.settings.arguments as ActivityPageArgs;
    if (payload['type'] == 'progress') {
      setState(() {
        progress = payload['progress'];
      });
    } else if (payload['type'] == 'resultView') {
      int? score = _calcScore(payload['response']);
      if ((score ?? 0) >= 90) {
        _controllerCenter.play();
        player.play();
      }
      DatabaseHelper.instance.addResponse(
          payload['response'], args.playlistId, args.activityId, score);
      /*
      controller.updateResponse(
          payload['response'], playlistId, activityId, score);
          */

      setState(() {
        progress = 100;
        _saved = true;
      });
    } else if (payload['type'] == 'complete') {
      // some activities does't have resultView
      if (!_saved) {
        int? score = _calcScore(payload['response']);
        if ((score ?? 0) >= 90) {
          _controllerCenter.play();
          player.play();
        }
        DatabaseHelper.instance.addResponse(
            payload['response'], args.playlistId, args.activityId, score);
      }
      Navigator.popAndPushNamed(context, '/playlist',
          arguments: RootID(
              args.playlistId, args.activityId, controller.user['paidUser']));
    }
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ActivityPageArgs;
    Size size = MediaQuery.of(context).size;
    print("activityView build");
    return Scaffold(
        appBar: MyAppBar(),
        body: Column(key: stickyKey, children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 10,
                color: Colors.white,
              ),
              Container(
                width: this.progress * width / 100,
                height: 10,
                color: Colors.blue,
              ),
            ],
          ),
          Align(
              alignment: Alignment.topRight,
              child: Text('${args.playlistId}/${args.activityId}',
                  style: TextStyle(color: Colors.grey))),
          Consumer<GlobalController>(builder: (context, controller, child) {
            return Expanded(
                child: Stack(fit: StackFit.expand, children: [
              Container(
                color: const Color(0xf6f6f8ff), //  Colors.blueAccent,
              ),
              !isNative(args.data)
                  ? (WebViewPlus(
                      //initialUrl: 'https://flutter.dev',
                      initialUrl: 'webNextjs/acts/${args.data["type"]}.html',
                      //initialUrl: 'webNextjs/audiotest.html',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        this.webController = controller.webViewController;
                      },
                      onPageFinished: (value) async {
                        print('value passed = ${args.data['data']}');
                        var str = json.encode(args.data['data']);
                        //await Future.delayed(const Duration(milliseconds: 200));
                        this
                            .webController
                            .runJavascript('window.receiveActData(${str})');
                      },
                      onProgress: (int progress) {},
                      navigationDelegate: (NavigationRequest request) {
                        _launchURL(request.url);
                        return NavigationDecision.prevent;
                      },
                      gestureNavigationEnabled: true,
                      javascriptChannels: {
                        JavascriptChannel(
                            name: 'jsChannel',
                            onMessageReceived: (message) async {
                              var payload = json.decode(message.message) as Map;

                              activityCallback(payload, controller);
                              // await showDialog(context: context, builder: (context) => AlertDialog())
                              //controller.webViewController.evaluateJavascript('ok()');
                            })
                      },
                    ))
                  : (Container(
                      decoration: new BoxDecoration(
                          color: Theme.of(context).colorScheme.surface),
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: getActivity(args.data, size, (payload) {
                        activityCallback(payload, controller);
                      }))),
              //ElevatedButton(onPressed: () {}, child: Text("Hello")),
              Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 30,
                    gravity: 0.5,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                  )),
            ]));
          }),
        ])
        //debug
        );
  }
}
