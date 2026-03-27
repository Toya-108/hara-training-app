<!DOCTYPE html>
<html lang="ja">
<head>




<!---   <cfif IsDefined("form.pref") and form.pref neq "">
    <cfset pref = form.pref>
  <cfelse>
    <cfset pref = "">
  </cfif>
 --->  
 <cfif IsDefined("form.month") and form.month neq "">
    <cfset month = form.month>
  <cfelse>
    <cfset month = "">
  </cfif>

  <cfif IsDefined("form.prefecture") and form.prefecture neq "">
      <cfset prefecture = form.prefecture>
  <cfelse>
      <cfif IsDefined("url.pref") and url.pref neq "">
          <cfset prefecture = url.pref>
      <cfelse>
          <cfset prefecture = "">
      </cfif>  
  </cfif>
  <cfif IsDefined("form.large_category") and form.large_category neq "">
    <cfset large_category = form.large_category>
  <cfelse>
    <cfif IsDefined("url.lc") and url.lc neq "">
      <cfset large_category = url.lc>
    <cfelse>
      <cfset large_category = ""><!--- デフォルトの値 --->
    </cfif>
  </cfif>

  <cfif IsDefined("form.middle_category") and form.middle_category neq "">
    <cfset middle_category = form.middle_category>
  <cfelse>
    <cfif IsDefined("url.mc") and url.mc neq "">
      <cfset middle_category = url.mc>
    <cfelse>
      <cfset middle_category = ""><!--- デフォルトの値 --->
    </cfif>
  </cfif>

  <cfif IsDefined("form.theme_id") and form.theme_id neq "">
    <cfset theme_id = form.theme_id>
  <cfelse>
    <cfif IsDefined("url.ti") and url.ti neq "">
      <cfset theme_id = url.ti>
    <cfelse>
      <cfset theme_id = ""><!--- デフォルトの値 --->
    </cfif>
  </cfif>

  <cfif IsDefined("form.lecture_style_id") and form.lecture_style_id neq "">
    <cfset lecture_style_id = form.lecture_style_id>
  <cfelse>
    <cfif IsDefined("url.ls") and url.ls neq "">
      <cfset lecture_style_id = url.ls>
    <cfelse>
      <cfset lecture_style_id = ""><!--- デフォルトの値 --->
    </cfif>
  </cfif>

