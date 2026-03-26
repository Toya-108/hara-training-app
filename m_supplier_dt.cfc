<cfcomponent displayname="m_supplier_dt" output="false">

    <cffunction name="getSupplierDetail" access="remote" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {} >
        <cfset var rawBody = "" >
        <cfset var contentType = "" >
        <cfset var supplierId = 0>

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cfif StructKeyExists(cgi, "content_type")>
            <cfset contentType = LCase(cgi.content_type)>
        </cfif>

        <cfif Find("application/json", contentType)>
            <cftry>
                <cfset rawBody = ToString(GetHttpRequestData().content)>
                <cfif Trim(rawBody) neq "">
                    <cfset requestData = DeserializeJSON(rawBody)>
                </cfif>
                <cfcatch>
                    <cfset requestData = {} >
                </cfcatch>
            </cftry>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_id")>
            <cfset supplierId = Val(requestData.supplier_id)>
        <cfelseif StructKeyExists(form, "supplier_id")>
            <cfset supplierId = Val(form.supplier_id)>
        </cfif>

        <cfif supplierId lte 0>
            <cfset result["status"] = 1>
            <cfset result["message"] = "取引先IDが不正です。">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery name="qGetSupplier">
                SELECT
                    s.supplier_id,
                    s.supplier_code,
                    s.supplier_name,
                    s.supplier_name_kana,
                    s.zip_code,
                    s.prefecture_code,
                    p.prefecture_name,
                    s.address1,
                    s.address2,
                    s.tel,
                    s.fax,
                    s.delivery_company_code,
                    d.delivery_company_name,
                    s.note,
                    s.use_flag,
                    DATE_FORMAT(s.create_datetime, '%Y/%m/%d %H:%i:%s') AS create_datetime_disp,
                    s.create_staff_code,
                    s.create_staff_name,
                    DATE_FORMAT(s.update_datetime, '%Y/%m/%d %H:%i:%s') AS update_datetime_disp,
                    s.update_staff_code,
                    s.update_staff_name
                FROM
                    m_supplier s
                LEFT OUTER JOIN
                    m_prefecture p
                        ON s.prefecture_code = p.prefecture_code
                LEFT OUTER JOIN
                    m_delivery_company d
                        ON s.delivery_company_code = d.delivery_company_code
                WHERE
                    s.supplier_id = <cfqueryparam value="#supplierId#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qGetSupplier.recordCount neq 1>
                <cfset result["status"] = 1>
                <cfset result["message"] = "データが存在しません。">
                <cfreturn result>
            </cfif>

            <cfset result["results"] = {} >
            <cfset result["results"]["supplier_id"] = qGetSupplier.supplier_id[1]>
            <cfset result["results"]["supplier_code"] = qGetSupplier.supplier_code[1]>
            <cfset result["results"]["supplier_name"] = qGetSupplier.supplier_name[1]>
            <cfset result["results"]["supplier_name_kana"] = qGetSupplier.supplier_name_kana[1]>
            <cfset result["results"]["zip_code"] = qGetSupplier.zip_code[1]>
            <cfset result["results"]["prefecture_code"] = qGetSupplier.prefecture_code[1]>
            <cfset result["results"]["prefecture_name"] = qGetSupplier.prefecture_name[1]>
            <cfset result["results"]["address1"] = qGetSupplier.address1[1]>
            <cfset result["results"]["address2"] = qGetSupplier.address2[1]>
            <cfset result["results"]["tel"] = qGetSupplier.tel[1]>
            <cfset result["results"]["fax"] = qGetSupplier.fax[1]>
            <cfset result["results"]["delivery_company_code"] = qGetSupplier.delivery_company_code[1]>
            <cfset result["results"]["delivery_company_name"] = qGetSupplier.delivery_company_name[1]>
            <cfset result["results"]["note"] = qGetSupplier.note[1]>
            <cfset result["results"]["use_flag"] = qGetSupplier.use_flag[1]>
            <cfset result["results"]["create_datetime_disp"] = qGetSupplier.create_datetime_disp[1]>
            <cfset result["results"]["create_staff_code"] = qGetSupplier.create_staff_code[1]>
            <cfset result["results"]["create_staff_name"] = qGetSupplier.create_staff_name[1]>
            <cfset result["results"]["update_datetime_disp"] = qGetSupplier.update_datetime_disp[1]>
            <cfset result["results"]["update_staff_code"] = qGetSupplier.update_staff_code[1]>
            <cfset result["results"]["update_staff_name"] = qGetSupplier.update_staff_name[1]>

            <cfset result["message"] = "取得しました。">

            <cfcatch type="database">
                <cfset result["status"] = 1>
                <cfset result["message"] = cfcatch.SQL & " / " & cfcatch.queryError>
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="saveSupplier" access="remote" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {} >
        <cfset var rawBody = "" >
        <cfset var contentType = "" >

        <cfset var supplierId = 0>
        <cfset var supplierCode = "">
        <cfset var supplierName = "">
        <cfset var supplierNameKana = "">
        <cfset var zipCode = "">
        <cfset var prefectureCode = "">
        <cfset var address1 = "">
        <cfset var address2 = "">
        <cfset var tel = "">
        <cfset var fax = "">
        <cfset var deliveryCompanyCode = "">
        <cfset var note = "">
        <cfset var useFlag = "1">

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cfif StructKeyExists(cgi, "content_type")>
            <cfset contentType = LCase(cgi.content_type)>
        </cfif>

        <cfif Find("application/json", contentType)>
            <cftry>
                <cfset rawBody = ToString(GetHttpRequestData().content)>
                <cfif Trim(rawBody) neq "">
                    <cfset requestData = DeserializeJSON(rawBody)>
                </cfif>
                <cfcatch>
                    <cfset requestData = {} >
                </cfcatch>
            </cftry>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_id")>
            <cfset supplierId = Val(requestData.supplier_id)>
        <cfelseif StructKeyExists(form, "supplier_id")>
            <cfset supplierId = Val(form.supplier_id)>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_code")>
            <cfset supplierCode = Trim(requestData.supplier_code)>
        <cfelseif StructKeyExists(form, "supplier_code")>
            <cfset supplierCode = Trim(form.supplier_code)>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_name")>
            <cfset supplierName = Trim(requestData.supplier_name)>
        <cfelseif StructKeyExists(form, "supplier_name")>
            <cfset supplierName = Trim(form.supplier_name)>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_name_kana")>
            <cfset supplierNameKana = Trim(requestData.supplier_name_kana)>
        <cfelseif StructKeyExists(form, "supplier_name_kana")>
            <cfset supplierNameKana = Trim(form.supplier_name_kana)>
        </cfif>

        <cfif StructKeyExists(requestData, "zip_code")>
            <cfset zipCode = Trim(requestData.zip_code)>
        <cfelseif StructKeyExists(form, "zip_code")>
            <cfset zipCode = Trim(form.zip_code)>
        </cfif>

        <cfif StructKeyExists(requestData, "prefecture_code")>
            <cfset prefectureCode = Trim(requestData.prefecture_code)>
        <cfelseif StructKeyExists(form, "prefecture_code")>
            <cfset prefectureCode = Trim(form.prefecture_code)>
        </cfif>

        <cfif StructKeyExists(requestData, "address1")>
            <cfset address1 = Trim(requestData.address1)>
        <cfelseif StructKeyExists(form, "address1")>
            <cfset address1 = Trim(form.address1)>
        </cfif>

        <cfif StructKeyExists(requestData, "address2")>
            <cfset address2 = Trim(requestData.address2)>
        <cfelseif StructKeyExists(form, "address2")>
            <cfset address2 = Trim(form.address2)>
        </cfif>

        <cfif StructKeyExists(requestData, "tel")>
            <cfset tel = Trim(requestData.tel)>
        <cfelseif StructKeyExists(form, "tel")>
            <cfset tel = Trim(form.tel)>
        </cfif>

        <cfif StructKeyExists(requestData, "fax")>
            <cfset fax = Trim(requestData.fax)>
        <cfelseif StructKeyExists(form, "fax")>
            <cfset fax = Trim(form.fax)>
        </cfif>

        <cfif StructKeyExists(requestData, "delivery_company_code")>
            <cfset deliveryCompanyCode = Trim(requestData.delivery_company_code)>
        <cfelseif StructKeyExists(form, "delivery_company_code")>
            <cfset deliveryCompanyCode = Trim(form.delivery_company_code)>
        </cfif>

        <cfif StructKeyExists(requestData, "note")>
            <cfset note = requestData.note>
        <cfelseif StructKeyExists(form, "note")>
            <cfset note = form.note>
        </cfif>

        <cfif StructKeyExists(requestData, "use_flag")>
            <cfset useFlag = Trim(requestData.use_flag)>
        <cfelseif StructKeyExists(form, "use_flag")>
            <cfset useFlag = Trim(form.use_flag)>
        </cfif>

        <cfif supplierCode eq "">
            <cfset result["status"] = 1>
            <cfset result["message"] = "取引先コード必須">
            <cfreturn result>
        </cfif>

        <cfif supplierName eq "">
            <cfset result["status"] = 1>
            <cfset result["message"] = "取引先名必須">
            <cfreturn result>
        </cfif>

        <cfif useFlag neq "0" AND useFlag neq "1">
            <cfset useFlag = "1">
        </cfif>

        <cftry>
            <cftransaction>

                <cfquery name="qCheckDuplicate">
                    SELECT supplier_id
                    FROM m_supplier
                    WHERE supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">
                    <cfif supplierId gt 0>
                        AND supplier_id <> <cfqueryparam value="#supplierId#" cfsqltype="cf_sql_integer">
                    </cfif>
                </cfquery>

                <cfif qCheckDuplicate.recordCount gt 0>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "同じコードが存在します">
                    <cfreturn result>
                </cfif>

                <cfif supplierId gt 0>
                    <cfquery>
                        UPDATE m_supplier
                        SET
                            supplier_code = <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">,
                            supplier_name = <cfqueryparam value="#supplierName#" cfsqltype="cf_sql_varchar">,
                            supplier_name_kana = <cfqueryparam value="#supplierNameKana#" cfsqltype="cf_sql_varchar" null="#supplierNameKana eq ''#">,
                            zip_code = <cfqueryparam value="#zipCode#" cfsqltype="cf_sql_varchar" null="#zipCode eq ''#">,
                            prefecture_code = <cfqueryparam value="#prefectureCode#" cfsqltype="cf_sql_varchar" null="#prefectureCode eq ''#">,
                            address1 = <cfqueryparam value="#address1#" cfsqltype="cf_sql_varchar" null="#address1 eq ''#">,
                            address2 = <cfqueryparam value="#address2#" cfsqltype="cf_sql_varchar" null="#address2 eq ''#">,
                            tel = <cfqueryparam value="#tel#" cfsqltype="cf_sql_varchar" null="#tel eq ''#">,
                            fax = <cfqueryparam value="#fax#" cfsqltype="cf_sql_varchar" null="#fax eq ''#">,
                            delivery_company_code = <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_varchar" null="#deliveryCompanyCode eq ''#">,
                            note = <cfqueryparam value="#note#" cfsqltype="cf_sql_longvarchar" null="#Trim(note) eq ''#">,
                            use_flag = <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint">
                        WHERE supplier_id = <cfqueryparam value="#supplierId#" cfsqltype="cf_sql_integer">
                    </cfquery>

                    <cfset result["results"]["supplier_id"] = supplierId>
                    <cfset result["results"]["supplier_code"] = supplierCode>
                    <cfset result["message"] = "更新しました。">

                <cfelse>
                    <cfquery>
                        INSERT INTO m_supplier (
                            supplier_code,
                            supplier_name,
                            supplier_name_kana,
                            zip_code,
                            prefecture_code,
                            address1,
                            address2,
                            tel,
                            fax,
                            delivery_company_code,
                            note,
                            use_flag
                        ) VALUES (
                            <cfqueryparam value="#supplierCode#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#supplierName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#supplierNameKana#" cfsqltype="cf_sql_varchar" null="#supplierNameKana eq ''#">,
                            <cfqueryparam value="#zipCode#" cfsqltype="cf_sql_varchar" null="#zipCode eq ''#">,
                            <cfqueryparam value="#prefectureCode#" cfsqltype="cf_sql_varchar" null="#prefectureCode eq ''#">,
                            <cfqueryparam value="#address1#" cfsqltype="cf_sql_varchar" null="#address1 eq ''#">,
                            <cfqueryparam value="#address2#" cfsqltype="cf_sql_varchar" null="#address2 eq ''#">,
                            <cfqueryparam value="#tel#" cfsqltype="cf_sql_varchar" null="#tel eq ''#">,
                            <cfqueryparam value="#fax#" cfsqltype="cf_sql_varchar" null="#fax eq ''#">,
                            <cfqueryparam value="#deliveryCompanyCode#" cfsqltype="cf_sql_varchar" null="#deliveryCompanyCode eq ''#">,
                            <cfqueryparam value="#note#" cfsqltype="cf_sql_longvarchar" null="#Trim(note) eq ''#">,
                            <cfqueryparam value="#useFlag#" cfsqltype="cf_sql_tinyint">
                        )
                    </cfquery>

                    <cfquery name="qGetInsertedId">
                        SELECT LAST_INSERT_ID() AS new_supplier_id
                    </cfquery>

                    <cfset result["results"]["supplier_id"] = qGetInsertedId.new_supplier_id[1]>
                    <cfset result["results"]["supplier_code"] = supplierCode>
                    <cfset result["message"] = "登録しました。">
                </cfif>

            </cftransaction>

            <cfcatch type="any">
                <cflog file="HARA_TRAINING_APP" type="Error" text="取引先保存エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "保存中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>






    <cffunction name="lookupZipcode" access="remote" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {} >
        <cfset var rawBody = "" >
        <cfset var contentType = "" >
        <cfset var zipCode = "" >
        <cfset var normalizedZipCode = "" >
        <cfset var httpResult = "" >
        <cfset var apiResponse = {} >
        <cfset var firstResult = {} >
        <cfset var prefCode2 = "" >

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cfif StructKeyExists(cgi, "content_type")>
            <cfset contentType = LCase(cgi.content_type)>
        </cfif>

        <cfif Find("application/json", contentType)>
            <cftry>
                <cfset rawBody = ToString(GetHttpRequestData().content)>
                <cfif Trim(rawBody) neq "">
                    <cfset requestData = DeserializeJSON(rawBody)>
                </cfif>
                <cfcatch>
                    <cfset requestData = {} >
                </cfcatch>
            </cftry>
        </cfif>

        <cfif StructKeyExists(requestData, "zip_code")>
            <cfset zipCode = Trim(requestData.zip_code)>
        <cfelseif StructKeyExists(form, "zip_code")>
            <cfset zipCode = Trim(form.zip_code)>
        </cfif>

        <!--- ハイフン除去・数字のみ --->
        <cfset normalizedZipCode = ReReplace(zipCode, "[^0-9]", "", "all")>

        <cfif normalizedZipCode eq "">
            <cfset result["status"] = 1>
            <cfset result["message"] = "郵便番号を入力してください。">
            <cfreturn result>
        </cfif>

        <cfif Len(normalizedZipCode) neq 7>
            <cfset result["status"] = 1>
            <cfset result["message"] = "郵便番号は7桁で入力してください。">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfhttp
                url="https://zipcloud.ibsnet.co.jp/api/search?zipcode=#URLEncodedFormat(normalizedZipCode)#"
                method="get"
                result="httpResult"
                charset="utf-8"
                timeout="15">
            </cfhttp>

            <cfif NOT StructKeyExists(httpResult, "fileContent") OR Trim(httpResult.fileContent) eq "">
                <cfset result["status"] = 1>
                <cfset result["message"] = "郵便番号検索APIの応答が空です。">
                <cfreturn result>
            </cfif>

            <cfset apiResponse = DeserializeJSON(ToString(httpResult.fileContent))>

            <cfif NOT StructKeyExists(apiResponse, "status")>
                <cfset result["status"] = 1>
                <cfset result["message"] = "郵便番号検索APIの応答形式が不正です。">
                <cfreturn result>
            </cfif>

            <cfif Val(apiResponse.status) neq 200>
                <cfset result["status"] = 1>

                <cfif StructKeyExists(apiResponse, "message") AND NOT IsNull(apiResponse.message)>
                    <cfset result["message"] = apiResponse.message>
                <cfelse>
                    <cfset result["message"] = "郵便番号から住所を取得できませんでした。">
                </cfif>

                <cfreturn result>
            </cfif>

            <cfif NOT StructKeyExists(apiResponse, "results") OR IsNull(apiResponse.results) OR ArrayLen(apiResponse.results) eq 0>
                <cfset result["status"] = 1>
                <cfset result["message"] = "該当する住所が見つかりませんでした。">
                <cfreturn result>
            </cfif>

            <cfset firstResult = apiResponse.results[1]>

            <!--- prefcode を 2桁化 --->
            <cfset prefCode2 = Right("0" & firstResult.prefcode, 2)>

            <cfset result["status"] = 0>
            <cfset result["message"] = "住所を取得しました。">

            <cfset result["results"]["zip_code"] = firstResult.zipcode>
            <cfset result["results"]["prefecture_code"] = prefCode2>
            <cfset result["results"]["prefecture_name"] = firstResult.address1>
            <cfset result["results"]["address1"] = firstResult.address2 & firstResult.address3>
            <cfset result["results"]["city"] = firstResult.address2>
            <cfset result["results"]["town"] = firstResult.address3>

            <cfcatch type="any">
                <cflog file="HARA_TRAINING_APP" type="Error" text="郵便番号検索エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "郵便番号検索中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>





    <cffunction name="deleteSupplier" access="remote" returnformat="json" output="false">
        <cfset var result = {}>

        <cfset var requestData = {} >
        <cfset var rawBody = "" >
        <cfset var contentType = "" >
        <cfset var supplierId = 0>

        <cfset result["status"] = 0>
        <cfset result["message"] = "">
        <cfset result["results"] = {}>

        <cfif StructKeyExists(cgi, "content_type")>
            <cfset contentType = LCase(cgi.content_type)>
        </cfif>

        <cfif Find("application/json", contentType)>
            <cftry>
                <cfset rawBody = ToString(GetHttpRequestData().content)>
                <cfif Trim(rawBody) neq "">
                    <cfset requestData = DeserializeJSON(rawBody)>
                </cfif>
                <cfcatch>
                    <cfset requestData = {} >
                </cfcatch>
            </cftry>
        </cfif>

        <cfif StructKeyExists(requestData, "supplier_id")>
            <cfset supplierId = Val(requestData.supplier_id)>
        <cfelseif StructKeyExists(form, "supplier_id")>
            <cfset supplierId = Val(form.supplier_id)>
        </cfif>

        <cfif supplierId lte 0>
            <cfset result["status"] = 1>
            <cfset result["message"] = "取引先IDが不正です。">
            <cfreturn result>
        </cfif>

        <cftry>
            <cftransaction>

                <cfquery name="qCheckSupplier">
                    SELECT
                        supplier_id,
                        supplier_code,
                        supplier_name
                    FROM
                        m_supplier
                    WHERE
                        supplier_id = <cfqueryparam value="#supplierId#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfif qCheckSupplier.recordCount neq 1>
                    <cfset result["status"] = 1>
                    <cfset result["message"] = "削除対象データが存在しません。">
                    <cfreturn result>
                </cfif>

                <cfquery>
                    DELETE FROM
                        m_supplier
                    WHERE
                        supplier_id = <cfqueryparam value="#supplierId#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfset result["results"]["supplier_id"] = qCheckSupplier.supplier_id[1]>
                <cfset result["results"]["supplier_code"] = qCheckSupplier.supplier_code[1]>
                <cfset result["results"]["supplier_name"] = qCheckSupplier.supplier_name[1]>
                <cfset result["message"] = "削除しました。">

            </cftransaction>

            <cfcatch type="any">
                <cflog file="HARA_TRAINING_APP" type="Error" text="取引先削除エラー #cfcatch.message# #cfcatch.detail#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "削除中にエラーが発生しました。">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>
    
</cfcomponent>