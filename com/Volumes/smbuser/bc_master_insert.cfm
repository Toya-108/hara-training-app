<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>無題ドキュメント</title>
</head>

<body>

<cfoutput>


<cfform name="m_adress_insert" method="post">
	<cfif IsDefined("Form.business_card_code") is false><cflocation url="bc_master_new.cfm"></cfif>

    <!--- Form変数の保持 --->
    <!---<cfif #v_flg# eq 2>--->
      <!--- 取引先M詳細画面のForm保持 --->
      <!--- 取引先M詳細画面のForm保持 --->
      <cfif IsDefined("Form.bc_client_code")><input type="hidden" name="bc_client_code" value="#Form.bc_client_code#"></cfif>
      <cfif IsDefined("Form.bc_main_emp")><input type="hidden" name="bc_main_emp" value="#Form.bc_main_emp#"></cfif>
      <cfif IsDefined("Form.bc_k_flg")><input type="hidden" name="bc_k_flg" value="#Form.bc_k_flg#"></cfif>
      <cfif IsDefined("Form.bc_cr_cd")><input type="hidden" name="bc_cr_cd" value="#Form.bc_cr_cd#"></cfif>
      <cfif IsDefined("Form.bc_tori_flg")><input type="hidden" name="bc_tori_flg" value="#Form.bc_tori_flg#"></cfif>
      <cfif IsDefined("Form.bc_client_name_kana")><input type="hidden" name="bc_client_name_kana" value="#Form.bc_client_name_kana#"></cfif>
      <cfif IsDefined("Form.bc_client_name")><input type="hidden" name="bc_client_name" value="#Form.bc_client_name#"></cfif>
      <cfif IsDefined("Form.bc_ryaku_name1")><input type="hidden" name="bc_ryaku_name1" value="#Form.bc_ryaku_name1#"></cfif>
      <cfif IsDefined("Form.bc_ryaku_name2")><input type="hidden" name="bc_ryaku_name2" value="#Form.bc_ryaku_name2#"></cfif>
      <cfif IsDefined("Form.bc_busyo")><input type="hidden" name="bc_busyo" value="#Form.bc_busyo#"></cfif>
      <cfif IsDefined("Form.bc_sel_condtn")><input type="hidden" name="bc_sel_condtn" value="#Form.bc_sel_condtn#"></cfif>
      <cfif IsDefined("Form.bc_post_no1")><input type="hidden" name="bc_post_no1" value="#Form.bc_post_no1#"></cfif>
      <cfif IsDefined("Form.bc_address_1")><input type="hidden" name="bc_address_1" value="#Form.bc_address_1#"></cfif>
      <cfif IsDefined("Form.bc_address_2")><input type="hidden" name="bc_address_2" value="#Form.bc_address_2#"></cfif>
      <cfif IsDefined("Form.bc_tel_no1")><input type="hidden" name="bc_tel_no1" value="#Form.bc_tel_no1#"></cfif>
      <cfif IsDefined("Form.bc_fax_no1")><input type="hidden" name="bc_fax_no1" value="#Form.bc_fax_no1#"></cfif>
      <cfif IsDefined("Form.bc_url_adr")><input type="hidden" name="bc_url_adr" value="#Form.bc_url_adr#"></cfif>
      <cfif IsDefined("Form.bc_tan_ei")><input type="hidden" name="bc_tan_ei" value="#Form.bc_tan_ei#"></cfif>
      <cfif IsDefined("Form.bc_gaiyou")><input type="hidden" name="bc_gaiyou" value="#Form.bc_gaiyou#"></cfif>
      <cfif IsDefined("Form.bc_cust_flag")><input type="hidden" name="bc_cust_flag" value="1"></cfif>
      <cfif IsDefined("Form.bc_department")><input type="hidden" name="bc_department" value="#Form.bc_department#"></cfif>
      <cfif IsDefined("Form.bc_supp_flag")>
        <input type="hidden" name="bc_supp_flag" value="1">
            <!--- テーブルの背景セット(委託先の場合緑色) --->
            <cfset bg_color_class = "green_table01">
      </cfif>
      <cfif IsDefined("Form.bc_seller_flag")><input type="hidden" name="bc_seller_flag" value="1"></cfif>
      <cfif IsDefined("Form.bc_seikyusaki_code")><input type="hidden" name="bc_seikyusaki_code" value="#Form.bc_seikyusaki_code#"></cfif>
      <cfif IsDefined("Form.bc_seikyusaki_name")><input type="hidden" name="bc_seikyusaki_name" value="#Form.bc_seikyusaki_name#"></cfif>
      <cfif IsDefined("Form.bc_nyuukin_houhou_code")><input type="hidden" name="bc_nyuukin_houhou_code" value="#Form.bc_nyuukin_houhou_code#"></cfif>
      <cfif IsDefined("Form.bc_nyuukin_houhou_name")><input type="hidden" name="bc_nyuukin_houhou_name" value="#Form.bc_nyuukin_houhou_name#"></cfif>
      <cfif IsDefined("Form.bc_urikake_hojyo_kamoku_code")><input type="hidden" name="bc_urikake_hojyo_kamoku_code" value="#Form.bc_urikake_hojyo_kamoku_code#"></cfif>
      <cfif IsDefined("Form.bc_urikake_hojyo_kamoku_name")><input type="hidden" name="bc_urikake_hojyo_kamoku_name" value="#Form.bc_urikake_hojyo_kamoku_name#"></cfif>
      <cfif IsDefined("Form.bc_seiksime_ymd1")><input type="hidden" name="bc_seiksime_ymd1" value="#Form.bc_seiksime_ymd1#"></cfif>
      <cfif IsDefined("Form.bc_nykyti_mm1")><input type="hidden" name="bc_nykyti_mm1" value="#Form.bc_nykyti_mm1#"></cfif>
      <cfif IsDefined("Form.bc_nykyti_ymd1")><input type="hidden" name="bc_nykyti_ymd1" value="#Form.bc_nykyti_ymd1#"></cfif>
      <cfif IsDefined("Form.bc_rounding_kbn")><input type="hidden" name="bc_rounding_kbn" value="#Form.bc_rounding_kbn#"></cfif>
      <cfif IsDefined("Form.bc_jisha_flag")><input type="hidden" name="bc_jisha_flag" value="#Form.bc_jisha_flag#"></cfif>
      <cfif IsDefined("Form.bc_jisha_section_code")><input type="hidden" name="bc_jisha_section_code" value="#Form.bc_jisha_section_code#"></cfif>
      <cfif IsDefined("Form.bc_login_id")><input type="hidden" name="bc_login_id" value="#Form.bc_login_id#"></cfif>
      <cfif IsDefined("Form.bc_password")><input type="hidden" name="bc_password" value="#Form.bc_password#"></cfif>
      <cfif IsDefined("Form.bc_sec_count")> 
        <cfloop index="i" from="1" to="#form.bc_sec_count#">              
            <cfif StructKeyExists(form,"sec_check" & i)>
              <input type="hidden" name="bc_sec_codes" value="#form["sec_code" & i]#">
            </cfif>
        </cfloop>
        
      </cfif>
    <!---</cfif>--->


    
    <cfset Form.business_card_code = ToString(LSNumberFormat(#Form.business_card_code#, "00000"))>
    <cfset this_day = #DateFormat(Now(), "yyyy/mm/dd")#>
    <cfset this_time = #TimeFormat(Now(), "HH:mm:ss")#>
    <cfset this_daytime = #this_day# & " " & #this_time#>

	<!--- firefox以外の場合 --->
	<!---<cfif #session.browser_code# IS 2>
        <cfquery datasource="#application.dsn#" name="qGetClient_code">
             Select client_code
               from m_client
              where member_id = '#session.member_id#' and
              		client_name = '#form.CLIENT_NAME#'
           order by client_code
        </cfquery>
        
        <cfset client_code = #qGetClient_code.client_code#>
    <cfelse>
        <cfset client_code = #form.client_code#>
	</cfif>--->

    <!--- 重複チェック --->
    <cfquery datasource="#application.dsn#" name="qGetBusinessCard">
    	 Select count(business_card_code) as cnt_bccd,
                (ifnull(max(cast(business_card_code as SIGNED)), 0) + 1) as max_bccd
           from m_business_card
          where member_id = '#session.member_id#' and
          		client_code = '#URL.client_cd#' and
                business_card_code = '#Form.business_card_code#'
    </cfquery>
    
    <cfif #qGetBusinessCard.cnt_bccd# eq "" or #qGetBusinessCard.cnt_bccd# eq 0>
      <cfset new_bc_cd = #qGetBusinessCard.cnt_bccd#>
    <cfelse>
      <cfset new_bc_cd = #qGetBusinessCard.max_bccd#>
    </cfif>
    
    
    <!---<cfquery datasource="#application.dsn#" name="qGetMaxBusinessCardCode">
    	 Select (ifnull(max(cast(business_card_code as SIGNED)), 0) + 1) as business_no
           from m_business_card
          where member_id = '#session.member_id#' and
          		client_code = '#client_code#'
    </cfquery>
    <cfif Trim(#Form.business_card_code#) EQ ""><cfset Form.business_card_code = #qGetMaxBusinessCardCode.business_no#></cfif>--->
    

	<cfquery datasource="#application.dsn#" name="qGetBusinessCardCode">
    	 Select max(ifnull(business_card_code,0)) as max_bc_cd
           from m_business_card
          where member_id = '#session.member_id#'
           and client_code = '#URL.client_cd#'
    </cfquery>
    
    <cfif #qGetBusinessCardCode.max_bc_cd# eq "">
      <cfset new_bccd = "00001">
    <cfelse>
      <cfset new_bccd = right("00000" & #qGetBusinessCardCode.max_bc_cd# + 1, 5)>
    </cfif>

    
	<!---<cfif #qGetBusinessCard.RecordCount# eq 0>--->
    	<cfquery datasource="#application.dsn#" name="qInsertBusinessCard">
        	Insert into m_business_card
            	(
                	member_id,
                    client_code,
                    <cfif IsDefined("Form.business_card_name") and Trim(#Form.business_card_name#) NEQ "">business_card_name,</cfif>
                    <cfif IsDefined("Form.business_card_name_kana") and Trim(#Form.business_card_name_kana#) NEQ "">business_card_name_kana,</cfif>
                    <cfif IsDefined("Form.business_card_yaku") and Trim(#Form.business_card_yaku#) NEQ "">post,</cfif>
                    <cfif IsDefined("Form.mobile_phone") and Trim(#Form.mobile_phone#) NEQ "">mobile_phone,</cfif>
                    <cfif IsDefined("Form.mobile_phone2") and Trim(#Form.mobile_phone2#) NEQ "">mobile_phone2,</cfif>
                    <cfif IsDefined("Form.mail_1") and Trim(#Form.mail_1#) NEQ "">mail_1,</cfif>
                    <cfif IsDefined("Form.mail_2") and Trim(#Form.mail_2#) NEQ "">mail_2,</cfif>
                    
                    <cfif IsDefined("Form.busyo") and Trim(#Form.busyo#) NEQ "">department,</cfif>
                    <cfif IsDefined("Form.postno") and Trim(#Form.postno#) NEQ "">post_no,</cfif>
                    <cfif IsDefined("Form.address") and Trim(#Form.address#) NEQ "">address,</cfif>
                    <cfif IsDefined("Form.address2") and Trim(#Form.address2#) NEQ "">address_2,</cfif>
                    <cfif IsDefined("Form.telno") and Trim(#Form.telno#) NEQ "">tel_no1,</cfif>
                    <cfif IsDefined("Form.faxno") and Trim(#Form.faxno#) NEQ "">fax_no,</cfif>
                    <cfif IsDefined("Form.biko") and Trim(#Form.biko#) NEQ "">com_memo,</cfif>
                    <cfif IsDefined("Form.department") and Trim(#Form.department#) NEQ "">department,</cfif>
                    business_card_code,
                    up_emp,
                    up_emp_name,
                    up_date
                )
                values
                (
                	'#session.member_id#',
                    '#URL.client_cd#',
                    <cfif IsDefined("Form.business_card_name") and Trim(#Form.business_card_name#) NEQ "">'#Form.business_card_name#',</cfif>
                    <cfif IsDefined("Form.business_card_name_kana") and Trim(#Form.business_card_name_kana#) NEQ "">'#Form.business_card_name_kana#',</cfif>
                    <cfif IsDefined("Form.business_card_yaku") and Trim(#Form.business_card_yaku#) NEQ "">'#Form.business_card_yaku#',</cfif>
                    <cfif IsDefined("Form.mobile_phone") and Trim(#Form.mobile_phone#) NEQ "">'#Form.mobile_phone#',</cfif>
                    <cfif IsDefined("Form.mobile_phone2") and Trim(#Form.mobile_phone2#) NEQ "">'#Form.mobile_phone2#',</cfif>
                    <cfif IsDefined("Form.mail_1") and Trim(#Form.mail_1#) NEQ "">'#Form.mail_1#',</cfif>
                    <cfif IsDefined("Form.mail_2") and Trim(#Form.mail_2#) NEQ "">'#Form.mail_2#',</cfif>
                    
                    <cfif IsDefined("Form.busyo") and Trim(#Form.busyo#) NEQ "">'#Form.busyo#',</cfif>
                    <cfif IsDefined("Form.postno") and Trim(#Form.postno#) NEQ "">'#Form.postno#',</cfif>
                    <cfif IsDefined("Form.address") and Trim(#Form.address#) NEQ "">'#Form.address#',</cfif>
                    <cfif IsDefined("Form.address2") and Trim(#Form.address2#) NEQ "">'#Form.address2#',</cfif>
                    <cfif IsDefined("Form.telno") and Trim(#Form.telno#) NEQ "">'#Form.telno#',</cfif>
                    <cfif IsDefined("Form.faxno") and Trim(#Form.faxno#) NEQ "">'#Form.faxno#',</cfif>
                    <cfif IsDefined("Form.biko") and Trim(#Form.biko#) NEQ "">'#Form.biko#',</cfif>
                    <cfif IsDefined("Form.department") and Trim(#Form.department#) NEQ "">'#Form.biko#',</cfif>
                    <!---'#Form.business_card_code#',--->
                    '#new_bccd#',
                    '#session.emp_code#',
                    '#session.emp_name#',
                    date_format('#this_daytime#','%Y/%m/%d %H:%i:%s')
                )
        </cfquery>
        
        <!---<cfif #URL.ad_wflg# IS 1>
            <input type="hidden" name="TORIHIKISAKI_TAB_FLAG" value="6">
            <script type="text/javascript">
                document.forms[0].method="POST"; // Request Method を指定します。
                document.forms[0].action="client_master_detail.cfm?client_cd=#client_code#"; // Request の送信先を指定します。
                document.forms[0].submit(); // Submitします。
            </script>
        <cfelse>--->
        
          <!---<cfif #URL.v_flg# eq 1>
        	<cflocation url="client_master_detail.cfm?client_cd=#URL.client_cd#" addtoken="no">
          <cfelse>
        	<cflocation url="client_master_syuusei.cfm?client_cd=#URL.client_cd#" addtoken="no">
          </cfif>--->
          
       <!--- </cfif>--->
    <!---<cfelse>
        <cfif #URL.ad_wflg# IS 1>
            <input type="hidden" name="TORIHIKISAKI_TAB_FLAG" value="6">
            <script type="text/javascript">
                alert('コードが重複しています。A');
                document.forms[0].method="POST"; // Request Method を指定します。
                document.forms[0].action="client_master_detail2.cfm?client_cd=#client_code#&ad_wflg=#URL.ad_wflg#"; // Request の送信先を指定します。
                document.forms[0].submit(); // Submitします。
            </script>
        <cfelse>
            <script type="text/javascript">
                alert('コードが重複しています。B');
                document.forms[0].method="POST"; // Request Method を指定します。
                document.forms[0].action="business_card_master.cfm?ad_wflg=#URL.ad_wflg#"; // Request の送信先を指定します。
                document.forms[0].submit(); // Submitします。
            </script>
        </cfif>
    </cfif>--->
</cfform>

  <cfif #URL.v_flg# eq 1>
	<script type="text/javascript">
        document.forms[0].method="POST"; // Request Method を指定します。
        document.forms[0].action="client_master_detail.cfm?#CGI.QUERY_STRING#"; // Request の送信先を指定します。
        document.forms[0].submit(); // Submitします。
    </script>
  
    <!---<cflocation url="client_master_detail.cfm?v_flg=#URL.v_flg#&client_cd=#URL.client_cd#">--->
  <cfelse>
	<script type="text/javascript">
        document.forms[0].method="POST"; // Request Method を指定します。
        document.forms[0].action="client_master_syuusei.cfm?#CGI.QUERY_STRING#"; // Request の送信先を指定します。
        document.forms[0].submit(); // Submitします。
    </script>
    <!---<cflocation url="client_master_syuusei.cfm?v_flg=#URL.v_flg#&client_cd=#URL.client_cd#">--->
  </cfif>



</cfoutput>
</body>
</html>
