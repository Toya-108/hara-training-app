<cfcomponent displayname="MDeliveryCompanyDt" output="false">

    <cffunction name="getDeliveryCompanyDetail" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var deliveryCompanyCode = "">
        <cfset var qGetDeliveryCompany = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "delivery_company_code")>
                <cfset deliveryCompanyCode = Trim(requestData.delivery_company_code)>
            </cfif>

            <cfif deliveryCompanyCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者コードが不正です。">
                <cfreturn result>
            </cfif>

            <cfquery name="qGetDeliveryCompany">
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
                    delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">
            </cfquery>

            <cfif qGetDeliveryCompany.recordCount neq 1>
                <cfset result["status"] = 1>
                <cfset result["message"] = "データが存在しません。">
                <cfreturn result>
            </cfif>

            <cfset result["results"]["delivery_company_code"] = qGetDeliveryCompany.delivery_company_code[1]>
            <cfset result["results"]["delivery_company_name"] = qGetDeliveryCompany.delivery_company_name[1]>
            <cfset result["results"]["note"] = qGetDeliveryCompany.note[1]>
            <cfset result["results"]["use_flag"] = qGetDeliveryCompany.use_flag[1]>
            <cfset result["results"]["create_datetime_disp"] = qGetDeliveryCompany.create_datetime_disp[1]>
            <cfset result["results"]["create_staff_code"] = qGetDeliveryCompany.create_staff_code[1]>
            <cfset result["results"]["create_staff_name"] = qGetDeliveryCompany.create_staff_name[1]>
            <cfset result["results"]["update_datetime_disp"] = qGetDeliveryCompany.update_datetime_disp[1]>
            <cfset result["results"]["update_staff_code"] = qGetDeliveryCompany.update_staff_code[1]>
            <cfset result["results"]["update_staff_name"] = qGetDeliveryCompany.update_staff_name[1]>

            <cfset result["message"] = "取得しました。">

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Error" text="配送業者詳細取得エラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者詳細の取得中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="saveDeliveryCompany" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>

        <cfset var originalDeliveryCompanyCode = "">
        <cfset var deliveryCompanyCode = "">
        <cfset var deliveryCompanyName = "">
        <cfset var note = "">
        <cfset var useFlag = "1">

        <cfset var qCheckDuplicate = "">
        <cfset var qCheckTarget = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "original_delivery_company_code")>
                <cfset originalDeliveryCompanyCode = Trim(requestData.original_delivery_company_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "delivery_company_code")>
                <cfset deliveryCompanyCode = Trim(requestData.delivery_company_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "delivery_company_name")>
                <cfset deliveryCompanyName = Trim(requestData.delivery_company_name)>
            </cfif>

            <cfif StructKeyExists(requestData, "note")>
                <cfset note = requestData.note>
            </cfif>

            <cfif StructKeyExists(requestData, "use_flag")>
                <cfset useFlag = Trim(requestData.use_flag)>
            </cfif>

            <cfif deliveryCompanyCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者コード必須です。">
                <cfreturn result>
            </cfif>

            <cfif deliveryCompanyName eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者名必須です。">
                <cfreturn result>
            </cfif>

            <cfif Len(deliveryCompanyCode) gt 5>
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者コードは5桁以内で入力してください。">
                <cfreturn result>
            </cfif>

            <cfif useFlag neq "0" AND useFlag neq "1">
                <cfset useFlag = "1">
            </cfif>

            <cftransaction>
                <cfquery name="qCheckDuplicate">
                    SELECT
                        delivery_company_code
                    FROM
                        m_delivery_company
                    WHERE
                        delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">
                    <cfif originalDeliveryCompanyCode neq "">
                        AND delivery_company_code <> <cfqueryparam value="#originalDeliveryCompanyCode#" cfsqltype="cf_sql_char">
                    </cfif>
                </cfquery>

                <cfif qCheckDuplicate.recordCount gt 0>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "同じ配送業者コードが存在します。">
                    <cfreturn result>
                </cfif>

                <cfif originalDeliveryCompanyCode neq "">
                    <cfquery name="qCheckTarget">
                        SELECT
                            delivery_company_code
                        FROM
                            m_delivery_company
                        WHERE
                            delivery_company_code = <cfqueryparam value="#originalDeliveryCompanyCode#" cfsqltype="cf_sql_char">
                    </cfquery>

                    <cfif qCheckTarget.recordCount neq 1>
                        <cfset result["status"] = 1>
                        <cfset result["message"] = "更新対象データが存在しません。">
                        <cfreturn result>
                    </cfif>

                    <cfquery>
                        UPDATE
                            m_delivery_company
                        SET
                            delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">,
                            delivery_company_name = <cfqueryparam value="#deliveryCompanyName#" cfsqltype="cf_sql_varchar">,
                            note = <cfqueryparam value="#note#" cfsqltype="cf_sql_varchar" null="#Trim(note) eq ''#">,
                            use_flag = <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint">,
                            update_datetime = NOW(),
                            update_staff_code = <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            update_staff_name = <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">
                        WHERE
                            delivery_company_code = <cfqueryparam value="#originalDeliveryCompanyCode#" cfsqltype="cf_sql_char">
                    </cfquery>

                    <cfset result["results"]["delivery_company_code"] = deliveryCompanyCode>
                    <cfset result["message"] = "更新しました。">

                <cfelse>
                    <cfquery>
                        INSERT INTO m_delivery_company (
                            delivery_company_code,
                            delivery_company_name,
                            note,
                            use_flag,
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">,
                            <cfqueryparam value="#deliveryCompanyName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#note#" cfsqltype="cf_sql_varchar" null="#Trim(note) eq ''#">,
                            <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint">,
                            NOW(),
                            <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">,
                            NULL,
                            NULL,
                            NULL
                        )
                    </cfquery>

                    <cfset result["results"]["delivery_company_code"] = deliveryCompanyCode>
                    <cfset result["message"] = "登録しました。">
                </cfif>
            </cftransaction>

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Error" text="配送業者保存エラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "保存中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="deleteDeliveryCompany" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var deliveryCompanyCode = "">
        <cfset var qCheckDeliveryCompany = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "delivery_company_code")>
                <cfset deliveryCompanyCode = Trim(requestData.delivery_company_code)>
            </cfif>

            <cfif deliveryCompanyCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者コードが不正です。">
                <cfreturn result>
            </cfif>

            <cftransaction>
                <cfquery name="qCheckDeliveryCompany">
                    SELECT
                        delivery_company_code,
                        delivery_company_name
                    FROM
                        m_delivery_company
                    WHERE
                        delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">
                </cfquery>

                <cfif qCheckDeliveryCompany.recordCount neq 1>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "削除対象データが存在しません。">
                    <cfreturn result>
                </cfif>

                <cfquery>
                    DELETE FROM
                        m_delivery_company
                    WHERE
                        delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_char">
                </cfquery>

                <cfset result["results"]["delivery_company_code"] = qCheckDeliveryCompany.delivery_company_code[1]>
                <cfset result["results"]["delivery_company_name"] = qCheckDeliveryCompany.delivery_company_name[1]>
                <cfset result["message"] = "削除しました。">
            </cftransaction>

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Error" text="配送業者削除エラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "削除中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>