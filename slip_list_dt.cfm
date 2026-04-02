<cfinclude template="init.cfm">

<cfset detailSlipNo = "">
<cfset displayMode = "view">

<cfif structKeyExists(form, "detail_slip_no")>
    <cfset detailSlipNo = trim(form.detail_slip_no)>
</cfif>

<cfif structKeyExists(form, "detail_display_mode")>
    <cfset displayMode = lcase(trim(form.detail_display_mode))>
</cfif>

<cfif displayMode NEQ "view" AND displayMode NEQ "edit">
    <cfset displayMode = "view">
</cfif>

<!--- 伝票ステータス取得 --->
<cfset slipStatus = "1">

<cfif detailSlipNo NEQ "">
    <cfquery name="qSlipStatus">
        SELECT status
        FROM t_slip
        WHERE slip_no = <cfqueryparam value="#detailSlipNo#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qSlipStatus.recordCount GT 0>
        <cfset slipStatus = qSlipStatus.status>
    </cfif>
</cfif>

<!--- 表示制御 --->
<cfif displayMode EQ "view">
    <cfset pageTitle = "伝票詳細">
    <cfset showBackButton = true>

    <!--- ★ここがポイント --->
    <cfif slipStatus EQ "2">
        <cfset showEditButton = false> <!-- 確定なら非表示 -->
    <cfelse>
        <cfif session.authorityLevel eq 9>
            <cfset showEditButton = true>
        <cfelse>
            <cfset showEditButton = false>
        </cfif>
    </cfif>

    <cfset showNewButton = false>
    <cfset showTrashButton = false>
    <cfset showCancelButton = false>

<cfelseif displayMode EQ "edit">
    <cfset pageTitle = "伝票修正">
    <cfset showBackButton = false>
    <cfset showEditButton = false>
    <cfset showNewButton = false>
    <cfset showTrashButton = false>
    <cfset showCancelButton = true>
</cfif>

<cfquery name="qSupplier">
    SELECT
        supplier_code,
        supplier_name
    FROM m_supplier
    WHERE use_flag = 1
    ORDER BY supplier_code ASC
</cfquery>

<cfinclude template="header.cfm">

<title>伝票明細</title>

<cfoutput>
    <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
    <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
    <link rel="stylesheet" href="#Application.asset_url#/css/flatpickr.min.css">
</cfoutput>

<style>
    .page-content {
        max-width: 1320px;
        margin: 24px auto;
        padding: 0 20px 36px;
        box-sizing: border-box;
    }

    .section-card {
        background: #FFFDF8;
        border: 1px solid #D1C4AB;
        border-radius: 12px;
        padding: 18px;
        margin-bottom: 18px;
    }

    .section-title {
        font-size: 18px;
        font-weight: bold;
        color: #314E3D;
        margin-bottom: 18px;
    }

    .header-grid {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 16px 18px;
    }

    .form-item {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .form-item.col-span-2 {
        grid-column: span 2;
    }

    .form-label {
        font-size: 14px;
        font-weight: bold;
        color: #314E3D;
    }

    .form-control,
    .form-textarea {
        width: 100%;
        box-sizing: border-box;
        border: 1px solid #CDBFA8;
        border-radius: 8px;
        background: #FFFFFF;
        color: #2F2A24;
        font-size: 14px;
    }

    .form-control {
        height: 40px;
        padding: 0 12px;
    }

    .form-textarea {
        min-height: 90px;
        padding: 10px 12px;
        resize: vertical;
    }

    .readonly-box,
    .readonly-textarea {
        width: 100%;
        box-sizing: border-box;
        border: 1px solid #D8CCB7;
        border-radius: 8px;
        background: #F8F4EA;
        color: #2F2A24;
        font-size: 14px;
    }

    .readonly-box {
        min-height: 40px;
        padding: 9px 12px;
    }

    .readonly-textarea {
        min-height: 90px;
        padding: 10px 12px;
        white-space: pre-wrap;
        word-break: break-word;
    }

    .table-wrap {
        width: 100%;
        overflow-x: auto;
    }

    .detail-table {
        width: 100%;
        min-width: 980px;
        border-collapse: collapse;
        background: #FFFFFF;
        table-layout: fixed;
    }

    .detail-table thead th {
        background: #E7DFC7;
        color: #314E3D;
        font-size: 13px;
        font-weight: bold;
        border: 1px solid #D1C4AB;
        padding: 10px 6px;
        text-align: center;
        white-space: nowrap;
    }

    .detail-table tbody td {
        border: 1px solid #D8CCB7;
        padding: 6px;
        background: #FFFDF8;
        vertical-align: middle;
        font-size: 13px;
    }

    .detail-table .form-control {
        height: 34px;
        font-size: 13px;
        padding: 0 8px;
    }

    .align-center {
        text-align: center;
    }

    .align-right {
        text-align: right;
    }

    .loading_indicator {
        display: none;
        margin-bottom: 12px;
        color: #314E3D;
        font-size: 14px;
        font-weight: bold;
    }

    .loading_indicator.is-visible {
        display: block;
    }

    .empty-row {
        text-align: center;
        padding: 24px 12px;
        color: #645B50;
        font-size: 14px;
    }

    .col-line-no { width: 48px; }
    .col-item-code { width: 120px; }
    .col-jan-code { width: 145px; }
    .col-item-name { width: 280px; }
    .col-qty { width: 72px; }
    .col-unit-price { width: 88px; }
    .col-amount { width: 96px; }

    .view-only { display: block; }
    .edit-only { display: none; }

    .edit_mode .view-only { display: none; }
    .edit_mode .edit-only { display: block; }

    .bottom-save-area {
        margin-top: 18px;
        display: flex;
        justify-content: center;
    }

    .save-button {
        min-width: 140px;
        height: 42px;
        padding: 0 20px;
        border: 1px solid #CDBFA8;
        border-radius: 8px;
        background: #FFF;
        color: #2F2A24;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
    }

    .save-button.primary {
        background: #4B6653;
        border-color: #4B6653;
        color: #FFF;
    }

    @media screen and (max-width: 1100px) {
        .header-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }
    }

    @media screen and (max-width: 700px) {
        .page-content {
            padding: 0 14px 28px;
        }

        .header-grid {
            grid-template-columns: 1fr;
        }

        .form-item.col-span-2 {
            grid-column: span 1;
        }
    }

    .status-badge {
        display: inline-block;
        min-width: 70px;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: bold;
        text-align: center;
    }

    .status-1 {
        background: #F5E7BE;
        color: #7A5A00;
    }

    .status-2 {
        background: #DCEBDC;
        color: #2F6A40;
    }

    .status-3 {
        background: #E5E7EB;
        color: #4B5563;
    }

    .status-display-wrap {
        min-height: 40px;
        display: flex;
        align-items: center;
    }
