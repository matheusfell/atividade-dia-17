<?php

$caminho = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if (str_starts_with($caminho, '/uploads/')) {
    $arquivo = __DIR__ . '/uploads/' . basename($caminho);
    if (!is_file($arquivo)) {
        http_response_code(404);
        exit;
    }
    header('Access-Control-Allow-Origin: *');
    header('Content-Type: ' . (new finfo(FILEINFO_MIME_TYPE))->file($arquivo));
    readfile($arquivo);
    exit;
}

require __DIR__ . '/api.php';
