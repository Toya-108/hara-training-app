<cfinclude template = "init.cfm">


<cfset scroll_survey_no = "-----">
<cfif StructKeyExists(Form, "survey_no")>
  <cfif Form.survey_no neq "">
    <cfset scroll_survey_no = Form.survey_no>   
  </cfif>
</cfif>

<cfif StructKeyExists(form,"list_screen") and form.list_screen neq "">
  <cfset list_screen = form.list_screen>
<cfelse>
  <cfset list_screen = 1>
</cfif>
<cfif StructKeyExists(form,"list_sort") and form.list_sort neq "">
  <cfset list_sort = form.list_sort>
<cfelse>
  <cfset list_sort = 2>
</cfif>
<cfif StructKeyExists(form,"list_page") and form.list_page neq "">
  <cfset list_page = form.list_page>
<cfelse>
  <cfset list_page = 1>
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

<cfset search_list_shop_code = "">
<cfif StructKeyExists(Form, "search_list_shop_code")>
  <cfif Form.search_list_shop_code neq "">
    <cfset search_list_shop_code = Form.search_list_shop_code>
  </cfif>
</cfif>
<cfif search_list_shop_code eq "">
  <cfset search_list_shop_code_ddlb = "All">
<cfelse>
  <cfset search_list_shop_code_ddlb = search_list_shop_code>
</cfif>

<cfset search_list_staff_code = "">
<cfif StructKeyExists(Form, "search_list_staff_code")>
  <cfif Form.search_list_staff_code neq "">
    <cfset search_list_staff_code = Form.search_list_staff_code>
  </cfif>
</cfif>
<cfif search_list_staff_code eq "">
  <cfset search_list_staff_code_ddlb = "All">
<cfelse>
  <cfset search_list_staff_code_ddlb = search_list_staff_code>
</cfif>

<cfif StructKeyExists(form,"search_list_sheet_code_ddlb") and form.search_list_sheet_code_ddlb neq "">
  <cfset search_list_sheet_code_ddlb = form.search_list_sheet_code_ddlb>
<cfelse>
  <cfset search_list_sheet_code_ddlb = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_survey_start_date") and form.search_list_survey_start_date neq "">
  <cfset search_list_survey_start_date = form.search_list_survey_start_date>
<cfelse>
  <cfset search_list_survey_start_date = "">
</cfif>

<cfif StructKeyExists(form,"search_list_survey_end_date") and form.search_list_survey_end_date neq "">
  <cfset search_list_survey_end_date = form.search_list_survey_end_date>
<cfelse>
  <cfset search_list_survey_end_date = "">
