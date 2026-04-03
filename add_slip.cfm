<cfinclude template="init.cfm">

<cfset pageTitle = "伝票登録">
<cfset showHomeButton = true>
<cfset showNewButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>伝票登録</title>

    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
        <link rel="stylesheet" href="#Application.asset_url#/css/flatpickr.min.css">
    </cfoutput>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background-color: #F7F1E3;
            color: #2F2A24;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Yu Gothic", sans-serif;
        }

        .page-wrap {
            padding-bottom: 40px;
        }

        .content-wrap {
            max-width: 1180px;
            margin: 30px auto 0;
            padding: 0 24px;
        }

        .page-title-area {
            margin-bottom: 24px;
        }

        .page-subtitle {
            margin: 0;
            font-size: 14px;
            color: #645B50;
        }

        .form-card {
            margin-bottom: 24px;
            padding: 24px;
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 12px;
        }

        .section-title {
            margin: 0 0 20px 0;
            padding-bottom: 10px;
            font-size: 20px;
            color: #2E4136;
            border-bottom: 1px solid #E6D8BF;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(240px, 1fr));
            gap: 20px 24px;
        }

        .form-row {
            position: relative;
            display: flex;
            flex-direction: column;
        }

        .form-row.full {
            grid-column: 1 / -1;
        }

        .form-label {
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
            color: #2E4136;
        }

        .required {
            margin-left: 6px;
            font-size: 12px;
            color: #B84A4A;
        }

        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            color: #2F2A24;
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 8px;
            font-size: 14px;
        }

        .form-input,
        .form-select {
            height: 40px;
            padding: 0 12px;
        }

        .form-textarea {
            min-height: 100px;
            padding: 10px 12px;
            resize: vertical;
        }

        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: #3F5B4B;
            background-color: #FFFCF4;
            box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
        }

        .form-input.is-error,
        .form-select.is-error,
        .form-textarea.is-error,
        .flatpickr-input.is-error {
            border-color: #B84A4A !important;
            background-color: #FFF8F8 !important;
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

        .readonly-cell {
            background-color: #F8F4EA;
        }

        .item-table-wrap {
            overflow-x: auto;
        }

        .item-table {
            width: 100%;
            border-collapse: collapse;
            background-color: #FFFFFF;
        }

        .item-table th,
        .item-table td {
            padding: 8px;
            text-align: left;
            vertical-align: middle;
            border: 1px solid #CDBFA8;
        }

        .item-table th {
            background-color: #EFE5D1;
            color: #2E4136;
            font-size: 14px;
        }

        .item-table td input {
            width: 100%;
            height: 36px;
            padding: 0 10px;
            border: 1px solid #CDBFA8;
            border-radius: 6px;
            font-size: 14px;
        }

        .item-table td input:focus {
            outline: none;
            border-color: #3F5B4B;
            background-color: #FFFCF4;
        }

        .table-btn {
            min-width: 90px;
            height: 36px;
            border: none;
            border-radius: 8px;
            background-color: #3F5B4B;
            color: #FFFFFF;
            font-size: 13px;
            cursor: pointer;
        }

        .table-btn.sub {
            background-color: #8A8175;
        }

        .action-area {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 24px;
        }

        .action-area.left {
            justify-content: flex-start;
            margin-top: 16px;
        }

        .action-btn {
            min-width: 120px;
            height: 42px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
        }

        .action-btn.save {
            background-color: #3F5B4B;
            color: #FFFFFF;
        }

        .action-btn.clear {
            background-color: #FFFFFF;
            color: #2F2A24;
            border: 1px solid #CDBFA8;
        }

        .message-area {
            display: none;
            margin-bottom: 20px;
            padding: 12px 14px;
            border-radius: 8px;
            font-size: 13px;
            line-height: 1.6;
        }

        .message-area.is-visible {
            display: block;
        }

        .message-area.error {
            background-color: #FFF3F3;
            border: 1px solid #E8B9B9;
            color: #B84A4A;
        }

        .message-area.success {
            background-color: #F1F8F2;
            border: 1px solid #B9D2BE;
            color: #2E6A3A;
        }

        .modal-bg {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 1000;
            background-color: rgba(0, 0, 0, 0.35);
        }

        .modal-bg.is-open {
            display: block;
        }

        .modal-box {
            width: 90%;
            max-width: 900px;
            margin: 60px auto 0;
            padding: 24px;
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 12px;
        }

        .modal-title {
            margin: 0 0 20px 0;
            font-size: 20px;
            color: #2E4136;
        }

        .supplier-modal-box {
            display: flex;
            flex-direction: column;
            max-height: 80vh;
            overflow: hidden;
        }

        .supplier-search-line {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            margin-bottom: 20px;
        }

        .supplier-search-code {
            width: 220px;
            flex: 0 0 220px;
            display: flex;
            flex-direction: column;
        }

        .supplier-search-name {
            flex: 1 1 auto;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }

        .supplier-search-code label,
        .supplier-search-name label {
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: bold;
            color: #2E4136;
        }

        .supplier-search-line {
            display: flex;
            align-items: end;
            gap: 12px;
            margin-bottom: 20px;
        }

        .supplier-search-code {
            width: 220px;
            flex: 0 0 220px;
            display: flex;
            flex-direction: column;
        }

        .supplier-search-name {
            flex: 1 1 auto;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }

        .supplier-search-code label,
        .supplier-search-name label {
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: bold;
            color: #2E4136;
        }

        .supplier-search-buttons {
            flex: 0 0 auto;
            display: flex;
            align-items: center;
            gap: 14px;
            height: 40px;
            padding-bottom: 0;
        }

        .icon-button {
            padding: 0;
            border: none;
            background: transparent;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .search-icon-button {
            width: 56px;
            height: 56px;
            margin-top: -2px;
        }

        .search-icon-button img {
            width: 48px;
            height: 48px;
            display: block;
        }

        .clear-icon-button {
            width: 56px;
            height: 56px;
            margin-top: -2px;
        }

        .clear-icon-button img {
            width: 35px;
            height: 35px;
            display: block;
        }

        .icon-button:hover {
            opacity: 0.85;
        }

        .icon-button:active {
            transform: scale(0.96);
        }

        .supplier-table-wrap {
            max-height: 420px;
            overflow-y: auto;
            border: 1px solid #CDBFA8;
        }

        .select-supplier-btn {
            min-width: 70px;
            height: 32px;
            border: none;
            border-radius: 6px;
            background-color: #3F5B4B;
            color: #FFFFFF;
            font-size: 13px;
            cursor: pointer;
        }

        .flatpickr-input[readonly],
        input.form-input.flatpickr-input {
            width: 100%;
            height: 40px;
            padding: 0 40px 0 12px;
            border: 1px solid #CDBFA8;
            border-radius: 8px;
            background-color: #FFFFFF;
            color: #2F2A24;
            font-size: 14px;
            cursor: pointer;
        }

        .flatpickr-input[readonly]:focus,
        input.form-input.flatpickr-input:focus {
            outline: none;
            border-color: #3F5B4B;
            background-color: #FFFCF4;
            box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
        }

        .form-row:has(.js-date-picker)::after {
            content: "📅";
            position: absolute;
            right: 12px;
            top: 37px;
            font-size: 16px;
            line-height: 1;
            pointer-events: none;
            opacity: 0.75;
        }

        .flatpickr-calendar {
            background: #FFFFFF;
            color: #2F2A24;
            border: 1px solid #CDBFA8;
            border-radius: 12px;
            box-shadow: 0 10px 24px rgba(47, 42, 36, 0.12);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Yu Gothic", sans-serif;
        }

        .flatpickr-months {
            padding-top: 6px;
        }

        .flatpickr-months .flatpickr-month {
            height: 44px;
            color: #2E4136;
        }

        .flatpickr-current-month {
            padding-top: 6px;
            font-size: 16px;
        }

        .flatpickr-current-month .flatpickr-monthDropdown-months,
        .flatpickr-current-month input.cur-year {
            color: #2E4136;
            font-weight: bold;
        }

        .flatpickr-prev-month,
        .flatpickr-next-month {
            fill: #3F5B4B;
            color: #3F5B4B;
        }

        span.flatpickr-weekday {
            color: #645B50;
            font-size: 12px;
            font-weight: bold;
        }

        .flatpickr-day {
            color: #2F2A24;
            border-radius: 8px;
        }

        .flatpickr-day:hover {
            background: #F7F1E3;
            border-color: #F7F1E3;
        }

        .flatpickr-day.today {
            color: #2E4136;
            border-color: #3F5B4B;
            font-weight: bold;
        }

        .flatpickr-day.selected,
        .flatpickr-day.startRange,
        .flatpickr-day.endRange {
            background: #3F5B4B;
            border-color: #3F5B4B;
            color: #FFFFFF;
        }

        .flatpickr-day.selected:hover,
        .flatpickr-day.startRange:hover,
        .flatpickr-day.endRange:hover {
            background: #32483B;
            border-color: #32483B;
        }

        .flatpickr-day.inRange {
            background: #EEF4EF;
            border-color: #EEF4EF;
            box-shadow: -5px 0 0 #EEF4EF, 5px 0 0 #EEF4EF;
        }

        .flatpickr-day.flatpickr-disabled,
        .flatpickr-day.flatpickr-disabled:hover {
            color: #B7AEA1;
        }

        .flatpickr-time {
            border-top: 1px solid #E6D8BF;
        }

        .flatpickr-time input,
        .flatpickr-time .flatpickr-am-pm {
            color: #2F2A24;
            font-weight: bold;
        }

        .flatpickr-time input:hover,
        .flatpickr-time .flatpickr-am-pm:hover {
            background: #FFFCF4;
        }

        .flatpickr-time input:focus,
        .flatpickr-time .flatpickr-am-pm:focus {
            background: #FFFCF4;
            outline: none;
        }
    </style>
</head>

<body>
<cfoutput>
    <div class="page-wrap">
        <cfinclude template="header.cfm">

        <div class="content-wrap">
            <div class="page-title-area">
                <p class="page-subtitle">基本情報と明細情報を入力して、伝票を登録します。</p>
            </div>

            <div id="form_message" class="message-area"></div>

            <form id="add_slip_form" novalidate>
                <div class="form-card">
                    <h2 class="section-title">伝票基本情報</h2>

                    <div class="form-grid">
                        <div class="form-row">
                            <label class="form-label" for="slip_date">
                                発注日
                                <span class="required">※必須</span>
                            </label>
                            <input
                                type="text"
                                id="slip_date"
                                name="slip_date"
                                class="form-input js-required js-date-picker"
                                data-label="発注日"
                                placeholder="発注日を選択">
                            <div class="field-error" data-for="slip_date"></div>
                        </div>

                        <div class="form-row">
                            <label class="form-label" for="supplier_display">
                                取引先
                                <span class="required">※必須</span>
                            </label>

                            <input
                                type="text"
                                id="supplier_display"
                                class="form-input js-required supplier-open-trigger"
                                data-label="取引先"
                                placeholder="取引先を選択"
                                readonly>

                            <input type="hidden" id="supplier_code" name="supplier_code">
                            <input type="hidden" id="supplier_name" name="supplier_name">

                            <div class="field-error" data-for="supplier_display"></div>
                        </div>

                        <div class="form-row">
                            <label class="form-label" for="delivery_date">
                                納品日
                                <span class="required">※必須</span>
                            </label>
                            <input
                                type="text"
                                id="delivery_date"
                                name="delivery_date"
                                class="form-input js-required js-date-picker"
                                data-label="納品日"
                                placeholder="納品日を選択">
                            <div class="field-error" data-for="delivery_date"></div>
                        </div>

                        <div class="form-row full">
                            <label class="form-label" for="memo">備考</label>
                            <textarea id="memo" name="memo" class="form-textarea" maxlength="300"></textarea>
                        </div>
                    </div>
                </div>

                <div class="form-card">
                    <h2 class="section-title">伝票明細</h2>

                    <div class="item-table-wrap">
                        <table class="item-table" id="item_table">
                            <thead>
                                <tr>
                                    <th style="width: 150px;">商品コード</th>
                                    <th style="width: 170px;">JANコード</th>
                                    <th>商品名</th>
                                    <th style="width: 120px;">数量</th>
                                    <th style="width: 140px;">単価</th>
                                    <th style="width: 120px;">削除</th>
                                </tr>
                            </thead>
                            <tbody id="item_table_body">
                                <tr>
                                    <td><input type="text" name="item_code[]" class="item-code" maxlength="20"></td>
                                    <td><input type="text" name="jan_code[]" class="jan-code readonly-cell" maxlength="20" readonly></td>
                                    <td><input type="text" name="item_name[]" class="item-name readonly-cell" maxlength="100"></td>
                                    <td><input type="text" name="qty[]" class="qty num-check" title="数量"></td>
                                    <td><input type="text" name="unit_price[]" class="price num-check readonly-cell" title="単価"></td>
                                    <td>
                                        <button type="button" class="table-btn sub delete-row-btn">削除</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="action-area left">
                        <button type="button" id="add_row_btn" class="table-btn">行追加</button>
                    </div>
                </div>

                <div class="action-area">
                    <button type="button" id="clear_btn" class="action-btn clear">クリア</button>
                    <button type="submit" id="save_btn" class="action-btn save">登録</button>
                </div>

                <div class="modal-bg" id="supplier_modal">
                    <div class="modal-box supplier-modal-box">
                        <h3 class="modal-title">取引先選択</h3>

                        <div class="supplier-search-line">
                            <div class="supplier-search-code">
                                <label for="modal_search_supplier_code">取引先コード</label>
                                <input
                                    type="text"
                                    id="modal_search_supplier_code"
                                    class="form-input"
                                    placeholder="取引先コード"
                                    maxlength="6">
                            </div>

                            <div class="supplier-search-name">
                                <label for="modal_search_supplier_name">取引先名</label>
                                <input
                                    type="text"
                                    id="modal_search_supplier_name"
                                    class="form-input"
                                    placeholder="取引先名">
                            </div>

                            <div class="supplier-search-buttons">
                                <button
                                    type="button"
                                    class="icon-button search-icon-button"
                                    id="modal_supplier_search_btn"
                                    aria-label="検索">
                                    <img src="#Application.asset_url#/image/search-icon.svg" alt="検索">
                                </button>

                                <button
                                    type="button"
                                    class="icon-button clear-icon-button"
                                    id="modal_supplier_clear_btn"
                                    aria-label="クリア">
                                    <img src="#Application.asset_url#/image/clear-icon.svg" alt="クリア">
                                </button>
                            </div>
                        </div>

                        <div class="supplier-table-wrap">
                            <table class="item-table">
                                <thead>
                                    <tr>
                                        <th style="width: 140px;">取引先コード</th>
                                        <th>取引先名</th>
                                        <th style="width: 120px;">配送業者</th>
                                        <th style="width: 100px;">選択</th>
                                    </tr>
                                </thead>
                                <tbody id="supplier_table_body">
                                    <tr>
                                        <td colspan="4" class="loading_text">検索してください。</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="action-area">
                            <button type="button" id="close_supplier_modal_btn" class="action-btn clear">閉じる</button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/validation-common.js"></script>
    <script src="#Application.asset_url#/js/flatpickr.min.js"></script>
    <script src="#Application.asset_url#/js/ja.js"></script>
    <script src="#Application.asset_url#/js/add_slip.js?20260331_1"></script>
</cfoutput>
</body>
</html>