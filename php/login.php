<?php
require_once __DIR__ . '/com/common.php';
$app = $GLOBALS['app'];
?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ログイン</title>

    <?php require_once __DIR__ . '/com/page_head.php'; ?>
</head>
<body>

<div id="login_app" class="page">

    <header class="top_header">
        <div class="logo_area">
            <img src="<?= h($app['asset_url']) ?>/image/hara-logiapp-logo.svg" alt="Hara LogiApp ロゴ">
            <div>
                <h1 class="app_name">Hara LogiApp</h1>
                <p class="app_sub_text">物流・業務管理アプリケーション</p>
            </div>
        </div>
    </header>

    <main class="center_area">
        <section class="main_box">
            <h2 class="page_title">ログイン</h2>

            <p class="page_text">
                ユーザー名とパスワードを入力して、<br>
                次の画面へ進んでください。
            </p>

            <div class="form_row">
                <label for="staff_code" class="form_label">
                    ユーザー名
                    <span class="required_mark">※必須</span>
                </label>
                <input
                    type="text"
                    id="staff_code"
                    name="staff_code"
                    class="input_text"
                    v-model="input_form.staff_code"
                    placeholder="ユーザー名"
                >
            </div>

            <div class="form_row">
                <label for="password" class="form_label">
                    パスワード
                    <span class="required_mark">※必須</span>
                </label>
                <input
                    :type="show_password_flag ? 'text' : 'password'"
                    id="password"
                    name="password"
                    class="input_text"
                    v-model="input_form.password"
                    placeholder="パスワード"
                >
            </div>

            <div class="check_row">
                <label for="show_password_check">
                    <input
                        type="checkbox"
                        id="show_password_check"
                        v-model="show_password_flag"
                    >
                    パスワードを表示
                </label>
            </div>

            <button
                type="button"
                class="main_button"
                @click="login_button_click"
                :disabled="loading_flag"
            >
                {{ loading_flag ? '処理中...' : 'ログイン' }}
            </button>
        </section>
    </main>

</div>

<?php require_once __DIR__ . '/com/page_script.php'; ?>
<script src="<?= h($app['asset_url']) ?>/js/login.js"></script>
</body>
</html>