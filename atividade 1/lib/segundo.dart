import 'package:flutter/material.dart';

import 'disciplinas.dart';

class Segundo extends StatelessWidget {
  const Segundo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Disciplinas(
      nomes: [
        'Programação Orientada a Objetos',
        'Banco de Dados',
        'Estruturas de Dados',
        'Redes de Computadores',
      ],
    );
  }
}
