<!DOCTYPE HTML>
<html>
<head>
<meta charset="UTF-8">
<meta name="author" content="GridSystemGenerator.com - v1.02" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<title>取引先詳細 | iMainteCenter </title>

<cfscript>
	str_title="取引先詳細";
	view_return="CCR_main.cfm";
</cfscript>


<style>
	.cursor_pointer{
		cursor:pointer;
	}


</style>







</head>

<body>


<cfset rtn_scrn="client_master.cfm?#CGI.QUERY_STRING#">
<cfif isdefined("url.rtn_scrn") and url.rtn_scrn eq 'none'>
    <cfset rtn_scrn="none">
</cfif>


<cfinclude template="topmenu.cfm">
<div class="clouds" >

<!---<cfquery datasource="#application.dsn#" name="qGetBizType">
    SELECT business_type_code,
           business_type_name
      FROM m_business_type
     WHERE kaisya_code = '#session.kaisya_code#'
</cfquery>--->

<cfoutput>

  

  <cfif IsDefined("URL.seach") eq false>
    <cfset URL.seach = "">
  </cfif>
  <cfif IsDefined("URL.cl_flg") eq false>
    <cfset URL.cl_flg = "">
  </cfif>
  <cfif IsDefined("URL.sort_flg") eq false>
    <cfset URL.sort_flg = "">
  </cfif>
	<!---<cfform name="client_mst_new" method="post">--->
	<!---<cfform action="client_master_update.cfm" name="client_mst_new" method="post">--->
	<cfform action="client_master_syuusei.cfm?#CGI.QUERY_STRING#" name="client_mst_new" method="post">
    <cfset action_page="client_master_syuusei.cfm?#CGI.QUERY_STRING#">

	<cfset tori_wflg = 1>

    <!---<cfif IsDefined("cfgridkey") is false>
		<cfset cfgridkey = #Form.client_code#>
    <cfelse>
    	<cfset cfgridkey = #cfgridkey#>
    </cfif>--->
    <!---<cfif IsDefined("URL.client_cd") is false>
	<!---
		<cfset cfgridkey = #Form.client_code#>
	--->
    <cfelse>
    	<cfset cfgridkey = #URL.client_cd#>
    </cfif>--->
	
        
    <cfquery datasource="#application.dsn#" name="qGetClient">
    	 select m_client.client_code,
         		<!---old_client_code,
         		client_eda,--->
         		m_client.client_name,
         		m_client.client_name_kana,
                m_client.ryk_name1,
                m_client.ryk_name2,
                m_client.post_no1,
                m_client.address_1,
                m_client.address_2,
                m_client.address_3,
                m_client.tel_no1,
                m_client.fax_no1,
                <!---m_client.memo,
                m_client.b_post_no,
                m_client.b_adr1,
                m_client.b_adr2,
                m_client.b_adr3,
                m_client.b_tel_no,
                m_client.b_fax_no,
                m_client.b_memo,
                m_client.c_post_no,
                m_client.c_adr1,
                m_client.c_adr2,
                m_client.c_adr3,
                m_client.c_tel_no,
                m_client.c_fax_no,
                m_client.c_memo,
                m_client.sofski1_code,
                m_client.sofski2_name,
                m_client.sofski2_code,--->
                m_client.url_address,
                <!---m_client.daihyo_yksk,
                m_client.president_name,
                m_client.president_name_kana,
                date_format(m_client.birth_ymd, '%Y/%m/%d %H:%i:%s') as birth_ymd,
                date_format(m_client.foundation_date, '%Y/%m/%d %H:%i:%s') as foundation_date,
                m_client.capital,
                m_client.yearly_tumover,
                m_client.jygin_su,
                m_client.ksn_mm,--->
                m_client.tantou_name,
                <!---m_client.kri_tan,
                m_client.zngnky_code,
                m_client.bank_name,
                m_client.zngn_stncode,
                m_client.stn_name,
                m_client.kouzasbt_kbn,
                m_client.kouza_no,
                m_client.kouzameigi_kana,
                m_client.tsry_kbn,
                m_client.nykkouza_code,
                m_client.gnknksyu_rate,
                m_client.sp_jkn,--->
                <!---m_client.nykytipri_flg,--->
                <!---m_client.seiksime_ymd1,
                m_client.nykyti_mm1,
                m_client.nykyti_ymd1,
                m_client.seikmemo1,
                m_client.seiksime_ymd2,
                m_client.nykyti_mm2,
                m_client.nykyti_ymd2,
                m_client.seikmemo2,
                m_client.seiksime_ymd3,
                m_client.nykyti_mm3,
                m_client.nykyti_ymd3,
                m_client.seikmemo3,
                m_client.uragtan_code,--->
                m_client.uragtanbmn_code,
                m_section.section_name,
                <!---m_client.ksyutan_code,
                m_client.ksyutanbmn_code,
                m_client.business_type,
                m_client.jigyo_niyo,
                m_client.shyy_trhkski1,
                m_client.shyy_trhkski2,
                m_client.shyy_trhkski3,
                m_client.shyy_siireski1,
                m_client.shyy_siireski2,
                m_client.shyy_siireski3,--->
                m_client.up_emp,
                <!---m_client.snseibmn_code,
                m_client.tkty,
                m_client.snk_sry_p,
                m_client.snk_sry_f,
                m_client.tdb_tssy_p,
                m_client.tdb_tssy_f,
                m_client.sysi_ari_flg,
                m_client.syanai_rank,
                m_client.hnko_inf,--->
                m_client.nowork_flg,
                case m_client.nowork_flg when 1 then '取引中' when 2 then '管理' when 3 then '休止' when 4 then '新規' else '' end as char_nowork_flg,
                m_client.biko,
                m_client.cr_code,

                m_client.up_code as up_code,
                m_client.up_name as up_name,
                trim(concat(m_client.up_code, ' ', ifnull(m_client.up_name,''))) as up_emp_code_name,                
                date_format(m_client.up_date, '%Y/%m/%d %H:%i:%s') as up_date,
                m_client.koushin_emp as koushin_emp,
                m_client.koushin_emp as koushin_emp_name,
                trim(concat(m_client.koushin_emp, ' ', ifnull(m_client.koushin_emp_name,''))) as koushin_emp_code_name,                
                date_format(m_client.koushin_date, '%Y/%m/%d %H:%i:%s') as koushin_date,
                m_client.client_flag,
                <!---m_client.up_cnt ,
                m_client.brcd,--->
                case m_client.rounding_kbn when 1 then '切り捨て' when 2 then '四捨五入' when 3 then '切り上げ' else '' end as char_rounding_kbn,
                m_client.seikyusaki_code,
                m_client.cust_flag,
                m_client.supp_flag,
                m_client.seller_flag,
                case when m_client.cust_flag = 1 then '顧客コード' when m_client.supp_flag = 1 then '委託先コード' when m_client.seller_flag = 1 then '購買先コード' end as cust_supp_seller_title,
                case m_client.seiksime_ymd1 when 31 then '末日' when null then '' else concat(cast(m_client.seiksime_ymd1 as char), '日') end as char_seiksime_ymd1,
                case m_client.nykyti_ymd1 when 31 then '末日' when null then '' else concat(cast(m_client.nykyti_ymd1 as char), '日') end as char_nykyti_ymd1,
                case m_client.nykyti_mm1 when 0 then '当月' when 1 then '翌月' when 2 then '翌々月' else '' end as char_nykyti_mm1,
                m_client.nyuukin_houhou_code,     
                m_client.urikake_hojyo_kamoku_code,   
                m_client.urikake_hojyo_kamoku_name,  
                m_client.jisha_flag,
                case m_client.jisha_flag when 1 then '自社' else '他社' end as c_jisha_flag,
                Y(t_geometory.geo) latitude,
                X(t_geometory.geo) longitude,
                login_id,
                password,
                m_client.section_code as supp_section_code
           from m_client left outer join m_section on m_client.kaisya_code = m_section.kaisya_code AND m_client.section_code = m_section.section_code 
                         left outer join t_geometory on m_client.kaisya_code = t_geometory.kaisya_code AND m_client.client_code = t_geometory.client_code
                                                  <!--- and m_client.uragtanbmn_code = m_section.section_code ---> 

          where m_client.kaisya_code = '#session.kaisya_code#' and
          		m_client.client_code = '#URL.client_cd#'
          		<!--- client_code = '#cfgridkey#'--->

    </cfquery>

    <cfquery datasource="#application.dsn#" name="qGetReport">
        SELECT
            t_report.slip_num,
            t_report.client_code,
            t_report.unit_code,
            t_report.unit_name,
            DATE_FORMAT(t_report.work_date,'%Y/%m/%d') work_date,
            t_report.update_date
        FROM t_report
       WHERE t_report.kaisya_code = '#session.kaisya_code#'
        AND t_report.client_code = '#url.client_cd#'
        AND t_report.del_flag <> 1
    </cfquery>
    <cfquery datasource="#application.dsn#" name="qGetTClient">
        SELECT m_section.section_name 
          FROM t_client LEFT OUTER JOIN m_section ON t_client.kaisya_code  = m_section.kaisya_code    
                                                 AND t_client.section_code = m_section.section_code 
         WHERE t_client.kaisya_code = '#session.kaisya_code#'
           AND t_client.client_code = '#URL.client_cd#' 
    </cfquery>

    <!---<cfif #qGetClient.old_client_code# neq ''>
    	<cfset old_cl_cd = #qGetClient.old_client_code#>
    <cfelse>
    	<cfset old_cl_cd = ''>
    </cfif>
    <cfif #qGetClient.client_eda# neq ''>
    	<cfset cl_eda = #qGetClient.client_eda#>
    <cfelse>
    	<cfset cl_eda = ''>
    </cfif>--->
    
	<!---<cfif #qGetClient.client_flag# eq 1 or #qGetClient.client_flag# eq 3>
    	<cfset Form.TORIHIKISAKI_TAB_FLAG = 9>
    </cfif>--->
	<cfif #qGetClient.cust_flag# eq 1>
    	<cfset Form.TORIHIKISAKI_TAB_FLAG = 9>
    </cfif>
    
    <!---<cfquery datasource="#application.dsn#" name="qGetBizType">
    	SELECT business_type_code,
        	   business_type_name
          FROM m_business_type
         WHERE kaisya_code = '#session.kaisya_code#'
    </cfquery>--->

	<!---<cfset cl_cd = #cfgridkey#>--->
	<cfset cl_cd = #qGetClient.client_code#>
    <cfset cfgridkey = "">

    <!---<cfquery datasource="#application.dsn#" name="qGetShop">
    SELECT shop_code,
           shop_name,
           shop_tantou
      FROM m_shop
     WHERE kaisya_code = '#session.kaisya_code#'
       and client_code = '#cl_cd#'
    order by shop_code
    </cfquery>--->
    
    <cfquery datasource="#application.dsn#" name="qGetAddress">
    SELECT business_card_code as bc_cd,
           business_card_name as bc_name,
           department as dptmt,
          
           post
      FROM m_business_card
     WHERE kaisya_code = '#session.kaisya_code#'
       and client_code = '#cl_cd#'
    </cfquery> 
 
 
    <cfquery datasource="#application.dsn#" name="qGetUnit">
    SELECT unit_code,
           unit_name,
           u_model,
           u_manufacturer,
           u_reibai_kind
      FROM m_unit
     WHERE kaisya_code = '#session.kaisya_code#'
       and client_code = '#cl_cd#'
       and del_flag = 0
    </cfquery> 

    <cfquery datasource="#application.dsn#" name="qGetNendo">
    	Select kaikei_nendo
          From m_company
         Where kaisya_code = '#session.kaisya_code#'
    </cfquery>
    
    
    <cfquery datasource="#application.dsn#" name="qGetEmp">
    	SELECT emp_code,
        	   name
          FROM m_emp
         WHERE kaisya_code = '#session.kaisya_code#'
           <!---and m_emp.emp_code = '#session.emp_code#'--->
		order by emp_code
    </cfquery>
    
    <!---<cfquery datasource="#application.dsn#" name="qGetSec">
      Select section_code,
             section_name
        From m_section
       Where kaisya_code = '#session.kaisya_code#'
      order by section_code
    </cfquery>--->
    
    <!--- 取引先担当者一覧 --->
    <cfquery datasource="#application.dsn#" name="qGetClientTan">
    	Select emp_code,
        	   emp_name,
               section_code,
               section_name,
               main_flg,
               case main_flg when 1 then '●' else '' end as char_main_flg
          From t_client_tantou
         where kaisya_code = '#session.kaisya_code#'
           and client_code = '#cl_cd#'
      order by main_flg desc, emp_code asc
           <!---and client_code = '#URL.client_cd#'--->
    </cfquery>
    <!--- 主担当がいるかどうか --->
    <cfquery datasource="#application.dsn#" name="qGetCMainTan">
    	Select count( emp_code ) as main_emp
          From t_client_tantou
         where kaisya_code = '#session.kaisya_code#'
           and client_code = '#cl_cd#'
           and main_flg = 1
           <!---and client_code = '#URL.client_cd#'--->
    </cfquery>

    <cfquery datasource="#application.dsn#" name="qGetEmpAuth">
        Select authority_flag
          From m_emp
         Where kaisya_code = '#session.kaisya_code#'
           and emp_code = '#session.emp_code#'
    </cfquery>

    
