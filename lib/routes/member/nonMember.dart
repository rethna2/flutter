import 'package:flutter/material.dart';
import './settings.dart';

class NonMember extends StatelessWidget {
  const NonMember({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(fontSize: 16, color: Color(0xff0d3756), height: 2);
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/member/login',
                        );
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/member/signup',
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/member/signup',
                        );
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.orange),
                      child: const Text(
                        'Become a Member',
                        style: TextStyle(color: Color(0xff0d3756)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                RichText(
                    text: TextSpan(style: textStyle, children: [
                  TextSpan(text: 'You can become a member by paying '),
                  TextSpan(
                      text: ' ₹ 500 per year',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                  TextSpan(
                      text:
                          '. There is no recurring payment. We offer multiple secured payment options. (UPI, Netbanking, Cards etc). '),
                ])),
                SizedBox(height: 15),
                Text(
                    'By becoming a member you get access to all locked activities. We also provide access to 100s of printable worksheets. We keep lot of our activities free so that It can benefit many students. Kindly support us by becoming a member. It helps us to pay our employees, bills and to build a better app in the coming years.',
                    style: textStyle),
                //  Settings()
              ],
            )));
  }
}
