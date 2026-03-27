<cfinclude template = "init.cfm">

<!--- 詳細用変数 1.詳細 2.新規作成 3.編集 --->
<cfif StructKeyExists(form,"input_screen") and form.input_screen neq "">
  <cfset input_screen = form.input_screen>
<cfelse>
  <cfset input_screen = 1>
</cfif>

<cfif StructKeyExists(form,"shop_code") and form.shop_code neq "">
  <cfset shop_code = form.shop_code>
<cfelse>
  <cfset shop_code = "">
</cfif>

<cfif StructKeyExists(form,"area_code_ddlb") and form.area_code_ddlb neq "">
  <cfset area_code_ddlb = form.area_code_ddlb>
<cfelse>
  <cfset area_code_ddlb = "">
</cfif>

<!--- 現在画面状態定義無し --->
<cfif StructKeyExists(form,"list_screen") and form.list_screen neq "">
  <cfset list_screen = form.list_screen>
<cfelse>
  <cfset list_screen = 1>
</cfif>
<cfif StructKeyExists(form,"list_sort") and form.list_sort neq "">
  <cfset list_sort = form.list_sort>
<cfelse>
  <cfset list_sort = 1>
</cfif>
<cfif StructKeyExists(form,"list_page") and form.list_page neq "">
  <cfset list_page = form.list_page>
<cfelse>
  <cfset list_page = 1>
</cfif>

<cfset search_list_text_box = "">
<cfif StructKeyExists(Form, "search_list_text_box")>
  <cfif Form.search_list_text_box neq "">
    <cfset search_list_text_box = Form.search_list_text_box>
  </cfif>
</cfif>

<cfset search_list_site_code = "">
<cfif StructKeyExists(Form, "search_list_site_code")>
  <cfif Form.search_list_site_code neq "">
    <cfset search_list_site_code = Form.search_list_site_code>
  </cfif>
</cfif>

<cfif StructKeyExists(form,"search_list_area_code_ddlb") and form.search_list_area_code_ddlb neq "">
  <cfset search_list_area_code_ddlb = form.search_list_area_code_ddlb>
<cfelse>
  <cfset search_list_area_code_ddlb = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_prefecture_code_ddlb") and form.search_list_prefecture_code_ddlb neq "">
  <cfset search_list_prefecture_code_ddlb = form.search_list_prefecture_code_ddlb>
<cfelse>
  <cfset search_list_prefecture_code_ddlb = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_shop_key_flag") and form.search_list_shop_key_flag neq "">
  <cfset search_list_shop_key_flag = form.search_list_shop_key_flag>
<cfelse>
  <cfset search_list_shop_key_flag = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_shop_security_flag") and form.search_list_shop_security_flag neq "">
  <cfset search_list_shop_security_flag = form.search_list_shop_security_flag>
<cfelse>
  <cfset search_list_shop_security_flag = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_shop_status") and form.search_list_shop_status neq "">
  <cfset search_list_shop_status = form.search_list_shop_status>
<cfelse>
  <cfset search_list_shop_status = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_sheet_code_ddlb") and form.search_list_sheet_code_ddlb neq "">
  <cfset search_list_sheet_code_ddlb = form.search_list_sheet_code_ddlb>
<cfelse>
  <cfset search_list_sheet_code_ddlb = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_status_ddlb") and form.search_list_status_ddlb neq "">
  <cfset search_list_status_ddlb = form.search_list_status_ddlb>
<cfelse>
  <cfset search_list_status_ddlb = "All">
</cfif>


<cfif StructKeyExists(form,"search_list_partner_company") and form.search_list_partner_company neq "">
  <cfset search_list_partner_company = form.search_list_partner_company>
<cfelse>
  <cfset search_list_partner_company = "">
</cfif>
<cfif StructKeyExists(form,"search_list_production_factory") and form.search_list_production_factory neq "">
  <cfset search_list_production_factory = form.search_list_production_factory>
<cfelse>
  <cfset search_list_production_factory = "">
</cfif>
<cfif StructKeyExists(form,"search_list_delivery_base") and form.search_list_delivery_base neq "">
  <cfset search_list_delivery_base = form.search_list_delivery_base>
<cfelse>
  <cfset search_list_delivery_base = "">
</cfif>
<cfif StructKeyExists(form,"search_list_delivery_course") and form.search_list_delivery_course neq "">
  <cfset search_list_delivery_course = form.search_list_delivery_course>
<cfelse>
  <cfset search_list_delivery_course = "">
</cfif>


<cfif StructKeyExists(form,"survey_back_flag") and form.survey_back_flag neq "">
  <cfset survey_back_flag = form.survey_back_flag>
<cfelse>
  <cfset survey_back_flag = 1>
</cfif>


  <cfset shop_code_keta = "">
  <cfquery name="qGetAdmin">
    SELECT m_admin.shop_code_keta
      FROM m_admin
  </cfquery>
  <cfset shop_code_keta = qGetAdmin.shop_code_keta>

  <cfquery name="qGetAreaList">
      SELECT m_area.area_code AS list_area_code,
             m_area.area_name AS list_area_name
        FROM m_area
    ORDER BY LPAD(m_area.area_code, 10, '0')
  </cfquery>

  <cfquery name="qGetLocationList">
      SELECT m_location.location_code AS list_location_code,
             m_location.location_name AS list_location_name
        FROM m_location
    ORDER BY LPAD(m_location.location_code, 10, '0')
  </cfquery>

  <cfquery name="qGetPrefectureList">
      SELECT m_prefecture.prefecture_code AS list_prefecture_code,
             m_prefecture.prefecture_name AS list_prefecture_name
        FROM m_prefecture
    ORDER BY LPAD(m_prefecture.prefecture_code, 10, '0')
  </cfquery>


  <cfset location_arr=[]>
  <cfloop index="i" from="1" to="6">
    <cfset location_arr[i]= qGetLocationList.list_location_name[i]>
  </cfloop>

  
<!---   <cfoutput>
  <cfloop index="i" from="1" to="6">
    #location_arr[i]#
  </cfloop>
  </cfoutput> --->

<cfset shop_name            = "">
<cfset shop_name_kana            = "">
<cfset site_code            = "">
<cfset area_name            = "">
<cfset shop_type1           = "">
<cfset shop_type2           = "">
<cfset partner_company           = "">
<cfset delivery_form           = "">
<cfset post_code            = "">
<cfset prefecture_code      = "">
<cfset prefecture_name      = "">
<cfset address1             = "">
<cfset address2             = "">
<cfset address1_kana        = "">
<cfset address2_kana        = "">
<cfset tel_no               = "">
<cfset office_tel_no               = "">
<cfset fax_no               = "">
<cfset eigyo_start_date     = "">
<cfset char_eigyo_start_date     = "">
<cfset eigyo_end_date       = "">
<cfset char_eigyo_end_date       = "">
<cfset open_time            = "">
<cfset char_open_time            = "">
<cfset char_open_hour            = "">
<cfset char_open_minute            = "">
<cfset char_delivery_form            = "">