</style>

<div class="page-content">
    <div class="loading_indicator" id="loading_indicator">読み込み中です...</div>

    <form id="detail_form" name="detail_form" method="post">
        <input type="hidden" id="detail_slip_no" name="detail_slip_no" value="<cfoutput>#encodeForHtmlAttribute(detailSlipNo)#</cfoutput>">
        <input type="hidden" id="detail_display_mode" name="detail_display_mode" value="<cfoutput>#encodeForHtmlAttribute(displayMode)#</cfoutput>">
        <input type="hidden" id="return_from_menu" name="return_from_menu" value="<cfoutput><cfif structKeyExists(form, 'return_from_menu')>#encodeForHtmlAttribute(form.return_from_menu)#</cfif></cfoutput>">

        <input type="hidden" id="return_search_slip_no" name="return_search_slip_no" value="<cfoutput><cfif structKeyExists(form, 'return_search_slip_no')>#encodeForHtmlAttribute(form.return_search_slip_no)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_order_date_from" name="return_search_order_date_from" value="<cfoutput><cfif structKeyExists(form, 'return_search_order_date_from')>#encodeForHtmlAttribute(form.return_search_order_date_from)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_order_date_to" name="return_search_order_date_to" value="<cfoutput><cfif structKeyExists(form, 'return_search_order_date_to')>#encodeForHtmlAttribute(form.return_search_order_date_to)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_delivery_date_from" name="return_search_delivery_date_from" value="<cfoutput><cfif structKeyExists(form, 'return_search_delivery_date_from')>#encodeForHtmlAttribute(form.return_search_delivery_date_from)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_delivery_date_to" name="return_search_delivery_date_to" value="<cfoutput><cfif structKeyExists(form, 'return_search_delivery_date_to')>#encodeForHtmlAttribute(form.return_search_delivery_date_to)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_supplier_code" name="return_search_supplier_code" value="<cfoutput><cfif structKeyExists(form, 'return_search_supplier_code')>#encodeForHtmlAttribute(form.return_search_supplier_code)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_supplier_keyword" name="return_search_supplier_keyword" value="<cfoutput><cfif structKeyExists(form, 'return_search_supplier_keyword')>#encodeForHtmlAttribute(form.return_search_supplier_keyword)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_item_keyword" name="return_search_item_keyword" value="<cfoutput><cfif structKeyExists(form, 'return_search_item_keyword')>#encodeForHtmlAttribute(form.return_search_item_keyword)#</cfif></cfoutput>">
        <input type="hidden" id="return_search_status" name="return_search_status" value="<cfoutput><cfif structKeyExists(form, 'return_search_status')>#encodeForHtmlAttribute(form.return_search_status)#</cfif></cfoutput>">
        <input type="hidden" id="return_current_page" name="return_current_page" value="<cfoutput><cfif structKeyExists(form, 'return_current_page')>#encodeForHtmlAttribute(form.return_current_page)#</cfif></cfoutput>">
        <input type="hidden" id="return_sort_field" name="return_sort_field" value="<cfoutput><cfif structKeyExists(form, 'return_sort_field')>#encodeForHtmlAttribute(form.return_sort_field)#</cfif></cfoutput>">
        <input type="hidden" id="return_sort_order" name="return_sort_order" value="<cfoutput><cfif structKeyExists(form, 'return_sort_order')>#encodeForHtmlAttribute(form.return_sort_order)#</cfif></cfoutput>">

        <div class="section-card <cfif displayMode EQ 'edit'>edit_mode</cfif>">
            <div class="section-title">ヘッダ情報</div>

            <div class="header-grid">
                <div class="form-item">
                    <div class="form-label">伝票番号</div>
                    <div class="readonly-box view-only" id="slip_no_disp"></div>
                    <input type="text" id="slip_no" class="form-control edit-only" readonly>
                </div>

                <div class="form-item">
                    <div class="form-label">状態</div>

                    <div class="view-only status-display-wrap">
                        <span id="status_disp" class="status-badge"></span>
                    </div>

                    <select id="status" class="form-control edit-only">
                        <option value="1">登録</option>
                        <option value="2">確定</option>
                        <option value="3">削除</option>
                    </select>
                </div>

                <div class="form-item">
                    <div class="form-label">発注日</div>
                    <div class="readonly-box view-only" id="slip_date_disp"></div>
                    <input type="text" id="slip_date" class="form-control js-date-picker edit-only">
                </div>

                <div class="form-item">
                    <div class="form-label">納品日</div>
                    <div class="readonly-box view-only" id="delivery_date_disp"></div>
                    <input type="text" id="delivery_date" class="form-control js-date-picker edit-only">
                </div>

                <div class="form-item">
                    <div class="form-label">取引先コード</div>
                    <div class="readonly-box view-only" id="supplier_code_disp"></div>
                    <select id="supplier_code" class="form-control edit-only">
                        <option value="">選択してください</option>
                        <cfoutput query="qSupplier">
                            <option value="#encodeForHtmlAttribute(supplier_code)#">#encodeForHtml(supplier_code)#</option>
                        </cfoutput>
                    </select>
                </div>

                <div class="form-item">
                    <div class="form-label">取引先名</div>
                    <div class="readonly-box" id="supplier_name_disp"></div>
                </div>

                <div class="form-item">
                    <div class="form-label">合計数量</div>
                    <div class="readonly-box align-right" id="total_qty_disp">0</div>
                </div>

                <div class="form-item">
                    <div class="form-label">合計金額</div>
                    <div class="readonly-box align-right" id="total_amount_disp">0</div>
                </div>

                <div class="form-item col-span-2">
                    <div class="form-label">備考</div>
                    <div class="readonly-textarea view-only" id="memo_disp"></div>
                    <textarea id="memo" class="form-textarea edit-only"></textarea>
                </div>

                <div class="form-item">
                    <div class="form-label">作成日時</div>
                    <div class="readonly-box" id="create_datetime_disp"></div>
                </div>

                <div class="form-item">
                    <div class="form-label">更新日時</div>
                    <div class="readonly-box" id="update_datetime_disp"></div>
                </div>
            </div>
        </div>

        <div class="section-card <cfif displayMode EQ 'edit'>edit_mode</cfif>">
            <div class="section-title">明細情報</div>

            <div class="table-wrap">
                <table class="detail-table">
                    <thead>
                        <tr>
                            <th class="col-line-no">行</th>
                            <th class="col-item-code">商品コード</th>
                            <th class="col-jan-code">JANコード</th>
                            <th class="col-item-name">商品名</th>
                            <th class="col-qty">数量</th>
                            <th class="col-unit-price">単価</th>
                            <th class="col-amount">金額</th>
                        </tr>
                    </thead>
                    <tbody id="detail_table_body">
                        <tr>
                            <td colspan="7" class="empty-row">読み込み中です...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <cfif displayMode EQ "edit">
                <div class="bottom-save-area">
                    <button type="button" class="save-button primary" id="save_btn">保存</button>
                </div>
            </cfif>
        </div>
    </form>
</div>

<cfoutput>
    <script src="#Application.asset_url#/js/flatpickr.min.js"></script>
    <script src="#Application.asset_url#/js/ja.js"></script>
    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/slip_list_dt.js"></script>
</cfoutput>