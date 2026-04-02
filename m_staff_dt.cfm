<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<!-- =========================
     受け取り（cfparamなし）
     ========================= -->
<cfset postedStaffCode = "">
<cfif StructKeyExists(Form, "staff_code")>
    <cfset postedStaffCode = Trim(Form.staff_code)>
</cfif>

<cfset returnStaffCode = "">
<cfif StructKeyExists(Form, "return_staff_code")>
    <cfset returnStaffCode = Trim(Form.return_staff_code)>
</cfif>

<cfset displayMode = "view">
<cfif StructKeyExists(Form, "display_mode") AND Trim(Form.display_mode) neq "">
    <cfset displayMode = LCase(Trim(Form.display_mode))>
</cfif>

<cfif displayMode neq "view" AND displayMode neq "edit" AND displayMode neq "add">
    <cfset displayMode = "view">
</cfif>

<cfset returnSearchStaffCode = "">
<cfif StructKeyExists(Form, "return_search_staff_code")>
    <cfset returnSearchStaffCode = Trim(Form.return_search_staff_code)>
</cfif>

<cfset returnSearchStaffName = "">
<cfif StructKeyExists(Form, "return_search_staff_name")>
    <cfset returnSearchStaffName = Trim(Form.return_search_staff_name)>
</cfif>

<cfset returnSearchMailAddress = "">
<cfif StructKeyExists(Form, "return_search_mail_address")>
    <cfset returnSearchMailAddress = Trim(Form.return_search_mail_address)>
</cfif>

<cfset returnSearchAuthorityLevel = "">
<cfif StructKeyExists(Form, "return_search_authority_level")>
    <cfset returnSearchAuthorityLevel = Trim(Form.return_search_authority_level)>
</cfif>

<cfset returnSearchUseFlag = "">
<cfif StructKeyExists(Form, "return_search_use_flag")>
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

<!-- =========================
     表示対象コード
     return優先 → なければpost
     ========================= -->
<cfset targetStaffCode = "">
<cfif returnStaffCode neq "">
    <cfset targetStaffCode = returnStaffCode>
<cfelseif postedStaffCode neq "">
    <cfset targetStaffCode = postedStaffCode>
</cfif>

<!-- =========================
     ヘッダー制御
     ========================= -->
<cfset pageTitle = "社員マスタ詳細">
<cfset pageHeading = "社員マスタ詳細">

<cfset showHomeButton = false>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showEditButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>
<cfset showTrashButton = false>
<cfset showCancelButton = false>

<cfif displayMode eq "view">
    <cfset pageTitle = "社員マスタ詳細">
    <cfset pageHeading = "社員マスタ詳細">
    <cfset showBackButton = true>
    <cfset showNewButton = true>
    <cfset showEditButton = true>
    <cfset showTrashButton = true>
<cfelseif displayMode eq "edit">
    <cfset pageTitle = "社員マスタ修正">
    <cfset pageHeading = "社員マスタ修正">
    <cfset showCancelButton = true>
<cfelseif displayMode eq "add">
    <cfset pageTitle = "社員マスタ追加">
    <cfset pageHeading = "社員マスタ追加">
    <cfset showCancelButton = true>
</cfif>

<!-- =========================
     初期値
     ========================= -->
<cfset detailOriginalStaffCode = "">
<cfset detailStaffCode = "">
<cfset detailStaffName = "">
<cfset detailStaffKana = "">
<cfset detailAuthorityLevel = "1">
<cfset detailMailAddress = "">
<cfset detailTelNo = "">
<cfset detailUseFlag = "1">
<cfset detailNote = "">
<cfset detailLastLoginDatetime = "">
<cfset detailCreateDatetime = "">
<cfset detailCreateStaffCode = "">
<cfset detailCreateStaffName = "">
<cfset detailUpdateDatetime = "">
<cfset detailUpdateStaffCode = "">
<cfset detailUpdateStaffName = "">
<cfset detailNotFoundMessage = "">

<!-- =========================
     DB取得（add以外のみ）
     ========================= -->
<cfif displayMode neq "add" AND targetStaffCode neq "">
    <cfquery name="qStaffDetail">
        SELECT
            staff_code,
            staff_name,
            staff_kana,
            authority_level,
            mail_address,
            tel_no,
            use_flag,
            note,
            DATE_FORMAT(last_login_datetime, '%Y/%m/%d %H:%i:%s') AS last_login_datetime_disp,
            DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
            create_staff_code,
            create_staff_name,
            DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
            update_staff_code,
            update_staff_name
        FROM
            m_staff
        WHERE
            staff_code = <cfqueryparam value="#targetStaffCode#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qStaffDetail.recordCount eq 1>
        <cfset detailOriginalStaffCode = qStaffDetail.staff_code[1]>
        <cfset detailStaffCode = qStaffDetail.staff_code[1]>
        <cfset detailStaffName = qStaffDetail.staff_name[1]>
        <cfset detailStaffKana = qStaffDetail.staff_kana[1]>
        <cfset detailAuthorityLevel = qStaffDetail.authority_level[1]>
        <cfset detailMailAddress = qStaffDetail.mail_address[1]>
        <cfset detailTelNo = qStaffDetail.tel_no[1]>
        <cfset detailUseFlag = qStaffDetail.use_flag[1]>
        <cfset detailNote = qStaffDetail.note[1]>
        <cfset detailLastLoginDatetime = qStaffDetail.last_login_datetime_disp[1]>
        <cfset detailCreateDatetime = qStaffDetail.create_datetime_disp[1]>
        <cfset detailCreateStaffCode = qStaffDetail.create_staff_code[1]>
        <cfset detailCreateStaffName = qStaffDetail.create_staff_name[1]>
        <cfset detailUpdateDatetime = qStaffDetail.update_datetime_disp[1]>
        <cfset detailUpdateStaffCode = qStaffDetail.update_staff_code[1]>
        <cfset detailUpdateStaffName = qStaffDetail.update_staff_name[1]>
    <cfelse>
        <cfset detailNotFoundMessage = "指定された社員が見つかりませんでした。">
    </cfif>
