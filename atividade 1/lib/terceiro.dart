import 'package:flutter/material.dart';

import 'disciplinas.dart';

class Terceiro extends StatelessWidget {
  const Terceiro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Disciplinas(
      nomes: [
        'Desenvolvimento Mobile com Flutter',
        'Engenharia de Software',
        'Desenvolvimento Web',
        'Projeto Integrador',
      ],
    );
  }
}
