<cfcomponent displayname="MStaff" output="false">

    <cffunction name="getStaffList" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {}>

        <cfset var page = 1>
        <cfset var pageSize = 50>
        <cfset var startRow = 0>

        <cfset var sortField = "">
        <cfset var sortOrder = "">
        <cfset var orderBySql = "staff_code ASC">

        <cfset var searchStaffCode = "">
        <cfset var searchStaffName = "">
        <cfset var searchMailAddress = "">
        <cfset var searchAuthorityLevel = "">
        <cfset var searchUseFlag = "">

        <cfset var qGetCount = "">
        <cfset var qGetStaffList = "">
        <cfset var totalCount = 0>
        <cfset var totalPage = 1>

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = []>
        <cfset result["paging"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "page")>
                <cfset page = Val(requestData.page)>
            </cfif>

            <cfif StructKeyExists(requestData, "pageSize")>
                <cfset pageSize = Val(requestData.pageSize)>
            </cfif>

            <cfif StructKeyExists(requestData, "sortField")>
                <cfset sortField = Trim(requestData.sortField)>
            </cfif>

            <cfif StructKeyExists(requestData, "sortOrder")>
                <cfset sortOrder = LCase(Trim(requestData.sortOrder))>
            </cfif>

            <cfif StructKeyExists(requestData, "search_staff_code")>
                <cfset searchStaffCode = Trim(requestData.search_staff_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_staff_name")>
                <cfset searchStaffName = Trim(requestData.search_staff_name)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_mail_address")>
                <cfset searchMailAddress = Trim(requestData.search_mail_address)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_authority_level")>
                <cfset searchAuthorityLevel = Trim(requestData.search_authority_level)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_use_flag")>
                <cfset searchUseFlag = Trim(requestData.search_use_flag)>
            </cfif>

            <cfif page lte 0>
                <cfset page = 1>
            </cfif>

            <cfif pageSize lte 0>
                <cfset pageSize = 50>
            </cfif>

            <cfset startRow = (page - 1) * pageSize>

            <cfif sortField eq "staff_code">
                <cfset orderBySql = "staff_code">
            <cfelseif sortField eq "staff_name">
                <cfset orderBySql = "staff_name">
            <cfelseif sortField eq "authority_level">
                <cfset orderBySql = "authority_level">
            <cfelseif sortField eq "mail_address">
                <cfset orderBySql = "mail_address">
            <cfelseif sortField eq "use_flag">
                <cfset orderBySql = "use_flag">
            <cfelseif sortField eq "create_datetime">
                <cfset orderBySql = "create_datetime">
            <cfelseif sortField eq "update_datetime">
                <cfset orderBySql = "update_datetime">
            <cfelse>
                <cfset orderBySql = "staff_code">
            </cfif>

            <cfif sortOrder eq "desc">
                <cfset orderBySql = orderBySql & " DESC">
            <cfelse>
                <cfset orderBySql = orderBySql & " ASC">
            </cfif>

            <cfquery name="qGetCount">
                SELECT COUNT(*) AS total_count
                FROM m_staff
                WHERE 1 = 1
                <cfif searchStaffCode neq "">
                    AND staff_code = <cfqueryparam value="#searchStaffCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchStaffName neq "">
                    AND (
                        staff_name LIKE <cfqueryparam value="%#searchStaffName#%" cfsqltype="cf_sql_varchar">
                        OR staff_kana LIKE <cfqueryparam value="%#searchStaffName#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif searchMailAddress neq "">
                    AND mail_address LIKE <cfqueryparam value="%#searchMailAddress#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchAuthorityLevel eq "1" OR searchAuthorityLevel eq "2" OR searchAuthorityLevel eq "9">
                    AND authority_level = <cfqueryparam value="#searchAuthorityLevel#" cfsqltype="cf_sql_tinyint">
                </cfif>
                <cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
                    AND use_flag = <cfqueryparam value="#searchUseFlag#" cfsqltype="cf_sql_tinyint">
                </cfif>
            </cfquery>

            <cfset totalCount = qGetCount.total_count>

            <cfif totalCount gt 0>
                <cfset totalPage = Ceiling(totalCount / pageSize)>
            <cfelse>
                <cfset totalPage = 1>
            </cfif>

            <cfif page gt totalPage>
                <cfset page = totalPage>
                <cfset startRow = (page - 1) * pageSize>
            </cfif>

            <cfquery name="qGetStaffList">
                SELECT
                    staff_id,
                    staff_code,
                    staff_name,
                    staff_kana,
                    authority_level,
                    mail_address,
                    tel_no,
                    use_flag,
                    DATE_FORMAT(last_login_datetime, '%Y/%m/%d') AS last_login_datetime_disp,
                    DATE_FORMAT(password_update_datetime, '%Y/%m/%d') AS password_update_datetime_disp,
                    note,
                    DATE_FORMAT(create_datetime, '%Y/%m/%d') AS create_datetime_disp,
                    create_staff_code,
                    create_staff_name,
                    DATE_FORMAT(update_datetime, '%Y/%m/%d') AS update_datetime_disp,
                    update_staff_code,
                    update_staff_name
                FROM
                    m_staff
                WHERE 1 = 1
                <cfif searchStaffCode neq "">
                    AND staff_code = <cfqueryparam value="#searchStaffCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchStaffName neq "">
                    AND (
                        staff_name LIKE <cfqueryparam value="%#searchStaffName#%" cfsqltype="cf_sql_varchar">
                        OR staff_kana LIKE <cfqueryparam value="%#searchStaffName#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif searchMailAddress neq "">
                    AND mail_address LIKE <cfqueryparam value="%#searchMailAddress#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchAuthorityLevel eq "1" OR searchAuthorityLevel eq "2" OR searchAuthorityLevel eq "9">
                    AND authority_level = <cfqueryparam value="#searchAuthorityLevel#" cfsqltype="cf_sql_tinyint">
                </cfif>
                <cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
                    AND use_flag = <cfqueryparam value="#searchUseFlag#" cfsqltype="cf_sql_tinyint">
                </cfif>
                ORDER BY #preserveSingleQuotes(orderBySql)#
                LIMIT #startRow#, #pageSize#
            </cfquery>

            <cfset result["status"] = 0>
            <cfset result["message"] = "社員一覧を取得しました。">
            <cfset result["results"] = []>

            <cfloop query="qGetStaffList">
                <cfset ArrayAppend(result["results"], {
                    "staff_id" = qGetStaffList.staff_id,
                    "staff_code" = qGetStaffList.staff_code,
                    "staff_name" = qGetStaffList.staff_name,
                    "staff_kana" = qGetStaffList.staff_kana,
                    "authority_level" = qGetStaffList.authority_level,
                    "mail_address" = qGetStaffList.mail_address,
                    "tel_no" = qGetStaffList.tel_no,
                    "use_flag" = qGetStaffList.use_flag,
                    "last_login_datetime_disp" = qGetStaffList.last_login_datetime_disp,
                    "password_update_datetime_disp" = qGetStaffList.password_update_datetime_disp,
                    "note" = qGetStaffList.note,
                    "create_datetime_disp" = qGetStaffList.create_datetime_disp,
                    "create_staff_code" = qGetStaffList.create_staff_code,
                    "create_staff_name" = qGetStaffList.create_staff_name,
                    "update_datetime_disp" = qGetStaffList.update_datetime_disp,
                    "update_staff_code" = qGetStaffList.update_staff_code,
                    "update_staff_name" = qGetStaffList.update_staff_name
                })>
            </cfloop>

            <cfset result["paging"]["page"] = page>
            <cfset result["paging"]["pageSize"] = pageSize>
            <cfset result["paging"]["totalCount"] = totalCount>
            <cfset result["paging"]["totalPage"] = totalPage>
            <cfset result["paging"]["hasPrev"] = (page gt 1)>
            <cfset result["paging"]["hasNext"] = (page lt totalPage)>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="社員一覧取得エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "社員一覧の取得中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>