</cfif>

<!-- =========================
     addでは必ず空表示
     ========================= -->
<cfset displayOriginalStaffCode = detailOriginalStaffCode>
<cfset displayStaffCode = detailStaffCode>
<cfset displayStaffName = detailStaffName>
<cfset displayStaffKana = detailStaffKana>
<cfset displayAuthorityLevel = detailAuthorityLevel>
<cfset displayMailAddress = detailMailAddress>
<cfset displayTelNo = detailTelNo>
<cfset displayUseFlag = detailUseFlag>
<cfset displayNote = detailNote>
<cfset displayLastLoginDatetime = detailLastLoginDatetime>
<cfset displayCreateDatetime = detailCreateDatetime>
<cfset displayCreateStaffCode = detailCreateStaffCode>
<cfset displayCreateStaffName = detailCreateStaffName>
<cfset displayUpdateDatetime = detailUpdateDatetime>
<cfset displayUpdateStaffCode = detailUpdateStaffCode>
<cfset displayUpdateStaffName = detailUpdateStaffName>

<cfif displayMode eq "add">
    <cfset displayOriginalStaffCode = "">
    <cfset displayStaffCode = "">
    <cfset displayStaffName = "">
    <cfset displayStaffKana = "">
    <cfset displayAuthorityLevel = "1">
    <cfset displayMailAddress = "">
    <cfset displayTelNo = "">
    <cfset displayUseFlag = "1">
    <cfset displayNote = "">
    <cfset displayLastLoginDatetime = "">
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
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260331_2">
    </cfoutput>

    <style>
        body { background-color: #F7F1E3; color: #2F2A24; }
        .dt_wrap { max-width: 1280px; margin: 20px auto 32px; padding: 0 20px; }
        .dt_card { background-color: #FFFFFF; border: 1px solid #CDBFA8; border-radius: 10px; padding: 20px 24px 24px; }
        .dt_header_row { display: flex; justify-content: space-between; align-items: flex-start; gap: 24px; margin-bottom: 16px; }
        .dt_title_area { display: flex; align-items: center; gap: 12px; min-height: 32px; }
        .dt_title { margin: 0; color: #2E4136; font-size: 24px; }
        .mode_badge { display: inline-block; min-width: 88px; padding: 5px 10px; border-radius: 999px; text-align: center; font-size: 12px; font-weight: bold; background-color: #EFE5D1; color: #2E4136; }
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
        .form_item.wide { grid-column: 1 / span 2; }
        .form_label { font-weight: bold; color: #2E4136; font-size: 14px; }
        .required_mark { margin-left: 4px; color: #B84A4A; font-size: 11px; }
        .form_value input, .form_value select, .form_value textarea {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #CDBFA8;
            border-radius: 6px;
            background-color: #FFFFFF;
            color: #2F2A24;
            font-size: 14px;
            padding: 8px 10px;
        }
        .form_value input:focus, .form_value select:focus, .form_value textarea:focus {
            border-color: #3F5B4B;
            background-color: #FFFCF4;
            box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
            outline: none;
        }
        .form_value textarea { min-height: 80px; resize: vertical; }
        .view_mode .form_value input,
        .view_mode .form_value select,
        .view_mode .form_value textarea {
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
        .normal_btn:disabled { opacity: 0.5; cursor: not-allowed; }

        .view-only { display: block; }
        .edit-only { display: none; }

        #dt_card:not(.view_mode) .view-only { display: none; }
        #dt_card:not(.view_mode) .edit-only { display: block; }

        /* 使用区分 */
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

        /* 権限 */
        .auth-badge {
            display: inline-block;
            min-width: 70px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
        }

        .auth-9 {
            background: #E8EAF6;
            color: #3949AB;
        }

        .auth-1 {
            background: #ECEFF1;
            color: #546E7A;
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
                            <div class="meta_value">#HTMLEditFormat(displayCreateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">作成者</div>
                            <div class="meta_value">#HTMLEditFormat(displayCreateStaffCode)# #HTMLEditFormat(displayCreateStaffName)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新日時</div>
                            <div class="meta_value">#HTMLEditFormat(displayUpdateDatetime)#</div>
                        </div>
                        <div class="meta_line">
                            <div class="meta_label">更新者</div>
                            <div class="meta_value">#HTMLEditFormat(displayUpdateStaffCode)# #HTMLEditFormat(displayUpdateStaffName)#</div>
                        </div>
                    </cfif>
                </div>
            </div>

            <div id="message_area" class="message_area<cfif detailNotFoundMessage neq ""> is-show message_error</cfif>">#HTMLEditFormat(detailNotFoundMessage)#</div>
            <div id="loading_area" class="loading_area">処理中です...</div>

            <form id="master_form" onsubmit="return false;">
                <input type="hidden" id="original_staff_code" name="original_staff_code" value="#HTMLEditFormat(displayOriginalStaffCode)#">
                <input type="hidden" id="return_staff_code" name="return_staff_code" value="#HTMLEditFormat(targetStaffCode)#">
                <input type="hidden" id="display_mode" name="display_mode" value="#HTMLEditFormat(displayMode)#">

                <input type="hidden" id="return_sort_field" name="return_sort_field" value="#HTMLEditFormat(returnSortField)#">
                <input type="hidden" id="return_sort_order" name="return_sort_order" value="#HTMLEditFormat(returnSortOrder)#">

                <input type="hidden" id="return_search_staff_code" name="return_search_staff_code" value="#HTMLEditFormat(returnSearchStaffCode)#">
                <input type="hidden" id="return_search_staff_name" name="return_search_staff_name" value="#HTMLEditFormat(returnSearchStaffName)#">
                <input type="hidden" id="return_search_mail_address" name="return_search_mail_address" value="#HTMLEditFormat(returnSearchMailAddress)#">
                <input type="hidden" id="return_search_authority_level" name="return_search_authority_level" value="#HTMLEditFormat(returnSearchAuthorityLevel)#">
                <input type="hidden" id="return_search_use_flag" name="return_search_use_flag" value="#HTMLEditFormat(returnSearchUseFlag)#">

                <div class="form_grid">
                    <div class="form_item">
                        <div class="form_label">社員コード<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="staff_code" name="staff_code" maxlength="20" value="#HTMLEditFormat(displayStaffCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">社員名<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="staff_name" name="staff_name" maxlength="100" value="#HTMLEditFormat(displayStaffName)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">社員名カナ</div>
                        <div class="form_value">
                            <input type="text" id="staff_kana" name="staff_kana" maxlength="100" value="#HTMLEditFormat(displayStaffKana)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">権限レベル</div>
                        <div class="form_value">

                            <!-- 表示用 -->
                            <span id="authority_level_disp" class="auth-badge view-only"></span>

                            <!-- 編集用 -->
                            <select id="authority_level" name="authority_level" class="form-control form-select edit-only">
                                <option value="1"<cfif displayAuthorityLevel eq "1"> selected</cfif>>一般</option>
                                <option value="9"<cfif displayAuthorityLevel eq "9"> selected</cfif>>管理者</option>
                            </select>

                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">メールアドレス</div>
                        <div class="form_value">
                            <input type="text" id="mail_address" name="mail_address" maxlength="255" value="#HTMLEditFormat(displayMailAddress)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">電話番号</div>
                        <div class="form_value">
                            <input type="text" id="tel_no" name="tel_no" maxlength="20" value="#HTMLEditFormat(displayTelNo)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">使用区分</div>
                        <div class="form_value">

                            <!-- 表示用 -->
                            <span id="use_flag_disp" class="use-badge view-only"></span>

                            <!-- 編集用 -->
                            <select id="use_flag" name="use_flag" class="form-control form-select edit-only">
                                <option value="1"<cfif displayUseFlag eq "1"> selected</cfif>>使用中</option>
                                <option value="0"<cfif displayUseFlag eq "0"> selected</cfif>>停止</option>
                            </select>

                        </div>
                    </div>

                    <div></div>

                    <cfif displayMode eq "add" OR displayMode eq "edit">
                        <div class="form_item">
                            <div class="form_label">
                                パスワード
                                <cfif displayMode eq "add"><span class="required_mark">必須</span></cfif>
                            </div>
                            <div class="form_value">
                                <input type="password" id="login_password" name="login_password" maxlength="100" value="">
                            </div>
                        </div>

                        <div class="form_item">
                            <div class="form_label">
                                パスワード確認
                                <cfif displayMode eq "add"><span class="required_mark">必須</span></cfif>
                            </div>
                            <div class="form_value">
                                <input type="password" id="login_password_confirm" name="login_password_confirm" maxlength="100" value="">
                            </div>
                        </div>
                    <cfelse>
                        <input type="hidden" id="login_password" name="login_password" value="">
                        <input type="hidden" id="login_password_confirm" name="login_password_confirm" value="">
                    </cfif>

                    <div class="form_item wide">
                        <div class="form_label">備考</div>
                        <div class="form_value">
                            <textarea id="note" name="note">#HTMLEditFormat(displayNote)#</textarea>
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
    <script src="#Application.asset_url#/js/m_staff_dt.js?20260331_2"></script>
</body>
</cfoutput>
</html>