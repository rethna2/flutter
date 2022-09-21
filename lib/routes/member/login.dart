import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../comps/core.dart';
import '../../common/globalController.dart';
import 'package:url_launcher/url_launcher_string.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.grey[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isWaiting = false;
  String errorMsg = '';

  Future<void> handleSubmit(controller) async {
    if (isWaiting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isWaiting = true;
      errorMsg = '';
    });
    String res = await controller.login(email.toLowerCase(), password);
    print('login $res');
    if (res == 'success') {
      Navigator.pushNamed(
        context,
        '/member/details',
      );
    } else {
      setState(() {
        errorMsg = res;
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      PTitle(title: 'Login'),
      if (this.errorMsg != '')
        Container(
            color: Colors.red,
            padding: const EdgeInsets.all(5),
            child: Text(this.errorMsg, style: TextStyle(color: Colors.white))),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child:
              Consumer<GlobalController>(builder: (context, controller, child) {
            return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...[
                      TextFormField(
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        validator: validateEmail,
                        onChanged: (value) {
                          email = value.trim();
                        },
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(8),
                          labelText: 'Email',
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Password',
                          contentPadding: EdgeInsets.all(8),
                        ),
                        obscureText: true,
                        validator: validatePassword,
                        onChanged: (value) {
                          password = value.trim();
                        },
                      ),
                      ProgButton(
                          isWaiting: isWaiting,
                          label: 'Login',
                          onClick: () {
                            handleSubmit(controller);
                          })
                    ].expand(
                      (widget) => [
                        widget,
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    )
                  ],
                ));
          })),
      Container(
          padding: const EdgeInsets.all(15),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(children: [
              Text('No Account?'),
              Button(
                  label: 'Sign Up',
                  onClick: () {
                    Navigator.pushNamed(
                      context,
                      '/member/signup',
                    );
                  })
            ]),
          )),
      Container(
          padding: const EdgeInsets.all(15),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(children: [
              Text('Forget Your Password?'),
              Button(
                  label: 'Reset Password',
                  onClick: () {
                    Navigator.pushNamed(
                      context,
                      '/member/forgetpassword',
                    );
                  })
            ]),
          )),
    ]));
  }
}
