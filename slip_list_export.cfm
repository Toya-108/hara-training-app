<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<cfset searchSlipNo = "">
<cfif StructKeyExists(URL, "search_slip_no")>
    <cfset searchSlipNo = Trim(URL.search_slip_no)>
</cfif>

<cfset searchOrderDateFrom = "">
<cfif StructKeyExists(URL, "search_order_date_from")>
    <cfset searchOrderDateFrom = Trim(URL.search_order_date_from)>
</cfif>

<cfset searchOrderDateTo = "">
<cfif StructKeyExists(URL, "search_order_date_to")>
    <cfset searchOrderDateTo = Trim(URL.search_order_date_to)>
</cfif>

<cfset searchDeliveryDateFrom = "">
<cfif StructKeyExists(URL, "search_delivery_date_from")>
    <cfset searchDeliveryDateFrom = Trim(URL.search_delivery_date_from)>
</cfif>

<cfset searchDeliveryDateTo = "">
<cfif StructKeyExists(URL, "search_delivery_date_to")>
    <cfset searchDeliveryDateTo = Trim(URL.search_delivery_date_to)>
</cfif>

<cfset searchSupplierCode = "">
<cfif StructKeyExists(URL, "search_supplier_code")>
    <cfset searchSupplierCode = Trim(URL.search_supplier_code)>
</cfif>

<cfset searchSupplierKeyword = "">
<cfif StructKeyExists(URL, "search_supplier_keyword")>
    <cfset searchSupplierKeyword = Trim(URL.search_supplier_keyword)>
</cfif>

<cfset searchItemKeyword = "">
<cfif StructKeyExists(URL, "search_item_keyword")>
    <cfset searchItemKeyword = Trim(URL.search_item_keyword)>
</cfif>

<cfset searchStatus = "">
<cfif StructKeyExists(URL, "search_status")>
    <cfset searchStatus = Trim(URL.search_status)>
</cfif>

<cfset sortField = "">
<cfif StructKeyExists(URL, "sortField")>
    <cfset sortField = Trim(URL.sortField)>
</cfif>

<cfset sortOrder = "asc">
<cfif StructKeyExists(URL, "sortOrder") AND LCase(Trim(URL.sortOrder)) eq "desc">
    <cfset sortOrder = "desc">
</cfif>

<cfset orderBySql = "t_slip.slip_no ASC, t_slip_detail.line_no ASC">

<cfif sortField eq "slip_no">
    <cfset orderBySql = "t_slip.slip_no">
<cfelseif sortField eq "slip_date">
    <cfset orderBySql = "t_slip.slip_date">
<cfelseif sortField eq "delivery_date">
    <cfset orderBySql = "t_slip.delivery_date">
<cfelseif sortField eq "supplier_code">
    <cfset orderBySql = "t_slip.supplier_code">
<cfelseif sortField eq "total_qty">
    <cfset orderBySql = "t_slip.total_qty">
<cfelseif sortField eq "status">
    <cfset orderBySql = "t_slip.status">
<cfelse>
    <cfset orderBySql = "t_slip.slip_no">
</cfif>

<cfif sortOrder eq "desc">
    <cfset orderBySql = orderBySql & " DESC, t_slip_detail.line_no DESC">
<cfelse>
    <cfset orderBySql = orderBySql & " ASC, t_slip_detail.line_no ASC">
</cfif>

<cfset filtering = " WHERE 1 = 1 ">

<cfif searchSlipNo neq "">
    <cfset filtering = filtering & " AND t_slip.slip_no LIKE '%" & Replace(searchSlipNo, "'", "''", "all") & "%'">
</cfif>

<cfif searchOrderDateFrom neq "">
    <cfset filtering = filtering & " AND t_slip.slip_date >= '" & Replace(searchOrderDateFrom, "'", "''", "all") & "'">
</cfif>

<cfif searchOrderDateTo neq "">
    <cfset filtering = filtering & " AND t_slip.slip_date <= '" & Replace(searchOrderDateTo, "'", "''", "all") & "'">
</cfif>

<cfif searchDeliveryDateFrom neq "">
    <cfset filtering = filtering & " AND t_slip.delivery_date >= '" & Replace(searchDeliveryDateFrom, "'", "''", "all") & "'">
</cfif>

<cfif searchDeliveryDateTo neq "">
    <cfset filtering = filtering & " AND t_slip.delivery_date <= '" & Replace(searchDeliveryDateTo, "'", "''", "all") & "'">
</cfif>

<cfif searchSupplierCode neq "">
    <cfset filtering = filtering & " AND t_slip.supplier_code = '" & Replace(searchSupplierCode, "'", "''", "all") & "'">
</cfif>

