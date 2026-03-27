<cfcomponent displayname="MItemDetail" output="false">

    <cffunction name="saveItem" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var oldItemCode = "">
        <cfset var itemCode = "">
        <cfset var janCode = "">
        <cfset var itemName = "">
        <cfset var itemNameKana = "">
        <cfset var gentanka = 0>
        <cfset var baitanka = 0>
        <cfset var itemCategory = "">
        <cfset var useFlag = 1>
        <cfset var qCheck = "">
        <cfset var qDup = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "old_item_code")>
                <cfset oldItemCode = Trim(requestData.old_item_code)>
            </cfif>
            <cfif StructKeyExists(requestData, "item_code")>
                <cfset itemCode = Trim(requestData.item_code)>
            </cfif>
            <cfif StructKeyExists(requestData, "jan_code")>
                <cfset janCode = Trim(requestData.jan_code)>
            </cfif>
            <cfif StructKeyExists(requestData, "item_name")>
                <cfset itemName = Trim(requestData.item_name)>
            </cfif>
            <cfif StructKeyExists(requestData, "item_name_kana")>
                <cfset itemNameKana = Trim(requestData.item_name_kana)>
            </cfif>
            <cfif StructKeyExists(requestData, "gentanka") AND requestData.gentanka neq "">
                <cfset gentanka = Val(requestData.gentanka)>
            </cfif>
            <cfif StructKeyExists(requestData, "baitanka") AND requestData.baitanka neq "">
                <cfset baitanka = Val(requestData.baitanka)>
            </cfif>
            <cfif StructKeyExists(requestData, "item_category")>
                <cfset itemCategory = Trim(requestData.item_category)>
            </cfif>
            <cfif StructKeyExists(requestData, "use_flag")>
                <cfset useFlag = Val(requestData.use_flag)>
            </cfif>

            <cfif itemCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品コードを入力してください。">
                <cfreturn result>
            </cfif>

            <cfif itemName eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品名を入力してください。">
                <cfreturn result>
            </cfif>

            <cftransaction>
                <cfquery name="qCheck">
                    SELECT item_code
                    FROM m_item
                    WHERE item_code = <cfqueryparam value="#oldItemCode neq '' ? oldItemCode : itemCode#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfif qCheck.recordCount eq 0>
                    <cfquery name="qDup">
                        SELECT item_code
                        FROM m_item
                        WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                    </cfquery>

                    <cfif qDup.recordCount gt 0>
                        <cfset result["status"] = 1>
                        <cfset result["message"] = "同じ商品コードが既に存在します。">
                        <cfreturn result>
                    </cfif>

                    <cfquery>
                        INSERT INTO m_item (
                            item_code,
                            jan_code,
                            item_name,
                            item_name_kana,
                            gentanka,
                            baitanka,
                            item_category,
                            use_flag,
                            create_datetime,
                            create_staff_code,
                            create_staff_name,
                            update_datetime,
                            update_staff_code,
                            update_staff_name
                        ) VALUES (
                            <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#janCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#itemName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#itemNameKana#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#gentanka#" cfsqltype="cf_sql_decimal" scale="2">,
                            <cfqueryparam value="#baitanka#" cfsqltype="cf_sql_decimal" scale="2">,
                            <cfqueryparam value="#itemCategory#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_integer">,
                            NOW(),
                            '#session.staffCode#',
                            '#session.staffName#',
                            NULL,
                            NULL,
                            NULL
                        )
                    </cfquery>

                    <cfset result["message"] = "登録しました。">
                <cfelse>
                    <cfif oldItemCode neq itemCode>
                        <cfquery name="qDup">
                            SELECT item_code
                            FROM m_item
                            WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                        </cfquery>

                        <cfif qDup.recordCount gt 0>
                            <cfset result["status"] = 1>
                            <cfset result["message"] = "同じ商品コードが既に存在します。">
                            <cfreturn result>
                        </cfif>
                    </cfif>

                    <cfquery>
                        UPDATE m_item
                        SET
                            item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">,
                            jan_code = <cfqueryparam value="#janCode#" cfsqltype="cf_sql_varchar">,
                            item_name = <cfqueryparam value="#itemName#" cfsqltype="cf_sql_varchar">,
                            item_name_kana = <cfqueryparam value="#itemNameKana#" cfsqltype="cf_sql_varchar">,
                            gentanka = <cfqueryparam value="#gentanka#" cfsqltype="cf_sql_decimal" scale="2">,
                            baitanka = <cfqueryparam value="#baitanka#" cfsqltype="cf_sql_decimal" scale="2">,
                            item_category = <cfqueryparam value="#itemCategory#" cfsqltype="cf_sql_varchar">,
                            use_flag = <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_integer">,
                            update_datetime = NOW(),
                            update_staff_code = '#session.staffId#',
                            update_staff_name = '#session.staffName#'
                        WHERE
                            item_code = <cfqueryparam value="#oldItemCode neq '' ? oldItemCode : itemCode#" cfsqltype="cf_sql_varchar">
                    </cfquery>

                    <cfset result["message"] = "保存しました。">
                </cfif>
            </cftransaction>

            <cfset result["status"] = 0>
            <cfset result["results"]["item_code"] = itemCode>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="商品保存エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品保存中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <cffunction name="deleteItem" access="remote" returntype="struct" returnformat="json" output="false">
        <cfset var result = {}>
        <cfset var requestData = {}>
        <cfset var itemCode = "">
        <cfset var qCheck = "">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cftry>
            <cfset requestData = DeserializeJSON(ToString(GetHttpRequestData().content))>

            <cfif StructKeyExists(requestData, "item_code")>
                <cfset itemCode = Trim(requestData.item_code)>
            </cfif>

            <cfif itemCode eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品コードが不正です。">
                <cfreturn result>
            </cfif>

            <cftransaction>
                <cfquery name="qCheck">
                    SELECT item_code, item_name
                    FROM m_item
                    WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfif qCheck.recordCount neq 1>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "削除対象データが存在しません。">
                    <cfreturn result>
                </cfif>

                <cfquery>
                    DELETE FROM m_item
                    WHERE item_code = <cfqueryparam value="#itemCode#" cfsqltype="cf_sql_varchar">
                </cfquery>

                <cfset result["status"] = 0>
                <cfset result["message"] = "削除しました。">
                <cfset result["results"]["item_code"] = qCheck.item_code[1]>
                <cfset result["results"]["item_name"] = qCheck.item_name[1]>
            </cftransaction>

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="商品削除エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "商品削除中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>