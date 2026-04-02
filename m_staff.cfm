<cfinclude template="init.cfm">

<cfset pageTitle = "社員マスタ一覧">
<cfset showHomeButton = true>

<cfif session.authorityLevel eq 9>
    <cfset showExportButton = true> 
    <cfset showNewButton = true>
<cfelse>
    <cfset showExportButton = false> 
    <cfset showNewButton = false>
</cfif>

<cfset formSearchStaffCode = "">
<cfif StructKeyExists(Form, "search_staff_code")>
    <cfset formSearchStaffCode = Trim(Form.search_staff_code)>
</cfif>

<cfset formSearchStaffName = "">
<cfif StructKeyExists(Form, "search_staff_name")>
    <cfset formSearchStaffName = Trim(Form.search_staff_name)>
</cfif>

<cfset formSearchMailAddress = "">
<cfif StructKeyExists(Form, "search_mail_address")>
    <cfset formSearchMailAddress = Trim(Form.search_mail_address)>
</cfif>

<cfset formSearchAuthorityLevel = "">
<cfif StructKeyExists(Form, "search_authority_level")>
    <cfset formSearchAuthorityLevel = Trim(Form.search_authority_level)>
</cfif>

<cfset formSearchUseFlag = "">
<cfif StructKeyExists(Form, "search_use_flag") AND (Form.search_use_flag eq "0" OR Form.search_use_flag eq "1")>
    <cfset formSearchUseFlag = Form.search_use_flag>
</cfif>

<cfset formSortField = "">
<cfif StructKeyExists(Form, "sort_field")>
    <cfset formSortField = Trim(Form.sort_field)>
</cfif>

<cfset formSortOrder = "">
<cfif StructKeyExists(Form, "sort_order")>
    <cfset formSortOrder = LCase(Trim(Form.sort_order))>
</cfif>

<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>社員マスタ一覧</title>
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
            margin-bottom: 12px;
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
            white-space: nowrap;
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

        .use_flag_badge,
        .authority_badge {
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

        .authority_admin {
            background-color: #E8EAF6;
            color: #3949AB;
        }

        .authority_manager {
            background-color: #FFF3E0;
            color: #EF6C00;
        }

        .authority_general {
            background-color: #ECEFF1;
            color: #546E7A;
        }

        .staff_table_body .staff_row {
            cursor: pointer;
        }

        .staff_table_body .staff_row:hover {
            background-color: #FFFCF4;
        }
    </style>
</head>
<body>
<cfoutput>

<cfinclude template="header.cfm">

<form id="master_form" method="post" class="search_form">

    <input type="hidden" id="detail_staff_code" name="staff_code" value="">
    <input type="hidden" id="detail_return_staff_code" name="return_staff_code" value="">
    <input type="hidden" id="detail_display_mode" name="display_mode" value="view">

    <input type="hidden" id="return_sort_field" name="return_sort_field" value="#HTMLEditFormat(formSortField)#">
    <input type="hidden" id="return_sort_order" name="return_sort_order" value="#HTMLEditFormat(formSortOrder)#">

    <input type="hidden" id="return_search_staff_code" name="return_search_staff_code" value="#HTMLEditFormat(formSearchStaffCode)#">
    <input type="hidden" id="return_search_staff_name" name="return_search_staff_name" value="#HTMLEditFormat(formSearchStaffName)#">
    <input type="hidden" id="return_search_mail_address" name="return_search_mail_address" value="#HTMLEditFormat(formSearchMailAddress)#">
    <input type="hidden" id="return_search_authority_level" name="return_search_authority_level" value="#HTMLEditFormat(formSearchAuthorityLevel)#">
    <input type="hidden" id="return_search_use_flag" name="return_search_use_flag" value="#HTMLEditFormat(formSearchUseFlag)#">

    <div class="wrap">

        <div class="search_area" style="display:flex; margin-top:30px; flex-wrap:wrap;">
            <div class="search_item">
                <label for="search_staff_code">社員コード</label>
                <input type="text" id="search_staff_code" name="search_staff_code" placeholder="社員コード" value="#HTMLEditFormat(formSearchStaffCode)#" style="width:180px;">
            </div>

            <div class="search_item">
                <label for="search_staff_name">社員名</label>
                <input type="text" id="search_staff_name" name="search_staff_name" placeholder="社員名 / 社員名(カナ)" value="#HTMLEditFormat(formSearchStaffName)#" style="width:250px;">
            </div>

            <div class="search_item">
                <label for="search_mail_address">メールアドレス</label>
                <input type="text" id="search_mail_address" name="search_mail_address" placeholder="メールアドレス" value="#HTMLEditFormat(formSearchMailAddress)#" style="width:300px;">
            </div>

            <div class="search_item">
                <label for="search_authority_level">権限</label>
                <select id="search_authority_level" name="search_authority_level" style="width:120px;">
                    <option value="">すべて</option>
                    <option value="1">一般</option>
                    <option value="9">管理者</option>
                </select>
            </div>

            <div class="search_item">
                <label for="search_use_flag">使用区分</label>
                <select id="search_use_flag" name="search_use_flag" style="width:120px;">
                    <option value="">すべて</option>
                    <option value="1">使用中</option>
                    <option value="0">停止</option>
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
                    <table class="list_table staff_table">
                        <thead>
                            <tr>
                                <th style="width:50px;">
                                    社員コード
                                    <span class="sort_btn" data-field="staff_code" data-sort="none">
                                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                                    </span>
                                </th>
                                <th style="width:auto">
                                    社員名
                                    <span class="sort_btn" data-field="staff_name" data-sort="none">
                                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                                    </span>
                                </th>
                                <th style="width:100px;">
                                    権限
                                    <span class="sort_btn" data-field="authority_level" data-sort="none">
                                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                                    </span>
                                </th>
                                <th style="width:340px;">
                                    メールアドレス
                                    <span class="sort_btn" data-field="mail_address" data-sort="none">
                                        <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                                    </span>
                                </th>
                                <th style="width:80px;">
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

                        <tbody id="staff_table_body" class="staff_table_body">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</form>

<script>
document.getElementById("search_authority_level").value = "#JSStringFormat(formSearchAuthorityLevel)#";
document.getElementById("search_use_flag").value = "#JSStringFormat(formSearchUseFlag)#";
document.getElementById("return_sort_field").value = "#JSStringFormat(formSortField)#";
document.getElementById("return_sort_order").value = "#JSStringFormat(formSortOrder)#";
</script>

<script src="#Application.asset_url#/js/m_staff.js?20260331_1"></script>

</cfoutput>
</body>
</html>