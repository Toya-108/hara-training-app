<cfcomponent displayname="slip_list" output="false">

    <cffunction name="getSlipList" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestData = {} />
        <cfset var requestBody = "" />
        <cfset var page = 1 />
        <cfset var pageSize = 50 />
        <cfset var offsetRow = 0 />
        <cfset var searchSlipNo = "" />
        <cfset var searchOrderDateFrom = "" />
        <cfset var searchOrderDateTo = "" />
        <cfset var searchDeliveryDateFrom = "" />
        <cfset var searchDeliveryDateTo = "" />
        <cfset var searchSupplierCode = "" />
        <cfset var searchSupplierKeyword = "" />
        <cfset var searchItemKeyword = "" />
        <cfset var searchStatus = "" />
        <cfset var sortField = "" />
        <cfset var sortOrder = "" />
        <cfset var orderBy = "t_slip.slip_date, t_slip.slip_no" />
        <cfset var qSlipCount = "" />
        <cfset var qSlipList = "" />
        <cfset var totalCount = 0 />
        <cfset var totalPage = 1 />
        <cfset var results = [] />
        <cfset var row = {} />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["results"] = [] />
        <cfset result["paging"] = {} />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "page")>
                <cfset page = val(requestData.page) />
            </cfif>

            <cfif structKeyExists(requestData, "pageSize")>
                <cfset pageSize = val(requestData.pageSize) />
            </cfif>

            <cfif structKeyExists(requestData, "search_slip_no")>
                <cfset searchSlipNo = trim(requestData.search_slip_no) />
            </cfif>

            <cfif structKeyExists(requestData, "search_order_date_from")>
                <cfset searchOrderDateFrom = trim(requestData.search_order_date_from) />
            <cfelseif structKeyExists(requestData, "search_slip_date_from")>
                <cfset searchOrderDateFrom = trim(requestData.search_slip_date_from) />
            </cfif>

            <cfif structKeyExists(requestData, "search_order_date_to")>
                <cfset searchOrderDateTo = trim(requestData.search_order_date_to) />
            <cfelseif structKeyExists(requestData, "search_slip_date_to")>
                <cfset searchOrderDateTo = trim(requestData.search_slip_date_to) />
            </cfif>

            <cfif structKeyExists(requestData, "search_delivery_date_from")>
                <cfset searchDeliveryDateFrom = trim(requestData.search_delivery_date_from) />
            </cfif>

            <cfif structKeyExists(requestData, "search_delivery_date_to")>
                <cfset searchDeliveryDateTo = trim(requestData.search_delivery_date_to) />
            </cfif>

            <cfif structKeyExists(requestData, "search_supplier_code")>
                <cfset searchSupplierCode = trim(requestData.search_supplier_code) />
            </cfif>

            <cfif structKeyExists(requestData, "search_supplier_keyword")>
                <cfset searchSupplierKeyword = trim(requestData.search_supplier_keyword) />
            </cfif>

            <cfif structKeyExists(requestData, "search_item_keyword")>
                <cfset searchItemKeyword = trim(requestData.search_item_keyword) />
            </cfif>

            <cfif structKeyExists(requestData, "search_status")>
                <cfset searchStatus = trim(requestData.search_status) />
            </cfif>

            <cfif structKeyExists(requestData, "sortField")>
                <cfset sortField = trim(requestData.sortField) />
            </cfif>

            <cfif structKeyExists(requestData, "sortOrder")>
                <cfset sortOrder = lcase(trim(requestData.sortOrder)) />
            </cfif>

            <cfif page LTE 0>
                <cfset page = 1 />
            </cfif>

            <cfif pageSize LTE 0>
                <cfset pageSize = 50 />
            </cfif>

            <cfset offsetRow = (page - 1) * pageSize />

            <cfswitch expression="#sortField#">
                <cfcase value="slip_no">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>

                <cfcase value="slip_date">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.slip_date ASC, t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.slip_date DESC, t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>

                <cfcase value="delivery_date">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.delivery_date ASC, t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.delivery_date DESC, t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>

                <cfcase value="supplier_code">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.supplier_code ASC, t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.supplier_code DESC, t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>

                <cfcase value="total_qty">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.total_qty ASC, t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.total_qty DESC, t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>

                <cfcase value="status">
                    <cfif sortOrder EQ "asc">
                        <cfset orderBy = "t_slip.status ASC, t_slip.slip_no ASC" />
                    <cfelseif sortOrder EQ "desc">
                        <cfset orderBy = "t_slip.status DESC, t_slip.slip_no DESC" />
                    </cfif>
                </cfcase>
            </cfswitch>

            <cfquery name="qSlipCount">
                SELECT COUNT(*) AS total_count
                FROM t_slip t_slip
                LEFT OUTER JOIN m_supplier m_supplier
                    ON t_slip.supplier_code = m_supplier.supplier_code
                WHERE 1 = 1
                <cfif searchSlipNo NEQ "">
                    AND t_slip.slip_no LIKE <cfqueryparam value="%#searchSlipNo#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchOrderDateFrom NEQ "">
                    AND t_slip.slip_date >= <cfqueryparam value="#searchOrderDateFrom#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchOrderDateTo NEQ "">
                    AND t_slip.slip_date <= <cfqueryparam value="#searchOrderDateTo#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchDeliveryDateFrom NEQ "">
                    AND t_slip.delivery_date >= <cfqueryparam value="#searchDeliveryDateFrom#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchDeliveryDateTo NEQ "">
                    AND t_slip.delivery_date <= <cfqueryparam value="#searchDeliveryDateTo#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchSupplierCode NEQ "">
                    AND t_slip.supplier_code = <cfqueryparam value="#searchSupplierCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchSupplierKeyword NEQ "">
                    AND (
                        m_supplier.supplier_name LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                        OR
                        m_supplier.supplier_name_kana LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif searchItemKeyword NEQ "">
                    AND EXISTS (
                        SELECT 1
                        FROM t_slip_detail t_slip_detail
                        LEFT OUTER JOIN m_item m_item
                            ON t_slip_detail.item_code = m_item.item_code
                        WHERE t_slip_detail.slip_no = t_slip.slip_no
                          AND (
                              m_item.item_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                              OR m_item.jan_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                              OR m_item.item_name LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                              OR m_item.item_name_kana LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                          )
                    )
                </cfif>
                <cfif searchStatus NEQ "">
                    AND t_slip.status = <cfqueryparam value="#searchStatus#" cfsqltype="cf_sql_integer">
                </cfif>
            </cfquery>

            <cfset totalCount = val(qSlipCount.total_count) />
            <cfset totalPage = ceiling(totalCount / pageSize) />

            <cfif totalPage LTE 0>
                <cfset totalPage = 1 />
            </cfif>

            <cfif page GT totalPage>
                <cfset page = totalPage />
                <cfset offsetRow = (page - 1) * pageSize />
            </cfif>

            <cfquery name="qSlipList">
                SELECT
                    t_slip.slip_no,
                    t_slip.slip_date,
                    t_slip.delivery_date,
                    t_slip.supplier_code,
                    m_supplier.supplier_name,
                    t_slip.total_qty,
                    t_slip.status
                FROM t_slip t_slip
                LEFT OUTER JOIN m_supplier m_supplier
                    ON t_slip.supplier_code = m_supplier.supplier_code
                WHERE 1 = 1
                <cfif searchSlipNo NEQ "">
                    AND t_slip.slip_no LIKE <cfqueryparam value="%#searchSlipNo#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchOrderDateFrom NEQ "">
                    AND t_slip.slip_date >= <cfqueryparam value="#searchOrderDateFrom#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchOrderDateTo NEQ "">
                    AND t_slip.slip_date <= <cfqueryparam value="#searchOrderDateTo#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchDeliveryDateFrom NEQ "">
                    AND t_slip.delivery_date >= <cfqueryparam value="#searchDeliveryDateFrom#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchDeliveryDateTo NEQ "">
                    AND t_slip.delivery_date <= <cfqueryparam value="#searchDeliveryDateTo#" cfsqltype="cf_sql_date">
                </cfif>
                <cfif searchSupplierCode NEQ "">
                    AND t_slip.supplier_code = <cfqueryparam value="#searchSupplierCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif searchSupplierKeyword NEQ "">
                    AND (
                        m_supplier.supplier_name LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                        OR
                        m_supplier.supplier_name_kana LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif searchItemKeyword NEQ "">
                    AND EXISTS (
                        SELECT 1
                        FROM t_slip_detail t_slip_detail
                        LEFT OUTER JOIN m_item m_item
                            ON t_slip_detail.item_code = m_item.item_code
                        WHERE t_slip_detail.slip_no = t_slip.slip_no
                          AND (
                              m_item.item_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                              OR m_item.jan_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                              OR m_item.item_name LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                              OR m_item.item_name_kana LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                          )
                    )
                </cfif>
                <cfif searchStatus NEQ "">
                    AND t_slip.status = <cfqueryparam value="#searchStatus#" cfsqltype="cf_sql_integer">
                </cfif>
                ORDER BY #preserveSingleQuotes(orderBy)#
                LIMIT <cfqueryparam value="#pageSize#" cfsqltype="cf_sql_integer">
                OFFSET <cfqueryparam value="#offsetRow#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfloop query="qSlipList">
                <cfset row = {} />
                <cfset row["slip_no"] = qSlipList.slip_no />
                <cfset row["slip_date"] = qSlipList.slip_date />
                <cfset row["slip_date_disp"] = "" />
                <cfset row["delivery_date"] = qSlipList.delivery_date />
                <cfset row["delivery_date_disp"] = "" />
                <cfset row["supplier_code"] = qSlipList.supplier_code />
                <cfset row["supplier_name"] = qSlipList.supplier_name />
                <cfset row["supplier_disp"] = qSlipList.supplier_code & "　" & qSlipList.supplier_name />
                <cfset row["total_qty"] = qSlipList.total_qty />
                <cfset row["status"] = qSlipList.status />

                <cfif isDate(qSlipList.slip_date)>
                    <cfset row["slip_date_disp"] = dateFormat(qSlipList.slip_date, "yyyy/mm/dd") />
                </cfif>

                <cfif isDate(qSlipList.delivery_date)>
                    <cfset row["delivery_date_disp"] = dateFormat(qSlipList.delivery_date, "yyyy/mm/dd") />
                </cfif>

                <cfset arrayAppend(results, row) />
            </cfloop>

            <cfset result["results"] = results />
            <cfset result["paging"]["page"] = page />
            <cfset result["paging"]["pageSize"] = pageSize />
            <cfset result["paging"]["totalCount"] = totalCount />
            <cfset result["paging"]["totalPage"] = totalPage />

            <cfcatch type="database">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票一覧取得中にデータベースエラーが発生しました。" />
            </cfcatch>

            <cfcatch type="any">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票一覧取得中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

        <cffunction name="bulkConfirmSlips" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestData = {} />
        <cfset var requestBody = "" />
        <cfset var password = "" />
        <cfset var searchSlipNo = "" />
        <cfset var searchOrderDateFrom = "" />
        <cfset var searchOrderDateTo = "" />
        <cfset var searchDeliveryDateFrom = "" />
        <cfset var searchDeliveryDateTo = "" />
        <cfset var searchSupplierCode = "" />
        <cfset var searchSupplierKeyword = "" />
        <cfset var searchItemKeyword = "" />
        <cfset var searchStatus = "" />
        <cfset var qGetAdmin = "" />
        <cfset var qTargetSlip = "" />
        <cfset var updatedCount = 0 />
        <cfset var staffCode = "SYSTEM" />
        <cfset var staffName = "SYSTEM" />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["updatedCount"] = 0 />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "password")>
                <cfset password = trim(requestData.password) />
            </cfif>

            <cfif password EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "パスワードを入力してください。" />
                <cfreturn result />
            </cfif>

            <cfquery name="qGetAdmin">
                SELECT admin_password
                FROM m_admin
                ORDER BY company_code ASC
                LIMIT 1
            </cfquery>

            <cfif qGetAdmin.recordCount EQ 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "基本設定が登録されていません。" />
                <cfreturn result />
            </cfif>

            <cfif trim(qGetAdmin.admin_password[1]) EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "確定パスワードが設定されていません。" />
                <cfreturn result />
            </cfif>

            <cfif NOT checkAdminPassword(password, qGetAdmin.admin_password[1])>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "パスワードが正しくありません。" />
                <cfreturn result />
            </cfif>

            <cfif structKeyExists(requestData, "search_slip_no")>
                <cfset searchSlipNo = trim(requestData.search_slip_no) />
            </cfif>
            <cfif structKeyExists(requestData, "search_order_date_from")>
                <cfset searchOrderDateFrom = trim(requestData.search_order_date_from) />
            </cfif>
            <cfif structKeyExists(requestData, "search_order_date_to")>
                <cfset searchOrderDateTo = trim(requestData.search_order_date_to) />
            </cfif>
            <cfif structKeyExists(requestData, "search_delivery_date_from")>
                <cfset searchDeliveryDateFrom = trim(requestData.search_delivery_date_from) />
            </cfif>
            <cfif structKeyExists(requestData, "search_delivery_date_to")>
                <cfset searchDeliveryDateTo = trim(requestData.search_delivery_date_to) />
            </cfif>
            <cfif structKeyExists(requestData, "search_supplier_code")>
                <cfset searchSupplierCode = trim(requestData.search_supplier_code) />
            </cfif>
            <cfif structKeyExists(requestData, "search_supplier_keyword")>
                <cfset searchSupplierKeyword = trim(requestData.search_supplier_keyword) />
            </cfif>
            <cfif structKeyExists(requestData, "search_item_keyword")>
                <cfset searchItemKeyword = trim(requestData.search_item_keyword) />
            </cfif>
            <cfif structKeyExists(requestData, "search_status")>
                <cfset searchStatus = trim(requestData.search_status) />
            </cfif>

            <cfif structKeyExists(session, "staffCode") AND trim(session.staffCode) NEQ "">
                <cfset staffCode = session.staffCode />
            </cfif>
            <cfif structKeyExists(session, "staffName") AND trim(session.staffName) NEQ "">
                <cfset staffName = session.staffName />
            </cfif>

            <cftransaction>
                <cfquery name="qTargetSlip">
                    SELECT DISTINCT
                        t_slip.slip_no
                    FROM t_slip t_slip
                    LEFT OUTER JOIN m_supplier m_supplier
                        ON t_slip.supplier_code = m_supplier.supplier_code
                    WHERE 1 = 1
                      AND t_slip.status = 1
                    <cfif searchSlipNo NEQ "">
                        AND t_slip.slip_no LIKE <cfqueryparam value="%#searchSlipNo#%" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif searchOrderDateFrom NEQ "">
                        AND t_slip.slip_date >= <cfqueryparam value="#searchOrderDateFrom#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif searchOrderDateTo NEQ "">
                        AND t_slip.slip_date <= <cfqueryparam value="#searchOrderDateTo#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif searchDeliveryDateFrom NEQ "">
                        AND t_slip.delivery_date >= <cfqueryparam value="#searchDeliveryDateFrom#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif searchDeliveryDateTo NEQ "">
                        AND t_slip.delivery_date <= <cfqueryparam value="#searchDeliveryDateTo#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif searchSupplierCode NEQ "">
                        AND t_slip.supplier_code = <cfqueryparam value="#searchSupplierCode#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif searchSupplierKeyword NEQ "">
                        AND (
                            m_supplier.supplier_name LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                            OR
                            m_supplier.supplier_name_kana LIKE <cfqueryparam value="%#searchSupplierKeyword#%" cfsqltype="cf_sql_varchar">
                        )
                    </cfif>
                    <cfif searchItemKeyword NEQ "">
                        AND EXISTS (
                            SELECT 1
                            FROM t_slip_detail t_slip_detail
                            LEFT OUTER JOIN m_item m_item
                                ON t_slip_detail.item_code = m_item.item_code
                            WHERE t_slip_detail.slip_no = t_slip.slip_no
                              AND (
                                  m_item.item_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                                  OR m_item.jan_code = <cfqueryparam value="#searchItemKeyword#" cfsqltype="cf_sql_varchar">
                                  OR m_item.item_name LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                                  OR m_item.item_name_kana LIKE <cfqueryparam value="%#searchItemKeyword#%" cfsqltype="cf_sql_varchar">
                              )
                        )
                    </cfif>
                    <cfif searchStatus EQ "2" OR searchStatus EQ "3">
                        AND 1 = 0
                    </cfif>
                </cfquery>

                <cfif qTargetSlip.recordCount LTE 0>
                    <cfset result["message"] = "一括確定の対象となる登録伝票がありませんでした。" />
                    <cfset result["updatedCount"] = 0 />
                    <cfreturn result />
                </cfif>

                <cfloop query="qTargetSlip">
                    <cfset reflectSlipToInventory(
                        slipNo = qTargetSlip.slip_no,
                        staffCode = staffCode,
                        staffName = staffName,
                        reasonPrefix = "一括確定"
                    ) />

                    <cfquery>
                        UPDATE t_slip
                        SET
                            status = 2,
                            fix_datetime = NOW(),
                            update_datetime = NOW(),
                            update_staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            update_staff_name = <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                        WHERE slip_no = <cfqueryparam value="#qTargetSlip.slip_no#" cfsqltype="cf_sql_varchar">
                          AND status = 1
                    </cfquery>

                    <cfset updatedCount += 1 />
                </cfloop>
            </cftransaction>

            <cfset result["updatedCount"] = updatedCount />
            <cfset result["message"] = updatedCount & "件を確定しました。" />

            <cfcatch type="database">
                <cflog file="Hara" text="一括確定DBエラー #cfcatch.message# | SQL: #cfcatch.sql# | Detail: #cfcatch.detail# | QueryError: #cfcatch.QueryError#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "一括確定中にデータベースエラーが発生しました。" />
            </cfcatch>
            <cfcatch type="any">
                <cflog file="Hara" text="一括確定エラー #cfcatch.message# | Detail: #cfcatch.detail# | Where: #cfcatch.tagContext[1].template#:#cfcatch.tagContext[1].line#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "一括確定中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>






    <cffunction name="reflectSlipToInventory" access="private" returntype="void" output="false">
        <cfargument name="slipNo" type="string" required="true">
        <cfargument name="staffCode" type="string" required="false" default="SYSTEM">
        <cfargument name="staffName" type="string" required="false" default="SYSTEM">
        <cfargument name="reasonPrefix" type="string" required="false" default="伝票確定">

        <cfset var qDetail = "" />
        <cfset var qInventory = "" />
        <cfset var beforeQty = 0 />
        <cfset var afterQty = 0 />
        <cfset var changeQty = 0 />

        <cfquery name="qDetail">
            SELECT
                item_code,
                SUM(qty) AS total_qty
            FROM t_slip_detail
            WHERE slip_no = <cfqueryparam value="#arguments.slipNo#" cfsqltype="cf_sql_varchar">
              AND item_code IS NOT NULL
              AND item_code <> ''
            GROUP BY item_code
        </cfquery>

        <cfloop query="qDetail">
            <cfset changeQty = val(qDetail.total_qty) />

            <cfif changeQty GT 0>
                <cfquery name="qInventory">
                    SELECT
                        item_code,
                        current_qty
                    FROM t_inventory
                    WHERE item_code = <cfqueryparam value="#qDetail.item_code#" cfsqltype="cf_sql_varchar">
                    FOR UPDATE
                </cfquery>

                <cfif qInventory.recordCount EQ 0>
                    <cfquery>
                        INSERT INTO t_inventory (
                            item_code,
                            current_qty,
                            safety_stock_qty,
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#qDetail.item_code#" cfsqltype="cf_sql_varchar">,
                            0,
                            0,
                            NOW(),
                            <cfqueryparam value="#arguments.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#arguments.staffName#" cfsqltype="cf_sql_varchar">,
                            NOW(),
                            <cfqueryparam value="#arguments.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#arguments.staffName#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>

                    <cfquery name="qInventory">
                        SELECT
                            item_code,
                            current_qty
                        FROM t_inventory
                        WHERE item_code = <cfqueryparam value="#qDetail.item_code#" cfsqltype="cf_sql_varchar">
                        FOR UPDATE
                    </cfquery>
                </cfif>

                <cfset beforeQty = val(qInventory.current_qty) />
                <cfset afterQty = beforeQty + changeQty />

                <cfquery>
                    UPDATE t_inventory
                    SET
                        current_qty = <cfqueryparam value="#afterQty#" cfsqltype="cf_sql_integer">,
                        last_in_datetime = NOW(),
                        update_datetime = NOW(),
                        update_staff_code = <cfqueryparam value="#arguments.staffCode#" cfsqltype="cf_sql_varchar">,
                        update_staff_name = <cfqueryparam value="#arguments.staffName#" cfsqltype="cf_sql_varchar">
                    WHERE item_code = <cfqueryparam value="#qDetail.item_code#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfquery>
                    INSERT INTO t_inventory_history (
                        item_code,
                        change_type,
                        before_qty,
                        change_qty,
                        after_qty,
                        reason,
                        create_datetime,
                        create_staff_code,
                        create_staff_name
                    ) VALUES (
                        <cfqueryparam value="#qDetail.item_code#" cfsqltype="cf_sql_varchar">,
                        1,
                        <cfqueryparam value="#beforeQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#changeQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#afterQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.reasonPrefix#（伝票番号:#arguments.slipNo#）" cfsqltype="cf_sql_varchar">,
                        NOW(),
                        <cfqueryparam value="#arguments.staffCode#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.staffName#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cfif>
        </cfloop>
    </cffunction>



    

    <cffunction name="checkAdminPassword" access="private" returntype="boolean" output="false">
        <cfargument name="plainPassword" type="string" required="true">
        <cfargument name="hashedPassword" type="string" required="true">

        <cfif trim(arguments.plainPassword) EQ "" OR trim(arguments.hashedPassword) EQ "">
            <cfreturn false>
        </cfif>

        <!--- ★ここが修正ポイント --->
        <cfreturn verifyBCryptHash(arguments.plainPassword, arguments.hashedPassword)>
    </cffunction>

</cfcomponent>