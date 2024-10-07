import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart';
import '../utils/filesystem.dart';
import 'comps/MyAppBar.dart';
import '../common/globalController.dart';
import './nativeActWrap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'comps/AskToSubscribe.dart';
import 'comps/CollectInfo.dart';
import '../utils/vars.dart';

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
  //'placeValueAbacus',
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
  String _updateResponse = '';
  ActivityPageArgs? _args;
  double width = 400;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  late AudioPlayer player;
  late Map response;
  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
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
      print('Error in loading! - 1');
      return;
    } else if (payload['type'] == 'progress') {
      setState(() {
        progress = payload['progress'].toInt();
      });
    } else if (payload['type'] == 'resultView') {
      String updateResponse = '';
      try {
        updateResponse = await updateProgress(payload, args, controller);
      } catch (e) {
        print('e = $e');
        //just consume it
      }

      setState(() {
        progress = 100;
        _saved = true;
        _updateResponse = updateResponse;
      });
    } else if (payload['type'] == 'complete') {
      // some activities does't have resultView
      String updateResponse = '';
      if (!_saved) {
        try {
          updateResponse = await updateProgress(payload, args, controller);
        } catch (e) {
          print('e = $e');
          //just consume it
        }
      } else {
        updateResponse = _updateResponse;
      }
      if (updateResponse != '') {
        setState(() {
          _updateResponse = updateResponse;
          _args = args;
        });
      } else {
        Navigator.popAndPushNamed(context, '/playlist',
            arguments: RouteArgs(
                id: args.playlistId,
                lastAct: args.activityId,
                paidUser: controller.user['paidUser']));
      }
    }
  }

  Future<String> updateProgress(payload, args, controller) async {
    print('updateProgress ${json.encode(payload)}');
    int? score;
    if (payload['response'] != null) {
      score = _calcScore(payload['response']);
      if ((score ?? 0) >= 90) {
        _controllerCenter.play();
        if (controller.user['userPref']['clapSound'] == true) {
          player.play();
        }
      }
    }

    String response = await DatabaseHelper.instance.addResponse(
        payload['response'],
        args.playlistId,
        args.activityId,
        score,
        args.actsCount,
        startTime,
        controller.user);
    return response;
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    /*
    if (_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _loading = false;
          }));
      return Scaffold(
          appBar: MyAppBar(), body: Container(child: Text('Loading....')));
    }
    */
    if (_updateResponse == 'collectInfo') {
      return CollectInfo(onClose: () {
        Navigator.popAndPushNamed(context, '/playlist',
            arguments: RouteArgs(
                id: _args?.playlistId ?? '',
                lastAct: _args?.activityId,
                paidUser: true));
      });
    }

    if (_updateResponse == 'askToSubscribe' && _args != null) {
      return AskToSubscribe(onClose: () {
        if (_args != null) {
          Navigator.popAndPushNamed(context, '/playlist',
              arguments: RouteArgs(
                  id: _args?.playlistId ?? '',
                  lastAct: _args?.activityId,
                  paidUser: false));
        }
      });
    }

    return WillPopScope(
        onWillPop: () => _onWillPop(args),
        child: Scaffold(
            appBar: MyAppBar(),
            body: Container(
                color: lc2,
                child: Column(key: stickyKey, children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 5,
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
                  Consumer<GlobalController>(
                      builder: (context, controller, child) {
                    return Expanded(
                        child: Stack(fit: StackFit.expand, children: [
                      Container(
                        color:
                            const Color(0xffbcdbf7), // const Color(0xfff6f6f8),
                      ),
                      !isNative(args.data)
                          ? (WebViewPlus(
                              //initialUrl: 'https://flutter.dev',
                              initialUrl:
                                  'webNextjs/acts/${args.data["type"]}.html',
                              //initialUrl: 'webNextjs/audiotest.html',
                              javascriptMode: JavascriptMode.unrestricted,
                              onWebViewCreated: (controller) {
                                webController = controller.webViewController;
                              },
                              onPageFinished: (value) async {
                                // print('value passed = ${args.data['data']}');
                              },
                              onWebResourceError: (WebResourceError error) {
                                print('WebResourceError $error');
                                // webController.reload();

                                Navigator.popAndPushNamed(context, '/playlist',
                                    arguments: RouteArgs(
                                        id: args.playlistId,
                                        lastAct: args.activityId,
                                        paidUser: true,
                                        isBack: true));
                              },
                              onProgress: (int progress) {
                                if (progress == 100) {
                                  var str = json.encode(args.data['data']);
                                  //await Future.delayed(const Duration(milliseconds: 200));
                                  try {
                                    webController.runJavascript(
                                        //'window.receiveActData(${str})'
                                        'try{window.receiveActData(${str})}catch(e){ window.jsChannel.postMessage(\'{"type": "error"}\');}');
                                  } catch (e) {
                                    //this.webController.reload();
                                    Navigator.popAndPushNamed(
                                        context, '/playlist',
                                        arguments: RouteArgs(
                                            id: args.playlistId,
                                            lastAct: args.activityId,
                                            paidUser: true,
                                            isBack: true));
                                    print('Error in loading! - 2');
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
                ]))
            //debug
            ));
  }
}
