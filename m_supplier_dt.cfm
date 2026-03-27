<cfinclude template="init.cfm">

<!--- =========================
      受け取り
      ========================= --->
<cfset supplierId = 0>

<cfset returnSearchSupplierCode = "">
<cfif StructKeyExists(Form, "return_search_supplier_code")>
    <cfset returnSearchSupplierCode = Trim(Form.return_search_supplier_code)>
</cfif>

<cfset returnSearchSupplierName = "">
<cfif StructKeyExists(Form, "return_search_supplier_name")>
    <cfset returnSearchSupplierName = Trim(Form.return_search_supplier_name)>
</cfif>

<cfset returnSearchDeliveryCompany = "">
<cfif StructKeyExists(Form, "return_search_delivery_company")>
    <cfset returnSearchDeliveryCompany = Trim(Form.return_search_delivery_company)>
</cfif>

<cfset returnSearchUseFlag = "">
<cfif StructKeyExists(Form, "return_search_use_flag") AND (Form.return_search_use_flag eq "0" OR Form.return_search_use_flag eq "1")>
    <cfset returnSearchUseFlag = Form.return_search_use_flag>
</cfif>

<cfset displayMode = "view">
<cfif StructKeyExists(Form, "display_mode") AND Trim(Form.display_mode) neq "">
    <cfset displayMode = LCase(Trim(Form.display_mode))>
</cfif>

<cfif displayMode neq "view" AND displayMode neq "edit" AND displayMode neq "add">
    <cfset displayMode = "view">
</cfif>

<cfset postedSupplierCode = "">
<cfif StructKeyExists(Form, "supplier_code")>
    <cfset postedSupplierCode = Trim(Form.supplier_code)>
</cfif>

<cfset returnSupplierCode = "">
<cfif StructKeyExists(Form, "return_supplier_code") AND Trim(Form.return_supplier_code) neq "">
    <cfset returnSupplierCode = Trim(Form.return_supplier_code)>
<cfelseif postedSupplierCode neq "">
    <cfset returnSupplierCode = postedSupplierCode>
</cfif>

<!--- =========================
      画面タイトル・ヘッダーボタン
      ========================= --->
<cfset pageTitle = "取引先マスタ詳細">
<cfset pageHeading = "取引先マスタ詳細">

<cfset showHomeButton = false>
<cfset showBackButton = false>
<cfset showNewButton = false>
<cfset showEditButton = false>
<cfset showImportButton = false>
<cfset showExportButton = false>
<cfset showTrashButton = false>
<cfset showCancelButton = false>

<cfif displayMode eq "view">
    <cfset pageTitle = "取引先マスタ詳細">
    <cfset pageHeading = "取引先マスタ詳細">
    <cfset showBackButton = true>
    <cfset showNewButton = true>
    <cfset showEditButton = true>
    <cfset showTrashButton = true>
<cfelseif displayMode eq "edit">
    <cfset pageTitle = "取引先マスタ修正">
    <cfset pageHeading = "取引先マスタ修正">
    <cfset showCancelButton = true>
<cfelseif displayMode eq "add">
    <cfset pageTitle = "取引先マスタ追加">
    <cfset pageHeading = "取引先マスタ追加">
    <cfset showCancelButton = true>
</cfif>

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

<!--- =========================
      都道府県マスタ取得
      ========================= --->
<cfquery name="qPrefecture">
    SELECT
        prefecture_code,
        prefecture_name
    FROM
        m_prefecture
    WHERE
        use_flag = 1
    ORDER BY
        prefecture_code ASC
</cfquery>

<!--- =========================
      初期表示用変数
      ========================= --->
<cfset detailSupplierId = "">
<cfset detailSupplierCode = "">
<cfset detailSupplierName = "">
<cfset detailSupplierNameKana = "">
<cfset detailZipCode = "">
<cfset detailPrefectureCode = "">
<cfset detailAddress1 = "">
<cfset detailAddress2 = "">
<cfset detailTel = "">
<cfset detailFax = "">
<cfset detailDeliveryCompanyCode = "">
<cfset detailNote = "">
<cfset detailUseFlag = "1">
<cfset detailCreateDatetime = "">
<cfset detailCreateStaffCode = "">
<cfset detailCreateStaffName = "">
<cfset detailUpdateDatetime = "">
<cfset detailUpdateStaffCode = "">
<cfset detailUpdateStaffName = "">
<cfset detailNotFoundMessage = "">

<!--- =========================
      supplier_codeで詳細取得
      ========================= --->
