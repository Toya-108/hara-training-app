<?php
require_once __DIR__ . '/com/common.php';
$app = $GLOBALS['app'];

echo '<pre>';
print_r($app);
echo '</pre>';
exit;
?>
<!DOCTYPE html>
<html lang="ja">
    
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ログイン</title>

    <link rel="icon" href="<?= htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') ?>/image/hara-logiapp-logo.ico">
    <link rel="stylesheet" href="<?= htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') ?>/css/style.css">    
    
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Yu Gothic", sans-serif;
            background-color: #F7F1E3;
            color: #2F2A24;
        }

        .page {
            min-height: 100vh;
            padding: 24px;
        }

        .header {
            margin-bottom: 40px;
        }

        .logo-area {
            display: flex;
        }

        .logo-area img {
            width: 56px;
            height: 56px;
            margin-right: 12px;
        }

        .app-name {
            margin: 0;
            font-size: 24px;
            color: #2E4136;
        }

        .app-text {
            margin: 4px 0 0 0;
            font-size: 13px;
            color: #645B50;
        }

        .main {
            text-align: center;
        }

        .login-box {
            width: 100%;
            max-width: 420px;
            margin: 0 auto;
            padding: 30px 24px;
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 12px;
            text-align: left;
        }

        .login-title {
            margin: 0 0 8px 0;
            font-size: 28px;
            text-align: center;
            color: #2E4136;
        }

        .login-text {
            margin: 0 0 24px 0;
            font-size: 14px;
            line-height: 1.6;
            text-align: center;
            color: #645B50;
        }

        .row {
            margin-bottom: 18px;
        }

        .row label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
            color: #2E4136;
        }

        .required {
            font-size: 12px;
            color: #B84A4A;
            margin-left: 6px;
        }

        .input-text {
            width: 100%;
            height: 44px;
            padding: 0 12px;
            font-size: 15px;
            border: 1px solid #CDBFA8;
            border-radius: 8px;
            background-color: #FFFFFF;
        }

        .input-text.is-error {
            border-color: #B84A4A;
            background-color: #FFF8F8;
        }

        .field-error {
            display: none;
            margin-top: 6px;
            font-size: 12px;
            color: #B84A4A;
        }

        .field-error.is-visible {
            display: block;
        }

        .check-row {
            margin-bottom: 20px;
            font-size: 14px;
            color: #645B50;
        }

        .message {
            display: none;
            margin-bottom: 18px;
            padding: 10px;
            font-size: 13px;
            color: #B84A4A;
            background-color: #FFF3F3;
            border: 1px solid #E8B9B9;
            border-radius: 8px;
        }

        .message.is-visible {
            display: block;
        }

        .login-button {
            width: 100%;
            height: 46px;
            border: none;
            border-radius: 8px;
            background-color: #3F5B4B;
            color: #FFFFFF;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <?php
echo '<pre>';
echo htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') . "\n";
echo htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') . '/image/hara-logiapp-logo.ico' . "\n";
echo htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') . '/css/style.css' . "\n";
echo '</pre>';
?>
    <div class="page">

        <header class="header">
            <div class="logo-area">
                <img src="<?= htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') ?>/image/hara-logiapp-logo.svg" alt="Hara LogiApp ロゴ">
                <div>
                    <h1 class="app-name">Hara LogiApp</h1>
                    <p class="app-text">物流・業務管理アプリケーション</p>
                </div>
            </div>
        </header>

        <div id="form_message" class="message" aria-live="polite"></div>

        <main class="main">
            <section class="login-box">
                <h2 class="login-title">ログイン</h2>
                <p class="login-text">
                    ユーザー名とパスワードを入力して、<br>
                    次の画面へ進んでください。
                </p>

                <form id="login_form" novalidate>
                    <div class="row">
                        <label for="staff_code">
                            ユーザー名
                            <span class="required">※必須</span>
                        </label>
                        <input
                            type="text"
                            id="staff_code"
                            name="staff_code"
                            class="input-text js-required"
                            data-label="ユーザー名"
                            autocomplete="username"
                            maxlength="20"
                        >
                        <div class="field-error" data-for="staff_code"></div>
                    </div>

                    <div class="row">
                        <label for="password">
                            パスワード
                            <span class="required">※必須</span>
                        </label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            class="input-text js-required"
                            data-label="パスワード"
                            autocomplete="current-password"
                            maxlength="100"
                        >
                        <div class="field-error" data-for="password"></div>
                    </div>

                    <div class="check-row">
                        <label for="toggle_password">
                            <input type="checkbox" id="toggle_password">
                            パスワードを表示
                        </label>
                    </div>

                    <button type="submit" id="login_button" class="login-button">
                        ログイン
                    </button>
                </form>
            </section>
        </main>
    </div>

    <script src="<?= htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') ?>/js/validation-common.js"></script>
    <script src="<?= htmlspecialchars($app['asset_url'], ENT_QUOTES, 'UTF-8') ?>/js/login.js?20260319_1"></script>
</body>
</html>