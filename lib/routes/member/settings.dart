import 'package:flutter/material.dart';
import '../comps/core.dart';
import 'package:provider/provider.dart';
import '../../common/globalController.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(fontSize: 16, color: Color(0xff0d3756), height: 2);
    return Container(
        padding: const EdgeInsets.all(10),
        child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          Map userPref = controller.user['userPref'] ?? {};
          print("userPref = ${userPref}");
          return Column(children: [
            PTitle(title: 'Settings'),
            CheckboxListTile(
              value: userPref['clapSound'] ?? true,
              title: Text(
                'Clap Sound on successfully completing the activity',
              ),
              onChanged: (bool? value) {
                controller.updateUserPref(
                    'clapSound', !(userPref['clapSound'] ?? true));
              },
            )
          ]);
        }));
  }
}