</cfif>



    <cfset order_by = "">
    <cfset filtering = "">
    <cfif list_sort eq 1>
      <cfset order_by = "survey_datetime,t_survey.survey_no DESC">
    <cfelseif list_sort eq 2>
      <cfset order_by = "survey_datetime DESC,t_survey.survey_no DESC">
    <cfelseif list_sort eq 3>
      <cfset order_by = "t_survey.survey_no">
    <cfelseif list_sort eq 4>
      <cfset order_by = "t_survey.survey_no DESC">
    <cfelseif list_sort eq 5>
      <cfset order_by = "m_shop.prefecture_code,t_survey.survey_no">
    <cfelseif list_sort eq 6>
      <cfset order_by = "m_shop.prefecture_code DESC,t_survey.survey_no">
    <cfelseif list_sort eq 7>
      <cfset order_by = "t_survey.shop_code,t_survey.survey_no">
    <cfelseif list_sort eq 8>
      <cfset order_by = "t_survey.shop_code DESC,t_survey.survey_no">
    <cfelseif list_sort eq 9>
      <cfset order_by = "m_shop.shop_name,t_survey.survey_no">
    <cfelseif list_sort eq 10>
      <cfset order_by = "m_shop.shop_name DESC,t_survey.survey_no">
    <cfelseif list_sort eq 11>
      <cfset order_by = "m_sheet.sheet_name,t_survey.survey_no">
    <cfelseif list_sort eq 12>
      <cfset order_by = "m_sheet.sheet_name DESC,t_survey.survey_no">
    <cfelseif list_sort eq 13>
      <cfset order_by = "MSHEET.sheet_pattern_name,t_survey.survey_no">
    <cfelseif list_sort eq 14>
      <cfset order_by = "MSHEET.sheet_pattern_name DESC,t_survey.survey_no">
    <cfelseif list_sort eq 15>
      <cfset order_by = "t_survey.survey_staff_code,t_survey.survey_no">
    <cfelseif list_sort eq 16>
      <cfset order_by = "t_survey.survey_staff_code DESC,t_survey.survey_no">
    </cfif>

    <cfif search_list_area_code_ddlb neq 'All'>
      <cfset filtering = filtering & " AND m_shop.area_code = '" & search_list_area_code_ddlb & "' ">
    </cfif>
    <cfif search_list_prefecture_code_ddlb neq 'All'>
      <cfset filtering = filtering & " AND m_shop.prefecture_code = '" & search_list_prefecture_code_ddlb & "' ">
    </cfif>
    <cfif search_list_shop_code neq "All" and search_list_shop_code neq "">
      <cfset filtering = filtering & " AND m_shop.shop_code = '" & search_list_shop_code & "' ">
    </cfif>
    <cfif search_list_sheet_code_ddlb neq "All" and search_list_sheet_code_ddlb neq "">
      <cfset filtering = filtering & " AND t_survey.sheet_code = '" & search_list_sheet_code_ddlb & "' ">
    </cfif>
    <cfif search_list_survey_start_date neq ''>
      <cfset filtering = filtering & " AND date_format(t_survey.survey_datetime,'%Y/%m/%d') >= '" & search_list_survey_start_date & "' ">
    </cfif>
    <cfif search_list_survey_end_date neq ''>
      <cfset filtering = filtering & " AND date_format(t_survey.survey_datetime,'%Y/%m/%d') <= '" & search_list_survey_end_date & "' ">
    </cfif>
    <cfif search_list_staff_code neq ''>
      <cfset filtering = filtering & " AND (LPAD(t_survey.survey_staff_code,40,'0') = LPAD('" & search_list_staff_code & "',40,'0') ">
      <cfset filtering = filtering & " OR t_survey.survey_staff_name LIKE '" & search_list_staff_code & "' ) ">
    </cfif>

  <cfset shop_code_keta = "">
  <cfset staff_code_keta = "">
  <cfquery name="qGetAdmin">
    SELECT m_admin.shop_code_keta,
           m_admin.staff_code_keta
      FROM m_admin
  </cfquery>
  <cfset shop_code_keta = qGetAdmin.shop_code_keta>
  <cfset staff_code_keta = qGetAdmin.staff_code_keta>

  <cfquery name="qGetAreaList">
      SELECT m_area.area_code AS list_area_code,
             m_area.area_name AS list_area_name
        FROM m_area
    ORDER BY LPAD(m_area.area_code, 10, '0')
  </cfquery>

  <cfquery name="qGetPrefectureList">
      SELECT m_prefecture.prefecture_code AS list_prefecture_code,
             m_prefecture.prefecture_name AS list_prefecture_name
        FROM m_prefecture
    ORDER BY LPAD(m_prefecture.prefecture_code, 10, '0')
  </cfquery>


  <cfquery name="qGetShopList">
      SELECT m_shop.shop_code AS list_shop_code,
             m_shop.shop_name AS list_shop_name
        FROM m_shop
    ORDER BY LPAD(m_shop.shop_code, 10, '0')
  </cfquery>

  <cfquery name="qGetStaffList">
      SELECT m_staff.staff_code AS list_staff_code,
             m_staff.last_name AS list_last_name,
             m_staff.first_name AS list_first_name
        FROM m_staff
    ORDER BY LPAD(m_staff.staff_code, 10, '0')
  </cfquery>

  <cfquery name="qGetSheetList">
      SELECT m_sheet.sheet_code AS list_sheet_code,
             m_sheet.sheet_name AS list_sheet_name
        FROM m_sheet
    ORDER BY LPAD(m_sheet.sheet_code, 10, '0')
  </cfquery>

  <cfquery name="qGetSurvey">
  WITH MSHEET AS (
      SELECT m_sheet.sheet_code,
             m_sheet_pattern.sheet_pattern,
             m_sheet_pattern.sheet_pattern_name
        FROM m_sheet,
             m_sheet_pattern
       WHERE m_sheet.sheet_pattern_code = m_sheet_pattern.sheet_pattern_code
  )
    SELECT t_survey.survey_no,
           t_survey.sheet_code,
           t_survey.shop_code,
           m_shop.shop_name,
           m_shop.prefecture_name,
           m_sheet.sheet_name,
           t_survey.survey_staff_code,
           t_survey.survey_staff_name,
           t_survey.survey_datetime,
           date_format(t_survey.survey_datetime,'%Y/%m/%d') AS char_survey_date,
           date_format(t_survey.survey_datetime,'%Y/%m/%d %H:%i') AS char_survey_datetime,
           t_survey.shop_staff_name,
           t_survey.biko,
           date_format(t_survey.create_date,'%Y/%m/%d %H:%i') AS char_create_datetime,
           date_format(t_survey.create_date,'%Y/%m/%d') AS char_create_date,
           t_survey.create_staff_code,
           t_survey.create_staff_name,
           date_format(t_survey.update_date,'%Y/%m/%d %H:%i') AS char_update_datetime,
           date_format(t_survey.update_date,'%Y/%m/%d') AS char_update_date,
           t_survey.update_staff_code,
           t_survey.update_staff_name,
           MSHEET.sheet_pattern,
           MSHEET.sheet_pattern_name
      FROM t_survey LEFT OUTER JOIN m_shop ON t_survey.shop_code = m_shop.shop_code
                    LEFT OUTER JOIN m_sheet ON t_survey.sheet_code = m_sheet.sheet_code,
           MSHEET
     WHERE t_survey.sheet_code = MSHEET.sheet_code
           #PreserveSingleQuotes(filtering)#
  ORDER BY #PreserveSingleQuotes(order_by)#
  </cfquery>


  <cfquery name="qGetShopCnt">
    SELECT COUNT(m_shop.shop_code) AS total_cnt_s
      FROM m_shop
     WHERE m_shop.status = 1
    <cfif search_list_area_code_ddlb neq 'All'>
      AND m_shop.area_code = <cfqueryparam value="#search_list_area_code_ddlb#" cfsqltype="CF_SQL_VARCHAR" maxlength="3">
    </cfif>
    <cfif search_list_prefecture_code_ddlb neq 'All'>
      AND m_shop.prefecture_code = <cfqueryparam value="#search_list_prefecture_code_ddlb#" cfsqltype="CF_SQL_VARCHAR" maxlength="2">
    </cfif>
    <cfif search_list_shop_code neq "All" and search_list_shop_code neq "">
      AND m_shop.shop_code = <cfqueryparam value="#search_list_shop_code#" cfsqltype="CF_SQL_VARCHAR" maxlength="#shop_code_keta#">
    </cfif>
  </cfquery>


