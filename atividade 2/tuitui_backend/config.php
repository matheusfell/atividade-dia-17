<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

const DB_HOST = '127.0.0.1';
const DB_NOME = 'twitter_pro_9000';
const DB_USUARIO = 'root';
const DB_SENHA = '';

function conexao(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $pdo = new PDO(
            'mysql:host=' . DB_HOST . ';dbname=' . DB_NOME . ';charset=utf8mb4',
            DB_USUARIO,
            DB_SENHA,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
    }
    return $pdo;
}

function entrada(): array
{
    $json = json_decode(file_get_contents('php://input'), true);
    return is_array($json) ? array_merge($_GET, $json) : array_merge($_GET, $_POST);
}

function responder($dados, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE);
    exit;
}

function erro(string $mensagem, int $status = 400): void
{
    responder(['ok' => false, 'erro' => $mensagem], $status);
}

function exigir(array $dados, array $campos): void
{
    foreach ($campos as $campo) {
        if (!isset($dados[$campo]) || trim((string) $dados[$campo]) === '') {
            erro("Campo obrigatório: $campo");
        }
    }
}

function usuarioExiste(int $id): bool
{
    $stmt = conexao()->prepare('SELECT 1 FROM usuarios WHERE id = ?');
    $stmt->execute([$id]);
    return (bool) $stmt->fetchColumn();
}

function saoAmigos(int $a, int $b): bool
{
    if ($a === $b) {
        return true;
    }
    $stmt = conexao()->prepare(
        "SELECT 1 FROM amizades WHERE status = 'aceita'
         AND ((solicitante_id = ? AND destinatario_id = ?) OR (solicitante_id = ? AND destinatario_id = ?))"
    );
    $stmt->execute([$a, $b, $b, $a]);
    return (bool) $stmt->fetchColumn();
}

function statusAmizade(int $eu, int $outro): string
{
    if ($eu === $outro) {
        return 'eu';
    }
    $stmt = conexao()->prepare(
        'SELECT solicitante_id, status FROM amizades
         WHERE (solicitante_id = ? AND destinatario_id = ?) OR (solicitante_id = ? AND destinatario_id = ?)
         ORDER BY id DESC LIMIT 1'
    );
    $stmt->execute([$eu, $outro, $outro, $eu]);
    $linha = $stmt->fetch();
    if (!$linha || $linha['status'] === 'recusada') {
        return 'nenhuma';
    }
    if ($linha['status'] === 'aceita') {
        return 'amigos';
    }
    return (int) $linha['solicitante_id'] === $eu ? 'enviada' : 'recebida';
}
