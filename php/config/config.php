<?php

return [
    'name' => 'Hara',
    'page_encoding' => 'UTF-8',

    'session' => [
        'name' => 'HARA_SESSION',
        'lifetime' => 60 * 60 * 24 * 365,
    ],

    'database' => [
        'host' => 'localhost',
        'port' => 3306,
        'dbname' => 'haradb',
        'username' => 'hara',
        'password' => 'haraApp1392#',
        'charset' => 'utf8mb4',
    ],

    'path_delimiter' => '/',
    'server_address' => 'https://tudmweb3.bestcloud.jp',
    'asset_url' => 'https://tudmweb3.bestcloud.jp/training/hara/php',
    'syslog_path' => '/opt/ColdFusion/cfusion/logs/',
];