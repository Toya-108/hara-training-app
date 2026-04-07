<cfinclude template="init.cfm">

<cfset pageTitle = "伝票受信" />
<cfset showHomeButton = true />
<cfset showBackButton = false />
<cfset showNewButton = false />
<cfset showEditButton = false />
<cfset showImportButton = false />
<cfset showExportButton = false />
<cfset showTrashButton = false />
<cfset showCancelButton = false />

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>伝票受信 | Hara Logi App</title>

    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
        <link rel="stylesheet" href="#Application.asset_url#/css/base.css">
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
    </cfoutput>

    <style>
        .receive-page {
            max-width: 1100px;
            margin: 0 auto;
            padding: 24px;
        }

        .receive-card {
            background: #FFFFFF;
            border: 1px solid #D8CDBB;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(63, 91, 75, 0.08);
            padding: 28px;
            margin-bottom: 24px;
        }

        .receive-title {
            margin: 0 0 10px 0;
            font-size: 28px;
            font-weight: 700;
            color: #2E4136;
        }

        .receive-description {
            margin: 0 0 24px 0;
            font-size: 15px;
            line-height: 1.8;
            color: #5B5348;
        }

        .receive-description code {
            background: #F5EFE2;
            padding: 2px 8px;
            border-radius: 8px;
            font-family: monospace;
        }

        .receive-upload-area {
            border: 2px dashed #CDBFA8;
            border-radius: 16px;
            background: #FBF8F2;
            padding: 32px;
        }

        .receive-form-row {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .receive-file-input {
            font-size: 14px;
            color: #2F2A24;
            background: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 10px;
            padding: 10px 12px;
            min-width: 320px;
        }

        .receive-button {
            appearance: none;
            border: none;
            border-radius: 12px;
            background: #3F5B4B;
            color: #FFFFFF;
            font-size: 15px;
            font-weight: 700;
            padding: 12px 22px;
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease, opacity 0.15s ease;
            box-shadow: 0 6px 14px rgba(63, 91, 75, 0.18);
        }

        .receive-button:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(63, 91, 75, 0.22);
        }

        .receive-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .receive-subtitle {
            margin: 0 0 16px 0;
            font-size: 20px;
            font-weight: 700;
            color: #2E4136;
        }

        .csv-format-table-wrap {
            border: 1px solid #E0D6C6;
            border-radius: 14px;
            overflow: hidden;
            background: #FFFFFF;
        }

        .csv-format-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #FFFFFF;
        }

        .csv-format-table th,
        .csv-format-table td {
            padding: 12px 14px;
            text-align: left;
            vertical-align: top;
            font-size: 14px;
            border-right: 1px solid #E0D6C6;
            border-bottom: 1px solid #E0D6C6;
        }

        .csv-format-table th {
            background: #F3EBDC;
            color: #2E4136;
            width: 180px;
        }

        .csv-format-table tr th:last-child,
        .csv-format-table tr td:last-child {
            border-right: none;
        }

        .csv-format-table tr:last-child th,
        .csv-format-table tr:last-child td {
            border-bottom: none;
        }

        .required-badge {
            display: inline-block;
            margin-left: 8px;
            padding: 2px 8px;
            font-size: 12px;
            font-weight: 700;
            border-radius: 999px;
            background: #D95C5C;
            color: #FFFFFF;
        }

        .optional-badge {
            display: inline-block;
            margin-left: 8px;
            padding: 2px 8px;
            font-size: 12px;
            font-weight: 700;
            border-radius: 999px;
            background: #C8B68A;
            color: #FFFFFF;
        }

        .sample-block {
            margin-top: 16px;
            padding: 16px;
            background: #2E4136;
            color: #F7F1E3;
            border-radius: 14px;
            overflow-x: auto;
            font-size: 13px;
            line-height: 1.8;
            white-space: pre;
        }

        .receive-result {
            display: none;
            margin-top: 20px;
            border-radius: 14px;
            padding: 16px 18px;
            font-size: 14px;
            line-height: 1.8;
        }

        .receive-result.is-success {
            display: block;
            background: #EEF7F0;
            border: 1px solid #A8C8AF;
            color: #244231;
        }

        .receive-result.is-error {
            display: block;
            background: #FCEEEE;
            border: 1px solid #E0A7A7;
            color: #7A2E2E;
        }

        .history-table-wrap {
            border: 1px solid #E0D6C6;
            border-radius: 14px;
            overflow: hidden;
            background: #FFFFFF;
        }

        .history-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #FFFFFF;
        }

        .history-table th,
        .history-table td {
            padding: 12px 14px;
            text-align: left;
            vertical-align: middle;
            font-size: 14px;
            border-right: 1px solid #E0D6C6;
            border-bottom: 1px solid #E0D6C6;
        }

        .history-table th {
            background: #F3EBDC;
            color: #2E4136;
        }

        .history-table tr th:last-child,
        .history-table tr td:last-child {
            border-right: none;
        }

        .history-table tr:last-child th,
        .history-table tr:last-child td {
            border-bottom: none;
        }

        .history-success {
            color: #2E7D32;
            font-weight: bold;
        }

        .history-error {
            color: #C62828;
            font-weight: bold;
        }

        .history-empty {
            color: #645B50;
            text-align: center;
        }
    </style>
