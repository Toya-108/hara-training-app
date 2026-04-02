<cfcomponent displayname="slip_list_dt" output="false">

    <cffunction name="getSlipDetail" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestBody = "" />
        <cfset var requestData = {} />
        <cfset var slipNo = "" />
        <cfset var qHeader = "" />
        <cfset var qDetail = "" />
        <cfset var header = {} />
        <cfset var details = [] />
        <cfset var row = {} />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["header"] = {} />
        <cfset result["details"] = [] />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "slip_no")>
                <cfset slipNo = trim(requestData.slip_no) />
            </cfif>

            <cfif slipNo EQ "">
                <cfset result["header"] = {} />
                <cfset result["details"] = [] />
                <cfreturn result />
            </cfif>

            <cfquery name="qHeader">
                SELECT
                    t.slip_no,
                    t.slip_date,
                    t.supplier_code,
                    s.supplier_name,
                    t.delivery_date,
                    t.status,
                    t.total_qty,
                    t.total_amount,
                    t.memo,
                    t.create_datetime,
                    t.update_datetime
                FROM t_slip t
                LEFT JOIN m_supplier s
                    ON t.supplier_code = s.supplier_code
                WHERE t.slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfquery name="qDetail">
                SELECT
                    d.slip_no,
                    d.line_no,
                    d.item_code,
                    i.jan_code,
                    i.item_name,
                    d.qty,
                    d.unit_price,
                    d.amount
                FROM t_slip_detail d
                LEFT JOIN m_item i
                    ON d.item_code = i.item_code
                WHERE d.slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
                ORDER BY d.line_no ASC
            </cfquery>

            <cfif qHeader.recordCount GT 0>
                <cfset header["slip_no"] = qHeader.slip_no />
                <cfset header["slip_date"] = "" />
                <cfset header["supplier_code"] = qHeader.supplier_code />
                <cfset header["supplier_name"] = qHeader.supplier_name />
                <cfset header["delivery_date"] = "" />
                <cfset header["status"] = qHeader.status />
                <cfset header["total_qty"] = qHeader.total_qty />
                <cfset header["total_amount"] = qHeader.total_amount />
                <cfset header["memo"] = qHeader.memo />
                <cfset header["create_datetime_disp"] = "" />
                <cfset header["update_datetime_disp"] = "" />

                <cfif isDate(qHeader.slip_date)>
                    <cfset header["slip_date"] = dateFormat(qHeader.slip_date, "yyyy-mm-dd") />
                </cfif>

                <cfif isDate(qHeader.delivery_date)>
                    <cfset header["delivery_date"] = dateFormat(qHeader.delivery_date, "yyyy-mm-dd") />
                </cfif>

                <cfif isDate(qHeader.create_datetime)>
                    <cfset header["create_datetime_disp"] = dateFormat(qHeader.create_datetime, "yyyy/mm/dd") & " " & timeFormat(qHeader.create_datetime, "HH:mm:ss") />
                </cfif>

                <cfif isDate(qHeader.update_datetime)>
                    <cfset header["update_datetime_disp"] = dateFormat(qHeader.update_datetime, "yyyy/mm/dd") & " " & timeFormat(qHeader.update_datetime, "HH:mm:ss") />
                </cfif>
            </cfif>

            <cfloop query="qDetail">
                <cfset row = {} />
                <cfset row["line_no"] = qDetail.line_no />
                <cfset row["item_code"] = qDetail.item_code />
                <cfset row["jan_code"] = qDetail.jan_code />
                <cfset row["item_name"] = qDetail.item_name />
                <cfset row["qty"] = qDetail.qty />
                <cfset row["unit_price"] = qDetail.unit_price />
                <cfset row["amount"] = qDetail.amount />
                <cfset arrayAppend(details, row) />
            </cfloop>

            <cfset result["header"] = header />
            <cfset result["details"] = details />

            <cfcatch type="database">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票詳細取得中にデータベースエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>


        <cffunction name="saveSlipDetail" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestBody = "" />
        <cfset var requestData = {} />
        <cfset var slipNo = "" />
        <cfset var displayMode = "" />
        <cfset var status = 1 />
        <cfset var slipDate = "" />
        <cfset var deliveryDate = "" />
        <cfset var supplierCode = "" />
        <cfset var memo = "" />
        <cfset var details = [] />
        <cfset var nowDt = now() />
        <cfset var qSupplier = "" />
        <cfset var qItem = "" />
        <cfset var qCurrentSlip = "" />
        <cfset var supplierName = "" />
        <cfset var totalQty = 0 />
        <cfset var totalAmount = 0 />
        <cfset var i = 0 />
        <cfset var detailRow = {} />
        <cfset var newSlipNo = "" />
        <cfset var qMax = "" />
        <cfset var itemCode = "" />
        <cfset var itemName = "" />
        <cfset var itemJanCode = "" />
        <cfset var qtyValue = 0 />
        <cfset var unitPriceValue = 0 />
        <cfset var currentStatus = 0 />
        <cfset var staffCode = "SYSTEM" />
        <cfset var staffName = "SYSTEM" />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["results"] = {} />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "slip_no")>
                <cfset slipNo = trim(requestData.slip_no) />
            </cfif>

            <cfif structKeyExists(requestData, "display_mode")>
                <cfset displayMode = trim(requestData.display_mode) />
            </cfif>

            <cfif structKeyExists(requestData, "status")>
                <cfset status = val(requestData.status) />
            </cfif>

            <cfif status NEQ 1 AND status NEQ 2>
                <cfset status = 1 />
            </cfif>

            <cfif structKeyExists(requestData, "slip_date")>
                <cfset slipDate = trim(requestData.slip_date) />
            </cfif>

            <cfif structKeyExists(requestData, "delivery_date")>
                <cfset deliveryDate = trim(requestData.delivery_date) />
            </cfif>

            <cfif structKeyExists(requestData, "supplier_code")>
                <cfset supplierCode = trim(requestData.supplier_code) />
            </cfif>

            <cfif structKeyExists(requestData, "memo")>
                <cfset memo = trim(requestData.memo) />
            </cfif>

            <cfif structKeyExists(requestData, "details") AND isArray(requestData.details)>
                <cfset details = requestData.details />
            <cfelse>
                <cfset details = [] />
            </cfif>

            <cfif structKeyExists(session, "staffCode") AND trim(session.staffCode) NEQ "">
                <cfset staffCode = session.staffCode />
            </cfif>
            <cfif structKeyExists(session, "staffName") AND trim(session.staffName) NEQ "">
                <cfset staffName = session.staffName />
            </cfif>

            <cfif slipDate EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "発注日を入力してください。" />
                <cfreturn result />
            </cfif>

            <cfif deliveryDate EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "納品日を入力してください。" />
                <cfreturn result />
            </cfif>

            <cfif supplierCode EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "取引先コードを選択してください。" />
                <cfreturn result />
            </cfif>

            <cfif arrayLen(details) EQ 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "明細を1行以上入力してください。" />
                <cfreturn result />
            </cfif>

            <cfquery name="qSupplier">
                SELECT supplier_name
                FROM m_supplier
                WHERE supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif qSupplier.recordCount EQ 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "取引先が存在しません。" />
                <cfreturn result />
            </cfif>

            <cfset supplierName = qSupplier.supplier_name />

            <cfloop from="1" to="#arrayLen(details)#" index="i">
                <cfset detailRow = details[i] />

                <cfif structKeyExists(detailRow, "item_code")>
                    <cfset itemCode = trim(detailRow.item_code) />
                <cfelse>
                    <cfset itemCode = "" />
                </cfif>

                <cfif structKeyExists(detailRow, "qty")>
                    <cfset qtyValue = val(replace(trim(detailRow.qty), ",", "", "all")) />
                <cfelse>
                    <cfset qtyValue = 0 />
                </cfif>

                <cfif structKeyExists(detailRow, "unit_price")>
                    <cfset unitPriceValue = val(replace(trim(detailRow.unit_price), ",", "", "all")) />
                <cfelse>
                    <cfset unitPriceValue = 0 />
                </cfif>

                <cfif itemCode NEQ "">
                    <cfset totalQty += qtyValue />
                    <cfset totalAmount += (qtyValue * unitPriceValue) />
                </cfif>
            </cfloop>

            <cftransaction>
                <cfif slipNo NEQ "">
                    <cfquery name="qCurrentSlip">
                        SELECT status
                        FROM t_slip
                        WHERE slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
                        FOR UPDATE
                    </cfquery>

                    <cfif qCurrentSlip.recordCount EQ 0>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "対象伝票が存在しません。" />
                        <cftransaction action="rollback" />
                        <cfreturn result />
                    </cfif>

                    <cfset currentStatus = val(qCurrentSlip.status) />

                    <cfif currentStatus EQ 2>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "確定済み伝票は修正できません。" />
                        <cftransaction action="rollback" />
                        <cfreturn result />
                    </cfif>

                    <cfif currentStatus EQ 3>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "削除済み伝票は修正できません。" />
                        <cftransaction action="rollback" />
                        <cfreturn result />
                    </cfif>
                </cfif>

                <cfif slipNo EQ "">
                    <cfquery name="qMax">
                        SELECT IFNULL(MAX(CAST(SUBSTRING(slip_no, 2) AS UNSIGNED)), 0) AS max_no
                        FROM t_slip
                    </cfquery>

                    <cfset newSlipNo = "S" & right("0000000" & (val(qMax.max_no) + 1), 7) />
                    <cfset slipNo = newSlipNo />

                    <cfquery>
                        INSERT INTO t_slip (
                            slip_no,
                            slip_date,
                            supplier_code,
                            supplier_name,
                            delivery_date,
                            status,
                            total_qty,
                            total_amount,
                            fix_datetime,
                            memo,
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#slipDate#" cfsqltype="cf_sql_date">,
                            <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#supplierName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#deliveryDate#" cfsqltype="cf_sql_date">,
                            <cfqueryparam value="#status#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#totalQty#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#totalAmount#" cfsqltype="cf_sql_decimal" scale="2">,
                            <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp" null="#status NEQ 2#">,
                            <cfqueryparam value="#memo#" cfsqltype="cf_sql_varchar" null="#NOT len(memo)#">,
                            <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>
                <cfelse>
                    <cfquery>
                        UPDATE t_slip
                        SET
                            slip_date = <cfqueryparam value="#slipDate#" cfsqltype="cf_sql_date">,
                            supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">,
                            supplier_name = <cfqueryparam value="#supplierName#" cfsqltype="cf_sql_varchar">,
                            delivery_date = <cfqueryparam value="#deliveryDate#" cfsqltype="cf_sql_date">,
                            status = <cfqueryparam value="#status#" cfsqltype="cf_sql_integer">,
                            total_qty = <cfqueryparam value="#totalQty#" cfsqltype="cf_sql_integer">,
                            total_amount = <cfqueryparam value="#totalAmount#" cfsqltype="cf_sql_decimal" scale="2">,
                            fix_datetime = <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp" null="#status NEQ 2#">,
                            memo = <cfqueryparam value="#memo#" cfsqltype="cf_sql_varchar" null="#NOT len(memo)#">,
                            update_datetime = <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                            update_staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                            update_staff_name = <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                        WHERE slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
                    </cfquery>

                    <cfquery>
                        DELETE FROM t_slip_detail
                        WHERE slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                </cfif>

                <cfloop from="1" to="#arrayLen(details)#" index="i">
                    <cfset detailRow = details[i] />

                    <cfif structKeyExists(detailRow, "item_code")>
                        <cfset itemCode = trim(detailRow.item_code) />
                    <cfelse>
                        <cfset itemCode = "" />
                    </cfif>

                    <cfif structKeyExists(detailRow, "item_name")>
                        <cfset itemName = trim(detailRow.item_name) />
                    <cfelse>
                        <cfset itemName = "" />
                    </cfif>

                    <cfif structKeyExists(detailRow, "qty")>
                        <cfset qtyValue = val(replace(trim(detailRow.qty), ",", "", "all")) />
                    <cfelse>
                        <cfset qtyValue = 0 />
                    </cfif>

                    <cfif structKeyExists(detailRow, "unit_price")>
                        <cfset unitPriceValue = val(replace(trim(detailRow.unit_price), ",", "", "all")) />
                    <cfelse>
                        <cfset unitPriceValue = 0 />
                    </cfif>

                    <cfset itemJanCode = "" />

                    <cfif itemCode NEQ "">
                        <cfquery name="qItem">
                            SELECT jan_code, item_name
                            FROM m_item
                            WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                        </cfquery>

                        <cfif qItem.recordCount GT 0>
                            <cfset itemJanCode = qItem.jan_code />
                            <cfif itemName EQ "">
                                <cfset itemName = qItem.item_name />
                            </cfif>
                        </cfif>

                        <cfquery>
                            INSERT INTO t_slip_detail (
                                slip_no,
                                line_no,
                                item_code,
                                jan_code,
                                item_name,
                                qty,
                                unit_price,
                                create_datetime,
                                create_staff_code,
                                create_staff_name,
                                update_datetime,
                                update_staff_code,
                                update_staff_name
                            ) VALUES (
                                <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#i#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#itemJanCode#" cfsqltype="cf_sql_varchar" null="#NOT len(itemJanCode)#">,
                                <cfqueryparam value="#itemName#" cfsqltype="cf_sql_varchar" null="#NOT len(itemName)#">,
                                <cfqueryparam value="#qtyValue#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#unitPriceValue#" cfsqltype="cf_sql_decimal" scale="2">,
                                <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                                <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                                <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#staffName#" cfsqltype="cf_sql_varchar">
                            )
                        </cfquery>
                    </cfif>
                </cfloop>

                <cfif status EQ 2>
                    <cfset reflectSlipToInventory(
                        slipNo = slipNo,
                        staffCode = staffCode,
                        staffName = staffName,
                        reasonPrefix = "伝票確定"
                    ) />
                </cfif>
            </cftransaction>

            <cfif status EQ 2>
                <cfset result["message"] = "保存して確定しました。" />
            <cfelse>
                <cfset result["message"] = "保存しました。" />
            </cfif>

            <cfset result["results"]["slip_no"] = slipNo />

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Information" text="伝票詳細 保存エラー #cfcatch.sql# #cfcatch.queryError#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票保存中にデータベースエラーが発生しました。" />
            </cfcatch>
            <cfcatch type="any">
                <cflog file="HARA_TRAINING_APP" type="Information" text="伝票詳細 保存エラー #cfcatch.message# #cfcatch.detail#" />
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票保存中にエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>


        <cffunction name="deleteSlipDetail" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestBody = "" />
        <cfset var requestData = {} />
        <cfset var slipNo = "" />
        <cfset var nowDt = now() />
        <cfset var qSlip = "" />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "slip_no")>
                <cfset slipNo = trim(requestData.slip_no) />
            </cfif>

            <cfif slipNo EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票番号が不正です。" />
                <cfreturn result />
            </cfif>

            <cfquery name="qSlip">
                SELECT status
                FROM t_slip
                WHERE slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif qSlip.recordCount EQ 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "対象伝票が存在しません。" />
                <cfreturn result />
            </cfif>

            <cfif val(qSlip.status) EQ 2>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "確定済み伝票は削除できません。" />
                <cfreturn result />
            </cfif>

            <cfif val(qSlip.status) EQ 3>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "すでに削除済みです。" />
                <cfreturn result />
            </cfif>

            <cfquery>
                UPDATE t_slip
                SET
                    status = 3,
                    delete_datetime = <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                    update_datetime = <cfqueryparam value="#nowDt#" cfsqltype="cf_sql_timestamp">,
                    update_staff_code = <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                    update_staff_name = <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">
                WHERE slip_no = <cfqueryparam value="#slipNo#" cfsqltype="cf_sql_varchar">
                  AND status = 1
            </cfquery>

            <cfset result["message"] = "削除しました。" />

            <cfcatch type="database">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票削除中にデータベースエラーが発生しました。" />
            </cfcatch>
            <cfcatch type="any">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票削除中にエラーが発生しました。" />
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





    <cffunction name="getItemByCode" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var requestBody = "" />
        <cfset var requestData = {} />
        <cfset var itemCode = "" />
        <cfset var qItem = "" />

        <cfset result["status"] = 0 />
        <cfset result["message"] = "" />
        <cfset result["results"] = {} />

        <cftry>
            <cfset requestBody = toString(getHttpRequestData().content) />

            <cfif len(trim(requestBody))>
                <cfset requestData = deserializeJSON(requestBody) />
            <cfelse>
                <cfset requestData = {} />
            </cfif>

            <cfif structKeyExists(requestData, "item_code")>
                <cfset itemCode = trim(requestData.item_code) />
            </cfif>

            <cfif itemCode EQ "">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "商品コードを入力してください。" />
                <cfreturn result />
            </cfif>

            <cfquery name="qItem">
                SELECT
                    item_code,
                    jan_code,
                    item_name,
                    gentanka
                FROM m_item
                WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif qItem.recordCount EQ 0>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "商品が見つかりません。" />
                <cfreturn result />
            </cfif>

            <cfset result["results"]["item_code"] = qItem.item_code />
            <cfset result["results"]["jan_code"] = qItem.jan_code />
            <cfset result["results"]["item_name"] = qItem.item_name />
            <cfset result["results"]["gentanka"] = qItem.gentanka />

            <cfcatch type="database">
                <cfset result["status"] = 1 />
                <cfset result["message"] = "商品取得中にデータベースエラーが発生しました。" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

</cfcomponent>