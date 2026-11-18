<?php

require __DIR__ . '/config.php';

$dados = entrada();
$acao = $dados['acao'] ?? '';
$db = conexao();

try {
    switch ($acao) {
        case 'cadastro':
            exigir($dados, ['nome', 'email', 'senha']);
            $email = strtolower(trim($dados['email']));
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                erro('E-mail inválido');
            }
            if (strlen($dados['senha']) < 4) {
                erro('A senha deve ter pelo menos 4 caracteres');
            }
            $stmt = $db->prepare('SELECT 1 FROM usuarios WHERE email = ?');
            $stmt->execute([$email]);
            if ($stmt->fetchColumn()) {
                erro('E-mail já cadastrado', 409);
            }
            $stmt = $db->prepare('INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)');
            $stmt->execute([trim($dados['nome']), $email, password_hash($dados['senha'], PASSWORD_DEFAULT)]);
            responder(['ok' => true, 'usuario' => [
                'id' => (int) $db->lastInsertId(),
                'nome' => trim($dados['nome']),
                'email' => $email,
            ]]);

        case 'login':
            exigir($dados, ['email', 'senha']);
            $stmt = $db->prepare('SELECT id, nome, email, senha FROM usuarios WHERE email = ?');
            $stmt->execute([strtolower(trim($dados['email']))]);
            $usuario = $stmt->fetch();
            if (!$usuario || !password_verify($dados['senha'], $usuario['senha'])) {
                erro('E-mail ou senha incorretos', 401);
            }
            unset($usuario['senha']);
            $usuario['id'] = (int) $usuario['id'];
            responder(['ok' => true, 'usuario' => $usuario]);

        case 'postar':
            exigir($dados, ['usuario_id', 'texto']);
            $usuarioId = (int) $dados['usuario_id'];
            if (!usuarioExiste($usuarioId)) {
                erro('Usuário não encontrado', 404);
            }
            $foto = null;
            if (!empty($dados['foto_base64'])) {
                $binario = base64_decode($dados['foto_base64'], true);
                if ($binario === false) {
                    erro('Foto inválida');
                }
                $tipo = (new finfo(FILEINFO_MIME_TYPE))->buffer($binario);
                $extensoes = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/gif' => 'gif', 'image/webp' => 'webp'];
                if (!isset($extensoes[$tipo])) {
                    erro('Formato de imagem não suportado');
                }
                $pasta = __DIR__ . '/uploads';
                if (!is_dir($pasta)) {
                    mkdir($pasta, 0777, true);
                }
                $foto = 'uploads/' . bin2hex(random_bytes(12)) . '.' . $extensoes[$tipo];
                file_put_contents(__DIR__ . '/' . $foto, $binario);
            }
            $stmt = $db->prepare('INSERT INTO postagens (usuario_id, texto, foto) VALUES (?, ?, ?)');
            $stmt->execute([$usuarioId, trim($dados['texto']), $foto]);
            responder(['ok' => true, 'id' => (int) $db->lastInsertId()]);

        case 'postagens':
            exigir($dados, ['usuario_id']);
            $eu = (int) $dados['usuario_id'];
            $busca = trim($dados['busca'] ?? '');
            $autor = isset($dados['autor_id']) ? (int) $dados['autor_id'] : 0;
            $sql = 'SELECT p.id, p.texto, p.foto, p.criado_em, u.id AS autor_id, u.nome AS autor_nome,
                    (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id) AS curtidas,
                    (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id AND c.usuario_id = ?) AS curti,
                    (SELECT COUNT(*) FROM comentarios m WHERE m.postagem_id = p.id) AS comentarios
                    FROM postagens p JOIN usuarios u ON u.id = p.usuario_id WHERE 1 = 1';
            $params = [$eu];
            if ($busca !== '') {
                foreach (preg_split('/\s+/', $busca) as $palavra) {
                    $sql .= ' AND p.texto LIKE ?';
                    $params[] = '%' . $palavra . '%';
                }
            }
            if ($autor > 0) {
                $sql .= ' AND p.usuario_id = ?';
                $params[] = $autor;
            }
            $sql .= ' ORDER BY p.id DESC LIMIT 200';
            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $lista = [];
            foreach ($stmt->fetchAll() as $p) {
                $autorId = (int) $p['autor_id'];
                $lista[] = [
                    'id' => (int) $p['id'],
                    'texto' => $p['texto'],
                    'foto' => $p['foto'],
                    'criado_em' => $p['criado_em'],
                    'autor_id' => $autorId,
                    'autor_nome' => $p['autor_nome'],
                    'curtidas' => (int) $p['curtidas'],
                    'curti' => (int) $p['curti'] > 0,
                    'comentarios' => (int) $p['comentarios'],
                    'amizade' => statusAmizade($eu, $autorId),
                ];
            }
            responder(['ok' => true, 'postagens' => $lista]);

        case 'curtir':
            exigir($dados, ['usuario_id', 'postagem_id']);
            $usuarioId = (int) $dados['usuario_id'];
            $postagemId = (int) $dados['postagem_id'];
            $stmt = $db->prepare('SELECT 1 FROM curtidas WHERE usuario_id = ? AND postagem_id = ?');
            $stmt->execute([$usuarioId, $postagemId]);
            if ($stmt->fetchColumn()) {
                $db->prepare('DELETE FROM curtidas WHERE usuario_id = ? AND postagem_id = ?')->execute([$usuarioId, $postagemId]);
                $curti = false;
            } else {
                $db->prepare('INSERT INTO curtidas (usuario_id, postagem_id) VALUES (?, ?)')->execute([$usuarioId, $postagemId]);
                $curti = true;
            }
            $stmt = $db->prepare('SELECT COUNT(*) FROM curtidas WHERE postagem_id = ?');
            $stmt->execute([$postagemId]);
            responder(['ok' => true, 'curti' => $curti, 'curtidas' => (int) $stmt->fetchColumn()]);

        case 'comentarios':
            exigir($dados, ['postagem_id']);
            $stmt = $db->prepare(
                'SELECT m.id, m.texto, m.criado_em, u.id AS autor_id, u.nome AS autor_nome
                 FROM comentarios m JOIN usuarios u ON u.id = m.usuario_id
                 WHERE m.postagem_id = ? ORDER BY m.id ASC'
            );
            $stmt->execute([(int) $dados['postagem_id']]);
            responder(['ok' => true, 'comentarios' => $stmt->fetchAll()]);

        case 'comentar':
            exigir($dados, ['usuario_id', 'postagem_id', 'texto']);
            $usuarioId = (int) $dados['usuario_id'];
            $postagemId = (int) $dados['postagem_id'];
            $stmt = $db->prepare('SELECT usuario_id FROM postagens WHERE id = ?');
            $stmt->execute([$postagemId]);
            $autorId = $stmt->fetchColumn();
            if ($autorId === false) {
                erro('Postagem não encontrada', 404);
            }
            if (!saoAmigos($usuarioId, (int) $autorId)) {
                erro('Você só pode comentar em postagens de amigos', 403);
            }
            $stmt = $db->prepare('INSERT INTO comentarios (postagem_id, usuario_id, texto) VALUES (?, ?, ?)');
            $stmt->execute([$postagemId, $usuarioId, trim($dados['texto'])]);
            responder(['ok' => true, 'id' => (int) $db->lastInsertId()]);

        case 'solicitar_amizade':
            exigir($dados, ['usuario_id', 'amigo_id']);
            $eu = (int) $dados['usuario_id'];
            $outro = (int) $dados['amigo_id'];
            if ($eu === $outro) {
                erro('Você não pode adicionar a si mesmo');
            }
            if (!usuarioExiste($outro)) {
                erro('Usuário não encontrado', 404);
            }
            $status = statusAmizade($eu, $outro);
            if ($status === 'amigos') {
                erro('Vocês já são amigos', 409);
            }
            if ($status === 'enviada') {
                erro('Solicitação já enviada', 409);
            }
            if ($status === 'recebida') {
                $db->prepare(
                    "UPDATE amizades SET status = 'aceita' WHERE solicitante_id = ? AND destinatario_id = ?"
                )->execute([$outro, $eu]);
                responder(['ok' => true, 'amizade' => 'amigos']);
            }
            $db->prepare(
                "INSERT INTO amizades (solicitante_id, destinatario_id, status) VALUES (?, ?, 'pendente')
                 ON DUPLICATE KEY UPDATE status = 'pendente'"
            )->execute([$eu, $outro]);
            responder(['ok' => true, 'amizade' => 'enviada']);

        case 'solicitacoes':
            exigir($dados, ['usuario_id']);
            $stmt = $db->prepare(
                "SELECT a.id, u.id AS usuario_id, u.nome, u.email
                 FROM amizades a JOIN usuarios u ON u.id = a.solicitante_id
                 WHERE a.destinatario_id = ? AND a.status = 'pendente' ORDER BY a.id DESC"
            );
            $stmt->execute([(int) $dados['usuario_id']]);
            responder(['ok' => true, 'solicitacoes' => $stmt->fetchAll()]);

        case 'responder_amizade':
            exigir($dados, ['usuario_id', 'solicitacao_id', 'aceitar']);
            $aceitar = filter_var($dados['aceitar'], FILTER_VALIDATE_BOOLEAN);
            $stmt = $db->prepare(
                "UPDATE amizades SET status = ? WHERE id = ? AND destinatario_id = ? AND status = 'pendente'"
            );
            $stmt->execute([$aceitar ? 'aceita' : 'recusada', (int) $dados['solicitacao_id'], (int) $dados['usuario_id']]);
            if ($stmt->rowCount() === 0) {
                erro('Solicitação não encontrada', 404);
            }
            responder(['ok' => true]);

        case 'amigos':
            exigir($dados, ['usuario_id']);
            $eu = (int) $dados['usuario_id'];
            $stmt = $db->prepare(
                "SELECT u.id, u.nome, u.email FROM amizades a
                 JOIN usuarios u ON u.id = IF(a.solicitante_id = ?, a.destinatario_id, a.solicitante_id)
                 WHERE a.status = 'aceita' AND (a.solicitante_id = ? OR a.destinatario_id = ?)
                 ORDER BY u.nome"
            );
            $stmt->execute([$eu, $eu, $eu]);
            responder(['ok' => true, 'amigos' => $stmt->fetchAll()]);

        case 'buscar_usuarios':
            exigir($dados, ['usuario_id', 'nome']);
            $eu = (int) $dados['usuario_id'];
            $stmt = $db->prepare('SELECT id, nome, email FROM usuarios WHERE nome LIKE ? ORDER BY nome LIMIT 50');
            $stmt->execute(['%' . trim($dados['nome']) . '%']);
            $lista = [];
            foreach ($stmt->fetchAll() as $u) {
                $u['id'] = (int) $u['id'];
                $u['amizade'] = statusAmizade($eu, $u['id']);
                $lista[] = $u;
            }
            responder(['ok' => true, 'usuarios' => $lista]);

        default:
            responder(['ok' => true, 'app' => 'Twitter Pro 9000 API']);
    }
} catch (PDOException $e) {
    erro('Erro no banco de dados: ' . $e->getMessage(), 500);
}