<!---     <cfif #qGetAddress.max_bc_cd# eq "">
      <cfset new_bccd = "00001">
    <cfelse>
      <cfset new_bccd = right("00000" & #qGetAddress.max_bc_cd# + 1, 5)>
    </cfif> --->    
    <!--- 今日の日付 --->
    <cfset now_day = #DateFormat(NOW(), 'yyyy/mm/dd')#>




  <cfif IsDefined("URL.v_flg") and #URL.v_flg# eq 5>
    <cfset ret_wind = "ls_client_list.cfm?sales_cd=" & #URL.sales_cd#>
  <cfelseif IsDefined("URL.v_flg") and #URL.v_flg# eq 4>
    <cfset ret_wind = "CCR_main.cfm">
  <cfelseif IsDefined("URL.v_flg") and #URL.v_flg# eq 3>
  	<cfset ret_wind = "ls_detail.cfm?sales_cd=" & #URL.sales_cd#>
  <cfelse>
    <cfset ret_wind = "client_master.cfm">
  </cfif>

  <!--- テーブルの背景セット(委託先の場合緑色) --->
  <cfset bg_color_class = "blue_table01">
  <cfif qGetClient.supp_flag eq 1>
      <cfset bg_color_class = "green_table01">
  </cfif>

  <div class="white_box" style="width:1024px;  
	margin-left: auto;
	margin-right: auto; padding-bottom:500px;
	 -moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px; margin-bottom:5px;" align="center">


   
    <div style="width:960px; margin-left:auto; margin-right:auto;" >
    
    
    
    <!--タイトルとボタン類-->
      <table width="960" border="0" cellpadding="0" cellspacing="0" style=" padding:15px 0px 10px; font-size:11px; letter-spacing:0.1em; color: rgb(0,38,129); ">
        <tr>
          <td width="" rowspan="2"  style="font-size:22px; color:rgb(0,88,176); letter-spacing:0.3em;  text-align:left;">#str_title#</td>

          <td width="220" align="left">登録日時：#qGetClient.up_date#</td>
          <td width="220" align="left">登録者：#qGetClient.up_emp_code_name#</td>
            
          <td rowspan="2" align="right">
            <input type="button" name="rtn_btn" class="bt_edit_s" value="" tabindex = "-1" onclick="return InputCheck('#action_page#');">
            <input type="button" name="b_del" class="bt_delete_s" value="" tabindex = "-1" onclick="return Delete();">
          </td>
        </tr>
        <tr>
          <td width="220" align="left">変更日時：#qGetClient.koushin_date#</td>
          <td width="220" align="left">変更者：#qGetClient.koushin_emp_code_name#</td>
        </tr>
      </table>
      <!--タイトルとボタン類-->

 


   <!--左サイド　基本情報box-->
    <table width="340" class="#bg_color_class#" style=" float:left;"  border="0" cellpadding="0" cellspacing="0">
      <tr>
        <th colspan="2" class="">基　本　情　報</th>
      </tr>
      
      <tr>
        <th height="27" width="80" align="right">取引先コード
          <input type="hidden" name="k_flg" value="#qGetClient.client_flag#"></th>
        <td align="left">#cl_cd#
          <input type="hidden" name="client_code" value="#cl_cd#">
          <input type="hidden" name="main_emp" value="#qGetCMainTan.main_emp#"></td>
      </tr>
      
      <tr>
        <th height="27" align="right">#qGetClient.cust_supp_seller_title#&nbsp;</th>
        <td align="left">#qGetClient.cr_code#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">取引先種別</th>
        <td align="left">
          <input type="CheckBox" name="cust_flag" disabled="no" <cfif #qGetClient.cust_flag# is "1">checked</cfif> >顧客
          <input type="CheckBox" name="supp_flag" disabled="no" <cfif #qGetClient.supp_flag# is "1">checked</cfif> >委託先
          <input type="CheckBox" name="seller_flag" disabled="no" <cfif #qGetClient.seller_flag# is "1">checked</cfif> >購買先</td>
      </tr>
      
      <tr>
        <th height="27" align="right">ふりがな</th>
        <td align="left">#qGetClient.client_name_kana#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">取引先名</th>
        <td align="left">#qGetClient.client_name#</td>
      </tr>

      <tr>
        <th height="27" align="right">略 称</th>
        <td align="left">#qGetClient.ryk_name1#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">部 　署</th>
        <td align="left">#qGetClient.tantou_name#</td>
      </tr>
      <cfif #qGetClient.supp_flag# is "1">
          <tr>
            <th height="27" align="right">ログインID</th>
            <td align="left">#qGetClient.login_id#</td>
          </tr>
          
          <tr>
            <th height="27" align="right">パスワード</th>
            <td align="left">
                <font size="1">
                <cfloop index='i' from="1" to="#Len(qGetClient.password)#">
                    ●
                </cfloop>
                </font>
            </td>
          </tr>
      </cfif>
<!---       <tr >
        <th height="27" align="right">自社/他社</th>
        <td align="left">#qGetClient.c_jisha_flag#<cfif #qGetClient.supp_section_name# neq "">（部門：#qGetClient.supp_section_name#）</cfif></td>
      </tr> --->
      
<!---       <tr>
        <th height="27" align="right">請 求 先</th>
        <td align="left">#qGetClient.seikyusaki_code#&nbsp;&nbsp;#qGetClient.seikyusaki_name#</td>
      </tr> --->
      
      <tr>
        <th height="27" align="right">取引状況</th>
        <td align="left">#qGetClient.char_nowork_flg#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">郵便番号</th>
        <td align="left">#qGetClient.post_no1#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">住 所</th>
        <td align="left">#qGetClient.address_1#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">ビル名等</th>
        <td align="left">#qGetClient.address_2#</td>
      </tr>
      <tr>
        <th height="27" align="right">緯度</th>
        <td align="left">#qGetClient.latitude#</td>
      </tr>
      
      <tr>
        <th height="27" align="right">経度</th>
        <td align="left">#qGetClient.longitude#</td>
      </tr>      
      <tr>
        <th height="27" align="right">電話番号</th>
        <td align="left">#qGetClient.tel_no1#</td>
      </tr>
      
      <tr >
        <th height="27" align="right">FAX番号</th>
        <td align="left">#qGetClient.fax_no1#</td>
      </tr>
      

      <tr>
        <th height="27" align="right">U　R　L</th>
        <td align="left"><a href="#qGetClient.url_address#" target="_blank">#qGetClient.url_address#</a></td>
      </tr>
    </table>
    <!--左サイド　基本情報box-->
 
 

<!--中央センター　box-->
  <div style="width:330px; float:left;  padding-left:10px;">
  
    <table width="330" border="0" cellpadding="0" cellspacing="0" class="#bg_color_class#">
      <tr>
         <th width="" class="" style="vertical-align:middle; ">
           <span style=" display:inline-block; width:215px;">取&nbsp;引&nbsp;先&nbsp;担&nbsp;当&nbsp;者</span>
           <img src="images2014/plus_icon1.png" class="cursor_pointer" height="18" width="18" border="0" onMouseOver="this.src='images2014/plus_icon2.png'"
           onMouseOut="this.src='images2014/plus_icon1.png'" style="vertical-align:middle;" onClick="clusr_add('client_cd=#URL.client_cd#&seach=#URLEncodedFormat(URL.seach)#&cl_flg=#URL.cl_flg#&sort_flg=#URL.sort_flg#&ad_wflg=1&v_flg=1&supp_flg=#qGetClient.supp_flag#');">
        </th>
      </tr>
    </table>
<!---     <div style="margin:20px;margin-bottom:20px;">
        <table width="300"  border="0" cellpadding="0" cellspacing="0" class="#bg_color_class#"  style="float:left; font-size:12px;">
          <!--- 基本情報枠 --->
          <tr>
            <th height="" colspan="2" id="blue-title01">基　本　情　報</th>
          </tr>
          
          <tr>
            <th width="80">登録コード</th>
            <td width="" align="left">&nbsp;&nbsp;#new_bccd#
              <!---<input type="text" id="nyuryoku" name="business_card_code" value="#new_bccd#" maxlength="5" tabindex="1" style="ime-mode:disabled;" /></td>--->
              <input type="hidden" id="nyuryoku" name="business_card_code" value="#new_bccd#" /></td>
          </tr>
          
          <tr>
            <th>か　　な</th>
            <td align="left">
              <input type="text" id="rudy" name="business_card_name_kana" class="input_text1_p tab_index" maxlength="50" style="width:230px;" />
          </tr>
          
          <tr>
            <th>氏　　名</th>
            <td align="left">
              <input type="text" id="name" name="business_card_name" class="input_text1_p tab_index" maxlength="50" style="width:230px;" />
          </tr>
          <tr>
            <th>役　　職</th>
            <td align="left">
              <input type="text" id="yaku" name="business_card_yaku" class="input_text1 tab_index" maxlength="25" style="width:230px;"/>
          </tr>
          <tr>
            <th>携　帯　1</th>
            <td align="left">
              <input type="text" name="mobile_phone" class="input_text1 tab_index" maxlength="15" <!---onblur="return PhoneNoCheck(this.value, 10);"---> style="width:230px; ime-mode:disabled;" />
          </tr>
          <tr>
            <th>携　帯　2</th>
            <td align="left">
              <input type="text" name="mobile_phone2" class="input_text1 tab_index" maxlength="15" <!---onblur="return PhoneNoCheck(this.value, 10);"---> style="width:230px; ime-mode:disabled;" />
          </tr>
          <tr>
            <th>E-mail 1</th>
            <td align="left">
              <input type="text" name="mail_1" class="input_text1 tab_index" maxlength="254" <!---onblur="return MailAddressCheck(this.value, 11);"---> style="width:230px; ime-mode:disabled;" />
          </tr>
          <tr>
            <th>E-mail 2</th>
            <td align="left">
              <input type="text" name="mail_2" class="input_text1 tab_index" maxlength="254" <!---onblur="return MailAddressCheck(this.value, 12);"---> style="width:230px; ime-mode:disabled;" />
          </tr>
        </table>
    </div> --->
    <div style="height:175px; width:330px;  overflow:hidden; overflow-y:scroll;  border:rgb(154,214,255)  solid 1px; background-color:rgba(255,255,255,0.9);">  
        <table width="330" class="#bg_color_class#" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <th width="100"  style=" border-left:none; border-top:none;">氏 名</td>
                <th width="90" style=" border-top:none;">役 職</td>
                <th width="90" style=" border-top:none; border-right:none;">所 属</td>
            </tr>
            <cfloop index="x" from="1" to="#qGetAddress.recordcount#">
            <tr>
                <td align="left" style=" border-left:none; border-top:none;"><a href="bc_master_detail_read.cfm?client_cd=#URL.client_cd#&seach=#URLEncodedFormat(URL.seach)#&cl_flg=#URL.cl_flg#&sort_flg=#URL.sort_flg#&ad_wflg=1&bc_code=#qGetAddress.bc_cd[x]#&v_flg=1&supp_flg=#qGetClient.supp_flag#">#qGetAddress.bc_name[x]#</a></td>
                <td style="text-align:left;" >#qGetAddress.post[x]#</td>
                <td style="text-align:left; border-right:none;">#qGetAddress.dptmt[x]#</td>
            </tr>
            </cfloop>
        </table>
    </div>
    
    <table width="330" height="" class="#bg_color_class#" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <th  class="" height="">自&nbsp;社&nbsp;担&nbsp;当&nbsp;事&nbsp;業&nbsp;所</th>
      </tr>
      <tr>
        <td height="64"> 
            <cfloop index="i" from="1" to="#qGetTClient.RecordCount#">
                #qGetTClient.section_name[i]#<br>
            </cfloop>
          <!--- <input type="hidden" name="tan_ei_h" value="#qGetClient.uragtanbmn_code#"> --->
        </td>
      </tr>
    </table>



<!---     <table width="330"   border="0" cellpadding="0" cellspacing="0">
      <tr>
       <th width="" class="blue-title01" style="vertical-align:middle; "> 
         <span style=" display:inline-block; width:218px;">自&nbsp;社&nbsp;担&nbsp;当&nbsp;者</span>
         <img src="images2014/plus_icon1.png" class="cursor_pointer" height="18" width="18" border="0" onMouseOver="this.src='images2014/plus_icon2.png'"
          onMouseOut="this.src='images2014/plus_icon1.png'" style="vertical-align:middle;"  onClick="select_tan();"></th>
      </tr>
    </table>
      <div style="height:150px; width:330px;  overflow:hidden; overflow-y:scroll;  border:rgb(154,214,255)  solid 1px; background-color:rgba(255,255,255,0.9);">  
    <table width="330" class="#bg_color_class#" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <th width="90" style="border-top:none; border-left:none;">社員番号</td>
        <th width="140" style="border-top:none;">氏 名</td>
        <th width="50"  style="border-top:none; border-right:none;">主</td>
      </tr>
      <cfloop index="n" from="1" to="#qGetClientTan.recordcount#">
      <tr>
        <td style="border-left:none; text-align:center">#qGetClientTan.emp_code[n]#</td>
        <td style="text-align:left">#qGetClientTan.emp_name[n]#</td>
        <td style="border-right:none;" align="center" >#qGetClientTan.char_main_flg[n]#</td>
      </tr>
      </cfloop>
    </table>
    </div> --->
      
  </div>
<!--中央センター　box-->
     <!--右サイド　請求関連タブbox--> 
    <div style="width:270px; float:right; overflow:hidden; ">
        <!--- 顧客の場合ユニットの一覧も表示 --->
        <cfif qGetClient.cust_flag eq 1>
            <ul class="tab">
                <li class="select" style="width:60px;">ユニット</li>
                <li style="width:60px;">作　業</li>
                <li style="width:60px;">概　要</li> 
            </ul>

         	<div class="content2" style="width:270px; height:452px; background-color: rgba(255,255,255,0.6);" align="center">
            	<!--- 概要 --->
                <li style="list-style:none;">
                     <div style="height:400px; width:330px;overflow-y:scroll; solid 1px; padding-top:15px;">  
                        <table width="330" class="#bg_color_class#" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <th width="90" style="border-top:none; border-left:none;text-align:left;">ユニット</th>
                            <th width="140" style="border-top:none;text-align:left">型式</th>
                            <!--- <th width="50"  style="border-top:none; border-right:none;">冷媒</th> --->
                        </tr>
                            <cfloop index="n" from="1" to="#qGetUnit.RecordCount#">
                                <tr>
                                    <td style="border-left:none; text-align:left"><a href="m_unit_detail.cfm?u_code=#qGetUnit.unit_code[n]#&c_code=#URL.client_cd#&rtn_scrn=none" target="_blank">#qGetUnit.unit_name[n]#</a></td>
                                    <td style="text-align:left">#qGetUnit.u_model[n]#</td>
                                    <!--- <td style="border-right:none;" align="center" >abcdefghi</td> --->
                                </tr>
                            </cfloop>
                        </table>
                    </div>
                </li>
                <li class="hide">
                     <div style="height:400px; width:330px;overflow-y:scroll; solid 1px; padding-top:15px;">  
                        <table width="330" class="#bg_color_class#" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <th width="90" style="border-top:none; border-left:none;text-align:left;">作業日</th>
                            <th width="140" style="border-top:none;text-align:left">ユニット</th>
                            <!--- <th width="50"  style="border-top:none; border-right:none;">冷媒</th> --->
                        </tr>
                            <cfloop index="cnt" from="1" to="#qGetReport.RecordCount#">
                                <tr>
                                    <td style="border-left:none; text-align:left"><a href="t_report_detail.cfm?s_num=#qGetReport.slip_num[cnt]#&v_flg=3&seach=&eq_page=&sort_flg=&d_frm=&d_to=&rtn_scrn=none" target="_blank">#qGetReport.work_date[cnt]#</a></td>
                                    <td style="text-align:left">#qGetReport.unit_name[cnt]#</td>
                                    <!--- <td style="border-right:none;" align="center" >abcdefghi</td> --->
                                </tr>
                            </cfloop>
                        </table>
                    </div>
<!---                     <div style='height:300px;overflow-y:auto'>
                        <table width="960" cellpadding="0" cellspacing="0" border="0" class='upside-table' style="margin-top:10px;">
                            <!--- 基本情報枠 --->
                            <tr class="oh_tr">
                                <td width="10%" align="left">
                                </td>
                                <td width="20%"align="left">
                                  修理日
                                </td>                       
                                <td width="35%" align="left">
                                  原因
                                </td>                       
                                <td width="35%" align="left">
                                  処置
                                </td>                                                                       
                            </tr>
                                <cfloop index="cnt" from="1" to="#qGetReport.RecordCount#" >                
                                    <cfif #cnt# LTE #qGetReport.RecordCount#>
                                        <tr style=" border-left:none;">
                                    
                                            <!---<td width="10" height="26" align="center"  style="padding:0px 5px ; border-right:none;">--->
                                            <td width="20" height="26" align="center">
                                            <!--- <a href="bc_master_detail_read.cfm?ad_wflg=2&bc_code=#qGetBusinessCard.bc_code[cnt]#"> --->
                                            <a href="t_report_detail.cfm?s_num=#qGetReport.slip_num[cnt]#&v_flg=3&seach=&eq_page=&sort_flg=&d_frm=&d_to=&rtn_scrn=none" target="_blank">
                                            <img  src="images2014/arrow_icon1.png" height="18" width="18" border="0" 
                                            onMouseOver="this.src='images2014/arrow_icon2.png'" onMouseOut="this.src='images2014/arrow_icon1.png'"  style="vertical-align:middle;"></a>
                                            </td>
                                             <!---<td align="right" width="90"  style="padding:0px 5px; ">--->
                                            <td width="" align="center" style="padding:0px 5px; text-align:left;">#qGetReport.work_date[cnt]#</td> 
                                            <td width="" align="center" style="padding:0px 5px; text-align:left;">#qGetReport.cause[cnt]#</td>
                                            <td width="" align="center" style="padding:0px 5px; text-align:left;">#qGetReport.measures[cnt]#</td>
                                            <!---<td >#client_code#</td>--->
                                        </tr>          
                                    </cfif>
                                </cfloop>
                        </table>
                    </div> --->
                </li>                 
                <li class="hide">
                    <table width="240" border="0" cellpadding="0" cellspacing="0" align="center"  style=" padding-top:15px; display:inline-block;"  class="#bg_color_class#" >
                		<tr>
                			<th height="24"  style="text-align:center;">概　　要</th>
                		</tr>
                		<tr>
                			<td align="center" style="border: rgb(168,207,230) solid 1px; border-top:none; color: rgb(40,40,40); background-color:rgba(255,255,255,0.9);">
                				<textarea name="gaiyou" disabled="disabled"  class="textarea_text1" style="width:220px; height:380px; margin:5px;">#qGetClient.biko#</textarea>
                			</td>
                		</tr>
                	</table> 
                </li>         
            </div>
        <cfelse>
            <div class="content2" style="width:270px; height:452px; background-color: rgba(255,255,255,0.6);" align="center">
                <table width="240" border="0" cellpadding="0" cellspacing="0" align="center"  style=" padding-top:15px; display:inline-block;"  class="#bg_color_class#" >
                    <tr>
                        <th height="24"  style="text-align:center;">概　　要</th>
                    </tr>
                    <tr>
                        <td align="center" style="border: rgb(168,207,230) solid 1px; border-top:none; color: rgb(40,40,40); background-color:rgba(255,255,255,0.9);">
                            <textarea name="gaiyou" disabled="disabled"  class="textarea_text1" style="width:220px; height:380px; margin:5px;">#qGetClient.biko#</textarea>
                        </td>
                    </tr>
                </table>
            </div>             
        </cfif>

    </div><!--右サイド　請求関連タブbox-->
  

</div>    



<!--- (end)コンテンツ　main --->    
</div>




    </cfform>
</cfoutput>

<cfinclude template="copyright.cfm">





<script type="text/javascript">

	$(document).ready(function() {
		
		// enable form tips
		$('form .help').formtips({ 
			tippedClass: 'tipped'
		});
		
	});

</script>

<!--- タブ --->
<script>

$(function() {
	//クリックしたときのファンクションをまとめて指定
	$('.tab li').click(function() {

		//.index()を使いクリックされたタブが何番目かを調べ、
		//indexという変数に代入します。
		var index = $('.tab li').index(this);

		//コンテンツを一度すべて非表示にし、
		$('.content2 li').css('display','none');

		//クリックされたタブと同じ順番のコンテンツを表示します。
		$('.content2 li').eq(index).css('display','block');

		//一度タブについているクラスselectを消し、
		$('.tab li').removeClass('select');

		//クリックされたタブのみにクラスselectをつけます。
		$(this).addClass('select')
	});
});


</script>


    
	<script type="text/javascript">
        <!--
        function NumCheck(){
            var j_cd = document.client_mst_new.client_code.value;
            
            if(isNaN(j_cd)){
                document.client_mst_new.client_code.value = "";
                document.client_mst_new.client_code.focus();
                alert('取引先コードは、数値で入力して下さい。');
                return false;
            }else{
                return true;
            }
        }
        //-->
    </script>
    
    <script type="text/javascript">
        function InputCheck(action_page){
            var j_cd = document.client_mst_new.client_code.value;
            
            if(j_cd == ""){
                document.client_mst_new.client_code.focus();
                alert('取引先コードを入力して下さい。');
                return false;
            }else{
//                <!---if(confirm('更新します。よろしいですか？')){--->
//                    return true;
//                <!---}else{
//                    return false;
//                }--->
				document.client_mst_new.method="POST";
				document.client_mst_new.action=action_page;
				document.client_mst_new.submit();
            }
        }

	//取引先削除
	function Delete(){
		var cl_cd = document.client_mst_new.client_code.value;
		if( confirm('この取引先を削除します。よろしいですか？\n注）取引先の担当者も削除されます。') ){
			document.forms[0].method="POST";
			document.forms[0].action="client_delete.cfm?client_cd=" + cl_cd;
			document.forms[0].submit();
			return true;
		}else{
			return false;
		}
	}
</script>

    </script>

    <script type="text/javascript">
        <!--
        function InputCheck2(cl_cd){
            var me_cd = document.client_mst_new.main_emp.value;
            var mflg = document.client_mst_new.main_flg.value;
			var cl = "0000" + cl_cd;
			var cln = cl.length;
			var clcd = cl.slice(-4,cln);
			
            <!---if(me_cd == "1"){
				if(mflg == "ON" ){
					document.client_mst_new.reset();
					document.client_mst_new.main_emp.focus();
					alert('既に主担当は登録されています。');
					return false;
				}else{					
					document.forms[0].method="POST";
					document.forms[0].action="tantou_touroku.cfm?client_cd=" + clcd;
					document.forms[0].submit();
					
				}
            }else{--->
				document.forms[0].method="POST";
				document.forms[0].action="tantou_touroku.cfm?client_cd=" + clcd;
				document.forms[0].submit();
			<!---}--->
        }
        //-->
    </script>
    
    <script type="text/javascript">
        <!--
        function PostCodeCheck(postcode, input_no){
            if(postcode.match(/^\d{3}-\d{4}$|^\d{3}-\d{2}$|^\d{3}$/)){
                return true;
            }else{
                if(postcode == ""){
                    return true;
                }else{
                    document.client_mst_new.elements[input_no].value = "";
                    document.client_mst_new.elements[input_no].focus();
                    alert('郵便番号の入力値が不正値です。');
                    return false;
                }
            }
        }
        //-->
    </script>
    
    <script type="text/javascript">
        <!--
        function PhoneNoCheck(phone_no, input_no){
            if(phone_no.match(/^[0-9-]{6,9}$|^[0-9-]{12}$/)){
                return true;
            }else{
                if(phone_no.match(/^\d{1,4}-\d{4}$|^\d{2,5}-\d{1,4}-\d{4}$/)){
                    return true;
                }else{
                    if(phone_no.match(/^\d{3}-\d{4}-\d{4}$|^\d{11}$/)){
                        return true;
                    }else{
                        if(phone_no.match(/^0\d0-\d{4}-\d{4}$/)){
                            return true;
                        }else{
                            if(phone_no == ""){
                                return true;
                            }else{
                                document.client_mst_new.elements[input_no].value = "";
                                document.client_mst_new.elements[input_no].focus();
                                alert('電話番号の入力値が不正値です。');
                                return false;
                            }
                        }
                    }
                }
            }
        }
        //-->
    </script>
    
    <script type="text/javascript">
        <!--
        function MailAddressCheck(mail_address, input_no){
            if(mail_address.match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)){
                return true;
            }else{
                if(mail_address.match(/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/)){
                    return true;
                }else{
                    if(mail_address.match(/^[A-Za-z0-9]+[\w-]+@[\w\.-]+\.\w{2,}$/)){
                        return true;
                    }else{
                        if(mail_address.match(/^[\w_-]+@[\w\.-]+\.\w{2,}$/)){
                            return true;
                        }else{
                            if(mail_address == ""){
                                return true;
                            }else{
                                document.client_mst_new.elements[input_no].value = "";
                                document.client_mst_new.elements[input_no].focus();
                                alert('メールアドレスの入力値が不正値です。');
                                return false;
                            }
                        }
                    }
                }
            }
        }
        //-->
    </script>