<cfif returnSupplierCode neq "">
    <cfquery name="qSupplierDetail">
        SELECT
            s.supplier_id,
            s.supplier_code,
            s.supplier_name,
            s.supplier_name_kana,
            s.zip_code,
            s.prefecture_code,
            p.prefecture_name,
            s.address1,
            s.address2,
            s.tel,
            s.fax,
            s.delivery_company_code,
            d.delivery_company_name,
            s.note,
            s.use_flag,
            DATE_FORMAT(s.create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
            s.create_staff_code,
            s.create_staff_name,
            DATE_FORMAT(s.update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
            s.update_staff_code,
            s.update_staff_name
        FROM
            m_supplier s
        LEFT OUTER JOIN
            m_prefecture p
                ON s.prefecture_code = p.prefecture_code
        LEFT OUTER JOIN
            m_delivery_company d
                ON s.delivery_company_code = d.delivery_company_code
        WHERE
            s.supplier_code = <cfqueryparam value="#returnSupplierCode#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qSupplierDetail.recordCount gt 0>
        <cfset supplierId = qSupplierDetail.supplier_id>
        <cfset detailSupplierId = qSupplierDetail.supplier_id>
        <cfset detailSupplierCode = qSupplierDetail.supplier_code>
        <cfset detailSupplierName = qSupplierDetail.supplier_name>

        <cfif NOT IsNull(qSupplierDetail.supplier_name_kana)>
            <cfset detailSupplierNameKana = qSupplierDetail.supplier_name_kana>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.zip_code)>
            <cfset detailZipCode = qSupplierDetail.zip_code>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.prefecture_code)>
            <cfset detailPrefectureCode = qSupplierDetail.prefecture_code>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.address1)>
            <cfset detailAddress1 = qSupplierDetail.address1>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.address2)>
            <cfset detailAddress2 = qSupplierDetail.address2>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.tel)>
            <cfset detailTel = qSupplierDetail.tel>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.fax)>
            <cfset detailFax = qSupplierDetail.fax>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.delivery_company_code)>
            <cfset detailDeliveryCompanyCode = qSupplierDetail.delivery_company_code>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.note)>
            <cfset detailNote = qSupplierDetail.note>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.use_flag)>
            <cfset detailUseFlag = qSupplierDetail.use_flag>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.create_datetime_disp)>
            <cfset detailCreateDatetime = qSupplierDetail.create_datetime_disp>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.create_staff_code)>
            <cfset detailCreateStaffCode = qSupplierDetail.create_staff_code>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.create_staff_name)>
            <cfset detailCreateStaffName = qSupplierDetail.create_staff_name>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.update_datetime_disp)>
            <cfset detailUpdateDatetime = qSupplierDetail.update_datetime_disp>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.update_staff_code)>
            <cfset detailUpdateStaffCode = qSupplierDetail.update_staff_code>
        </cfif>

        <cfif NOT IsNull(qSupplierDetail.update_staff_name)>
            <cfset detailUpdateStaffName = qSupplierDetail.update_staff_name>
        </cfif>
    <cfelse>
        <cfset detailNotFoundMessage = "指定された取引先が見つかりませんでした。">
    </cfif>
</cfif>

<!--- =========================
      add画面では表示だけ空にする
      ========================= --->
<cfset displaySupplierId = detailSupplierId>
<cfset displaySupplierCode = detailSupplierCode>
<cfset displaySupplierName = detailSupplierName>
<cfset displaySupplierNameKana = detailSupplierNameKana>
<cfset displayZipCode = detailZipCode>
<cfset displayPrefectureCode = detailPrefectureCode>
<cfset displayAddress1 = detailAddress1>
<cfset displayAddress2 = detailAddress2>
<cfset displayTel = detailTel>
<cfset displayFax = detailFax>
<cfset displayDeliveryCompanyCode = detailDeliveryCompanyCode>
<cfset displayNote = detailNote>
<cfset displayUseFlag = detailUseFlag>
<cfset displayCreateDatetime = detailCreateDatetime>
<cfset displayCreateStaffCode = detailCreateStaffCode>
<cfset displayCreateStaffName = detailCreateStaffName>
<cfset displayUpdateDatetime = detailUpdateDatetime>
<cfset displayUpdateStaffCode = detailUpdateStaffCode>
<cfset displayUpdateStaffName = detailUpdateStaffName>

