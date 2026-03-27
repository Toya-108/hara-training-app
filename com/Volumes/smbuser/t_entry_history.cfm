<cfinclude template = "init.cfm">


<cfset scroll_shop_code = "-----">
<cfif StructKeyExists(Form, "shop_code")>
  <cfif Form.shop_code neq "">
    <cfset scroll_shop_code = Form.shop_code>   
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
  <cfset list_sort = 1>
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

<cfif StructKeyExists(form,"search_list_sheet_code_ddlb") and form.search_list_sheet_code_ddlb neq "">
  <cfset search_list_sheet_code_ddlb = form.search_list_sheet_code_ddlb>
<cfelse>
  <cfset search_list_sheet_code_ddlb = "All">
</cfif>

<cfif StructKeyExists(form,"search_list_entry_date") and form.search_list_entry_date neq "">
  <cfset search_list_entry_date = form.search_list_entry_date>
<cfelse>
  <cfset search_list_entry_date = "">
</cfif>

<cfif StructKeyExists(form,"search_list_entry_staff_name") and form.search_list_entry_staff_name neq "">
  <cfset search_list_entry_staff_name = form.search_list_entry_staff_name>
<cfelse>
  <cfset search_list_entry_staff_name = "">
</cfif>


  <cfset filtering = "">
  <cfset order_by = "">

<!---   <cfif list_screen neq 1>
  </cfif> --->
    <cfif search_list_area_code_ddlb neq "All">
      <cfset filtering = filtering & " AND m_shop.area_code = '" & search_list_area_code_ddlb & "' ">
    </cfif>
    <cfif search_list_shop_code neq "All" and search_list_shop_code neq "">
      <cfset filtering = filtering & " AND t_entry_history.shop_code = '" & search_list_shop_code & "' ">
    </cfif>
    <cfif search_list_entry_date neq "">
      <cfset filtering = filtering & " AND t_entry_history.entry_date = '" & search_list_entry_date & "' ">
    </cfif>
    <cfif search_list_entry_staff_name neq "">
      <cfset filtering = filtering & " AND t_entry_history.entry_staff_name LIKE '%" & search_list_entry_staff_name & "%' ">
    </cfif>

    <cfif list_sort eq 1>
      <cfset order_by = " t_entry_history.entry_datetime">
    <cfelseif list_sort eq 2>
      <cfset order_by = " t_entry_history.entry_datetime DESC">
    <cfelseif list_sort eq 3>
      <cfset order_by = " m_shop.area_code">
    <cfelseif list_sort eq 4>
      <cfset order_by = " m_shop.area_code DESC">
    <cfelseif list_sort eq 5>
      <cfset order_by = " t_entry_history.shop_code">
    <cfelseif list_sort eq 6>
      <cfset order_by = " t_entry_history.shop_code DESC">
    <cfelseif list_sort eq 7>
      <cfset order_by = " t_entry_history.entry_staff_code">
    <cfelseif list_sort eq 8>
      <cfset order_by = " t_entry_history.entry_staff_code DESC">
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

  <cfquery name="qGetShopList">
      SELECT m_shop.shop_code AS list_shop_code,
             m_shop.shop_name AS list_shop_name
        FROM m_shop
    ORDER BY LPAD(m_shop.shop_code, 10, '0')
  </cfquery>


<cfquery name="qGetEntryHistory">
  SELECT t_entry_history.entry_datetime,
         CONCAT(date_format(t_entry_history.entry_datetime, '%Y/%m/%d'), ' ', time_format(t_entry_history.entry_datetime, '%H:%i')) as char_entry_datetime,
         t_entry_history.entry_staff_code,
         t_entry_history.entry_staff_name,
         t_entry_history.entry_date,
         t_entry_history.shop_code,
         m_shop.shop_name,
         m_shop.area_code,
         m_area.area_name
    FROM t_entry_history LEFT OUTER JOIN (m_shop LEFT OUTER JOIN m_area ON m_shop.area_code = m_area.area_code) ON t_entry_history.shop_code = m_shop.shop_code
   WHERE 1 = 1
         #PreserveSingleQuotes(filtering)#
  ORDER BY #PreserveSingleQuotes(order_by)#

</cfquery>


<cfset title_name = "ドライバー入店履歴">
<cfset title_arr = ArrayNew(2)>
<cfset title_arr[1][1] = "入店日時">
<cfset title_arr[1][2] = "地域">
<cfset title_arr[1][3] = "店舗">
<cfset title_arr[1][4] = "ドライバー">

