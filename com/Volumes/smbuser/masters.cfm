<cfset fm_user = application.fm_user>
<cfset fm_password = application.fm_password>
<cfset only_seminar = false>
<cfif IsDefined("url.only_seminar") and url.only_seminar eq 1>
  <cfset only_seminar = true>
</cfif>

<cfscript>
    random_word = "waretemosueniawantozoomou";
    function setRandStringsToForceNumeralToString(a){
        var b = random_word & a;
        return b;
    }
    function removeRandStrings(a){
        return Replace(a, random_word, "", "ALL");
    }
</cfscript>
<cffunction name="getFmToken" access="public" returnformat="plain">
  <cfargument name="db">
  <cfset tk_url = application.fm_host & application.fm17_api_end_point & db & "/sessions">
  <!--- 認証 --->
  <cfhttp url="#tk_url#" method="post" timeout="60">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#application.fm_author#" />
      <!--- <cfhttpparam type="body" value="{}"> --->
  </cfhttp>
 
   <cftry>
      <cfset res = DeserializeJSON(cfhttp.fileContent)>
      <cfset token = res.response.token>
      <cfcatch type="Any">
        <cflog type="error" file="jpi_error" text="MasterGet認証エラー---#now()#error_code:#cfhttp.fileContent#">
      </cfcatch>
    </cftry>

  <cfreturn "Bearer " & token>


</cffunction>


<cfif !only_seminar>

  <!--- 大分類ゲット --->
  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "LargeAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>