<cfset delivery_start_time            = "">
<cfset char_delivery_start_time            = "">
<cfset deliverable_start_time            = "">
<cfset char_deliverable_start_time            = "">
<cfset close_time           = "">
<cfset char_close_time           = "">
<cfset char_close_hour           = "">
<cfset char_close_minute           = "">
<cfset delivery_end_time            = "">
<cfset char_delivery_end_time            = "">
<cfset deliverable_end_time            = "">
<cfset char_deliverable_end_time            = "">

<cfset production_factory            = "">
<cfset delivery_qty            = "">
<cfset delivery_base            = "">
<cfset delivery_course            = "">
<cfset entrance_manner            = "">
<cfset shop_code_new            = "">
<cfset shop_code_old            = "">
<cfset char_go_date            = "">

<cfset car_type            = "">
<cfset single_is            = "">
<cfset normal_delivery_time            = "">
<cfset char_normal_delivery_time            = "">

<cfset shop_key_flag           = 1>
<cfset shop_security_flag           = 1>
<cfset shop_key_biko           = "">
<cfset shop_security_biko           = "">

<cfset latitude           = "">
<cfset longitude           = "">

<cfset location_file1           = "">
<cfset location_file2           = "">
<cfset location_file3           = "">
<cfset location_file4           = "">
<cfset location_file5           = "">
<cfset location_file6           = "">
<cfset karte_file           = "">


<cfset biko                 = "">
<cfset status                 = 1>
<cfset char_status                 = "">
<cfset char_create_date     = "">
<cfset create_staff_code    = "">
<cfset create_staff_name    = "">
<cfset char_update_date     = "">
<cfset update_staff_code    = "">
<cfset update_staff_name    = "">

<cfif input_screen eq 1 or input_screen eq 3>
  <cfquery name="qGetShop">
      SELECT m_shop.shop_code,
             m_shop.shop_name,
             m_shop.shop_name_kana,
             m_shop.site_code,
             m_shop.area_code,
             m_area.area_name,
             m_shop.post_code,
             m_shop.prefecture_code,
             m_shop.prefecture_name,
             m_shop.address1,
             m_shop.address2,
             m_shop.tel_no,
             m_shop.office_tel_no,
             m_shop.fax_no,

             m_shop.shop_type1,
             m_shop.shop_type2,
             CASE m_shop.shop_type1
                  WHEN 1 THEN '直営'
                  WHEN 2 THEN 'FC'
                  ELSE '' END AS char_shop_type1,
             CASE m_shop.shop_type2
                  WHEN 1 THEN 'DT'
                  WHEN 2 THEN 'IN'
                  ELSE '' END AS char_shop_type2,
             m_shop.partner_company,
             m_shop.open_time,
             m_shop.close_time,
             m_shop.delivery_start_time,
             m_shop.delivery_end_time,
             m_shop.deliverable_start_time,
             m_shop.deliverable_end_time,

             time_format(m_shop.open_time,'%H:%i') char_open_time,
             time_format(m_shop.close_time,'%H:%i') char_close_time,
             time_format(m_shop.delivery_start_time,'%H:%i') char_delivery_start_time,
             time_format(m_shop.delivery_end_time,'%H:%i') char_delivery_end_time,
             m_shop.delivery_form,
             CASE m_shop.delivery_form
                  WHEN 1 THEN '対面'
                  WHEN 2 THEN '無人'
                  ELSE '' END AS char_delivery_form,
             time_format(m_shop.deliverable_start_time,'%H:%i') char_deliverable_start_time,
             time_format(m_shop.deliverable_end_time,'%H:%i') char_deliverable_end_time,

             m_shop.production_factory,
             m_shop.delivery_qty,
             m_shop.delivery_base,
             m_shop.delivery_course,
             m_shop.location,
             ST_Latitude(location) as latitude,
             ST_Longitude(location) as longitude,
             date_format(m_shop.go_date,'%Y/%m/%d') as char_go_date,
             m_shop.car_type,
             m_shop.single_is,
             time_format(m_shop.normal_delivery_time,'%H:%i') as char_normal_delivery_time,
             m_shop.shop_key_flag,
             m_shop.shop_key_biko,
             m_shop.shop_security_flag,
             m_shop.shop_security_biko,
             m_shop.normal_delivery_time,
             m_shop.entrance_manner,
             m_shop.shop_code_new,
             m_shop.shop_code_old,

             m_shop.location_file1,
             m_shop.location_file2,
             m_shop.location_file3,
             m_shop.location_file4,
             m_shop.location_file5,
             m_shop.location_file6,
             m_shop.karte_file,

             date_format(m_shop.eigyo_start_date,'%Y/%m/%d') char_eigyo_start_date,
             m_shop.eigyo_end_date,
             date_format(m_shop.eigyo_end_date,'%Y/%m/%d') char_eigyo_end_date,
             m_shop.open_time,
             date_format(m_shop.open_time,'%H') char_open_hour,
             date_format(m_shop.open_time,'%i') char_open_minute,
             m_shop.close_time,
             date_format(m_shop.close_time,'%H') char_close_hour,
             date_format(m_shop.close_time,'%i') char_close_minute,
             m_shop.biko,
             m_shop.status,
             CASE m_shop.status
                  WHEN 1 THEN '営業中'
                  WHEN 2 THEN '休業'
                  WHEN 3 THEN '店舗番号変更'
                  WHEN 9 THEN '閉店'
                  ELSE '' END AS char_status,
             m_shop.create_date,
             date_format(m_shop.create_date,'%Y/%m/%d %H:%i') char_create_date,
             m_shop.create_staff_code,
             m_shop.create_staff_name,
             m_shop.update_date,
             date_format(m_shop.update_date,'%Y/%m/%d %H:%i') char_update_date,
             m_shop.update_staff_code,
             m_shop.update_staff_name
        FROM m_shop LEFT OUTER JOIN m_area ON m_shop.area_code = m_area.area_code
       WHERE shop_code = <cfqueryparam value="#shop_code#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
  </cfquery>

  <cfset shop_name            =qGetShop.shop_name>
  <cfset shop_name_kana            =qGetShop.shop_name_kana>
  <cfset site_code            =qGetShop.site_code>
  <cfset area_name            =qGetShop.area_name>
  <cfset area_code_ddlb            =qGetShop.area_code>
  <cfset post_code             =qGetShop.post_code> 
  <cfset prefecture_code      = qGetShop.prefecture_code>
  <cfset prefecture_name      = qGetShop.prefecture_name>
  <cfset address1             =qGetShop.address1> 
  <cfset address2             =qGetShop.address2> 
  <cfset tel_no               =qGetShop.tel_no>
  <cfset office_tel_no               =qGetShop.office_tel_no>
  <cfset fax_no               =qGetShop.fax_no>

  <cfset shop_type1             =qGetShop.shop_type1> 
  <cfset shop_type2             =qGetShop.shop_type2> 
  <cfset char_shop_type1             =qGetShop.char_shop_type1> 
  <cfset char_shop_type2             =qGetShop.char_shop_type2> 
  <cfset partner_company           = qGetShop.partner_company>

  <cfset open_time             =qGetShop.open_time> 
  <cfset close_time             =qGetShop.close_time> 
  <cfset delivery_start_time             =qGetShop.delivery_start_time> 
  <cfset delivery_end_time             =qGetShop.delivery_end_time> 
  <cfset delivery_form            = qGetShop.delivery_form>
  <cfset deliverable_start_time             =qGetShop.deliverable_start_time> 
  <cfset deliverable_end_time             =qGetShop.deliverable_end_time> 

  <cfset char_open_time             =qGetShop.char_open_time> 
  <cfset char_close_time             =qGetShop.char_close_time> 
  <cfset char_delivery_start_time             =qGetShop.char_delivery_start_time> 
  <cfset char_delivery_end_time             =qGetShop.char_delivery_end_time> 
  <cfset char_delivery_form            = qGetShop.char_delivery_form>
  <cfset char_deliverable_start_time             =qGetShop.char_deliverable_start_time> 
  <cfset char_deliverable_end_time             =qGetShop.char_deliverable_end_time> 

  <cfset production_factory             =qGetShop.production_factory> 
  <cfset delivery_qty             =qGetShop.delivery_qty> 
  <cfset delivery_base             =qGetShop.delivery_base> 
  <cfset delivery_course             =qGetShop.delivery_course> 
  <cfset entrance_manner             =qGetShop.entrance_manner> 
  <cfset shop_code_new             =qGetShop.shop_code_new> 
  <cfset shop_code_old             =qGetShop.shop_code_old> 
  <cfset char_go_date             =qGetShop.char_go_date> 

  <cfset car_type             =qGetShop.car_type> 
  <cfset single_is             =qGetShop.single_is> 
  <cfset normal_delivery_time             =qGetShop.normal_delivery_time> 
  <cfset char_normal_delivery_time             =qGetShop.char_normal_delivery_time> 

  <cfset shop_key_flag             =qGetShop.shop_key_flag> 
  <cfset shop_security_flag             =qGetShop.shop_security_flag> 
  <cfset shop_key_biko             =qGetShop.shop_key_biko> 
  <cfset shop_security_biko             =qGetShop.shop_security_biko> 

  <cfset latitude             =qGetShop.latitude> 
  <cfset longitude             =qGetShop.longitude> 

  <cfset location_file1             =qGetShop.location_file1> 
  <cfset location_file2             =qGetShop.location_file2> 
  <cfset location_file3             =qGetShop.location_file3> 
  <cfset location_file4             =qGetShop.location_file4> 
  <cfset location_file5             =qGetShop.location_file5> 
  <cfset location_file6             =qGetShop.location_file6> 
  <cfset karte_file             =qGetShop.karte_file> 

  <cfset biko                 =qGetShop.biko>
  <cfset status                 =qGetShop.status>
  <cfset char_status                 =qGetShop.char_status>
  <cfset char_create_date     =qGetShop.char_create_date>
  <cfset create_staff_code    =qGetShop.create_staff_code>
  <cfset create_staff_name    =qGetShop.create_staff_name>
  <cfset char_update_date     =qGetShop.char_update_date>
  <cfset update_staff_code    =qGetShop.update_staff_code>
  <cfset update_staff_name    =qGetShop.update_staff_name>
  

  <cfquery name="qGetSurvey">
  SELECT t_survey.survey_no,
         t_survey.sheet_code,
         t_survey.shop_code,
         m_shop.shop_name,
         m_sheet.sheet_name,
         t_survey.survey_datetime,
         date_format(t_survey.survey_datetime,'%Y/%m/%d') AS char_survey_datetime
    FROM t_survey LEFT OUTER JOIN m_shop ON t_survey.shop_code = m_shop.shop_code
                  LEFT OUTER JOIN m_sheet ON t_survey.sheet_code = m_sheet.sheet_code
   WHERE t_survey.shop_code = <cfqueryparam value="#shop_code#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
   ORDER BY date_format(t_survey.survey_datetime,'%Y/%m/%d') DESC, t_survey.survey_no
  </cfquery>

