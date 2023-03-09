import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pschool_math/routes/comps/core.dart';
import './settings.dart';
import '../../common/globalController.dart';
import '../../utils/utils.dart';
import '../comps/subscribeBtn.dart';
import '../comps/core.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Consumer<GlobalController>(builder: (context, controller, child) {
        int subDate = getPaymentMap(controller.user['profile']);

        String? email = controller.user['profile']?['id'];
        Map user = controller.user;
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              /*
              Button(
                  label: 'Test Api Error',
                  onClick: () {
                    controller.testApi();
                  }), */
              RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Color(0xff0d3756)),
                      children: [
                    TextSpan(text: 'Hello '),
                    TextSpan(
                        text: email,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
              SizedBox(height: 20),
              if (user['everSubscribed'] ?? false)
                user['paidUser']
                    ? (RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Color(0xff0d3756)),
                            children: [
                            const TextSpan(text: 'You have subscribed till '),
                            TextSpan(
                                text: user['subscribedTill'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ])))
                    : (Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                              text: TextSpan(
                                  style: const TextStyle(color: Colors.red),
                                  children: [
                                const TextSpan(
                                    text: 'Your subscription ended on '),
                                TextSpan(
                                    text: user['subscribedTill'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ])),
                          const SizedBox(height: 15),
                          SubscribeBtn(label: 'Renew'),
                          const SizedBox(height: 15),
                          Text(
                              'Renew your subscription for one more year and support us.')
                        ],
                      )),
              SizedBox(height: 20),
              if (subDate == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        'Support us by becoming a member. No recurring charges.'),
                    SizedBox(height: 15),
                    SubscribeBtn(label: 'Subscribe')
                  ],
                ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(10.0),
                    color: Color(0xff18b3a1)),
                child: Text(
                    'Kindly do not share your login details outside your family. Instead ask them to become a member and support PSchool.',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Settings(),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  controller.logout();
                  Navigator.pushNamed(
                    context,
                    '/member/login',
                  );
                },
                child: Text(
                  'Logout',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ]));
      })
    ]);
  }
}
