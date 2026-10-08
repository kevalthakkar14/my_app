import 'package:flutter/material.dart';

import 'color_resource.dart';

class ThemeResource {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor:
        ColorResource.background,
    primaryColor:
        ColorResource.primaryOrange,

    colorScheme: const ColorScheme.dark(
      primary: ColorResource.primaryOrange,
      secondary: ColorResource.primaryOrange,
      surface: ColorResource.cardBackground,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          ColorResource.background,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor:
          ColorResource.secondaryBackground,
      labelStyle: const TextStyle(
        color: Colors.white60,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          color: Colors.white12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          color:
              ColorResource.primaryOrange,
        ),
      ),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            ColorResource.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    ),
  );
}