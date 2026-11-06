import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/screens/cadastro_lugar.dart';
import 'package:guia_turismo/screens/home_screen.dart';
import 'package:guia_turismo/screens/login_screen.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

class Inicializar extends StatelessWidget {
  const Inicializar({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Enquanto o Firebase liga, mostra uma bolinha girando na tela
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Quando o Firebase termina de carregar, o app principal é exibido
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LugaresController()),
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => ThemeController()),
            ChangeNotifierProvider(create: (_) => CameraController()),
          ],
          child: Consumer<ThemeController>(
            builder: (context, controllerThema, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: controllerThema.temaClaro(),
              darkTheme: controllerThema.temaEscuro(),
              themeMode: controllerThema.temaAtual,
              initialRoute: 'login',
              routes: {
                'login': (context) => const LoginScreen(),
                'home': (context) => const HomeScreen(),
                'lugares': (context) => const LugaresScreen(),
                'cadastro': (context) => const CadastroLugar(),
              },
            ),
          ),
        );
      },
    );
  }
}