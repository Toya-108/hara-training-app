<cfinclude template="init.cfm">

<cfset pageTitle = "在庫管理" />
<cfset showHomeButton = true />
<cfset showBackButton = false />
<cfset showNewButton = false />
<cfset showEditButton = false />
<cfset showImportButton = false />
<cfset showExportButton = false />
<cfset showTrashButton = false />
<cfset showCancelButton = false />

<cfinclude template="header.cfm">

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>在庫管理</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <cfoutput><link rel="stylesheet" href="#Application.asset_url#/css/style.css"></cfoutput>
    <cfoutput><script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script></cfoutput>

    <style>
        body {
            margin: 0;
            background: #F7F1E3;
            color: #2F2A24;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Yu Gothic", sans-serif;
        }

        .inventory-page {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
        }

        .search-card,
        .list-card,
        .summary-card,
        .modal-card {
            background: #FFFCF7;
            border: 1px solid #D8CCB8;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(63, 91, 75, 0.08);
        }

        .search-card {
            padding: 20px;
            margin-bottom: 20px;
        }

        .search-title,
        .list-title {
            margin: 0 0 16px;
            font-size: 22px;
            font-weight: 700;
            color: #2E4136;
        }

        .search-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(180px, 1fr));
            gap: 16px;
        }

        .search-item {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .search-item label {
            font-size: 14px;
            font-weight: 700;
            color: #2E4136;
        }

        .search-item input,
        .search-item select,
        .adjust-form input,
        .adjust-form select,
        .adjust-form textarea {
            height: 42px;
            padding: 0 12px;
            border: 1px solid #CDBFA8;
            border-radius: 5px;
            background: #FFFFFF;
            font-size: 14px;
            color: #2F2A24;
            box-sizing: border-box;
            transition: border-color 0.15s ease, background-color 0.15s ease, box-shadow 0.15s ease;
        }

        .adjust-form textarea {
            height: 92px;
            padding: 10px 12px;
            resize: vertical;
        }

        .search-item input:focus,
        .search-item select:focus {
            border-color: #3F5B4B;
            background-color: #FFFCF4;
            box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
            outline: none;
        }

        .search-item input::placeholder {
            color: #8A8175;
        }
        
        .search-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 18px;
        }

        .action-button {
            min-width: 120px;
            height: 42px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 700;
            font-size: 14px;
            transition: 0.2s ease;
        }

        .action-button.primary {
            background: #3F5B4B;
            color: #FFFFFF;
        }

        .action-button.secondary {
            background: #EDE5D8;
            color: #3F5B4B;
            border: 1px solid #D8CCB8;
        }

        .action-button:hover {
            transform: translateY(-1px);
            opacity: 0.95;
        }

        .summary-wrap {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }

        .summary-card {
            padding: 20px;
        }

        .summary-label {
            font-size: 14px;
            font-weight: 700;
            color: #5C6B63;
            margin-bottom: 10px;
        }

        .summary-value {
            font-size: 34px;
            font-weight: 800;
            color: #2E4136;
        }

        .list-card {
            padding: 20px;
        }

        .list-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 16px;
        }

        .list-info {
            font-size: 14px;
            color: #5C6B63;
        }

        .table-wrap {
            overflow-x: auto;
            border: 1px solid #E2D8C8;
            border-radius: 12px;
        }

        table.inventory-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1100px;
            background: #FFFFFF;
        }

        .inventory-table th,
        .inventory-table td {
            padding: 14px 12px;
            border-bottom: 1px solid #EFE7DA;
            text-align: left;
            vertical-align: middle;
            font-size: 14px;
        }

        .inventory-table th {
            background: #F4EEE3;
            color: #3F5B4B;
            font-weight: 700;
            white-space: nowrap;
        }

        .inventory-table tbody tr {
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .inventory-table tbody tr:hover {
            background: #F7F3EA;
        }

        .sort-button {
            background: none;
            border: none;
            color: #3F5B4B;
            font-weight: 700;
            cursor: pointer;
            font-size: 14px;
            padding: 0;
        }

        .qty-cell {
            font-weight: 700;
        }

        .low-stock {
            color: #B7791F;
            font-weight: 800;
        }

        .zero-stock {
            color: #C53030;
            font-weight: 800;
        }

        .row-action-button {
            min-width: 92px;
            height: 34px;
            border: none;
            border-radius: 999px;
            background: #DCEADB;
            color: #2E4136;
            font-weight: 700;
            cursor: pointer;
        }

        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin-top: 18px;
            flex-wrap: wrap;
        }

        .page-button {
            min-width: 38px;
            height: 38px;
            border-radius: 8px;
            border: 1px solid #D8CCB8;
            background: #FFFFFF;
            color: #3F5B4B;
            cursor: pointer;
            font-weight: 700;
        }

        .page-button.active {
            background: #3F5B4B;
            color: #FFFFFF;
            border-color: #3F5B4B;
        }

        .page-button:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }

        .modal-overlay {
            position: fixed;
            inset: 0;
            background:
                linear-gradient(135deg, rgba(47, 42, 36, 0.50), rgba(63, 91, 75, 0.22));
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 24px;
            box-sizing: border-box;
        }

        .modal-overlay.is-open {
            display: flex;
            animation: modalFadeIn 0.2s ease;
        }

        .modal-card {
            width: 100%;
            max-width: 720px;
            padding: 0;
            border-radius: 24px;
            overflow: hidden;
            background: linear-gradient(180deg, #FFFDF9 0%, #FFF9F0 100%);
            border: 1px solid rgba(216, 204, 184, 0.95);
            box-shadow:
                0 24px 60px rgba(47, 42, 36, 0.22),
                0 10px 24px rgba(63, 91, 75, 0.10);
            animation: modalSlideUp 0.24s ease;
        }

        .modal-title {
            margin: 0;
            padding: 24px 28px 18px;
            font-size: 26px;
            color: #2E4136;
            font-weight: 800;
            letter-spacing: 0.02em;
            background: linear-gradient(180deg, rgba(247, 241, 227, 0.95) 0%, rgba(255, 252, 247, 0.9) 100%);
            border-bottom: 1px solid #E8DDCB;
            position: relative;
        }

        .modal-title::before {
            content: "";
            display: inline-block;
            width: 6px;
            height: 28px;
            border-radius: 999px;
            background: linear-gradient(180deg, #3F5B4B 0%, #6E8B78 100%);
            margin-right: 12px;
            vertical-align: -6px;
        }

        .modal-item-info {
            margin: 22px 28px 18px;
            padding: 16px 18px;
            border-radius: 18px;
            background: linear-gradient(180deg, #F8F4EC 0%, #FFFDF9 100%);
            border: 1px solid #E4D8C8;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.7);
            line-height: 1.9;
        }

        .modal-item-info div {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 4px 0;
            font-size: 14px;
            color: #3A342D;
            border-bottom: 1px dashed rgba(216, 204, 184, 0.65);
        }

        .modal-item-info div:last-child {
            border-bottom: none;
        }

        .modal-item-info strong {
            min-width: 92px;
            color: #2E4136;
            font-weight: 800;
        }

        .adjust-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px 16px;
            padding: 0 28px 8px;
        }

        .adjust-form > div {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .adjust-form .full-width {
            grid-column: 1 / -1;
        }

        .adjust-form label {
            font-size: 13px;
            font-weight: 800;
            color: #33483B;
            letter-spacing: 0.02em;
        }

        .adjust-form input,
        .adjust-form select,
        .adjust-form textarea {
            width: 100%;
            height: 46px;
            padding: 0 14px;
            border: 1px solid #D6C8B4;
            border-radius: 12px;
            background: #FFFFFF;
            font-size: 14px;
            color: #2F2A24;
            box-sizing: border-box;
            transition:
                border-color 0.18s ease,
                box-shadow 0.18s ease,
                background-color 0.18s ease,
                transform 0.18s ease;
            box-shadow: 0 1px 2px rgba(47, 42, 36, 0.04);
        }

        .adjust-form textarea {
            min-height: 110px;
            height: 110px;
            padding: 12px 14px;
            resize: vertical;
            line-height: 1.6;
        }

        .adjust-form input:focus,
        .adjust-form select:focus,
        .adjust-form textarea:focus {
            outline: none;
            border-color: #3F5B4B;
            background: #FFFDF8;
            box-shadow:
                0 0 0 4px rgba(63, 91, 75, 0.12),
                0 4px 12px rgba(63, 91, 75, 0.08);
            transform: translateY(-1px);
        }

        .adjust-form input[readonly] {
            background: #F3EEE4;
            color: #6A6257;
            border-color: #DDD1BE;
            font-weight: 700;
            cursor: default;
        }

        .adjust-form textarea::placeholder {
            color: #9A9083;
        }

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 28px 26px;
            margin-top: 8px;
            border-top: 1px solid #EEE3D4;
            background: rgba(255, 252, 247, 0.85);
        }

        .modal-actions .action-button {
            min-width: 132px;
            height: 46px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
            letter-spacing: 0.02em;
            box-shadow: 0 4px 10px rgba(47, 42, 36, 0.08);
        }

        .modal-actions .action-button.secondary {
            background: #F3EBDE;
            color: #3F5B4B;
            border: 1px solid #D8CCB8;
        }

        .modal-actions .action-button.primary {
            background: linear-gradient(180deg, #496755 0%, #3F5B4B 100%);
            color: #FFFFFF;
            border: 1px solid #385142;
        }

        .modal-actions .action-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(47, 42, 36, 0.13);
            opacity: 1;
        }

        .modal-actions .action-button:active {
            transform: translateY(0);
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        @keyframes modalSlideUp {
            from {
                opacity: 0;
                transform: translateY(14px) scale(0.98);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        @media (max-width: 1024px) {
            .search-grid,
            .summary-wrap,
            .adjust-form {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .inventory-page {
                padding: 16px;
            }

            .search-grid,
            .summary-wrap {
                grid-template-columns: 1fr;
            }

            .list-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .search-actions {
                flex-direction: column;
            }

            .action-button {
                width: 100%;
            }

            .modal-overlay {
                padding: 14px;
            }

            .modal-card {
                max-width: 100%;
                border-radius: 18px;
            }

            .modal-title {
                padding: 20px 20px 16px;
                font-size: 22px;
            }

            .modal-item-info {
                margin: 16px 20px 14px;
                padding: 14px;
            }

            .modal-item-info div {
                display: block;
                line-height: 1.7;
            }

            .modal-item-info strong {
                display: block;
                min-width: auto;
                margin-bottom: 2px;
            }

            .adjust-form {
                grid-template-columns: 1fr;
                padding: 0 20px 6px;
            }

            .modal-actions {
                flex-direction: column-reverse;
                padding: 18px 20px 20px;
            }

            .modal-actions .action-button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="inventory-page">
        <div class="search-card">
            <h2 class="search-title">在庫検索</h2>

            <form id="search_form">
                <div class="search-grid">
                    <div class="search-item">
                        <label for="search_item_code">商品コード</label>
                        <input type="text" id="search_item_code" name="item_code" placeholder="商品コード">
                    </div>

                    <div class="search-item">
                        <label for="search_jan_code">JANコード</label>
                        <input type="text" id="search_jan_code" name="jan_code" placeholder="JANコード">
                    </div>

                    <div class="search-item">
                        <label for="search_keyword">商品名 / カナ</label>
                        <input type="text" id="search_keyword" name="keyword" placeholder="商品名 / 商品名(カナ)">
                    </div>

                    <div class="search-item">
                        <label for="search_item_category">分類</label>
                        <select id="search_item_category" name="item_category">
                            <option value="">すべて</option>
                            <option value="1">食品</option>
                            <option value="2">雑貨</option>
                            <option value="3">日用品</option>
                            <option value="4">衣料</option>
                            <option value="5">小物</option>
                        </select>
                    </div>

                    <div class="search-item">
                        <label for="search_stock_status">在庫状態</label>
                        <select id="search_stock_status" name="stock_status">
                            <option value="">すべて</option>
                            <option value="normal">通常</option>
                            <option value="low">安全在庫以下</option>
                            <option value="zero">在庫ゼロ</option>
                        </select>
                    </div>

                    <div class="search-item">
                        <label for="search_qty_from">現在庫数（以上）</label>
                        <input type="text" id="search_qty_from" name="qty_from" class="num-check" title="現在庫数（以上）" placeholder="数値">
                    </div>

                    <div class="search-item">
                        <label for="search_qty_to">現在庫数（以下）</label>
                        <input type="text" id="search_qty_to" name="qty_to" class="num-check" title="現在庫数（以下）" placeholder="数値">
                    </div>

                    <div class="search-item">
                        <label for="search_safety_stock_only">不足在庫のみ</label>
                        <select id="search_safety_stock_only" name="safety_stock_only">
                            <option value="0">表示しない</option>
                            <option value="1">表示する</option>
                        </select>
                    </div>
                </div>

                <div class="search-actions">
                    <button type="button" class="action-button secondary" id="clear_button">クリア</button>
                    <button type="submit" class="action-button primary" id="search_button">検索</button>
                </div>
            </form>
        </div>

        <div class="summary-wrap">
            <div class="summary-card">
                <div class="summary-label">対象商品数</div>
                <div class="summary-value" id="summary_item_count">0</div>
            </div>
            <div class="summary-card">
                <div class="summary-label">在庫総数</div>
                <div class="summary-value" id="summary_total_qty">0</div>
            </div>
            <div class="summary-card">
                <div class="summary-label">不足在庫商品数</div>
                <div class="summary-value" id="summary_low_stock_count">0</div>
            </div>
        </div>

        <div class="list-card">
            <div class="list-header">
                <h2 class="list-title">在庫一覧</h2>
                <div class="list-info" id="list_info">0件表示</div>
            </div>

            <div class="table-wrap">
                <table class="inventory-table">
                    <thead>
                        <tr>
                            <th><button type="button" class="sort-button" data-sort-column="item_code">商品コード</button></th>
                            <th><button type="button" class="sort-button" data-sort-column="jan_code">JANコード</button></th>
                            <th><button type="button" class="sort-button" data-sort-column="item_name">商品名</button></th>
                            <th><button type="button" class="sort-button" data-sort-column="item_category">分類</button></th>
                            <th><button type="button" class="sort-button" data-sort-column="current_qty">現在庫数</button></th>
                            <th><button type="button" class="sort-button" data-sort-column="safety_stock_qty">安全在庫数</button></th>
                            <th>在庫状態</th>
                            <th><button type="button" class="sort-button" data-sort-column="update_datetime">更新日時</button></th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody id="inventory_list_body">
                        <tr>
                            <td colspan="9">データを読み込み中です。</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="pagination" id="pagination"></div>
        </div>
    </div>

    <div class="modal-overlay" id="adjust_modal">
        <div class="modal-card">
            <h2 class="modal-title">在庫調整</h2>

            <div class="modal-item-info" id="modal_item_info"></div>

            <form id="adjust_form">
                <input type="hidden" id="adjust_item_code" name="item_code">

                <div class="adjust-form">
                    <div>
                        <label for="adjust_type">調整方法</label>
                        <select id="adjust_type" name="change_type">
                            <option value="1">加算</option>
                            <option value="2">減算</option>
                            <option value="3">直接設定</option>
                        </select>
                    </div>

                    <div>
                        <label for="adjust_qty">数量</label>
                        <input type="text" id="adjust_qty" name="change_qty" class="num-check" title="調整数量">
                    </div>

                    <div>
                        <label for="adjust_safety_stock_qty">安全在庫数</label>
                        <input type="text" id="adjust_safety_stock_qty" name="safety_stock_qty" class="num-check" title="安全在庫数">
                    </div>

                    <div>
                        <label for="adjust_current_qty_preview">現在庫数</label>
                        <input type="text" id="adjust_current_qty_preview" readonly>
                    </div>

                    <div class="full-width">
                        <label for="adjust_reason">理由</label>
                        <textarea id="adjust_reason" name="reason" placeholder="棚卸差異、受入反映、破損調整など"></textarea>
                    </div>
                </div>
            </form>

            <div class="modal-actions">
                <button type="button" class="action-button secondary" id="modal_close_button">閉じる</button>
                <button type="button" class="action-button primary" id="save_adjust_button">保存</button>
            </div>
        </div>
    </div>

    <cfoutput><script src="#Application.asset_url#/js/validation-common.js"></script></cfoutput>
    <cfoutput><script src="#Application.asset_url#/js/inventory.js"></script></cfoutput>
</body>
</html>