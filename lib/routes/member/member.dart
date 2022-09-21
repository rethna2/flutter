import 'package:flutter/material.dart';
import '../comps/MyAppBar.dart';
import 'login.dart';
import 'signup.dart';
import 'resetPassword.dart';
import 'userDetails.dart';
import 'nonMember.dart';
import 'package:provider/provider.dart';
import '../../common/globalController.dart';

//final _navigatorKey = GlobalKey<NavigatorState>();

class MemberPage extends StatelessWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: 'Member Page'),
        body: Consumer<GlobalController>(builder: (context, controller, child) {
          return Navigator(
              //key: _navigatorKey,
              initialRoute: controller.user['profile'] != null
                  ? '/member/details'
                  : '/member/new',
              onGenerateRoute: (RouteSettings routeSettings) {
                WidgetBuilder builder;
                switch (routeSettings.name) {
                  case '/member/login':
                    builder = (BuildContext context) => Login();
                    break;
                  case '/member/signup':
                    builder = (BuildContext context) => const Signup();
                    break;
                  case '/member/forgetpassword':
                    builder = (BuildContext context) => const ResetPassword();
                    break;
                  case '/member/details':
                    builder = (BuildContext context) => const UserDetails();
                    break;
                  case '/member/new':
                  default:
                    builder = (BuildContext context) => const NonMember();
                }
                return MaterialPageRoute<void>(
                    builder: builder, settings: routeSettings);
              });
        }));
  }
}
