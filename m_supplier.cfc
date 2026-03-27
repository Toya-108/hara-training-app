<cfcomponent displayname="MSupplier" output="false">

    <cffunction name="getSupplierList" access="remote" returntype="struct" returnformat="json" output="false">

        <cfset var result = {}>
        <cfset var requestData = {}>

        <cfset var page = 1>
        <cfset var pageSize = 50>
        <cfset var startRow = 0>

        <cfset var sortField = "">
        <cfset var sortOrder = "">
        <cfset var orderBySql = "s.supplier_code ASC">

        <cfset var searchSupplierCode = "">
        <cfset var searchSupplierName = "">
        <cfset var searchSupplierNameKana = "">
        <cfset var searchDeliveryCompany = "">
        <cfset var searchUseFlag = "">

        <cfset var filtering = "">

        <cfset var qGetCount = "">
        <cfset var qGetSupplierList = "">
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

            <cfif StructKeyExists(requestData, "search_supplier_code")>
                <cfset searchSupplierCode = Trim(requestData.search_supplier_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_supplier_name")>
                <cfset searchSupplierName = Trim(requestData.search_supplier_name)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_supplier_name_kana")>
                <cfset searchSupplierNameKana = Trim(requestData.search_supplier_name_kana)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_delivery_company")>
                <cfset searchDeliveryCompany = Trim(requestData.search_delivery_company)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_use_flag")>
                <cfset searchUseFlag = Trim(requestData.search_use_flag)>
            </cfif>

            <cfset sleep(100)>

            <cfif page lte 0>
                <cfset page = 1>
            </cfif>

            <cfif pageSize lte 0>
                <cfset pageSize = 50>
            </cfif>

            <cfset startRow = (page - 1) * pageSize>

            <!--- ソート条件作成 --->
            <cfif sortField eq "supplier_code">
                <cfset orderBySql = "s.supplier_code">
            <cfelseif sortField eq "supplier_name">
                <cfset orderBySql = "s.supplier_name">
            <cfelseif sortField eq "supplier_name_kana">
                <cfset orderBySql = "s.supplier_name_kana">
            <cfelseif sortField eq "tel">
                <cfset orderBySql = "s.tel">
            <cfelseif sortField eq "delivery_company">
                <cfset orderBySql = "d.delivery_company_name">
            <cfelseif sortField eq "use_flag">
                <cfset orderBySql = "s.use_flag">
            <cfelseif sortField eq "create_datetime">
                <cfset orderBySql = "s.create_datetime">
            <cfelseif sortField eq "update_datetime">
                <cfset orderBySql = "s.update_datetime">
            <cfelse>
                <cfset orderBySql = "s.supplier_code">
            </cfif>

            <cfif sortOrder eq "desc">
                <cfset orderBySql = orderBySql & " DESC">
            <cfelse>
                <cfset orderBySql = orderBySql & " ASC">
            </cfif>

            <!--- filtering 作成 --->
            <cfset filtering = "">

            <cfif searchSupplierCode neq "">
                <cfset filtering = filtering & " AND s.supplier_code = '" & searchSupplierCode & "'">
            </cfif>

            <cfif searchSupplierName neq "">
                <cfset filtering = filtering & " AND (s.supplier_name LIKE '%" & searchSupplierName & "%' OR s.supplier_name_kana LIKE '%" & searchSupplierName & "%')">
            </cfif>

            <cfif searchDeliveryCompany neq "">
                <cfset filtering = filtering & " AND d.delivery_company_code = '" & searchDeliveryCompany & "'">
            </cfif>

            <cfif searchUseFlag eq "0" or searchUseFlag eq "1">
                <cfset filtering = filtering & " AND s.use_flag = " & Val(searchUseFlag)>
            </cfif>

            <!--- 件数取得 --->
            <cfquery name="qGetCount">
                SELECT COUNT(*) AS total_count
                FROM m_supplier s
                LEFT OUTER JOIN m_delivery_company d
                    ON s.delivery_company_code = d.delivery_company_code
                WHERE 1 = 1
                #preserveSingleQuotes(filtering)#
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

            <!--- 一覧取得 --->
            <cfquery name="qGetSupplierList">
                SELECT
                    s.supplier_id,
                    s.supplier_code,
                    s.supplier_name,
                    s.supplier_name_kana,
                    s.zip_code,
                    s.prefecture_code,
                    s.address1,
                    s.address2,
                    s.tel,
                    s.fax,
                    s.delivery_company_code,
                    d.delivery_company_name,
                    s.note,
                    s.use_flag,
                    s.create_datetime,
                    s.create_staff_code,
                    s.create_staff_name,
                    DATE_FORMAT(s.create_datetime, '%Y/%m/%d') AS create_datetime_disp,
                    s.update_datetime,
                    s.update_staff_code,
                    s.update_staff_name,
                    DATE_FORMAT(s.update_datetime, '%Y/%m/%d') AS update_datetime_disp
                FROM m_supplier s
                LEFT OUTER JOIN m_delivery_company d
                    ON s.delivery_company_code = d.delivery_company_code
                WHERE 1 = 1
                #preserveSingleQuotes(filtering)#
                ORDER BY #preserveSingleQuotes(orderBySql)#
                LIMIT #startRow#, #pageSize#
            </cfquery>

            <cfset result["status"] = 1>
            <cfset result["message"] = "取引先一覧を取得しました。">
            <cfset result["results"] = []>

            <cfloop query="qGetSupplierList">
                <cfset ArrayAppend(result["results"], {
                    "supplier_id" = qGetSupplierList.supplier_id,
                    "supplier_code" = qGetSupplierList.supplier_code,
                    "supplier_name" = qGetSupplierList.supplier_name,
                    "supplier_name_kana" = qGetSupplierList.supplier_name_kana,
                    "zip_code" = qGetSupplierList.zip_code,
                    "prefecture" = qGetSupplierList.prefecture_code,
                    "address1" = qGetSupplierList.address1,
                    "address2" = qGetSupplierList.address2,
                    "tel" = qGetSupplierList.tel,
                    "fax" = qGetSupplierList.fax,
                    "delivery_company_code" = qGetSupplierList.delivery_company_code,
                    "delivery_company" = qGetSupplierList.delivery_company_name,
                    "note" = qGetSupplierList.note,
                    "use_flag" = qGetSupplierList.use_flag,
                    "create_datetime" = qGetSupplierList.create_datetime,
                    "create_staff_code" = qGetSupplierList.create_staff_code,
                    "create_staff_name" = qGetSupplierList.create_staff_name,
                    "create_datetime_disp" = qGetSupplierList.create_datetime_disp,
                    "update_datetime" = qGetSupplierList.update_datetime,
                    "update_staff_code" = qGetSupplierList.update_staff_code,
                    "update_staff_name" = qGetSupplierList.update_staff_name,
                    "update_datetime_disp" = qGetSupplierList.update_datetime_disp
                })>
            </cfloop>result

            <cfset result["paging"]["page"] = page>
            <cfset result["paging"]["pageSize"] = pageSize>
            <cfset result["paging"]["totalCount"] = totalCount>
            <cfset result["paging"]["totalPage"] = totalPage>
            <cfset result["paging"]["hasPrev"] = (page gt 1)>
            <cfset result["paging"]["hasNext"] = (page lt totalPage)>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="取引先一覧取得エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 0>
                <cfset result["message"] = "取引先一覧の取得中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>