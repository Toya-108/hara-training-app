<!DOCTYPE html>
<html lang="ja">
<head>
    <cfif application.use_analytics>
      <!-- Global site tag (gtag.js) - Google Analytics -->
      <script async src="https://www.googletagmanager.com/gtag/js?id=UA-135625983-1"></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'UA-135625983-1');
      </script>    
    </cfif>
    <cfoutput>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, maximum-scale=1.0, user-scalable=yes">
     <meta name="keywords" content="jpi,日本計画研究所,ビジネスセミナー,セミナー,省官庁">
     <meta property="og:type" content="website">
     <meta property="og:url" content="#application.base_url#">
     <meta property="og:title" content="ビジネスセミナーの情報はJPIへ | 株式会社JPI（日本計画研究所">
        <link rel="shortcut icon" href="#application.base_url#images/favicon.ico">
  
        <!-- ========== title ========== -->
      <title>ビジネスセミナーの情報はJPIへ | 株式会社JPI（日本計画研究所）</title>
      <!-- ========== /title ========== -->
      
      <!-- ========== meta description ========== -->
      <meta name="description" content="“「政」と「官」と「民」との知の懸け橋” として国家政策やナショナルプロジェクトの敷衍化を支え、国家知の創造を目指す幹部・上級管理職の事業遂行に有益な情報をご参加者を限定したリアルな特別セミナーという形で半世紀、提供し続けています。">
      <!-- ========== /meta description ========== -->
  
    
      <!-- ========== css ========== -->
        <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/south-street/jquery-ui.css" >
        <link rel="stylesheet" href="#application.base_url#css2/fullcalendar.min.css" type="text/css">
        
        
        
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Swiper/3.4.1/css/swiper.min.css">

        <link rel="stylesheet" href="#application.base_url#css2/top.css?112433456">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans+Condensed:700" rel="stylesheet">
        <!-- ========== /css ========== -->
        

    </cfoutput>





</head>
<cfset now = now()>
<cfset today = dateFormat(now,"yyyy/mm/dd")>
<cfset this_year = dateFormat(now,"yyyy")>
<cfset next_year = Int(dateFormat(now,"yyyy") + 1)>

<cfif IsDefined("form.month") and form.month neq "">
  <cfset month = form.month>
<cfelse>
  <cfset month = "">
</cfif>
<cfif IsDefined("form.year") and form.year neq "">
  <cfset year = form.year>
<cfelse>
  <cfset year = "">
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

<cfif IsDefined("form.keyword") and form.keyword neq "">
  <cfset keyword = form.keyword>
<cfelse>
  <cfif IsDefined("url.keyword") and url.keyword neq "">
      <cfset keyword = URLDecode(url.keyword)>
  <cfelse>
      <cfset keyword = "">
  </cfif>  
</cfif>

<cfif IsDefined("form.dy") and form.dy neq "">
  <cfset target_day = form.dy>
<cfelse>
  <cfif IsDefined("url.dy") and url.dy neq "">
      <cfset target_day = url.dy>
  <cfelse>
      <cfset target_day = "">
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