<cfif displayMode eq "add">
    <cfset displaySupplierId = "">
    <cfset displaySupplierCode = "">
    <cfset displaySupplierName = "">
    <cfset displaySupplierNameKana = "">
    <cfset displayZipCode = "">
    <cfset displayPrefectureCode = "">
    <cfset displayAddress1 = "">
    <cfset displayAddress2 = "">
    <cfset displayTel = "">
    <cfset displayFax = "">
    <cfset displayDeliveryCompanyCode = "">
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
        <link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260326_1">
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
        .view_mode .form_value select,
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

            <div id="loading_area" class="loading_area">読み込み中です...</div>

            <div id="message_area" class="message_area<cfif detailNotFoundMessage neq ""> is-show message_error</cfif>">
                #HTMLEditFormat(detailNotFoundMessage)#
            </div>

            <form id="supplier_dt_form" method="post" onsubmit="return false;">
                <input type="hidden" id="supplier_id" name="supplier_id" value="#HTMLEditFormat(displaySupplierId)#">
                <input type="hidden" id="display_mode" name="display_mode" value="#HTMLEditFormat(displayMode)#">
                <input type="hidden" id="return_supplier_code" name="return_supplier_code" value="#HTMLEditFormat(returnSupplierCode)#">

                <input type="hidden" id="return_search_supplier_code" name="return_search_supplier_code" value="#HTMLEditFormat(returnSearchSupplierCode)#">
                <input type="hidden" id="return_search_supplier_name" name="return_search_supplier_name" value="#HTMLEditFormat(returnSearchSupplierName)#">
                <input type="hidden" id="return_search_delivery_company" name="return_search_delivery_company" value="#HTMLEditFormat(returnSearchDeliveryCompany)#">
                <input type="hidden" id="return_search_use_flag" name="return_search_use_flag" value="#HTMLEditFormat(returnSearchUseFlag)#">

                <div class="form_grid">
                    <div class="form_item">
                        <div class="form_label">取引先コード<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="supplier_code" name="supplier_code" maxlength="20" value="#HTMLEditFormat(displaySupplierCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">取引先名<span class="required_mark">必須</span></div>
                        <div class="form_value">
                            <input type="text" id="supplier_name" name="supplier_name" maxlength="100" value="#HTMLEditFormat(displaySupplierName)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">取引先名カナ</div>
                        <div class="form_value">
                            <input type="text" id="supplier_name_kana" name="supplier_name_kana" maxlength="100" value="#HTMLEditFormat(displaySupplierNameKana)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">郵便番号</div>
                        <div class="form_value">
                            <input type="text" id="zip_code" name="zip_code" maxlength="20" value="#HTMLEditFormat(displayZipCode)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">都道府県</div>
                        <div class="form_value">
                            <select id="prefecture_code" name="prefecture_code">
                                <option value="">選択してください</option>
                                <cfloop query="qPrefecture">
                                    <option value="#HTMLEditFormat(qPrefecture.prefecture_code)#"<cfif displayPrefectureCode eq qPrefecture.prefecture_code> selected</cfif>>
                                        #HTMLEditFormat(qPrefecture.prefecture_name)#
                                    </option>
                                </cfloop>
                            </select>
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">住所1</div>
                        <div class="form_value">
                            <input type="text" id="address1" name="address1" maxlength="100" value="#HTMLEditFormat(displayAddress1)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">住所2</div>
                        <div class="form_value">
                            <input type="text" id="address2" name="address2" maxlength="100" placeholder="番地・建物を入力" value="#HTMLEditFormat(displayAddress2)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">電話番号</div>
                        <div class="form_value">
                            <input type="text" id="tel" name="tel" maxlength="20" placeholder="電話番号を入力" value="#HTMLEditFormat(displayTel)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">FAX番号</div>
                        <div class="form_value">
                            <input type="text" id="fax" name="fax" maxlength="20" placeholder="FAX番号を入力" value="#HTMLEditFormat(displayFax)#">
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">配送業者</div>
                        <div class="form_value">
                            <select id="delivery_company_code" name="delivery_company_code" class="form-control form-select">
                                <option value="">選択してください</option>
                                <cfloop query="qDeliveryCompany">
                                    <option value="#HTMLEditFormat(qDeliveryCompany.delivery_company_code)#"<cfif displayDeliveryCompanyCode eq qDeliveryCompany.delivery_company_code> selected</cfif>>
                                        #HTMLEditFormat(qDeliveryCompany.delivery_company_name)#
                                    </option>
                                </cfloop>
                            </select>
                        </div>
                    </div>

                    <div class="form_item">
                        <div class="form_label">使用区分</div>
                        <div class="form_value">
                            <select id="use_flag" name="use_flag" class="form-control form-select">
                                <option value="1"<cfif displayUseFlag eq "1"> selected</cfif>>有効</option>
                                <option value="0"<cfif displayUseFlag eq "0"> selected</cfif>>無効</option>
                            </select>
                        </div>
                    </div>

                    <div class="form_item wide">
                        <div class="form_label">備考</div>
                        <div class="form_value">
                            <textarea id="note" name="note" placeholder="備考を入力">#HTMLEditFormat(displayNote)#</textarea>
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
    <script src="#Application.asset_url#/js/m_supplier_dt.js?20260326_1"></script>
</body>
</cfoutput>
</html>