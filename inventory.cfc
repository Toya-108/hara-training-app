<cfcomponent output="false">

    <cffunction name="getInventoryList" access="remote" returnformat="json" output="false" httpmethod="POST">
        <cfset var result = { "status" = 0, "message" = "", "results" = {} } />
        <cfset var itemCode = "" />
        <cfset var janCode = "" />
        <cfset var keyword = "" />
        <cfset var itemCategory = "" />
        <cfset var stockStatus = "" />
        <cfset var qtyFrom = "" />
        <cfset var qtyTo = "" />
        <cfset var safetyStockOnly = "0" />
        <cfset var page = 1 />
        <cfset var pageSize = 10 />
        <cfset var offsetValue = 0 />
        <cfset var sortColumn = "item_code" />
        <cfset var sortOrder = "asc" />
        <cfset var validSortColumnList = "item_code,jan_code,item_name,item_category,current_qty,safety_stock_qty,update_datetime" />
        <cfset var qCount = "" />
        <cfset var qList = "" />
        <cfset var totalCount = 0 />
        <cfset var totalPages = 1 />
        <cfset var summaryItemCount = 0 />
        <cfset var summaryTotalQty = 0 />
        <cfset var summaryLowStockCount = 0 />
        <cfset var rowArray = [] />
        <cfset var rowData = {} />
        <cfset var i = 1 />

        <cftry>
            <cfif structKeyExists(form, "item_code")>
                <cfset itemCode = trim(form.item_code) />
            </cfif>
            <cfif structKeyExists(form, "jan_code")>
                <cfset janCode = trim(form.jan_code) />
            </cfif>
            <cfif structKeyExists(form, "keyword")>
                <cfset keyword = trim(form.keyword) />
            </cfif>
            <cfif structKeyExists(form, "item_category")>
                <cfset itemCategory = trim(form.item_category) />
            </cfif>
            <cfif structKeyExists(form, "stock_status")>
                <cfset stockStatus = trim(form.stock_status) />
            </cfif>
            <cfif structKeyExists(form, "qty_from")>
                <cfset qtyFrom = trim(form.qty_from) />
            </cfif>
            <cfif structKeyExists(form, "qty_to")>
                <cfset qtyTo = trim(form.qty_to) />
            </cfif>
            <cfif structKeyExists(form, "safety_stock_only")>
                <cfset safetyStockOnly = trim(form.safety_stock_only) />
            </cfif>
            <cfif structKeyExists(form, "page") AND isNumeric(form.page)>
                <cfset page = val(form.page) />
                <cfif page lte 0>
                    <cfset page = 1 />
                </cfif>
            </cfif>
            <cfif structKeyExists(form, "page_size") AND isNumeric(form.page_size)>
                <cfset pageSize = val(form.page_size) />
                <cfif pageSize lte 0>
                    <cfset pageSize = 10 />
                </cfif>
            </cfif>
            <cfif structKeyExists(form, "sort_column")>
                <cfset sortColumn = trim(form.sort_column) />
            </cfif>
            <cfif structKeyExists(form, "sort_order")>
                <cfset sortOrder = lCase(trim(form.sort_order)) />
            </cfif>

            <cfif NOT listFindNoCase(validSortColumnList, sortColumn)>
                <cfset sortColumn = "item_code" />
            </cfif>

            <cfif sortOrder neq "asc" AND sortOrder neq "desc">
                <cfset sortOrder = "asc" />
            </cfif>

            <cfset offsetValue = (page - 1) * pageSize />

            <cfquery name="qCount">
                SELECT
                    COUNT(*) AS total_count,
                    COALESCE(SUM(inv.current_qty), 0) AS total_qty,
                    COALESCE(SUM(
                        CASE
                            WHEN inv.current_qty <= COALESCE(inv.safety_stock_qty, 0) THEN 1
                            ELSE 0
                        END
                    ), 0) AS low_stock_count
                FROM m_item mi
                LEFT JOIN t_inventory inv
                    ON mi.item_code = inv.item_code
                WHERE 1 = 1
                <cfif itemCode neq "">
                    AND mi.item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif janCode neq "">
                    AND mi.jan_code = <cfqueryparam value="#janCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif keyword neq "">
                    AND (
                        mi.item_name LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                        OR mi.item_name_kana LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif itemCategory neq "" AND isNumeric(itemCategory)>
                    AND mi.item_category = <cfqueryparam value="#val(itemCategory)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif qtyFrom neq "" AND isNumeric(qtyFrom)>
                    AND COALESCE(inv.current_qty, 0) >= <cfqueryparam value="#val(qtyFrom)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif qtyTo neq "" AND isNumeric(qtyTo)>
                    AND COALESCE(inv.current_qty, 0) <= <cfqueryparam value="#val(qtyTo)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif safetyStockOnly eq "1">
                    AND COALESCE(inv.current_qty, 0) <= COALESCE(inv.safety_stock_qty, 0)
                </cfif>
                <cfif stockStatus eq "normal">
                    AND COALESCE(inv.current_qty, 0) > COALESCE(inv.safety_stock_qty, 0)
                <cfelseif stockStatus eq "low">
                    AND COALESCE(inv.current_qty, 0) > 0
                    AND COALESCE(inv.current_qty, 0) <= COALESCE(inv.safety_stock_qty, 0)
                <cfelseif stockStatus eq "zero">
                    AND COALESCE(inv.current_qty, 0) <= 0
                </cfif>
            </cfquery>

            <cfset totalCount = qCount.total_count />
            <cfset summaryItemCount = qCount.total_count />
            <cfset summaryTotalQty = qCount.total_qty />
            <cfset summaryLowStockCount = qCount.low_stock_count />

            <cfif totalCount gt 0>
                <cfset totalPages = ceiling(totalCount / pageSize) />
            </cfif>

            <cfif page gt totalPages>
                <cfset page = totalPages />
                <cfif page lte 0>
                    <cfset page = 1 />
                </cfif>
                <cfset offsetValue = (page - 1) * pageSize />
            </cfif>

            <cfquery name="qList">
                SELECT
                    mi.item_code,
                    mi.jan_code,
                    mi.item_name,
                    mi.item_name_kana,
                    mi.item_category,
                    CASE mi.item_category
                        WHEN 1 THEN '食品'
                        WHEN 2 THEN '雑貨'
                        WHEN 3 THEN '日用品'
                        WHEN 4 THEN '衣料'
                        WHEN 5 THEN '小物'
                        ELSE ''
                    END AS item_category_name,
                    COALESCE(inv.current_qty, 0) AS current_qty,
                    COALESCE(inv.safety_stock_qty, 0) AS safety_stock_qty,
                    DATE_FORMAT(inv.update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime
                FROM m_item mi
                LEFT JOIN t_inventory inv
                    ON mi.item_code = inv.item_code
                WHERE 1 = 1
                <cfif itemCode neq "">
                    AND mi.item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif janCode neq "">
                    AND mi.jan_code = <cfqueryparam value="#janCode#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif keyword neq "">
                    AND (
                        mi.item_name LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                        OR mi.item_name_kana LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                    )
                </cfif>
                <cfif itemCategory neq "" AND isNumeric(itemCategory)>
                    AND mi.item_category = <cfqueryparam value="#val(itemCategory)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif qtyFrom neq "" AND isNumeric(qtyFrom)>
                    AND COALESCE(inv.current_qty, 0) >= <cfqueryparam value="#val(qtyFrom)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif qtyTo neq "" AND isNumeric(qtyTo)>
                    AND COALESCE(inv.current_qty, 0) <= <cfqueryparam value="#val(qtyTo)#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif safetyStockOnly eq "1">
                    AND COALESCE(inv.current_qty, 0) <= COALESCE(inv.safety_stock_qty, 0)
                </cfif>
                <cfif stockStatus eq "normal">
                    AND COALESCE(inv.current_qty, 0) > COALESCE(inv.safety_stock_qty, 0)
                <cfelseif stockStatus eq "low">
                    AND COALESCE(inv.current_qty, 0) > 0
                    AND COALESCE(inv.current_qty, 0) <= COALESCE(inv.safety_stock_qty, 0)
                <cfelseif stockStatus eq "zero">
                    AND COALESCE(inv.current_qty, 0) <= 0
                </cfif>
                ORDER BY
                <cfif sortColumn eq "item_code">
                    mi.item_code
                <cfelseif sortColumn eq "jan_code">
                    mi.jan_code
                <cfelseif sortColumn eq "item_name">
                    mi.item_name
                <cfelseif sortColumn eq "item_category">
                    mi.item_category
                <cfelseif sortColumn eq "current_qty">
                    COALESCE(inv.current_qty, 0)
                <cfelseif sortColumn eq "safety_stock_qty">
                    COALESCE(inv.safety_stock_qty, 0)
                <cfelseif sortColumn eq "update_datetime">
                    inv.update_datetime
                <cfelse>
                    mi.item_code
                </cfif>
                #sortOrder#
                LIMIT <cfqueryparam value="#pageSize#" cfsqltype="cf_sql_integer">
                OFFSET <cfqueryparam value="#offsetValue#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset rowArray = [] />

            <cfloop query="qList">
                <cfset rowData = {} />
                <cfset rowData["item_code"] = qList.item_code />
                <cfset rowData["jan_code"] = qList.jan_code />
                <cfset rowData["item_name"] = qList.item_name />
                <cfset rowData["item_name_kana"] = qList.item_name_kana />
                <cfset rowData["item_category"] = qList.item_category />
                <cfset rowData["item_category_name"] = qList.item_category_name />
                <cfset rowData["current_qty"] = qList.current_qty />
                <cfset rowData["safety_stock_qty"] = qList.safety_stock_qty />
                <cfset rowData["update_datetime"] = qList.update_datetime />
                <cfset arrayAppend(rowArray, rowData) />
            </cfloop>

            <cfset result["results"] = {
                "rows" = rowArray,
                "summary" = {
                    "item_count" = summaryItemCount,
                    "total_qty" = summaryTotalQty,
                    "low_stock_count" = summaryLowStockCount
                },
                "pagination" = {
                    "current_page" = page,
                    "page_size" = pageSize,
                    "total_count" = totalCount,
                    "total_pages" = totalPages
                }
            } />

            <cfcatch type="database">
                <cflog file="Hara" text="inventory getInventoryList DBエラー #cfcatch.message# | SQL: #cfcatch.sql# | Detail: #cfcatch.detail# | QueryError: #cfcatch.QueryError#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "在庫一覧の取得中にデータベースエラーが発生しました。" />
            </cfcatch>
            <cfcatch type="any">
                <cflog file="Hara" text="inventory getInventoryList エラー #cfcatch.message# | Detail: #cfcatch.detail# | Where: #cfcatch.tagContext[1].template#:#cfcatch.tagContext[1].line#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "在庫一覧の取得中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <cffunction name="saveInventoryAdjustment" access="remote" returnformat="json" output="false" httpmethod="POST">
        <cfset var result = { "status" = 0, "message" = "", "results" = {} } />
        <cfset var itemCode = "" />
        <cfset var changeType = 1 />
        <cfset var changeQty = 0 />
        <cfset var safetyStockQty = 0 />
        <cfset var reason = "" />
        <cfset var staffCode = "" />
        <cfset var staffName = "" />
        <cfset var qInventory = "" />
        <cfset var qItem = "" />
        <cfset var beforeQty = 0 />
        <cfset var afterQty = 0 />

        <cftry>
            <cfif structKeyExists(form, "item_code")>
                <cfset itemCode = trim(form.item_code) />
            </cfif>
            <cfif structKeyExists(form, "change_type") AND isNumeric(form.change_type)>
                <cfset changeType = val(form.change_type) />
            </cfif>
            <cfif structKeyExists(form, "change_qty") AND isNumeric(form.change_qty)>
                <cfset changeQty = val(form.change_qty) />
            </cfif>
            <cfif structKeyExists(form, "safety_stock_qty") AND isNumeric(form.safety_stock_qty)>
                <cfset safetyStockQty = val(form.safety_stock_qty) />
            </cfif>
            <cfif structKeyExists(form, "reason")>
                <cfset reason = trim(form.reason) />
            </cfif>

            <cfif structKeyExists(session, "staff_code")>
                <cfset staffCode = session.staff_code />
            </cfif>
            <cfif structKeyExists(session, "staff_name")>
                <cfset staffName = session.staff_name />
            </cfif>

            <cfif itemCode eq "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "商品コードが不正です。" />
                <cfreturn result />
            </cfif>

            <cfif changeType neq 1 AND changeType neq 2 AND changeType neq 3>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "調整方法が不正です。" />
                <cfreturn result />
            </cfif>

            <cfif changeQty lt 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "数量は0以上を入力してください。" />
                <cfreturn result />
            </cfif>

            <cfif safetyStockQty lt 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "安全在庫数は0以上を入力してください。" />
                <cfreturn result />
            </cfif>

            <cfquery name="qItem">
                SELECT
                    item_code
                FROM m_item
                WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif qItem.recordCount eq 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "対象商品が存在しません。" />
                <cfreturn result />
            </cfif>

            <cftransaction>
                <cfquery name="qInventory">
                    SELECT
                        item_code,
                        current_qty,
                        safety_stock_qty
                    FROM t_inventory
                    WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                    FOR UPDATE
                </cfquery>

                <cfif qInventory.recordCount eq 0>
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
                            <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">,
                            0,
                            <cfqueryparam value="#safetyStockQty#" cfsqltype="cf_sql_integer">,
                            NOW(),
                            <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">,
                            NOW(),
                            <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>

                    <cfquery name="qInventory">
                        SELECT
                            item_code,
                            current_qty,
                            safety_stock_qty
                        FROM t_inventory
                        WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                        FOR UPDATE
                    </cfquery>
                </cfif>

                <cfset beforeQty = qInventory.current_qty />

                <cfif changeType eq 1>
                    <cfset afterQty = beforeQty + changeQty />
                <cfelseif changeType eq 2>
                    <cfset afterQty = beforeQty - changeQty />
                <cfelse>
                    <cfset afterQty = changeQty />
                </cfif>

                <cfif afterQty lt 0>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "在庫数がマイナスになるため更新できません。" />
                    <cftransaction action="rollback" />
                    <cfreturn result />
                </cfif>

                <cfquery>
                    UPDATE t_inventory
                    SET
                        current_qty = <cfqueryparam value="#afterQty#" cfsqltype="cf_sql_integer">,
                        safety_stock_qty = <cfqueryparam value="#safetyStockQty#" cfsqltype="cf_sql_integer">,
                        update_datetime = NOW(),
                        update_staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                        update_staff_name = <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                        <cfif changeType eq 1>
                            , last_in_datetime = NOW()
                        <cfelseif changeType eq 2>
                            , last_out_datetime = NOW()
                        </cfif>
                    WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
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
                        <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#changeType#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#beforeQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#changeQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#afterQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#reason#" cfsqltype="cf_sql_varchar">,
                        NOW(),
                        <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cftransaction>

            <cfset result["message"] = "在庫を更新しました。" />
            <cfset result["results"] = {
                "item_code" = itemCode,
                "before_qty" = beforeQty,
                "after_qty" = afterQty
            } />

            <cfcatch type="database">
                <cflog file="Hara" text="inventory saveInventoryAdjustment DBエラー #cfcatch.message# | SQL: #cfcatch.sql# | Detail: #cfcatch.detail# | QueryError: #cfcatch.QueryError#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "在庫更新中にデータベースエラーが発生しました。" />
            </cfcatch>
            <cfcatch type="any">
                <cflog file="Hara" text="inventory saveInventoryAdjustment エラー #cfcatch.message# | Detail: #cfcatch.detail# | Where: #cfcatch.tagContext[1].template#:#cfcatch.tagContext[1].line#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "在庫更新中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

</cfcomponent>