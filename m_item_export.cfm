<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<cfset searchProductCode = "">
<cfif StructKeyExists(URL, "search_product_code")>
    <cfset searchProductCode = Trim(URL.search_product_code)>
</cfif>

<cfset searchJanCode = "">
<cfif StructKeyExists(URL, "search_jan_code")>
    <cfset searchJanCode = Trim(URL.search_jan_code)>
</cfif>

<cfset searchProductName = "">
<cfif StructKeyExists(URL, "search_product_name")>
    <cfset searchProductName = Trim(URL.search_product_name)>
</cfif>

<cfset sortField = "">
<cfif StructKeyExists(URL, "sortField")>
    <cfset sortField = Trim(URL.sortField)>
</cfif>

<cfset sortOrder = "asc">
<cfif StructKeyExists(URL, "sortOrder") AND LCase(Trim(URL.sortOrder)) eq "desc">
    <cfset sortOrder = "desc">
</cfif>

<cfset orderBySql = "m_item.item_code ASC">

<cfif sortField eq "item_code">
    <cfset orderBySql = "m_item.item_code">
<cfelseif sortField eq "jan_code">
    <cfset orderBySql = "m_item.jan_code">
<cfelseif sortField eq "item_name">
    <cfset orderBySql = "m_item.item_name">
<cfelseif sortField eq "create_datetime">
    <cfset orderBySql = "m_item.create_datetime">
<cfelseif sortField eq "update_datetime">
    <cfset orderBySql = "m_item.update_datetime">
<cfelse>
    <cfset orderBySql = "m_item.item_code">
</cfif>

<cfif sortOrder eq "desc">
    <cfset orderBySql = orderBySql & " DESC">
<cfelse>
    <cfset orderBySql = orderBySql & " ASC">
</cfif>

<cfset filtering = " WHERE 1 = 1 ">

<cfif searchProductCode neq "">
    <cfset filtering = filtering & " AND m_item.item_code = '" & Replace(searchProductCode, "'", "''", "all") & "'">
</cfif>

<cfif searchJanCode neq "">
    <cfset filtering = filtering & " AND m_item.jan_code = '" & Replace(searchJanCode, "'", "''", "all") & "'">
</cfif>

<cfif searchProductName neq "">
    <cfset filtering = filtering & " AND (m_item.item_name LIKE '%" & Replace(searchProductName, "'", "''", "all") & "%' OR m_item.item_name_kana LIKE '%" & Replace(searchProductName, "'", "''", "all") & "%')">
</cfif>

<!--- 出力ファイル名 --->
<cfset export_file_name = "商品マスタ_" & DateFormat(Now(), "yyyymmdd") & "_" & TimeFormat(Now(), "HHmmss") & ".csv">
<cfset export_file = Application.temp_path & Application.path_delimiter & export_file_name>

<!--- 見出しは先に1回だけ出力 --->
<cfset header_data = "商品コード,JANコード,商品名,商品名カナ,原価,売価,分類,使用区分,作成日時,作成者コード,作成者名,更新日時,更新者コード,更新者名">
<cffile
    action="write"
    file="#export_file#"
    output="#header_data#"
    mode="777"
    charset="shift_jis">

<!---
    データ本体のみをSQLで出力
    export_db.sh 側で
    - mysql実行
    - タブ→カンマ変換
    - CP932変換
    を行う前提
--->
<cfset pageSql = "
SELECT
    IFNULL(m_item.item_code, ''),
    IFNULL(m_item.jan_code, ''),
    IFNULL(m_item.item_name, ''),
    IFNULL(m_item.item_name_kana, ''),

    IFNULL(CAST(m_item.gentanka AS CHAR), ''),
    IFNULL(CAST(m_item.baitanka AS CHAR), ''),

    IFNULL(
        CASE
            WHEN m_item.item_category = 1 THEN '食品'
            WHEN m_item.item_category = 2 THEN '雑貨'
            WHEN m_item.item_category = 3 THEN '日用品'
            WHEN m_item.item_category = 4 THEN '衣料'
            WHEN m_item.item_category = 5 THEN '小物'
            ELSE ''
        END
    , ''),

    IFNULL(CASE WHEN m_item.use_flag = 1 THEN '有効' ELSE '無効' END, ''),

    IFNULL(DATE_FORMAT(m_item.create_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(m_item.create_staff_code, ''),
    IFNULL(m_item.create_staff_name, ''),
    IFNULL(DATE_FORMAT(m_item.update_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(m_item.update_staff_code, ''),
    IFNULL(m_item.update_staff_name, '')

FROM m_item
#PreserveSingleQuotes(filtering)#
ORDER BY #PreserveSingleQuotes(orderBySql)#
">

<!--- export_db.cfc を呼び出してデータ行を追記 --->
<cfset ed = createObject("component", "training.hara.com.export_db")>
<cfset error_txt = ed.expDb(export_file, pageSql, "append")>

<cfif Trim(error_txt) neq "">
    <cfcontent type="text/plain; charset=UTF-8" reset="true">
    <cfoutput>CSVエクスポート中にエラーが発生しました。
#error_txt#</cfoutput>
    <cfabort>
</cfif>

<!--- ダウンロード --->
<cflocation
    url="download.cfm?f=#URLEncodedFormat(export_file_name)#&fnm=#URLEncodedFormat(export_file_name)#"
    addtoken="false">