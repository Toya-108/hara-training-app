<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<cfset postedDeliveryCompanyCode = "">
<cfif StructKeyExists(Form, "delivery_company_code")>
    <cfset postedDeliveryCompanyCode = Trim(Form.delivery_company_code)>
</cfif>

<cfset returnDeliveryCompanyCode = "">
<cfif StructKeyExists(Form, "return_delivery_company_code")>
    <cfset returnDeliveryCompanyCode = Trim(Form.return_delivery_company_code)>
</cfif>

<cfset sourcePage = "list">
<cfif StructKeyExists(Form, "source_page") AND Trim(Form.source_page) neq "">
    <cfset sourcePage = LCase(Trim(Form.source_page))>
</cfif>

<cfif sourcePage neq "list" AND sourcePage neq "detail">
    <cfset sourcePage = "list">
</cfif>

<cfset sourceDeliveryCompanyCode = "">
<cfif StructKeyExists(Form, "source_delivery_company_code")>
    <cfset sourceDeliveryCompanyCode = Trim(Form.source_delivery_company_code)>
</cfif>

<cfset displayMode = "view">
<cfif StructKeyExists(Form, "display_mode") AND Trim(Form.display_mode) neq "">
    <cfset displayMode = LCase(Trim(Form.display_mode))>
</cfif>

<cfif displayMode neq "view" AND displayMode neq "edit" AND displayMode neq "add">
    <cfset displayMode = "view">
</cfif>

<cfset returnPage = "1">
<cfif StructKeyExists(Form, "return_page") AND IsNumeric(Form.return_page) AND Val(Form.return_page) gt 0>
    <cfset returnPage = Trim(Form.return_page)>
</cfif>

<cfset returnSearchDeliveryCompanyCode = "">
<cfif StructKeyExists(Form, "return_search_delivery_company_code")>
    <cfset returnSearchDeliveryCompanyCode = Trim(Form.return_search_delivery_company_code)>
</cfif>

<cfset returnSearchDeliveryCompanyName = "">
<cfif StructKeyExists(Form, "return_search_delivery_company_name")>
    <cfset returnSearchDeliveryCompanyName = Trim(Form.return_search_delivery_company_name)>
</cfif>

<cfset returnSearchUseFlag = "">
<cfif StructKeyExists(Form, "return_search_use_flag") AND (Form.return_search_use_flag eq "0" OR Form.return_search_use_flag eq "1")>
    <cfset returnSearchUseFlag = Trim(Form.return_search_use_flag)>
</cfif>

<cfset returnSortField = "">
<cfif StructKeyExists(Form, "return_sort_field")>
    <cfset returnSortField = Trim(Form.return_sort_field)>
</cfif>

<cfset returnSortOrder = "">
<cfif StructKeyExists(Form, "return_sort_order")>
    <cfset returnSortOrder = LCase(Trim(Form.return_sort_order))>
</cfif>

<cfset targetDeliveryCompanyCode = "">
<cfif returnDeliveryCompanyCode neq "">
    <cfset targetDeliveryCompanyCode = returnDeliveryCompanyCode>
<cfelseif postedDeliveryCompanyCode neq "">
    <cfset targetDeliveryCompanyCode = postedDeliveryCompanyCode>
</cfif>

<cfset pageTitle = "配送業者マスタ詳細">
<cfset pageHeading = "配送業者マスタ詳細">

<cfset showHomeButton = false>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showEditButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>
<cfset showTrashButton = false>
<cfset showCancelButton = false>

<cfif displayMode eq "view">
    <cfset pageTitle = "配送業者マスタ詳細">
    <cfset pageHeading = "配送業者マスタ詳細">
    <cfset showBackButton = true>
    <cfif session.authorityLevel eq 9>
        <cfset showNewButton = true>
        <cfset showEditButton = true>
        <cfset showTrashButton = true>
    </cfif>
<cfelseif displayMode eq "edit">
    <cfset pageTitle = "配送業者マスタ修正">
    <cfset pageHeading = "配送業者マスタ修正">
    <cfset showCancelButton = true>
