<cfinclude template="init.cfm">

<cfset postedItemCode = "">
<cfif StructKeyExists(Form, "item_code")>
    <cfset postedItemCode = Trim(Form.item_code)>
</cfif>

<cfset returnItemCode = "">
<cfif StructKeyExists(Form, "return_item_code") AND Trim(Form.return_item_code) neq "">
    <cfset returnItemCode = Trim(Form.return_item_code)>
</cfif>

<cfset displayMode = "view">
<cfif StructKeyExists(Form, "display_mode") AND Trim(Form.display_mode) neq "">
    <cfset displayMode = LCase(Trim(Form.display_mode))>
</cfif>

<cfif displayMode neq "view" AND displayMode neq "edit" AND displayMode neq "add">
    <cfset displayMode = "view">
</cfif>

<cfset returnTo = "list">
<cfif StructKeyExists(Form, "return_to") AND Trim(Form.return_to) neq "">
    <cfset returnTo = LCase(Trim(Form.return_to))>
</cfif>
<cfif returnTo neq "list" AND returnTo neq "detail">
    <cfset returnTo = "list">
</cfif>

<cfset returnUrl = "m_item.cfm">
<cfif StructKeyExists(Form, "return_url") AND Trim(Form.return_url) neq "">
    <cfset returnUrl = Trim(Form.return_url)>
</cfif>

<cfset returnSearchProductCode = "">
<cfif StructKeyExists(Form, "return_search_product_code")>
    <cfset returnSearchProductCode = Trim(Form.return_search_product_code)>
</cfif>

<cfset returnSearchJanCode = "">
<cfif StructKeyExists(Form, "return_search_jan_code")>
    <cfset returnSearchJanCode = Trim(Form.return_search_jan_code)>
</cfif>

<cfset returnSearchProductName = "">
<cfif StructKeyExists(Form, "return_search_product_name")>
    <cfset returnSearchProductName = Trim(Form.return_search_product_name)>
</cfif>

<cfset returnSortField = "">
<cfif StructKeyExists(Form, "return_sort_field")>
    <cfset returnSortField = Trim(Form.return_sort_field)>
</cfif>

<cfset returnSortOrder = "">
<cfif StructKeyExists(Form, "return_sort_order")>
    <cfset returnSortOrder = LCase(Trim(Form.return_sort_order))>
</cfif>

<cfset returnPage = "1">
<cfif StructKeyExists(Form, "return_page") AND IsNumeric(Form.return_page) AND Val(Form.return_page) gt 0>
    <cfset returnPage = Form.return_page>
</cfif>

<cfset pageTitle = "商品マスタ詳細">
<cfset pageHeading = "商品マスタ詳細">

<cfset showHomeButton = false>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showEditButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>
<cfset showTrashButton = false>
<cfset showCancelButton = false>


<cfif displayMode eq "view">
    <cfset pageTitle = "商品マスタ詳細">
    <cfset pageHeading = "商品マスタ詳細">
    <cfset showBackButton = true>
    <cfif session.authorityLevel eq 9>
      <cfset showNewButton = true>
      <cfset showEditButton = true>
      <cfset showTrashButton = true>
    </cfif>
<cfelseif displayMode eq "edit">
    <cfset pageTitle = "商品マスタ修正">
    <cfset pageHeading = "商品マスタ修正">
    <cfset showCancelButton = true>
<cfelseif displayMode eq "add">
    <cfset pageTitle = "商品マスタ追加">
    <cfset pageHeading = "商品マスタ追加">
    <cfset showCancelButton = true>
</cfif>

<cfset detailItemCode = "">
<cfset detailJanCode = "">
<cfset detailItemName = "">
<cfset detailItemNameKana = "">
<cfset detailGentanka = "">
<cfset detailBaitanka = "">
<cfset detailItemCategory = "">
<cfset detailUseFlag = "1">
<cfset detailCreateDatetime = "">
<cfset detailCreateStaffCode = "">
<cfset detailCreateStaffName = "">
<cfset detailUpdateDatetime = "">
<cfset detailUpdateStaffCode = "">
<cfset detailUpdateStaffName = "">
<cfset detailNotFoundMessage = "">

