<cfinclude template="init.cfm">

<cfset pageTitle = "伝票一覧">
<cfset showHomeButton = true>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>

<cfset initSearchSlipNo = "">
<cfset initSearchOrderDateFrom = "">
<cfset initSearchOrderDateTo = "">
<cfset initSearchDeliveryDateFrom = "">
<cfset initSearchDeliveryDateTo = "">
<cfset initSearchSupplierCode = "">
<cfset initSearchSupplierKeyword = "">
<cfset initSearchItemKeyword = "">
<cfset initSearchStatus = "">
<cfset initCurrentPage = 1>
<cfset initSortField = "">
<cfset initSortOrder = "">

<cfif structKeyExists(form, "return_search_slip_no")>
    <cfset initSearchSlipNo = trim(form.return_search_slip_no)>
</cfif>

<cfif structKeyExists(form, "return_search_order_date_from")>
    <cfset initSearchOrderDateFrom = trim(form.return_search_order_date_from)>
<cfelseif structKeyExists(form, "return_search_slip_date_from")>
    <cfset initSearchOrderDateFrom = trim(form.return_search_slip_date_from)>
</cfif>

<cfif structKeyExists(form, "return_search_order_date_to")>
    <cfset initSearchOrderDateTo = trim(form.return_search_order_date_to)>
<cfelseif structKeyExists(form, "return_search_slip_date_to")>
    <cfset initSearchOrderDateTo = trim(form.return_search_slip_date_to)>
</cfif>

<cfif structKeyExists(form, "return_search_delivery_date_from")>
    <cfset initSearchDeliveryDateFrom = trim(form.return_search_delivery_date_from)>
</cfif>

<cfif structKeyExists(form, "return_search_delivery_date_to")>
    <cfset initSearchDeliveryDateTo = trim(form.return_search_delivery_date_to)>
</cfif>

<cfif structKeyExists(form, "return_search_supplier_code")>
    <cfset initSearchSupplierCode = trim(form.return_search_supplier_code)>
</cfif>

<cfif structKeyExists(form, "return_search_supplier_keyword")>
    <cfset initSearchSupplierKeyword = trim(form.return_search_supplier_keyword)>
</cfif>

<cfif structKeyExists(form, "return_search_item_keyword")>
    <cfset initSearchItemKeyword = trim(form.return_search_item_keyword)>
</cfif>

<cfif structKeyExists(form, "return_search_status")>
    <cfset initSearchStatus = trim(form.return_search_status)>
</cfif>

<cfif structKeyExists(form, "return_current_page")>
    <cfset initCurrentPage = val(form.return_current_page)>
    <cfif initCurrentPage LTE 0>
        <cfset initCurrentPage = 1>
    </cfif>
</cfif>

<cfif structKeyExists(form, "return_sort_field")>
    <cfset initSortField = trim(form.return_sort_field)>
</cfif>

<cfif structKeyExists(form, "return_sort_order")>
    <cfset initSortOrder = trim(form.return_sort_order)>
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

<cfoutput>
    <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
    <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
    <link rel="stylesheet" href="#Application.asset_url#/css/flatpickr.min.css">
</cfoutput>

