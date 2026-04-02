<cfinclude template="init.cfm">

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
    </cfoutput>

    <title>メニュー</title>

    <style>
        * {
            box-sizing: border-box;
        }

        .page {
            min-height: 100vh;
            padding: 24px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
            flex-direction: row;
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
            margin-left: auto;
            height: 56px;
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
            width: 140px;
            padding: 6px;
            background-color: #F5EEDC;
            border: 1px solid #E0D5C3;
            border-radius: 14px;
            box-shadow: 0 8px 20px rgba(46, 65, 54, 0.10);
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
            padding: 12px 14px;
            border: none;
            border-radius: 10px;
            background-color: #F7F1E3;
            color: #2E4136;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            transition: all 0.15s ease;
        }

        .logout-button:hover {
            background-color: #EDE3CF;
            color: #1E2F26;
        }

        .main {
            max-width: 1180px;
            margin: 0 auto;
        }

        .menu-grid {
            display: flex;
            justify-content: center;
            gap: 24px;
            flex-wrap: wrap;
            margin-bottom: 36px;
        }

        .menu-button {
            width: 230px;
            height: 150px;
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
            transition: opacity 0.15s ease, transform 0.15s ease;
            border-radius: 14px;
            box-shadow: 0 8px 18px rgba(46, 65, 54, 0.10);
        }

        .menu-button:hover {
            opacity: 0.92;
            transform: translateY(-2px);
        }

        .menu-button.disabled-button {
            opacity: 0.55 !important;
            /* cursor: not-allowed; */
        }

        .menu-button.disabled-button:hover {
            opacity: 0.55 !important;
            transform: none;
        }

        .menu-icon {
            width: 72px;
            height: 72px;
            margin-bottom: 16px;
        }

        .menu-text {
            font-size: 28px;
            font-weight: bold;
            line-height: 1.2;
        }

        .dashboard {
            margin-top: 8px;
        }

        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .kpi-card {
            background-color: #FFFDF8;
            border: 1px solid #E0D5C3;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(46, 65, 54, 0.05);
        }

        .kpi-card.clickable-card {
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease, background-color 0.15s ease;
        }

        .kpi-card.clickable-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(46, 65, 54, 0.10);
            background-color: #FFFCF5;
        }

        .kpi-card.clickable-card:active {
            transform: translateY(0);
        }

        .kpi-label {
            margin: 0 0 12px 0;
            font-size: 14px;
            color: #645B50;
        }

        .kpi-value {
            margin: 0;
            font-size: 32px;
            font-weight: bold;
            color: #2E4136;
            line-height: 1.2;
        }

        .dashboard-row {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 16px;
        }

        .panel {
            background-color: #FFFDF8;
            border: 1px solid #E0D5C3;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(46, 65, 54, 0.05);
        }

        .panel-title {
            margin: 0 0 16px 0;
            font-size: 18px;
            color: #2E4136;
        }

        .info-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 16px;
            border-radius: 12px;
            background-color: #F9F4E8;
            border: 1px solid #E8DDCA;
        }

        .info-item.clickable-item {
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease, background-color 0.15s ease;
        }

        .info-item.clickable-item:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(46, 65, 54, 0.08);
            background-color: #FCF8EE;
        }

        .info-item-left {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .info-main {
            font-size: 15px;
            font-weight: bold;
            color: #2E4136;
        }

        .info-sub {
            font-size: 13px;
            color: #645B50;
        }

        .status-badge {
            min-width: 72px;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            background-color: #EAE4D6;
            color: #4E463C;
        }

        .status-1 {
            background-color: #FCE7A8;
            color: #6B5300;
        }

        .status-2 {
            background-color: #CFE8D7;
            color: #1F5A34;
        }

        .status-3 {
            background-color: #E5D8D8;
            color: #6A4B4B;
        }

        .summary-box {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .summary-item {
            padding: 16px;
            border-radius: 12px;
            background-color: #F9F4E8;
            border: 1px solid #E8DDCA;
        }

        .summary-label {
            margin: 0 0 8px 0;
            font-size: 14px;
            color: #645B50;
        }

        .summary-value {
            margin: 0;
            font-size: 28px;
            font-weight: bold;
            color: #2E4136;
        }

        .loading-text,
        .empty-text,
        .error-text {
            margin: 0;
            font-size: 14px;
        }

        .loading-text {
            color: #645B50;
        }

        .empty-text {
            color: #645B50;
        }

        .error-text {
            color: #B42318;
            font-weight: bold;
        }

        .modal-bg {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.35);
            z-index: 100;
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

        .modal-bg.is-open {
            display: block;
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
                <div class="staff-name">#session.staffName#</div>

                <button type="button" class="detail-button" id="detail_button">
                    <img
                        src="#Application.asset_url#/image/arrow-down-icon.svg"
                        data-down="#Application.asset_url#/image/arrow-down-icon.svg"
                        data-up="#Application.asset_url#/image/arrow-up-icon.svg"
                        id="arrow_icon"
                        alt="メニュー開閉">
                </button>

                <div class="user-menu" id="user_menu">
                    <button type="button" class="logout-button" id="logout-button">
                        ログアウト
                    </button>
                </div>
            </div>
        </header>

        <cfset addSlipButtonClass = "menu-button">
        <cfif session.authorityLevel eq 1>
            <cfset addSlipButtonClass = "menu-button disabled-button">
        </cfif>

        <main class="main">
            <div class="menu-grid">
                <button type="button" class="#addSlipButtonClass#" id="add_slip_button">
                    <img src="#Application.asset_url#/image/slip-entry-icon.svg" alt="伝票登録" class="menu-icon">
                    <span class="menu-text">伝票登録</span>
                </button>

                <button type="button" class="menu-button" id="slip_list_button">
                    <img src="#Application.asset_url#/image/slip-list-icon.svg" alt="伝票一覧" class="menu-icon">
                    <span class="menu-text">伝票一覧</span>
                </button>

                <button type="button" class="menu-button" id="inventory_button">
                    <img src="#Application.asset_url#/image/inventory-icon.svg" alt="在庫管理" class="menu-icon">
                    <span class="menu-text">在庫管理</span>
                </button>

                <button type="button" class="menu-button" id="total_report_button">
                    <img src="#Application.asset_url#/image/total-report-icon.svg" alt="集計レポート" class="menu-icon">
                    <span class="menu-text">集計レポート</span>
                </button>

                <button type="button" class="menu-button" id="master_button">
                    <img src="#Application.asset_url#/image/master-icon.svg" alt="マスタ" class="menu-icon">
                    <span class="menu-text">マスタ</span>
                </button>

                <button type="button" class="menu-button" id="admin_button">
                    <img src="#Application.asset_url#/image/admin-icon.svg" alt="基本設定" class="menu-icon">
                    <span class="menu-text">基本設定</span>
                </button>

            </div>

            <section class="dashboard">
                <div class="kpi-grid">
                    <div class="kpi-card clickable-card" id="today_slip_count_card" title="今日の伝票一覧へ">
                        <p class="kpi-label">今日の伝票数</p>
                        <p class="kpi-value" id="today_slip_count">-</p>
                    </div>

                    <div class="kpi-card clickable-card" id="unfixed_slip_count_card" title="未確定伝票一覧へ">
                        <p class="kpi-label">未確定伝票数</p>
                        <p class="kpi-value" id="unfixed_slip_count">-</p>
                    </div>

                    <div class="kpi-card clickable-card" id="today_total_qty_card" title="日別集計レポートへ">
                        <p class="kpi-label">今日の商品合計数量</p>
                        <p class="kpi-value" id="today_total_qty">-</p>
                    </div>

                    <div class="kpi-card clickable-card" id="today_total_amount_card" title="日別売上集計へ">
                        <p class="kpi-label">今日の合計金額</p>
                        <p class="kpi-value" id="today_total_amount">-</p>
                    </div>
                </div>

                <div class="dashboard-row">
                    <div class="panel">
                        <h3 class="panel-title">最近の伝票</h3>
                        <div id="recent_slip_list" class="info-list">
                            <p class="loading-text">読み込み中です...</p>
                        </div>
                    </div>

                    <div class="panel">
                        <h3 class="panel-title">本日の状況</h3>
                        <div class="summary-box">
                            <div class="summary-item">
                                <p class="summary-label">削除伝票数</p>
                                <p class="summary-value" id="deleted_slip_count">-</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <div class="modal-bg" id="master_modal">
            <div class="modal-box">
                <h3 class="modal-title">マスタ選択</h3>

                <button type="button" class="master-button" id="item-master-button">商品マスタ</button>
                <button type="button" class="master-button" id="supplier-master-button">取引先マスタ</button>
                <button type="button" class="master-button" id="staff-master-button">社員マスタ</button>

                <button type="button" class="close-button" id="close_modal_button">閉じる</button>
            </div>
        </div>
    </div>

    <script src="#application.asset_url#/js/menu.js?20260402_1"></script>
</body>
</cfoutput>
</html>