<cfcomponent output="false">

    <cffunction name="getDashboardData" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {
            "status" = 0,
            "message" = "",
            "results" = {}
        }>

        <cfset var qTodaySlipCount = "">
        <cfset var qUnfixedSlipCount = "">
        <cfset var qTodayTotal = "">
        <cfset var qTodayDeliveryCount = "">
        <cfset var qDeletedSlipCount = "">
        <cfset var qRecentSlips = "">
        <cfset var recentSlips = []>
        <cfset var work = {}>

        <cftry>
            <!--- 今日の伝票数 --->
            <cfquery name="qTodaySlipCount">
                SELECT COUNT(*) AS today_slip_count
                FROM t_slip
                WHERE slip_date = CURDATE()
                  AND status <> 3
            </cfquery>

            <!--- 未確定伝票数（登録=1） --->
            <cfquery name="qUnfixedSlipCount">
                SELECT COUNT(*) AS unfixed_slip_count
                FROM t_slip
                WHERE status = 1
            </cfquery>

            <!--- 今日の合計数量・合計金額 --->
            <cfquery name="qTodayTotal">
                SELECT
                    COALESCE(SUM(total_qty), 0) AS today_total_qty,
                    COALESCE(SUM(total_amount), 0) AS today_total_amount
                FROM t_slip
                WHERE slip_date = CURDATE()
                  AND status <> 3
            </cfquery>

            <!--- 本日納品予定件数 --->
            <cfquery name="qTodayDeliveryCount">
                SELECT COUNT(*) AS today_delivery_count
                FROM t_slip
                WHERE delivery_date = CURDATE()
                  AND status <> 3
            </cfquery>

            <!--- 削除伝票数 --->
            <cfquery name="qDeletedSlipCount">
                SELECT COUNT(*) AS deleted_slip_count
                FROM t_slip
                WHERE status = 3
            </cfquery>

            <!--- 最近の伝票5件 --->
            <cfquery name="qRecentSlips">
                SELECT
                    slip_no,
                    slip_date,
                    delivery_date,
                    supplier_name,
                    status
                FROM t_slip
                ORDER BY create_datetime DESC, slip_no DESC
                LIMIT 5
            </cfquery>

            <cfloop query="qRecentSlips">
                <cfset work = {
                    "slip_no" = qRecentSlips.slip_no,
                    "slip_date" = dateFormat(qRecentSlips.slip_date, "yyyy/mm/dd"),
                    "delivery_date" = dateFormat(qRecentSlips.delivery_date, "yyyy/mm/dd"),
                    "supplier_name" = qRecentSlips.supplier_name,
                    "status" = qRecentSlips.status,
                    "status_name" = ""
                }>

                <cfswitch expression="#qRecentSlips.status#">
                    <cfcase value="1">
                        <cfset work.status_name = "登録">
                    </cfcase>
                    <cfcase value="2">
                        <cfset work.status_name = "確定">
                    </cfcase>
                    <cfcase value="3">
                        <cfset work.status_name = "削除">
                    </cfcase>
                    <cfdefaultcase>
                        <cfset work.status_name = "不明">
                    </cfdefaultcase>
                </cfswitch>

                <cfset arrayAppend(recentSlips, work)>
            </cfloop>

            <cfset result["results"] = {
                "today_slip_count" = qTodaySlipCount.today_slip_count,
                "unfixed_slip_count" = qUnfixedSlipCount.unfixed_slip_count,
                "today_total_qty" = qTodayTotal.today_total_qty,
                "today_total_amount" = qTodayTotal.today_total_amount,
                "today_delivery_count" = qTodayDeliveryCount.today_delivery_count,
                "deleted_slip_count" = qDeletedSlipCount.deleted_slip_count,
                "recent_slips" = recentSlips
            }>

            <cfcatch type="database">
                <cflog
                    file="Hara"
                    type="error"
                    text="メニューダッシュボード取得エラー #cfcatch.message# | Detail: #cfcatch.detail# | SQL: #cfcatch.SQL# | QueryError: #cfcatch.QueryError#">

                <cfset result["status"] = 1>
                <cfset result["message"] = "ダッシュボードの取得中にエラーが発生しました。">
                <cfset result["results"] = {}>
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>