<?php

$config = require __DIR__ . '/../config/config.php';

// 文字コード
mb_internal_encoding($config['page_encoding']);
mb_http_output($config['page_encoding']);

// タイムゾーン
date_default_timezone_set('Asia/Tokyo');

// セッション設定
session_name($config['session']['name']);
session_set_cookie_params([
    'lifetime' => $config['session']['lifetime'],
    'path' => '/',
    'httponly' => true,
    'secure' => true,
    'samesite' => 'Lax',
]);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// アプリ共通値
$GLOBALS['app'] = $config;

function db(): PDO
{
    static $pdo = null;

    if ($pdo === null) {
        $config = $GLOBALS['app']['database'];

        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            $config['host'],
            $config['port'],
            $config['dbname'],
            $config['charset']
        );

        $pdo = new PDO(
            $dsn,
            $config['username'],
            $config['password'],
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
    }

    return $pdo;
}