import 'package:flutter/material.dart';
import 'comps/MyAppBar.dart';
import 'comps/core.dart';

class AskToSubscribe extends StatelessWidget {
  // const UserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Color(0xff0d3756));
    return Scaffold(
        appBar: MyAppBar(),
        body: Stack(
          children: [
            Container(
              decoration:
                  new BoxDecoration(color: const Color(0xffbcdbf7), boxShadow: [
                new BoxShadow(
                    color: Colors.grey, blurRadius: 5.0, offset: Offset(5, 5)),
              ]),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(30),
              height: 300,
              child: Column(children: [
                SizedBox(height: 15),
                Text(
                    'These activities are available only for members. Please support us by becoming a member.',
                    style: style),
                SizedBox(height: 15),
                Text(
                    'Get access to all locked activities by becoming a member.',
                    style: style),
                PTitle(title: '₹ 500/year'),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Button(
                      label: 'Later',
                      onClick: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(width: 25),
                  Button(
                      label: 'Subscribe',
                      onClick: () {
                        Navigator.pushNamed(
                          context,
                          '/member',
                        );
                      }),
                ]),
                SizedBox(height: 15),
                Text(
                    'If you have already paid, please login to avoid seeing this message again.',
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
              ]),
            ),
            Positioned(
                right: -5,
                top: 10,
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.red,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  padding: EdgeInsets.all(5.0),
                  shape: CircleBorder(),
                )),
          ],
        ));
  }
}
