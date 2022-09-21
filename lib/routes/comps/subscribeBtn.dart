import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../common/globalController.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SubscribeBtn extends StatefulWidget {
  final String label;

  const SubscribeBtn({Key? key, this.label = "Subscribe"}) : super(key: key);

  @override
  _SubscribeBtnState createState() => _SubscribeBtnState();
}

class _SubscribeBtnState extends State<SubscribeBtn> {
  bool isWaiting = false;
  bool success = false;
  String errorMsg = "";
  Razorpay _razorpay = Razorpay();
  void initState() {
    super.initState();
    print("_SubscribeBtnState");
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void handleClick(
      Map user, Function getPaymentInfo, Function getProfile) async {
    if (isWaiting) {
      return;
    }
    setState(() {
      isWaiting = true;
    });
    final paymentInfo = await getPaymentInfo();
    print('paymentInfo = $paymentInfo');
    if (paymentInfo['error']) {
      return;
    }
    Map data = paymentInfo['data'];
    if (data['code'] == 1101) {
      setState(() {
        errorMsg = data['msg'];
        isWaiting = false;
      });
      return;
    }
    print('email = ${user['profile']['id']}');
    String email = user['profile']['id'];
    Map<String, dynamic> options = {
      'key': 'rzp_live_OVBWBRMiJoIxne',
      //'key': 'rzp_test_Y5tfJSIvCHI8Xc',
      'amount': '50000',
      'currency': 'INR',
      'name': 'PSchool',
      'order_id': data['id'],
      'prefill': {'email': email, 'contact': false},
      'customer': {'email': email, 'contact': false},
      'email': email,
      'contact': false,
      'description': 'One year subscription',
      'readonly': {'email': 1},
    };
    print('options = $options');

    void _handlePaymentSuccess(PaymentSuccessResponse response) async {
      // Do something when payment succeeds
      print("_handlePaymentSuccess ");
      setState(() {
        isWaiting = false;
        success = true;
      });
      await getProfile();
    }

    void _handlePaymentError(PaymentFailureResponse response) {
      Map res = jsonDecode(response.message ?? "{}");

      // Do something when payment fails
      setState(() {
        errorMsg = res['error']!['description'];
        isWaiting = false;
      });
      print('response.message = ${response.message}');
      print('response.code = ${response.code}');
      print('response.message = ${response.message}');

      print("_handlePaymentError = ${response.toString()}");
    }

    void _handleExternalWallet(ExternalWalletResponse response) {
      // Do something when an external wallet is selected
      print("_handleExternalWallet");
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    if (success) {
      return Column(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(10.0),
                color: Colors.orange),
            child: Text('Your payment was Successful!',
                style: TextStyle(fontSize: 20, color: Colors.white))),
        SizedBox(height: 20),
        Text(
            'Please check your email. You would have got more information. Kindly remember your password if you are using PSchool in more than one devices.',
            style: TextStyle(color: Colors.black))
      ]);
    }
    return Consumer<GlobalController>(builder: (context, controller, child) {
      print('USER ********** ${controller.user}');
      return Column(children: [
        if (errorMsg != "")
          Container(
              color: Colors.red,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(15),
              child: Text(errorMsg, style: TextStyle(color: Colors.white))),
        GestureDetector(
          onTap: () {
            handleClick(controller.user, controller.getPaymentInfo,
                controller.getProfile);
          },
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              clipBehavior: Clip.none,
              color: Colors.orange,
              padding: EdgeInsets.fromLTRB(40, 10, 4, 10),
              width: 170,
              child: Row(children: [
                isWaiting
                    ? SpinKitRing(
                        color: Color(0xff0d3756),
                        lineWidth: 3,
                        size: 25.0,
                      )
                    : Icon(Icons.arrow_forward),
                SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                      color: Color(0xff0d3756),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ]),
            ),
            Positioned(
                left: -55,
                top: 0,
                child: Transform.rotate(
                    angle: -Math.pi / 12,
                    child: Container(
                        color: Color(0xff1b75b7),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text(
                          '₹500 / year',
                          style: TextStyle(color: Colors.white),
                        )))),
          ]),
        )
      ]);
    });
  }
}
