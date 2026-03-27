<?php
// ==========================================================
// login_api.php
// ==========================================================
// ログイン処理API
// ==========================================================

require_once __DIR__ . '/../com/common.php';
require_once __DIR__ . '/../com/database.php';

// JSONで返す設定
header('Content-Type: application/json');

// 戻り値
$result = [
    'status' => 0,
    'message' => ''
];

// POST取得
$staff_code = $_POST['staff_code'] ?? '';
$password   = $_POST['password'] ?? '';

// トリム
$staff_code = trim($staff_code);
$password   = trim($password);

// ------------------------------
// 必須チェック
// ------------------------------
if ($staff_code === '') {
    $result['message'] = 'ユーザー名を入力してください';
    echo json_encode($result);
    exit;
}

if ($password === '') {
    $result['message'] = 'パスワードを入力してください';
    echo json_encode($result);
    exit;
}

// ------------------------------
// DB処理
// ------------------------------
try {
    $db = get_database_connection();

    $sql = "
        SELECT
            staff_code,
            staff_name,
            login_password_hash,
            authority_level,
            use_flag
        FROM m_staff
        WHERE staff_code = :staff_code
    ";

    $stmt = $db->prepare($sql);
    $stmt->bindValue(':staff_code', $staff_code);
    $stmt->execute();

    $user = $stmt->fetch();

} catch (Exception $e) {
    $result['message'] = 'ログイン処理中にエラーが発生しました';
    echo json_encode($result);
    exit;
}

// ------------------------------
// ユーザーなし
// ------------------------------
if (!$user) {
    $result['message'] = 'ユーザー名またはパスワードが違います';
    echo json_encode($result);
    exit;
}

// ------------------------------
// 使用不可
// ------------------------------
if ($user['use_flag'] != 1) {
    $result['message'] = 'このユーザーは使用できません';
    echo json_encode($result);
    exit;
}

// ------------------------------
// パスワードチェック
// ------------------------------
if ($user['login_password_hash'] !== hash('sha256', $password)) {
    $result['message'] = 'ユーザー名またはパスワードが違います';
    echo json_encode($result);
    exit;
}

// ------------------------------
// セッション保存
// ------------------------------
$_SESSION['is_logged_in'] = true;
$_SESSION['staff_code']   = $user['staff_code'];
$_SESSION['staff_name']   = $user['staff_name'];
$_SESSION['authority']    = $user['authority_level'];

// 成功
$result['status'] = 1;
$result['message'] = 'ログイン成功';

echo json_encode($result);