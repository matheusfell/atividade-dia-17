import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api.dart';
import '../modelos.dart';

class NovaPostagemTela extends StatefulWidget {
  const NovaPostagemTela({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<NovaPostagemTela> createState() => _NovaPostagemTelaState();
}

class _NovaPostagemTelaState extends State<NovaPostagemTela> {
  static const _limite = 280;
  final _texto = TextEditingController();
  Uint8List? _foto;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto(ImageSource origem) async {
    try {
      final arquivo = await ImagePicker().pickImage(source: origem, maxWidth: 1280, imageQuality: 80);
      if (arquivo == null) return;
      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() => _foto = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a imagem')),
      );
    }
  }

  Future<void> _publicar() async {
    setState(() => _enviando = true);
    try {
      await Api.postar(widget.usuario.id, _texto.text.trim(), _foto);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = _texto.text.trim().length;
    final valido = tamanho > 0 && tamanho <= _limite;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova postagem'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: valido && !_enviando ? _publicar : null,
              child: _enviando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Postar'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Text(widget.usuario.inicial)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _texto,
                  autofocus: true,
                  maxLines: null,
                  minLines: 4,
                  maxLength: _limite,
                  decoration: const InputDecoration(
                    hintText: 'O que está acontecendo?',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          if (_foto != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_foto!, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: () => setState(() => _foto = null),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _escolherFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text('Galeria'),
              ),
              OutlinedButton.icon(
                onPressed: () => _escolherFoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Câmera'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
