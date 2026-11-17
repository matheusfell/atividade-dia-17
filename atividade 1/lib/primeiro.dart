import 'package:flutter/material.dart';

import 'disciplinas.dart';

class Primeiro extends StatelessWidget {
  const Primeiro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Disciplinas(
      nomes: [
        'Lógica de Programação',
        'Fundamentos de Computação',
        'Matemática Aplicada',
        'Introdução à Web',
      ],
    );
  }
}