<style>
    body {
        margin: 0;
        background: #F7F1E3;
        font-family: "Hiragino Sans", "Yu Gothic", "Meiryo", sans-serif;
        color: #2F2A24;
    }

    .page-content {
        max-width: 1540px;
        margin: 24px auto;
        padding: 0 24px 40px;
        box-sizing: border-box;
    }

    .search-area {
        margin-bottom: 24px;
    }

    .search-row {
        display: flex;
        align-items: flex-end;
        gap: 24px;
        flex-wrap: wrap;
        margin-bottom: 16px;
    }

    .search-row:last-child {
        margin-bottom: 0;
    }

    .search-item {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .search-item label {
        font-size: 14px;
        font-weight: bold;
        color: #314E3D;
        min-height: 21px;
    }

    .search-item.slipno-item {
        width: 220px;
    }

    .search-item.date-item {
        width: 360px;
    }

    .search-item.supplier-select-item {
        width: 240px;
    }

    .search-item.supplier-text-item {
        width: 260px;
    }

    .search-item.item-keyword-item {
        width: 320px;
    }

    .search-item.status-item {
        width: 180px;
    }

    .form-control {
        height: 40px;
        padding: 0 12px;
        border: 1px solid #CDBFA8;
        border-radius: 8px;
        background: #FFFFFF;
        color: #2F2A24;
        font-size: 14px;
        box-sizing: border-box;
        width: 100%;
    }

    .date-range {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .date-range .form-control {
        width: 160px;
    }

    .date-separator {
        font-size: 22px;
        color: #314E3D;
        line-height: 1;
    }

    .search-actions {
        display: flex;
        align-items: flex-end;
        gap: 10px;
        margin-left: 0;
    }

    .icon-button {
        width: 42px;
        height: 42px;
        border: none;
        background: transparent;
        cursor: pointer;
        padding: 0;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .icon-button svg {
        width: 36px;
        height: 36px;
        stroke: #4B6653;
    }

    .list-header-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 18px;
        flex-wrap: wrap;
        gap: 16px;
    }

    .page-info {
        font-size: 18px;
        font-weight: bold;
        color: #314E3D;
    }

    .paging-top {
        display: flex;
        align-items: center;
        gap: 14px;
    }

    .paging_button {
        min-width: 95px;
        height: 40px;
        padding: 0 16px;
        border: 1px solid #CDBFA8;
        border-radius: 8px;
        background: #FFFDF8;
        color: #314E3D;
        font-size: 13px;
        font-weight: bold;
        cursor: pointer;
        box-sizing: border-box;
    }

    .paging_button:disabled {
        opacity: 0.45;
        cursor: default;
    }

    .paging_text {
        font-size: 18px;
        font-weight: bold;
        color: #314E3D;
        min-width: 80px;
        text-align: center;
    }

    .table_wrap {
        width: 100%;
        overflow-x: auto;
    }

    .list_table {
        width: 100%;
        min-width: 1320px;
        border-collapse: collapse;
        background: #FFFFFF;
    }

    .list_table thead th {
        background: #E7DFC7;
        color: #314E3D;
        font-size: 13px;
        font-weight: bold;
        border: 1px solid #D1C4AB;
        padding: 12px 10px;
        text-align: center;
        white-space: nowrap;
    }

    .list_table tbody td {
        border: 1px solid #D8CCB7;
        padding: 11px 10px;
        font-size: 13px;
        color: #2F2A24;
        background: #FFFDF8;
        word-break: break-all;
    }

    .list_table tbody tr {
        cursor: pointer;
    }

    .list_table tbody tr:hover td {
        background: #F4EEDC;
    }

    .align-center {
        text-align: center;
    }

    .align-right {
        text-align: right;
    }

    .sort_btn {
        display: inline-block;
        margin-left: 6px;
        cursor: pointer;
        vertical-align: middle;
    }

    .sort_btn img {
        width: 18px;
        height: 18px;
        display: inline-block;
        vertical-align: middle;
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

    .loading_text,
    .error_text,
    .empty-message {
        text-align: center;
        padding: 34px 12px;
        color: #645B50;
        font-size: 14px;
        background: #FFFDF8;
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

    @media screen and (max-width: 1300px) {
        .search-actions {
            margin-left: 0;
        }
    }

    @media screen and (max-width: 900px) {
        .page-content {
            padding: 0 16px 32px;
        }

        .search-row {
            gap: 18px;
        }

        .search-item.slipno-item,
        .search-item.date-item,
        .search-item.supplier-select-item,
        .search-item.supplier-text-item,
        .search-item.item-keyword-item,
        .search-item.status-item {
            width: 100%;
        }

        .date-range .form-control {
            width: calc(50% - 18px);
        }

        .search-actions {
            width: 100%;
            justify-content: flex-end;
        }

        .list-header-row {
            align-items: flex-start;
            flex-direction: column;
        }
    }
</style>

<div class="page-content">
    <form id="master_form" name="master_form" method="post">
        <input type="hidden" id="detail_slip_no" name="detail_slip_no" value="">
        <input type="hidden" id="detail_display_mode" name="detail_display_mode" value="">

        <input type="hidden" id="return_search_slip_no" name="return_search_slip_no" value="">
        <input type="hidden" id="return_search_order_date_from" name="return_search_order_date_from" value="">
        <input type="hidden" id="return_search_order_date_to" name="return_search_order_date_to" value="">
        <input type="hidden" id="return_search_delivery_date_from" name="return_search_delivery_date_from" value="">
        <input type="hidden" id="return_search_delivery_date_to" name="return_search_delivery_date_to" value="">
        <input type="hidden" id="return_search_supplier_code" name="return_search_supplier_code" value="">
        <input type="hidden" id="return_search_supplier_keyword" name="return_search_supplier_keyword" value="">
        <input type="hidden" id="return_search_item_keyword" name="return_search_item_keyword" value="">
        <input type="hidden" id="return_search_status" name="return_search_status" value="">

        <input type="hidden" id="init_current_page" value="<cfoutput>#initCurrentPage#</cfoutput>">
        <input type="hidden" id="init_sort_field" value="<cfoutput>#encodeForHtmlAttribute(initSortField)#</cfoutput>">
        <input type="hidden" id="init_sort_order" value="<cfoutput>#encodeForHtmlAttribute(initSortOrder)#</cfoutput>">

        <div class="search-area">
            <div class="search-row">
                <div class="search-item slipno-item">
                    <label for="search_slip_no">伝票番号</label>
                    <input type="text" id="search_slip_no" class="form-control" value="<cfoutput>#encodeForHtmlAttribute(initSearchSlipNo)#</cfoutput>">
                </div>

                <div class="search-item date-item">
                    <label>発注日</label>
                    <div class="date-range">
                        <input type="text" id="search_order_date_from" class="form-control js-date-picker" placeholder="年 / 月 / 日" value="<cfoutput>#encodeForHtmlAttribute(initSearchOrderDateFrom)#</cfoutput>">
                        <span class="date-separator">～</span>
                        <input type="text" id="search_order_date_to" class="form-control js-date-picker" placeholder="年 / 月 / 日" value="<cfoutput>#encodeForHtmlAttribute(initSearchOrderDateTo)#</cfoutput>">
                    </div>
                </div>

                <div class="search-item date-item">
                    <label>納品日</label>
                    <div class="date-range">
                        <input type="text" id="search_delivery_date_from" class="form-control js-date-picker" placeholder="年 / 月 / 日" value="<cfoutput>#encodeForHtmlAttribute(initSearchDeliveryDateFrom)#</cfoutput>">
                        <span class="date-separator">～</span>
                        <input type="text" id="search_delivery_date_to" class="form-control js-date-picker" placeholder="年 / 月 / 日" value="<cfoutput>#encodeForHtmlAttribute(initSearchDeliveryDateTo)#</cfoutput>">
                    </div>
                </div>
            </div>

            <div class="search-row">
                <div class="search-item supplier-select-item">
                    <label for="search_supplier_code">取引先</label>
                    <select id="search_supplier_code" class="form-control">
                        <option value="">すべて</option>
                        <cfoutput query="qSupplier">
                            <option value="#encodeForHtmlAttribute(supplier_code)#" <cfif initSearchSupplierCode EQ supplier_code>selected</cfif>>
                                #encodeForHtml(supplier_name)#
                            </option>
                        </cfoutput>
                    </select>
                </div>

                <div class="search-item supplier-text-item">
                    <label for="search_supplier_keyword">&nbsp;</label>
                    <input type="text" id="search_supplier_keyword" class="form-control" placeholder="取引先名で絞り込み" value="<cfoutput>#encodeForHtmlAttribute(initSearchSupplierKeyword)#</cfoutput>">
                </div>

                <div class="search-item item-keyword-item">
                    <label for="search_item_keyword">商品</label>
                    <input type="text" id="search_item_keyword" class="form-control" placeholder="商品コード / JANコード / 商品名 / 商品名(カナ)" value="<cfoutput>#encodeForHtmlAttribute(initSearchItemKeyword)#</cfoutput>">
                </div>

                <div class="search-item status-item">
                    <label for="search_status">状態</label>
                    <select id="search_status" class="form-control">
                        <option value="" <cfif initSearchStatus EQ "">selected</cfif>>すべて</option>
                        <option value="1" <cfif initSearchStatus EQ "1">selected</cfif>>登録</option>
                        <option value="2" <cfif initSearchStatus EQ "2">selected</cfif>>確定</option>
                        <option value="3" <cfif initSearchStatus EQ "3">selected</cfif>>削除</option>
                    </select>
                </div>

                <div class="search-actions">
                    <button type="button" class="icon-button" id="search_btn" aria-label="検索">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="7"></circle>
                            <line x1="20" y1="20" x2="16.65" y2="16.65"></line>
                        </svg>
                    </button>

                    <button type="button" class="icon-button" id="clear_btn" aria-label="クリア">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M3 12a9 9 0 1 0 3-6.7"></path>
                            <polyline points="3 3 3 8 8 8"></polyline>
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <div class="loading_indicator" id="loading_indicator">読み込み中です...</div>

        <div class="list-header-row">
            <div class="page-info" id="page_status">1 / 1 ページ</div>

            <div class="paging-top">
                <button type="button" class="paging_button" id="first_page_btn">TOP</button>
                <button type="button" class="paging_button" id="prev_page_btn">Prev</button>
                <div class="paging_text" id="page_number_text">1 / 1</div>
                <button type="button" class="paging_button" id="next_page_btn">Next</button>
                <button type="button" class="paging_button" id="last_page_btn">END</button>
            </div>
        </div>

        <div class="table_wrap">
            <table class="list_table">
                <thead>
                    <tr>
                        <th style="width: 150px;">
                            伝票番号
                            <span class="sort_btn" data-field="slip_no" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                        <th style="width: 150px;">
                            発注日
                            <span class="sort_btn" data-field="slip_date" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                        <th style="width: 150px;">
                            納品日
                            <span class="sort_btn" data-field="delivery_date" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                        <th style="width: 260px;">
                            取引先
                            <span class="sort_btn" data-field="supplier_code" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                        <th style="width: 140px;">
                            合計数量
                            <span class="sort_btn" data-field="total_qty" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                        <th style="width: 140px;">
                            状態
                            <span class="sort_btn" data-field="status" data-sort="none">
                                <cfoutput><img src="#Application.asset_url#/image/sort_default.svg" alt="ソート"></cfoutput>
                            </span>
                        </th>
                    </tr>
                </thead>
                <tbody id="slip_table_body">
                    <tr>
                        <td colspan="6" class="loading_text">読み込み中です...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </form>
</div>

<cfoutput>
    <script src="#Application.asset_url#/js/flatpickr.min.js"></script>
    <script src="#Application.asset_url#/js/ja.js"></script>
    <script src="#Application.asset_url#/js/slip_list.js"></script>
</cfoutput>