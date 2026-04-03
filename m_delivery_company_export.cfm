<cfinclude template="init.cfm">
<cfsetting showdebugoutput="false">

<cfset searchDeliveryCompanyCode = "">
<cfset searchDeliveryCompanyName = "">
<cfset searchUseFlag = "">
<cfset sortField = "">
<cfset sortOrder = "">
<cfset orderBySql = "delivery_company_code ASC">

<cfset fileName = "">
<cfset csvHeader = "">
<cfset csvBody = "">
<cfset csvContent = "">
<cfset newLine = chr(13) & chr(10)>
<cfset timeStamp = dateFormat(now(), "yyyymmdd") & timeFormat(now(), "HHnnss")>

<cftry>
    <!--- ===== フォーム値取得 ===== --->
    <cfif StructKeyExists(Form, "search_delivery_company_code")>
        <cfset searchDeliveryCompanyCode = Trim(Form.search_delivery_company_code)>
    </cfif>

    <cfif StructKeyExists(Form, "search_delivery_company_name")>
        <cfset searchDeliveryCompanyName = Trim(Form.search_delivery_company_name)>
    </cfif>

    <cfif StructKeyExists(Form, "search_use_flag")>
        <cfset searchUseFlag = Trim(Form.search_use_flag)>
    </cfif>

    <cfif StructKeyExists(Form, "sort_field")>
        <cfset sortField = Trim(Form.sort_field)>
    </cfif>

    <cfif StructKeyExists(Form, "sort_order")>
        <cfset sortOrder = LCase(Trim(Form.sort_order))>
    </cfif>

    <!--- ===== ORDER BY制御 ===== --->
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

    <cfset fileName = "配送業者一覧_" & timeStamp & ".csv">

    <!--- ===== 一覧データ取得 ===== --->
    <cfquery name="qDeliveryCompany">
        SELECT
            delivery_company_code,
            delivery_company_name,
            note,
            CASE
                WHEN use_flag = 1 THEN '使用中'
                ELSE '停止'
            END AS use_flag_name,
            DATE_FORMAT(create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
            create_staff_code,
            create_staff_name,
            DATE_FORMAT(update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
            update_staff_code,
            update_staff_name
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
    </cfquery>

    <!--- ===== CSVヘッダ ===== --->
    <cfset csvHeader = '"配送業者コード","配送業者名","備考","使用区分","作成日時","作成者コード","作成者名","更新日時","更新者コード","更新者名"'>

    <!--- ===== CSV本文作成 ===== --->
    <cfset csvBody = csvHeader & newLine>

    <cfloop query="qDeliveryCompany">
        <cfset csvBody &= '"' & replace(qDeliveryCompany.delivery_company_code, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.delivery_company_name, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.note, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.use_flag_name, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.create_datetime_disp, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.create_staff_code, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.create_staff_name, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.update_datetime_disp, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.update_staff_code, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & replace(qDeliveryCompany.update_staff_name, '"', '""', 'all') & '"' & newLine >
    </cfloop>

    <cfset csvContent = csvBody>

    <cfheader
        name="Content-Disposition"
        value='attachment; filename="#fileName#"'>
    <cfcontent
        type="text/csv; charset=UTF-8"
        variable="#toBinary(toBase64(csvContent))#"
        reset="true">

    <cfcatch type="database">
        <cflog
            file="Hara"
            type="error"
            text="配送業者CSV出力エラー #cfcatch.message# | Detail: #cfcatch.detail# | SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">

        <cfheader
            name="Content-Disposition"
            value='attachment; filename="delivery_company_export_error.csv"'>
        <cfcontent
            type="text/csv; charset=UTF-8"
            reset="true">
        <cfoutput>CSV出力中にデータベースエラーが発生しました。</cfoutput>
    </cfcatch>

    <cfcatch type="any">
        <cflog
            file="Hara"
            type="error"
            text="配送業者CSV出力エラー #cfcatch.message# | Detail: #cfcatch.detail#">

        <cfheader
            name="Content-Disposition"
            value='attachment; filename="delivery_company_export_error.csv"'>
        <cfcontent
            type="text/csv; charset=UTF-8"
            reset="true">
        <cfoutput>CSV出力中にエラーが発生しました。</cfoutput>
    </cfcatch>
</cftry>