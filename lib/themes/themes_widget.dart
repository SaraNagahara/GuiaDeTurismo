import 'package:flutter/material.dart';

AppBarTheme defineAppBar(cor) {
  return AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.pink,
    foregroundColor: Colors.white, //cor de texto
    elevation: 4, //Box shadow
  );
}

BottomNavigationBarThemeData defineNavegacaoBase(cor) {
  return BottomNavigationBarThemeData(
    backgroundColor: Colors.pink,
    elevation: 4,
    selectedItemColor: Colors.pink,
  );
}

ElevatedButtonThemeData defineBotaoElevated(cor) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.pink, 
      foregroundColor: Colors.white,
      ),
  );
}
