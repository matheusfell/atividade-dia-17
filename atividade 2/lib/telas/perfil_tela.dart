import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import 'feed_tela.dart';

class PerfilTela extends StatefulWidget {
  const PerfilTela({super.key, required this.usuario, required this.perfil});

  final Usuario usuario;
  final Usuario perfil;

  @override
  State<PerfilTela> createState() => _PerfilTelaState();
}

class _PerfilTelaState extends State<PerfilTela> {
  int _versao = 0;
  bool _ocupado = false;

  Future<void> _solicitar() async {
    setState(() => _ocupado = true);
    try {
      final status = await Api.solicitarAmizade(widget.usuario.id, widget.perfil.id);
      setState(() {
        widget.perfil.amizade = status;
        _versao++;
      });
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Widget _acao() {
    switch (widget.perfil.amizade) {
      case 'nenhuma':
        return FilledButton.icon(
          onPressed: _ocupado ? null : _solicitar,
          icon: const Icon(Icons.person_add),
          label: const Text('Solicitar amizade'),
        );
      case 'recebida':
        return FilledButton.icon(
          onPressed: _ocupado ? null : _solicitar,
          icon: const Icon(Icons.how_to_reg),
          label: const Text('Aceitar amizade'),
        );
      case 'enviada':
        return const OutlinedButton(onPressed: null, child: Text('Solicitação pendente'));
      case 'amigos':
        return const OutlinedButton(onPressed: null, child: Text('Vocês são amigos'));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.perfil.nome)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: cores.primaryContainer,
            child: Column(
              children: [
                CircleAvatar(radius: 36, child: Text(widget.perfil.inicial, style: const TextStyle(fontSize: 28))),
                const SizedBox(height: 8),
                Text(widget.perfil.nome, style: Theme.of(context).textTheme.titleLarge),
                Text(widget.perfil.email),
                const SizedBox(height: 12),
                _acao(),
              ],
            ),
          ),
          Expanded(
            child: FeedTela(
              key: ValueKey(_versao),
              usuario: widget.usuario,
              autorId: widget.perfil.id,
            ),
          ),
        ],
      ),
    );
  }
}
