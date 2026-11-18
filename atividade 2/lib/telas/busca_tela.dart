import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import '../widgets/postagem_card.dart';
import 'feed_tela.dart';
import 'perfil_tela.dart';

class BuscaTela extends StatefulWidget {
  const BuscaTela({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<BuscaTela> createState() => _BuscaTelaState();
}

class _BuscaTelaState extends State<BuscaTela> {
  final _termo = TextEditingController();
  bool _pessoas = true;
  bool _carregando = false;
  bool _buscou = false;
  List<Usuario> _usuarios = [];
  List<Postagem> _postagens = [];

  @override
  void dispose() {
    _termo.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final termo = _termo.text.trim();
    if (termo.isEmpty) return;
    setState(() => _carregando = true);
    try {
      if (_pessoas) {
        _usuarios = await Api.buscarUsuarios(widget.usuario.id, termo);
      } else {
        _postagens = await Api.postagens(widget.usuario.id, busca: termo);
      }
      _buscou = true;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _resultados() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (!_buscou) {
      return MensagemVazia(
        icone: Icons.search,
        texto: _pessoas ? 'Busque pessoas pelo nome' : 'Busque postagens por palavras',
      );
    }
    if (_pessoas) {
      if (_usuarios.isEmpty) return const MensagemVazia(icone: Icons.person_off, texto: 'Ninguém encontrado');
      return ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (_, i) {
          final u = _usuarios[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.inicial)),
            title: Text(u.nome),
            subtitle: Text(u.email),
            trailing: Text(_rotuloAmizade(u.amizade)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PerfilTela(usuario: widget.usuario, perfil: u)),
            ),
          );
        },
      );
    }
    if (_postagens.isEmpty) return const MensagemVazia(icone: Icons.search_off, texto: 'Nenhuma postagem encontrada');
    return ListView.separated(
      itemCount: _postagens.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => PostagemCard(usuario: widget.usuario, postagem: _postagens[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _termo,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            decoration: InputDecoration(
              hintText: _pessoas ? 'Nome da pessoa' : 'Palavras da postagem',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _buscar),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
            ),
          ),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, icon: Icon(Icons.person), label: Text('Pessoas')),
            ButtonSegment(value: false, icon: Icon(Icons.article), label: Text('Postagens')),
          ],
          selected: {_pessoas},
          onSelectionChanged: (s) {
            setState(() {
              _pessoas = s.first;
              _buscou = false;
            });
            _buscar();
          },
        ),
        const SizedBox(height: 8),
        Expanded(child: _resultados()),
      ],
    );
  }
}

String _rotuloAmizade(String status) {
  switch (status) {
    case 'amigos':
      return 'Amigos';
    case 'enviada':
      return 'Pendente';
    case 'recebida':
      return 'Quer ser seu amigo';
    case 'eu':
      return 'Você';
    default:
      return '';
  }
}