<cfelseif displayMode eq "add">
    <cfset pageTitle = "配送業者マスタ追加">
    <cfset pageHeading = "配送業者マスタ追加">
    <cfset showCancelButton = true>
</cfif>

<cfset detailOriginalDeliveryCompanyCode = "">
<cfset detailDeliveryCompanyCode = "">
<cfset detailDeliveryCompanyName = "">
<cfset detailNote = "">
<cfset detailUseFlag = "1">
<cfset detailCreateDatetime = "">
<cfset detailCreateStaffCode = "">
<cfset detailCreateStaffName = "">
<cfset detailUpdateDatetime = "">
<cfset detailUpdateStaffCode = "">
<cfset detailUpdateStaffName = "">
<cfset detailNotFoundMessage = "">

<cfif displayMode neq "add" AND targetDeliveryCompanyCode neq "">
    <cfquery name="qDeliveryCompanyDetail">
        SELECT
            delivery_company_code,
            delivery_company_name,
            note,
            use_flag,
            DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
            create_staff_code,
            create_staff_name,
            DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
            update_staff_code,
            update_staff_name
        FROM
            m_delivery_company
        WHERE
            delivery_company_code = <cfqueryparam value="#targetDeliveryCompanyCode#" cfsqltype="cf_sql_char">
    </cfquery>

    <cfif qDeliveryCompanyDetail.recordCount eq 1>
        <cfset detailOriginalDeliveryCompanyCode = qDeliveryCompanyDetail.delivery_company_code[1]>
        <cfset detailDeliveryCompanyCode = qDeliveryCompanyDetail.delivery_company_code[1]>
        <cfset detailDeliveryCompanyName = qDeliveryCompanyDetail.delivery_company_name[1]>
        <cfset detailNote = qDeliveryCompanyDetail.note[1]>
        <cfset detailUseFlag = qDeliveryCompanyDetail.use_flag[1]>
        <cfset detailCreateDatetime = qDeliveryCompanyDetail.create_datetime_disp[1]>
        <cfset detailCreateStaffCode = qDeliveryCompanyDetail.create_staff_code[1]>
        <cfset detailCreateStaffName = qDeliveryCompanyDetail.create_staff_name[1]>
        <cfset detailUpdateDatetime = qDeliveryCompanyDetail.update_datetime_disp[1]>
        <cfset detailUpdateStaffCode = qDeliveryCompanyDetail.update_staff_code[1]>
        <cfset detailUpdateStaffName = qDeliveryCompanyDetail.update_staff_name[1]>
    <cfelse>
        <cfset detailNotFoundMessage = "指定された配送業者が見つかりませんでした。">
    </cfif>
</cfif>

<cfset displayOriginalDeliveryCompanyCode = detailOriginalDeliveryCompanyCode>
<cfset displayDeliveryCompanyCode = detailDeliveryCompanyCode>
<cfset displayDeliveryCompanyName = detailDeliveryCompanyName>
<cfset displayNote = detailNote>
<cfset displayUseFlag = detailUseFlag>
<cfset displayCreateDatetime = detailCreateDatetime>
<cfset displayCreateStaffCode = detailCreateStaffCode>
<cfset displayCreateStaffName = detailCreateStaffName>
<cfset displayUpdateDatetime = detailUpdateDatetime>
<cfset displayUpdateStaffCode = detailUpdateStaffCode>
<cfset displayUpdateStaffName = detailUpdateStaffName>