<cfset title_name = "調査票一覧">
<cfset title_arr = ArrayNew(2)>
<cfset title_arr[1][1] = "訪問日時">
<cfset title_arr[1][2] = "調査票番号">
<cfset title_arr[1][3] = "都道府県">
<cfset title_arr[1][4] = "店舗No">
<cfset title_arr[1][5] = "店舗名">
<cfset title_arr[1][6] = "調査名">
<cfset title_arr[1][7] = "シート">
<cfset title_arr[1][8] = "訪問者">

<!--- 幅 --->
<cfset title_arr[2][1] = "10%">
<cfset title_arr[2][2] = "8%">
<cfset title_arr[2][3] = "7%">
<cfset title_arr[2][4] = "6%">
<cfset title_arr[2][5] = "15%">
<cfset title_arr[2][6] = "">
<cfset title_arr[2][7] = "10%">
<cfset title_arr[2][8] = "8%">

<cfset width_icon = "2%">

<!DOCTYPE html>
<html lang="ja">
  <cfoutput>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <cfinclude template="common/css.cfm">
    <link rel="stylesheet" type="text/css" href="css/page.css">
    
    <title>#title_name#</title>

  </head>

  <body>
    <form id="master_form" name="master_form">
    <cfset hd_title="#title_name#">
    <cfset hd_btn_back="menu">
    <cfset hd_btn_add="">
    <cfset hd_btn_export="">
    <cfinclude template="header.cfm">

    <input type="hidden" id="list_screen" name="list_screen" value="#list_screen#">
    <input type="hidden" id="list_sort" name="list_sort" value="#list_sort#">
    <input type="hidden" id="list_page" name="list_page" value="#list_page#">
    <input type="hidden" id="filtering" name="filtering" value="#filtering#">
    <input type="hidden" id="order_by" name="order_by" value="#order_by#">

    <input type="hidden" id="survey_no" name="survey_no" value="">
    <input type="hidden" id="input_screen" name="input_screen" value="">
    <input type="hidden" id="shop_code_keta" name="shop_code_keta" value="#shop_code_keta#">
    <input type="hidden" id="staff_code_keta" name="staff_code_keta" value="#staff_code_keta#">


    <div class="wrap" style="margin-top:20px;">
      <div class="search_conditional_box" style="margin-top:15px;">

        <div>地域&nbsp;
          <select name="search_list_area_code_ddlb" id="search_list_area_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_area_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetAreaList">
              <option value="#list_area_code#" <cfif search_list_area_code_ddlb eq list_area_code>selected="selected"</cfif>>#list_area_code#&emsp;#list_area_name#</option>
            </cfloop>
          </select>
        </div>
        <div>都道府県&nbsp;
          <select name="search_list_prefecture_code_ddlb" id="search_list_prefecture_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_prefecture_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetPrefectureList">
              <option value="#list_prefecture_code#" <cfif search_list_prefecture_code_ddlb eq list_prefecture_code>selected="selected"</cfif>>#list_prefecture_code#&emsp;#list_prefecture_name#</option>
            </cfloop>
          </select>
        </div>
        <div>店舗&nbsp;
          <input type="text" name="search_list_shop_code" id="search_list_shop_code" class="box_input2 p-search p-focus-move" value="#search_list_shop_code#" maxlength="10" style="width:70px;">
          <select name="search_list_shop_code_ddlb" id="search_list_shop_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_shop_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetShopList">
              <option value="#list_shop_code#" <cfif search_list_shop_code_ddlb eq list_shop_code>selected="selected"</cfif>>#list_shop_code#&emsp;#list_shop_name#</option>
            </cfloop>
          </select>
        </div>
      </div>
      <div class="search_conditional_box" style="margin-top:15px;">        
        <div>調査名&nbsp;
          <select name="search_list_sheet_code_ddlb" id="search_list_sheet_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_sheet_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetsheetList">
              <option value="#list_sheet_code#" <cfif search_list_sheet_code_ddlb eq list_sheet_code>selected="selected"</cfif>>#list_sheet_code#&emsp;#list_sheet_name#</option>
            </cfloop>
          </select>
        </div>
        <div>訪問日&nbsp;
          <input type="text" name="search_list_survey_start_date" id="search_list_survey_start_date" class="box_input_date p-search p-jquery-ui-datepicker p-focus-move" value="#search_list_survey_start_date#" maxlength="10" readonly>
          &nbsp;〜&nbsp;
          <input type="text" name="search_list_survey_end_date" id="search_list_survey_end_date" class="box_input_date p-search p-jquery-ui-datepicker p-focus-move" value="#search_list_survey_end_date#" maxlength="10" readonly>
        </div>
        <div>訪問者&nbsp;
          <input type="text" name="search_list_staff_code" id="search_list_staff_code" class="box_input2 p-search p-focus-move" value="#search_list_staff_code#" maxlength="10" style="width:70px;">
          <select name="search_list_staff_code_ddlb" id="search_list_staff_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_staff_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetStaffList">
              <option value="#list_staff_code#" <cfif search_list_staff_code_ddlb eq list_staff_code> selected="selected"</cfif>>#list_staff_code#&emsp;#list_last_name#&nbsp;#list_first_name#</option>
            </cfloop>
          </select>
        </div>
        <div class="p-operation-btn p-disabled-btn">
          <svg id="search_btn" class="search_icon p-info-box" viewBox="0 0 100 100" title="検索"><use xlink:href="##search_icon" /></svg>
        </div>
        <div class="p-operation-btn p-disabled-btn">
          <svg id="search_clear_btn" class="search_icon p-info-box" viewBox="0 0 24 22.5" style="margin-left: 0px;" title="クリア"><use xlink:href="##search_clear_icon" /></svg>
        </div>
      </div>

      <div style="float:left;margin-top:15px;">
        <!--- #LSNumberFormat(qGetShop.RecordCount, "9,999")#&emsp;/&emsp;#qGetShopCnt.total_cnt_s#&emsp;件 --->
        調査票&emsp;#LSNumberFormat(qGetSurvey.RecordCount, "9,999")#&nbsp;件&emsp;営業中店舗&emsp;#LSNumberFormat(qGetShopCnt.total_cnt_s, "9,999")#&nbsp;件
      </div>
      <div style="float:right;margin-top:15px;">
        <cfif qGetSurvey.RecordCount GTE 1>
          <cfset MaxRows = 50>
          <cfset pg = createObject("component","com.paging")>
          <cfset paging = pg.setPage(list_page,qGetSurvey.RecordCount,MaxRows,list_sort)>
          <cfoutput>
           #paging.div#
          </cfoutput>
        </cfif>

      </div>

      <div style="clear:both;"></div>

      <cfset scroll_row = 0>

      <div id="list_table_div" class="list_table_wrap" style="margin-top:10px; max-height:85vh;">
        <table id="list_table">
          <thead>
            <tr>
              <th width="#width_icon#">
              </th>
              <cfloop index="i" from="1" to="#ArrayLen(title_arr[1])#">
                <th width="#title_arr[2][i]#">
                  #title_arr[1][i]#&nbsp;
                  <cfset even = i*2>
                  <cfset odd = i*2-1>
                  <a>
                    <cfif list_sort eq odd>
                      <img src="images/svg/sort_asc.svg" onclick="changeSort(#even#)">
                    <cfelseif list_sort eq even>
                      <img src="images/svg/sort_desc.svg" onclick="changeSort(#odd#)">
                    <cfelse>
                      <img src="images/svg/sort_both.svg" onclick="changeSort(#even#)">
                    </cfif>
                  </a>
                </th>
              </cfloop>
            </tr>
          </thead>
          <tbody>
            <cfif #qGetSurvey.recordcount# gte 1>
              <cfloop index="i" from="#paging.s_page#" to="#paging.e_page#">
              <cfif i gt qGetSurvey.recordcount>
                <cfbreak>
              </cfif>

              <cfif scroll_survey_no eq qGetSurvey.survey_no[i]>
                <cfif i MOD MaxRows eq 0>
                  <cfset scroll_row = MaxRows>
                <cfelse>
                  <cfset scroll_row = i MOD MaxRows>
                </cfif>
              </cfif>
              <tr>
                <td class="p-operation-btn p-disabled-btn" style="text-align:center;">
                  <svg class="l_icon edit_btn" viewBox="0 0 24 24" onclick="editPage('#qGetSurvey.survey_no[i]#')"><use xlink:href="##right_arrow_icon"/></svg>
                </td>
                 <td style="text-align:center;">
                  #qGetSurvey.char_survey_datetime[i]#
                </td>
                <td style="text-align:center;">
                  #qGetSurvey.survey_no[i]#
                </td>
                <td>
                  #qGetSurvey.prefecture_name[i]#
                </td>
                <td style="text-align:center;">
                  #qGetSurvey.shop_code[i]#
                </td>
                <td>
                  #qGetSurvey.shop_name[i]#
                </td>
                <td>
                  #qGetSurvey.sheet_name[i]#
                </td>
                <td>
                  #qGetSurvey.sheet_pattern_name[i]#
                </td>
                <td style="text-align:left;">
                  #qGetSurvey.survey_staff_name[i]#
                </td>
              </tr>
            </cfloop>
            <cfelse>
              <tr>
                <td colspan="#ArrayLen(title_arr[1]) + 1#">
                  データはありません。
                </td>
              </tr>  
            </cfif>
          </tbody>
        </table>
      </div><!--- list_table_wrap --->
    </div><!--- wrap --->

      <input type="hidden" id="scroll_row" value="#scroll_row#">

    </form>
    </cfoutput>

    <cfinclude template="common/js.cfm">
    <cfoutput>
      <script src="#Application.asset_url#/js/scroll.js?21090611" defer></script>
      <script src="#Application.asset_url#/js/t_survey.js?2022052401" defer></script>
    </cfoutput>
  </body>
</html>