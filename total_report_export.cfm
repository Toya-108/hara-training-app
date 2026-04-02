<cfinclude template="init.cfm">

<cfsetting showdebugoutput="false">

<cfset reportType = "day">
<cfset slipDateFrom = "">
<cfset slipDateTo = "">
<cfset deliveryDateFrom = "">
<cfset deliveryDateTo = "">
<cfset supplierCode = "">
<cfset itemKeyword = "">
<cfset statusValue = "">

<cfset reportName = "日別集計">
<cfset fileName = "">
<cfset csvHeader = "">
<cfset csvBody = "">
<cfset csvContent = "">
<cfset newLine = chr(13) & chr(10)>
<cfset timeStamp = dateFormat(now(), "yyyymmdd") & timeFormat(now(), "HHnnss")>

<cftry>
    <!--- ===== フォーム値取得 ===== --->
    <cfif structKeyExists(form, "report_type") AND len(trim(form.report_type))>
        <cfset reportType = trim(form.report_type)>
    </cfif>

    <cfif structKeyExists(form, "slip_date_from")>
        <cfset slipDateFrom = trim(form.slip_date_from)>
    </cfif>

    <cfif structKeyExists(form, "slip_date_to")>
        <cfset slipDateTo = trim(form.slip_date_to)>
    </cfif>

    <cfif structKeyExists(form, "delivery_date_from")>
        <cfset deliveryDateFrom = trim(form.delivery_date_from)>
    </cfif>

    <cfif structKeyExists(form, "delivery_date_to")>
        <cfset deliveryDateTo = trim(form.delivery_date_to)>
    </cfif>

    <cfif structKeyExists(form, "supplier_code")>
        <cfset supplierCode = trim(form.supplier_code)>
    </cfif>

    <cfif structKeyExists(form, "item_keyword")>
        <cfset itemKeyword = trim(form.item_keyword)>
    </cfif>

    <cfif structKeyExists(form, "status")>
        <cfset statusValue = trim(form.status)>
    </cfif>

    <!--- ===== 不正値対策 ===== --->
    <cfif NOT listFindNoCase("day,supplier,item,status", reportType)>
        <cfset reportType = "day">
    </cfif>

    <!--- ===== 集計区分名とファイル名 ===== --->
    <cfif reportType EQ "day">
        <cfset reportName = "日別集計">
    <cfelseif reportType EQ "supplier">
        <cfset reportName = "取引先別集計">
    <cfelseif reportType EQ "item">
        <cfset reportName = "商品別集計">
    <cfelseif reportType EQ "status">
        <cfset reportName = "状態別集計">
    </cfif>

    <cfset fileName = reportName & "_" & timeStamp & ".csv">

    <!--- ===== 集計結果取得 ===== --->
    <cfif reportType EQ "day">

        <cfquery name="qReport">
            SELECT
                DATE_FORMAT(s.slip_date, '%Y/%m/%d') AS group_key,
                COUNT(*) AS slip_count,
                COALESCE(SUM(s.total_qty), 0) AS total_qty,
                COALESCE(SUM(s.total_amount), 0) AS total_amount
            FROM
                t_slip s
            WHERE
                1 = 1

            <cfif len(slipDateFrom)>
                AND s.slip_date >= <cfqueryparam value="#replace(slipDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(slipDateTo)>
                AND s.slip_date <= <cfqueryparam value="#replace(slipDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateFrom)>
                AND s.delivery_date >= <cfqueryparam value="#replace(deliveryDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateTo)>
                AND s.delivery_date <= <cfqueryparam value="#replace(deliveryDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(supplierCode)>
                AND s.supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
            </cfif>

            <cfif len(statusValue)>
                AND s.status = <cfqueryparam value="#statusValue#" cfsqltype="cf_sql_integer">
            </cfif>

            <cfif len(itemKeyword)>
                AND EXISTS (
                    SELECT
                        1
                    FROM
                        t_slip_detail d
                    WHERE
                        d.slip_no = s.slip_no
                        AND (
                            d.item_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.jan_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.item_name LIKE <cfqueryparam value="%#itemKeyword#%" cfsqltype="cf_sql_varchar">
                        )
                )
            </cfif>

            GROUP BY
                s.slip_date
            ORDER BY
                s.slip_date DESC
        </cfquery>

        <cfset csvHeader = '"日付","伝票数","合計数量","合計金額"'>

    <cfelseif reportType EQ "supplier">

        <cfquery name="qReport">
            SELECT
                CONCAT(s.supplier_code, ' : ', s.supplier_name) AS group_key,
                COUNT(*) AS slip_count,
                COALESCE(SUM(s.total_qty), 0) AS total_qty,
                COALESCE(SUM(s.total_amount), 0) AS total_amount
            FROM
                t_slip s
            WHERE
                1 = 1

            <cfif len(slipDateFrom)>
                AND s.slip_date >= <cfqueryparam value="#replace(slipDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(slipDateTo)>
                AND s.slip_date <= <cfqueryparam value="#replace(slipDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateFrom)>
                AND s.delivery_date >= <cfqueryparam value="#replace(deliveryDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateTo)>
                AND s.delivery_date <= <cfqueryparam value="#replace(deliveryDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(supplierCode)>
                AND s.supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
            </cfif>

            <cfif len(statusValue)>
                AND s.status = <cfqueryparam value="#statusValue#" cfsqltype="cf_sql_integer">
            </cfif>

            <cfif len(itemKeyword)>
                AND EXISTS (
                    SELECT
                        1
                    FROM
                        t_slip_detail d
                    WHERE
                        d.slip_no = s.slip_no
                        AND (
                            d.item_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.jan_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.item_name LIKE <cfqueryparam value="%#itemKeyword#%" cfsqltype="cf_sql_varchar">
                        )
                )
            </cfif>

            GROUP BY
                s.supplier_code,
                s.supplier_name
            ORDER BY
                total_amount DESC,
                s.supplier_code ASC
        </cfquery>

        <cfset csvHeader = '"取引先","伝票数","合計数量","合計金額"'>

    <cfelseif reportType EQ "item">

        <cfquery name="qReport">
            SELECT
                CONCAT(d.item_code, ' : ', d.item_name) AS group_key,
                COUNT(DISTINCT s.slip_no) AS slip_count,
                COALESCE(SUM(d.qty), 0) AS total_qty,
                COALESCE(SUM(d.amount), 0) AS total_amount
            FROM
                t_slip s
                INNER JOIN t_slip_detail d
                    ON s.slip_no = d.slip_no
            WHERE
                1 = 1

            <cfif len(slipDateFrom)>
                AND s.slip_date >= <cfqueryparam value="#replace(slipDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(slipDateTo)>
                AND s.slip_date <= <cfqueryparam value="#replace(slipDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateFrom)>
                AND s.delivery_date >= <cfqueryparam value="#replace(deliveryDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateTo)>
                AND s.delivery_date <= <cfqueryparam value="#replace(deliveryDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(supplierCode)>
                AND s.supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
            </cfif>

            <cfif len(statusValue)>
                AND s.status = <cfqueryparam value="#statusValue#" cfsqltype="cf_sql_integer">
            </cfif>

            <cfif len(itemKeyword)>
                AND (
                    d.item_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                    OR d.jan_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                    OR d.item_name LIKE <cfqueryparam value="%#itemKeyword#%" cfsqltype="cf_sql_varchar">
                )
            </cfif>

            GROUP BY
                d.item_code,
                d.item_name
            ORDER BY
                total_amount DESC,
                d.item_code ASC
        </cfquery>

        <cfset csvHeader = '"商品","伝票数","合計数量","合計金額"'>

    <cfelseif reportType EQ "status">

        <cfquery name="qReport">
            SELECT
                CASE
                    WHEN s.status = 1 THEN '登録'
                    WHEN s.status = 2 THEN '確定'
                    WHEN s.status = 3 THEN '削除'
                    ELSE 'その他'
                END AS group_key,
                COUNT(*) AS slip_count,
                COALESCE(SUM(s.total_qty), 0) AS total_qty,
                COALESCE(SUM(s.total_amount), 0) AS total_amount
            FROM
                t_slip s
            WHERE
                1 = 1

            <cfif len(slipDateFrom)>
                AND s.slip_date >= <cfqueryparam value="#replace(slipDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(slipDateTo)>
                AND s.slip_date <= <cfqueryparam value="#replace(slipDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateFrom)>
                AND s.delivery_date >= <cfqueryparam value="#replace(deliveryDateFrom, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(deliveryDateTo)>
                AND s.delivery_date <= <cfqueryparam value="#replace(deliveryDateTo, '/', '-', 'all')#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(supplierCode)>
                AND s.supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
            </cfif>

            <cfif len(statusValue)>
                AND s.status = <cfqueryparam value="#statusValue#" cfsqltype="cf_sql_integer">
            </cfif>

            <cfif len(itemKeyword)>
                AND EXISTS (
                    SELECT
                        1
                    FROM
                        t_slip_detail d
                    WHERE
                        d.slip_no = s.slip_no
                        AND (
                            d.item_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.jan_code = <cfqueryparam value="#itemKeyword#" cfsqltype="cf_sql_varchar">
                            OR d.item_name LIKE <cfqueryparam value="%#itemKeyword#%" cfsqltype="cf_sql_varchar">
                        )
                )
            </cfif>

            GROUP BY
                s.status
            ORDER BY
                s.status ASC
        </cfquery>

        <cfset csvHeader = '"状態","伝票数","合計数量","合計金額"'>

    </cfif>

    <!--- ===== CSV本文作成 ===== --->
    <cfset csvBody = csvHeader & newLine>

    <cfloop query="qReport">
        <cfset csvBody &= '"' & replace(qReport.group_key, '"', '""', 'all') & '",' >
        <cfset csvBody &= '"' & qReport.slip_count & '",' >
        <cfset csvBody &= '"' & qReport.total_qty & '",' >
        <cfset csvBody &= '"' & qReport.total_amount & '"' & newLine >
    </cfloop>

    <!--- UTF-8 BOM付き --->
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
            text="レポートCSV出力エラー #cfcatch.message# | Detail: #cfcatch.detail# | SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">

        <cfheader
			name="Content-Disposition"
			value='attachment; filename="#fileName#"'
		>
		<cfcontent
			type="text/csv; charset=UTF-8"
			reset="true">
		<cfoutput>#csvBody#</cfoutput>
        <cfoutput>CSV出力中にデータベースエラーが発生しました。</cfoutput>
    </cfcatch>

    <cfcatch type="any">
        <cflog
            file="Hara"
            type="error"
            text="レポートCSV出力エラー #cfcatch.message# | Detail: #cfcatch.detail#">

        <cfheader
			name="Content-Disposition"
			value='attachment; filename="#fileName#"'
		>
		<cfcontent
			type="text/csv; charset=UTF-8"
			reset="true">
		<cfoutput>#csvBody#</cfoutput>
        <cfoutput>CSV出力中にエラーが発生しました。</cfoutput>
    </cfcatch>
</cftry>