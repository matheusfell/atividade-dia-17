import 'package:flutter/material.dart';

import 'modelos.dart';
import 'sessao.dart';
import 'telas/home_tela.dart';
import 'telas/login_tela.dart';

void main() {
  runApp(const TuiTui());
}

class TuiTui extends StatelessWidget {
  const TuiTui({super.key});

  @override
  Widget build(BuildContext context) {
    const tinta = Color(0xFF152A39);
    const petroleo = Color(0xFF075C57);
    const gelo = Color(0xFFF1F7F7);
    const borda = Color(0xFFD1E0E3);
    const menta = Color(0xFFC7F1E8);
    final cores = ColorScheme.fromSeed(seedColor: petroleo).copyWith(
      primary: petroleo,
      primaryContainer: menta,
      onPrimaryContainer: tinta,
      surface: Colors.white,
      onSurface: tinta,
      outlineVariant: borda,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: cores);
    final cantos = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final campo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: borda),
    );

    return MaterialApp(
      title: 'TuiTui',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: gelo,
        textTheme: base.textTheme.copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: tinta,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: borda)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gelo,
          border: campo,
          enabledBorder: campo,
          focusedBorder: campo.copyWith(
            borderSide: const BorderSide(color: petroleo, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(shape: cantos),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(shape: cantos),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: petroleo,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  late final Future<Usuario?> _sessao = Sessao.carregar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: _sessao,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final usuario = snapshot.data;
        return usuario == null ? const LoginTela() : HomeTela(usuario: usuario);
      },
    );
  }
}