<!---   <cfif IsDefined("url.seminarNo") and url.seminarNo neq "">
    <cfset form.keyword = url.seminarNo>
  </cfif> --->
  <cfif IsDefined("form.keyword") and form.keyword neq "">
      <cfset keyword = form.keyword>
  <cfelse>
      <cfif IsDefined("url.keyword") and url.keyword neq "">
          <cfset keyword = URLDecode(url.keyword)>
      <cfelse>
        <cfif IsDefined("url.kw") and url.kw neq "">
          <cfset keyword = URLDecode(url.kw)>
        <cfelse>
          <cfset keyword = "">
        </cfif>
        
      </cfif>  
  </cfif>

  <cfset keyword = replace(keyword,"'","","all")>

  <cfif IsDefined("form.dy") and form.dy neq "">
      <cfset target_day = form.dy>
  <cfelse>
      <cfif IsDefined("url.dy") and url.dy neq "">
          <cfset target_day = url.dy>
      <cfelse>
          <cfset target_day = "">
      </cfif>  
  </cfif>


  <cfscript>
    //あいまい検索したいカラムをここにセット
    target_colums = [
                'SPEAKER1.name',
                'SPEAKER2.name',
                'SPEAKER3.name',
                'SPEAKER1.company_name',
                'SPEAKER2.company_name',
                'SPEAKER3.company_name',
                'SPEAKER1.department',
                'SPEAKER2.department',
                'SPEAKER3.department',
                'SPEAKER1.post',
                'SPEAKER2.post',
                'SPEAKER3.post',
                'm_seminar.seminar_code',
                'm_seminar.main_theme',
                'm_seminar.sub_theme',
                'm_seminar.sub_theme2',
                'm_seminar.title1',
                'm_seminar.description1',
                'm_seminar.title2',
                'm_seminar.description2'             ];
    keywords = ListToArray(Replace(keyword,'　',' ','all')," ",true);
    joken = "";
    for(i=1;i LTE ArrayLen(keywords);i=i+1) {
      joken &= " AND(";
        for(idx=1; idx LTE ArrayLen(target_colums);idx = idx + 1){

                  joken &= " convert(" & target_colums[idx] & " using utf8)" & "  collate utf8_unicode_ci LIKE '%" & keywords[i] & "%' OR ";
        }
      joken &= " 1<>1)";
    }
   
  </cfscript>
  <cftry>

    <cfquery name="qGetSeminar">
      SELECT DISTINCT m_seminar.seminar_code,
             m_seminar.event_date,
             date_format(m_seminar.event_date, '%Y年%c月') AS char_event_month,
             date_format(m_seminar.event_date, '%c月%e日') AS char_event_date,
             CASE DAYOFWEEK(m_seminar.event_date) WHEN 1 THEN '日'
                                                  WHEN 2 THEN '月'
                                                  WHEN 3 THEN '火'
                                                  WHEN 4 THEN '水'
                                                  WHEN 5 THEN '木'
                                                  WHEN 6 THEN '金'
                                                  WHEN 7 THEN '土' END as char_youbi,
             m_seminar.start_time,
             date_format(m_seminar.start_time, '%H:%i') AS char_start_time,
             date_format(m_seminar.end_time, '%H:%i') AS char_end_time,
             CASE WHEN CHAR_LENGTH(m_seminar.main_theme) > 41 THEN CONCAT(SUBSTRING(REPLACE(m_seminar.main_theme ,'\r\n',''),1,41),'...') 
                  ELSE m_seminar.main_theme
                END AS char_main_theme,
             m_seminar.main_theme,
             CASE WHEN CHAR_LENGTH(m_seminar.sub_theme) > 43 THEN CONCAT(SUBSTRING(REPLACE(m_seminar.sub_theme ,'\r\n',''),1,43),'...') 
                  ELSE m_seminar.sub_theme
                END AS char_sub_theme,


            CASE WHEN m_seminar.unlimited_publicable_flag = 1 AND m_seminar.event_date < curdate() THEN 1
                 ELSE 0
                END AS is_archive,
             m_seminar.sub_theme,
             m_seminar.sub_theme2,
             m_seminar.title1,
             m_seminar.description1,
             m_seminar.title2,
             m_seminar.description2,
             m_seminar.place_id,
             m_place.place_name,
             m_seminar.entry_fee_name,
             m_seminar.unit_price_include_tax_1,
             m_seminar.unit_price_include_tax_2,
             m_seminar.unit_price_include_tax_3,
             m_seminar.unit_price_include_tax_4,
             m_seminar.unit_price_include_tax_5,
             m_seminar.publication_date,
             m_seminar.large_category_id1,
             m_seminar.large_category_id2,
             m_seminar.large_category_id3,
             m_seminar.large_category_id4,
             m_seminar.large_category_id5,
             m_seminar.large_category_id6,
             m_seminar.large_category_id7,
             m_seminar.large_category_id8,
             m_seminar.large_category_id9,
             m_seminar.large_category_id10,

             LARGE1.large_category_name large_name1,
             LARGE2.large_category_name large_name2,
             LARGE3.large_category_name large_name3,
             LARGE4.large_category_name large_name4,
             LARGE5.large_category_name large_name5,
             LARGE6.large_category_name large_name6,
             LARGE7.large_category_name large_name7,
             LARGE8.large_category_name large_name8,
             LARGE9.large_category_name large_name9,
             LARGE10.large_category_name large_name10,


             m_seminar.middle_category_id1,
             m_seminar.middle_category_id2,
             m_seminar.middle_category_id3,
             m_seminar.middle_category_id4,
             m_seminar.middle_category_id5,
             m_seminar.middle_category_id6,
             m_seminar.middle_category_id7,
             m_seminar.middle_category_id8,
             m_seminar.middle_category_id9,
             m_seminar.middle_category_id10,

             MIDDLE1.middle_category_name middle_name1,
             MIDDLE2.middle_category_name middle_name2,
             MIDDLE3.middle_category_name middle_name3,
             MIDDLE4.middle_category_name middle_name4,
             MIDDLE5.middle_category_name middle_name5,
             MIDDLE6.middle_category_name middle_name6,
             MIDDLE7.middle_category_name middle_name7,
             MIDDLE8.middle_category_name middle_name8,
             MIDDLE9.middle_category_name middle_name9,
             MIDDLE10.middle_category_name middle_name10,
             <cfloop index="i" from="1" to="3">
               CONCAT(SPEAKER#i#.name,' 氏') name#i#,
               SPEAKER#i#.company_name company_name#i#,
               SPEAKER#i#.department department#i#,
               SPEAKER#i#.post post#i#, 
               SPEAKER#i#.file_name file_name#i#,           
             </cfloop>         
             m_seminar.fee_note,
             m_seminar.note,
             m_seminar.create_date,
             m_seminar.update_date
        FROM m_seminar LEFT OUTER JOIN m_place ON m_seminar.place_id = m_place.place_id
                       LEFT OUTER JOIN m_large_category LARGE1 ON m_seminar.large_category_id1 = LARGE1.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE2 ON m_seminar.large_category_id2 = LARGE2.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE3 ON m_seminar.large_category_id3 = LARGE3.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE4 ON m_seminar.large_category_id4 = LARGE4.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE5 ON m_seminar.large_category_id5 = LARGE5.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE6 ON m_seminar.large_category_id6 = LARGE6.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE7 ON m_seminar.large_category_id7 = LARGE7.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE8 ON m_seminar.large_category_id8 = LARGE8.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE9 ON m_seminar.large_category_id9 = LARGE9.large_category_id
                       LEFT OUTER JOIN m_large_category LARGE10 ON m_seminar.large_category_id10 = LARGE10.large_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE1 ON m_seminar.middle_category_id1 = MIDDLE1.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE2 ON m_seminar.middle_category_id2 = MIDDLE2.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE3 ON m_seminar.middle_category_id3 = MIDDLE3.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE4 ON m_seminar.middle_category_id4 = MIDDLE4.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE5 ON m_seminar.middle_category_id5 = MIDDLE5.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE6 ON m_seminar.middle_category_id6 = MIDDLE6.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE7 ON m_seminar.middle_category_id7 = MIDDLE7.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE8 ON m_seminar.middle_category_id8 = MIDDLE8.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE9 ON m_seminar.middle_category_id9 = MIDDLE9.middle_category_id
                       LEFT OUTER JOIN m_middle_category MIDDLE10 ON m_seminar.middle_category_id10 = MIDDLE10.middle_category_id

                       LEFT OUTER JOIN m_theme THEME1 ON m_seminar.theme_id1 = THEME1.theme_id
                       LEFT OUTER JOIN m_theme THEME2 ON m_seminar.theme_id2 = THEME2.theme_id
                       LEFT OUTER JOIN m_theme THEME3 ON m_seminar.theme_id3 = THEME3.theme_id
    <cfloop index="i" from="1" to="3">
                        LEFT OUTER JOIN ( SELECT t_seminar_speaker_mapping.seminar_code,
                                                t_seminar_speaker_mapping.name,
                                                t_seminar_speaker_mapping.company_name,
                                                t_seminar_speaker_mapping.department,
                                                t_seminar_speaker_mapping.post,
                                                t_seminar_speaker_mapping.file_name
                                           FROM t_seminar_speaker_mapping
                                          WHERE t_seminar_speaker_mapping.sort_order = #i# ) SPEAKER#i# ON m_seminar.seminar_code = SPEAKER#i#.seminar_code                    
    </cfloop>
        <!---
                       LEFT OUTER JOIN (SELECT t_category_seminar_mapping.seminar_id,
                                               t_category_seminar_mapping.middle_category_id,
                                               m_middle_category.large_category_id
                                          FROM t_category_seminar_mapping,m_middle_category
                                         WHERE t_category_seminar_mapping.middle_category_id = m_middle_category.middle_category_id
                                              <cfif large_category neq "">
                                               AND m_middle_category.large_category_id =  #large_category#
                                              </cfif> 
                                        ) SMAPPING ON m_seminar.seminar_id AND SMAPPING.seminar_id
                                        --->

       WHERE (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
       AND (m_seminar.event_date >= curdate() or m_seminar.unlimited_publicable_flag = 1)
       AND m_seminar.event_date IS NOT NULL
       AND m_seminar.fm_fpub = 1

        <cfif prefecture neq "">
          AND m_place.prefecture_id = #pref#
        </cfif>
        <cfif month neq "">
          AND DATE_FORMAT(m_seminar.event_date,'%m') = #month#
        </cfif>
        <cfif target_day neq "" and IsDate(target_day)>
          AND m_seminar.event_date = <cfqueryparam value="#target_day#" cfsqltype="CF_SQL_DATE" maxlength="20">
        </cfif>

        <cfif large_category neq "">
         AND (   LARGE1.large_category_id =  #large_category#
              OR LARGE2.large_category_id =  #large_category#
              OR LARGE3.large_category_id =  #large_category#
              OR LARGE4.large_category_id =  #large_category#
              OR LARGE5.large_category_id =  #large_category#
              OR LARGE6.large_category_id =  #large_category#
              OR LARGE7.large_category_id =  #large_category#
              OR LARGE8.large_category_id =  #large_category#
              OR LARGE9.large_category_id =  #large_category#
              OR LARGE10.large_category_id =  #large_category# 
             )
        </cfif>
        <cfif middle_category neq "">
         AND (   MIDDLE1.middle_category_id =  #middle_category#
              OR MIDDLE2.middle_category_id =  #middle_category#
              OR MIDDLE3.middle_category_id =  #middle_category#
              OR MIDDLE4.middle_category_id =  #middle_category#
              OR MIDDLE5.middle_category_id =  #middle_category#
              OR MIDDLE6.middle_category_id =  #middle_category#
              OR MIDDLE7.middle_category_id =  #middle_category#
              OR MIDDLE8.middle_category_id =  #middle_category#
              OR MIDDLE9.middle_category_id =  #middle_category#
              OR MIDDLE10.middle_category_id =  #middle_category# 
             )
        </cfif>
        <cfif theme_id neq "">
         AND (   m_seminar.theme_id1 =  #theme_id#
              OR m_seminar.theme_id2 =  #theme_id#
              OR m_seminar.theme_id3 =  #theme_id# 
             )
        </cfif>
        <cfif lecture_style_id neq "">
         AND m_seminar.lecture_style_list LIKE '%#lecture_style_id#%'
        </cfif>
        <cfif keyword neq "">
            #PreserveSingleQuotes(joken)#
        </cfif>
        ORDER BY m_seminar.event_date,m_seminar.start_time              
    </cfquery>
    <cfcatch type="database">
      エラーが発生しました。<br>お手数ですが、もう一度戻ってお試しください。<cfabort>
      <cflog type="information" file="jpi_error" text="seminar_list.cfm--検索エラー---キーワード---#keyword#">
    </cfcatch>
  </cftry>
  <cfif keyword neq "">
    <cflog type="information" file="jpi_info" text="seminar_list.cfm--検索---キーワード---#keyword#">
  </cfif>
  <cfquery name="qGgetPref">
    SELECT prefecture_id,prefecture_name FROM m_prefecture
  </cfquery>
  <cfquery name="qGetCategory">
    SELECT large_category_id,large_category_name FROM m_large_category
  </cfquery>
  <cfquery name="qGetTheme">
    SELECT theme_id,theme FROM m_theme
  </cfquery>
  <cfquery name="qGetLectureStyle">
    SELECT lecture_style_id,lecture_style_name,archive_flag FROM m_lecture_style
  </cfquery>

  <cfquery name="qGetCategoryNum">
     SELECT m_middle_category.large_category_id,
            m_large_category.large_category_name,
            m_large_category.img_file,
            m_middle_category.middle_category_id,
            m_middle_category.middle_category_name,
           COUNT(SEMINAR.middle_category_id) AS middle_category_cnt
      FROM m_middle_category LEFT OUTER JOIN (SELECT m_seminar.middle_category_id1 AS middle_category_id
                                                FROM m_seminar
                                               WHERE main_theme IS NOT NULL
                                                 AND m_seminar.fm_fpub = 1
                                                 AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                                 AND m_seminar.event_date >= curdate()
                                               UNION ALL
                                              SELECT m_seminar.middle_category_id2 AS middle_category_id
                                                FROM m_seminar
                                               WHERE main_theme IS NOT NULL
                                                AND m_seminar.fm_fpub = 1
                                                AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                                AND m_seminar.event_date >= curdate()
                                               UNION ALL
                                              SELECT m_seminar.middle_category_id3 AS middle_category_id
                                                FROM m_seminar
                                               WHERE main_theme IS NOT NULL
                                                 AND m_seminar.fm_fpub = 1
                                                 AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                                 AND m_seminar.event_date >= curdate()
                                               UNION ALL
                                              SELECT m_seminar.middle_category_id4 AS middle_category_id
                                                FROM m_seminar
                                              WHERE main_theme IS NOT NULL
                                                AND m_seminar.fm_fpub = 1
                                                AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                                AND m_seminar.event_date >= curdate()
                                               UNION ALL
                                              SELECT m_seminar.middle_category_id5 AS middle_category_id
                                                FROM m_seminar
                                               WHERE main_theme IS NOT NULL
                                                 AND m_seminar.fm_fpub = 1
                                                 AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                                 AND m_seminar.event_date >= curdate()
                                                  ) SEMINAR ON m_middle_category.middle_category_id = SEMINAR.middle_category_id
                             LEFT OUTER JOIN m_large_category ON m_middle_category.large_category_id = m_large_category.large_category_id
    GROUP BY m_middle_category.large_category_id,
            m_large_category.large_category_name,
            m_large_category.img_file,
            m_middle_category.middle_category_id,
            m_middle_category.middle_category_name
    ORDER BY m_middle_category.large_category_id,middle_category_id
  </cfquery>
  <cfset footer_title = "">
  <cfset left_header_title = "">
  <cfset footer_description = "">
  <cfif prefecture neq "">
    <cfquery name="qGgetPrefName">
      SELECT prefecture_id,prefecture_name 
        FROM m_prefecture
      WHERE prefecture_id = <cfqueryparam value="#Left(prefecture,2)#" cfsqltype="CF_SQL_INTEGER" maxlength="5">
    </cfquery>
    <cfset footer_title = qGgetPrefName.prefecture_name>
    <cfset footer_description = "">
    <cfset left_header_title = qGgetPrefName.prefecture_name>    
  </cfif>

  <cfif theme_id neq "">
    <cfquery name="qGgetThemeName">
      SELECT m_theme.theme,m_theme.description
        FROM m_theme
       WHERE m_theme.theme_id = <cfqueryparam value="#Left(theme_id,5)#" cfsqltype="CF_SQL_INTEGER" maxlength="5">
    </cfquery>
    <cfset footer_title = qGgetThemeName.theme>
    <cfset footer_description = qGgetThemeName.description>
    <cfset left_header_title = qGgetThemeName.theme & "のセミナー一覧">
  </cfif>
  <cfif lecture_style_id neq "">
    <cfquery name="qGgetLectureStyle">
      SELECT lecture_style_id,lecture_style_name
        FROM m_lecture_style
       WHERE m_lecture_style.lecture_style_id = <cfqueryparam value="#lecture_style_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="2">
    </cfquery>
    <cfset footer_title = qGgetLectureStyle.lecture_style_name>
    <cfset footer_description = "">
    <!--- <cfset left_header_title = qGgetThemeName.theme & "のセミナー一覧"> --->
  </cfif>

  <cfif large_category neq "">
    <cfquery name="qGgetLargeCategoryName">
      SELECT m_large_category.large_category_name,
             m_large_category.large_category_name_disp,
             m_large_category.description
        FROM m_large_category
       WHERE m_large_category.large_category_id = <cfqueryparam value="#Left(large_category,5)#" cfsqltype="CF_SQL_INTEGER" maxlength="5">
    </cfquery>
    <cfset footer_title = qGgetLargeCategoryName.large_category_name_disp>
    <cfset footer_description = qGgetLargeCategoryName.description>
    <cfset left_header_title = qGgetLargeCategoryName.large_category_name_disp & "のセミナー予定一覧">
  </cfif>
  <cfif middle_category neq "">
    <cfquery name="qGetCategoryName">
      SELECT m_large_category.large_category_name,
             m_middle_category.middle_category_name,
             m_large_category.color,
             m_large_category.img_file,
             m_middle_category.description
        FROM m_large_category LEFT OUTER JOIN m_middle_category ON m_large_category.large_category_id = m_middle_category.large_category_id
       WHERE m_middle_category.middle_category_id = <cfqueryparam value="#Left(middle_category,5)#" cfsqltype="CF_SQL_INTEGER" maxlength="5">
    </cfquery>
    <cfset footer_title = qGetCategoryName.middle_category_name & " 関連">
    <cfset footer_description = qGetCategoryName.description>
    <cfset left_header_title = qGetCategoryName.middle_category_name & " 関連のセミナー日程一覧">
  </cfif>

  <cfif left_header_title eq "">
    <cfset left_header_title = "セミナー一覧・検索">
    <cfset header_content_desc = "セミナー情報を所管省庁、テーマ、開催日、受講方法、フリーワードから検索できます。">
  <cfelse>
    <cfset header_content_desc = left_header_title & "のセミナー情報一覧です。">
  </cfif>
  <cfset css_file = "side.css?3333">
  <cfset css_file2 = "seminar_list.css?1234456">
  
  <cfinclude template="header3.cfm">
  <cfoutput>
    <link rel="stylesheet" href="#application.base_url#css2/fullcalendar.min.css" type="text/css">
  </cfoutput>

  <cfset page_title = 'セミナー一覧'>
  <cfif middle_category neq "">
    <cfset page_title = qGetCategoryName.large_category_name & "/" & qGetCategoryName.middle_category_name>
  </cfif>
  <cfif CGI.SCRIPT_NAME contains "seminar_list.cfm">
    <cfoutput><link rel="canonical" href="#application.base_url#seminar_list?#CGI.QUERY_STRING#"></cfoutput>
  </cfif>
</head>
<body>
  <cfoutput>
    <nav class="breadcrum fade">
        <ul>
            <a href="#application.base_url#">
                <li>TOP</li>
            </a>
            <span class="migi">></span>
            <a href="#application.base_url#seminar_list">
                <li><span>セミナー一覧ページ</span></li>
            </a>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </ul>
    </nav>
  </cfoutput>
    
  <div class="contents">
    <cfoutput>
      <div class="sidebar" id="pc">
        <div>
          <div class="ministry_navigation">
            <div class="ministry_menu">
              <cfset category_cnt = 1>
              <cfloop index="i" from="1" to="#qGetCategoryNum.RecordCount#">
                  <cfif qGetCategoryNum.large_category_id[i] neq qGetCategoryNum.large_category_id[i - 1]>
                    <cfset category_cnt = category_cnt + 1>
                      <h3>
                        <a href="#application.base_url#seminar_list?lc=#qGetCategoryNum.large_category_id[i]#">
                          <img src="#application.base_url#image/#qGetCategoryNum.img_file[i]#">#qGetCategoryNum.large_category_name[i]#
                        </a>
                      </h3>
                      <ul> 
                  </cfif>

                  <!--- middle_category --->
                  <cfif middle_category eq qGetCategoryNum.middle_category_id[i]>
                    <cfset bg_color = '##fff799'>
                  <cfelse>
                    <cfset bg_color = ''>
                  </cfif>
                  
                  <li>
                    <a onclick="getMiddle('#qGetCategoryNum.middle_category_id[i]#')">
                      #qGetCategoryNum.middle_category_name[i]#<cfif qGetCategoryNum.middle_category_cnt[i]neq 0>(#qGetCategoryNum.middle_category_cnt[i]#)</cfif>
                    </a>
                  </li>
                  <cfif qGetCategoryNum.large_category_id[i] neq qGetCategoryNum.large_category_id[i + 1]>
                    </ul>
                  </cfif>                  
              </cfloop>

            </div>
          </div>
        </div>
      </div>
    </cfoutput>
      <div class="main">


        <div class="search_container">

                  <cfoutput>
                    <!--- 日付検索用 --->
                    <input type="hidden" id="url_var" value="?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&ls=#lecture_style_id#">
                    <!--- キーワード検索用 --->
                    <input type="hidden" id="url_var2" value="?lc=#large_category#&ti=#theme_id#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">
                    <div class="icon_btn icon_btn1" id="button">
                        <img src="#application.base_url#image/syokan_icon.png">
                        <span class="icon_span" id="category_select">
                          <cfif large_category neq "">
                            #Left(qGgetLargeCategoryName.large_category_name,7)#
                          <cfelseif middle_category neq "">
                            #Left(qGetCategoryName.large_category_name,7)#
                          <cfelse>
                            所管省庁
                          </cfif>
                          
                        </span>
                    </div>
                        
                        <ul class="ul_1" id="pop_up" style="display:none;text-align:left;">
                          <li>
                              <a href="#application.base_url#seminar_list?lc=&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">全所管官庁</a>
                          </li>
                          <cfloop index="i" from="1" to="#qGetCategory.RecordCount#">
                            <li>
                              <a href="#application.base_url#seminar_list?lc=#qGetCategory.large_category_id[i]#&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">#qGetCategory.large_category_name[i]#</a>
                            </li>
                          </cfloop>
                        </ul>
                        
                    <div class="icon_btn icon_btn2" id="button2">
                        <img src="#application.base_url#image/tikyuu_icon.png">
                        <span class="icon_span" id="theme_select">
                          <cfif theme_id neq "">
                            #Left(qGgetThemeName.theme,7)#
                          <cfelse>
                            テーマ
                          </cfif>
                        </span>
                    </div>
                    
                        <ul class="ul_1" id="pop_up2" style="display:none;text-align:left;">
                          <li>
                              <a href="#application.base_url#seminar_list?lc=#large_category#&ti=&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">全テーマ</a>
                          </li>                          
                          <cfloop index="i" from="1" to="#qGetTheme.RecordCount#">
                            <li>
                              <a href="#application.base_url#seminar_list?lc=#large_category#&ti=#qGetTheme.theme_id[i]#&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">#qGetTheme.theme[i]#</a>
                            </li>
                          </cfloop>
                        </ul>
                    <div class="icon_btn icon_btn3" id="button3">
                        <img src="#application.base_url#image/calendar_icon.png">
                        <span class="icon_span" id="date_select">
                          <cfif target_day neq "">
                            #Right(target_day,5)#
                          <cfelse>
                            開催日
                          </cfif>                          
                          
                        </span>
                    </div>
                    

                        <ul class="ul_2" id="pop_up3" style="display:none;cursor:pointer;">
                            <li class="date">
                                <div id="calendar_short">

                                </div>
                            </li>
                        </ul>

                        <!--- classにspと入れると消える --->
                    <div class="icon_btn" id="button4">
                      <img src="#application.base_url#image/pen_icon.png" style="width:10;height:15px">
                        <!--- <img src="#application.base_url#image/access_icon.png"> --->
                        <span class="icon_span" id="lecture_select">
                          <cfif lecture_style_id neq "">
                            #qGgetLectureStyle.lecture_style_name#
                          <cfelse>
                            受講方法
                          </cfif> 
                        </span>
                    </div>


                        <ul class="ul_2" id="pop_up4" style="display:none;text-align:left;">
                          <li>
                              <a href="#application.base_url#seminar_list?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=">全て</a>
                          </li>                                                    
                          <cfloop index="i" from="1" to="#qGetLectureStyle.RecordCount#">
                            <li><a href="#application.base_url#seminar_list?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&dy=#target_day#&ls=#qGetLectureStyle.lecture_style_id[i]#">#qGetLectureStyle.lecture_style_name[i]#</a></li>
                          </cfloop>                           
                        </ul>  
                    <form name="seminar_cond" action="#application.base_url#seminar_list?lc=#large_category#&ti=#theme_id#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">                  
                      <div class="search_area">
                          <input type="text" name="keyword" id="freeword" value="#keyword#" placeholder="フリーワード" maxlength="30">
                      </div>
                      <div class="search_btn">
                          <img src="#application.base_url#image/search_icon.png" onclick="searchWithKeyword(13)">
                      </div>
                    </form>
                  </cfoutput>
        </div>
        <cfoutput>
          <div style="text-align:right;">
            <a href="#application.base_url#seminar_list">
              <span style="color:blue;">検索条件のクリア</span>
            </a>
          </div>
        </cfoutput>
        <cfoutput>
          <cfif qGetSeminar.RecordCount GTE 1>
            <!---
            <div style="text-align:left;color:red;">
              開催予定セミナー：<a href="##" style="text-decoration: underline;">#qGetSeminar.RecordCount#件</a><br>
              過去アーカイブセミナー：<a href="##" style="text-decoration: underline;">XX件</a>
            </div>
            --->
            <div class="date_list">
              
                  <cfset normal_seminar_cnt = 0>
                  <cfloop index="i" from="1" to="#qGetSeminar.RecordCount#">
                    <!--- アーカイブは下に表示するため飛ばす --->
                    <cfif qGetSeminar.is_archive[i] eq 1>
                      <cfcontinue>
                    <cfelse>
                      <cfset normal_seminar_cnt = normal_seminar_cnt + 1>
                    </cfif>
                    <cfif normal_seminar_cnt eq 1 or (qGetSeminar.char_event_month[i] neq qGetSeminar.char_event_month[i - 1])>
                      <table class="seminar_t1">
                          <tr>
                            <td colspan="3" class="month">
                              #qGetSeminar.char_event_month[i]#
                            </td>
                          </tr>
                    </cfif>
                          <tr>
                            <th class="date">
                              No.#qGetSeminar.seminar_code[i]#<br>
                              <span>#qGetSeminar.char_event_date[i]#</span>&nbsp;<span>(#qGetSeminar.char_youbi[i]#)</span><br>
                              <span>#qGetSeminar.char_start_time[i]#-#qGetSeminar.char_end_time[i]#</span>
                            </th>

                            <td class="seminar_content">
                              <div>
                                <a class="sub_title" onclick="movePage('#qGetSeminar.seminar_code[i]#')">
                                  #qGetSeminar.char_sub_theme[i]#
                                </a>
                                <br>
                                <a class="event_title" onclick="movePage('#qGetSeminar.seminar_code[i]#')">
                                  #qGetSeminar.main_theme[i]#
                                </a>
                              </div>
                              <div class="fl">
                                <div class="lh_100">
                                  #qGetSeminar.company_name1[i]#　
                                </div>
                                <div class="lh_100">
                                  #qGetSeminar.department1[i]#
                                </div>
                                <div class="lh_100">
                                  #qGetSeminar.post1[i]#
                                </div>
                                <div class="bold">
                                  #qGetSeminar.name1[i]#
                                </div>
                              </div>
                              <div class="fl" style="margin-left:10px;">
                                <div class="lh_100">
                                  #qGetSeminar.company_name2[i]#
                                </div>
                                <div class="lh_100">
                                  #qGetSeminar.department2[i]#
                                </div>                                
                                <div class="lh_100">
                                  #qGetSeminar.post2[i]#
                                </div>
                                <div class="bold">
                                  #qGetSeminar.name2[i]#
                                </div>
                              </div>
                              <div class="fl" style="margin-left:10px;">
                                <div class="lh_100">
                                  #qGetSeminar.company_name3[i]#
                                </div>
                                <div class="lh_100">
                                  #qGetSeminar.department3[i]#
                                </div>                                
                                <div class="lh_100">
                                  #qGetSeminar.post3[i]#
                                </div>
                                <div class="bold">
                                  #qGetSeminar.name3[i]#
                                </div>
                              </div>                              
                            </td>
                            <td class="cost">
                              <strong>セミナー参加費</strong>
    #qGetSeminar.fee_note[i]#
                            </td>

                          </tr>
                    <cfif i eq qGetSeminar.RecordCount or (qGetSeminar.char_event_month[i] neq qGetSeminar.char_event_month[i + 1])>
                      </table>
                    </cfif>

                  </cfloop>

                  <cfset archive_seminar_cnt = 0>
                  <table class="seminar_t1">
                      <tr>
                        <td colspan="3" class="month" style="background-color:##004d25">
                          アーカイブ配信(過去開催分)
                        </td>
                      </tr>
                      <cfloop index="i" from="1" to="#qGetSeminar.RecordCount#"  >
                        <cfif qGetSeminar.is_archive[i] neq 1>
                          <cfcontinue>
                        <cfelse>
                          <cfset archive_seminar_cnt = archive_seminar_cnt + 1>
                        </cfif>

                        <!---
                        <cfif archive_seminar_cnt eq 1 or (qGetSeminar.char_event_month[i] neq qGetSeminar.char_event_month[i - 1])>
                          <table class="seminar_t1">
                              <tr>
                                <td colspan="3" class="month">
                                  #qGetSeminar.char_event_month[i]#
                                </td>
                              </tr>
                        </cfif>
                        --->
                              <tr>
                                <th class="date">
                                  No.#qGetSeminar.seminar_code[i]#<br>
                                  <!--- <span>#qGetSeminar.char_event_date[i]#</span>&nbsp;<span>(#qGetSeminar.char_youbi[i]#)</span><br> --->
                                  <!--- <span>#qGetSeminar.char_start_time[i]#-#qGetSeminar.char_end_time[i]#</span> --->
                                </th>

                                <td class="seminar_content">
                                  <div>
                                    <a class="sub_title" onclick="movePage('#qGetSeminar.seminar_code[i]#')">
                                      #qGetSeminar.char_sub_theme[i]#
                                    </a>
                                    <br>
                                    <a class="event_title" onclick="movePage('#qGetSeminar.seminar_code[i]#')">
                                      #qGetSeminar.main_theme[i]#
                                    </a>
                                  </div>
                                  <div class="fl">
                                    <div class="lh_100">
                                      #qGetSeminar.company_name1[i]#　
                                    </div>
                                    <div class="lh_100">
                                      #qGetSeminar.department1[i]#
                                    </div>
                                    <div class="lh_100">
                                      #qGetSeminar.post1[i]#
                                    </div>
                                    <div class="bold">
                                      #qGetSeminar.name1[i]#
                                    </div>
                                  </div>
                                  <div class="fl" style="margin-left:10px;">
                                    <div class="lh_100">
                                      #qGetSeminar.company_name2[i]#
                                    </div>
                                    <div class="lh_100">
                                      #qGetSeminar.department2[i]#
                                    </div>                                
                                    <div class="lh_100">
                                      #qGetSeminar.post2[i]#
                                    </div>
                                    <div class="bold">
                                      #qGetSeminar.name2[i]#
                                    </div>
                                  </div>
                                  <div class="fl" style="margin-left:10px;">
                                    <div class="lh_100">
                                      #qGetSeminar.company_name3[i]#
                                    </div>
                                    <div class="lh_100">
                                      #qGetSeminar.department3[i]#
                                    </div>                                
                                    <div class="lh_100">
                                      #qGetSeminar.post3[i]#
                                    </div>
                                    <div class="bold">
                                      #qGetSeminar.name3[i]#
                                    </div>
                                  </div>                              
                                </td>
                                <td class="cost">
                                  <strong>セミナー参加費</strong>
        #qGetSeminar.fee_note[i]#
                                </td>

                              </tr>
                      <!---
                        <cfif i eq qGetSeminar.RecordCount or (qGetSeminar.char_event_month[i] neq qGetSeminar.char_event_month[i + 1])>
                          </table>
                        </cfif>
                        --->

                      </cfloop>
                      <cfif archive_seminar_cnt eq 0>
                      <tr>
                        <td colspan="3">
                          該当するセミナーはありません。
                        </td>
                      </tr>                        
                      </cfif>
                  </table>


                  <cfif footer_description neq "">
                    <div style="width:100%;text-align:left;">
                      <div style="border-bottom:medium solid ##23943E;display: inline-block;font-size:1.2em;color:black;margin-top:30px;margin-bottom:10px;">
                        #footer_title#セミナーの目的・特徴
                      </div>
                      <div>
                      <pre style="white-space:pre-line">
                        #footer_description#
                      </pre>
                      </div>
                    </div>
                  </cfif>
                                      
            </div>
          <cfelse>
            <!--- ↓に高さを指定しないと選択肢がフッターの部分で消えてしまう --->
            <div class="date_list" style="min-height:600px;">
              <span style="color:##7d7d7d">条件に一致する該当するセミナーはありません。</span>
                  <cfif footer_description neq "">
                    <div style="width:100%;text-align:left;">
                      <div style="border-bottom:medium solid ##23943E;display: inline-block;font-size:1.2em;color:black;margin-top:30px;margin-bottom:10px;">
                        #footer_title#セミナーの目的・特徴
                      </div>
                      <div>
                      <pre style="white-space:pre-line">
                        #footer_description#
                      </pre>
                      </div>
                    </div>
                  </cfif>
            </div>
          </cfif> 

        </cfoutput>
      </div>

    
  </div>
  <cfoutput>
    <input type="hidden" name="base_url" id="base_url" value="#application.base_url#">
  </cfoutput>
  <div style="clear:both;margin-bottom:30px;"></div>
  <cfoutput>
    <script type="text/javascript" src="#application.base_url#js/jquery-1.9.1.min.js"></script>
    <script src="#application.base_url#js/moment.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/fullcalendar.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/ja.js" type="text/javascript"></script>

  </cfoutput>
   <script>
    $(function(){
      
      
      $('#calendar_short').fullCalendar({
          adtitable: true,
          height: 300,
          header: {
              left:   'prev',
              center: 'title',
              right:  'next',
          },

            dayClick: function(date, jsEvent, view) {
              
          // change the day's background color just for fun
              $(this).css('background-color', '#01c39a');
              $(this).css('color', '#fff');
              var str_dy = moment( date ).format( 'YYYY/MM/DD' );
              var base_url = $("#base_url").val();
              var url_var = $("#url_var").val();
              location.href = base_url + "seminar_list" + url_var + "&dy=" + str_dy;

            }
      });

        // $(".icon_btn").on("click", function() {
        //   //$(".icon_btn").not($(this)).next('ul').hide();
        //   $(this).next('ul').slideToggle();
        // });

        $(document).on('click', function(e) {
            // ２．クリックされた場所の判定
            if(!$(e.target).closest('#pop_up').length && !$(e.target).closest('#button').length){
                $('#pop_up').fadeOut();
            }else if($(e.target).closest('#button').length){
                // ３．ポップアップの表示状態の判定
                if($('#pop_up').is(':hidden')){
                    $('#pop_up').fadeIn();
                }else{
                    $('#pop_up').fadeOut();
                }
            }
        });

            //１．クリックイベントの設定
        $(document).on('click', function(e) {
            // ２．クリックされた場所の判定
            if(!$(e.target).closest('#pop_up2').length && !$(e.target).closest('#button2').length){
                $('#pop_up2').fadeOut();
            }else if($(e.target).closest('#button2').length){
                // ３．ポップアップの表示状態の判定
                if($('#pop_up2').is(':hidden')){
                    $('#pop_up2').fadeIn();
                }else{
                    $('#pop_up2').fadeOut();
                }
            }
        });

            //１．クリックイベントの設定
        $(document).on('click', function(e) {
            // ２．クリックされた場所の判定
            if(!$(e.target).closest('#pop_up3').length && !$(e.target).closest('#button3').length){
                $('#pop_up3').fadeOut();
            }else if($(e.target).closest('#button3').length){
                // ３．ポップアップの表示状態の判定
                if($('#pop_up3').is(':hidden')){
                    $('#pop_up3').fadeIn();
                }else{
                    $('#pop_up3').fadeOut();
                }
            }
        });

            //１．クリックイベントの設定
        $(document).on('click', function(e) {
            // ２．クリックされた場所の判定
            if(!$(e.target).closest('#pop_up4').length && !$(e.target).closest('#button4').length){
                $('#pop_up4').fadeOut();
            }else if($(e.target).closest('#button4').length){
                // ３．ポップアップの表示状態の判定
                if($('#pop_up4').is(':hidden')){
                    $('#pop_up4').fadeIn();
                }else{
                    $('#pop_up4').fadeOut();
                }
            }
        });


    });



      $(document).on("ready",function(){
        var base_url = $("#base_url").val();
        $(".slide_delay").show();
        $(".seminar_cond").on("change",function(){
          $("#middle_category").val('');
          document.seminar_cond.target="_self";
          document.seminar_cond.method="post";
          document.seminar_cond.action = base_url + "seminar_list";
          document.seminar_cond.submit();
        })
      })
      function movePage(scd){
          $("#middle_category").val('');
          var base_url = $("#base_url").val();
          document.seminar_cond.target="_self";
          document.seminar_cond.method="post";
          document.seminar_cond.action = base_url + "seminar/" + scd;
          document.seminar_cond.submit();    
      }
      function searchWithKeyword(ecd){
        var base_url = $("#base_url").val();
        var url_var = $("#url_var2").val();
        var keyword = $("#freeword").val();
        if(ecd === 13){
          $("#middle_category").val('');
          document.seminar_cond.target="_self";
          document.seminar_cond.method="post";
          document.seminar_cond.action = base_url + "seminar_list" + url_var + "&keyword=" + keyword;
          document.seminar_cond.submit();          
          //location.href = base_url + "seminar_list" + url_var + "&keyword=" + keyword;    
        }
      }
      function getMiddle(mid){
        var base_url = $("#base_url").val();
        location.href = base_url + "seminar_list?mc=" + mid;

      }

</script>
  <cfinclude template="footer3.cfm">
</body>
</html>


<!-- Localized -->
