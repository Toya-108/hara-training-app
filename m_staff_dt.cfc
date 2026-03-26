<cfcomponent displayname="MStaffDt" output="false">

    <cffunction name="getStaffDetail" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var staffId = 0>
        <cfset var qGetStaff = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "staff_id")>
                <cfset staffId = Val(requestData.staff_id)>
            </cfif>

            <cfif staffId lte 0>
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員IDが不正です。">
                <cfreturn result>
            </cfif>

            <cfquery name="qGetStaff">
                SELECT
                    staff_id,
                    staff_code,
                    staff_name,
                    staff_kana,
                    authority_level,
                    mail_address,
                    tel_no,
                    DATE_FORMAT(last_login_datetime, '%Y/%m/%d %H:%i:%s') AS last_login_datetime_disp,
                    DATE_FORMAT(password_update_datetime, '%Y/%m/%d %H:%i:%s') AS password_update_datetime_disp,
                    use_flag,
                    note,
                    DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
                    create_staff_code,
                    create_staff_name,
                    DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
                    update_staff_code,
                    update_staff_name
                FROM
                    m_staff
                WHERE
                    staff_id = <cfqueryparam value="#staffId#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qGetStaff.recordCount neq 1>
                <cfset result["status"] = 1>
                <cfset result["message"] = "データが存在しません。">
                <cfreturn result>
            </cfif>

            <cfset result["results"]["staff_id"] = qGetStaff.staff_id[1]>
            <cfset result["results"]["staff_code"] = qGetStaff.staff_code[1]>
            <cfset result["results"]["staff_name"] = qGetStaff.staff_name[1]>
            <cfset result["results"]["staff_kana"] = qGetStaff.staff_kana[1]>
            <cfset result["results"]["authority_level"] = qGetStaff.authority_level[1]>
            <cfset result["results"]["mail_address"] = qGetStaff.mail_address[1]>
            <cfset result["results"]["tel_no"] = qGetStaff.tel_no[1]>
            <cfset result["results"]["last_login_datetime_disp"] = qGetStaff.last_login_datetime_disp[1]>
            <cfset result["results"]["password_update_datetime_disp"] = qGetStaff.password_update_datetime_disp[1]>
            <cfset result["results"]["use_flag"] = qGetStaff.use_flag[1]>
            <cfset result["results"]["note"] = qGetStaff.note[1]>
            <cfset result["results"]["create_datetime_disp"] = qGetStaff.create_datetime_disp[1]>
            <cfset result["results"]["create_staff_code"] = qGetStaff.create_staff_code[1]>
            <cfset result["results"]["create_staff_name"] = qGetStaff.create_staff_name[1]>
            <cfset result["results"]["update_datetime_disp"] = qGetStaff.update_datetime_disp[1]>
            <cfset result["results"]["update_staff_code"] = qGetStaff.update_staff_code[1]>
            <cfset result["results"]["update_staff_name"] = qGetStaff.update_staff_name[1]>

            <cfset result["message"] = "取得しました。">

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="社員詳細取得エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員詳細の取得中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="saveStaff" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>

        <cfset var staffId = 0>
        <cfset var staffCode = "">
        <cfset var staffName = "">
        <cfset var staffKana = "">
        <cfset var loginPassword = "">
        <cfset var loginPasswordConfirm = "">
        <cfset var loginPasswordHash = "">
        <cfset var authorityLevel = "1">
        <cfset var mailAddress = "">
        <cfset var telNo = "">
        <cfset var useFlag = "1">
        <cfset var note = "">

        <cfset var qCheckDuplicate = "">
        <cfset var qGetInsertedId = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "staff_id")>
                <cfset staffId = Val(requestData.staff_id)>
            </cfif>

            <cfif StructKeyExists(requestData, "staff_code")>
                <cfset staffCode = Trim(requestData.staff_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "staff_name")>
                <cfset staffName = Trim(requestData.staff_name)>
            </cfif>

            <cfif StructKeyExists(requestData, "staff_kana")>
                <cfset staffKana = Trim(requestData.staff_kana)>
            </cfif>

            <cfif StructKeyExists(requestData, "login_password")>
                <cfset loginPassword = Trim(requestData.login_password)>
            </cfif>

            <cfif StructKeyExists(requestData, "login_password_confirm")>
                <cfset loginPasswordConfirm = Trim(requestData.login_password_confirm)>
            </cfif>

            <cfif StructKeyExists(requestData, "authority_level")>
                <cfset authorityLevel = Trim(requestData.authority_level)>
            </cfif>

            <cfif StructKeyExists(requestData, "mail_address")>
                <cfset mailAddress = Trim(requestData.mail_address)>
            </cfif>

            <cfif StructKeyExists(requestData, "tel_no")>
                <cfset telNo = Trim(requestData.tel_no)>
            </cfif>

            <cfif StructKeyExists(requestData, "use_flag")>
                <cfset useFlag = Trim(requestData.use_flag)>
            </cfif>

            <cfif StructKeyExists(requestData, "note")>
                <cfset note = requestData.note>
            </cfif>

            <cfif staffCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員コード必須">
                <cfreturn result>
            </cfif>

            <cfif staffName eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員名必須">
                <cfreturn result>
            </cfif>

            <cfif authorityLevel neq "1" AND authorityLevel neq "2" AND authorityLevel neq "9">
                <cfset authorityLevel = "1">
            </cfif>

            <cfif useFlag neq "0" AND useFlag neq "1">
                <cfset useFlag = "1">
            </cfif>

            <cfif staffId lte 0 AND loginPassword eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "新規登録時はパスワード必須です。">
                <cfreturn result>
            </cfif>

            <cfif loginPassword neq "" OR loginPasswordConfirm neq "">
                <cfif loginPassword neq loginPasswordConfirm>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "パスワード確認が一致しません。">
                    <cfreturn result>
                </cfif>

                <cfset loginPasswordHash = Hash(loginPassword, "SHA-256")>
            </cfif>

            <cftransaction>
                <cfquery name="qCheckDuplicate">
                    SELECT staff_id
                    FROM m_staff
                    WHERE staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">
                    <cfif staffId gt 0>
                        AND staff_id <> <cfqueryparam value="#staffId#" cfsqltype="cf_sql_integer">
                    </cfif>
                </cfquery>

                <cfif qCheckDuplicate.recordCount gt 0>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "同じ社員コードが存在します。">
                    <cfreturn result>
                </cfif>

                <cfif staffId gt 0>
                    <cfquery>
                        UPDATE m_staff
                        SET
                            staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            staff_name = <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">,
                            staff_kana = <cfqueryparam value="#staffKana#" cfsqltype="cf_sql_varchar" null="#staffKana eq ''#">,
                            authority_level = <cfqueryparam value="#authorityLevel#" cfsqltype="cf_sql_tinyint" null="#authorityLevel eq ''#">,
                            mail_address = <cfqueryparam value="#mailAddress#" cfsqltype="cf_sql_varchar" null="#mailAddress eq ''#">,
                            tel_no = <cfqueryparam value="#telNo#" cfsqltype="cf_sql_varchar" null="#telNo eq ''#">,
                            use_flag = <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint" null="#useFlag eq ''#">,
                            note = <cfqueryparam value="#note#" cfsqltype="cf_sql_varchar" null="#Trim(note) eq ''#">,
                            <cfif loginPasswordHash neq "">
                                login_password_hash = <cfqueryparam value="#loginPasswordHash#" cfsqltype="cf_sql_varchar">,
                                password_update_datetime = NOW(),
                            </cfif>
                            update_datetime = NOW(),
                            update_staff_code = '#session.staffCode#',
                            update_staff_name = '#session.staffName#'
                        WHERE
                            staff_id = <cfqueryparam value="#staffId#" cfsqltype="cf_sql_integer">
                    </cfquery>

                    <cfset result["results"]["staff_id"] = staffId>
                    <cfset result["results"]["staff_code"] = staffCode>
                    <cfset result["message"] = "更新しました。">

                <cfelse>
                    <cfquery>
                        INSERT INTO m_staff (
                            staff_code,
                            staff_name,
                            staff_kana,
                            login_password_hash,
                            authority_level,
                            mail_address,
                            tel_no,
                            password_update_datetime,
                            use_flag,
                            note,
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffKana#" cfsqltype="cf_sql_varchar" null="#staffKana eq ''#">,
                            <cfqueryparam value="#loginPasswordHash#" cfsqltype="cf_sql_varchar" null="#loginPasswordHash eq ''#">,
                            <cfqueryparam value="#authorityLevel#" cfsqltype="cf_sql_tinyint" null="#authorityLevel eq ''#">,
                            <cfqueryparam value="#mailAddress#" cfsqltype="cf_sql_varchar" null="#mailAddress eq ''#">,
                            <cfqueryparam value="#telNo#" cfsqltype="cf_sql_varchar" null="#telNo eq ''#">,
                            <cfif loginPasswordHash neq "">NOW()<cfelse>NULL</cfif>,
                            <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint" null="#useFlag eq ''#">,
                            <cfqueryparam value="#note#" cfsqltype="cf_sql_varchar" null="#Trim(note) eq ''#">,
                            NOW(),
                            '#session.staffCode#',
                            '#session.staffName#',
                            NULL,
                            NULL,
                            NULL
                        )
                    </cfquery>

                    <cfquery name="qGetInsertedId">
                        SELECT LAST_INSERT_ID() AS new_staff_id
                    </cfquery>

                    <cfset result["results"]["staff_id"] = qGetInsertedId.new_staff_id[1]>
                    <cfset result["results"]["staff_code"] = staffCode>
                    <cfset result["message"] = "登録しました。">
                </cfif>
            </cftransaction>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="社員保存エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "保存中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

        <cffunction name="deleteStaff" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var staffId = 0>
        <cfset var qCheckStaff = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "staff_id")>
                <cfset staffId = Val(requestData.staff_id)>
            </cfif>

            <cfif staffId lte 0>
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員IDが不正です。">
                <cfreturn result>
            </cfif>

            <cftransaction>
                <cfquery name="qCheckStaff">
                    SELECT
                        staff_id,
                        staff_code,
                        staff_name
                    FROM
                        m_staff
                    WHERE
                        staff_id = <cfqueryparam value="#staffId#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfif qCheckStaff.recordCount neq 1>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "削除対象データが存在しません。">
                    <cfreturn result>
                </cfif>

                <cfquery>
                    DELETE FROM
                        m_staff
                    WHERE
                        staff_id = <cfqueryparam value="#staffId#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfset result["results"]["staff_id"] = qCheckStaff.staff_id[1]>
                <cfset result["results"]["staff_code"] = qCheckStaff.staff_code[1]>
                <cfset result["results"]["staff_name"] = qCheckStaff.staff_name[1]>
                <cfset result["message"] = "削除しました。">
            </cftransaction>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="社員削除エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "削除中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>