<!--- /fmi/data/v1/databases/:database/layouts/:layout/_find --->
  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_large_category,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_large_category,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>

  <!--- 
  絞り込みの形式はこんな感じ↓↓
    {"query": [ {"FileMaker更新日": ">12/31/2017"},{"FileMaker更新日": "=12/31/2017","FileMaker更新時刻":">03:00"}]} 

  --->

  <cfset cond1["FileMaker更新日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["FileMaker更新日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["FileMaker更新時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#serializeJSON(query)#">
  </cfhttp>
  <cfset res = DeserializeJSON(httpResp.fileContent)>

  <!--- 
  エラー系のレスポンス例↓↓
    {"message": [{code:501,message:"Time value does not meet validation entry options"}],"response":""} 

  --->


  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_large_category
            (
            large_category_id,
            large_category_name,
            update_date                
            )VALUES(
            #dt["分野CD"]#,
            '#dt["分野名"]#',                  
            now()
            )ON DUPLICATE KEY UPDATE
            large_category_id = VALUES(large_category_id),
            large_category_name = VALUES(large_category_name),
            update_date = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_large_category---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
      
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_large_category = now()
    </cfquery>
  <cfelse>
  </cfif>



  <!--- 
  "分野明細WebCD": "46",
  "分野明細Web名": "その他",
  "分野CD": "12",
  "作成日": "",
  "修正日": "03/14/2018",
  "作成時刻": "",
  "修正時刻": "" 
  --->


  <!--- 中分類ゲット --->
  <cfset fm_db              = "JPI_Master" >
  <cfset layout               = "MiddleAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>



  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_middle_category,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_middle_category,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>


  <cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#serializeJSON(query)#">
  </cfhttp>
  <cfset res = DeserializeJSON(httpResp.fileContent)>
  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_middle_category
            (
            large_category_id,
            middle_category_id,
            middle_category_name,
            update_date                
            )VALUES(
            #dt["分野CD"]#,
            <cfif dt["分野明細WebCD"] neq "">'#dt["分野明細WebCD"]#',<cfelse>NULL,</cfif>
            <cfif dt["分野明細Web名"] neq "">'#dt["分野明細Web名"]#',<cfelse>NULL,</cfif>                  
            now()
            )ON DUPLICATE KEY UPDATE
            large_category_id = VALUES(large_category_id),
            middle_category_id = VALUES(middle_category_id),
            middle_category_name = VALUES(middle_category_name),
            update_date = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_middle_category---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_middle_category = now()
    </cfquery>
  <cfelse>
    <cflog type="error" file="jpi_error" text="Middle Category Get Error---Code:#res.messages[1].code#--Message:#res.messages[1].message#---#now()#">
  </cfif>


  <!--- 
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

  参加費種別マスターゲット 

  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  --->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "FeeTypeAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>


  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_fee_category,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_fee_category,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>


  <cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#serializeJSON(query)#">
  </cfhttp>
  <cfset res = DeserializeJSON(httpResp.fileContent)>



  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_fee_category
            (
            fee_category_id,
            fee_category_name,
            content,
            design_for,
            fellow,
            statement,
            update_date                
            )VALUES(
            #dt["SEQ"]#,
            <cfif dt["参加費種別"] neq "">'#dt["参加費種別"]#',<cfelse>NULL,</cfif>
            <cfif dt["内容"] neq "">'#dt["内容"]#',<cfelse>NULL,</cfif>
            <cfif dt["官民"] neq "">'#dt["官民"]#',<cfelse>NULL,</cfif>
            <cfif dt["F同行"] neq "">#dt["F同行"]#,<cfelse>NULL,</cfif>
            <cfif dt["Web用表示文言"] neq "">'#dt["Web用表示文言"]#',<cfelse>NULL,</cfif>                  
            now()
            )ON DUPLICATE KEY UPDATE
            fee_category_id = VALUES(fee_category_id),
            fee_category_name = VALUES(fee_category_name),
            content = VALUES(content),
            design_for = VALUES(design_for),
            fellow = VALUES(fellow),
            statement = VALUES(statement),
            update_date = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_fee_category---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_fee_category = now()
    </cfquery>
  <cfelse>
  </cfif>





  <!--- 
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

  参加費マスターゲット 

  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  --->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "FeeAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>


  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_fee,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_fee,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>


  <cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#serializeJSON(query)#">
  </cfhttp>
  <cfset res = DeserializeJSON(httpResp.fileContent)>


  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_fee
            (
            fee_id,
            fee_category_id,
            participant_num,
            fee,
            update_date                
            )VALUES(
            #dt["SEQ"]#,
            <cfif dt["参加費種別ID"] neq "">#dt["参加費種別ID"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加人数"] neq "">#dt["参加人数"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加費"] neq "">#dt["参加費"]#,<cfelse>NULL,</cfif>                 
            now()
            )ON DUPLICATE KEY UPDATE
            fee_id = VALUES(fee_id),
            fee_category_id = VALUES(fee_category_id),
            participant_num = VALUES(participant_num),
            fee = VALUES(fee),
            update_date = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_fee---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_fee = now()
    </cfquery>
  <cfelse>
  </cfif>







  <!--- 
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

  顧客マスターゲット 

  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  --->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "ClientAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>





  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_client,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_client,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>


  <cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfset query["limit"]        = setRandStringsToForceNumeralToString(30000)>
  <!--- <cfset query["range"]        = setRandStringsToForceNumeralToString(20000)> --->
  <cfset query["offset"]      = setRandStringsToForceNumeralToString(1)>
  <cfset query = serializeJSON(query)>
  <cfset query = removeRandStrings(query)>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#query#">
  </cfhttp>
  <cftry>
    <cfset res = DeserializeJSON(httpResp.fileContent)>
    <cfcatch type="Any">
      <cflog type="error" file="jpi_error" text="ClientAPIエラー---#now()#error_code:#res.messages[1].code#---error_message：#res.messages[1].message#">
    </cfcatch>
  </cftry>
  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_client
            (
              client_code,
              last_name,
              last_name_kana,
              company_name,
              company_name_kana,
              department,
              post,
              email,
              zip_code,
              prefecture,
              address1,
              address2,
              phone,
              fax,
              info_mail_flag,
              name_b,
              name_kana_b,
              company_b,
              company_kana_b,
              department_b,
              post_b,
              zip_code_b,
              prefecture_b,
              address1_b,
              address2_b,
              phone_b,
              fax_b,
              email_b,
              note_b,
              note,
              fm_record_id,
              status,
              create_date

            )VALUES(
            #dt["SEQ"]#,
            <cfif dt["顧客名"] neq "">REPLACE(REPLACE('#dt["顧客名"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["顧客名フリガナ"] neq "">REPLACE(REPLACE('#dt["顧客名フリガナ"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["会社名"] neq "">REPLACE(REPLACE('#Left(dt["会社名"],60)#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["会社名フリガナ"] neq "">REPLACE(REPLACE('#Left(dt["会社名フリガナ"],120)#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["部署"] neq "">REPLACE(REPLACE('#dt["部署"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["役職"] neq "">REPLACE(REPLACE('#dt["役職"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["Email"] neq "">REPLACE(REPLACE('#dt["Email"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["郵便番号1"] neq "" and dt["郵便番号2"] neq "">REPLACE(REPLACE('#dt["郵便番号1"]##dt["郵便番号2"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["都道府県名"] neq "">REPLACE(REPLACE('#dt["都道府県名"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["住所1"] neq "">REPLACE(REPLACE('#dt["住所1"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["住所2"] neq "">REPLACE(REPLACE('#dt["住所2"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["TEL"] neq "">REPLACE(REPLACE('#dt["TEL"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["FAX"] neq "">REPLACE(REPLACE('#dt["FAX"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["メルマガ配信"] neq "">REPLACE(REPLACE('#dt["メルマガ配信"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先氏名"] neq "">REPLACE(REPLACE('#dt["請求先氏名"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先氏名フリガナ"] neq "">REPLACE(REPLACE('#dt["請求先氏名フリガナ"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先会社名"] neq "">REPLACE(REPLACE('#dt["請求先会社名"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先会社名フリガナ"] neq "">REPLACE(REPLACE('#dt["請求先会社名フリガナ"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先部署"] neq "">REPLACE(REPLACE('#dt["請求先部署"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先役職"] neq "">REPLACE(REPLACE('#dt["請求先役職"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先郵便番号1"] neq "" and dt["請求先郵便番号2"] neq "">REPLACE(REPLACE('#dt["請求先郵便番号1"]##dt["請求先郵便番号2"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先都道府県名"] neq "">REPLACE(REPLACE('#dt["請求先都道府県名"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先住所1"] neq "">REPLACE(REPLACE('#dt["請求先住所1"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先住所2"] neq "">REPLACE(REPLACE('#dt["請求先住所2"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先TEL"] neq "">REPLACE(REPLACE('#dt["請求先TEL"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先FAX"] neq "">REPLACE(REPLACE('#dt["請求先FAX"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先Email"] neq "">REPLACE(REPLACE('#dt["請求先Email"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["請求先備考"] neq "">REPLACE(REPLACE('#dt["請求先備考"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["備考"] neq "">REPLACE(REPLACE('#dt["備考"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            <cfif dt["レコードID"] neq "">REPLACE(REPLACE('#dt["レコードID"]#','\r',''), ',', ''),<cfelse>NULL,</cfif>
            1,
            now()
            )ON DUPLICATE KEY UPDATE
             client_code    = VALUES(client_code),
             last_name      = VALUES(last_name),
             last_name_kana = VALUES(last_name_kana),
             company_name   = VALUES(company_name),
             company_name_kana = VALUES(company_name_kana),
             department     = VALUES(department),
             post           = VALUES(post),
             email          = VALUES(email),
             zip_code       = VALUES(zip_code),
             prefecture     = VALUES(prefecture),
             address1       = VALUES(address1),
             address2       = VALUES(address2),
             phone          = VALUES(phone),
             fax            = VALUES(fax),
             info_mail_flag = VALUES(info_mail_flag),
             name_b         = VALUES(name_b),
             name_kana_b    = VALUES(name_kana_b),
             company_b      = VALUES(company_b),
             company_kana_b      = VALUES(company_kana_b),
             department_b   = VALUES(department_b),
             post_b         = VALUES(post_b),
             zip_code_b     = VALUES(zip_code_b),
             prefecture_b   = VALUES(prefecture_b),
             address1_b     = VALUES(address1_b),
             address2_b     = VALUES(address2_b),
             phone_b        = VALUES(phone_b),
             fax_b          = VALUES(fax_b),
             email_b        = VALUES(email_b),
             note_b         = VALUES(note_b),
             note           = VALUES(note),
             fm_record_id   = VALUES(fm_record_id),
             status         = VALUES(status),
             update_date    = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_client---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_client = now()
    </cfquery>
  <cfelse>
    <cflog type="error" file="jpi_error" text="ClientAPIエラー---#now()#error_code:#res.messages[1].code#---error_message：#res.messages[1].message#">
  </cfif>





  <!--- 
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

  社員マスターゲット 

  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  --->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "EmployeeAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>


  <!--- ここからはトークンをもとにデータをゲット --->
  <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
  <cfset layout_url   = base_url & "/" & fm_file>
  <cfset query        = {}>
  <cfset query_array  = []>
  <cfset cond1 = {}>
  <cfset cond2 = {}>

  <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
  <cfquery name="qGetLastUpdate">
    SELECT DATE_FORMAT(CAST(IFNULL(m_fee,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
           DATE_FORMAT(IFNULL(m_fee,'1900/12/31 00:00'), '%H:%i') l_time 
      FROM t_last_update
  </cfquery>


  <cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
  <cfset ArrayAppend(query_array, cond1)>

  <cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
  <cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
  <cfset ArrayAppend(query_array, cond2)>
  <cfset query["query"] = query_array>

  <cfhttp url="#layout_url#" method="post" result="httpResp">
      <cfhttpparam type="header" name="Content-Type" value="application/json" />
      <cfhttpparam type="header" name="Authorization" value="#token#" />
      <cfhttpparam type="body" value="#serializeJSON(query)#">
  </cfhttp>
  <cfset res = DeserializeJSON(httpResp.fileContent)>
  <cfif res.messages[1].code eq 0>
    <cfset record_count = ArrayLen(res.response.data)>
    <cfloop index="i" from="1" to="#record_count#">
      <cfset dt = res.response.data[i].fieldData>
      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_emp
            (
            fm_seq_no,
            emp_code,
            department,
            post,
            last_name,
            password,
            fm_fstate,
            fm_fplanner,
            fm_fadmin,
            fm_fassistant,
            update_date                
            )VALUES(
            #dt["SEQ"]#,
            <cfif dt["社員番号"] neq "">'#dt["社員番号"]#',<cfelse>NULL,</cfif>
            <cfif dt["部署"] neq "">'#dt["部署"]#',<cfelse>NULL,</cfif>
            <cfif dt["役職"] neq "">'#dt["役職"]#',<cfelse>NULL,</cfif>                 
            <cfif dt["氏名"] neq "">'#dt["氏名"]#',<cfelse>NULL,</cfif>                 
            <cfif dt["ログインパスワード"] neq "">'#dt["ログインパスワード"]#',<cfelse>NULL,</cfif>                 
            <cfif dt["F在籍"] neq "">#dt["F在籍"]#,<cfelse>NULL,</cfif>                 
            <cfif dt["F企画者"] neq "">#dt["F企画者"]#,<cfelse>NULL,</cfif>
            <cfif dt["F管理者権限"] neq "">#dt["F管理者権限"]#,<cfelse>NULL,</cfif>
            <cfif dt["Fアシスタント"] neq "">#dt["Fアシスタント"]#,<cfelse>NULL,</cfif>                 
            now()
            )ON DUPLICATE KEY UPDATE
            emp_code = VALUES(emp_code),
            department = VALUES(department),
            post = VALUES(post),
            last_name = VALUES(last_name),
            password = VALUES(password),
            fm_fstate = VALUES(fm_fstate),
            fm_fplanner = VALUES(fm_fplanner),
            fm_fadmin = VALUES(fm_fadmin),
            fm_fassistant = VALUES(fm_fassistant),
            update_date = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_emp---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>    
    </cfloop>
    <cfquery name="updLastUpd">
      UPDATE t_last_update SET m_emp = now()
    </cfquery>
  <cfelse>
    <cflog type="error" file="jpi_error" text="m_emp---#now()#データ取得エラー：#res.messages[1].message#">
  </cfif>






</cfif> <!--- セミナーだけのゲットじゃなかったら --->


<!--- 
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

会場マスターテーブルゲット 

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
--->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "PlaceAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>



<!--- ここからはトークンをもとにデータをゲット --->
<cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
<cfset layout_url   = base_url & "/" & fm_file>
<cfset query        = {}>
<cfset query_array  = []>
<cfset cond1 = {}>
<cfset cond2 = {}>

<!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
<cfquery name="qGetLastUpdate">
  SELECT DATE_FORMAT(CAST(IFNULL(m_place,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
         DATE_FORMAT(IFNULL(m_place,'1900/12/31 00:00'), '%H:%i') l_time 
    FROM t_last_update
</cfquery>


<cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
<cfset ArrayAppend(query_array, cond1)>

<cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
<cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
<cfset ArrayAppend(query_array, cond2)>
<cfset query["query"] = query_array>

<cfhttp url="#layout_url#" method="post" result="httpResp">
    <cfhttpparam type="header" name="Content-Type" value="application/json" />
    <cfhttpparam type="header" name="Authorization" value="#token#" />
    <cfhttpparam type="body" value="#serializeJSON(query)#">
</cfhttp>
<cfset res = DeserializeJSON(httpResp.fileContent)>
<cfif res.messages[1].code eq 0>
  <cfset record_count = ArrayLen(res.response.data)>
  <cfloop index="i" from="1" to="#record_count#">
    <cfset dt = res.response.data[i].fieldData>
    <cftry>
      <cfquery name="qInsMaster">
          INSERT INTO m_place
          (
          place_id,
          place_name,
          place_name_web,
          zip_code,
          prefecture_id,
          prefecture_name,
          address1,
          address2,
          phone,
          fax,
          place_url,
          route,
          update_date                
          )VALUES(
          #dt["SEQ"]#,
          <cfif dt["会場名"] neq "">'#dt["会場名"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場名Web用"] neq "">'#dt["会場名Web用"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場郵便番号"] neq "">'#dt["会場郵便番号"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場都道府県CD"] neq "">#dt["会場都道府県CD"]#,<cfelse>NULL,</cfif>
          <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場住所1"] neq "">'#dt["会場住所1"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場住所2"] neq "">'#dt["会場住所2"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場TEL"] neq "">'#dt["会場TEL"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場FAX"] neq "">'#dt["会場FAX"]#',<cfelse>NULL,</cfif>
          <cfif dt["会場URL"] neq "">'#dt["会場URL"]#',<cfelse>NULL,</cfif>
          <cfif dt["道順"] neq "">'#dt["道順"]#',<cfelse>NULL,</cfif> 
          now()
          )ON DUPLICATE KEY UPDATE
          place_id       = VALUES(place_id),
          place_name     = VALUES(place_name),
          place_name_web = VALUES(place_name_web),
          zip_code       = VALUES(zip_code),
          prefecture_id  = VALUES(prefecture_id),
          prefecture_name = VALUES(prefecture_name),
          address1       = VALUES(address1),
          address2       = VALUES(address2),
          phone          = VALUES(phone),
          fax            = VALUES(fax),
          place_url      = VALUES(place_url),
          route          = VALUES(route),
          update_date    = now()
      </cfquery>
      <cfcatch type="Database">
          <cflog type="error" file="jpi_error" text="m_place---#now()#SQLエラー：#cfcatch.queryError#">
          <cfcontinue>
      </cfcatch>            
    </cftry>    
  </cfloop>
  <cfquery name="updLastUpd">
    UPDATE t_last_update SET m_place = now()
  </cfquery>
<cfelse>
</cfif>





<!--- 
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

テーママスターゲット 

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
--->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "TemabAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>



<!--- ここからはトークンをもとにデータをゲット --->
<cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
<cfset layout_url   = base_url & "/" & fm_file>
<cfset query        = {}>
<cfset query_array  = []>
<cfset cond1 = {}>
<cfset cond2 = {}>

<!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
<cfquery name="qGetLastUpdate">
  SELECT DATE_FORMAT(CAST(IFNULL(m_theme,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
         DATE_FORMAT(IFNULL(m_theme,'1900/12/31 00:00'), '%H:%i') l_time 
    FROM t_last_update
</cfquery>


<cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
<cfset ArrayAppend(query_array, cond1)>

<cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
<cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
<cfset ArrayAppend(query_array, cond2)>
<cfset query["query"] = query_array>

<cfhttp url="#layout_url#" method="post" result="httpResp">
    <cfhttpparam type="header" name="Content-Type" value="application/json" />
    <cfhttpparam type="header" name="Authorization" value="#token#" />
    <cfhttpparam type="body" value="#serializeJSON(query)#">
</cfhttp>
<cfset res = DeserializeJSON(httpResp.fileContent)>
<cfif res.messages[1].code eq 0>
  <cfset record_count = ArrayLen(res.response.data)>
  <cfloop index="i" from="1" to="#record_count#">
    <cfset dt = res.response.data[i].fieldData>
    <cftry>
      <cfquery name="qInsMaster">
          INSERT INTO m_theme
          (
          theme_id,
          theme,
          update_date                
          )VALUES(
          #dt["d_no"]#,
          <cfif dt["大分類テーマ名"] neq "">'#dt["大分類テーマ名"]#',<cfelse>NULL,</cfif>
          now()
          )ON DUPLICATE KEY UPDATE
          theme_id       = VALUES(theme_id),
          theme     = VALUES(theme),
          update_date    = now()
      </cfquery>
      <cfcatch type="Database">
          <cflog type="error" file="jpi_error" text="m_theme---#now()#SQLエラー：#cfcatch.queryError#">
          <cfcontinue>
      </cfcatch>            
    </cftry>    
  </cfloop>
  <cfquery name="updLastUpd">
    UPDATE t_last_update SET m_theme = now()
  </cfquery>
<cfelse>
</cfif>



<!--- 



<!--- 
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

セミナー講演者マッピングテーブルゲット 

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
--->

<cfset fm_db                = "JPI_SeminarData" >
<cfset layout               = "RequestAPI" >
<cfset base_url             = application.fm_host & application.fm17_api_end_point>
<cfset token                = getFmToken(fm_db)>



<!--- ここからはトークンをもとにデータをゲット --->
<cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
<cfset layout_url  = base_url & "/" & fm_file>
<cfset query       = {}>
<cfset query_array = []>
<cfset cond1       = {}>
<cfset cond2       = {}>
<cfset confirm     = {}>

<!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
<cfquery name="qGetLastUpdate">
  SELECT DATE_FORMAT(CAST(IFNULL(t_seminar_speaker_mapping,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
         DATE_FORMAT(IFNULL(t_seminar_speaker_mapping,'1900/12/31 00:00'), '%H:%i') l_time 
    FROM t_last_update
</cfquery>

<!--- {"query": [ { "F確定": "1"]} --->


<!--- <cfset confirm["F確定"] = 1>
<cfset ArrayAppend(query_array, confirm)> --->


<cfset cond1["F確定"] =  ">=" &  1>
<cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
<cfset ArrayAppend(query_array, cond1)>

<cfset cond2["F確定"] =  ">=" &  1>
<cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
<cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
<cfset ArrayAppend(query_array, cond2)>

<cfset query["query"] = query_array>
<!--- <cfset query["range"]        = setRandStringsToForceNumeralToString(20000)> --->
<cfset query["limit"]        = setRandStringsToForceNumeralToString(20000)>
<cfset query["offset"]      = setRandStringsToForceNumeralToString(1)>
<cfset query = serializeJSON(query)>
<cfset query = removeRandStrings(query)>
<cfhttp url="#layout_url#" method="post" result="httpResp">
    <cfhttpparam type="header" name="Content-Type" value="application/json" />
    <cfhttpparam type="header" name="Authorization" value="#token#" />
    <cfhttpparam type="body" value="#query#">
</cfhttp>
<cfset res = DeserializeJSON(httpResp.fileContent)>
 <!--- <cflog type="error" file="jpi_error" text="#ArrayLen(res.response.data)#"> --->
<cfset sort_order = 1>
<cfset prev_seminar = "">

<cfif res.messages[1].code eq 0>

<cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---#ArrayLen(res.response.data)#">
  <cfset record_count = ArrayLen(res.response.data)>
  <cfloop index="i" from="1" to="#record_count#">


    <cfset dt = res.response.data[i].fieldData>
<!---     <cfif i neq 1>
      <cfset prev_seminar = res.data[i - 1].fieldData["セミナーNO"]>
      <cfif dt["セミナーNO"] eq prev_seminar>
        <cfset sort_order = sort_order + 1>
      <cfelse>
         <cfset sort_order = 1>
         <cfquery name="qGetNewSortOrder">
           SELECT MAX(IFNULL(sort_order,0)) + 1 AS new_sort_order FROM t_seminar_speaker_mapping WHERE seminar_code = '#dt["セミナーNO"]#'
         </cfquery>
         <cfif qGetNewSortOrder.new_sort_order neq "">
           <cfset sort_order = qGetNewSortOrder.new_sort_order>
         </cfif>
      </cfif>
    </cfif> --->
    <cftry>
      <cfquery name="qGetSeminarMapping">
        SELECT seminar_code
          FROM t_seminar_speaker_mapping
         WHERE seminar_code = '#dt["セミナーNO"]#'
           AND speaker_code = '#dt["講師No"]#'
      </cfquery>
      <cfcatch type="Database">
          <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---qGetSeminarMapping#now()#SQLエラー：#cfcatch.queryError#">
          <cfcontinue>
      </cfcatch> 
    </cftry>
    <cfif qGetSeminarMapping.Recordcount GTE 1>
      <cftry>
        <cfquery name="qUpSeminarMap">
          UPDATE t_seminar_speaker_mapping
             SET seminar_code = '#dt["セミナーNO"]#',
              speaker_code = <cfif dt["講師No"] neq "">'#dt["講師No"]#',<cfelse>NULL,</cfif>
              name = <cfif dt["講師名"] neq "">'#dt["講師名"]#',<cfelse>NULL,</cfif>
              name_kana = <cfif dt["講師フリガナ"] neq "">'#dt["講師フリガナ"]#',<cfelse>NULL,</cfif>
              company_name = <cfif dt["会社名"] neq "">'#dt["会社名"]#',<cfelse>NULL,</cfif>
              <!--- <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif> --->
              department = <cfif dt["部署"] neq "">'#dt["部署"]#',<cfelse>NULL,</cfif>
              post = <cfif dt["役職"] neq "">'#dt["役職"]#',<cfelse>NULL,</cfif>
              biography = <cfif dt["講師略歴"] neq "">'#dt["講師略歴"]#',<cfelse>NULL,</cfif>
              note = <cfif dt["講師備考"] neq "">'#dt["講師備考"]#',<cfelse>NULL,</cfif>
              file_name = <cfif dt["講師画像名"] neq "">'#dt["講師画像名"]#',<cfelse>NULL,</cfif>
              update_date = now()
         WHERE seminar_code = '#dt["セミナーNO"]#'
           AND speaker_code = '#dt["講師No"]#' 
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---qUpSeminarMap#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch> 
      </cftry>      
    <cfelse>
      <cfquery name="qGetNewSortOrder">
       SELECT MAX(IFNULL(t_seminar_speaker_mapping.sort_order,0)) + 1 AS new_sort_order FROM t_seminar_speaker_mapping WHERE seminar_code = '#dt["セミナーNO"]#'
      </cfquery>
     <cfset sort_order = 1>
     <cfif qGetNewSortOrder.new_sort_order neq "">
       <cfset sort_order = qGetNewSortOrder.new_sort_order>
     </cfif>      
      <cftry>
      <cfquery name="qInsSeminarMap">

            INSERT INTO t_seminar_speaker_mapping
            (
            seminar_code,
            speaker_code,
            name,
            name_kana,
            company_name,
            department,
            post,
            biography,
            note,
            file_name,
            sort_order,
            update_date                
            )VALUES(
            '#dt["セミナーNO"]#',
            <cfif dt["講師No"] neq "">'#dt["講師No"]#',<cfelse>NULL,</cfif>
            <cfif dt["講師名"] neq "">'#dt["講師名"]#',<cfelse>NULL,</cfif>
            <cfif dt["講師フリガナ"] neq "">'#dt["講師フリガナ"]#',<cfelse>NULL,</cfif>
            <cfif dt["会社名"] neq "">'#dt["会社名"]#',<cfelse>NULL,</cfif>
            <!--- <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif> --->
            <cfif dt["部署"] neq "">'#dt["部署"]#',<cfelse>NULL,</cfif>
            <cfif dt["役職"] neq "">'#dt["役職"]#',<cfelse>NULL,</cfif>
            <cfif dt["講師略歴"] neq "">'#dt["講師略歴"]#',<cfelse>NULL,</cfif>
            <cfif dt["講師備考"] neq "">'#dt["講師備考"]#',<cfelse>NULL,</cfif>
            <cfif dt["講師画像名"] neq "">'#dt["講師画像名"]#',<cfelse>NULL,</cfif>
            #sort_order#,
            now()
            )
      </cfquery>  
      <cfcatch type="Database">
          <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---qInsSeminarMap#now()#SQLエラー：#cfcatch.queryError#">
          <cfcontinue>
      </cfcatch> 
    </cftry>    
    </cfif>
<!--- 
    <cftry>
      
      <cfquery name="qInsMaster">
          INSERT INTO t_seminar_speaker_mapping
          (
          seminar_code,
          speaker_code,
          name,
          name_kana,
          company_name,
          department,
          post,
          biography,
          note,
          file_name,
          sort_order,
          update_date                
          )VALUES(
          '#dt["セミナーNO"]#',
          <cfif dt["講師No"] neq "">'#dt["講師No"]#',<cfelse>NULL,</cfif>
          <cfif dt["講師名"] neq "">'#dt["講師名"]#',<cfelse>NULL,</cfif>
          <cfif dt["講師フリガナ"] neq "">'#dt["講師フリガナ"]#',<cfelse>NULL,</cfif>
          <cfif dt["会社名"] neq "">'#dt["会社名"]#',<cfelse>NULL,</cfif>
          <!--- <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif> --->
          <cfif dt["部署"] neq "">'#dt["部署"]#',<cfelse>NULL,</cfif>
          <cfif dt["役職"] neq "">'#dt["役職"]#',<cfelse>NULL,</cfif>
          <cfif dt["講師略歴"] neq "">'#dt["講師略歴"]#',<cfelse>NULL,</cfif>
          <cfif dt["講師備考"] neq "">'#dt["講師備考"]#',<cfelse>NULL,</cfif>
          <cfif dt["講師画像名"] neq "">'#dt["講師画像名"]#',<cfelse>NULL,</cfif>
          #sort_order#,
          now()
          )ON DUPLICATE KEY UPDATE
          seminar_code   = VALUES(seminar_code),
          speaker_code = VALUES(speaker_code),
          name         = VALUES(name),
          name_kana    = VALUES(name_kana),
          company_name = VALUES(company_name),
          department   = VALUES(department),
          post         = VALUES(post),
          biography    = VALUES(biography),
          note         = VALUES(note),
          file_name    = VALUES(file_name),
          sort_order    = VALUES(sort_order),
          update_date  = now()
      </cfquery>

      <cfcatch type="Database">
          <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---#now()#SQLエラー：#cfcatch.queryError#">
          <cfcontinue>
      </cfcatch>            
    </cftry>  
     --->  
  </cfloop>
  <cfquery name="updLastUpd">
    UPDATE t_last_update SET t_seminar_speaker_mapping = now()
  </cfquery>
<cfelse>
</cfif>


 --->

<!--- セミナーマスターゲット --->

<cfset fm_db                = "JPI_SeminarData" >
<cfset layout               = "SeminarAPI" >
<cfset base_url             = application.fm_host & application.fm17_api_end_point>
<cfset token                = getFmToken(fm_db)>


<!--- ここからはトークンをもとにデータをゲット --->
<cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
<cfset layout_url  = base_url & "/" & fm_file>
<cfset query       = {}>
<cfset query_array = []>
<cfset cond1       = {}>
<cfset cond2       = {}>
<cfset confirm     = {}>
<cfset sort = {}>
<cfset sort_arr = []>
<cfset sort_contents = {}>

<!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
<cfquery name="qGetLastUpdate">
  SELECT DATE_FORMAT(CAST(IFNULL(m_seminar,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
         DATE_FORMAT(IFNULL(m_seminar,'1900/12/31 00:00'), '%H:%i') l_time 
    FROM t_last_update
</cfquery>

<!--- 現在の追加料金をゲット --->
<!--- 
<cfquery name="qGetAddFee">
  SELECT IFNULL(cur_add_fee,0) cur_add_fee,
         IFNULL(cur_add_fee_cnt,0) cur_add_fee_cnt,
         step_amount,
         max_cnt 
    FROM m_admin
</cfquery>

<cfset add_fee = qGetAddFee.cur_add_fee>
<cfset fee_cnt = qGetAddFee.cur_add_fee_cnt>
<cfset max_cnt = qGetAddFee.max_cnt>
<cfset step_amount = qGetAddFee.step_amount> 
--->
<cfset is_new_sem = false>





<!--- {"query": [ { "F決定": "1"}]} --->


<!--- <cfset confirm["F決定"] = "=" & 1>
<cfset ArrayAppend(query_array, confirm)> --->

<!--- ソート --->
<!--- "sort" : [ { "fieldName": "LastName", "sortOrder": "ascend" }, { "fieldName": "FirstName", "sortOrder": "ascend" } ] --->

<!--- <cfset cond1["開催日"] = ">" & '10/28/2018'> --->

<cfset cond1["F公開"] = ">=" &  1>
<cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
<cfset ArrayAppend(query_array, cond1)>

<cfset cond2["F公開"] = ">=" &  1>
<cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
<cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
<cfset ArrayAppend(query_array, cond2)>

<cfset sort_contents["fieldName"] = "セミナーNO">
<cfset sort_contents["sortOrder"] = "ascend">
<cfset ArrayAppend(sort_arr, sort_contents)>

<cfset query["query"] = query_array>
<!--- <cfset query["range"]        = setRandStringsToForceNumeralToString(20000)> --->
<cfset query["limit"]        = setRandStringsToForceNumeralToString(20000)>
<cfset query["offset"]      = setRandStringsToForceNumeralToString(1)>
<cfset query = serializeJSON(query)>
<cfset query = removeRandStrings(query)>

<cfset sort["sort"] = sort_arr>
<cfhttp url="#layout_url#" method="post" result="httpResp">
    <cfhttpparam type="header" name="Content-Type" value="application/json" />
    <cfhttpparam type="header" name="Authorization" value="#token#" />
    <cfhttpparam type="body" value="#query#">
</cfhttp>
<cfset res = DeserializeJSON(httpResp.fileContent)>
<cfif res.messages[1].code eq 0>
  <cfset record_count = ArrayLen(res.response.data)>

  <cfquery name="qGetLectureStyle">
    SELECT lecture_style_id FROM m_lecture_style WHERE archive_flag = 1
  </cfquery>
  <cfset ls_list = ValueList(qGetLectureStyle.lecture_style_id)>
  <cfloop index="i" from="1" to="#record_count#">
    <!--- <cfset is_new_sem = false> --->
    <cfset dt = res.response.data[i].fieldData>
    <cfif dt["セミナーNO"] neq "">
<!---       <cfquery name="qGetSeminar">
        SELECT seminar_code FROM m_seminar WHERE seminar_code = '#dt["セミナーNO"]#'
      </cfquery>
      <cfif qGetSeminar.RecordCount LT 1>
        <cfset is_new_sem = true>
      </cfif> --->
      <cfset unlimit = 0>
      <cfif dt["受講方法CD"] neq "" and qGetLectureStyle.RecordCount gte 1 and dt["掲載停止F"] neq 1>
        <cfloop index="li" from="1" to="#qGetLectureStyle.RecordCount#">
          <cfif ListFind(dt["受講方法CD"],qGetLectureStyle.lecture_style_id[li]) GTE 1>
            <cfset unlimit = 1>
            <cfbreak>
          </cfif>
        </cfloop>
      </cfif>

      <cftry>
        <cfquery name="qInsMaster" result="ins_m_seminar_result">
            INSERT INTO m_seminar
            (
            seminar_code,
            event_date,
            start_time,
            end_time,
            main_theme,
            sub_theme,
            sub_theme2,
            title1,
            title2,
            title3,
            title4,
            title_live,
            title_archive,
            description1,
            description2,
            description3,
            description4,
            description_live,
            description_archive,         
            place_id,
            <!--- entry_fee_code, --->
            fee_category_id,
            publication_date,
            public_flag,
            seminar_status,
            promoter,
            large_category_id1,
            large_category_id2,
            large_category_id3,
            large_category_id4,
            large_category_id5,
            large_category_id6,
            large_category_id7,
            large_category_id8,
            large_category_id9,
            large_category_id10,
            middle_category_id1,
            middle_category_id2,
            middle_category_id3,
            middle_category_id4,
            middle_category_id5,
            middle_category_id6,
            middle_category_id7,
            middle_category_id8,
            middle_category_id9,
            middle_category_id10,
            theme_id1,
            theme_id2,
            theme_id3,
            fee1,
            fee2,
            fee3,
            fee4,
            add_fee,
            fee_note,
            hp_registered_date,
            hp_registered_time,
            fm_fpub,
            personnel,
            lecture_style_list,
            unlimited_publicable_flag,
            update_date                
            )VALUES(
            <cfif dt["セミナーNO"] neq "">'#dt["セミナーNO"]#',<cfelse>NULL,</cfif>
            <cfif dt["開催日"] neq "">STR_TO_DATE('#dt["開催日"]#', '%m/%d/%Y'),<cfelse>NULL,</cfif> 
            <cfif dt["開催日"] neq "" and dt["開始時間"] neq "">CONCAT(DATE_FORMAT(STR_TO_DATE('#dt["開催日"]#', '%m/%d/%Y'),'%Y/%m/%d'),' #dt["開始時間"]#'),<cfelse>NULL,</cfif>
            <cfif dt["開催日"] neq "" and dt["終了時間"] neq "">CONCAT(DATE_FORMAT(STR_TO_DATE('#dt["開催日"]#', '%m/%d/%Y'),'%Y/%m/%d'),' #dt["終了時間"]#'),<cfelse>NULL,</cfif>
            <cfif dt["セミナータイトル"] neq "">'#dt["セミナータイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["サブテーマ"] neq "">'#dt["サブテーマ"]#',<cfelse>NULL,</cfif>
            <!--- <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif> --->
            <cfif dt["サブテーマ2"] neq "">'#dt["サブテーマ2"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目1_タイトル"] neq "">'#dt["講義項目1_タイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目2_タイトル"] neq "">'#dt["講義項目2_タイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目3_タイトル"] neq "">'#dt["講義項目3_タイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目4_タイトル"] neq "">'#dt["講義項目4_タイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["ライブ受講タイトル"] neq "">'#dt["ライブ受講タイトル"]#',<cfelse>NULL,</cfif>
            <cfif StructKeyExists(dt,"アーカイブ受講タイトル") and dt["アーカイブ受講タイトル"] neq "">'#dt["アーカイブ受講タイトル"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目1"] neq "">'#dt["講義項目1"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目2"] neq "">'#dt["講義項目2"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目3"] neq "">'#dt["講義項目3"]#',<cfelse>NULL,</cfif>
            <cfif dt["講義項目4"] neq "">'#dt["講義項目4"]#',<cfelse>NULL,</cfif>
            <cfif dt["ライブ受講内容"] neq "">'#dt["ライブ受講内容"]#',<cfelse>NULL,</cfif>
            <cfif StructKeyExists(dt,"アーカイブ受講内容") and  dt["アーカイブ受講内容"] neq "">'#dt["アーカイブ受講内容"]#',<cfelse>NULL,</cfif>
            <cfif dt["会場CD"] neq "">#dt["会場CD"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加費CD"] neq "">#dt["参加費CD"]#,<cfelse>NULL,</cfif>
            <cfif dt["掲載日時"] neq "">STR_TO_DATE('#dt["掲載日時"]#', '%m/%d/%Y'),<cfelse>NULL,</cfif>
            <cfif dt["F公開"] neq "">#dt["F公開"]#,<cfelse>NULL,</cfif>
            <cfif dt["現在の状態Web"] neq "">'#dt["現在の状態Web"]#',<cfelse>NULL,</cfif>
            <cfif dt["主催者名"] neq "">'#dt["主催者名"]#',<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(1)"] neq "" and dt["大分類CD(1)"] neq "?">#dt["大分類CD(1)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(2)"] neq "">#dt["大分類CD(2)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(3)"] neq "">#dt["大分類CD(3)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(4)"] neq "">#dt["大分類CD(4)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(5)"] neq "">#dt["大分類CD(5)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(6)"] neq "">#dt["大分類CD(6)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(7)"] neq "">#dt["大分類CD(7)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(8)"] neq "">#dt["大分類CD(8)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(9)"] neq "">#dt["大分類CD(9)"]#,<cfelse>NULL,</cfif>
            <cfif dt["大分類CD(10)"] neq "">#dt["大分類CD(10)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(1)"] neq "">#dt["分野明細WebCD(1)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(2)"] neq "">#dt["分野明細WebCD(2)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(3)"] neq "">#dt["分野明細WebCD(3)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(4)"] neq "">#dt["分野明細WebCD(4)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(5)"] neq "">#dt["分野明細WebCD(5)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(6)"] neq "">#dt["分野明細WebCD(6)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(7)"] neq "">#dt["分野明細WebCD(7)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(8)"] neq "">#dt["分野明細WebCD(8)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(9)"] neq "">#dt["分野明細WebCD(9)"]#,<cfelse>NULL,</cfif>
            <cfif dt["分野明細WebCD(10)"] neq "">#dt["分野明細WebCD(10)"]#,<cfelse>NULL,</cfif>

            <cfif dt["テーマコード1"] neq "">#dt["テーマコード1"]#,<cfelse>NULL,</cfif>
            <cfif dt["テーマコード2"] neq "">#dt["テーマコード2"]#,<cfelse>NULL,</cfif>
            <cfif dt["テーマコード3"] neq "">#dt["テーマコード3"]#,<cfelse>NULL,</cfif>

            <cfif dt["参加費基本金額(1)"] neq "">#dt["参加費基本金額(1)"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加費基本金額(2)"] neq "">#dt["参加費基本金額(2)"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加費基本金額(3)"] neq "">#dt["参加費基本金額(3)"]#,<cfelse>NULL,</cfif>
            <cfif dt["参加費基本金額(4)"] neq "">#dt["参加費基本金額(4)"]#,<cfelse>NULL,</cfif>

            <cfif dt["参加費追加金額"] neq "">#dt["参加費追加金額"]#,<cfelse>0,</cfif><!--- 参加費追加金額 --->
            <cfif dt["セミナー参加費文言"] neq "">'#dt["セミナー参加費文言"]#',<cfelse>NULL,</cfif>
            <cfif dt["HP登録日"] neq "">STR_TO_DATE('#dt["HP登録日"]#', '%m/%d/%Y'),<cfelse>NULL,</cfif>
            <cfif dt["HP登録時刻"] neq "">'#dt["HP登録時刻"]#',<cfelse>NULL,</cfif>
            <cfif dt["F公開"] neq "">#dt["F公開"]#,<cfelse>NULL,</cfif>
            <cfif dt["企画担当者名(1)"] neq "">'#dt["企画担当者名(1)"]#',<cfelse>NULL,</cfif>
            <cfif dt["受講方法CD"] neq "">'#dt["受講方法CD"]#',<cfelse>NULL,</cfif>
            #unlimit#,
            now()
            )ON DUPLICATE KEY UPDATE
            seminar_code        = VALUES(seminar_code),
            event_date          = VALUES(event_date),
            start_time          = VALUES(start_time),
            end_time            = VALUES(end_time),
            main_theme          = VALUES(main_theme),
            sub_theme           = VALUES(sub_theme),
            sub_theme2          = VALUES(sub_theme2),
            title1              = VALUES(title1),
            title2              = VALUES(title2),
            title3              = VALUES(title3),
            title4              = VALUES(title4),
            title_live              = VALUES(title_live),
            title_archive              = VALUES(title_archive),
            description1        = VALUES(description1),
            description2        = VALUES(description2),
            description3        = VALUES(description3),
            description4        = VALUES(description4),
            description_live        = VALUES(description_live),
            description_archive        = VALUES(description_archive),
            place_id            = VALUES(place_id),
            fee_category_id     = VALUES(fee_category_id),
            publication_date    = VALUES(publication_date),
            public_flag         = VALUES(public_flag),
            seminar_status      = VALUES(seminar_status),
            promoter            = VALUES(promoter),
            large_category_id1  = VALUES(large_category_id1),
            large_category_id2  = VALUES(large_category_id2),
            large_category_id3  = VALUES(large_category_id3),
            large_category_id4  = VALUES(large_category_id4),
            large_category_id5  = VALUES(large_category_id5),
            large_category_id6  = VALUES(large_category_id6),
            large_category_id7  = VALUES(large_category_id7),
            large_category_id8  = VALUES(large_category_id8),
            large_category_id9  = VALUES(large_category_id9),
            large_category_id10 = VALUES(large_category_id10),
            middle_category_id1 = VALUES(middle_category_id1),
            middle_category_id2 = VALUES(middle_category_id2),
            middle_category_id3 = VALUES(middle_category_id3),
            middle_category_id4 = VALUES(middle_category_id4),
            middle_category_id5 = VALUES(middle_category_id5),
            middle_category_id6 = VALUES(middle_category_id6),
            middle_category_id7 = VALUES(middle_category_id7),
            middle_category_id8 = VALUES(middle_category_id8),
            middle_category_id9 = VALUES(middle_category_id9),
            middle_category_id10 = VALUES(middle_category_id10),

            theme_id1 = VALUES(theme_id1),
            theme_id2 = VALUES(theme_id2),
            theme_id3 = VALUES(theme_id3),
            fee1              = VALUES(fee1),
            fee2              = VALUES(fee2),
            fee3              = VALUES(fee3),
            fee4              = VALUES(fee4),

            add_fee              = VALUES(add_fee),
            fee_note             = VALUES(fee_note),
            hp_registered_date   = VALUES(hp_registered_date),
            hp_registered_time   = VALUES(hp_registered_time),
            fm_fpub   = VALUES(fm_fpub),
            personnel   = VALUES(personnel),
            lecture_style_list  = VALUES(lecture_style_list),
            unlimited_publicable_flag  = VALUES(unlimited_publicable_flag),
            update_date         = now()
        </cfquery>
<!--- 
        <cfif is_new_sem>
          <!--- 追加金額は最大値までいったら0にする --->
          <cfif fee_cnt eq max_cnt>
            <cfset fee_cnt = 0>
            <cfset add_fee = 0>
          <cfelse>
            <cfset fee_cnt = fee_cnt + 1>
            <cfset add_fee = add_fee + step_amount>          
          </cfif>
          
          <!--- 追加料金をアップデート --->
          <cfquery name="updAddFee">
            UPDATE m_admin SET cur_add_fee = #add_fee#,cur_add_fee_cnt = #fee_cnt#
          </cfquery>

        </cfif>
 --->

        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_seminar---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>
    </cfif>  
  </cfloop>






  <!--- 
  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

  セミナー講演者マッピングテーブルゲット 

  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  --->

  <cfset data_arr = res.response.data>
  <cfset token = "">
  <cfloop index="i" from="1" to="#record_count#">
    <cfset is_new_sem = false>
    
    <cfset dt2 = data_arr[i].fieldData>
    <cfif dt2["セミナーNO"] neq "">
      <cfset fm_db                = "JPI_SeminarData" >
      <cfset layout               = "RequestAPI" >
      <cfset base_url             = application.fm_host & application.fm17_api_end_point>
      <cfif token eq "">
        <cfset token                = getFmToken(fm_db)>
      </cfif>
      

      <!--- ここからはトークンをもとにデータをゲット --->
      <cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
      <cfset layout_url  = base_url & "/" & fm_file>
      <cfset query       = {}>
      <cfset query_array = []>
      <cfset cond1       = {}>
      <cfset confirm     = {}>
      <cfset sort = {}>
      <cfset sort_arr = []>
      <cfset sort_contents = {}>
      <cfset sort_contents2 = {}>

<!--- ソート --->
<!--- "sort" : [ { "fieldName": "LastName", "sortOrder": "ascend" }, { "fieldName": "FirstName", "sortOrder": "ascend" } ] --->


      <!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
      <cfquery name="qGetLastUpdate">
        SELECT DATE_FORMAT(CAST(IFNULL(t_seminar_speaker_mapping,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
               DATE_FORMAT(IFNULL(t_seminar_speaker_mapping,'1900/12/31 00:00'), '%H:%i') l_time 
          FROM t_last_update
      </cfquery>

      <cfset cond1["F確定"] =  ">=" &  1>
      <cfset cond1["セミナーNO"] = "=" & dt2["セミナーNO"]>
      <cfset ArrayAppend(query_array, cond1)>

      <cfset query["query"] = query_array>
      <!--- <cfset query["range"]        = setRandStringsToForceNumeralToString(20000)> --->
      <cfset query["limit"]        = setRandStringsToForceNumeralToString(20000)>
      <cfset query["offset"]      = setRandStringsToForceNumeralToString(1)>


      <cfset sort_contents["fieldName"] = "セミナーNO">
      <cfset sort_contents["sortOrder"] = "ascend">
      <cfset ArrayAppend(sort_arr, sort_contents)>

      <cfset sort_contents2["fieldName"] = "SEQ">
      <cfset sort_contents2["sortOrder"] = "ascend">
      <cfset ArrayAppend(sort_arr, sort_contents2)>

      <cfset query["sort"] = sort_arr>
      <cfset query = serializeJSON(query)>
      <cfset query = removeRandStrings(query)>
      <cfhttp url="#layout_url#" method="post" result="httpResp">
          <cfhttpparam type="header" name="Content-Type" value="application/json" />
          <cfhttpparam type="header" name="Authorization" value="#token#" />
          <cfhttpparam type="body" value="#query#">
      </cfhttp>
      <cfset res = DeserializeJSON(httpResp.fileContent)>
       <!--- <cflog type="error" file="jpi_error" text="#ArrayLen(res.response.data)#"> --->
      <cfset sort_order = 1>
      <cfset prev_seminar = "">

      <cfif res.messages[1].code eq 0>

        <cftry>
          <cfquery name="qDelSeminarMapping">
            DELETE FROM t_seminar_speaker_mapping WHERE seminar_code = '#dt2["セミナーNO"]#'
          </cfquery>
          <cfcatch type="Database">
              <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---qGetSeminarMapping#now()#SQLエラー：#cfcatch.queryError#">
              <cfcontinue>
          </cfcatch> 
        </cftry>
        
        <cfset record_count2 = ArrayLen(res.response.data)>
              <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---record_count2---#record_count2#">
        <cfloop index="cnt" from="1" to="#record_count2#">

          <cfset dt = res.response.data[cnt].fieldData>
          <cflog type="error" file="jpi_error" text="講演者#cnt#---講師No:#dt["講師No"]#---#dt["セミナーNO"]#--cnt--#cnt#">


          <cfset sort_order = cnt>     
            <cftry>
            <cfquery name="qInsSeminarMap">

                  INSERT INTO t_seminar_speaker_mapping
                  (
                  seminar_code,
                  speaker_code,
                  name,
                  name_kana,
                  company_name,
                  department,
                  post,
                  biography,
                  note,
                  file_name,
                  sort_order,
                  update_date                
                  )VALUES(
                  '#dt["セミナーNO"]#',
                  <cfif dt["講師No"] neq "">'#dt["講師No"]#',<cfelse>NULL,</cfif>
                  <cfif dt["講師名"] neq "">'#dt["講師名"]#',<cfelse>NULL,</cfif>
                  <cfif dt["講師フリガナ"] neq "">'#dt["講師フリガナ"]#',<cfelse>NULL,</cfif>
                  <cfif dt["会社名"] neq "">'#dt["会社名"]#',<cfelse>NULL,</cfif>
                  <!--- <cfif dt["会場都道府県名"] neq "">'#dt["会場都道府県名"]#',<cfelse>NULL,</cfif> --->
                  <cfif dt["部署"] neq "">'#dt["部署"]#',<cfelse>NULL,</cfif>
                  <cfif dt["役職"] neq "">'#dt["役職"]#',<cfelse>NULL,</cfif>
                  <cfif dt["講師略歴"] neq "">'#dt["講師略歴"]#',<cfelse>NULL,</cfif>
                  <cfif dt["講師備考"] neq "">'#dt["講師備考"]#',<cfelse>NULL,</cfif>
                  <cfif dt["講師画像名"] neq "">'#dt["講師画像名"]#',<cfelse>NULL,</cfif>
                  #sort_order#,
                  now()
                  )
            </cfquery>  
            <cfcatch type="Database">
                <cflog type="error" file="jpi_error" text="t_seminar_speaker_mapping---qInsSeminarMap#now()#SQLエラー：#cfcatch.queryError#">
                <cfcontinue>
            </cfcatch> 
          </cftry>    
        </cfloop>
        <cfquery name="updLastUpd">
          UPDATE t_last_update SET t_seminar_speaker_mapping = now()
        </cfquery>
      <cfelse>
      </cfif>
    </cfif>
  </cfloop>


  <cfquery name="updLastUpd">
    UPDATE t_last_update SET m_seminar = now()
  </cfquery>
<cfelse>
</cfif>



<!--- 
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

受講形態マスターテーブルゲット 

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
--->

  <cfset fm_db                = "JPI_Master" >
  <cfset layout               = "ClassStyleAPI" >
  <cfset base_url             = application.fm_host & application.fm17_api_end_point>
  <cfset token                = getFmToken(fm_db)>



<!--- ここからはトークンをもとにデータをゲット --->
<cfset fm_file      = fm_db & "/layouts/" & layout & "/_find">
<cfset layout_url   = base_url & "/" & fm_file>
<cfset query        = {}>
<cfset query_array  = []>
<cfset cond1 = {}>
<cfset cond2 = {}>

<!--- 最後にアップデートした時間を取得(差分を持ってくるため。) --->
<cfquery name="qGetLastUpdate">
  SELECT DATE_FORMAT(CAST(IFNULL(m_lecture_style,'1900/12/31 00:00') AS DATE), '%m/%d/%Y') l_date,
         DATE_FORMAT(IFNULL(m_lecture_style,'1900/12/31 00:00'), '%H:%i') l_time 
    FROM t_last_update
</cfquery>


<cfset cond1["修正日"] = ">" & qGetLastUpdate.l_date>
<cfset ArrayAppend(query_array, cond1)>

<cfset cond2["修正日"] = "=" & qGetLastUpdate.l_date>
<cfset cond2["修正時刻"] = ">=" & qGetLastUpdate.l_time>
<cfset ArrayAppend(query_array, cond2)>
<cfset query["query"] = query_array>

<cfhttp url="#layout_url#" method="post" result="httpResp">
    <cfhttpparam type="header" name="Content-Type" value="application/json" />
    <cfhttpparam type="header" name="Authorization" value="#token#" />
    <cfhttpparam type="body" value="#serializeJSON(query)#">
</cfhttp>
<cfset res = DeserializeJSON(httpResp.fileContent)>
<cfif res.messages[1].code eq 0>
  <cfset record_count = ArrayLen(res.response.data)>
  <cfloop index="i" from="1" to="#record_count#">
    <cfset dt = res.response.data[i].fieldData>
    <cflog type="infromation" file="jpi_error" text="m_lecture_style---#now()##structkeylist(dt)#">
    <cfif dt["受講方法CD"] neq "">

      <cftry>
        <cfquery name="qInsMaster">
            INSERT INTO m_lecture_style
            (
            lecture_style_id,
            lecture_style_name,
            archive_flag,
            update_date                
            )VALUES(
            '#dt["受講方法CD"]#',
            <cfif dt["受講方法"] neq "">'#dt["受講方法"]#',<cfelse>NULL,</cfif>
            <cfif dt["アーカイブフラグ"] neq "">#dt["アーカイブフラグ"]#,<cfelse>0,</cfif>
            now()
            )ON DUPLICATE KEY UPDATE
            lecture_style_id       = VALUES(lecture_style_id),
            lecture_style_name     = VALUES(lecture_style_name),
            archive_flag = VALUES(archive_flag),
            update_date    = now()
        </cfquery>
        <cfcatch type="Database">
            <cflog type="error" file="jpi_error" text="m_lecture_style---#now()#SQLエラー：#cfcatch.queryError#">
            <cfcontinue>
        </cfcatch>            
      </cftry>
    </cfif>

  </cfloop>
  <cfquery name="updLastUpd">
    UPDATE t_last_update SET m_lecture_style = now()
  </cfquery>
<cfelse>
  <cflog type="infromation" file="jpi_error" text="m_lecture_style---#now()#---error_code:#res.messages[1].code#---error_message：#res.messages[1].message#">
</cfif>




<cflog type="error" file="jpi_error" text="m_seminar---#now()#マスターゲット実行">
<!--- <cflocation url="#CGI.HTTP_REFERER#"> --->
マスターゲット実行