<cfinclude template="init.cfm">

<cfset displayMode = "view">

<cfif structKeyExists(form, "display_mode")>
    <cfset displayMode = lcase(trim(form.display_mode))>
</cfif>

<cfif displayMode NEQ "view" AND displayMode NEQ "edit">
    <cfset displayMode = "view">
</cfif>

<cfset pageTitle = "基本設定">
<cfset showHomeButton = false>
<cfset showBackButton = true>
<cfset showNewButton = false>
<cfset showEditButton = true>
<cfset showImportButton = false>
<cfset showExportButton = false>
<cfset showTrashButton = false>
<cfset showCancelButton = false>

<cfif displayMode EQ "edit">
    <cfset showEditButton = false>
    <cfset showCancelButton = true>
</cfif>

<cfquery name="qAdmin">
    SELECT
        company_code,
        company_name,
        center_name,
        postal_code,
        address1,
        address2,
        tel_no,
        fax_no,
        memo,
        admin_password,
        DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
        create_staff_code,
        create_staff_name,
        DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
        update_staff_code,
        update_staff_name
    FROM m_admin
    ORDER BY company_code ASC
    LIMIT 1
</cfquery>

<cfset companyCode = "">
<cfset companyName = "">
<cfset centerName = "">
<cfset postalCode = "">
<cfset address1 = "">
<cfset address2 = "">
<cfset telNo = "">
<cfset faxNo = "">
<cfset memo = "">
<cfset createDatetime = "">
<cfset createStaffCode = "">
<cfset createStaffName = "">
<cfset updateDatetime = "">
<cfset updateStaffCode = "">
<cfset updateStaffName = "">

<cfif qAdmin.recordCount GT 0>
    <cfset companyCode = qAdmin.company_code>
    <cfset companyName = qAdmin.company_name>
    <cfset centerName = qAdmin.center_name>
    <cfset postalCode = qAdmin.postal_code>
    <cfset address1 = qAdmin.address1>
    <cfset address2 = qAdmin.address2>
    <cfset telNo = qAdmin.tel_no>
    <cfset faxNo = qAdmin.fax_no>
    <cfset memo = qAdmin.memo>
    <cfset createDatetime = qAdmin.create_datetime_disp>
    <cfset createStaffCode = qAdmin.create_staff_code>
    <cfset createStaffName = qAdmin.create_staff_name>
    <cfset updateDatetime = qAdmin.update_datetime_disp>
    <cfset updateStaffCode = qAdmin.update_staff_code>
    <cfset updateStaffName = qAdmin.update_staff_name>
</cfif>

<cfinclude template="header.cfm">

<title>基本設定</title>

<cfoutput>
    <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
    <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
</cfoutput>

