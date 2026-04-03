<cfcomponent displayname="MDeliveryCompany" output="false">

    <cffunction name="getDeliveryCompanyList" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {}>

        <cfset var page = 1>
        <cfset var pageSize = 50>
        <cfset var startRow = 0>

        <cfset var sortField = "">
        <cfset var sortOrder = "">
        <cfset var orderBySql = "delivery_company_code ASC">

        <cfset var searchDeliveryCompanyCode = "">
        <cfset var searchDeliveryCompanyName = "">
        <cfset var searchUseFlag = "">

        <cfset var qGetCount = "">
        <cfset var qGetDeliveryCompanyList = "">
        <cfset var totalCount = 0>
        <cfset var totalPage = 1>
        <cfset var rowData = {}>

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

            <cfif StructKeyExists(requestData, "search_delivery_company_code")>
                <cfset searchDeliveryCompanyCode = Trim(requestData.search_delivery_company_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_delivery_company_name")>
                <cfset searchDeliveryCompanyName = Trim(requestData.search_delivery_company_name)>
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

            <cfif sortField eq "delivery_company_code">
                <cfset orderBySql = "delivery_company_code">
            <cfelseif sortField eq "delivery_company_name">
                <cfset orderBySql = "delivery_company_name">
            <cfelseif sortField eq "note">
                <cfset orderBySql = "note">
            <cfelseif sortField eq "use_flag">
                <cfset orderBySql = "use_flag">
            <cfelseif sortField eq "create_datetime">
                <cfset orderBySql = "create_datetime">
            <cfelseif sortField eq "update_datetime">
                <cfset orderBySql = "update_datetime">
            <cfelse>
                <cfset orderBySql = "delivery_company_code">
            </cfif>

            <cfif sortOrder eq "desc">
                <cfset orderBySql = orderBySql & " DESC">
            <cfelse>
                <cfset orderBySql = orderBySql & " ASC">
            </cfif>

            <cfquery name="qGetCount">
                SELECT
                    COUNT(*) AS total_count
                FROM
                    m_delivery_company
                WHERE
                    1 = 1
                <cfif searchDeliveryCompanyCode neq "">
                    AND delivery_company_code = <cfqueryparam value="#searchDeliveryCompanyCode#" cfsqltype="cf_sql_char">
                </cfif>
                <cfif searchDeliveryCompanyName neq "">
                    AND delivery_company_name LIKE <cfqueryparam value="%#searchDeliveryCompanyName#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
                    AND use_flag = <cfqueryparam value="#searchUseFlag#" cfsqltype="cf_sql_tinyint">
                </cfif>
            </cfquery>

            <cfset totalCount = qGetCount.total_count[1]>

            <cfif totalCount gt 0>
                <cfset totalPage = Ceiling(totalCount / pageSize)>
            <cfelse>
                <cfset totalPage = 1>
            </cfif>

            <cfif page gt totalPage>
                <cfset page = totalPage>
                <cfset startRow = (page - 1) * pageSize>
            </cfif>

            <cfquery name="qGetDeliveryCompanyList">
                SELECT
                    delivery_company_code,
                    delivery_company_name,
                    note,
                    use_flag,
                    DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
                    DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp
                FROM
                    m_delivery_company
                WHERE
                    1 = 1
                <cfif searchDeliveryCompanyCode neq "">
                    AND delivery_company_code = <cfqueryparam value="#searchDeliveryCompanyCode#" cfsqltype="cf_sql_char">
                </cfif>
                <cfif searchDeliveryCompanyName neq "">
                    AND delivery_company_name LIKE <cfqueryparam value="%#searchDeliveryCompanyName#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
                    AND use_flag = <cfqueryparam value="#searchUseFlag#" cfsqltype="cf_sql_tinyint">
                </cfif>
                ORDER BY #PreserveSingleQuotes(orderBySql)#
                LIMIT <cfqueryparam value="#startRow#" cfsqltype="cf_sql_integer">,
                      <cfqueryparam value="#pageSize#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfloop query="qGetDeliveryCompanyList">
                <cfset rowData = {}>

                <cfset rowData["delivery_company_code"] = qGetDeliveryCompanyList.delivery_company_code>
                <cfset rowData["delivery_company_name"] = qGetDeliveryCompanyList.delivery_company_name>
                <cfset rowData["note"] = qGetDeliveryCompanyList.note>
                <cfset rowData["use_flag"] = qGetDeliveryCompanyList.use_flag>
                <cfset rowData["create_datetime_disp"] = qGetDeliveryCompanyList.create_datetime_disp>
                <cfset rowData["update_datetime_disp"] = qGetDeliveryCompanyList.update_datetime_disp>

                <cfset ArrayAppend(result["results"], rowData)>
            </cfloop>

            <cfset result["paging"]["currentPage"] = page>
            <cfset result["paging"]["pageSize"] = pageSize>
            <cfset result["paging"]["totalCount"] = totalCount>
            <cfset result["paging"]["totalPage"] = totalPage>

            <cfset result["message"] = "取得しました。">

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Error" text="配送業者一覧取得エラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "配送業者一覧の取得中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>