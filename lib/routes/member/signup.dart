import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import '../comps/core.dart';
import '../../utils/utils.dart';
import 'package:provider/provider.dart';
import '../../common/globalController.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isWaiting = false;
  String errorMsg = '';
  String otp = '';
  bool showConfirmSignup = false;

  Future<void> handleSubmit(controller, isResendCode) async {
    print('handleSubmit signup');
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
    String? res;
    if (!showConfirmSignup) {
      if (!isResendCode) {
        res = await controller.signup(email.toLowerCase(), password);
      } else {
        res = await controller.resendConfirmationCode(email.toLowerCase());
      }
    } else {
      res = await controller.confirmRegistration(
          otp, email.toLowerCase(), password);
    }
    print('res = $res');
    if (res == 'success') {
      if (showConfirmSignup) {
        Navigator.pushNamed(
          context,
          '/member/details',
        );
      } else {
        setState(() {
          isWaiting = false;
          showConfirmSignup = true;
        });
      }
    } else {
      setState(() {
        isWaiting = false;
        errorMsg = res ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child:
        Consumer<GlobalController>(builder: (context, controller, child) {
      return Container(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            PTitle(title: 'Signup'),
            if (errorMsg != '')
              Text(errorMsg, style: const TextStyle(color: Colors.red)),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (!showConfirmSignup)
                    TextFormField(
                      autofocus: true,
                      validator: validateEmail,
                      onChanged: (value) {
                        email = value.trim();
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                  if (!showConfirmSignup)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: validatePassword,
                      obscureText: true,
                      onChanged: (value) {
                        password = value.trim();
                      },
                    ),
                  if (showConfirmSignup)
                    Column(children: [
                      const SizedBox(height: 15),
                      Text(
                          "Please check your email and fill the verification code (OTP). If  you don't get the email, please check spam and promotions tab.",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 15),
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        validator: validateOTP,
                        onChanged: (value) {
                          otp = value.trim();
                        },
                        decoration: InputDecoration(
                          labelText: 'Verification Code (OTP) *',
                        ),
                      ),
                    ]),
                  ProgButton(
                      isWaiting: isWaiting,
                      label: !showConfirmSignup ? 'Sign Up' : 'Verify Email',
                      onClick: () {
                        handleSubmit(controller, false);
                      })
                ],
              ),
            ),
            RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xff0d3756)),
                    children: [
                  TextSpan(text: 'By signing up, you agree to our '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: new TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString('https://pschool.in');
                      },
                  ),
                  TextSpan(text: ' and our '),
                  TextSpan(
                    text: 'Terms and Conditions.',
                    style: new TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString('https://pschool.in');
                      },
                  ),
                ])),
            SizedBox(height: 15),
            Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                        'Have already signed up but forgot to confirm email id?',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff0d3756))),
                    Button(
                        label: 'Resend Code',
                        onClick: () {
                          handleSubmit(controller, true);
                        }),
                    SizedBox(height: 15),
                    Text('Have an Account?'),
                    Button(
                        label: 'Login',
                        onClick: () {
                          Navigator.pushNamed(
                            context,
                            '/member/login',
                          );
                        })
                  ],
                ))
          ]));
    }));
  }
}
