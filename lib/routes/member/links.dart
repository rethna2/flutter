import 'package:flutter/material.dart';

class Links extends StatelessWidget {
  const Links({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/member/login',
            );
          },
          child: const Text('Login Page')),
      GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/member/signup',
            );
          },
          child: const Text('SignUp Page')),
      GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/member/forgetpassword',
            );
          },
          child: const Text('Forget Password Page'))
    ]);
  }
}
