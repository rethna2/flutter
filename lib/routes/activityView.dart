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
  /*'rightOne'*/
  'placeValueAbacus',
  'numberLine'
];

int? _calcScore(response) {
  if (response is List) {
    num score =
        response.where((item) => item['right'] == true).toList().length /
            response.length;
    return (score * 100).round();
  }
  return null;
}

class ActivityViewState extends State<ActivityView> {
  late WebViewController webController;
  late ConfettiController _controllerCenter;
  GlobalKey stickyKey = GlobalKey();
  int progress = 0;
  double width = 400;
  late Map response;
  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
    readFile().then((str) {
      print('Read File:::::::: ${str}');
      if (str == '') {
        print('No file Present');
        this.response = {};
      } else {
        this.response = json.decode(str);
      }
    });
    // Enable virtual display.
    // if (Platform.isAndroid) WebViewPlus.platform = AndroidWebView();
    WidgetsBinding.instance.addPostFrameCallback((_) => findWidth(context));
    super.initState();
  }

  void findWidth(context) {
    final keyContext = stickyKey.currentContext;
    print('findWidth~~ $keyContext');
    if (keyContext != null) {
      // widget is visible
      final box = keyContext.findRenderObject() as RenderBox;
      print('box.size = ${box.size}');
      width = box.size.width;
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
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
      }
      setState(() {
        progress = 100;
      });
    } else if (payload['type'] == 'complete') {
      String activityId = args.activityId;
      String playlistId = args.playlistId;
      controller.updateResponse(payload['response'], playlistId, activityId);

      // Navigator.of(context).pop();
      /*
      Navigator.pushNamed(context, '/playlist',
          arguments:
              RootID(playlistId, activityId, controller.user['paidUser']));
              */
      //TODO: The below code is needed for back to work properly. But presently giving loading error. Need to fix this later.

      Navigator.popAndPushNamed(context, '/playlist',
          arguments:
              RootID(playlistId, activityId, controller.user['paidUser']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ActivityPageArgs;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: MyAppBar(),
        body: Column(
          key: stickyKey,
          children: [
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
            Consumer<GlobalController>(builder: (context, controller, child) {
              return Expanded(
                  child: Stack(children: [
                nativeAct.indexOf(args.data["type"]) == -1
                    ? (WebViewPlus(
                        //initialUrl: 'https://flutter.dev',
                        initialUrl: 'webNextjs/acts/${args.data["type"]}.html',
                        //initialUrl: 'webNextjs/audiotest.html',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (controller) {
                          this.webController = controller.webViewController;
                        },
                        onPageFinished: (value) {
                          var str = json.encode(args.data['data']);
                          print('onPageFinished = ${args.data['data']}');
                          print('onPageFinished = ${str}');
                          this
                              .webController
                              .runJavascript('window.receiveActData(${str})');
                        },
                        onProgress: (int progress) {
                          print('WebView is loading (progress : $progress%)');
                        },
                        gestureNavigationEnabled: true,
                        javascriptChannels: {
                          JavascriptChannel(
                              name: 'jsChannel',
                              onMessageReceived: (message) async {
                                print('Javascript: "${message.message}"');
                                var payload =
                                    json.decode(message.message) as Map;

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
                    ))
              ]));
            })
          ],
        ));
  }
}
