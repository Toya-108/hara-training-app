<?php
require_once __DIR__ . '/com/common.php';
require_once __DIR__ . '/com/database.php';

try {
    $db = get_database_connection();
    echo "DB接続成功";
} catch (Exception $e) {
    echo "失敗: " . $e->getMessage();
}