<style>
    body {
        margin: 0;
        background: #F7F1E3;
        font-family: "Hiragino Sans", "Yu Gothic", "Meiryo", sans-serif;
        color: #2F2A24;
    }

    .page-content {
        max-width: 1200px;
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

    .header-meta {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 18px;
    }

    .meta-box {
        min-width: 340px;
        font-size: 12px;
        color: #645B50;
        line-height: 1.7;
    }

    .meta-line {
        display: flex;
        gap: 10px;
    }

    .meta-label {
        width: 92px;
        flex-shrink: 0;
        font-weight: bold;
        color: #2E4136;
    }

    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
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

    .required {
        margin-left: 4px;
        color: #B84A4A;
        font-size: 11px;
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

    .view-only { display: block; }
    .edit-only { display: none; }

    .edit_mode .view-only { display: none; }
    .edit_mode .edit-only { display: block; }

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

    .password-note {
        font-size: 12px;
        color: #645B50;
        line-height: 1.6;
    }

    .bottom-save-area {
        margin-top: 18px;
        display: flex;
        justify-content: center;
    }

    .save-button {
        min-width: 140px;
        height: 42px;
        padding: 0 20px;
        border: 1px solid #4B6653;
        border-radius: 8px;
        background: #4B6653;
        color: #FFF;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
    }

    @media screen and (max-width: 900px) {
        .form-grid {
            grid-template-columns: 1fr;
        }

        .form-item.col-span-2 {
            grid-column: span 1;
        }

        .header-meta {
            justify-content: flex-start;
        }
    }
</style>

<div class="page-content">
    <div class="loading_indicator" id="loading_indicator">処理中です...</div>

    <form id="basic_setting_form" method="post">
        <input type="hidden" id="display_mode" name="display_mode" value="<cfoutput>#encodeForHtmlAttribute(displayMode)#</cfoutput>">

        <div class="section-card <cfif displayMode EQ 'edit'>edit_mode</cfif>">
            <div class="section-title">会社情報</div>

            <div class="form-grid">
                <div class="form-item">
                    <div class="form-label">会社コード<span class="required">必須</span></div>
                    <div class="readonly-box view-only" id="company_code_disp"><cfoutput>#encodeForHtml(companyCode)#</cfoutput></div>
                    <input type="text" id="company_code" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(companyCode)#</cfoutput>" maxlength="8">
                </div>

                <div class="form-item">
                    <div class="form-label">会社名<span class="required">必須</span></div>
                    <div class="readonly-box view-only" id="company_name_disp"><cfoutput>#encodeForHtml(companyName)#</cfoutput></div>
                    <input type="text" id="company_name" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(companyName)#</cfoutput>" maxlength="60">
                </div>

                <div class="form-item">
                    <div class="form-label">センター名</div>
                    <div class="readonly-box view-only" id="center_name_disp"><cfoutput>#encodeForHtml(centerName)#</cfoutput></div>
                    <input type="text" id="center_name" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(centerName)#</cfoutput>" maxlength="60">
                </div>

                <div class="form-item">
                    <div class="form-label">郵便番号</div>
                    <div class="readonly-box view-only" id="postal_code_disp"><cfoutput>#encodeForHtml(postalCode)#</cfoutput></div>
                    <input type="text" id="postal_code" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(postalCode)#</cfoutput>" maxlength="8">
                </div>

                <div class="form-item">
                    <div class="form-label">住所1</div>
                    <div class="readonly-box view-only" id="address1_disp"><cfoutput>#encodeForHtml(address1)#</cfoutput></div>
                    <input type="text" id="address1" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(address1)#</cfoutput>" maxlength="100">
                </div>

                <div class="form-item">
                    <div class="form-label">住所2</div>
                    <div class="readonly-box view-only" id="address2_disp"><cfoutput>#encodeForHtml(address2)#</cfoutput></div>
                    <input type="text" id="address2" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(address2)#</cfoutput>" maxlength="100">
                </div>

                <div class="form-item">
                    <div class="form-label">電話番号</div>
                    <div class="readonly-box view-only" id="tel_no_disp"><cfoutput>#encodeForHtml(telNo)#</cfoutput></div>
                    <input type="text" id="tel_no" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(telNo)#</cfoutput>" maxlength="20">
                </div>

                <div class="form-item">
                    <div class="form-label">FAX番号</div>
                    <div class="readonly-box view-only" id="fax_no_disp"><cfoutput>#encodeForHtml(faxNo)#</cfoutput></div>
                    <input type="text" id="fax_no" class="form-control edit-only" value="<cfoutput>#encodeForHtmlAttribute(faxNo)#</cfoutput>" maxlength="20">
                </div>

                <div class="form-item col-span-2">
                    <div class="form-label">備考</div>
                    <div class="readonly-textarea view-only" id="memo_disp"><cfoutput>#encodeForHtml(memo)#</cfoutput></div>
                    <textarea id="memo" class="form-textarea edit-only" maxlength="100"><cfoutput>#encodeForHtml(memo)#</cfoutput></textarea>
                </div>
            </div>
        </div>

        <div class="section-card <cfif displayMode EQ 'edit'>edit_mode</cfif>">
            <div class="section-title">管理パスワード</div>

            <div class="form-grid">
                <div class="form-item col-span-2">
                    <div class="form-label">現在のパスワード</div>
                    <div class="readonly-box view-only">••••••••</div>
                    <input type="password" id="admin_password" class="form-control edit-only" value="" maxlength="60" autocomplete="new-password">
                    <div class="password-note edit-only">
                        パスワードを変更する場合のみ入力してください。空欄なら現在の設定を保持します。
                    </div>
                </div>
            </div>

            <cfif displayMode EQ "edit">
                <div class="bottom-save-area">
                    <button type="button" id="save_btn" class="save-button">保存</button>
                </div>
            </cfif>
        </div>
    </form>
</div>

<cfoutput>
    <script src="#Application.asset_url#/js/sweetalert2.all.min.js"></script>
    <script src="#Application.asset_url#/js/admin_setting.js?20260401_2"></script>
</cfoutput>