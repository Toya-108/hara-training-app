<cfcomponent output="false">

    <cffunction name="importSlipCsv" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var csvText = "" />
        <cfset var csvLines = [] />
        <cfset var headerList = [] />
        <cfset var requiredColumns = [] />
        <cfset var headerIndexMap = {} />
        <cfset var slipMap = {} />
        <cfset var itemCodeMap = {} />
        <cfset var lineIndex = 0 />
        <cfset var currentLine = "" />
        <cfset var currentColumns = [] />
        <cfset var slipNo = "" />
        <cfset var slipDate = "" />
        <cfset var supplierCode = "" />
        <cfset var deliveryDate = "" />
        <cfset var slipMemo = "" />
        <cfset var itemCode = "" />
        <cfset var qtyText = "" />
        <cfset var detailMemo = "" />
        <cfset var qtyValue = 0 />
        <cfset var normalizedSlipNo = "" />
        <cfset var rowData = {} />
        <cfset var slipRow = {} />
        <cfset var detailArray = [] />
        <cfset var detailRow = {} />
        <cfset var lineNo = 0 />
        <cfset var totalQty = 0 />
        <cfset var totalAmount = 0 />
        <cfset var itemPrice = 0 />
        <cfset var uploadFilePath = "" />
        <cfset var uploadDirectory = getTempDirectory() />
        <cfset var qGetSupplier = "" />
        <cfset var qGetItem = "" />
        <cfset var importedSlipCount = 0 />
        <cfset var importedDetailCount = 0 />
        <cfset var historyItemCount = 0 />
        <cfset var staffCode = "" />
        <cfset var staffName = "" />

        <cfset result["status"] = 1 />
        <cfset result["message"] = "伝票受信に失敗しました。" />
        <cfset result["results"] = {} />

        <cftry>
            <!--- ログインチェック --->
            <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "ログイン情報が確認できません。再度ログインしてください。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfif>

            <cfif NOT structKeyExists(session, "staffCode") OR NOT len(trim(session.staffCode))>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "セッション内の社員コードが取得できません。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfif>

            <cfif NOT structKeyExists(session, "staffName") OR NOT len(trim(session.staffName))>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "セッション内の社員名が取得できません。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfif>

            <cfset staffCode = trim(session.staffCode) />
            <cfset staffName = trim(session.staffName) />

            <!--- 一時ディレクトリがなければ作成 --->
            <cfif NOT directoryExists(uploadDirectory)>
                <cfdirectory action="create" directory="#uploadDirectory#">
            </cfif>

            <!--- CSVファイルアップロード --->
            <cffile
                action="upload"
                filefield="csv_file"
                destination="#uploadDirectory#"
                nameconflict="makeunique"
                accept=".csv,text/csv,application/vnd.ms-excel">

            <cfset uploadFilePath = cffile.serverDirectory & "/" & cffile.serverFile />

            <cfif NOT len(trim(cffile.serverFile))>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "CSVファイルが選択されていません。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfif>

            <!--- CSV読込 --->
            <cffile action="read" file="#uploadFilePath#" variable="csvText" charset="utf-8">

            <cfset csvText = replace(csvText, chr(239) & chr(187) & chr(191), "", "one") />
            <cfset csvText = replace(csvText, chr(13) & chr(10), chr(10), "all") />
            <cfset csvText = replace(csvText, chr(13), chr(10), "all") />
            <cfset csvLines = listToArray(csvText, chr(10)) />

            <cfif arrayLen(csvLines) LTE 1>
                <cfset result["status"] = 1 />
                <cfset result["message"] = "CSVファイルにデータがありません。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                    <cffile action="delete" file="#uploadFilePath#">
                </cfif>

                <cfreturn result />
            </cfif>

            <!--- ヘッダ読込 --->
            <cfset headerList = parseCsvLine(csvLines[1]) />
            <cfset requiredColumns = ["slip_no", "slip_date", "supplier_code", "delivery_date", "item_code", "qty"] />

            <cfloop from="1" to="#arrayLen(headerList)#" index="lineIndex">
                <cfset headerIndexMap[lCase(trim(headerList[lineIndex]))] = lineIndex />
            </cfloop>

            <cfloop array="#requiredColumns#" index="currentLine">
                <cfif NOT structKeyExists(headerIndexMap, currentLine)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSVファイル内の見出しに必須列 #currentLine# がありません。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>
            </cfloop>

            <!--- CSV行を伝票ごとにまとめる --->
            <cfloop from="2" to="#arrayLen(csvLines)#" index="lineIndex">
                <cfset currentLine = trim(csvLines[lineIndex]) />

                <cfif NOT len(currentLine)>
                    <cfcontinue>
                </cfif>

                <cfset currentColumns = parseCsvLine(currentLine) />

                <cfset slipNo = getCsvValue(currentColumns, headerIndexMap, "slip_no") />
                <cfset slipDate = getCsvValue(currentColumns, headerIndexMap, "slip_date") />
                <cfset supplierCode = getCsvValue(currentColumns, headerIndexMap, "supplier_code") />
                <cfset deliveryDate = getCsvValue(currentColumns, headerIndexMap, "delivery_date") />
                <cfset slipMemo = getCsvValue(currentColumns, headerIndexMap, "slip_memo") />
                <cfset itemCode = getCsvValue(currentColumns, headerIndexMap, "item_code") />
                <cfset qtyText = getCsvValue(currentColumns, headerIndexMap, "qty") />
                <cfset detailMemo = getCsvValue(currentColumns, headerIndexMap, "detail_memo") />

                <cfif NOT len(slipNo)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 伝票番号が空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT len(slipDate)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 発注日が空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT isDate(slipDate)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 発注日の形式が不正です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT len(supplierCode)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 取引先コードが空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT len(deliveryDate)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 納品日が空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT isDate(deliveryDate)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 納品日の形式が不正です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT len(itemCode)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 商品コードが空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT len(qtyText)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 数量が空です。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfif NOT isNumeric(qtyText)>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 数量が数値ではありません。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfset qtyValue = int(val(qtyText)) />

                <cfif qtyValue LTE 0>
                    <cfset result["status"] = 1 />
                    <cfset result["message"] = "CSV #lineIndex# 行目: 数量は1以上を指定してください。" />

                    <cfset saveReceiveHistory(
                        receiveDatetime = now(),
                        slipCount = 0,
                        detailCount = 0,
                        itemCount = 0,
                        successFlag = 0,
                        message = result["message"]
                    ) />

                    <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                        <cffile action="delete" file="#uploadFilePath#">
                    </cfif>

                    <cfreturn result />
                </cfif>

                <cfset normalizedSlipNo = trim(slipNo) />

                <cfif NOT structKeyExists(slipMap, normalizedSlipNo)>
                    <cfset rowData = {} />
                    <cfset rowData["slip_no"] = normalizedSlipNo />
                    <cfset rowData["slip_date"] = dateFormat(parseDateTime(slipDate), "yyyy-mm-dd") />
                    <cfset rowData["supplier_code"] = trim(supplierCode) />
                    <cfset rowData["delivery_date"] = dateFormat(parseDateTime(deliveryDate), "yyyy-mm-dd") />
                    <cfset rowData["slip_memo"] = trim(slipMemo) />
                    <cfset rowData["details"] = [] />
                    <cfset slipMap[normalizedSlipNo] = rowData />
                <cfelse>
                    <cfif slipMap[normalizedSlipNo]["slip_date"] NEQ dateFormat(parseDateTime(slipDate), "yyyy-mm-dd")>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "CSV #lineIndex# 行目: 同一伝票番号で発注日が一致していません。" />

                        <cfset saveReceiveHistory(
                            receiveDatetime = now(),
                            slipCount = 0,
                            detailCount = 0,
                            itemCount = 0,
                            successFlag = 0,
                            message = result["message"]
                        ) />

                        <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                            <cffile action="delete" file="#uploadFilePath#">
                        </cfif>

                        <cfreturn result />
                    </cfif>

                    <cfif slipMap[normalizedSlipNo]["supplier_code"] NEQ trim(supplierCode)>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "CSV #lineIndex# 行目: 同一伝票番号で取引先コードが一致していません。" />

                        <cfset saveReceiveHistory(
                            receiveDatetime = now(),
                            slipCount = 0,
                            detailCount = 0,
                            itemCount = 0,
                            successFlag = 0,
                            message = result["message"]
                        ) />

                        <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                            <cffile action="delete" file="#uploadFilePath#">
                        </cfif>

                        <cfreturn result />
                    </cfif>

                    <cfif slipMap[normalizedSlipNo]["delivery_date"] NEQ dateFormat(parseDateTime(deliveryDate), "yyyy-mm-dd")>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "CSV #lineIndex# 行目: 同一伝票番号で納品日が一致していません。" />

                        <cfset saveReceiveHistory(
                            receiveDatetime = now(),
                            slipCount = 0,
                            detailCount = 0,
                            itemCount = 0,
                            successFlag = 0,
                            message = result["message"]
                        ) />

                        <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                            <cffile action="delete" file="#uploadFilePath#">
                        </cfif>

                        <cfreturn result />
                    </cfif>
                </cfif>

                <cfset detailRow = {} />
                <cfset detailRow["item_code"] = trim(itemCode) />
                <cfset detailRow["qty"] = qtyValue />
                <cfset detailRow["memo"] = trim(detailMemo) />

                <cfset arrayAppend(slipMap[normalizedSlipNo]["details"], detailRow) />
                <cfset itemCodeMap[trim(itemCode)] = true />
            </cfloop>

            <cftransaction>
                <cfloop collection="#slipMap#" item="slipNo">
                    <cfset slipRow = slipMap[slipNo] />

                    <!--- 既存伝票があれば明細→ヘッダの順で削除 --->
                    <cfquery>
                        DELETE FROM
                            t_slip_detail
                        WHERE
                            slip_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_no']#">
                    </cfquery>

                    <cfquery>
                        DELETE FROM
                            t_slip
                        WHERE
                            slip_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_no']#">
                    </cfquery>

                    <!--- 取引先取得 --->
                    <cfquery name="qGetSupplier">
                        SELECT
                            supplier_code,
                            supplier_name
                        FROM
                            m_supplier
                        WHERE
                            supplier_code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['supplier_code']#">
                            AND use_flag = 1
                    </cfquery>

                    <cfif qGetSupplier.recordCount EQ 0>
                        <cfset result["status"] = 1 />
                        <cfset result["message"] = "取引先コード #slipRow['supplier_code']# が有効な取引先マスタとして取得できません。" />
                        <cftransaction action="rollback" />

                        <cfset saveReceiveHistory(
                            receiveDatetime = now(),
                            slipCount = 0,
                            detailCount = 0,
                            itemCount = 0,
                            successFlag = 0,
                            message = result["message"]
                        ) />

                        <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                            <cffile action="delete" file="#uploadFilePath#">
                        </cfif>

                        <cfreturn result />
                    </cfif>

                    <cfset totalQty = 0 />
                    <cfset totalAmount = 0 />
                    <cfset detailArray = slipRow["details"] />

                    <cfloop from="1" to="#arrayLen(detailArray)#" index="lineNo">
                        <cfset detailRow = detailArray[lineNo] />

                        <!--- 商品取得 --->
                        <cfquery name="qGetItem">
                            SELECT
                                item_code,
                                jan_code,
                                item_name,
                                gentanka
                            FROM
                                m_item
                            WHERE
                                item_code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#detailRow['item_code']#">
                                AND (use_flag = 1 OR use_flag IS NULL)
                        </cfquery>

                        <cfif qGetItem.recordCount EQ 0>
                            <cfset result["status"] = 1 />
                            <cfset result["message"] = "商品コード #detailRow['item_code']# が有効な商品マスタとして取得できません。" />
                            <cftransaction action="rollback" />

                            <cfset saveReceiveHistory(
                                receiveDatetime = now(),
                                slipCount = 0,
                                detailCount = 0,
                                itemCount = 0,
                                successFlag = 0,
                                message = result["message"]
                            ) />

                            <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                                <cffile action="delete" file="#uploadFilePath#">
                            </cfif>

                            <cfreturn result />
                        </cfif>

                        <cfif NOT len(trim(qGetItem.gentanka))>
                            <cfset result["status"] = 1 />
                            <cfset result["message"] = "商品コード #detailRow['item_code']# の原単価が未設定です。" />
                            <cftransaction action="rollback" />

                            <cfset saveReceiveHistory(
                                receiveDatetime = now(),
                                slipCount = 0,
                                detailCount = 0,
                                itemCount = 0,
                                successFlag = 0,
                                message = result["message"]
                            ) />

                            <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                                <cffile action="delete" file="#uploadFilePath#">
                            </cfif>

                            <cfreturn result />
                        </cfif>

                        <cfset itemPrice = val(qGetItem.gentanka) />
                        <cfset totalQty = totalQty + detailRow["qty"] />
                        <cfset totalAmount = totalAmount + (detailRow["qty"] * itemPrice) />

                        <cfif lineNo EQ 1>
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
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_no']#">,
                                    <cfqueryparam cfsqltype="cf_sql_date" value="#slipRow['slip_date']#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['supplier_code']#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetSupplier.supplier_name#">,
                                    <cfqueryparam cfsqltype="cf_sql_date" value="#slipRow['delivery_date']#">,
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="0">,
                                    <cfqueryparam cfsqltype="cf_sql_decimal" value="0">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_memo']#" null="#NOT len(slipRow['slip_memo'])#">,
                                    NOW(),
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffCode#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffName#">,
                                    NOW(),
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffCode#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffName#">
                                )
                            </cfquery>
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
                                memo,
                                create_datetime,
                                create_staff_code,
                                create_staff_name,
                                update_datetime,
                                update_staff_code,
                                update_staff_name
                            ) VALUES (
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_no']#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#lineNo#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetItem.item_code#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetItem.jan_code#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetItem.item_name#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#detailRow['qty']#">,
                                <cfqueryparam cfsqltype="cf_sql_decimal" value="#itemPrice#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#detailRow['memo']#" null="#NOT len(detailRow['memo'])#">,
                                NOW(),
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffCode#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffName#">,
                                NOW(),
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffCode#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffName#">
                            )
                        </cfquery>

                        <cfset importedDetailCount = importedDetailCount + 1 />
                    </cfloop>

                    <cfquery>
                        UPDATE
                            t_slip
                        SET
                            total_qty = <cfqueryparam cfsqltype="cf_sql_integer" value="#totalQty#">,
                            total_amount = <cfqueryparam cfsqltype="cf_sql_decimal" value="#totalAmount#">,
                            update_datetime = NOW(),
                            update_staff_code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffCode#">,
                            update_staff_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#staffName#">
                        WHERE
                            slip_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slipRow['slip_no']#">
                    </cfquery>

                    <cfset importedSlipCount = importedSlipCount + 1 />
                </cfloop>
            </cftransaction>

            <cfset historyItemCount = structCount(itemCodeMap) />

            <cfset result["status"] = 0 />
            <cfset result["message"] = "伝票受信が完了しました。伝票 #importedSlipCount# 件、明細 #importedDetailCount# 件を登録しました。" />
            <cfset result["results"]["slip_count"] = importedSlipCount />
            <cfset result["results"]["detail_count"] = importedDetailCount />
            <cfset result["results"]["item_count"] = historyItemCount />

            <cfset saveReceiveHistory(
                receiveDatetime = now(),
                slipCount = importedSlipCount,
                detailCount = importedDetailCount,
                itemCount = historyItemCount,
                successFlag = 1,
                message = result["message"]
            ) />

            <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                <cffile action="delete" file="#uploadFilePath#">
            </cfif>

            <cfreturn result />

            <cfcatch type="database">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="伝票受信DBエラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.queryError# | Detail: #cfcatch.detail#">

                <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                    <cffile action="delete" file="#uploadFilePath#">
                </cfif>

                <cfset result["status"] = 1 />
                <cfset result["message"] = "伝票受信中にデータベースエラーが発生しました。" />

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfcatch>

            <cfcatch type="any">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="伝票受信エラー Message: #cfcatch.message# | Detail: #cfcatch.detail# | Where: #cfcatch.tagContext[1].template#:#cfcatch.tagContext[1].line#">

                <cfif len(uploadFilePath) AND fileExists(uploadFilePath)>
                    <cffile action="delete" file="#uploadFilePath#">
                </cfif>

                <cfset result["status"] = 1 />

                <cfif findNoCase("No file was uploaded", cfcatch.message) OR findNoCase("csv_file", cfcatch.message)>
                    <cfset result["message"] = "CSVファイルが選択されていません。" />
                <cfelse>
                    <cfset result["message"] = "伝票受信中にエラーが発生しました。" />
                </cfif>

                <cfset saveReceiveHistory(
                    receiveDatetime = now(),
                    slipCount = 0,
                    detailCount = 0,
                    itemCount = 0,
                    successFlag = 0,
                    message = result["message"]
                ) />

                <cfreturn result />
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getReceiveHistory" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {} />
        <cfset var qGetHistory = "" />
        <cfset var historyArray = [] />
        <cfset var rowData = {} />

        <cfset result["status"] = 1 />
        <cfset result["message"] = "受信履歴の取得に失敗しました。" />
        <cfset result["results"] = [] />

        <cftry>
            <cfquery name="qGetHistory">
                SELECT
                    DATE_FORMAT(receive_datetime, '%Y-%m-%d %H:%i:%s') AS receive_datetime,
                    slip_count,
                    detail_count,
                    item_count,
                    success_flag
                FROM
                    r_receive
                ORDER BY
                    receive_datetime DESC,
                    receive_id DESC
                LIMIT 5
            </cfquery>

            <cfloop query="qGetHistory">
                <cfset rowData = {} />
                <cfset rowData["receive_datetime"] = qGetHistory.receive_datetime />
                <cfset rowData["slip_count"] = qGetHistory.slip_count />
                <cfset rowData["detail_count"] = qGetHistory.detail_count />
                <cfset rowData["item_count"] = qGetHistory.item_count />
                <cfset rowData["success_flag"] = qGetHistory.success_flag />
                <cfset arrayAppend(historyArray, rowData) />
            </cfloop>

            <cfset result["status"] = 0 />
            <cfset result["message"] = "" />
            <cfset result["results"] = historyArray />
            <cfreturn result />

            <cfcatch type="database">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="受信履歴取得DBエラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.queryError#">

                <cfset result["status"] = 1 />
                <cfset result["message"] = "受信履歴の取得中にデータベースエラーが発生しました。" />
                <cfreturn result />
            </cfcatch>

            <cfcatch type="any">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="受信履歴取得エラー Message: #cfcatch.message# | Detail: #cfcatch.detail#">

                <cfset result["status"] = 1 />
                <cfset result["message"] = "受信履歴の取得中にエラーが発生しました。" />
                <cfreturn result />
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="saveReceiveHistory" access="private" returntype="void" output="false">
        <cfargument name="receiveDatetime" type="date" required="true">
        <cfargument name="slipCount" type="numeric" required="true">
        <cfargument name="detailCount" type="numeric" required="true">
        <cfargument name="itemCount" type="numeric" required="true">
        <cfargument name="successFlag" type="numeric" required="true">
        <cfargument name="message" type="string" required="true">

        <cftry>
            <cfquery>
                INSERT INTO r_receive (
                    receive_datetime,
                    slip_count,
                    detail_count,
                    item_count,
                    success_flag,
                    message,
                    create_datetime
                ) VALUES (
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.receiveDatetime#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.slipCount#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.detailCount#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemCount#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.successFlag#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.message#" null="#NOT len(trim(arguments.message))#">,
                    NOW()
                )
            </cfquery>

            <cfcatch type="database">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="受信履歴保存DBエラー SQL: #cfcatch.SQL# | QueryError: #cfcatch.queryError#">
            </cfcatch>

            <cfcatch type="any">
                <cflog
                    file="slip_receive"
                    type="error"
                    text="受信履歴保存エラー Message: #cfcatch.message# | Detail: #cfcatch.detail#">
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getCsvValue" access="private" returntype="string" output="false">
        <cfargument name="columns" type="array" required="true">
        <cfargument name="headerIndexMap" type="struct" required="true">
        <cfargument name="columnName" type="string" required="true">

        <cfset var columnIndex = 0 />

        <cfif NOT structKeyExists(arguments.headerIndexMap, lCase(arguments.columnName))>
            <cfreturn "" />
        </cfif>

        <cfset columnIndex = arguments.headerIndexMap[lCase(arguments.columnName)] />

        <cfif arrayLen(arguments.columns) LT columnIndex>
            <cfreturn "" />
        </cfif>

        <cfreturn trim(arguments.columns[columnIndex]) />
    </cffunction>

    <cffunction name="parseCsvLine" access="private" returntype="array" output="false">
        <cfargument name="lineText" type="string" required="true">

        <cfset var resultArray = [] />
        <cfset var currentValue = "" />
        <cfset var currentChar = "" />
        <cfset var nextChar = "" />
        <cfset var inQuotes = false />
        <cfset var i = 0 />
        <cfset var textLength = len(arguments.lineText) />

        <cfloop from="1" to="#textLength#" index="i">
            <cfset currentChar = mid(arguments.lineText, i, 1) />

            <cfif currentChar EQ '"'>
                <cfif inQuotes>
                    <cfif i LT textLength>
                        <cfset nextChar = mid(arguments.lineText, i + 1, 1) />
                    <cfelse>
                        <cfset nextChar = "" />
                    </cfif>

                    <cfif nextChar EQ '"'>
                        <cfset currentValue = currentValue & '"' />
                        <cfset i = i + 1 />
                    <cfelse>
                        <cfset inQuotes = false />
                    </cfif>
                <cfelse>
                    <cfset inQuotes = true />
                </cfif>
            <cfelseif currentChar EQ "," AND NOT inQuotes>
                <cfset arrayAppend(resultArray, currentValue) />
                <cfset currentValue = "" />
            <cfelse>
                <cfset currentValue = currentValue & currentChar />
            </cfif>
        </cfloop>

        <cfset arrayAppend(resultArray, currentValue) />

        <cfreturn resultArray />
    </cffunction>

</cfcomponent>