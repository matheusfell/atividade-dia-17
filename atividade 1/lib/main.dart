import 'package:flutter/material.dart';

import 'primeiro.dart';
import 'segundo.dart';
import 'terceiro.dart';

void main() {
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disciplinas por semestre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const Menu(),
    );
  }
}

enum Tela {
  home('Home', Home()),
  primeiro('Primeiro semestre', Primeiro()),
  segundo('Segundo semestre', Segundo()),
  terceiro('Terceiro semestre', Terceiro());

  const Tela(this.titulo, this.conteudo);

  final String titulo;
  final Widget conteudo;
}

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Tela _tela = Tela.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tela.titulo)),
      body: _tela.conteudo,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Matheus Bento'),
              accountEmail: Text('matheus.bento@gmail.com'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),
            for (final tela in Tela.values)
              ListTile(
                title: Text(tela.titulo),
                selected: _tela == tela,
                onTap: () {
                  setState(() => _tela = tela);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Abra o menu lateral e selecione um semestre para ver as disciplinas.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
