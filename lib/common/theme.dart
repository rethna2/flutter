import 'package:flutter/material.dart';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff0d3756),
      secondary: const Color(0xff1b75b7),
      tertiary: const Color(0xffbcdbf7),
      background: const Color(0xffdddddd),
      surface: const Color(0xfff6f6f8)),
  textTheme: const TextTheme(
    headline1: TextStyle(
      fontFamily: 'Corben',
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: Colors.white,
    ),
  ),
);
