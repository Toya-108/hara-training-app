<cfinclude template="init.cfm">

<cfset pageTitle = "取引先マスタ一覧">
<cfset showBackButton = true>
<cfset showNewButton = true>
<!--- <cfset showImportButton = true> --->
<cfset showExportButton = true>

<!--- =========================
      配送業者マスタ取得
      ========================= --->
<cfquery name="qDeliveryCompany">
    SELECT
        delivery_company_code,
        delivery_company_name
    FROM
        m_delivery_company
    WHERE
        use_flag = 1
    ORDER BY
        delivery_company_name ASC
</cfquery>

<cfset formSearchSupplierCode = "">
<cfif StructKeyExists(Form, "search_supplier_code")>
    <cfset formSearchSupplierCode = Trim(Form.search_supplier_code)>
</cfif>

<cfset formSearchSupplierName = "">
<cfif StructKeyExists(Form, "search_supplier_name")>
    <cfset formSearchSupplierName = Trim(Form.search_supplier_name)>
</cfif>

<!--- delivery_company_code を持つ --->
<cfset formSearchDeliveryCompany = "">
<cfif StructKeyExists(Form, "search_delivery_company")>
    <cfset formSearchDeliveryCompany = Trim(Form.search_delivery_company)>
</cfif>

<cfset formSearchUseFlag = "">
<cfif StructKeyExists(Form, "search_use_flag") AND (Form.search_use_flag eq "0" OR Form.search_use_flag eq "1")>
    <cfset formSearchUseFlag = Form.search_use_flag>
</cfif>