<cfif searchSupplierKeyword neq "">
    <cfset safeKeyword = Replace(searchSupplierKeyword, "'", "''", "all")>
    <cfset filtering = filtering & "
        AND (
            m_supplier.supplier_name LIKE '%" & safeKeyword & "%'
            OR
            m_supplier.supplier_name_kana LIKE '%" & safeKeyword & "%'
        )
    ">
</cfif>

<cfif searchItemKeyword neq "">
    <cfset filtering = filtering & "
        AND EXISTS (
            SELECT 1
            FROM t_slip_detail t_slip_detail_exists
            LEFT OUTER JOIN m_item m_item_exists
                ON t_slip_detail_exists.item_code = m_item_exists.item_code
            WHERE t_slip_detail_exists.slip_no = t_slip.slip_no
              AND (
                    m_item_exists.item_code = '" & Replace(searchItemKeyword, "'", "''", "all") & "'
                 OR m_item_exists.jan_code = '" & Replace(searchItemKeyword, "'", "''", "all") & "'
                 OR m_item_exists.item_name LIKE '%" & Replace(searchItemKeyword, "'", "''", "all") & "%'
                 OR m_item_exists.item_name_kana LIKE '%" & Replace(searchItemKeyword, "'", "''", "all") & "%'
              )
        )
    ">
</cfif>

<cfif searchStatus eq "1" OR searchStatus eq "2" OR searchStatus eq "3">
    <cfset filtering = filtering & " AND t_slip.status = " & Val(searchStatus)>
</cfif>

<cfset export_file_name = "伝票一覧_" & DateFormat(Now(), "yyyymmdd") & "_" & TimeFormat(Now(), "HHmmss") & ".csv">
<cfset export_file = Application.temp_path & Application.path_delimiter & export_file_name>

<cfset header_data = "伝票番号,発注日,納品日,状態,状態名,取引先コード,取引先名,合計数量,合計金額,確定日時,削除日時,伝票備考,行番号,商品コード,JANコード,商品名,数量,単価,明細金額,明細備考,伝票作成日時,伝票作成者コード,伝票作成者名,伝票更新日時,伝票更新者コード,伝票更新者名,明細作成日時,明細作成者コード,明細作成者名,明細更新日時,明細更新者コード,明細更新者名">

<cffile
    action="write"
    file="#export_file#"
    output="#header_data#"
    mode="777"
    charset="shift_jis">

<cfset pageSql = "
SELECT
    IFNULL(t_slip.slip_no, ''),
    IFNULL(DATE_FORMAT(t_slip.slip_date, '%Y/%m/%d'), ''),
    IFNULL(DATE_FORMAT(t_slip.delivery_date, '%Y/%m/%d'), ''),
    IFNULL(CAST(t_slip.status AS CHAR), ''),
    IFNULL(
        CASE
            WHEN t_slip.status = 1 THEN '登録'
            WHEN t_slip.status = 2 THEN '確定'
            WHEN t_slip.status = 3 THEN '削除'
            ELSE ''
        END
    , ''),
    IFNULL(t_slip.supplier_code, ''),
    IFNULL(m_supplier.supplier_name, ''),
    IFNULL(CAST(t_slip.total_qty AS CHAR), ''),
    IFNULL(CAST(t_slip.total_amount AS CHAR), ''),
    IFNULL(DATE_FORMAT(t_slip.fix_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(DATE_FORMAT(t_slip.delete_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(t_slip.memo, ''),
    IFNULL(CAST(t_slip_detail.line_no AS CHAR), ''),
    IFNULL(t_slip_detail.item_code, ''),
    IFNULL(t_slip_detail.jan_code, ''),
    IFNULL(t_slip_detail.item_name, ''),
    IFNULL(CAST(t_slip_detail.qty AS CHAR), ''),
    IFNULL(CAST(t_slip_detail.unit_price AS CHAR), ''),
    IFNULL(CAST(t_slip_detail.amount AS CHAR), ''),
    IFNULL(t_slip_detail.memo, ''),
    IFNULL(DATE_FORMAT(t_slip.create_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(t_slip.create_staff_code, ''),
    IFNULL(t_slip.create_staff_name, ''),
    IFNULL(DATE_FORMAT(t_slip.update_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(t_slip.update_staff_code, ''),
    IFNULL(t_slip.update_staff_name, ''),
    IFNULL(DATE_FORMAT(t_slip_detail.create_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(t_slip_detail.create_staff_code, ''),
    IFNULL(t_slip_detail.create_staff_name, ''),
    IFNULL(DATE_FORMAT(t_slip_detail.update_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(t_slip_detail.update_staff_code, ''),
    IFNULL(t_slip_detail.update_staff_name, '')
FROM
    t_slip
LEFT OUTER JOIN m_supplier
    ON t_slip.supplier_code = m_supplier.supplier_code
LEFT OUTER JOIN t_slip_detail
    ON t_slip.slip_no = t_slip_detail.slip_no
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