<!---   <cfdump var="#qGetSurvey#"> --->




</cfif>


<cfset title_name = "店舗">
<cfset title_arr=[]>
<cfset title_arr[1] = "店舗コード">
<cfset title_arr[2] = "店舗名">
<cfset title_arr[3] = "店舗名">
<cfset title_arr[4] = "店舗名略">
<cfset title_arr[5] = "店舗名略">
<cfset title_arr[6] = "店舗区分">
<cfset title_arr[7] = "郵便番号">
<cfset title_arr[8] = "住所1">
<cfset title_arr[9] = "住所2">
<cfset title_arr[10] = "住所1">
<cfset title_arr[11] = "住所2">
<cfset title_arr[12] = "TEL">
<cfset title_arr[13] = "FAX">
<cfset title_arr[14] = "営業開始日">
<cfset title_arr[15] = "営業終了日">
<cfset title_arr[16] = "開店時刻">
<cfset title_arr[17] = "閉店時刻">
<cfset title_arr[18] = "IPアドレス">
<cfset title_arr[19] = "ユーザー名">
<cfset title_arr[20] = "パスワード">
<cfset title_arr[21] = "パス">
<cfset title_arr[22] = "備考">
<cfset title_arr[23] = "登録日時">
<cfset title_arr[24] = "登録者">
<cfset title_arr[25] = "更新日時">
<cfset title_arr[26] = "更新者">

<!DOCTYPE html>
<html>
<cfoutput>
<head>
  <meta charset="utf-8">

  <cfinclude template="common/css.cfm">
  
  <title>#title_name#マスタ</title>
  <style>

  .upside-table{
  border-collapse:collapse;
  }
  .upside-table th{
  height:24px;
  /*  font-size:12px;
  border-width: 1px;*/

  text-align:left;
 /* border-bottom:none;*/
  border: rgb(222, 205, 177) solid 1px;
  padding:0px 10px;
  font-size:12px;
  color:rgb(182, 157, 100);
  font-weight:normal;
  background-color:rgba(245,245,235,1);
 }
  .upside-table td{
  height:24px;
  text-align:left;
  border: rgb(222, 205, 177) solid 1px;
  padding:0px 10px;
  color: rgb(40,40,40); 
  font-size:12px;
  background-color:rgba(255,255,255,0.9);
  }

  .shop_master_table{
    width:100%;
    padding:20px 0px 10px 0px;
    font-size:15px;
    letter-spacing:0.1em; 
  }
  .survey_result_button{
    text-align:center;
    cursor:pointer;
    position:relative;
    border-radius:6px;
    font-size: 14px;
    padding:8px 18px 8px 38px;
    background: rgb(221, 221, 221);
    box-shadow: 0px 1px 0px rgba(170, 170, 170, 0.8);
}
.survey_result_button::before{
  content:url(images/svg/file_pen.svg);
  background-size:12px 12px;
  width:18px !important;
  height:18px;
  vertical-align: middle;
  padding-right: 5px;
  position:absolute;
  left:12px;
  top:10px;
}
.survey_result_button:hover{
  background: rgb(190,190,190);
  box-shadow: 0px 0px 0px;
  color:white;
}
.survey_result_button:hover::before{
  content:url(images/svg/file_pen_w.svg);}

  </style>
