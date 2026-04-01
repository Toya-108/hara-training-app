<cfinclude template="init.cfm">

<cfset pageTitle = "集計レポート">
<cfset showHomeButton = true>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showEditButton = false>
<cfset showImportButton = false>
<cfset showExportButton = true>
<cfset showTrashButton = false>
<cfset showCancelButton = false>

<!--- 取引先一覧取得 --->
<cfquery name="qSupplier">
    SELECT
        supplier_code,
        supplier_name
    FROM
        m_supplier
    WHERE
        use_flag = 1
    ORDER BY
        supplier_code
</cfquery>

<cfset defaultSlipDateFrom = dateFormat(dateAdd("m", -1, now()), "yyyy/mm/dd")>
<cfset defaultSlipDateTo   = dateFormat(now(), "yyyy/mm/dd")>
<cfset defaultDeliveryDateFrom = "">
<cfset defaultDeliveryDateTo   = "">

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>集計レポート</title>

    <cfoutput>
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
        <link rel="stylesheet" href="#Application.asset_url#/css/flatpickr.min.css">
    </cfoutput>


    <style>
        .report-page {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
        }

        .report-search-area {
            background: #FFFCF5;
            border: 1px solid #D8CBB3;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(63, 91, 75, 0.08);
        }

        .report-search-title {
            font-size: 24px;
            font-weight: bold;
            color: #2E4136;
            margin-bottom: 20px;
        }

        .report-search-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(220px, 1fr));
            gap: 16px 20px;
        }

        .report-form-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .report-form-label {
            font-size: 14px;
            font-weight: bold;
            color: #2E4136;
        }

        .report-form-control {
            width: 100%;
            height: 44px;
            border: 1px solid #D8CBB3;
            border-radius: 10px;
            background: #FFFFFF;
            padding: 0 12px;
            font-size: 14px;
            color: #2E4136;
            box-sizing: border-box;
        }

        .report-date-range {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .report-date-range .report-form-control {
            flex: 1;
        }

        .report-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 20px;
        }

        .report-button {
            min-width: 120px;
            height: 44px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.2s;
        }

        .report-button:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .search-button {
            background: #3F5B4B;
            color: #FFFFFF;
        }

        .clear-button {
            background: #EDE4D3;
            color: #2E4136;
        }

        .report-summary-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .report-summary-card {
            background: #FFFFFF;
            border: 1px solid #D8CBB3;
            border-radius: 16px;
            padding: 20px 24px;
            box-shadow: 0 2px 8px rgba(63, 91, 75, 0.06);
        }

        .report-summary-label {
            font-size: 14px;
            color: #6B6B6B;
            margin-bottom: 12px;
            font-weight: bold;
        }

        .report-summary-value {
            font-size: 28px;
            font-weight: bold;
            color: #2E4136;
            line-height: 1.2;
        }

        .report-table-area {
            background: #FFFFFF;
            border: 1px solid #D8CBB3;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(63, 91, 75, 0.06);
        }

        .report-table-title {
            font-size: 24px;
            font-weight: bold;
            color: #2E4136;
            margin-bottom: 20px;
        }

        .report-table-wrap {
            overflow-x: auto;
        }

        .report-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }

        .report-table th {
            background: #F7F1E3;
            color: #2E4136;
            font-size: 14px;
            font-weight: bold;
            padding: 14px 12px;
            border-bottom: 1px solid #D8CBB3;
            text-align: left;
            white-space: nowrap;
        }

        .report-table td {
            font-size: 14px;
            color: #2E4136;
            padding: 14px 12px;
            border-bottom: 1px solid #EEE6D8;
            background: #FFFFFF;
        }

        .report-table tbody tr:hover td {
            background: #FAF6EC;
        }

        .report-empty {
            padding: 40px 16px;
            text-align: center;
            color: #6B6B6B;
            font-size: 15px;
        }

        .loading-area {
            display: none;
            text-align: center;
            padding: 24px;
            color: #2E4136;
            font-weight: bold;
        }

        @media screen and (max-width: 1200px) {
            .report-search-grid,
            .report-summary-grid {
                grid-template-columns: repeat(2, minmax(220px, 1fr));
            }
        }

        @media screen and (max-width: 768px) {
            .report-page {
                padding: 16px;
            }

            .report-search-grid,
            .report-summary-grid {
                grid-template-columns: 1fr;
            }

            .report-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .report-button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <cfinclude template="header.cfm">

    <div class="report-page">
        <div class="report-search-area">
            <div class="report-search-title">集計条件</div>

            <form id="report_search_form">
                <div class="report-search-grid">
                    <div class="report-form-item">
                        <div class="report-form-label">発注日</div>
                        <div class="report-date-range">
                            <input
                                type="text"
                                id="slip_date_from"
                                name="slip_date_from"
                                class="report-form-control datepicker"
                                value="<cfoutput>#defaultSlipDateFrom#</cfoutput>"
                                autocomplete="off">
                            <span>～</span>
                            <input
                                type="text"
                                id="slip_date_to"
                                name="slip_date_to"
                                class="report-form-control datepicker"
                                value="<cfoutput>#defaultSlipDateTo#</cfoutput>"
                                autocomplete="off">
                        </div>
                    </div>

                    <div class="report-form-item">
                        <div class="report-form-label">納品日</div>
                        <div class="report-date-range">
                            <input
                                type="text"
                                id="delivery_date_from"
                                name="delivery_date_from"
                                class="report-form-control datepicker"
                                value="<cfoutput>#defaultDeliveryDateFrom#</cfoutput>"
                                autocomplete="off">
                            <span>～</span>
                            <input
                                type="text"
                                id="delivery_date_to"
                                name="delivery_date_to"
                                class="report-form-control datepicker"
                                value="<cfoutput>#defaultDeliveryDateTo#</cfoutput>"
                                autocomplete="off">
                        </div>
                    </div>

                    <div class="report-form-item">
                        <div class="report-form-label">取引先</div>
                        <select id="supplier_code" name="supplier_code" class="report-form-control">
                            <option value="">すべて</option>
                            <cfloop query="qSupplier">
                                <option value="<cfoutput>#encodeForHtmlAttribute(qSupplier.supplier_code)#</cfoutput>">
                                    <cfoutput>#encodeForHtml(qSupplier.supplier_code)# : #encodeForHtml(qSupplier.supplier_name)#</cfoutput>
                                </option>
                            </cfloop>
                        </select>
                    </div>

                    <div class="report-form-item">
                        <div class="report-form-label">商品キーワード</div>
                        <input
                            type="text"
                            id="item_keyword"
                            name="item_keyword"
                            class="report-form-control"
                            placeholder="商品コード / JAN / 商品名">
                    </div>

                    <div class="report-form-item">
                        <div class="report-form-label">状態</div>
                        <select id="status" name="status" class="report-form-control">
                            <option value="">すべて</option>
                            <option value="1">登録</option>
                            <option value="2">確定</option>
                            <option value="3">削除</option>
                        </select>
                    </div>

                    <div class="report-form-item">
                        <div class="report-form-label">集計区分</div>
                        <select id="report_type" name="report_type" class="report-form-control">
                            <option value="day">日別集計</option>
                            <option value="supplier">取引先別集計</option>
                            <option value="item">商品別集計</option>
                            <option value="status">状態別集計</option>
                        </select>
                    </div>
                </div>

                <div class="report-actions">
                    <button type="button" id="clear_button" class="report-button clear-button">条件クリア</button>
                    <button type="submit" id="search_button" class="report-button search-button">集計する</button>
                </div>
            </form>
        </div>

        <div class="report-summary-grid">
            <div class="report-summary-card">
                <div class="report-summary-label">伝票数</div>
                <div class="report-summary-value" id="summary_slip_count">0件</div>
            </div>
            <div class="report-summary-card">
                <div class="report-summary-label">合計数量</div>
                <div class="report-summary-value" id="summary_total_qty">0</div>
            </div>
            <div class="report-summary-card">
                <div class="report-summary-label">合計金額</div>
                <div class="report-summary-value" id="summary_total_amount">¥0</div>
            </div>
            <div class="report-summary-card">
                <div class="report-summary-label">集計行数</div>
                <div class="report-summary-value" id="summary_row_count">0行</div>
            </div>
        </div>

        <div class="report-table-area">
            <div class="report-table-title">集計結果</div>

            <div class="loading-area" id="loading_area">集計中です...</div>

            <div class="report-table-wrap">
                <table class="report-table">
                    <thead>
                        <tr>
                            <th id="column_group_key">集計キー</th>
                            <th>伝票数</th>
                            <th>合計数量</th>
                            <th>合計金額</th>
                        </tr>
                    </thead>
                    <tbody id="report_table_body">
                        <tr>
                            <td colspan="4" class="report-empty">検索条件を指定して「集計する」を押してください。</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>

<cfoutput>
    <script src="#Application.asset_url#/js/flatpickr.min.js"></script>
    <script src="#Application.asset_url#/js/ja.js"></script>
    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/total_report.js"></script>
</cfoutput>
</html>