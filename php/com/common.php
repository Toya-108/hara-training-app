<?php
if (session_status() === PHP_SESSION_NONE) {
    session_name('php_study_app');
    session_start();
}

mb_internal_encoding('UTF-8');

$GLOBALS['app'] = [
    'name' => 'PHP Study App',

    // Dockerローカル環境では http://localhost:8080/ がルートなので空文字
    'asset_url' => '',

    // docker-compose の db サービスへ接続する
    'db_host' => 'db',
    'db_port' => '3306',
    'db_name' => 'sample',
    'db_user' => 'app',
    'db_password' => 'apppass',
    'db_charset' => 'utf8mb4',

    'log_file' => __DIR__ . '/../logs/php_study_app.log'
];

function h($text)
{
    return htmlspecialchars((string)$text, ENT_QUOTES, 'UTF-8');
}

function write_app_log($message)
{
    $app = $GLOBALS['app'];
    $date_time = date('Y-m-d H:i:s');
    $log_text = '[' . $date_time . '] ' . $message . PHP_EOL;
    error_log($log_text, 3, $app['log_file']);
}