</head>
<body>
    <cfinclude template="header.cfm">

    <div class="receive-page">
        <div class="receive-card">
            <h1 class="receive-title">伝票受信</h1>
            <p class="receive-description">
                CSVファイルから伝票データを一括登録します。<br>
                同じ 伝票番号 が複数行ある場合は、同一伝票の明細として受信し、
                行番号はシステム側で 1 から自動採番します。<br>
                商品情報は 商品マスタ、取引先名は 取引先マスタ から取得します。
            </p>

            <div class="receive-upload-area">
                <form id="slip_receive_form" enctype="multipart/form-data">
                    <div class="receive-form-row">
                        <input type="file" id="csv_file" name="csv_file" class="receive-file-input" accept=".csv,text/csv">
                        <button type="button" id="receive_button" class="receive-button">受信開始</button>
                    </div>
                </form>

                <div id="receive_result" class="receive-result"></div>
            </div>
        </div>

        <div class="receive-card">
            <h2 class="receive-subtitle">受信履歴</h2>

            <div class="history-table-wrap">
                <table class="history-table">
                    <thead>
                        <tr>
                            <th>受信日時</th>
                            <th>伝票数</th>
                            <th>明細数</th>
                            <th>商品数</th>
                            <th>結果</th>
                        </tr>
                    </thead>
                    <tbody id="receive_history_body">
                        <tr>
                            <td colspan="5" class="history-empty">読み込み中です...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>


        <div class="receive-card">
            <h2 class="receive-subtitle">CSVフォーマット</h2>

            <div class="csv-format-table-wrap">
                <table class="csv-format-table">
                    <tr>
                        <th>列名</th>
                        <th>説明</th>
                    </tr>
                    <tr>
                        <td>slip_no <span class="required-badge">必須</span></td>
                        <td>伝票番号</td>
                    </tr>
                    <tr>
                        <td>slip_date <span class="required-badge">必須</span></td>
                        <td>発注日（例: 2026-04-07）</td>
                    </tr>
                    <tr>
                        <td>supplier_code <span class="required-badge">必須</span></td>
                        <td>取引先コード</td>
                    </tr>
                    <tr>
                        <td>delivery_date <span class="required-badge">必須</span></td>
                        <td>納品日（例: 2026-04-08）</td>
                    </tr>
                    <tr>
                        <td>item_code <span class="required-badge">必須</span></td>
                        <td>商品コード</td>
                    </tr>
                    <tr>
                        <td>qty <span class="required-badge">必須</span></td>
                        <td>数量</td>
                    </tr>
                    <tr>
                        <td>slip_memo <span class="optional-badge">任意</span></td>
                        <td>伝票備考</td>
                    </tr>
                    <tr>
                        <td>detail_memo <span class="optional-badge">任意</span></td>
                        <td>明細備考</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <cfoutput>
        <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
        <script src="#Application.asset_url#/js/slip_receive.js?20260407_02"></script>
    </cfoutput>
</body>
</html>