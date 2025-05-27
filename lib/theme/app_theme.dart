import 'package:flutter/material.dart';

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'Apple SD Gothic Neo', // iOS 한글 시스템 폰트 강제 적용
  scaffoldBackgroundColor: const Color(0xFF181818), // 배경색
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF181818), // 카드/배경과 통일감 있게 #181818
    foregroundColor: Color(0xFFFFFFFF),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2196F3), // 보조 색상(화이트)
    surface: Color(0xFF222222),
    onSurface: Color(0xFFFFFFFF),
    secondary: Color(0xFF2196F3),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
    bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
    titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Color(0xFFFFFFFF),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF181818),
    selectedItemColor: Color(0xFF2196F3),
    unselectedItemColor: Color(0xFF888888),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);

final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'Apple SD Gothic Neo', // iOS 한글 시스템 폰트 강제 적용
  scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 기본 배경색
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF000000),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFF000000),
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2196F3),
    surface: Color(0xFFF5F5F5),
    onSurface: Color(0xFF000000),
    secondary: Color(0xFF2196F3),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF000000)),
    bodyLarge: TextStyle(color: Color(0xFF000000)),
    titleMedium: TextStyle(color: Color(0xFF000000)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Color(0xFFFFFFFF),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFFFFFFF),
    selectedItemColor: Color(0xFF2196F3),
    unselectedItemColor: Color(0xFF888888),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
); 