</head>
<body>
<div style="display:flex;">
  <!--- 詳細画面 --->
  <cfif input_screen eq 1>
    <cfset hd_title="#title_name#マスタ 詳細">
    <!--- 戻る --->
    <cfset hd_btn_back="">
    <!--- 編集 --->
    <cfset hd_btn_change="">
    <!--- 新規追加 --->
    <cfset hd_btn_add="">
    <!--- 削除 --->
    <cfset hd_btn_del="">

  <!--- 新規作成画面 --->
  <cfelseif input_screen eq 2>
    <cfset hd_title="#title_name#マスタ 登録">
    <!--- キャンセル --->
    <cfset hd_btn_cancel="">
    <!--- 新規作成実行 --->
    <cfset hd_btn_update="">

  <!--- 編集画面 --->
  <cfelseif input_screen eq 3>
    <cfset hd_title="#title_name#マスタ 変更">
    <!--- キャンセル --->
    <cfset hd_btn_cancel="">
    <!--- 新規作成実行 --->
    <cfset hd_btn_update="">
  </cfif>
</div>

<cfinclude template="header.cfm">

<div class="wrap" style="margin-top:20px;">
<form name="master_dt_form" id="master_dt_form">

  <input type="hidden" id="input_screen" name="input_screen" value="#input_screen#">
  <input type="hidden" id="shop_code_keta" name="shop_code_keta" value="#shop_code_keta#">

  <input type="hidden" id="download_flg" name="download_flg" value="">

  <!--- 一覧用変数 --->
  <input type="hidden" name="list_screen" value="#list_screen#">
  <input type="hidden" name="list_sort" value="#list_sort#">
  <input type="hidden" name="list_page" value="#list_page#">
  <input type="hidden" name="search_list_text_box" value="#search_list_text_box#">
  <input type="hidden" name="search_list_site_code" value="#search_list_site_code#">
  <input type="hidden" name="search_list_area_code_ddlb" value="#search_list_area_code_ddlb#">
  <input type="hidden" name="search_list_prefecture_code_ddlb" value="#search_list_prefecture_code_ddlb#">
  <input type="hidden" name="search_list_shop_key_flag" value="#search_list_shop_key_flag#">
  <input type="hidden" name="search_list_shop_security_flag" value="#search_list_shop_security_flag#">
  <input type="hidden" name="search_list_shop_status" value="#search_list_shop_status#">

  <input type="hidden" name="search_list_sheet_code_ddlb" value="#search_list_sheet_code_ddlb#">
  <input type="hidden" name="search_list_status_ddlb" value="#search_list_status_ddlb#">

  <input type="hidden" name="search_list_partner_company" value="#search_list_partner_company#">
  <input type="hidden" name="search_list_production_factory" value="#search_list_production_factory#">
  <input type="hidden" name="search_list_delivery_base" value="#search_list_delivery_base#">
  <input type="hidden" name="search_list_delivery_course" value="#search_list_delivery_course#">


  <!--- キャンセルでの戻り用変数 --->
  <input type="hidden" id="return_shop_code" name="return_shop_code" value="#shop_code#">

  <!--- 調査票への表示用変数 --->
  <input type="hidden" id="survey_no" name="survey_no" value="">
  <input type="hidden" id="editable_flag" name="editable_flag" value="false">
  <!--- 調査票からの戻り用変数 --->
  <input type="hidden" id="survey_back_flag" name="survey_back_flag" value="#survey_back_flag#">


  <cfif input_screen eq 1>
    

      <table class="shop_master_table">
        <tr>
          <td width="350" style="font-size:17px; letter-spacing:0.1em;">
            #shop_code# #shop_name#<br>
            <font size="2">#shop_name_kana#</font><br>
            <font size="2">#area_name#&emsp;<cfif status neq 1><font color="red">#char_status#</font></cfif></font>
            <input type="hidden" id="shop_code" name="shop_code" value="#shop_code#">
            <input type="hidden" id="shop_name" name="shop_name" value="#shop_name#">
          </td>
          <td align="left" >住所:〒#post_code#&emsp;#prefecture_name##address1#<!---&nbsp;#address2#---><br>店舗:#tel_no#&emsp;事務所:#office_tel_no#&emsp;FAX:#fax_no#</td>
          <td>
            <div id="survey_result_button" class="survey_result_button">
                <cfif survey_back_flag eq 0>
                  店舗情報
                <cfelseif survey_back_flag eq 1>
                調査履歴
                </cfif>
            </div>
          </td>
        </tr>
      </table>

  
  <cfelseif input_screen eq 2>
    <div>
      <table width="49%" align="left" cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
          <tr>
            <th width="100" style="" >店舗No</th>
            <td width="" align="left">
              <input id="shop_code" name="shop_code" type="text" class="box_input2 p-check-already-use p-required-entry p-focus-move" style="height:10px;padding:3px;font-size:11px;" title="店舗No" maxlength="#shop_code_keta#">
            </td>
          </tr>
<!---           <tr>
            <th width="100" style="" >サイトコード</th>
            <td width="" align="left">
              <input id="site_code" name="site_code" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" title="サイトコード" maxlength="5">
            </td>
          </tr> --->
          <tr>
            <th width="100" style="" >店舗名</th>
            <td width="" align="left">
              <input id="shop_name" name="shop_name" type="text" class="box_input2 p-required-entry p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" title="店舗名" maxlength="40">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >店舗名カナ</th>
            <td width="" align="left">
              <input id="shop_name_kana" name="shop_name_kana" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" title="店舗名カナ" maxlength="40">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >地域</th>
            <td width="" align="left">
              <select name="area_code_ddlb" id="area_code_ddlb" class="drop_list01 p-required-entry p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;" title="地域名">
                <option value="" <cfif area_code_ddlb eq "">selected="selected"</cfif>></option>
                <cfloop query="qGetAreaList">
                  <option value="#list_area_code#" <cfif area_code_ddlb eq list_area_code>selected="selected"</cfif>>#list_area_code#&emsp;#list_area_name#</option>
                </cfloop>
              </select>
            </td>
          </tr>
          <tr>
            <th></th>
            <td></td>
          </tr>
        </table>

      <table width="49%" align="right" cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
          <tr>
            <th width="100" style="" >郵便番号</th>
            <td width="" align="left">
              <input id="post_code" name="post_code" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:70px;" maxlength="7">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >住所</th>
            <td width="" align="left">
              <select name="prefecture_code_ddlb" id="prefecture_code_ddlb" class="drop_list01 p-focus-move p-no-comma" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
                <option value="" <cfif prefecture_code eq "">selected="selected"</cfif>></option>
                <cfloop query="qGetPrefectureList">
                  <option value="#list_prefecture_code#" <cfif prefecture_code eq list_prefecture_code>selected="selected"</cfif>>#list_prefecture_name#</option>
                </cfloop>
              </select>
              <input id="address1" name="address1" type="text" class="box_input2 p-focus-move" style="height:10px;padding:3px;font-size:11px;width:70%;" maxlength="40">
              <!--- <input id="address2" name="address2" type="text" class="box_input2 p-focus-move" style="height:10px;padding:3px;font-size:11px;width:45%;" maxlength="40"> --->
              <input id="prefecture_name" name="prefecture_name" type="hidden">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >店舗電話番号</th>
            <td width="" align="left">
              <input id="tel_no" name="tel_no" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >事務所電話番号</th>
            <td width="" align="left">
              <input id="office_tel_no" name="office_tel_no" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >FAX番号</th>
            <td width="" align="left">
              <input id="fax_no" name="fax_no" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
