import 'package:flutter/material.dart';

const allChars = {
  'hi': {
    'consonants':
        "क, ख, ग, घ, ङ, च, छ, ज, झ, ञ, ट, ठ, ड, ढ, ण, त, थ, द, ध, न, प, फ, ब, भ, म, य, र, ल, व, श, ष, स, ह, क्ष, ज्ञ",
    'vowels': "अ, आ, इ, ई, उ, ऊ, ऋ, ए, ऐ, ओ, औ, अं, अः",
    'mixed': "का, कि, की, कु, कू, कृ, के, कै, को, कौ, कं, कः, क्, क़"
  },
  'mr': {
    'consonants':
        "क, ख, ग, घ, ङ, च, छ, ज, झ, ञ, ट, ठ, ड, ढ, ण, त, थ, द, ध, न, प, फ, ब, भ, म, य, र, ल, व, श, ष, स, ह, क्ष, ज्ञ, ळ",
    'vowels': "अ, आ, इ, ई, उ, ऊ, ऋ, ए, ऐ, ओ, औ, अं, अः, ॲ, ऑ",
    'mixed': "का, कि, की, कु, कू, कृ, के, कै, को, कौ, कं, कः, क्, क़"
  },
  'bn': {
    'consonants':
        "ক, খ, গ, ঘ, ঙ, চ, ছ, জ, ঝ, ঞ, ট, ঠ, ড, ঢ, ণ, ত, থ, দ, ধ, ন, প, ফ, ব, ভ, ম, য, র, ল, শ, ষ, স, হ, য়, ড়, ঢ়",
    'vowels': "অ, আ, ই, ঈ, উ, ঊ, ঋ, ঌ, এ, ঐ, ও, ঔ",
    'mixed': "কা, কি, কী, কু, কূ, কৃ, কৄ, কে, কৈ, কো, কৌ"
  },
  'ta': {
    'consonants':
        'க, ங, ச, ஞ, ட, ண, த, ந, ப, ம, ய, ர, ல, வ, ழ, ள, ற, ன, ஜ, ஷ, ஸ, ஹ',
    'vowels': 'அ, ஆ, இ, ஈ, உ, ஊ, எ, ஏ, ஐ, ஒ, ஓ, ஔ, ஃ',
    'mixed': 'க், கா, கி, கீ, கு, கூ, கெ, கே, கை, கொ, கோ, கௌ'
  }
};

class Keyboard extends StatefulWidget {
  const Keyboard({Key? key, required this.onPick, required this.lang})
      : super(key: key);

  @override
  State<Keyboard> createState() => _KeyboardState();

  final Function onPick;
  final String lang;
}

class _KeyboardState extends State<Keyboard> {
  late Map chars;
  late List list;
  late List basic;
  String selected = '';
  static List keyEntries = [
    'QWERTYUIOP',
    'ASDFGHJKL',
    'ZXCVBNM',
    ['Space', 'DEL', 'Done']
  ];

  @override
  void initState() {
    String lang = widget.lang;
    if (lang == 'en') {
    } else if (lang == 'ml') {
    } else {
      chars = {
        'consonants': allChars[lang]?['consonants']
            ?.split(',')
            .map((char) => char.trim())
            .toList(),
        'vowels': allChars[lang]?['vowels']
            ?.split(',')
            .map((char) => char.trim())
            .toList(),
        'partials': allChars[lang]?['mixed']
            ?.split(',')
            .map((char) => char.trim()[1])
            .toList(),
      };
      basic = [
        chars['vowels'][0],
        ...chars['consonants'],
        '⁂',
        'Space',
        'DEL',
        'Done'
      ];
      list = basic;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lang == 'en') {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < keyEntries.length; i++) ...[
                  Container(
                      child: Row(children: [
                    for (int j = 0; j < keyEntries[i].length; j++) ...[
                      Expanded(
                          child: GestureDetector(
                              onTap: () => widget.onPick(keyEntries[i][j]),
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border:
                                          Border.all(color: Colors.blueAccent)),
                                  child: Text(keyEntries[i][j],
                                      textAlign: TextAlign.center))))
                    ]
                  ])),
                ]
              ]));
    }

    if (widget.lang == 'ml') {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < keyEntries.length; i++) ...[
                  Container(
                      child: Row(children: [
                    for (int j = 0; j < keyEntries[i].length; j++) ...[
                      GestureDetector(
                          onTap: () => widget.onPick(keyEntries[i][j]),
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.blueAccent)),
                              child: Text(keyEntries[i][j],
                                  textAlign: TextAlign.center)))
                    ]
                  ])),
                ]
              ]));
    }
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < list.length; i++)
                GestureDetector(
                    onTap: () {
                      if (list[i].length >= 3) {
                        widget.onPick(list[i]);
                        return;
                      }
                      if (selected != '') {
                        if (list[i] == '✕') {
                          setState(() {
                            selected = '';
                            list = basic;
                          });
                          return;
                        }
                        print('onPick = ${list[i]}');
                        widget.onPick(list[i]);
                        setState(() {
                          selected = '';
                          list = basic;
                        });
                      } else {
                        selected = list[i];
                        if (list[i] == chars['vowels'][0]) {
                          setState(() {
                            list = [...chars['vowels'], '✕'];
                          });
                        } else if (list[i] == '⁂') {
                          List temp = [].map((char) => list[i] + char).toList();
                          setState(() {
                            list = [...chars['partials'], '✕'];
                          });
                        } else {
                          List temp = chars['partials']
                              .map((char) => list[i] + char)
                              .toList();
                          setState(() {
                            list = [list[i], ...temp, '✕'];
                          });
                        }
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.blueAccent)),
                        child: Text(list[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 21))))
            ]));
  }
}
