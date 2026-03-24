<cfcomponent displayname="MItem" output="false">

    <cffunction name="getItemList" access="remote" returntype="struct" returnformat="json" output="false">

        <cfset var result = {}>
        <cfset var requestData = {}>

        <cfset var page = 1>
        <cfset var pageSize = 50>
        <cfset var startRow = 0>

        <cfset var sortField = "">
        <cfset var sortOrder = "">
        <cfset var orderBySql = "item_code ASC">

        <cfset var searchProductCode = "">
        <cfset var searchJanCode = "">
        <cfset var searchProductName = "">

        <cfset var filtering = "">

        <cfset var qGetCount = "">
        <cfset var qGetItemList = "">
        <cfset var totalCount = 0>
        <cfset var totalPage = 1>

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = []>
        <cfset result["paging"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <!--- ページ情報取得 --->
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

            <!--- 検索条件取得 --->
            <cfif StructKeyExists(requestData, "search_product_code")>
                <cfset searchProductCode = Trim(requestData.search_product_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_jan_code")>
                <cfset searchJanCode = Trim(requestData.search_jan_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "search_product_name")>
                <cfset searchProductName = Trim(requestData.search_product_name)>
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
            <cfif sortField eq "item_code">
                <cfset orderBySql = "item_code">
            <cfelseif sortField eq "jan_code">
                <cfset orderBySql = "jan_code">
            <cfelseif sortField eq "item_category">
                <cfset orderBySql = "item_name_kana">
            <cfelseif sortField eq "item_name">
                <cfset orderBySql = "item_name">
            <cfelseif sortField eq "cost_price">
                <cfset orderBySql = "gentanka">
            <cfelse>
                <cfset orderBySql = "item_code">
            </cfif>

            <cfif sortOrder eq "desc">
                <cfset orderBySql = orderBySql & " DESC">
            <cfelse>
                <cfset orderBySql = orderBySql & " ASC">
            </cfif>

            <!--- filtering 作成 --->
            <cfset filtering = "">

            <cfif searchProductCode neq "">
              <cfset filtering = filtering & " AND item_code = '#searchProductCode#'">
            </cfif>

            <cfif searchJanCode neq "">
                <cfset filtering = filtering & " AND jan_code = '#searchJanCode#'">
            </cfif>

            <cfif searchProductName neq "">
                <cfset filtering = filtering & " AND (item_name LIKE '%" & searchProductName & "%' OR item_name_kana LIKE '%" & searchProductName & "%')">
            </cfif>

            <!--- 件数取得 --->
            <cfquery name="qGetCount">
                SELECT COUNT(*) AS total_count
                FROM m_item
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
            <cfquery name="qGetItemList">
                SELECT
                    item_code,
                    jan_code,
                    item_name_kana,
                    item_name,
                    gentanka
                FROM m_item
                WHERE 1 = 1
                #preserveSingleQuotes(filtering)#
                ORDER BY #preserveSingleQuotes(orderBySql)#
                LIMIT #startRow#, #pageSize#
            </cfquery>

            <cfset result["status"] = 1>
            <cfset result["message"] = "商品一覧を取得しました。">
            <cfset result["results"] = []>

            <cfloop query="qGetItemList">
                <cfset ArrayAppend(result["results"], {
                    "item_code" = qGetItemList.item_code,
                    "jan_code" = qGetItemList.jan_code,
                    "item_name_kana" = qGetItemList.item_name_kana,
                    "item_name" = qGetItemList.item_name,
                    "gentanka" = qGetItemList.gentanka
                })>
            </cfloop>

            <cfset result["paging"]["page"] = page>
            <cfset result["paging"]["pageSize"] = pageSize>
            <cfset result["paging"]["totalCount"] = totalCount>
            <cfset result["paging"]["totalPage"] = totalPage>
            <cfset result["paging"]["hasPrev"] = (page gt 1)>
            <cfset result["paging"]["hasNext"] = (page lt totalPage)>

            <cfcatch>
              <cflog file="HARA_TRAINING_APP" type="Error" text="商品一覧取得エラー #cfcatch.sql#　#cfcatch.queryError#">
              <cfset result["status"] = 0>
              <cfset result["message"] = "商品一覧の取得中にエラーが発生しました。">
          </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>