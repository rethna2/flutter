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
  final num actsCount;
  ActivityPageArgs(this.data, this.playlistId, this.activityId, this.actsCount);
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
  'dictation',
  'phonics'
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
  bool _loading = true;
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

  void activityCallback(payload, controller) async {
    final args = ModalRoute.of(context)!.settings.arguments as ActivityPageArgs;
    if (payload['type'] == 'error') {
      Navigator.popAndPushNamed(context, '/playlist',
          arguments: RouteArgs(
              id: args.playlistId,
              lastAct: args.activityId,
              paidUser: true,
              isBack: true));
      print('Error in loading!');
      return;
    } else if (payload['type'] == 'progress') {
      setState(() {
        progress = payload['progress'].toInt();
      });
    } else if (payload['type'] == 'resultView') {
      bool res = await updateProgress(payload, args, controller);
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
        bool res = await updateProgress(payload, args, controller);
      }
      Navigator.popAndPushNamed(context, '/playlist',
          arguments: RouteArgs(
              id: args.playlistId,
              lastAct: args.activityId,
              paidUser: controller.user['paidUser']));
    }
  }

  Future<bool> updateProgress(payload, args, controller) async {
    //  print('updateProgress ${json.encode(payload)}');
    if (payload['response'] == null) {
      return false;
    }
    int? score = _calcScore(payload['response']);
    if ((score ?? 0) >= 90) {
      _controllerCenter.play();
      if (controller.user['userPref']['clapSound'] == true) {
        player.play();
      }
    }
    await DatabaseHelper.instance.addResponse(payload['response'],
        args.playlistId, args.activityId, score, args.actsCount);
    return true;
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _onWillPop(args) async {
    //return true;
    Navigator.popAndPushNamed(context, '/playlist',
        arguments: RouteArgs(
            id: args.playlistId,
            lastAct: args.activityId,
            paidUser: true,
            isBack: true));
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ActivityPageArgs;
    Size size = MediaQuery.of(context).size;
    print("activityView build $_loading");
    /*
    if (_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _loading = false;
          }));
      return Scaffold(
          appBar: MyAppBar(), body: Container(child: Text('Loading....')));
    }
    */
    return WillPopScope(
        onWillPop: () => _onWillPop(args),
        child: Scaffold(
            appBar: MyAppBar(),
            body: Column(key: stickyKey, children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 5,
                    color: Colors.white,
                  ),
                  Container(
                    width: this.progress * width / 100,
                    height: 5,
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
                          initialUrl:
                              'webNextjs/acts/${args.data["type"]}.html',
                          //initialUrl: 'webNextjs/audiotest.html',
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (controller) {
                            this.webController = controller.webViewController;
                          },
                          onPageFinished: (value) async {
                            // print('value passed = ${args.data['data']}');
                          },
                          onWebResourceError: (WebResourceError error) {
                            print('WebResourceError $error');
                            // this.webController.reload();
                            Navigator.popAndPushNamed(context, '/playlist',
                                arguments: RouteArgs(
                                    id: args.playlistId,
                                    lastAct: args.activityId,
                                    paidUser: true,
                                    isBack: true));
                          },
                          onProgress: (int progress) {
                            if (progress == 100) {
                              print('loaded 100%');
                              var str = json.encode(args.data['data']);
                              //await Future.delayed(const Duration(milliseconds: 200));
                              try {
                                this.webController.runJavascript(
                                    //'window.receiveActData(${str})'
                                    'try{window.receiveActData(${str})}catch(e){ window.jsChannel.postMessage(\'{"type": "error"}\');}');
                              } catch (e) {
                                //this.webController.reload();
                                Navigator.popAndPushNamed(context, '/playlist',
                                    arguments: RouteArgs(
                                        id: args.playlistId,
                                        lastAct: args.activityId,
                                        paidUser: true,
                                        isBack: true));
                                print('Error in loading!');
                              }
                            }
                          },
                          navigationDelegate: (NavigationRequest request) {
                            _launchURL(request.url);
                            return NavigationDecision.prevent;
                          },
                          gestureNavigationEnabled: true,
                          javascriptChannels: {
                            JavascriptChannel(
                                name: 'jsChannel',
                                onMessageReceived: (message) async {
                                  print(
                                      'message = ${message.toString()} : ${message.message}');
                                  var payload =
                                      json.decode(message.message) as Map;

                                  activityCallback(payload, controller);
                                  // await showDialog(context: context, builder: (context) => AlertDialog())
                                  //controller.webViewController.evaluateJavascript('ok()');
                                })
                          },
                        ))
                      : (Container(
                          padding: EdgeInsets.only(top: 10.0),
                          decoration: new BoxDecoration(
                              color: Theme.of(context).colorScheme.surface),
                          width: double.infinity,
                          //padding: const EdgeInsets.all(15),
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
            ));
  }
}