<cfif displayMode eq "add">
    <cfset displayOriginalDeliveryCompanyCode = "">
    <cfset displayDeliveryCompanyCode = "">
    <cfset displayDeliveryCompanyName = "">
    <cfset displayNote = "">
    <cfset displayUseFlag = "1">
    <cfset displayCreateDatetime = "">
    <cfset displayCreateStaffCode = "">
    <cfset displayCreateStaffName = "">
    <cfset displayUpdateDatetime = "">
    <cfset displayUpdateStaffCode = "">
    <cfset displayUpdateStaffName = "">
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
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260403_1">
    </cfoutput>

    <style>
        body {
            background-color: #F7F1E3;
            color: #2F2A24;
        }

        .dt_wrap {
            max-width: 1280px;
            margin: 20px auto 32px;
            padding: 0 20px;
        }

        .dt_card {
            background-color: #FFFFFF;
            border: 1px solid #CDBFA8;
            border-radius: 10px;
            padding: 20px 24px 24px;
        }

        .dt_header_row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 24px;
            margin-bottom: 16px;
        }

        .dt_title_area {
            display: flex;
            align-items: center;
            gap: 12px;
            min-height: 32px;
        }

        .dt_title {
            margin: 0;
            color: #2E4136;
            font-size: 24px;
        }

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

        .meta_box {
            min-width: 350px;
            max-width: 430px;
            font-size: 12px;
            color: #645B50;
            line-height: 1.6;
        }

        .meta_line {
            display: flex;
            gap: 10px;
        }

        .meta_label {
            width: 78px;
            flex-shrink: 0;
            font-weight: bold;
            color: #2E4136;
        }

        .meta_value {
            word-break: break-all;
        }

        .message_area {
            display: none;
            margin-bottom: 14px;
            padding: 10px 12px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14px;
        }

        .message_area.is-show {
            display: block;
        }

        .message_success {
            background-color: #E6F4EA;
            border: 1px solid #B7DFC2;
            color: #2E7D32;
        }

        .message_error {
            background-color: #FDECEC;
            border: 1px solid #E6BBBB;
            color: #B84A4A;
        }

        .loading_area {
            display: none;
            margin-bottom: 14px;
            padding: 10px 12px;
            border: 1px solid #CDBFA8;
            border-radius: 8px;
            background-color: #F5EEDC;
            color: #2E4136;
            font-size: 14px;
            font-weight: bold;
        }

        .loading_area.is-show {
            display: block;
        }

        .form_grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px 20px;
            align-items: start;
        }

        .form_item {
            display: grid;
            grid-template-columns: 130px 1fr;
            gap: 10px;
            align-items: center;
        }

        .form_item.wide {
            grid-column: 1 / span 2;
        }

        .form_label {
            font-weight: bold;
            color: #2E4136;
            font-size: 14px;
        }

        .required_mark {
            margin-left: 4px;
            color: #B84A4A;
            font-size: 11px;
        }

        .form_value input,
        .form_value select,
        .form_value textarea {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #CDBFA8;
            border-radius: 6px;
            background-color: #FFFFFF;
            color: #2F2A24;
            font-size: 14px;
            padding: 8px 10px;
        }

        .form_value input:focus,
        .form_value select:focus,
        .form_value textarea:focus {
            border-color: #3F5B4B;
            background-color: #FFFCF4;
            box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
            outline: none;
        }

        .form_value textarea {
            min-height: 68px;
            resize: vertical;
        }

        .readonly_input {
            background-color: #F5F0E6 !important;
        }

        .view_mode .form_value input,
        .view_mode .form_value textarea {
            background-color: #F5F0E6;
            pointer-events: none;
        }

        .button_area {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 22px;
            flex-wrap: wrap;
        }

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

        .normal_btn:hover:not(:disabled) {
            background: #EFE5D1;
        }

        .normal_btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .use-badge {
            display: inline-block;
            min-width: 70px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
        }

        .use-1 {
            background: #DCEBDC;
            color: #2F6A40;
        }

        .use-0 {
            background: #FDECEB;
            color: #C62828;
        }

        @media (max-width: 900px) {
            .dt_header_row {
                flex-direction: column;
            }

            .meta_box {
                min-width: auto;
                max-width: none;
                width: 100%;
            }

            .form_grid {
                grid-template-columns: 1fr;
            }

            .form_item,
            .form_item.wide {
                grid-column: auto;
                grid-template-columns: 1fr;
            }
        }
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
                            <div id="create_datetime" class="meta_value">#HTMLEditFormat(displayCreateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">作成者</div>
                            <div class="meta_value">
                                <span id="create_staff_code">#HTMLEditFormat(displayCreateStaffCode)#</span>
                                <span id="create_staff_name">#HTMLEditFormat(displayCreateStaffName)#</span>
                            </div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新日時</div>
                            <div id="update_datetime" class="meta_value">#HTMLEditFormat(displayUpdateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新者</div>
                            <div class="meta_value">
                                <span id="update_staff_code">#HTMLEditFormat(displayUpdateStaffCode)#</span>
                                <span id="update_staff_name">#HTMLEditFormat(displayUpdateStaffName)#</span>
                            </div>
                        </div>
                    </cfif>
                </div>
            </div>

            <div id="loading_area" class="loading_area">処理中です...</div>

            <div id="message_area" class="message_area<cfif detailNotFoundMessage neq ""> is-show message_error</cfif>">
                #HTMLEditFormat(detailNotFoundMessage)#
            </div>

            <form id="master_form" method="post" onsubmit="return false;">
                <input type="hidden" id="original_delivery_company_code" name="original_delivery_company_code" value="#HTMLEditFormat(displayOriginalDeliveryCompanyCode)#">
                <input type="hidden" id="return_delivery_company_code" name="return_delivery_company_code" value="#HTMLEditFormat(targetDeliveryCompanyCode)#">
                <input type="hidden" id="display_mode" name="display_mode" value="#HTMLEditFormat(displayMode)#">
                <input type="hidden" id="source_page" name="source_page" value="#HTMLEditFormat(sourcePage)#">
                <input type="hidden" id="source_delivery_company_code" name="source_delivery_company_code" value="#HTMLEditFormat(sourceDeliveryCompanyCode)#">

                <input type="hidden" id="return_page" name="return_page" value="#HTMLEditFormat(returnPage)#">
                <input type="hidden" id="return_sort_field" name="return_sort_field" value="#HTMLEditFormat(returnSortField)#">
                <input type="hidden" id="return_sort_order" name="return_sort_order" value="#HTMLEditFormat(returnSortOrder)#">

                <input type="hidden" id="return_search_delivery_company_code" name="return_search_delivery_company_code" value="#HTMLEditFormat(returnSearchDeliveryCompanyCode)#">
                <input type="hidden" id="return_search_delivery_company_name" name="return_search_delivery_company_name" value="#HTMLEditFormat(returnSearchDeliveryCompanyName)#">
                <input type="hidden" id="return_search_use_flag" name="return_search_use_flag" value="#HTMLEditFormat(returnSearchUseFlag)#">

                <div class="form_grid">
                    <div class="form_item">
                        <div class="form_label">配送業者コード<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="delivery_company_code" name="delivery_company_code" maxlength="5" value="#HTMLEditFormat(displayDeliveryCompanyCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">配送業者名<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="delivery_company_name" name="delivery_company_name" maxlength="100" value="#HTMLEditFormat(displayDeliveryCompanyName)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">使用区分</div>
                        <div class="form_value">
                            <cfif displayMode eq "view">
                                <span class="use-badge <cfif displayUseFlag eq '1'>use-1<cfelse>use-0</cfif>">
                                    <cfif displayUseFlag eq "1">使用中<cfelse>停止</cfif>
                                </span>
                            <cfelse>
                                <select id="use_flag" name="use_flag">
                                    <option value="1"<cfif displayUseFlag eq "1"> selected</cfif>>使用中</option>
                                    <option value="0"<cfif displayUseFlag eq "0"> selected</cfif>>停止</option>
                                </select>
                            </cfif>
                        </div>
                    </div>

                    <div></div>

                    <div class="form_item wide">
                        <div class="form_label">備考</div>
                        <div class="form_value">
                            <textarea id="note" name="note">#HTMLEditFormat(displayNote)#</textarea>
                        </div>
                    </div>
                </div>

                <cfif displayMode neq "view">
                    <div class="button_area">
                        <button type="button" id="save_btn" class="normal_btn">保存</button>
                    </div>
                </cfif>
            </form>
        </div>
    </div>

    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/m_delivery_company_dt.js?20260403_2"></script>
</body>
</cfoutput>
</html>