<!--- 自社担当者選択 --->
<script type="text/javascript">
<!--
  function select_tan(){
	var clcd = document.client_mst_new.client_code.value;
	
	document.forms[0].method="POST";
	document.forms[0].action="emp_select.cfm?client_cd=" + clcd + "&v_flg=1";
	document.forms[0].submit();
  }

//-->
</script>

<!--- 取引先ユーザー追加 --->
<script type="text/javascript">
<!--
  function clusr_add(query_string){

	var clcd = document.client_mst_new.client_code.value;
	
	document.forms[0].method="POST";
	document.forms[0].action="bc_master_new.cfm?" + query_string;
	document.forms[0].submit();
  }

//-->
</script>



<!--- 折衝記録画面ここから --->
<script type="text/javascript">
<!--
function KirokuUp(cl_cd, sl_cd){
	window.open("ls_kiroku.cfm?client_cd=" + cl_cd + "&sales_code=" + sl_cd, "", "width=500,height=500,resizable=yes,scrollbars=yes");
}
-->
</script>
<!--- 折衝記録画面ここまで--->

    
    
<!--- ENTERキー反応不可ここから --->
<script type="text/javascript">
<!--
function submitStop(e){

	if (!e) var e = window.event;

	if(e.keyCode == 13)
		return false;
}
-->
</script>
<!--- ENTERキー反応不可ここまで--->



</body>
</html>
