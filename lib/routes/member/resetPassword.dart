import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../comps/core.dart';
import '../../common/globalController.dart';
import '../../utils/utils.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isWaiting = false;
  String errorMsg = '';
  String otp = '';
  bool formTwo = false;

  Future<void> handleSubmit(controller, isResendCode) async {
    print('handleSubmit resetPassword');
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
    if (!formTwo) {
      res = await controller.forgetPassword(email.toLowerCase());
    } else {
      res =
          await controller.confirmPassword(otp, email.toLowerCase(), password);
    }
    if (res == 'success') {
      if (formTwo) {
        Navigator.pushNamed(
          context,
          '/member/details',
        );
      } else {
        setState(() {
          isWaiting = false;
          formTwo = true;
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
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              PTitle(title: 'Reset Password'),
              if (errorMsg != '')
                Text(errorMsg, style: const TextStyle(color: Colors.red)),
              Consumer<GlobalController>(builder: (context, controller, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (!formTwo)
                        TextFormField(
                          // The validator receives the text that the user has entered.
                          validator: validateEmail,
                          onChanged: (value) {
                            email = value.trim();
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                      if (formTwo)
                        Column(
                          children: [
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
                                labelText: 'Code (OTP) *',
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                              ),
                              validator: validatePassword,
                              obscureText: true,
                              onChanged: (value) {
                                password = value.trim();
                              },
                            ),
                          ],
                        ),
                      ProgButton(
                          isWaiting: isWaiting,
                          label: !formTwo ? 'Send Code' : 'Submit',
                          onClick: () {
                            handleSubmit(controller, false);
                          })
                    ],
                  ),
                );
              }),
            ])));
  }
}
