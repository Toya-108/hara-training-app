<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<cfset searchSupplierCode = "">
<cfif StructKeyExists(URL, "search_supplier_code")>
    <cfset searchSupplierCode = Trim(URL.search_supplier_code)>
</cfif>

<cfset searchSupplierName = "">
<cfif StructKeyExists(URL, "search_supplier_name")>
    <cfset searchSupplierName = Trim(URL.search_supplier_name)>
</cfif>

<cfset searchDeliveryCompany = "">
<cfif StructKeyExists(URL, "search_delivery_company")>
    <cfset searchDeliveryCompany = Trim(URL.search_delivery_company)>
</cfif>

<cfset searchUseFlag = "">
<cfif StructKeyExists(URL, "search_use_flag")>
    <cfset searchUseFlag = Trim(URL.search_use_flag)>
</cfif>

<cfset sortField = "">
<cfif StructKeyExists(URL, "sortField")>
    <cfset sortField = Trim(URL.sortField)>
</cfif>

<cfset sortOrder = "asc">
<cfif StructKeyExists(URL, "sortOrder") AND LCase(Trim(URL.sortOrder)) eq "desc">
    <cfset sortOrder = "desc">
</cfif>

<cfset orderBySql = "s.supplier_code ASC">

<cfif sortField eq "supplier_code">
    <cfset orderBySql = "s.supplier_code">
<cfelseif sortField eq "supplier_name">
    <cfset orderBySql = "s.supplier_name">
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

<cfset filtering = " WHERE 1 = 1 ">

<cfif searchSupplierCode neq "">
    <cfset filtering = filtering & " AND s.supplier_code = '" & Replace(searchSupplierCode, "'", "''", "all") & "'">
</cfif>

<cfif searchSupplierName neq "">
    <cfset filtering = filtering & " AND (s.supplier_name LIKE '%" & Replace(searchSupplierName, "'", "''", "all") & "%' OR s.supplier_name_kana LIKE '%" & Replace(searchSupplierName, "'", "''", "all") & "%')">
</cfif>

<cfif searchDeliveryCompany neq "">
    <cfset filtering = filtering & " AND s.delivery_company_code = '" & Replace(searchDeliveryCompany, "'", "''", "all") & "'">
</cfif>

<cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
    <cfset filtering = filtering & " AND s.use_flag = " & Val(searchUseFlag)>
</cfif>

<cfset export_file_name = "取引先マスタ_" & DateFormat(Now(), "yyyymmdd") & "_" & TimeFormat(Now(), "HHmmss") & ".csv">
<cfset export_file = Application.temp_path & Application.path_delimiter & export_file_name>

<cfset header_data = "取引先コード,取引先名,取引先名カナ,郵便番号,都道府県,住所1,住所2,電話番号,FAX番号,配送業者コード,配送業者名,備考,使用区分,作成日時,作成者コード,作成者名,更新日時,更新者コード,更新者名">
<cffile
    action="write"
    file="#export_file#"
    output="#header_data#"
    mode="777"
    charset="shift_jis">

<cfset pageSql = "
SELECT
    IFNULL(s.supplier_code, ''),
    IFNULL(s.supplier_name, ''),
    IFNULL(s.supplier_name_kana, ''),
    IFNULL(s.zip_code, ''),
    IFNULL(p.prefecture_name, ''),
    IFNULL(s.address1, ''),
    IFNULL(s.address2, ''),
    IFNULL(s.tel, ''),
    IFNULL(s.fax, ''),
    IFNULL(s.delivery_company_code, ''),
    IFNULL(d.delivery_company_name, ''),
    IFNULL(s.note, ''),
    IFNULL(CASE WHEN s.use_flag = 1 THEN '有効' ELSE '無効' END, ''),
    IFNULL(DATE_FORMAT(s.create_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(s.create_staff_code, ''),
    IFNULL(s.create_staff_name, ''),
    IFNULL(DATE_FORMAT(s.update_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(s.update_staff_code, ''),
    IFNULL(s.update_staff_name, '')
FROM
    m_supplier s
LEFT OUTER JOIN
    m_prefecture p
        ON s.prefecture_code = p.prefecture_code
LEFT OUTER JOIN
    m_delivery_company d
        ON s.delivery_company_code = d.delivery_company_code
#PreserveSingleQuotes(filtering)#
ORDER BY
    #PreserveSingleQuotes(orderBySql)#
">

<cfset ed = createObject("component", "training.hara.com.export_db")>
<cfset error_txt = ed.expDb(export_file, pageSql, "append")>

<cfif Trim(error_txt) neq "">
    <cfcontent type="text/plain; charset=UTF-8" reset="true">
    <cfoutput>CSVエクスポート中にエラーが発生しました。
#error_txt#</cfoutput>
    <cfabort>
</cfif>

<cflocation
    url="download.cfm?f=#URLEncodedFormat(export_file_name)#&fnm=#URLEncodedFormat(export_file_name)#"
    addtoken="false">