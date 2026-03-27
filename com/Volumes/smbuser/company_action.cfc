<cfcomponent>
  <cfheader name="Access-Control-Allow-Origin" value="*" />
  <!--- 取引先番号の重複チェック --->
  <cffunction name="checkCompanyNo" access="remote" returnFormat="plain">
    <cfset result = 0>
    <cfquery name="qCheckCompanyNo" datasource="#application.dsn#">
      SELECT company_no 
        FROM m_company 
       WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
    </cfquery>
    <cfif qCheckCompanyNo.RecordCount GTE 1>
      <cfset result = 1>
    </cfif>
    <cfreturn result>
  </cffunction>
  <cffunction name="checkEmail" access="remote" returnFormat="plain">
    <cfset result = 0>
    <cfquery name="qCheckEmail" datasource="#application.dsn#">
      SELECT staff_id 
        FROM m_account 
       WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
         AND email = <cfqueryparam value="#Form.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="60">
    </cfquery>
    <cfif qCheckEmail.RecordCount GTE 1>
      <cfset result = 1>
    </cfif>
    <cfreturn result>
  </cffunction>

  <cffunction name="getRegisteredAccounts" access="remote" returnformat="json">
    
    <!--- <cfset result = {}> --->
    <cfset accounts = {}>
    <cfset folder_staff = {}>
    <cfset dataset = []>

    <cfquery name="qGetAccounts" datasource="#application.dsn#">
      SELECT m_account.staff_id,
             m_account.staff_name,
             m_account.email,
             m_account.readable_bill,
             IF(m_account.password_hash IS NOT NULL,'本PW設定済',m_account.password_default) password_default,
             m_account.readable_support,
             CASE WHEN  m_account.password_hash IS NOT NULL THEN 1
                  WHEN send_temp_pass_datetime IS NULL THEN 0 <!--- 仮PW設定済み ---> 
                   <!--- 本PW設定済み --->
                  WHEN send_temp_pass_datetime IS NOT NULL THEN 2 <!--- 仮PW設定済みでメール送信済み。本PWは設定していない。 --->
                  ELSE 0 <!--- 本PW設定済み --->
            END AS temp_pass_send_status
        FROM m_account
      WHERE m_account.company_no = '#form.company_no#'
    </cfquery>
    <cfloop index="i" from="1" to="#qGetAccounts.RecordCount#">
      <cfset record = {}>
      <cfset record["staff_id"] = qGetAccounts.staff_id[i]>
      <cfset record["staff_name"] = qGetAccounts.staff_name[i]>
      <cfset record["email"] = qGetAccounts.email[i]>
      <cfset record["readable_bill"] = qGetAccounts.readable_bill[i]>
      <cfset record["readable_support"] = qGetAccounts.readable_support[i]>
      <cfset record["p_default"] = qGetAccounts.password_default[i]>
      <cfset record["temp_pass_send_status"] = qGetAccounts.temp_pass_send_status[i]>
      
      <cfset dataset[i] = record>      
    </cfloop>
    <cfset accounts["accounts"] = dataset>

    <cfquery name="qGetFolder" datasource="#application.dsn#">
      SELECT m_account_folder.folder_no,m_account_folder.staff_id
        FROM m_account_folder LEFT OUTER JOIN m_account ON m_account_folder.company_no = m_account.company_no
                                                       AND m_account_folder.staff_id = m_account.staff_id
       WHERE m_account.company_no = <cfqueryparam value = "#form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">
         AND m_account.status = 1
      ORDER BY LPAD(m_account_folder.staff_id, 20, 0)
    </cfquery>

    <cfloop index="i" from="1" to="#qGetFolder.RecordCount#">
      <cfif i eq 1 or qGetFolder.staff_id[i] neq qGetFolder.staff_id[i-1]>
        <cfset folder_staff[qGetFolder.staff_id[i]] = []>
      </cfif>
      <cfset ArrayAppend(folder_staff[qGetFolder.staff_id[i]],qGetFolder.folder_no[i])>
    </cfloop>
    <cfset accounts["folder_staff"] = folder_staff>

    <cfreturn accounts>
  </cffunction>

  <cffunction name="editCompany" access="remote" returnFormat="plain">
    <cfquery name="qInsertSystem" datasource="#application.dsn#">
      INSERT INTO
        m_company (
          company_no,
          company_name,
          tu_staff_id1,
          create_date
        )
      VALUES
        (
          <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
          <cfqueryparam value="#Form.company_name#" cfsqltype="CF_SQL_VARCHAR" maxlength="60">,
          <cfif StructKeyExists(form,"tu_staff_id1") and form.tu_staff_id1 neq "">
            <cfqueryparam value="#Form.tu_staff_id1#" cfsqltype="CF_SQL_VARCHAR" maxlength="8">,
          <cfelse>
            NULL,
          </cfif>
          now()
        ) ON DUPLICATE KEY UPDATE
        company_no = VALUES(company_no),
        company_name = VALUES(company_name),
        tu_staff_id1 = VALUES(tu_staff_id1),
        update_date = now()
    </cfquery>

    <!--- フォルダーを作成(各会社のフォルダーはファイル登録時に作成) --->
    <cfquery name="qGetFolder" datasource="#application.dsn#">
      SELECT folder_no FROM m_folder
    </cfquery>
    <cfloop index="i" from="1" to="#qGetFolder.RecordCount#">
      <cfset company_folder_path = application.folder_path & qGetFolder.folder_no[i]>
      <cfif !DirectoryExists(company_folder_path)>
          <cfdirectory action="create" directory="#company_folder_path#" mode="777">
      </cfif>
    </cfloop>

    <cfreturn 1>
  </cffunction>
  <cffunction name="delCompany" access="remote" returnFormat="plain">
    <cfquery name="qDelCompany" datasource="#application.dsn#">
      DELETE FROM m_company WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
    </cfquery>
    <cfquery name="qDelCompanyStaff" datasource="#application.dsn#">
      DELETE FROM m_account WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
    </cfquery>
    <cfset bill_path = application.bill_path & Form.company_no>
    <cfif DirectoryExists(bill_path)>
        <cfdirectory action="delete" directory="#bill_path#" recurse="yes">
    </cfif>
    <cfset support_path = application.support_path & Form.company_no>
    <cfif DirectoryExists(support_path)>
        <cfdirectory action="delete" directory="#support_path#" recurse="yes">
    </cfif>
    <cfreturn 0>
  </cffunction>
  <cffunction name="addAccounts" access="remote" returnFormat="json">
    <cfquery name="qGetOtherAccounts" datasource="#application.dsn#">
      SELECT email,
             staff_name,
             password_default,
             password_salt,
             password_hash
      FROM m_account
      WHERE email = <cfqueryparam value="#Form.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="60">
    </cfquery>


    <cfset password_default = "">
    <cfset password_salt = "">
    <cfset password_hash = "">

    <!--- すでに該当のメールアドレスで他の取引先に登録があった場合それを入力 --->
    <cfif qGetOtherAccounts.RecordCount GTE 1>
      <cfset password_default = qGetOtherAccounts.password_default[1]>
      <cfset password_salt = qGetOtherAccounts.password_salt[1]>
      <cfset password_hash = qGetOtherAccounts.password_hash[1]>
    <cfelse>
      <cfset pass_keta = 8>
      <cfscript>
        randomCFC=CreateObject("component","common_file");
        random = randomCFC.getRandom(pass_keta);
      </cfscript>
      <cfset password_default = random>      
    </cfif>


    <cfquery name="qGetNewAccounts" datasource="#application.dsn#">
      SELECT IFNULL(MAX(staff_id),0) + 1 AS new_staff_id
      FROM m_account
      WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
    </cfquery>    
    <cfquery name="qInsertAccounts" datasource="#application.dsn#">
      INSERT INTO
      m_account (
          company_no,
          staff_id,
          staff_name,
          email,

          password_default,
          password_salt,
          password_hash,
          create_date
        )
      VALUES
        (
          <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="8">,
          #qGetNewAccounts.new_staff_id#,
          '#Form.staff_name#',
          '#Form.email#',

          <cfqueryparam value = "#password_default#" cfsqltype="CF_SQL_VARCHAR" maxlength="60" null="#(len(password_default) ? false : true)#">,
          <cfqueryparam value = "#password_salt#" cfsqltype="CF_SQL_VARCHAR" maxlength="60" null="#(len(password_salt) ? false : true)#">,
          <cfqueryparam value = "#password_hash#" cfsqltype="CF_SQL_VARCHAR" maxlength="60" null="#(len(password_hash) ? false : true)#">,
          now()
        )
    </cfquery>

    <cfif structKeyExists(form,"folder_chk") and form.folder_chk neq "">
      <cfset folder_list = form.folder_chk>
      <cfloop index="folder_no" list="#folder_list#">
        <cfquery name="qUpdAuthority" datasource="#application.dsn#">
          INSERT INTO m_account_folder (
            company_no,
            staff_id,
            folder_no
          )VALUES(
            <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
            <cfqueryparam value="#qGetNewAccounts.new_staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
            <cfqueryparam value="#folder_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
          )ON DUPLICATE KEY UPDATE 
          company_no = VALUES(company_no),
          staff_id = VALUES(staff_id),
          folder_no = VALUES(folder_no)        
        </cfquery>        
      </cfloop>
    </cfif>
    <cfreturn 0>
  </cffunction>

  <cffunction name="resetP" access="remote" returnFormat="plain">
    <!--- 同じメールアドレスのアカウントすべてのパスワードを初期化します。 --->
    <cfquery name="qGetEmail" datasource="#application.dsn#">
      SELECT email
      FROM m_account
      WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
        AND staff_id = <cfqueryparam value="#Form.staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
    </cfquery>

    <cfset pass_keta = 8>
    <cfscript>
      randomCFC=CreateObject("component","common_file");
      random = randomCFC.getRandom(pass_keta);
    </cfscript>

    <cfquery name="qUpdDefaultPassword" datasource="#application.dsn#">
      UPDATE m_account 
         SET password_default = <cfqueryparam value="#random#" cfsqltype="CF_SQL_VARCHAR" maxlength="60">,
             password_salt = NULL,
             password_hash = NULL,
             send_temp_pass_datetime = NULL
       WHERE email = '#qGetEmail.email#'
    </cfquery>
    <cfreturn random>          
  </cffunction>
  <cffunction name="sendP" access="remote" returnFormat="plain">
    <!--- 同じメールアドレスのアカウントすべてのパスワードを初期化します。 --->
    <cfquery name="qGetEmail" datasource="#application.dsn#">
      SELECT email,password_default,staff_name
      FROM m_account
      WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
        AND staff_id = <cfqueryparam value="#Form.staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
    </cfquery>

    <cfset mail_obj = createObject("component","quick_post.com.mail")>
    <cfset subject = "【#application.app_name#】システム登録のご案内">
    <cfset content = "#qGetEmail.staff_name#様