<!---           <tr>
            <th></th>
            <td></td>
          </tr> --->
        </table>

    </div>
  <cfelseif input_screen eq 3>
    <div>
      <table width="49%" align="left" cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
          <tr>
            <th width="100" style="" >店舗No</th>
            <td width="" align="left">
              #shop_code#
              <input id="shop_code" name="shop_code" type="hidden" value="#shop_code#">
            </td>
          </tr>
<!---           <tr>
            <th width="100" style="" >サイトコード</th>
            <td width="" align="left">
              <input id="site_code" name="site_code" type="text" value="#site_code#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" title="サイトコード" maxlength="5">
            </td>
          </tr> --->
          <tr>
            <th width="100" style="" >店舗名</th>
            <td width="" align="left">
              <input id="shop_name" name="shop_name" type="text" value="#shop_name#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >店舗名カナ</th>
            <td width="" align="left">
              <input id="shop_name_kana" name="shop_name_kana" type="text" value="#shop_name_kana#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >地域</th>
            <td width="" align="left">
              <select name="area_code_ddlb" id="area_code_ddlb" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
                <option value="" <cfif area_code_ddlb eq "">selected="selected"</cfif>></option>
                <cfloop query="qGetAreaList">
                  <option value="#list_area_code#" <cfif area_code_ddlb eq list_area_code>selected="selected"</cfif>>#list_area_code#&emsp;#list_area_name#</option>
                </cfloop>
              </select>
            </td>
          </tr>
          <tr>
            <th>ステータス</th>
            <td>
              <select name="status" id="status" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
                <option value="1" <cfif status eq 1>selected="selected"</cfif>>営業中</option>
                <option value="2" <cfif status eq 2>selected="selected"</cfif>>休業</option>
                <option value="3" <cfif status eq 3>selected="selected"</cfif>>店舗番号変更</option>
                <option value="9" <cfif status eq 9>selected="selected"</cfif>>閉店</option>
              </select>
            </td>
          </tr>
        </table>

      <table width="49%" align="right" cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
          <tr>
            <th width="100" style="" >郵便番号</th>
            <td width="" align="left">
              <input id="post_code" name="post_code" type="text" class="box_input2 p-focus-move p-no-comma" value="#post_code#" style="height:10px;padding:3px;font-size:11px;width:70px" maxlength="7">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >住所</th>
            <td width="" align="left">
              <select name="prefecture_code_ddlb" id="prefecture_code_ddlb" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
                <option value="" <cfif prefecture_code eq "">selected="selected"</cfif>></option>
                <cfloop query="qGetPrefectureList">
                  <option value="#list_prefecture_code#" <cfif prefecture_code eq list_prefecture_code>selected="selected"</cfif>>#list_prefecture_name#</option>
                </cfloop>
              </select>
              <input id="address1" name="address1" type="text" class="box_input2 p-focus-move p-no-comma" value="#address1#" style="height:10px;padding:3px;font-size:11px;width:70%;" maxlength="40">
              <cfif prefecture_code neq "">
                <cfloop query="qGetPrefectureList">
                  <cfif prefecture_code eq list_prefecture_code><input id="prefecture_name" name="prefecture_name" type="hidden" value="#list_prefecture_name#"></cfif>
                </cfloop>
              <cfelse>
                <input id="prefecture_name" name="prefecture_name" type="hidden" value="">
              </cfif>
              <!--- <input id="address2" name="address2" type="text" class="box_input2 p-focus-move" value="#address2#" style="height:10px;padding:3px;font-size:11px;width:45%;" maxlength="40"> --->
            </td>
          </tr>
          <tr>
            <th width="100" style="" >店舗電話番号</th>
            <td width="" align="left">
              <input id="tel_no" name="tel_no" type="text" class="box_input2 p-focus-move p-no-comma" value="#tel_no#" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >事務所電話番号</th>
            <td width="" align="left">
              <input id="office_tel_no" name="office_tel_no" type="text" class="box_input2 p-focus-move p-no-comma" value="#office_tel_no#" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
          <tr>
            <th width="100" style="" >FAX番号</th>
            <td width="" align="left">
              <input id="fax_no" name="fax_no" type="text" class="box_input2 p-focus-move p-no-comma" value="#fax_no#" style="height:10px;padding:3px;font-size:11px;" maxlength="20">
            </td>
          </tr>
