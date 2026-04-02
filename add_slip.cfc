<cfcomponent displayname="AddSlip" output="false">

    <cffunction name="saveSlip" access="remote" returntype="struct" returnformat="json" output="false">

        <cfset var result = {}>

        <cfset var requestData = {}>

        <cfset var slipNo = "">
        <cfset var slipDate = "">
        <cfset var supplierCode = "">
        <cfset var supplierName = "">
        <cfset var deliveryDate = "">
        <cfset var memo = "">
        <cfset var detailList = []>

        <cfset var qGetSlipNo = "">
        <cfset var detail = {}>

        <cfset var i = 0>
        <cfset var lineNo = 0>

        <cfset var slipPrefix = "">
        <cfset var nextSeq = 1>

        <cfset var totalQty = 0>
        <cfset var totalAmount = 0>
        <cfset var janCode = "">
        <cfset var qtyValue = 0>
        <cfset var unitPriceValue = 0>

        <cfset result["status"] = 1>
        <cfset result["message"] = "">

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "slip_date")>
                <cfset slipDate = Trim(requestData.slip_date)>
            </cfif>

            <cfif StructKeyExists(requestData, "supplier_code")>
                <cfset supplierCode = Trim(requestData.supplier_code)>
            </cfif>

            <cfif StructKeyExists(requestData, "supplier_name")>
                <cfset supplierName = Trim(requestData.supplier_name)>
            </cfif>

            <cfif StructKeyExists(requestData, "delivery_date")>
                <cfset deliveryDate = Trim(requestData.delivery_date)>
            </cfif>

            <cfif StructKeyExists(requestData, "memo")>
                <cfset memo = Trim(requestData.memo)>
            </cfif>

            <cfif StructKeyExists(requestData, "detail_list")>
                <cfset detailList = requestData.detail_list>
            </cfif>

            <cfif slipDate eq "">
                <cfset result["message"] = "発注日を入力してください。">
                <cfreturn result>
            </cfif>

            <cfif supplierCode eq "">
                <cfset result["message"] = "取引先を選択してください。">
                <cfreturn result>
            </cfif>

            <cfif supplierName eq "">
                <cfset result["message"] = "取引先名が取得できません。">
                <cfreturn result>
            </cfif>

            <cfif deliveryDate eq "">
                <cfset result["message"] = "納品日を入力してください。">
                <cfreturn result>
            </cfif>

            <cfif ArrayLen(detailList) eq 0>
                <cfset result["message"] = "明細を1行以上入力してください。">
                <cfreturn result>
            </cfif>

            <cfif NOT StructKeyExists(session, "staffCode") OR session.staffCode eq "">
                <cfset result["message"] = "ログイン情報が取得できません。再ログインしてください。">
                <cfreturn result>
            </cfif>

            <cfif NOT StructKeyExists(session, "staffName") OR session.staffName eq "">
                <cfset result["message"] = "ログイン者名が取得できません。再ログインしてください。">
                <cfreturn result>
            </cfif>

            <cfloop from="1" to="#ArrayLen(detailList)#" index="i">
                <cfset detail = detailList[i]>

                <cfif NOT StructKeyExists(detail, "item_code") OR Trim(detail.item_code) eq "">
                    <cfset result["message"] = i & "行目の商品コードを入力してください。">
                    <cfreturn result>
                </cfif>

                <cfif NOT StructKeyExists(detail, "item_name") OR Trim(detail.item_name) eq "">
                    <cfset result["message"] = i & "行目の商品名を入力してください。">
                    <cfreturn result>
                </cfif>

                <cfif NOT StructKeyExists(detail, "qty") OR Trim(detail.qty) eq "">
                    <cfset result["message"] = i & "行目の数量を入力してください。">
                    <cfreturn result>
                </cfif>

                <cfif NOT StructKeyExists(detail, "unit_price") OR Trim(detail.unit_price) eq "">
                    <cfset result["message"] = i & "行目の単価を入力してください。">
                    <cfreturn result>
                </cfif>

                <cfset qtyValue = Val(Replace(Trim(detail.qty), ",", "", "all"))>
                <cfset unitPriceValue = Val(Replace(Trim(detail.unit_price), ",", "", "all"))>

                <cfif qtyValue LTE 0>
                    <cfset result["message"] = i & "行目の数量は1以上を入力してください。">
                    <cfreturn result>
                </cfif>

                <cfif unitPriceValue LT 0>
                    <cfset result["message"] = i & "行目の単価は0以上を入力してください。">
                    <cfreturn result>
                </cfif>

                <cfset totalQty = totalQty + qtyValue>
                <cfset totalAmount = totalAmount + (qtyValue * unitPriceValue)>
            </cfloop>

            <cftransaction isolation="serializable">

                <cfset slipPrefix = DateFormat(slipDate, "yymmdd")>

                <cfquery name="qGetSlipNo">
                    SELECT
                        MAX(slip_no) AS max_slip_no
                    FROM
                        t_slip
                    WHERE
                        slip_no LIKE <cfqueryparam value="#slipPrefix#%" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfif qGetSlipNo.max_slip_no neq "">
                    <cfset nextSeq = Val(Right(qGetSlipNo.max_slip_no, 4)) + 1>
                <cfelse>
                    <cfset nextSeq = 1>
                </cfif>

                <cfset slipNo = slipPrefix & Right("0000" & nextSeq, 4)>

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
                        <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                        <cfqueryparam value="#totalQty#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#totalAmount#" cfsqltype="cf_sql_decimal" scale="2">,
                        <cfqueryparam value="#memo#" cfsqltype="cf_sql_varchar" null="#(memo eq '')#">,
                        NOW(),
                        <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">,
                        NOW(),
                        <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>

                <cfloop from="1" to="#ArrayLen(detailList)#" index="i">
                    <cfset detail = detailList[i]>
                    <cfset lineNo = i>

                    <cfset janCode = "">
                    <cfif StructKeyExists(detail, "jan_code")>
                        <cfset janCode = Trim(detail.jan_code)>
                    </cfif>

                    <cfset qtyValue = Val(Replace(Trim(detail.qty), ",", "", "all"))>
                    <cfset unitPriceValue = Val(Replace(Trim(detail.unit_price), ",", "", "all"))>

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
                            <cfqueryparam value="#lineNo#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#Trim(detail.item_code)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#janCode#" cfsqltype="cf_sql_varchar" null="#(janCode eq '')#">,
                            <cfqueryparam value="#Trim(detail.item_name)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#qtyValue#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#unitPriceValue#" cfsqltype="cf_sql_decimal" scale="2">,
                            NOW(),
                            <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">,
                            NOW(),
                            <cfqueryparam value="#session.staffCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#session.staffName#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>
                </cfloop>

            </cftransaction>

            <cfset result["status"] = 0>
            <cfset result["message"] = "伝票を登録しました。伝票番号：" & slipNo>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="
                    伝票登録エラー
                    message: #cfcatch.message#
                    detail: #cfcatch.detail#
                    sql: #StructKeyExists(cfcatch, 'sql') ? cfcatch.sql : ''#
                ">
                <cfset result["status"] = 1>
                <cfset result["message"] = "伝票登録中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="getItemByCode" access="remote" returntype="struct" returnformat="json" output="false">

        <cfset var result = {}>
        <cfset var record = {}>

        <cfset var itemCode = "">
        <cfset var qGetItem = "">
        <cfset var req = "">
        <cfset var body = {}>

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cfset req = GetHttpRequestData()>

        <cfif Len(req.content)>
            <cfset body = DeserializeJSON(ToString(req.content))>

            <cfif StructKeyExists(body, "item_code") and body.item_code neq "">
                <cfset itemCode = Trim(body.item_code)>
            </cfif>
        </cfif>

        <cflog file="HARA_TRAINING_APP" type="Information" text="商品コード：#itemCode#">

        <cftry>
            <cfquery name="qGetItem">
                SELECT
                    item_code,
                    jan_code,
                    item_name,
                    gentanka
                FROM
                    m_item
                WHERE
                    TRIM(item_code) = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="商品取得エラー：#cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品取得中にエラーが発生しました。">
                <cfreturn result>
            </cfcatch>
        </cftry>

        <cflog file="HARA_TRAINING_APP" type="Information" text="商品取得件数：#qGetItem.recordCount#件">

        <cfif qGetItem.recordCount eq 0>
            <cfset result["status"] = 1>
            <cfset result["message"] = "該当商品なし">
            <cfreturn result>
        </cfif>

        <cfset record["item_code"] = qGetItem.item_code>
        <cfset record["jan_code"] = qGetItem.jan_code>
        <cfset record["item_name"] = qGetItem.item_name>
        <cfset record["gentanka"] = qGetItem.gentanka>

        <cfset result["results"] = record>

        <cfreturn result>
    </cffunction>
</cfcomponent>