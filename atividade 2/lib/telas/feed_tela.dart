import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import '../widgets/postagem_card.dart';

class FeedTela extends StatefulWidget {
  const FeedTela({super.key, required this.usuario, this.autorId});

  final Usuario usuario;
  final int? autorId;

  @override
  State<FeedTela> createState() => _FeedTelaState();
}

class _FeedTelaState extends State<FeedTela> {
  List<Postagem> _postagens = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final lista = await Api.postagens(widget.usuario.id, autorId: widget.autorId);
      if (!mounted) return;
      setState(() {
        _postagens = lista;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _carregar,
      child: _erro != null
          ? ListView(children: [MensagemVazia(icone: Icons.cloud_off, texto: _erro!)])
          : _postagens.isEmpty
              ? ListView(
                  children: const [
                    MensagemVazia(icone: Icons.chat_bubble_outline, texto: 'Nenhuma postagem ainda'),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: _postagens.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) => PostagemCard(
                    usuario: widget.usuario,
                    postagem: _postagens[i],
                    aoMudarAmizade: _carregar,
                  ),
                ),
    );
  }
}

class MensagemVazia extends StatelessWidget {
  const MensagemVazia({super.key, required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Icon(icone, size: 56, color: cor),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center, style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}
