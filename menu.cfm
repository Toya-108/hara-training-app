<cfinclude template="init.cfm">

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
    </cfoutput>

    <title>メニュー</title>

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
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 48px;
        }

        .logo-area {
            display: flex;
            align-items: center;
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

        .user-area {
            position: relative;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 14px;
            border-radius: 999px;
            background-color: #F5EEDC;
            border: 1px solid #E0D5C3;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
        }

        .staff-name {
            font-size: 14px;
            font-weight: bold;
            color: #2E4136;
            line-height: 1;
        }

        .detail-button {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            padding: 0;
            border: none;
            border-radius: 999px;
            background-color: transparent;
            cursor: pointer;
            flex-shrink: 0;
        }

        .detail-button:hover {
            background-color: rgba(63, 91, 75, 0.08);
        }

        .detail-button img {
            width: 30px;
            height: 30px;
            display: block;
        }

        .user-menu {
            display: none;
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            width: 160px;
            padding: 8px;
            background-color: #FFFFFF;
            border: 1px solid #E0D5C3;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            opacity: 0;
            transform: translateY(-8px);
            transition: all 0.2s ease;
            z-index: 10;
        }

        .user-menu.is-open {
            display: block;
            opacity: 1;
            transform: translateY(0);
        }

        .logout-button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 8px;
            background-color: transparent;
            color: #2E4136;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-align: left;
            transition: all 0.15s ease;
        }

        .logout-button:hover {
            background-color: #F5EEDC;
            color: #1E2F26;
        }

        .main {
            max-width: 900px;
            margin: 0 auto;
        }

        .menu-grid {
            display: flex;
            justify-content: center;
            gap: 24px;
            flex-wrap: wrap;
        }

        .menu-button {
            width: 300px;
            height: 220px;
            border: none;
            border-radius: 16px;
            background-color: #3F5B4B;
            color: #FFFFFF;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
            transition: opacity 0.15s ease;
        }

        .menu-button:hover {
            opacity: 0.9;
        }

        .menu-icon {
            width: 72px;
            height: 72px;
            margin-bottom: 16px;
        }

        .menu-button.disabled-button {
            opacity: 0.55 !important;
            cursor: not-allowed;
        }

        .menu-button.disabled-button:hover {
            opacity: 0.55 !important;
        }

        .menu-text {
            font-size: 28px;
            font-weight: bold;
            line-height: 1.2;
        }

        .modal-bg {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.35);
        }

        .modal-bg.is-open {
            display: block;
        }

        .modal-box {
            width: 90%;
            max-width: 420px;
            margin: 120px auto 0 auto;
            padding: 24px;
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 12px;
        }

        .modal-title {
            margin: 0 0 20px 0;
            font-size: 22px;
            color: #2E4136;
            text-align: center;
        }

        .master-button {
            width: 100%;
            margin-bottom: 12px;
            padding: 14px;
            border: none;
            border-radius: 8px;
            background-color: #3F5B4B;
            color: #FFFFFF;
            font-size: 16px;
            cursor: pointer;
        }

        .close-button {
            width: 100%;
            padding: 12px;
            border: 1px solid #CDBFA8;
            border-radius: 8px;
            background-color: #FFFFFF;
            color: #2F2A24;
            font-size: 14px;
            cursor: pointer;
        }

        @media (max-width: 640px) {
            .page {
                padding: 16px;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }

            .user-area {
                align-self: flex-end;
            }

            .menu-button {
                width: 100%;
                max-width: 320px;
                height: 180px;
            }

            .menu-icon {
                width: 60px;
                height: 60px;
            }

            .menu-text {
                font-size: 24px;
            }
        }
    </style>
</head>

<cfoutput>
    <body>
        <div class="page">

            <header class="header">
                <div class="logo-area">
                    <img src="#Application.asset_url#/image/hara-logiapp-logo.svg" alt="Hara LogiApp ロゴ">
                    <div>
                        <h1 class="app-name">Hara LogiApp</h1>
                        <p class="app-text">物流・業務管理アプリケーション</p>
                    </div>
                </div>

                <div class="user-area">
                    <div class="staff-name">
                        #session.staffName#
                    </div>

                    <button type="button" class="detail-button" id="detail_button">
                        <img
                            src="#Application.asset_url#/image/arrow-down-icon.svg"
                            data-down="#Application.asset_url#/image/arrow-down-icon.svg"
                            data-up="#Application.asset_url#/image/arrow-up-icon.svg"
                            class="arrow-icon arrow-down-icon"
                            alt="メニュー開閉">
                    </button>

                    <div class="user-menu" id="user_menu">
                        <button type="button" class="logout-button" id="logout-button">
                            ログアウト
                        </button>
                    </div>
                </div>
            </header>

            <main class="main">
                <div class="menu-grid">
                    <button type="button" class="menu-button" id="add_slip_button">
                        <img src="#Application.asset_url#/image/slip-entry-icon.svg" alt="伝票登録" class="menu-icon">
                        <span class="menu-text">伝票登録</span>
                    </button>

                    <button type="button" class="menu-button" id="slip_list_button">
                        <img src="#Application.asset_url#/image/slip-list-icon.svg" alt="伝票一覧" class="menu-icon">
                        <span class="menu-text">伝票一覧</span>
                    </button>

                    <cfset disabled_btn = "">

                    <cfif session.authorityLevel eq 1>
                        <cfset disabled_btn = "disabled-button">
                    </cfif>

                    <button type="button" class="menu-button #disabled_btn#" id="master_button">
                        <img src="#Application.asset_url#/image/master-icon.svg" alt="マスタ" class="menu-icon">
                        <span class="menu-text">マスタ</span>
                    </button>
                </div>
            </main>

            <div class="modal-bg" id="master_modal">
                <div class="modal-box">
                    <h3 class="modal-title">マスタ選択</h3>

                    <button type="button" class="master-button" id="item-master-button">
                        商品マスタ
                    </button>
                    <button type="button" class="master-button" id="supplier-master-button">
                        取引先マスタ
                    </button>
                    <button type="button" class="master-button" id="staff-master-button">
                        社員マスタ
                    </button>

                    <button type="button" class="close-button" id="close_modal_button">
                        閉じる
                    </button>
                </div>
            </div>
        </div>

        <script src="#application.asset_url#/js/menu.js?20260326_1"></script>
    </body>
</cfoutput>
</html>