<cfif postedItemCode neq "" AND displayMode neq "add">
    <cfquery name="qItemDetail">
        SELECT
            item_code,
            jan_code,
            item_name,
            item_name_kana,
            gentanka,
            baitanka,
            item_category,
            use_flag,
            DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
            create_staff_code,
            create_staff_name,
            DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
            update_staff_code,
            update_staff_name
        FROM
            m_item
        WHERE
            item_code = <cfqueryparam value="#postedItemCode#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qItemDetail.recordCount eq 1>
        <cfset detailItemCode = qItemDetail.item_code[1]>
        <cfset detailJanCode = qItemDetail.jan_code[1]>
        <cfset detailItemName = qItemDetail.item_name[1]>
        <cfset detailItemNameKana = qItemDetail.item_name_kana[1]>
        <cfset detailGentanka = qItemDetail.gentanka[1]>
        <cfset detailBaitanka = qItemDetail.baitanka[1]>
        <cfset detailItemCategory = qItemDetail.item_category[1]>
        <cfset detailUseFlag = qItemDetail.use_flag[1]>
        <cfset detailCreateDatetime = qItemDetail.create_datetime_disp[1]>
        <cfset detailCreateStaffCode = qItemDetail.create_staff_code[1]>
        <cfset detailCreateStaffName = qItemDetail.create_staff_name[1]>
        <cfset detailUpdateDatetime = qItemDetail.update_datetime_disp[1]>
        <cfset detailUpdateStaffCode = qItemDetail.update_staff_code[1]>
        <cfset detailUpdateStaffName = qItemDetail.update_staff_name[1]>
    <cfelse>
        <cfset detailNotFoundMessage = "指定された商品が見つかりませんでした。">
    </cfif>
</cfif>

<cfif displayMode eq "add">
    <cfset detailItemCode = "">
    <cfset detailJanCode = "">
    <cfset detailItemName = "">
    <cfset detailItemNameKana = "">
    <cfset detailGentanka = "">
    <cfset detailBaitanka = "">
    <cfset detailItemCategory = "">
    <cfset detailUseFlag = "1">
    <cfset detailCreateDatetime = "">
    <cfset detailCreateStaffCode = "">
    <cfset detailCreateStaffName = "">
    <cfset detailUpdateDatetime = "">
    <cfset detailUpdateStaffCode = "">
    <cfset detailUpdateStaffName = "">
</cfif>

<cfset bodyClass = "">
<cfif displayMode eq "view">
    <cfset bodyClass = "view_mode">
</cfif>

