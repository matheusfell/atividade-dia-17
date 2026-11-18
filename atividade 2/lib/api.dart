import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'modelos.dart';

class ApiException implements Exception {
  ApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class Api {
  static String get servidor {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static String urlFoto(String caminho) => '$servidor/$caminho';

  static Future<Map<String, dynamic>> _enviar(Map<String, dynamic> corpo) async {
    final http.Response resposta;
    try {
      resposta = await http
          .post(
            Uri.parse('$servidor/api.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(corpo),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor');
    }
    final Map<String, dynamic> dados;
    try {
      dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Resposta inválida do servidor');
    }
    if (dados['ok'] != true) {
      throw ApiException(dados['erro']?.toString() ?? 'Erro desconhecido');
    }
    return dados;
  }

  static Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final dados = await _enviar({'acao': 'cadastro', 'nome': nome, 'email': email, 'senha': senha});
    return Usuario.fromJson(dados['usuario']);
  }

  static Future<Usuario> login(String email, String senha) async {
    final dados = await _enviar({'acao': 'login', 'email': email, 'senha': senha});
    return Usuario.fromJson(dados['usuario']);
  }

  static Future<void> postar(int usuarioId, String texto, Uint8List? foto) async {
    await _enviar({
      'acao': 'postar',
      'usuario_id': usuarioId,
      'texto': texto,
      if (foto != null) 'foto_base64': base64Encode(foto),
    });
  }

  static Future<List<Postagem>> postagens(int usuarioId, {String busca = '', int? autorId}) async {
    final dados = await _enviar({
      'acao': 'postagens',
      'usuario_id': usuarioId,
      'busca': busca,
      if (autorId != null) 'autor_id': autorId,
    });
    return (dados['postagens'] as List).map((p) => Postagem.fromJson(p)).toList();
  }

  static Future<(bool, int)> curtir(int usuarioId, int postagemId) async {
    final dados = await _enviar({'acao': 'curtir', 'usuario_id': usuarioId, 'postagem_id': postagemId});
    return (dados['curti'] as bool, dados['curtidas'] as int);
  }

  static Future<List<Comentario>> comentarios(int postagemId) async {
    final dados = await _enviar({'acao': 'comentarios', 'postagem_id': postagemId});
    return (dados['comentarios'] as List).map((c) => Comentario.fromJson(c)).toList();
  }

  static Future<void> comentar(int usuarioId, int postagemId, String texto) async {
    await _enviar({'acao': 'comentar', 'usuario_id': usuarioId, 'postagem_id': postagemId, 'texto': texto});
  }

  static Future<String> solicitarAmizade(int usuarioId, int amigoId) async {
    final dados = await _enviar({'acao': 'solicitar_amizade', 'usuario_id': usuarioId, 'amigo_id': amigoId});
    return dados['amizade'] as String;
  }

  static Future<List<Solicitacao>> solicitacoes(int usuarioId) async {
    final dados = await _enviar({'acao': 'solicitacoes', 'usuario_id': usuarioId});
    return (dados['solicitacoes'] as List).map((s) => Solicitacao.fromJson(s)).toList();
  }

  static Future<void> responderAmizade(int usuarioId, int solicitacaoId, bool aceitar) async {
    await _enviar({
      'acao': 'responder_amizade',
      'usuario_id': usuarioId,
      'solicitacao_id': solicitacaoId,
      'aceitar': aceitar,
    });
  }

  static Future<List<Usuario>> amigos(int usuarioId) async {
    final dados = await _enviar({'acao': 'amigos', 'usuario_id': usuarioId});
    return (dados['amigos'] as List).map((u) => Usuario.fromJson(u)).toList();
  }

  static Future<List<Usuario>> buscarUsuarios(int usuarioId, String nome) async {
    final dados = await _enviar({'acao': 'buscar_usuarios', 'usuario_id': usuarioId, 'nome': nome});
    return (dados['usuarios'] as List).map((u) => Usuario.fromJson(u)).toList();
  }
}
