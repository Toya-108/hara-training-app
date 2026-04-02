<cfcomponent output="false">

    <cffunction name="getTotalReport" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {
            "status" = 0,
            "message" = "",
            "summary" = {
                "total_slip_count" = 0,
                "total_qty" = 0,
                "total_amount" = 0
            },
            "results" = []
        }>

        <cfset var slipDateFrom = "">
        <cfset var slipDateTo = "">
        <cfset var deliveryDateFrom = "">
        <cfset var deliveryDateTo = "">
        <cfset var supplierCode = "">
        <cfset var itemKeyword = "">
        <cfset var statusValue = "">
        <cfset var reportType = "day">

        <cfset var summarySql = "">
        <cfset var detailSql = "">
        <cfset var qSummary = "">
        <cfset var qReport = "">

        <cftry>
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

            <cfif structKeyExists(form, "report_type") AND len(trim(form.report_type))>
                <cfset reportType = trim(form.report_type)>
            </cfif>

            <!--- 不正値対策 --->
            <cfif NOT listFindNoCase("day,supplier,item,status", reportType)>
                <cfset reportType = "day">
            </cfif>

            <!--- =========================
                  サマリー取得
                 ========================= --->
            <cfquery name="qSummary">
                SELECT
                    COUNT(*) AS total_slip_count,
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
                                OR d.item_name_kana LIKE <cfqueryparam value="%#itemKeyword#%" cfsqltype="cf_sql_varchar">
                            )
                    )
                </cfif>
            </cfquery>

            <cfset result.summary.total_slip_count = qSummary.total_slip_count>
            <cfset result.summary.total_qty = qSummary.total_qty>
            <cfset result.summary.total_amount = qSummary.total_amount>

            <!--- =========================
                  集計結果取得
                 ========================= --->
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

            </cfif>

            <cfloop query="qReport">
                <cfset arrayAppend(result.results, {
                    "group_key" = qReport.group_key,
                    "slip_count" = qReport.slip_count,
                    "total_qty" = qReport.total_qty,
                    "total_amount" = qReport.total_amount
                })>
            </cfloop>

            <cfcatch type="database">
                <cflog
                    file="Hara"
                    type="error"
                    text="レポート集計エラー #cfcatch.message# | Detail: #cfcatch.detail# | SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">

                <cfset result.status = 1>
                <cfset result.message = "レポート集計中にデータベースエラーが発生しました。">
            </cfcatch>

            <cfcatch type="any">
                <cflog
                    file="Hara"
                    type="error"
                    text="レポート集計エラー #cfcatch.message# | Detail: #cfcatch.detail#">

                <cfset result.status = 1>
                <cfset result.message = "レポート集計中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>