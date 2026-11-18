import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import 'feed_tela.dart';

class ComentariosTela extends StatefulWidget {
  const ComentariosTela({super.key, required this.usuario, required this.postagem});

  final Usuario usuario;
  final Postagem postagem;

  @override
  State<ComentariosTela> createState() => _ComentariosTelaState();
}

class _ComentariosTelaState extends State<ComentariosTela> {
  final _texto = TextEditingController();
  List<Comentario> _comentarios = [];
  bool _carregando = true;
  bool _enviando = false;

  Postagem get p => widget.postagem;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final lista = await Api.comentarios(p.id);
      if (!mounted) return;
      setState(() {
        _comentarios = lista;
        p.comentarios = lista.length;
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

  Future<void> _comentar() async {
    final texto = _texto.text.trim();
    if (_enviando || texto.isEmpty) return;
    setState(() => _enviando = true);
    try {
      await Api.comentar(widget.usuario.id, p.id, texto);
      if (!mounted) return;
      if (_texto.text.trim() == texto) _texto.clear();
      await _carregar();
    } on ApiException catch (e) {
      _aviso(e.mensagem);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: cores.surfaceVariant.withOpacity(0.5),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.autorNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.texto),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _comentarios.isEmpty
                    ? const SingleChildScrollView(
                        child: MensagemVazia(icone: Icons.forum_outlined, texto: 'Nenhum comentário ainda'),
                      )
                    : ListView.separated(
                        itemCount: _comentarios.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = _comentarios[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(c.autorNome.isEmpty ? '?' : c.autorNome[0].toUpperCase())),
                            title: Text(c.autorNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(c.texto),
                            trailing: Text(tempoRelativo(c.criadoEm)),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: p.podeComentar
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _texto,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _comentar(),
                            decoration: const InputDecoration(
                              hintText: 'Escreva um comentário',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _enviando ? null : _comentar,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    )
                  : ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text('Somente amigos de ${p.autorNome} podem comentar'),
                      subtitle: const Text('Envie uma solicitação de amizade pela postagem'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
