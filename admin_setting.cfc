<cfcomponent output="false">

    <cffunction name="saveBasicSetting" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestBody = "" />
        <cfset var requestData = {} />
        <cfset var companyCode = "" />
        <cfset var companyName = "" />
        <cfset var centerName = "" />
        <cfset var postalCode = "" />
        <cfset var address1 = "" />
        <cfset var address2 = "" />
        <cfset var telNo = "" />
        <cfset var faxNo = "" />
        <cfset var memo = "" />
        <cfset var adminPassword = "" />
        <cfset var hashedPassword = "" />
        <cfset var qExists = "" />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["results"] = {} />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "company_code")>
                <cfset companyCode = trim(requestData.company_code) />
            </cfif>

            <cfif structKeyExists(requestData, "company_name")>
                <cfset companyName = trim(requestData.company_name) />
            </cfif>

            <cfif structKeyExists(requestData, "center_name")>
                <cfset centerName = trim(requestData.center_name) />
            </cfif>

            <cfif structKeyExists(requestData, "postal_code")>
                <cfset postalCode = trim(requestData.postal_code) />
            </cfif>

            <cfif structKeyExists(requestData, "address1")>
                <cfset address1 = trim(requestData.address1) />
            </cfif>

            <cfif structKeyExists(requestData, "address2")>
                <cfset address2 = trim(requestData.address2) />
            </cfif>

            <cfif structKeyExists(requestData, "tel_no")>
                <cfset telNo = trim(requestData.tel_no) />
            </cfif>

            <cfif structKeyExists(requestData, "fax_no")>
                <cfset faxNo = trim(requestData.fax_no) />
            </cfif>

            <cfif structKeyExists(requestData, "memo")>
                <cfset memo = trim(requestData.memo) />
            </cfif>

            <cfif structKeyExists(requestData, "admin_password")>
                <cfset adminPassword = trim(requestData.admin_password) />
            </cfif>

            <cfif companyCode EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "会社コードを入力してください。" />
                <cfreturn result />
            </cfif>

            <cfif companyName EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "会社名を入力してください。" />
                <cfreturn result />
            </cfif>

            <!--- パスワードが入力されているときだけ bcrypt 化 --->
            <cfif adminPassword NEQ "">
                <cfset hashedPassword = hashAdminPassword(adminPassword) />
            </cfif>

            <cftransaction>
                <cfquery name="qExists">
                    SELECT
                        company_code,
                        admin_password
                    FROM m_admin
                    WHERE company_code = <cfqueryparam value="#companyCode#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfif qExists.recordCount GT 0>
                    <cfquery>
                        UPDATE m_admin
                        SET
                            company_name = <cfqueryparam value="#companyName#" cfsqltype="cf_sql_varchar" null="#companyName EQ ''#">,
                            center_name = <cfqueryparam value="#centerName#" cfsqltype="cf_sql_varchar" null="#centerName EQ ''#">,
                            postal_code = <cfqueryparam value="#postalCode#" cfsqltype="cf_sql_varchar" null="#postalCode EQ ''#">,
                            address1 = <cfqueryparam value="#address1#" cfsqltype="cf_sql_varchar" null="#address1 EQ ''#">,
                            address2 = <cfqueryparam value="#address2#" cfsqltype="cf_sql_varchar" null="#address2 EQ ''#">,
                            tel_no = <cfqueryparam value="#telNo#" cfsqltype="cf_sql_varchar" null="#telNo EQ ''#">,
                            fax_no = <cfqueryparam value="#faxNo#" cfsqltype="cf_sql_varchar" null="#faxNo EQ ''#">,
                            memo = <cfqueryparam value="#memo#" cfsqltype="cf_sql_varchar" null="#memo EQ ''#">,
                            <cfif adminPassword NEQ "">
                            admin_password = <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                            </cfif>
                            update_datetime = NOW(),
                            update_staff_code = <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            update_staff_name = <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">
                        WHERE company_code = <cfqueryparam value="#companyCode#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                <cfelse>
                    <cfquery>
                        INSERT INTO m_admin (
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
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#companyCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#companyName#" cfsqltype="cf_sql_varchar" null="#companyName EQ ''#">,
                            <cfqueryparam value="#centerName#" cfsqltype="cf_sql_varchar" null="#centerName EQ ''#">,
                            <cfqueryparam value="#postalCode#" cfsqltype="cf_sql_varchar" null="#postalCode EQ ''#">,
                            <cfqueryparam value="#address1#" cfsqltype="cf_sql_varchar" null="#address1 EQ ''#">,
                            <cfqueryparam value="#address2#" cfsqltype="cf_sql_varchar" null="#address2 EQ ''#">,
                            <cfqueryparam value="#telNo#" cfsqltype="cf_sql_varchar" null="#telNo EQ ''#">,
                            <cfqueryparam value="#faxNo#" cfsqltype="cf_sql_varchar" null="#faxNo EQ ''#">,
                            <cfqueryparam value="#memo#" cfsqltype="cf_sql_varchar" null="#memo EQ ''#">,
                            <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar" null="#adminPassword EQ ''#">,
                            NOW(),
                            <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">,
                            NULL,
                            NULL,
                            NULL
                        )
                    </cfquery>
                </cfif>
            </cftransaction>

            <cfset result["message"] = "基本設定を保存しました。" />
            <cfset result["results"]["company_code"] = companyCode />

            <cfcatch type="database">
                <cflog file="HARA-TRAINING-APP" type="Error" text="基本設定 保存エラー #cfcatch.SQL# #cfcatch.QueryError#">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "基本設定の保存中にデータベースエラーが発生しました。" />
            </cfcatch>

            <cfcatch type="any">
                <cflog file="HARA-TRAINING-APP" type="Error" text="基本設定 保存エラー #cfcatch.message#">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "基本設定の保存中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <cffunction name="hashAdminPassword" access="private" returntype="string" output="false">
        <cfargument name="plainPassword" type="string" required="true">

        <cfif trim(arguments.plainPassword) EQ "">
            <cfreturn "">
        </cfif>

        <cfreturn generateBCryptHash(arguments.plainPassword)>
    </cffunction>

    <cffunction name="checkAdminPassword" access="public" returntype="boolean" output="false">
        <cfargument name="plainPassword" type="string" required="true">
        <cfargument name="hashedPassword" type="string" required="true">

        <cfif trim(arguments.plainPassword) EQ "" OR trim(arguments.hashedPassword) EQ "">
            <cfreturn false>
        </cfif>

        <cfreturn checkBCryptHash(arguments.plainPassword, arguments.hashedPassword)>
    </cffunction>

</cfcomponent>