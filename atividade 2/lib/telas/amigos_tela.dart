import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import 'feed_tela.dart';
import 'perfil_tela.dart';

class AmigosTela extends StatefulWidget {
  const AmigosTela({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<AmigosTela> createState() => _AmigosTelaState();
}

class _AmigosTelaState extends State<AmigosTela> {
  List<Solicitacao> _solicitacoes = [];
  List<Usuario> _amigos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final resultados = await Future.wait([
        Api.solicitacoes(widget.usuario.id),
        Api.amigos(widget.usuario.id),
      ]);
      if (!mounted) return;
      setState(() {
        _solicitacoes = resultados[0] as List<Solicitacao>;
        _amigos = resultados[1] as List<Usuario>;
      });
    } on ApiException catch (e) {
      _aviso(e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _responder(Solicitacao s, bool aceitar) async {
    try {
      await Api.responderAmizade(widget.usuario.id, s.id, aceitar);
      _aviso(aceitar ? 'Você e ${s.nome} agora são amigos' : 'Solicitação recusada');
      await _carregar();
    } on ApiException catch (e) {
      _aviso(e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    final titulo = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Solicitações de amizade (${_solicitacoes.length})', style: titulo),
          ),
          if (_solicitacoes.isEmpty)
            const ListTile(title: Text('Nenhuma solicitação pendente'))
          else
            for (final s in _solicitacoes)
              ListTile(
                leading: CircleAvatar(child: Text(s.nome[0].toUpperCase())),
                title: Text(s.nome),
                subtitle: Text(s.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Recusar',
                      onPressed: () => _responder(s, false),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                    IconButton(
                      tooltip: 'Aceitar',
                      onPressed: () => _responder(s, true),
                      icon: const Icon(Icons.check, color: Colors.green),
                    ),
                  ],
                ),
              ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Meus amigos (${_amigos.length})', style: titulo),
          ),
          if (_amigos.isEmpty)
            const MensagemVazia(
              icone: Icons.people_outline,
              texto: 'Você ainda não tem amigos. Solicite amizade a partir de uma postagem ou da busca.',
            )
          else
            for (final u in _amigos)
              ListTile(
                leading: CircleAvatar(child: Text(u.inicial)),
                title: Text(u.nome),
                subtitle: Text(u.email),
                onTap: () {
                  u.amizade = 'amigos';
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PerfilTela(usuario: widget.usuario, perfil: u)),
                  );
                },
              ),
        ],
      ),
    );
  }
}
