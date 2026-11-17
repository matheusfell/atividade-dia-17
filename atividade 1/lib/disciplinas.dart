import 'package:flutter/material.dart';

class Disciplinas extends StatelessWidget {
  const Disciplinas({super.key, required this.nomes});

  final List<String> nomes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Disciplinas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final nome in nomes)
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(nome),
          ),
      ],
    );
  }
}
