int _int(dynamic v) => v is int ? v : int.parse(v.toString());

class Usuario {
  Usuario({required this.id, required this.nome, required this.email, this.amizade = 'nenhuma'});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: _int(json['id']),
        nome: json['nome'] as String,
        email: json['email'] as String,
        amizade: (json['amizade'] as String?) ?? 'nenhuma',
      );

  final int id;
  final String nome;
  final String email;
  String amizade;

  String get inicial => nome.isEmpty ? '?' : nome[0].toUpperCase();
}

class Postagem {
  Postagem({
    required this.id,
    required this.texto,
    required this.foto,
    required this.criadoEm,
    required this.autorId,
    required this.autorNome,
    required this.curtidas,
    required this.curti,
    required this.comentarios,
    required this.amizade,
  });

  factory Postagem.fromJson(Map<String, dynamic> json) => Postagem(
        id: _int(json['id']),
        texto: json['texto'] as String,
        foto: json['foto'] as String?,
        criadoEm: DateTime.tryParse(json['criado_em'].toString()) ?? DateTime.now(),
        autorId: _int(json['autor_id']),
        autorNome: json['autor_nome'] as String,
        curtidas: _int(json['curtidas']),
        curti: json['curti'] == true,
        comentarios: _int(json['comentarios']),
        amizade: json['amizade'] as String,
      );

  final int id;
  final String texto;
  final String? foto;
  final DateTime criadoEm;
  final int autorId;
  final String autorNome;
  int curtidas;
  bool curti;
  int comentarios;
  String amizade;

  bool get podeComentar => amizade == 'amigos' || amizade == 'eu';
}

class Comentario {
  Comentario({required this.id, required this.texto, required this.autorNome, required this.criadoEm});

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
        id: _int(json['id']),
        texto: json['texto'] as String,
        autorNome: json['autor_nome'] as String,
        criadoEm: DateTime.tryParse(json['criado_em'].toString()) ?? DateTime.now(),
      );

  final int id;
  final String texto;
  final String autorNome;
  final DateTime criadoEm;
}

class Solicitacao {
  Solicitacao({required this.id, required this.usuarioId, required this.nome, required this.email});

  factory Solicitacao.fromJson(Map<String, dynamic> json) => Solicitacao(
        id: _int(json['id']),
        usuarioId: _int(json['usuario_id']),
        nome: json['nome'] as String,
        email: json['email'] as String,
      );

  final int id;
  final int usuarioId;
  final String nome;
  final String email;
}

String tempoRelativo(DateTime data) {
  final diferenca = DateTime.now().difference(data);
  if (diferenca.inMinutes < 1) return 'agora';
  if (diferenca.inHours < 1) return '${diferenca.inMinutes} min';
  if (diferenca.inDays < 1) return '${diferenca.inHours} h';
  if (diferenca.inDays < 7) return '${diferenca.inDays} d';
  final d = data.day.toString().padLeft(2, '0');
  final m = data.month.toString().padLeft(2, '0');
  return '$d/$m/${data.year}';
}
