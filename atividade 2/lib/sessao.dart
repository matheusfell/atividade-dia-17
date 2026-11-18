import 'package:shared_preferences/shared_preferences.dart';

import 'modelos.dart';

class Sessao {
  static const _id = 'usuario_id';
  static const _nome = 'usuario_nome';
  static const _email = 'usuario_email';

  static Future<void> salvar(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_id, usuario.id);
    await prefs.setString(_nome, usuario.nome);
    await prefs.setString(_email, usuario.email);
  }

  static Future<Usuario?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_id);
    final nome = prefs.getString(_nome);
    final email = prefs.getString(_email);
    if (id == null || nome == null || email == null) return null;
    return Usuario(id: id, nome: nome, email: email);
  }

  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_id);
    await prefs.remove(_nome);
    await prefs.remove(_email);
  }
}