<!---           <tr>
            <th></th>
            <td></td>
          </tr> --->
        </table>

    </div>
  </cfif>

  <cfif survey_back_flag eq 0>
    <div id='unit-contents' style="margin-top:20px;display:none;">
  <cfelseif survey_back_flag eq 1>
    <div id='unit-contents' style="margin-top:20px;">
  </cfif>
    <table width="49%" align="left"  cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">

      <tr>
        <th width="100" style="" >サイトコード</th>


        <cfif input_screen eq 1>
          <td width="" align="left">
            #site_code#
          </td>
        <cfelseif input_screen eq 2>
          <td width="" align="left">
            <input id="site_code" name="site_code" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" title="サイトコード" maxlength="5">
          </td>
        <cfelseif input_screen eq 3>
          <td width="" align="left">
            <input id="site_code" name="site_code" type="text" value="#site_code#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;" title="サイトコード" maxlength="5">
          </td>
        </cfif>
      </tr>


      <tr>
        <th width="100" style="" >店舗TYPE</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          <cfif char_shop_type1 eq "" and char_shop_type2 eq "">
          <cfelse>
            #char_shop_type1#&nbsp;/&nbsp;#char_shop_type2#
          </cfif>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <select name="shop_type1" id="shop_type1" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option value="" <cfif shop_type1 eq "">selected="selected"</cfif>></option>
            <option value="1"<cfif shop_type1 eq 1>selected="selected"</cfif>>直営</option>
            <option value="2"<cfif shop_type1 eq 2>selected="selected"</cfif>>FC</option>
          </select>&nbsp;/&nbsp;
          <select name="shop_type2" id="shop_type2" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option value="" <cfif shop_type2 eq "">selected="selected"</cfif>></option>
            <option value="1" <cfif shop_type2 eq 1>selected="selected"</cfif>>DT</option>
            <option value="2" <cfif shop_type2 eq 2>selected="selected"</cfif>>IN</option>
          </select>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >協力会社</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #partner_company#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="partner_company" name="partner_company" value="#partner_company#" type="text" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:100%;" maxlength="100">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >営業時間</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          <cfif char_open_time eq "" and char_close_time eq "">
          <cfelse>
            #char_open_time#&nbsp;〜&nbsp;#char_close_time#
          </cfif>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <select id="open_time_hour" name="open_time_hour" class="p-focus-move drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(open_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="open_time_minute" name="open_time_minute" class="p-focus-move drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(open_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;〜&nbsp;
          <input type="hidden" id="open_time" name="open_time" value="">
          <select id="close_time_hour" name="close_time_hour" class="p-focus-move drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(close_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="close_time_minute" name="close_time_minute" class="p-focus-move drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(close_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>
          <input type="hidden" id="close_time" name="close_time" value="">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >納品時間</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          <cfif char_delivery_start_time eq "" and char_delivery_end_time eq "">
          <cfelse>
            #char_delivery_start_time#&nbsp;〜&nbsp;#char_delivery_end_time#
          </cfif>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <select id="delivery_start_time_hour" name="delivery_start_time_hour" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(delivery_start_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="delivery_start_time_minute" name="delivery_start_time_minute" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(delivery_start_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;〜&nbsp;   
          <input type="hidden" id="delivery_start_time" name="delivery_start_time" value="">
          <select id="delivery_end_time_hour" name="delivery_end_time_hour" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(delivery_end_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="delivery_end_time_minute" name="delivery_end_time_minute" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(delivery_end_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>
          <input type="hidden" id="delivery_end_time" name="delivery_end_time" value="">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >納品形態</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #char_delivery_form#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <select name="delivery_form" id="delivery_form" class="drop_list01 p-focus-move" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option value="" <cfif delivery_form eq "">selected="selected"</cfif>></option>
            <option value="1"<cfif delivery_form eq 1>selected="selected"</cfif>>対面</option>
            <option value="2"<cfif delivery_form eq 2>selected="selected"</cfif>>無人</option>
          </select>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >納品可能時間</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          <cfif char_deliverable_start_time eq "" and char_deliverable_end_time eq "">
          <cfelse>
            #char_deliverable_start_time#&nbsp;〜&nbsp;#char_deliverable_end_time#
          </cfif>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <select id="deliverable_start_time_hour" name="deliverable_start_time_hour" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(deliverable_start_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="deliverable_start_time_minute" name="deliverable_start_time_minute" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(deliverable_start_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;〜&nbsp;   
          <input type="hidden" id="deliverable_start_time" name="deliverable_start_time" value="">
          <select id="deliverable_end_time_hour" name="deliverable_end_time_hour" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(deliverable_end_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="deliverable_end_time_minute" name="deliverable_end_time_minute" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(deliverable_end_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>
          <input type="hidden" id="deliverable_end_time" name="deliverable_end_time" value="">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >生産工場</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #production_factory#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="production_factory" name="production_factory" type="text" value="#production_factory#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="20">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >配送数/週</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #delivery_qty#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="delivery_qty" name="delivery_qty" type="text" value="#delivery_qty#" class="box_input2 p-focus-move p-check-unsignedint" style="height:10px;padding:3px;font-size:11px;text-align:right;" maxlength="20">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >配送拠点</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #delivery_base#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="delivery_base" name="delivery_base" type="text" value="#delivery_base#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >配送コース</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #delivery_course#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="delivery_course" name="delivery_course" type="text" value="#delivery_course#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="100" style="" >入店方法</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          #entrance_manner#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <input id="entrance_manner" name="entrance_manner" type="text" value="#entrance_manner#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="100">
        </cfif>
        </td>
      </tr>
      <tr>
        <th>変更後店舗No</th>
        <td>
        <cfif input_screen eq 1>
          #shop_code_new#
        <cfelseif input_screen eq 2>

        <cfelseif input_screen eq 3>
          <input id="shop_code_new" name="shop_code_new" type="text" value="#shop_code_new#" class="box_input2 p-no-comma" style="height:10px;padding:3px;font-size:11px;width:100px;" maxlength="12">
        </cfif>
        </td>
      </tr>
      <tr>
        <th>旧店舗No</th>
        <td>
        <cfif input_screen eq 1>
          #shop_code_old#
        <cfelseif input_screen eq 2>
          <input id="shop_code_old" name="shop_code_old" type="text" value="#shop_code_old#" class="box_input2 p-no-comma" style="height:10px;padding:3px;font-size:11px;width:100px;" maxlength="12">
        <cfelseif input_screen eq 3>
          #shop_code_old#
        </cfif>
        </td>
      </tr>
    </table>

    <table width="49%" align="right"  cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">

      <!--- カルテファイルに許可する拡張子 --->
      <!--- <cfset karte_accept_extension = ".xls,.xlsx,.pdf"> --->
      <cfset karte_accept_extension = ".pdf">
      <tr>
        <th width="100" style="" >カルテ</th>
        <td width="" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & karte_file>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="0" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_karte_file_name">#karte_file#</span>
          <input type="hidden" id="before_karte_file_name" value="#karte_file#">
          </td>
          <td width="200">
          <label for="karte_file" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
            PDFを選択
            <input id="karte_file" name="karte_file" type="file" style="display:none;" accept="#karte_accept_extension#">
          </label>
          <span id="clear_file_0" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_karte_file_name">#karte_file#</span>
          <input type="hidden" id="before_karte_file_name" value="#karte_file#">
          </td>
          <td width="200">
          <label for="karte_file" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
            PDFを選択
            <input id="karte_file" name="karte_file" type="file" style="display:none;" accept="#karte_accept_extension#">
          </label>
          <cfif karte_file neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check0" class="p-checkbox-class" ><!--- style="margin:5px 3px 3px 3px;" ---></span>
          </cfif>
          <span id="clear_file_0" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >GO年月日</th>
        <cfif input_screen eq 1>
          <td align="left">
            #char_go_date#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
            <input id="go_date" name="go_date" type="text" value="#char_go_date#" class="box_input_date p-jquery-ui-datepicker p-focus-move" style="height:10px;padding:3px;font-size:11px;" maxlength="20" readonly>
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >車型指定</th>
        <cfif input_screen eq 1>
          <td align="left">
          #car_type#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <input id="car_type" name="car_type" type="text" value="#car_type#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >単独・IS</th>
        <cfif input_screen eq 1>
          <td align="left">
          #single_is#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <input id="single_is" name="single_is" type="text" value="#single_is#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:300px;" maxlength="40">
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >通常納品時間</th>
        <cfif input_screen eq 1>
          <td align="left">
          #char_normal_delivery_time#
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <select id="normal_delivery_time_hour" name="normal_delivery_time_hour" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="23">
              <option value="#Right("00" & i,2)#"<cfif Left(normal_delivery_time,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>&nbsp;&nbsp;:&nbsp;
          <select id="normal_delivery_time_minute" name="normal_delivery_time_minute" class="p-focus-move drop_list01" style="height:20px;padding: 3px 25px 3px 8px;font-size:11px;">
            <option></option>
            <cfloop index="i" from="0" to="59">
              <option value="#Right("00" & i,2)#"<cfif Mid(normal_delivery_time,4,2) eq Right("00" & i,2)>selected="selected"</cfif>>#Right("00" & i,2)#</option>
            </cfloop>
          </select>
          <input type="hidden" id="normal_delivery_time" name="normal_delivery_time" value="">
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >鍵</th>
        <cfif input_screen eq 1>
          <td align="left">
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_key_flag" value="1" <cfif shop_key_flag eq 1>checked</cfif> disabled="disabled">あり
            <div class="radio_box_out_circle"></div>
          </label>
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_key_flag" value="0" <cfif shop_key_flag eq 0>checked</cfif> disabled="disabled">なし
            <div class="radio_box_out_circle"></div>
          </label>
          <span id="disp_shop_key_biko" style="margin-left:10px;">#shop_key_biko#</span>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_key_flag" class="shop_key_flag" value="1" <cfif shop_key_flag eq 1>checked</cfif>>あり
            <div class="radio_box_out_circle"></div>
          </label>
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_key_flag" class="shop_key_flag" value="0" <cfif shop_key_flag eq 0>checked</cfif>>なし
            <div class="radio_box_out_circle"></div>
          </label>
          <cfif shop_key_flag eq 1>
            <input type="text" id="shop_key_biko" name="shop_key_biko" class="box_input2 p-focus-move p-no-comma" value="#shop_key_biko#" style="height:10px;padding:3px;font-size:11px;width:200px;">
          <cfelseif shop_key_flag eq 0>
            <input type="text" id="shop_key_biko" name="shop_key_biko" class="box_input2 p-focus-move p-no-comma" value="#shop_key_biko#" style="height:10px;padding:3px;font-size:11px;width:200px;display:none;">
          </cfif>
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >セキュリティ</th>
        <cfif input_screen eq 1>
          <td align="left">
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_security_flag" value="1" <cfif shop_security_flag eq 1>checked</cfif> disabled="disabled">あり
            <div class="radio_box_out_circle"></div>
          </label>
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_security_flag" value="0" <cfif shop_security_flag eq 0>checked</cfif> disabled="disabled">なし
            <div class="radio_box_out_circle"></div>
          </label>
          <span id="disp_shop_security_biko" style="margin-left:10px;">#shop_security_biko#</span>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_security_flag" class="shop_security_flag" value="1" <cfif shop_security_flag eq 1>checked</cfif>>あり
            <div class="radio_box_out_circle"></div>
          </label>
          <label class="radio_box control_radio_box side">
            <input type="radio" name="shop_security_flag" class="shop_security_flag" value="0" <cfif shop_security_flag eq 0>checked</cfif>>なし
            <div class="radio_box_out_circle"></div>
          </label>
          <cfif shop_security_flag eq 1>
            <input type="text" id="shop_security_biko" name="shop_security_biko" class="box_input2 p-focus-move p-no-comma" value="#shop_security_biko#" style="height:10px;padding:3px;font-size:11px;width:200px;">
          <cfelseif shop_security_flag eq 0>
            <input type="text" id="shop_security_biko" name="shop_security_biko" class="box_input2 p-focus-move p-no-comma" value="#shop_security_biko#" style="height:10px;padding:3px;font-size:11px;width:200px;display:none;">
          </cfif>
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" >緯度/経度</th>
        <cfif input_screen eq 1>
          <td align="left">
            <cfif latitude eq "" and longitude eq "">
            <cfelse>
              #latitude#&nbsp;/&nbsp;#longitude#          
            </cfif>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td colspan="2" align="left">
          <input id="latitude" name="latitude" type="text" value="#latitude#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:100px;" maxlength="20">
          &nbsp;/&nbsp;
          <input id="longitude" name="longitude" type="text" value="#longitude#" class="box_input2 p-focus-move p-no-comma" style="height:10px;padding:3px;font-size:11px;width:100px;" maxlength="20">
          <input id="location" name="location" type="hidden">
          <input id="btn" name="btn" type="button" value="取得">
        </cfif>
        </td>
      </tr>
      <tr>
        <th style="" ></th>
        <td colspan="2" align="left">
        </td>
      </tr>
      <tr>
        <th style="" ></th>
        <td colspan="2" align="left">
        </td>
      </tr>
      <tr>
        <th style="" ></th>
        <td colspan="2" align="left">
        </td>
      </tr>
      <tr>
        <th>
        </th>
        <td  colspan="2">
        </td>
      </tr>
      <tr>
        <th>
        </th>
        <td colspan="2">
        </td>
      </tr>
      <tr>
        <th>
        </th>
        <td colspan="2">
        </td>
      </tr>

    </table>

    <table width="49%" align="left"  cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">

      <cfif input_screen eq 1>
        <cfset colspan = "2">
        <cfset width1 = "100">
        <cfset width2 = "">
      <cfelseif input_screen eq 2 or input_screen eq 3>
        <cfset colspan = "3">
        <cfset width1 = "100">
        <cfset width2 = "">
        <cfset width3 = "200">
      </cfif>
      <tr>
        <th colspan="#colspan#" class="blue-title01" style="text-align:center;">略図</th>
      </tr>


      <!--- 繰り返しに変更したい --->

      <!--- 略図ファイルに許可する拡張子(未決定) --->
      <cfset locationfile_accept_extension = ".png,.jpeg,.jpg">

      <tr>
        <th width="#width1#" style="" >1.#location_arr[1]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file1>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="1" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file1_name">#location_file1#</span>
          <input type="hidden" id="before_location_file1_name" value="#location_file1#">
          </td>
          <td width="#width3#">
          <label for="location_file1" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
            画像を選択
            <input id="location_file1" name="location_file1" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
          </label>
          <span id="clear_file_1" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file1_name">#location_file1#</span>
          <input type="hidden" id="before_location_file1_name" value="#location_file1#">
          </td>
          <td width="#width3#">
            <label for="location_file1" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file1" name="location_file1" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file1 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check1" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_1" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>


      <tr>
        <th width="#width1#" style="" >2.#location_arr[2]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file2>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="2" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file2_name">#location_file2#</span>
          <input type="hidden" id="before_location_file2_name" value="#location_file2#">
          </td>
          <td width="#width3#">
          <span id="disp_location_file2_name">#location_file2#</span>
            <label for="location_file2" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
              画像を選択
              <input id="location_file2" name="location_file2" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <span id="clear_file_2" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file2_name">#location_file2#</span>
          <input type="hidden" id="before_location_file2_name" value="#location_file2#">
          </td>
          <td width="#width3#">
            <label for="location_file2" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file2" name="location_file2" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file2 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check2" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_2" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="#width1#" style="" >3.#location_arr[3]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file3>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="3" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file3_name">#location_file3#</span>
          <input type="hidden" id="before_location_file3_name" value="#location_file3#">
          </td>
          <td width="#width3#">
            <label for="location_file3" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
              画像を選択
              <input id="location_file3" name="location_file3" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <span id="clear_file_3" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file3_name">#location_file3#</span>
          <input type="hidden" id="before_location_file3_name" value="#location_file3#">
          </td>
          <td width="#width3#">
            <label for="location_file3" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file3" name="location_file3" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file3 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check3" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_3" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="#width1#" style="" >4.#location_arr[4]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file4>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="4" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file4_name">#location_file4#</span>
          <input type="hidden" id="before_location_file4_name" value="#location_file4#">
          </td>
          <td width="#width3#">
            <label for="location_file4" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
              画像を選択
              <input id="location_file4" name="location_file4" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <span id="clear_file_4" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file4_name">#location_file4#</span>
          <input type="hidden" id="before_location_file4_name" value="#location_file4#">
          </td>
          <td width="#width3#">
            <label for="location_file4" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file4" name="location_file4" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file4 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check4" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_4" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="#width1#" style="" >5.#location_arr[5]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file5>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="5" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file5_name">#location_file5#</span>
          <input type="hidden" id="before_location_file5_name" value="#location_file5#">
          </td>
          <td width="#width3#">
            <label for="location_file5" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
              画像を選択
              <input id="location_file5" name="location_file5" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <span id="clear_file_5" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file5_name">#location_file5#</span>
          <input type="hidden" id="before_location_file5_name" value="#location_file5#">
          </td>
          <td width="#width3#">
            <label for="location_file5" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file5" name="location_file5" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file5 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check5" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_5" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>
      <tr>
        <th width="#width1#" style="" >6.#location_arr[6]#</th>
        <td width="#width2#" align="left">
        <cfif input_screen eq 1>
          <cfset dest_dir = "/var/local/buns/" & shop_code & "/" & location_file6>
          <cfif !FileExists(dest_dir)>
            ファイルなし
          <cfelse>
            <span class="p-download-file" data-flag="6" style="color:blue;cursor:pointer;">ダウンロード</span>
          </cfif>
        <cfelseif input_screen eq 2>
          <span id="disp_location_file6_name">#location_file6#</span>
          <input type="hidden" id="before_location_file6_name" value="#location_file6#">
          </td>
          <td width="#width3#">
            <label for="location_file6" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;cursor:pointer;">
              画像を選択
              <input id="location_file6" name="location_file6" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <span id="clear_file_6" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        <cfelseif input_screen eq 3>
          <span id="disp_location_file6_name">#location_file6#</span>
          <input type="hidden" id="before_location_file6_name" value="#location_file6#">
          </td>
          <td width="#width3#">
            <label for="location_file6" style="color: white;background-color: gray;padding: 3px;border-radius: 2px;">
              画像を選択
              <input id="location_file6" name="location_file6" type="file" class="p-location-files" style="display:none;" accept="#locationfile_accept_extension#">
            </label>
          <cfif location_file6 neq "">
            <span>&emsp;削除<input type="checkbox" name="delete_check6" class="p-checkbox-class" ></span>
          </cfif>
          <span id="clear_file_6" style="color:blue;cursor:pointer;display:none;">&nbsp;クリア</span>
        </cfif>
        </td>
      </tr>


    </table>
    <table width="49%" align="right"  cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
      <tr>
        <th colspan="2" class="blue-title01" style="text-align:center;">備考</th>
      </tr>
      <tr>
        <cfif input_screen eq 1>
          <td align="left" valign="top" style="height:150px;">
            #biko#
          </td>
        <cfelseif input_screen eq 2 or input_screen eq 3>
          <td align="left" style="height:150px;">
            <textarea id="biko" name="biko" class="box_input2 p-focus-move" style="width:97%;height:85%;" maxlength="300">#biko#</textarea>
          </td>
        </cfif>
      </tr>
    </table>

  </div>

  <div style="clear:both;"></div>
  <cfif input_screen eq 1>
    <cfif survey_back_flag eq 0>
      <div id='survey-contents' style="margin-top:20px;" >
    <cfelseif survey_back_flag eq 1>
      <div id='survey-contents' style="margin-top:20px;display:none;" >
    </cfif>
      <table width="100%" align="center"  cellpadding="0" cellspacing="0" border="0" class='upside-table' style=" margin-bottom:10px;">
        <tr>
          <th colspan="3" width="" style="text-align:center;" >調査結果</th>
        </tr>
        <tr>
          <th width="100" style="" ></th>
          <th width="200" style="" >調査日</th>
          <th width="" style="" >調査名</th>
        </tr>
        <cfloop index="survey_idx" from="1" to="#qGetSurvey.recordcount#">
          <tr>
            <td class="p-operation-btn p-disabled-btn" style="text-align:center;">
              <svg class="l_icon edit_btn" viewBox="0 0 24 24" onclick="showDetail('#qGetSurvey.survey_no[survey_idx]#')"><use xlink:href="##right_arrow_icon"/></svg>
            </td>
            <td>
              #qGetSurvey.char_survey_datetime[survey_idx]#
            </td>
            <td>
              #qGetSurvey.sheet_name[survey_idx]#
            </td>
          </tr>
        </cfloop>
      </table>
    </div>
  </cfif>
</form>
</div>

</cfoutput>
<!--- カルテ出力処理 --->
<cfif input_screen eq 1>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 0>
    <cfheader name="Content-Disposition" value="attachment; filename=#karte_file#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#karte_file#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 1>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file1#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file1#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 2>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file2#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file2#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 3>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file3#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file3#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 4>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file4#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file4#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 5>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file5#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file5#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
  <cfif IsDefined("form.download_flg") and form.download_flg eq 6>
    <cfheader name="Content-Disposition" value="attachment; filename=#location_file6#">
    <cfcontent type="image/png" file="/var/local/buns/#shop_code#/#location_file6#" deletefile="no"><!--- Application変数に変更 --->
  </cfif>
</cfif>


<cfinclude template="common/js.cfm">

<cfoutput>
 <script type="text/javascript" src="//maps.google.com/maps/api/js?key=#Application.api_key#"></script> 
 <script src="#Application.asset_url#/js/cmn_convert_kana.js?20220330" defer></script>
 <script src="#Application.asset_url#/js/m_shop_dt.js?2022051901" defer></script>
</cfoutput>
</body>
</html>