<!--- 幅 --->
<cfset title_arr[2][1] = "5%">
<cfset title_arr[2][2] = "7%%">
<cfset title_arr[2][3] = "6%">
<cfset title_arr[2][4] = "15%">

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
        <div>店舗&nbsp;
          <input type="text" name="search_list_shop_code" id="search_list_shop_code" class="box_input2 p-search p-focus-move" value="#search_list_shop_code#" maxlength="10" style="width:70px;">
          <select name="search_list_shop_code_ddlb" id="search_list_shop_code_ddlb" class="drop_list01 p-search">
            <option value="All" <cfif search_list_shop_code_ddlb eq "All">selected="selected"</cfif>>すべて</option>
            <cfloop query="qGetShopList">
              <option value="#list_shop_code#" <cfif search_list_shop_code_ddlb eq list_shop_code>selected="selected"</cfif>>#list_shop_code#&emsp;#list_shop_name#</option>
            </cfloop>
          </select>
        </div>
        <div>入店日&nbsp;
          <input type="text" name="search_list_entry_date" id="search_list_entry_date" class="box_input_date p-search p-jquery-ui-datepicker p-focus-move" value="#search_list_entry_date#" maxlength="10" readonly>
        </div>
        <div>ドライバー名&nbsp;
          <input type="text" name="search_list_entry_staff_name" id="search_list_entry_staff_name" class="box_input2 p-search p-focus-move" value="#search_list_entry_staff_name#" maxlength="10">
        </div>
        <div class="p-operation-btn p-disabled-btn">
          <svg id="search_btn" class="search_icon p-info-box" viewBox="0 0 100 100" title="検索"><use xlink:href="##search_icon" /></svg>
        </div>
        <div class="p-operation-btn p-disabled-btn">
          <svg id="search_clear_btn" class="search_icon p-info-box" viewBox="0 0 24 22.5" style="margin-left: 0px;" title="クリア"><use xlink:href="##search_clear_icon" /></svg>
        </div>
      </div>

      <div style="float:left;margin-top:15px;">
      </div>
      <div style="float:right;margin-top:15px;">
        <cfif qGetEntryHistory.RecordCount GTE 1>
          <cfset MaxRows = 100>
          <cfset pg = createObject("component","com.paging")>
          <cfset paging = pg.setPage(list_page,qGetEntryHistory.RecordCount,MaxRows,list_sort)>
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
            <cfif #qGetEntryHistory.recordcount# gte 1>
              <cfloop index="i" from="#paging.s_page#" to="#paging.e_page#">
              <cfif i gt qGetEntryHistory.recordcount>
                <cfbreak>
              </cfif>

              <cfif scroll_shop_code eq qGetEntryHistory.shop_code[i]>
                <cfif i MOD MaxRows eq 0>
                  <cfset scroll_row = MaxRows>
                <cfelse>
                  <cfset scroll_row = i MOD MaxRows>
                </cfif>
              </cfif>
              <tr>
                 <td style="text-align:center;">
                  #qGetEntryHistory.char_entry_datetime[i]#
                </td>
                <td>
                  #qGetEntryHistory.area_name[i]#
                </td>
                <td>
                  #qGetEntryHistory.shop_name[i]#
                </td>
                <td>
                  #qGetEntryHistory.entry_staff_name[i]#
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
    </form>
    </cfoutput>

    <!--- csv出力処理 --->
    <cfif IsDefined("form.exp_flg") and form.exp_flg eq 1>
      <cfif DirectoryExists(application.temp_dir & Application.dir_separator & "shop") is false>
        <cfset create_dir = application.temp_dir & Application.dir_separator & "shop">
          <cfdirectory action="create" directory="#create_dir#" mode="777">
      </cfif>
      <cflog file="Compact5-Master" type="information" text="ショップマスタ　担当者：#Session.staff_code#　エクスポート">
      <cfset today = LSDateFormat(now(),"yyyymmdd")>
      <cfset time = TimeFormat(now(), "HHnnss")>
      <cfset filename = Application.temp_dir & Application.dir_separator & "staff_" & Session.staff_code & "_" & today & time & ".csv">
      <cfset header = "店舗コード,">
      <cfset header = header & "店舗名,">
      <cfset header = header & "地域名,">
      <cfset header = header & "住所1,">
      <cfset header = header & "住所2,">
      <cfset header = header & "電話番号,">
      <cfset header = header & "登録日時,">
      <cfset header = header & "登録者コード,">
      <cfset header = header & "登録者,">
      <cfset header = header & "更新日時,">
      <cfset header = header & "更新者コード,">
      <cfset header = header & "更新者">
      <cffile action="write" file="#filename#" output="#header#" charset="shift_jis">
      <cfloop index="cnt" from="1" to="#qGetShop.RecordCount#">
        <cfset data = "">
        <cfset data = data & qGetShop.shop_code[cnt] & ",">
        <cfset data = data & qGetShop.shop_name[cnt] & ",">
        <cfset data = data & qGetShop.area_name[cnt] & ",">
        <cfset data = data & qGetShop.address1[cnt] & ",">
        <cfset data = data & qGetShop.address2[cnt] & ",">
        <cfset data = data & qGetShop.tel_no[cnt] & ",">
        <cfset data = data & qGetShop.char_create_date[cnt] & ",">
        <cfset data = data & qGetShop.create_staff_code[cnt] & ",">
        <cfset data = data & qGetShop.create_staff_name[cnt] & ",">
        <cfset data = data & qGetShop.char_update_date[cnt] & ",">
        <cfset data = data & qGetShop.update_staff_code[cnt] & ",">
        <cfset data = data & qGetShop.update_staff_name[cnt]>
        <cffile action="append" file="#filename#" output="#data#" charset="shift_jis"> 
      </cfloop>
        <cfheader name="Content-Disposition" value="attachment; filename=店舗マスタ_#Session.staff_code#_#today##time#.csv" charset="shift_jis">
      <cfcontent type="text/csv" file="#filename#" deletefile="yes">
    </cfif>
    <!--- csv出力処理　ここまで --->

    <cfinclude template="common/js.cfm">
    <cfoutput>
      <script src="#Application.asset_url#/js/scroll.js?21090611" defer></script>
      <script src="#Application.asset_url#/js/t_entry_history.js?20220330" defer></script>
    </cfoutput>
  </body>
</html>