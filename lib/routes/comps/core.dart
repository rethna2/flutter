import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Button extends StatelessWidget {
  Button({Key? key, required this.label, required this.onClick})
      : super(key: key);
  String label;
  Function onClick;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        //fixedSize: Size(150, 50),
        minimumSize: Size(120, 35),
        onPrimary: Colors.black87,
        primary: Color(0xff4fa7f7),
      ),
      onPressed: () {
        print('onPressed label $label');
        onClick();
      },
      child: Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}

class ProgButton extends StatelessWidget {
  ProgButton(
      {Key? key,
      required this.label,
      required this.onClick,
      required this.isWaiting})
      : super(key: key);
  String label;
  Function onClick;
  bool isWaiting;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        icon: isWaiting
            ? SpinKitRing(
                color: Colors.white,
                lineWidth: 3,
                size: 25.0,
              )
            : Icon(Icons.arrow_forward),
        label: Text(label, style: TextStyle(fontSize: 18)),
        onPressed: () {
          onClick();
        });
  }
}

class PTitle extends StatelessWidget {
  PTitle({Key? key, required this.title}) : super(key: key);
  String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.girassol(textStyle: TextStyle(fontSize: 25)));
  }
}