<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#HTMLEditFormat(pageTitle)#</cfoutput></title>
    <cfoutput>
        <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260331_keep_state_1">
    </cfoutput>
    <style>
        body { background-color: #F7F1E3; color: #2F2A24; }
        .dt_wrap { max-width: 1280px; margin: 20px auto 32px; padding: 0 20px; }
        .dt_card { background-color: #FFFFFF; border: 1px solid #CDBFA8; border-radius: 10px; padding: 20px 24px 24px; }
        .dt_header_row { display: flex; justify-content: space-between; align-items: flex-start; gap: 24px; margin-bottom: 16px; }
        .dt_title_area { display: flex; align-items: center; gap: 12px; min-height: 32px; }
        .dt_title { margin: 0; color: #2E4136; font-size: 24px; }
        .mode_badge {
            display: inline-block;
            min-width: 88px;
            padding: 5px 10px;
            border-radius: 999px;
            text-align: center;
            font-size: 12px;
            font-weight: bold;
            background-color: #EFE5D1;
            color: #2E4136;
        }
        .meta_box { min-width: 350px; max-width: 430px; font-size: 12px; color: #645B50; line-height: 1.6; }
        .meta_line { display: flex; gap: 10px; }
        .meta_label { width: 110px; flex-shrink: 0; font-weight: bold; color: #2E4136; }
        .meta_value { word-break: break-all; }
        .message_area { display: none; margin-bottom: 14px; padding: 10px 12px; border-radius: 8px; font-weight: bold; font-size: 14px; }
        .message_area.is-show { display: block; }
        .message_error { background-color: #FDECEC; border: 1px solid #E6BBBB; color: #B84A4A; }
        .loading_area { display: none; margin-bottom: 14px; padding: 10px 12px; border: 1px solid #CDBFA8; border-radius: 8px; background-color: #F5EEDC; color: #2E4136; font-size: 14px; font-weight: bold; }
        .loading_area.is-show { display: block; }
        .form_grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 20px; align-items: start; }
        .form_item { display: grid; grid-template-columns: 130px 1fr; gap: 10px; align-items: center; }
        .form_label { font-weight: bold; color: #2E4136; font-size: 14px; }
        .required_mark { margin-left: 4px; color: #B84A4A; font-size: 11px; }
        .form_value input, .form_value select {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #CDBFA8;
            border-radius: 6px;
            background-color: #FFFFFF;
            color: #2F2A24;
            font-size: 14px;
            padding: 8px 10px;
        }
        .view_mode .form_value input,
        .view_mode .form_value select {
            background-color: #F5F0E6;
            pointer-events: none;
        }
        .button_area { display: flex; justify-content: center; gap: 12px; margin-top: 22px; flex-wrap: wrap; }
        .normal_btn {
            min-width: 130px;
            height: 40px;
            border: 1px solid #CDBFA8;
            border-radius: 6px;
            background: #FFFFFF;
            color: #2E4136;
            font-weight: bold;
            cursor: pointer;
            padding: 0 14px;
        }
        .normal_btn:hover:not(:disabled) { background: #EFE5D1; }
    </style>
</head>

<cfoutput>
<body class="#bodyClass#">
    <cfinclude template="header.cfm">

    <div class="dt_wrap">
        <div class="dt_card" id="dt_card">
            <div class="dt_header_row">
                <div class="dt_title_area">
                </div>

                <div class="meta_box">
                    <cfif displayMode neq "add">
                        <div class="meta_line">
                            <div class="meta_label">作成日時</div>
                            <div class="meta_value">#HTMLEditFormat(detailCreateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">作成者</div>
                            <div class="meta_value">#HTMLEditFormat(detailCreateStaffCode)# #HTMLEditFormat(detailCreateStaffName)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新日時</div>
                            <div class="meta_value">#HTMLEditFormat(detailUpdateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新者</div>
                            <div class="meta_value">#HTMLEditFormat(detailUpdateStaffCode)# #HTMLEditFormat(detailUpdateStaffName)#</div>
                        </div>
                    </cfif>
                </div>
            </div>

            <div id="message_area" class="message_area<cfif detailNotFoundMessage neq ""> is-show message_error</cfif>">#HTMLEditFormat(detailNotFoundMessage)#</div>
            <div id="loading_area" class="loading_area">処理中です...</div>

            <form id="master_form" onsubmit="return false;">
                <input type="hidden" id="item_code" name="item_code" value="#HTMLEditFormat(detailItemCode)#">
                <input type="hidden" id="return_item_code" name="return_item_code" value="#HTMLEditFormat(returnItemCode)#">
                <input type="hidden" id="display_mode" name="display_mode" value="#HTMLEditFormat(displayMode)#">
                <input type="hidden" id="return_to" name="return_to" value="#HTMLEditFormat(returnTo)#">
                <input type="hidden" id="return_url" name="return_url" value="#HTMLEditFormat(returnUrl)#">

                <input type="hidden" id="return_search_product_code" name="return_search_product_code" value="#HTMLEditFormat(returnSearchProductCode)#">
                <input type="hidden" id="return_search_jan_code" name="return_search_jan_code" value="#HTMLEditFormat(returnSearchJanCode)#">
                <input type="hidden" id="return_search_product_name" name="return_search_product_name" value="#HTMLEditFormat(returnSearchProductName)#">
                <input type="hidden" id="return_sort_field" name="return_sort_field" value="#HTMLEditFormat(returnSortField)#">
                <input type="hidden" id="return_sort_order" name="return_sort_order" value="#HTMLEditFormat(returnSortOrder)#">
                <input type="hidden" id="return_page" name="return_page" value="#HTMLEditFormat(returnPage)#">

                <div class="form_grid">
                    <div class="form_item">
                        <div class="form_label">商品コード<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="input_item_code" name="input_item_code" maxlength="20" value="#HTMLEditFormat(detailItemCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">JAN</div>
                        <div class="form_value">
                            <input type="text" id="jan_code" name="jan_code" maxlength="20" value="#HTMLEditFormat(detailJanCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">商品名<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="item_name" name="item_name" maxlength="100" value="#HTMLEditFormat(detailItemName)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">商品名カナ</div>
                        <div class="form_value">
                            <input type="text" id="item_name_kana" name="item_name_kana" maxlength="100" value="#HTMLEditFormat(detailItemNameKana)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">原価</div>
                        <div class="form_value">
                            <input type="text" id="gentanka" name="gentanka" step="0.01" value="#HTMLEditFormat(detailGentanka)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">売価</div>
                        <div class="form_value">
                            <input type="text" id="baitanka" name="baitanka" step="0.01" value="#HTMLEditFormat(detailBaitanka)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">分類</div>
                        <div class="form_value">
                            <select id="item_category" name="item_category" class="form-control form-select">
                                <option value=""<cfif detailItemCategory eq ""> selected</cfif>>選択してください</option>
                                <option value="1"<cfif detailItemCategory eq "1" OR detailItemCategory eq 1> selected</cfif>>食品</option>
                                <option value="2"<cfif detailItemCategory eq "2" OR detailItemCategory eq 2> selected</cfif>>雑貨</option>
                                <option value="3"<cfif detailItemCategory eq "3" OR detailItemCategory eq 3> selected</cfif>>日用品</option>
                                <option value="4"<cfif detailItemCategory eq "4" OR detailItemCategory eq 4> selected</cfif>>衣料</option>
                                <option value="5"<cfif detailItemCategory eq "5" OR detailItemCategory eq 5> selected</cfif>>小物</option>
                            </select>
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">使用区分</div>
                        <div class="form_value">
                            <select id="use_flag" name="use_flag" class="form-control form-select">
                                <option value="1"<cfif detailUseFlag eq "1"> selected</cfif>>有効</option>
                                <option value="0"<cfif detailUseFlag eq "0"> selected</cfif>>無効</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="button_area">
                    <button type="button" id="save_btn" class="normal_btn">保存</button>
                </div>
            </form>
        </div>
    </div>

    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/m_item_dt.js?20260331_keep_state_1"></script>
</body>
</cfoutput>
</html>