import 'package:flutter/material.dart';

class ActComplete extends StatelessWidget {
  final Function onNext;
  final List response;
  final Widget children;
  const ActComplete(
      {Key? key,
      required this.onNext,
      required this.response,
      this.children = const SizedBox.shrink()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(children: [
          Text('You have completed this activity.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25)),
          if (children != null) children,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5.0,
                            offset: Offset(2, 4))
                      ]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                      'Score : ${response.where((item) => item['right'] == true).length} / ${response.length}',
                      style: const TextStyle(fontSize: 16))),
              ElevatedButton(
                  onPressed: () {
                    onNext(response);
                    /*
                  widget.activityCallback(
                      {'type': 'complete', 'response': response});
                  */
                  },
                  child: const Text('Next'))
            ],
          )
        ]));
  }
}