<html lang="ja">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>取引先マスタ一覧</title>
    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
    </cfoutput>

    <style>
        body {
        background-color: #F7F1E3;
        color: #2F2A24;
        }

        .search_area {
        margin-left: 60px;
        }

        .search_item {
        margin-left: 20px;
        margin-right: 20px;
        }

        .search_item label {
        display: block;
        margin-bottom: 6px;
        font-size: 14px;
        font-weight: bold;
        color: #2E4136;
        }

        .search_item input,
        .search_item select {
        height: 34px;
        padding: 0 14px;
        border: 1px solid #CDBFA8;
        border-radius: 5px;
        font-size: 15px;
        background-color: #FFFFFF;
        color: #2F2A24;
        box-sizing: border-box;
        }

        .search_item input:focus,
        .search_item select:focus {
        border-color: #3F5B4B;
        background-color: #FFFCF4;
        box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
        outline: none;
        }

        .search_item input::placeholder {
        color: #8A8175;
        }

        .search_btn_area {
        display: flex;
        align-items: flex-end;
        gap: 10px;
        }

        .icon_btn {
        background: transparent;
        border: none;
        cursor: pointer;
        padding: 0;
        border-radius: 6px;
        }

        .icon_btn:hover {
        background: #EFE5D1;
        }

        .search_btn img {
        width: 40px;
        height: 40px;
        display: block;
        }

        .table_scroll {
        max-height: 65%;
        overflow-y: auto;
        overflow-x: auto;
        }

        .table_div {
        margin: 0 80px 80px;
        }

        .list_table {
        width: 100%;
        border-collapse: collapse;
        background-color: #FFFFFF;
        }

        .list_table th,
        .list_table td {
        border: 1px solid #CDBFA8;
        padding: 8px 10px;
        }

        .list_table th {
        background: #EFE5D1;
        color: #2E4136;
        position: sticky;
        top: 0;
        z-index: 1;
        }

        .list_table td {
        color: #2F2A24;
        white-space: nowrap;
        }

        .paging_info_area {
        margin: 24px 80px 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        }

        .page_status {
        font-size: 16px;
        font-weight: bold;
        color: #2E4136;
        }

        .paging_dummy {
        display: flex;
        align-items: center;
        gap: 10px;
        }

        .paging_btn {
        min-width: 80px;
        height: 34px;
        border: 1px solid #CDBFA8;
        border-radius: 6px;
        background: #FFFFFF;
        color: #2E4136;
        cursor: pointer;
        padding: 0 12px;
        }

        .paging_btn:hover:not(:disabled) {
        background: #EFE5D1;
        }

        .paging_btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        }

        .page_number_text {
        min-width: 90px;
        text-align: center;
        color: #2E4136;
        font-weight: bold;
        }

        .loading_text {
        text-align: center;
        color: #645B50;
        }

        .error_text {
        text-align: center;
        color: #B84A4A;
        }

        .sort_btn {
        display: inline-flex;
        align-items: center;
        cursor: pointer;
        margin-left: 4px;
        }

        .sort_btn.active img {
        opacity: 1;
        }

        .sort_btn:hover img {
        opacity: 0.8;
        }

        .sort_btn img {
        width: 14px;
        height: 14px;
        vertical-align: middle;
        }

        .loading_indicator {
        display: none;
        margin: 16px 80px 0;
        padding: 10px 14px;
        border: 1px solid #CDBFA8;
        border-radius: 8px;
        background-color: #F5EEDC;
        color: #2E4136;
        font-size: 14px;
        font-weight: bold;
        }

        .loading_indicator.is-visible {
        display: block;
        }

        .use_flag_badge {
        display: inline-block;
        min-width: 52px;
        padding: 2px 8px;
        border-radius: 999px;
        text-align: center;
        font-size: 12px;
        font-weight: bold;
        }

        .use_flag_on {
        background-color: #E6F4EA;
        color: #2E7D32;
        }

        .use_flag_off {
        background-color: #FDECEC;
        color: #C62828;
        }

        .supplier_table_body .supplier_row {
            cursor: pointer;
        }

        .supplier_table_body .supplier_row:hover {
            background-color: #FFFCF4;
        }
    </style>
    </head>
    <body>
    <cfoutput>

    <cfinclude template="header.cfm">

    <form id="master_form" method="post" class="search_form">

        <input type="hidden" id="detail_supplier_code" name="supplier_code" value="">
        <input type="hidden" id="detail_display_mode" name="display_mode" value="view">

        <input type="hidden" id="return_search_supplier_code" name="return_search_supplier_code" value="#HTMLEditFormat(formSearchSupplierCode)#">
        <input type="hidden" id="return_search_supplier_name" name="return_search_supplier_name" value="#HTMLEditFormat(formSearchSupplierName)#">
        <input type="hidden" id="return_search_delivery_company" name="return_search_delivery_company" value="#HTMLEditFormat(formSearchDeliveryCompany)#">
        <input type="hidden" id="return_search_use_flag" name="return_search_use_flag" value="#HTMLEditFormat(formSearchUseFlag)#">

        <div class="wrap">

        <div class="search_area" style="display:flex; margin-top:30px; flex-wrap:wrap;">
            <div class="search_item">
            <label for="search_supplier_code">取引先コード</label>
            <input type="text" id="search_supplier_code" name="search_supplier_code" placeholder="取引先コードを入力" value="#HTMLEditFormat(formSearchSupplierCode)#">
            </div>

            <div class="search_item">
            <label for="search_supplier_name">取引先名</label>
            <input type="text" id="search_supplier_name" name="search_supplier_name" placeholder="取引先名を入力" value="#HTMLEditFormat(formSearchSupplierName)#" style="width:250px;">
            </div>

            <div class="search_item">
            <label for="search_delivery_company">配送業者</label>
            <select id="search_delivery_company" name="search_delivery_company" style="width:200px;">
                <option value="">すべて</option>
                <cfloop query="qDeliveryCompany">
                    <option value="#HTMLEditFormat(qDeliveryCompany.delivery_company_code)#"<cfif formSearchDeliveryCompany eq qDeliveryCompany.delivery_company_code> selected</cfif>>
                        #HTMLEditFormat(qDeliveryCompany.delivery_company_name)#
                    </option>
                </cfloop>
            </select>
            </div>

            <div class="search_item">
            <label for="search_use_flag">使用区分</label>
            <select id="search_use_flag" name="search_use_flag" style="width:120px;">
                <option value="">すべて</option>
                <option value="1"<cfif formSearchUseFlag eq "1"> selected</cfif>>有効</option>
                <option value="0"<cfif formSearchUseFlag eq "0"> selected</cfif>>無効</option>
            </select>
            </div>

            <div class="search_btn_area" style="display:flex;">
            <button type="button" id="search_btn" class="icon_btn search_btn" title="検索">
                <img src="#Application.asset_url#/image/search-icon.svg" alt="検索">
            </button>
            <button type="button" id="clear_btn" class="icon_btn search_btn clear_btn" title="クリア">
                <img src="#Application.asset_url#/image/clear-icon.svg" alt="クリア">
            </button>
            </div>
        </div>

        <div class="paging_info_area">
            <div id="page_status" class="page_status">1 / 1 ページ</div>

            <div class="paging_dummy">
            <button type="button" id="first_page_btn" class="paging_btn">TOP</button>
            <button type="button" id="prev_page_btn" class="paging_btn">Prev</button>
            <div id="page_number_text" class="page_number_text">1 / 1</div>
            <button type="button" id="next_page_btn" class="paging_btn">Next</button>
            <button type="button" id="last_page_btn" class="paging_btn">END</button>
            </div>
        </div>

        <div id="loading_indicator" class="loading_indicator">
            読み込み中です...
        </div>

        <div style="margin-top:30px;">
            <div class="table_div">
            <div class="table_scroll">
                <table class="list_table supplier_table">
                <thead>
                    <tr>
                    <th style="width:130px;">
                        取引先コード
                        <span class="sort_btn" data-field="supplier_code" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    <th style="width:auto">
                        取引先名
                        <span class="sort_btn" data-field="supplier_name" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    <th style="width:180px;">
                        配送業者名
                        <span class="sort_btn" data-field="delivery_company" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    <th style="width:90px;">
                        使用区分
                        <span class="sort_btn" data-field="use_flag" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    <th style="width:120px;">
                        作成日時
                        <span class="sort_btn" data-field="create_datetime" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    <th style="width:120px;">
                        更新日時
                        <span class="sort_btn" data-field="update_datetime" data-sort="none">
                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                    </th>
                    </tr>
                </thead>

                <tbody id="supplier_table_body" class="supplier_table_body">
                </tbody>
                </table>
            </div>
            </div>
        </div>

        </div>
    </form>

    <script src="#Application.asset_url#/js/m_supplier.js?20260325_6"></script>
    </cfoutput>
    </body>
</html>