平素より、弊社サービスをご利用いただきまして、まことにありがとうございます。

#application.app_name#システムへのご利用登録が完了しました。
下記URLにメールアドレス、仮パスワードでログインしてください。
ログインいただきましたら、画面に従って本パスワードの設定をお願いいたします。

　　　　　　　　　　記

【#application.app_name# URL】#application.base_url#login.cfm
【ID】#qGetEmail.email#
【仮パスワード】#qGetEmail.password_default#

次回以降のログイン時は新しく設定いただきました本パスワードをご利用ください。
本メールのアドレスは送信専用アドレスですのでご質問等がございましたら弊社営業担当者へご連絡ください。

今後とも、よろしくお願いいたします。
  
株式会社テクニカル・ユニオン
〒104-0061
東京都中央区銀座8-12-8 PMO銀座八丁目９F
TEL:03-6264-2620
FAX:03-6264-2621
https://www.technicalunion.com/
              ">
    <cfset mail_result = mail_obj.sendMail(subject,content,qGetEmail.email)>
    <cfif mail_result eq 0>
      
    </cfif>
    <cflog
    text = "Pass Notify Mail Sent：#qGetEmail.email# Result:#mail_result#"
    type = "information"
    file = "air_post">

    <cfquery name="qUpdDefaultPassword" datasource="#application.dsn#">
      UPDATE m_account 
         SET send_temp_pass_datetime = now()
       WHERE email = '#qGetEmail.email#'
    </cfquery>
    <cfreturn 1>          
  </cffunction>

  
  

  <cffunction name="changeAuthority" access="remote" returnFormat="json">
    <cfif form.folder_chk eq 1>
      <cfquery name="qUpdAuthority" datasource="#application.dsn#">
        INSERT INTO m_account_folder (
          company_no,
          staff_id,
          folder_no
        )VALUES(
          <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
          <cfqueryparam value="#Form.staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
          <cfqueryparam value="#Form.folder_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
        )ON DUPLICATE KEY UPDATE 
        company_no = VALUES(company_no),
        staff_id = VALUES(staff_id),
        folder_no = VALUES(folder_no)        
      </cfquery>
    <cfelse>
      <cfquery name="qUpdAuthority" datasource="#application.dsn#">
        DELETE FROM m_account_folder 
         WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
           AND staff_id = <cfqueryparam value="#Form.staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
           AND folder_no = <cfqueryparam value="#Form.folder_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
      </cfquery>
    </cfif>

    <cfreturn 0>
  </cffunction>

  <cffunction name="delRegisteredStaff" access="remote" returnFormat="json">
    <cfquery name="qDelSystemStaff" datasource="#application.dsn#">
      DELETE FROM m_account WHERE company_no = <cfqueryparam value="#Form.company_no#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
                               AND staff_id = <cfqueryparam value="#Form.staff_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
    </cfquery>
    <cfreturn 0>
  </cffunction>


  
</cfcomponent>