<cfscript>
  //あいまい検索したいカラムをここにセット
  target_colums = [
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

<cfquery name="qGetTopSeminar">
  SELECT m_seminar.seminar_code
    FROM m_seminar
   WHERE m_seminar.event_date >= curdate() AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
   AND m_seminar.event_date >= curdate()
   AND m_seminar.fm_fpub = 1
ORDER BY m_seminar.hp_registered_date DESC, m_seminar.hp_registered_time DESC,m_seminar.update_date DESC, m_seminar.event_date,m_seminar.start_time,m_seminar.seminar_code
   LIMIT 10
</cfquery>

<cfquery name="qGetSeminar">
  SELECT m_seminar.seminar_code,
         date_format(m_seminar.event_date, '%m/%d') AS event_date,
         date_format(m_seminar.event_date, '%Y年%c月') AS char_event_month,
         CASE WHEN date_format(m_seminar.event_date,'%Y/%m/%d') = '#today#' THEN 1
         ELSE 0 END AS today_event,
         date_format(m_seminar.event_date, '%Y.%m.%d') AS char_event_date,
         CASE DAYOFWEEK(m_seminar.event_date) WHEN 1 THEN '日'
                                              WHEN 2 THEN '月'
                                              WHEN 3 THEN '火'
                                              WHEN 4 THEN '水'
                                              WHEN 5 THEN '木'
                                              WHEN 6 THEN '金'
                                              WHEN 7 THEN '土' END as char_youbi,
         date_format(m_seminar.start_time, '%H:%i') AS start_time,
         date_format(m_seminar.end_time, '%H:%i') AS end_time,
         CASE WHEN CHAR_LENGTH(m_seminar.main_theme) > 60 THEN CONCAT(SUBSTRING(REPLACE(m_seminar.main_theme ,'\r\n',''),1,60),'...') 
              ELSE m_seminar.main_theme
            END AS char_main_theme,
         m_seminar.main_theme,
         CASE WHEN CHAR_LENGTH(m_seminar.sub_theme) > 100 THEN CONCAT(SUBSTRING(REPLACE(m_seminar.sub_theme ,'\r\n',''),1,100),'...') 
              ELSE m_seminar.sub_theme
            END AS char_sub_theme,
         CASE WHEN CHAR_LENGTH(m_seminar.sub_theme2) > 100 THEN CONCAT(SUBSTRING(REPLACE(m_seminar.sub_theme2 ,'\r\n',''),1,100),'...') 
              ELSE m_seminar.sub_theme2
            END AS char_sub_theme2,            
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
         m_seminar.unit_price_without_tax_1,
         m_seminar.unit_price_tax_1,
         m_seminar.unit_price_include_tax_2,
         m_seminar.unit_price_without_tax_2,
         m_seminar.unit_price_tax_2,
         m_seminar.unit_price_include_tax_3,
         m_seminar.unit_price_without_tax_3,
         m_seminar.unit_price_tax_3,
         m_seminar.unit_price_include_tax_4,
         m_seminar.unit_price_without_tax_4,
         m_seminar.unit_price_tax_4,
         m_seminar.unit_price_include_tax_5,
         m_seminar.unit_price_without_tax_5,
         m_seminar.unit_price_tax_5,
         m_seminar.publication_date,
         <cfloop index="i" from="1" to="3">
           CONCAT(SPEAKER#i#.name,' 氏') name#i#,
           SPEAKER#i#.company_name company_name#i#,
           SPEAKER#i#.department department#i#,
           SPEAKER#i#.post post#i#, 
           SPEAKER#i#.file_name file_name#i#,           
         </cfloop>         
    
         m_seminar.note,
         m_seminar.create_date,
         m_seminar.update_date
    FROM m_seminar LEFT OUTER JOIN m_place ON m_seminar.place_id = m_place.place_id
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


   WHERE m_seminar.seminar_code IN(
    <cfif qGetTopSeminar.RecordCount GTE 1>
      #ArrayToList(qGetTopSeminar["seminar_code"],",")#
    <cfelse>
      'no_data'
    </cfif>
    
    )
   AND m_seminar.event_date >= curdate() AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
   AND m_seminar.event_date >= curdate()
   AND m_seminar.fm_fpub = 1
   AND main_theme IS NOT NULL
  ORDER BY m_seminar.event_date,m_seminar.start_time
             
</cfquery>

<cfquery name="qGetLargeCategoryNum">
   SELECT m_large_category.large_category_id,
          m_large_category.large_category_name,
          COUNT(SEMINAR.large_category_id) as large_category_cnt
    FROM m_large_category LEFT OUTER JOIN ( SELECT m_seminar.seminar_code,
                                                   m_seminar.large_category_id1 AS large_category_id
                                              FROM m_seminar
                                             WHERE m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                             UNION
                                            SELECT m_seminar.seminar_code,
                                                   m_seminar.large_category_id2 AS large_category_id
                                              FROM m_seminar
                                             WHERE m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                             UNION
                                            SELECT m_seminar.seminar_code,
                                                   m_seminar.large_category_id3 AS large_category_id
                                              FROM m_seminar
                                             WHERE m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                             UNION
                                            SELECT m_seminar.seminar_code,
                                                   m_seminar.large_category_id4 AS large_category_id
                                              FROM m_seminar
                                            WHERE m_seminar.fm_fpub = 1
                                              AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                              AND m_seminar.event_date >= curdate()
                                             UNION
                                            SELECT m_seminar.seminar_code,
                                                   m_seminar.large_category_id5 AS large_category_id
                                              FROM m_seminar
                                             WHERE m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                        ) SEMINAR ON m_large_category.large_category_id = SEMINAR.large_category_id
  GROUP BY m_large_category.large_category_id
  ORDER BY large_category_id;
</cfquery>


<cfquery name="qGetThemeNum">
   SELECT m_theme.theme_id,
          m_theme.theme,
         COUNT(SEMINAR.theme_id) AS theme_id_cnt
    FROM m_theme LEFT OUTER JOIN (SELECT m_seminar.theme_id1 AS theme_id
                                              FROM m_seminar
                                             WHERE main_theme IS NOT NULL
                                               AND m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                             UNION ALL
                                            SELECT m_seminar.theme_id2 AS theme_id
                                              FROM m_seminar
                                             WHERE main_theme IS NOT NULL
                                              AND m_seminar.fm_fpub = 1
                                              AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                              AND m_seminar.event_date >= curdate()
                                             UNION ALL
                                            SELECT m_seminar.theme_id3 AS theme_id
                                              FROM m_seminar
                                             WHERE main_theme IS NOT NULL
                                               AND m_seminar.fm_fpub = 1
                                               AND (m_seminar.publication_date IS NULL OR m_seminar.publication_date >= curdate())
                                               AND m_seminar.event_date >= curdate()
                                                ) SEMINAR ON m_theme.theme_id = SEMINAR.theme_id
  GROUP BY m_theme.theme_id,
           m_theme.theme
  ORDER BY theme_id
</cfquery>



<!--- <cfquery name="qGetPref">
  SELECT prefecture_id,prefecture_name FROM m_prefecture
</cfquery> --->
<cfquery name="qGetCategory">
  SELECT large_category_id,large_category_name FROM m_large_category
</cfquery>
<cfquery name="qGZetAdmin">
  SELECT web_top_greeting FROM m_admin
</cfquery>  
  <cfquery name="qGetTheme">
    SELECT theme_id,theme FROM m_theme
  </cfquery>
  <cfquery name="qGetLectureStyle">
    SELECT lecture_style_id,lecture_style_name,archive_flag FROM m_lecture_style
  </cfquery>
<!--- 
<cfif middle_category neq "">
    <cfquery name="qGetCategoryName">
      SELECT m_large_category.large_category_name,
             m_middle_category.middle_category_name,
             m_large_category.color,
             m_large_category.img_file
        FROM m_large_category LEFT OUTER JOIN m_middle_category ON m_large_category.large_category_id = m_middle_category.large_category_id
       WHERE m_middle_category.middle_category_id = #middle_category#
    </cfquery>
</cfif>
<cfif large_category neq "">
    <cfquery name="qGgetLargeCategoryName">
      SELECT m_large_category.large_category_name
        FROM m_large_category
       WHERE m_large_category.large_category_id = #large_category#
    </cfquery>
</cfif>
<cfif theme_id neq "">
    <cfquery name="qGgetThemeName">
      SELECT m_theme.theme
        FROM m_theme
       WHERE m_theme.theme_id = #theme_id#
    </cfquery>
</cfif>
<cfif prefecture neq "">
    <cfquery name="qGgetPrefName">
      SELECT prefecture_id,prefecture_name 
        FROM m_prefecture
      WHERE prefecture_id = #prefecture#
    </cfquery>    
</cfif>
 --->
<body>
    <cfoutput>
        <div class="contact contact_btn pc" >
            <a href="#application.base_url#contact">
               <img src="#application.base_url#image/fix_contact_btn.png">
            </a>
        </div>
        <div class="sp_navi sp">
            <div class="sp_navi_left">
                <a href="#application.base_url#">
                    <img src="#application.base_url#image/jpi_logo1.svg" alt="株式会社JPI" class="header-jpi-logo">
                </a>
            </div>
            <div class="sp_navi_right">
                <div class="sp_navi_contact">
                   <a href="#application.base_url#contact"><img src="#application.base_url#image/contact_menu.png"></a>
                </div>
                <div class="sp_navi_menu">
                    <div class="globalNavi nav_top sp">
                        <div id="navToggle">
                            <div>
                                <span class="span_first"></span>
                                <span class="span_second"></span>
                                <span class="span_third"></span>
                            </div>
                        </div>
                        <nav class="header-nav sp">
                            <cfinclude template="header_menu.cfm">
                        </nav>
                    </div>
            
                </div>
            </div>
        </div>
    </cfoutput>
    <!-- ========== header ========== -->
    <cfoutput>
        <header>
            
            <div class="swiper-container">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <img src="#application.base_url#image/main-visual-1.jpg?123" alt="ヘッダー画像" class="main-visual pc" id="pc">
                        <img src="#application.base_url#image/keyvisual_sp_1.png?1234" alt="ヘッダー画像" class="main-visual sp" id="sp">
                    </div>
                    <div class="swiper-slide">
                        <img src="#application.base_url#image/main-visual-2.jpg?123" alt="ヘッダー画像" class="main-visual pc" id="pc">
                        <img src="#application.base_url#image/keyvisual_sp_2.jpg?201823" alt="ヘッダー画像" class="main-visual sp" id="sp">
                    </div>
                    <div class="swiper-slide">
                        <img src="#application.base_url#image/main-visual-3.jpg?123" alt="ヘッダー画像" class="main-visual pc" id="pc">
                        <img src="#application.base_url#image/keyvisual_sp_3.png?1234" alt="ヘッダー画像" class="main-visual sp" id="sp">
                    </div>
                </div>
                <div class="swiper-button-next pc">
                    <span>next</span>
                </div>
                <div class="swiper-button-prev pc">
                    <span>prev</span>
                </div>
               <a href="#application.base_url#"><img src="#application.base_url#image/jpi_logo1.svg" alt="株式会社JPI" class="header-jpi-logo-top" id="pc"></a>
                <p class="main-message">株式会社JPI（日本計画研究所）は<br>“「政」と「官」と「民」との知の懸け橋” として<br>国家政策やナショナルプロジェクトの敷衍化を支え、<br>国家知の創造を目指す幹部・上級管理職の事業遂行に<br>有益な情報をご参加者を限定したリアルな特別セミナーという形で<br>半世紀、提供し続けています。</p>
                

                 <!-- If we need pagination -->
                <div class="swiper-pagination"></div>
            
                <!-- If we need scrollbar -->
                <div class="swiper-scrollbar"></div>
            </div>

            <div class="search_container">
                    <!--- 日付検索用 --->
                    <input type="hidden" id="url_var" value="?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=#prefecture#&ls=#lecture_style_id#">
                    <!--- キーワード検索用 --->
                    <input type="hidden" id="url_var2" value="?lc=#large_category#&ti=#theme_id#&pref=#prefecture#&dy=#target_day#&ls=#lecture_style_id#">
                    <div class="icon_btn" id="button">
                        <img src="#application.base_url#image/syokan_icon.png">
                        <span class="icon_span" id="category_select">
                          <cfif large_category neq "">
                            #Left(qGgetLargeCategoryName.large_category_name,4)#
                          <cfelseif middle_category neq "">
                            #Left(qGetCategoryName.large_category_name,4)#
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
                    <div class="icon_btn" id="button2">
                        <img src="#application.base_url#image/tikyuu_icon.png">
                        <span class="icon_span" id="theme_select">
                          <cfif theme_id neq "">
                            #Left(qGgetThemeName.theme,4)#
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
                    <div class="icon_btn" id="button3">
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

                    <!--- <div class="icon_btn sp" id="button4"> --->
                      <!--- &nbsp; --->
<!---                         <img src="#application.base_url#image/access_icon.png">
                        <span class="icon_span" id="place_select">
                          <cfif prefecture neq "">
                            #qGgetPrefName.prefecture_name#
                          <cfelse>
                            開催地
                          </cfif> 
                        </span>
 <!--- --->                    </div> --->

<!---                         <ul class="ul_2" id="pop_up4" style="display:none;text-align:left;">
                          <li>
                              <a href="#application.base_url#seminar_list.cfm?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=&dy=#target_day#">全開催地</a>
                          </li>                                                    
                          <cfloop index="i" from="1" to="#qGgetPref.RecordCount#">
                            <li><a href="#application.base_url#seminar_list.cfm?lc=#large_category#&ti=#theme_id#&keyword=#keyword#&pref=#qGgetPref.prefecture_id[i]#&dy=#target_day#">#qGgetPref.prefecture_name[i]#</a></li>
                          </cfloop>                           
                        </ul> ---> 
                        
<!---                         <div class="search_area">
                            <input type="text" name="seminar-search" placeholder="フリーワード">
                        </div>
                        <a href="">
                            <div class="search_btn">
                                <img src="#application.base_url#image/search_icon.png">
                            </div>
                        </a> --->
                        <form name="seminar_cond" action="#application.base_url#seminar_list">                  
                          <div class="search_area">
                              <input type="text" name="keyword" id="freeword" value="#keyword#" placeholder="フリーワード" maxlength="30">
                          </div>
                          <div class="search_btn">
                              <img src="#application.base_url#image/search_icon.png" onclick="searchWithKeyword(13)">
                          </div>
                        </form>


                        <div class="header_news pc">
                            <cfif qGZetAdmin.web_top_greeting neq "">
                                <p>#qGZetAdmin.web_top_greeting#</p>
                            <cfelse>
                                <p>&nbsp;</p>
                            </cfif>
                            
                        </div>
            </div>
            <div class="scroll">
                <a href="##news">
                    <span id="pc"></span>Scroll
                </a>
            </div>
            
            <div class="header_btn_area pc" >
                <a href="#application.base_url#mail_magazine">
                    <div class="header_btn">
                        <span>配信メール登録/変更/削除</span>
                    </div>
                </a>
                <a href="#application.base_url#login?new=1">
                    <div class="header_btn pc">
                        <span>セミナー申込簡便化会員登録・変更</span>
                    </div>
                </a>
            </div>
            
            

            
            <nav class="header-nav pc">
                <cfinclude template="header_menu.cfm">
            </nav>
        
            
            
        </header>
    </cfoutput>

    
    <!-- ========== /header ========== -->
    
    
    
    <!-- ========== main ========== -->
    <cfoutput>
        <article class="main">
            <section id="news">
                <div class="section-title">
                    <div class="section-title-icon-div">
                        <img src="#application.base_url#image/section-title-icon.png" class="section-title-icon">
                    </div>
                    <p>新着情報</p>
                </div>
                
                <div class="section-contents">
                    <ul>
                        <cfif qGetSeminar.RecordCount GTE 1>
                          <cfloop index="i" from="1" to="#qGetSeminar.RecordCount#">
                              <li>
                                  <div class="section_title_left">
                                      <p><img src="#application.base_url#image/new.png"><span>#qGetSeminar.char_event_date[i]#(#qGetSeminar.char_youbi[i]#) #qGetSeminar.start_time[i]#~#qGetSeminar.end_time[i]#</span></p>
                                      <h5>#qGetSeminar.char_sub_theme[i]#</h5>
                                      <a href="#application.base_url#seminar/#qGetSeminar.seminar_code[i]#"><h3>【#qGetSeminar.main_theme[i]#】</h3></a>
                                      <small>#qGetSeminar.char_sub_theme2[i]#</small>
                                  </div>
                                  <div class="section_title_right">
                                      <a href="#application.base_url#seminar/#qGetSeminar.seminar_code[i]#" class="section_btn">
                                          <span class="detail_btn">詳細</span>
                                      </a>
  <!---                                     <a href="#application.base_url#seminar/#qGetSeminar.seminar_code[i]#" class="apply_btn">
                                          <span class="apply_detail_btn">お申込受付中</span>
                                      </a> --->
                                  </div>
                              </li>
                          </cfloop>
                          
                        </cfif>

                    </ul>
                </div>
            </section>
            
            
            
            <section id="seminar-search">

                <div class="section-title">
                    <div class="section-title-icon-div">
                        <img src="#application.base_url#image/section-title-icon.png" class="section-title-icon">
                    </div>
                    <p>セミナーを探す</p>
                </div>
                <form name="seminar_cond2" action="#application.base_url#seminar_list">                  
                    <div class="section-contents">
                        <input type="text" name="kw" id="seminar-search-input" placeholder="フリーワード検索" maxlength="30">
                        <button id="seminar-search-button">
                            <img src="#application.base_url#image/search-button-icon.png" class="search-button-icon" onclick="searchWithKeyword2(13)">
                        </button>
                    </div>
                </form>





                <div class="kanryo-search">
                    <div class="kanryo_container pc">
                        <div class="kanryo_title">
                            <div class="kanryo_icon">
                                <img src="image/icon_kanryo.png">
                            </div>
                            <h3>所管省庁から探す</h3>
                        </div>
                        <nav class="kanryo-nav">
                            <ul>
                                <cfloop index="i" from="1" to="7">
                                    <li style="width: 13%;">
                                        <a href="#application.base_url#seminar_list?lc=#qGetLargeCategoryNum.large_category_id[i]#"><p style="font-size:0.9em;">#qGetLargeCategoryNum.large_category_name[i]#(#qGetLargeCategoryNum.large_category_cnt[i]#)</p></a>
                                    </li>
                                </cfloop>
                            </ul>

                            <ul>
                                <cfloop index="i" from="8" to="#qGetLargeCategoryNum.RecordCount#">
                                    <li style="width: 13%;">
                                        <a href="#application.base_url#seminar_list?lc=#qGetLargeCategoryNum.large_category_id[i]#"><p style="font-size:0.9em;">#qGetLargeCategoryNum.large_category_name[i]#(#qGetLargeCategoryNum.large_category_cnt[i]#)</p></a>
                                    </li>
                                </cfloop>
                            </ul>
                         </nav>
                    </div>

                    <div class="kanryo_container pc">
                        <div class="kanryo_title">
                            <div class="kanryo_icon">
                                <img src="image/theme_icon.png">
                            </div>
                            <h3>テーマで探す</h3>
                        </div>
                        <nav class="kanryo-nav">
                            <ul>
                                <cfloop index="i" from="1" to="7">
                                    <li style="width: 13%;">
                                        <a href="#application.base_url#seminar_list?ti=#qGetThemeNum.theme_id[i]#"><p style="font-size:0.9em;">#qGetThemeNum.theme[i]#(#qGetThemeNum.theme_id_cnt[i]#)</p></a>
                                    </li>
                                </cfloop>
                            </ul>

                            <ul>
                                <cfloop index="i" from="8" to="#qGetThemeNum.RecordCount#">
                                    <li style="width: 13%;">
                                        <a href="#application.base_url#seminar_list?ti=#qGetThemeNum.theme_id[i]#"><p style="font-size:0.9em;">#qGetThemeNum.theme[i]#(#qGetThemeNum.theme_id_cnt[i]#)</p></a>
                                    </li>
                                </cfloop>
                            </ul>
                         </nav>
                    </div>
                    <!--             sp            -->
                                
     
     
           
                     <div class="kanryo_container" id="sp">
                        <div class="tab-content">



        <div class="kanryo_title hidden_box">
           
           <input type="radio" id="label1" name="label" checked />
            <label for="label1" class="label" id="l1"><h3>所管省庁から探す</h3></label>
            
            <input type="radio" id="label2" name="label"/>
            <label for="label2" class="label" id="l2"><h3>テーマから探す</h3></label>
        
            
            <div class="hidden_show_1">
            <nav class="kanryo-nav">
                                    <ul>
                                        <cfloop index="i" from="1" to="7">
                                            <li>
                                                <a href="#application.base_url#seminar_list?lc=#qGetLargeCategoryNum.large_category_id[i]#"><p>#qGetLargeCategoryNum.large_category_name[i]#(#qGetLargeCategoryNum.large_category_cnt[i]#)</p></a>
                                            </li>
                                        </cfloop>                                    
                                    </ul>
                        
                                    <ul>
                                        <cfloop index="i" from="8" to="#qGetLargeCategoryNum.RecordCount#">
                                            <li>
                                                <a href="#application.base_url#seminar_list?lc=#qGetLargeCategoryNum.large_category_id[i]#"><p>#qGetLargeCategoryNum.large_category_name[i]#(#qGetLargeCategoryNum.large_category_cnt[i]#)</p></a>
                                            </li>
                                        </cfloop>
                                    </ul>
                                </nav>
        </div>

        
        <div class="hidden_show_2">
                                   <nav class="kanryo-nav">
                                    <ul>
                                        <cfloop index="i" from="1" to="7">
                                            <li>
                                                <a href="#application.base_url#seminar_list?ti=#qGetThemeNum.theme_id[i]#"><p>#qGetThemeNum.theme[i]#(#qGetThemeNum.theme_id_cnt[i]#)</p></a>
                                            </li>
                                        </cfloop>
                                    </ul>
            
                                    <ul>
                                        <!--- <cfloop index="i" from="8" to="#qGetThemeNum.RecordCount#"> --->
                                        <cfloop index="i" from="8" to="14">
                                            <li>
                                                <a href="#application.base_url#seminar_list?ti=#qGetThemeNum.theme_id[i]#"><p>#qGetThemeNum.theme[i]#(#qGetThemeNum.theme_id_cnt[i]#)</p></a>
                                            </li>
                                        </cfloop>
                                    </ul>

                                 </nav>
        </div>
    </div>
    </div></div>





                    <!--          sp end   -->
                    <div class="kanryo_container">
                        <div class="kanryo_title pc">
                            <div class="kanryo_icon">
                                <img src="image/calendar.png">
                            </div>
                            <h3>開催日から探す</h3>
                        </div>

                        <div class="kanryo_title_sp sp">
                            <div class="kanryo_icon">
                                <img src="image/calendar.png">
                            </div>
                            <h3>開催日から探す</h3>
                        </div>


                     <div class="calendar_container">
                        <div id="calendar" style="cursor:pointer;">
                        </div>

                        </div>
                        </div>
                </div>
                    </div>
                </div>
            </section>

            <section id="jpi-point">
                <div class="section-title">
                    <div class="section-title-icon-div">
                        <img src="#application.base_url#image/section-title-icon.png" class="section-title-icon">
                    </div>
                    <p>JPIが選ばれる理由</p>
                </div>
                
                <div class="section-contents" id="pc">
                    <ul class="jpi-point-list">
                        
                        <li class="jpi-point-1">
                            <img src="#application.base_url#image/1.png" class="point-number">
                            <p>半世紀に及ぶ国内外講師陣<br>特別招聘のセミナー開催</p>
                        </li>
                        
                        <li class="jpi-point-2">
                            <img src="#application.base_url#image/2.png" class="point-number">
                            <p>プライベート空間による<br>プレミアム効果</p>
                        </li>
                        
                        <li class="jpi-point-3">
                            <img src="#application.base_url#image/3.png" class="point-number">
                            <p>幹部・上級管理職の<br>事業遂行支援事業</p>
                        </li>
                        
                    </ul>
                    
                    <ul class="jpi-point-list">
                       
                        <li class="jpi-point-4">
                            <img src="#application.base_url#image/4.png" class="point-number">
                            <p>非公開性</p>
                        </li>
                        
                        <li class="jpi-point-5">
                            <img src="#application.base_url#image/5.png" class="point-number">
                            <p>リアルの場</p>
                        </li>
                        
                        <li class="jpi-point-6">
                            <img src="#application.base_url#image/6.png" class="point-number">
                            <p>パブリシティ</p>
                        </li>
                        
                    </ul>
                </div>

                <div class="section-contents sp_mg_top" id="sp">
                    <ul class="jpi-point-list">
                        
                        <li class="jpi-point-1">
                            <img src="#application.base_url#image/1.png" class="point-number">
                            <p>半世紀に及ぶ国内外講師陣<br>特別招聘のセミナー開催</p>
                        </li>
                        
                        <li class="jpi-point-2">
                            <img src="#application.base_url#image/2.png" class="point-number">
                            <p>プライベート空間による<br>プレミアム効果</p>
                        </li>
                        
                    </ul>

                     <ul class="jpi-point-list">

                        <li class="jpi-point-3">
                            <img src="#application.base_url#image/3.png" class="point-number">
                            <p>幹部・上級管理職の<br>事業遂行支援事業</p>
                        </li>

                        <li class="jpi-point-4">
                            <img src="#application.base_url#image/4.png" class="point-number">
                            <p>非公開性</p>
                        </li>
                        
                    </ul>
                    
                    <ul class="jpi-point-list">

                        <li class="jpi-point-5">
                            <img src="#application.base_url#image/5.png" class="point-number">
                            <p>リアルの場</p>
                        </li>
                        
                        <li class="jpi-point-6">
                            <img src="#application.base_url#image/6.png" class="point-number">
                            <p>パブリシティ</p>
                        </li>
                        
                    </ul>
                </div>
                <div class="btn_container">
                    <a href="#application.base_url#reason"><span class="detail_btn ft-14">詳細はこちら</span></a>
                </div>
            </section>
        </article>
        <!-- ========== /main ========== -->
    </cfoutput>


  <cfoutput>
      <!-- ========== jQuery ========== -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
      <!--- 
      <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/i18n/jquery.ui.datepicker-ja.min.js"></script>
      --->
      <script src="#application.base_url#js/sample.js"></script>
    <!-- ========== /jQuery ========== -->
    <input type="hidden" name="base_url" id="base_url" value="#application.base_url#">
  </cfoutput>
  <cfinclude template="footer3.cfm">
  <div style="clear:both;margin-bottom:30px;"></div>
  <cfoutput>

    <script type="text/javascript" src="#application.base_url#js/jquery-1.9.1.min.js"></script>
    <script src="#application.base_url#js/moment.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/fullcalendar.min.js" type="text/javascript"></script>
    <script src="#application.base_url#js/ja.js" type="text/javascript"></script>

  </cfoutput>

    <script>
        ( function () {
            //initialize swiper when document ready  
            var mySwiper = new Swiper ('.swiper-container', {
            // Optional parameters
            direction: 'horizontal',
            loop: true,
            autoplay: 4000,
            speed: 2000,
            effect: 'fade',
            paginationClickable: true,
            nextButton: '.swiper-button-next',
            prevButton: '.swiper-button-prev',
            // 前後スライドへのナビゲーションを表示する場合
            // ページネーションを表示する場合
            });
        } )();
        $(function(){
            $('a[href^="#news"]').click(function(){
                var speed = 500;
                var href= $(this).attr("href");
                var target = $(href == "#" || href == "" ? 'html' : href);
                var position = target.offset().top;
            $("html, body").animate({scrollTop:position}, speed, "swing");
                return false;
            });
        });
    </script>
     <script>
        $(function () {
            $(window).scroll(function () {

                if ($(this).scrollTop() > 620) {
                    $('.header-nav').addClass('is-fixed');
                } else {
                    $('.header-nav').removeClass('is-fixed');
                }
            });
        });

        $(function () {
            $(window).scroll(function () {

                if ($(this).scrollTop() > 650) {
                    $('.contact_btn').addClass('contact-fixed');
                } else {
                    $('.contact_btn').removeClass('contact-fixed');
                }
            });
        });
   $(function() {
            $('#navToggle').click(function(){//headerに .openNav を付加・削除
                $('.sp_navi_menu').toggleClass('openNav');
            });
        });
        $(function() {
            $('#navToggle').click(function(){//headerに .openNav を付加・削除
                $('.navi_slide').slideToggle();
            });
        });
  //   $(function() {
  //   $("#datepicker").datepicker();
  // });
$(function () {
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
      $('#calendar').fullCalendar({
        adtitable: true,
        height: 500,
        header: {
        left:   'prev',
        center: 'title',
        right:  'next',
        },

        dayClick: function(date, jsEvent, view) {
              var str_dy = moment( date ).format( 'YYYY/MM/DD' );
              var base_url = $("#base_url").val();
              location.href = base_url + "seminar_list?dy=" + str_dy;

            $(this).css('background-color', '#01c39a');
            $(this).css('color', '#fff');
        }
      });


    // $('#calendar').fullCalendar({
    //   windowResize: function(view) {
    //     alert('The calendar has adjusted to a window resize');
    //   }
    // });

    // $('#calendar_short').fullCalendar({
    //   windowResize: function(view) {
    //     alert('The calendar has adjusted to a window resize');
    //   }
    // });
    $('#calendar_short').fullCalendar({
        adtitable: true,
        height: 300,
        header: {
            left:   'prev',
            center: 'title',
            right:  'next',
        },

          dayClick: function(date, jsEvent, view) {
              var str_dy = moment( date ).format( 'YYYY/MM/DD' );
              var base_url = $("#base_url").val();
              location.href = base_url + "seminar_list?dy=" + str_dy;
        // change the day's background color just for fun
        $(this).css('background-color', '#01c39a');
        $(this).css('color', '#fff');

        }
    });

});
  function searchWithKeyword(ecd){
    var base_url = $("#base_url").val();
    var keyword = $("#freeword").val();
    if(ecd === 13){
      document.seminar_cond.target="_self";
      document.seminar_cond.method="post";
      document.seminar_cond.action = base_url + "seminar_list?keyword=" + keyword;
      document.seminar_cond.submit();          
    }
  }
  function searchWithKeyword2(ecd){
    var base_url = $("#base_url").val();
    var keyword = $("#seminar-search-input").val();
    if(ecd === 13){
      document.seminar_cond2.target="_self";
      document.seminar_cond2.method="post";
      document.seminar_cond2.action = base_url + "seminar_list?keyword=" + keyword;
      document.seminar_cond2.submit();          
    }
  }
</script>
<script>
</script>
</body>
</html>
    <!--. ========== /swiper-js ========== -->
    
