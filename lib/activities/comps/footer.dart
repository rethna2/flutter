import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final Function onNext;
  final List response;
  final bool showNext;
  final Widget children;
  const Footer(
      {Key? key,
      required this.onNext,
      required this.response,
      required this.showNext,
      this.children = const SizedBox.shrink()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 5.0, offset: Offset(2, 4))
                ]),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                    'Score : ${response.where((item) => item['right'] == true).length} / ${response.length}',
                    style: TextStyle(fontSize: 16))),
            if (children != null) children,
            if (showNext)
              ElevatedButton(
                  onPressed: () {
                    onNext();
                    /*
                  widget.activityCallback(
                      {'type': 'complete', 'response': response});
                  */
                  },
                  child: Text('Next'))
          ],
        ));
  }
}
