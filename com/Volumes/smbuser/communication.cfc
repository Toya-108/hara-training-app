<cfcomponent>
    <cfheader name="Access-Control-Allow-Origin" value="*" />
    <cfsetting showDebugOutput="No">

    <!--- 下部側へ送信 --->

<!--- 
        <!--- ログイン処理 --->
        <cffunction name="tryLogin" access="remote" returnFormat="plain">
            <cfquery name="qCheckEmp" datasource="#application.dsn#">
                SELECT emp_code
                  FROM m_emp 
                WHERE
                  AND company_code = '#url.c_cd#' 
                  AND login_id = '#form.id#'
                  AND login_password = '#form.pass#'
            </cfquery>
            <cfset result = 0 />
            <!--- 社員マスタでOKの場合 --->
            <cfif qCheckEmp.Recordcount>
                <cfset result = 1 />                        
            <!--- 社員マスタでNGの場合取引先マスタを見る --->
            <cfelse>
                <cfquery name="qCheckClient" datasource="#application.dsn#">
                    SELECT client_code
                      FROM m_client 
                    WHERE
                      AND company_code = '#url.c_cd#' 
                      AND login_id = '#form.id#'
                      AND password = '#form.pass#'
                </cfquery>
                <cfif qCheckClient.Recordcount>
                    <cfset result = 1 />
                </cfif>
            </cfif>
            <cfreturn result>
        </cffunction> --->
        

        <!--- 
        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        伝票番号送信
        iPad側で修理報告書を作成する際にここで伝票番号を発行しています。 

        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
         --->
        <cffunction name="getNewSlipNum" access="remote" returnFormat="plain">
        
            <cftransaction>
                <!--- 現在の伝票番号を取得 --->
                <cfquery datasource="#application.dsn#" name="qGetSlipNum">
                    SELECT CAST(ifnull(cur_slip_num,0) AS SIGNED) cur_slip_num
                      FROM m_company 
                     WHERE kaisya_code = '#url.c_cd#'
                </cfquery>

                <cftransaction action="setsavepoint" savepoint="savepoint"/>
                    <cfset slip_num = qGetSlipNum.cur_slip_num>
                    <cfloop condition="true">
                        <cfset a = slip_num + 1>
                        <cfquery datasource="#application.dsn#" name="qUpdSlipNum" result="rUpdSlipNum">
                            UPDATE m_company SET cur_slip_num = '#a#' WHERE kaisya_code = '#url.c_cd#' AND ifnull(cur_slip_num,0) = #slip_num#
                        </cfquery>
                        <cfquery datasource="#application.dsn#" name="qCheckTreportSlipNum">
                            SELECT slip_num
                              FROM t_report 
                             WHERE kaisya_code = '#url.c_cd#' AND slip_num = '#a#'
                        </cfquery>

                        <cfset slip_num = a>
                            <cfif rUpdSlipNum.RecordCount LTE 1 and qCheckTreportSlipNum.RecordCount lt 1>
                                <cfbreak>
                            <cfelse>
                                <cftransaction action="rollback" savepoint="savepoint" />
                            </cfif>             
                    </cfloop>
            </cftransaction>
            <cfreturn slip_num>
        </cffunction>
        <!--- 
        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        ログイン処理 

        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
         --->
        <cffunction name="tryLogin" access="remote" returnFormat="plain">
            <cfset OK_flag = 0>
            <!--- 委託先コードがある場合取引先マスタのログインIDをチェック --->
            <cfif IsDefined("url.cl_cd") and #url.cl_cd# neq "">            
                <cfquery datasource="#application.dsn#" name="qGetClient">
                    SELECT kaisya_code
                      FROM m_client 
                     WHERE kaisya_code = '#url.c_cd#'
                       AND supp_flag = 1
                       AND client_code = '#url.cl_cd#'
                       AND login_id = '#form.l_id#'
                       AND password = '#form.pd#'
                </cfquery>
                <cfif #qGetClient.RecordCount# GTE 1>
                    <cfset OK_flag = 1>
                </cfif>
            </cfif>
            <!--- 委託先コードがない場合社員マスタのログインIDをチェック --->
<!---           <cfif IsDefined("url.cl_cd") eq false or #url.cl_cd# eq "">
                <cfquery datasource="#application.dsn#" name="qGetEmp">
                    SELECT kaisya_code
                      FROM m_emp 
                     WHERE kaisya_code = '#url.c_cd#'
                       AND login_id = '#form.l_id#'
                       AND password = '#form.pd#'
                </cfquery>
                <cfif #qGetEmp.RecordCount# GTE 1>
                    <cfset OK_flag = 1>
                </cfif>             
            </cfif> --->
            <cfreturn OK_flag >
        </cffunction>

        <!--- 会社マスタ(iPad側は管理マスタ) --->
        <cffunction name="getKanri" access="remote" returnFormat="plain">
            <cfquery datasource="#application.dsn#" name="qGetCompany">
                SELECT kaisya_name,
                       post_no,
                       CONCAT(IFNULL(address_1,''),' ',IFNULL(address_2,'')) as address,
                       tel_no,
                       fax_no,
                       min_slip_num,
                       max_slip_num
                  FROM m_company 
                 WHERE kaisya_code = '#url.c_cd#'
            </cfquery>
            <cfset recordCount = #qGetCompany.RecordCount#>
            <cfset data = "">
            <cfset output = "">
            <cfloop index="cnt" from="1" to="#recordCount#">
                <cfset data = #qGetCompany.kaisya_name[cnt]# & ","
                             & #qGetCompany.post_no[cnt]# & ","
                             & #qGetCompany.address[cnt]# & ","
                             & #qGetCompany.tel_no[cnt]# & ","
                             & #qGetCompany.fax_no[cnt]# & ","
                             & #qGetCompany.min_slip_num[cnt]# & ","
                             & #qGetCompany.max_slip_num[cnt]# & #chr(10)#>         
                <cfset output = #output# & #data#>
            </cfloop>
            <cfreturn #output# >
        </cffunction>


        <!--- 
        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        端末登録処理

        c_cd:company
        cl_cd:client_code
        t_name:terminal_name
        r_date:register_date

        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
         --->
        <cffunction name="setTerminal" access="remote" returnFormat="plain">

            <cfquery datasource="#application.dsn#" name="qGetLimit">
                SELECT limit_terminal_num
                  FROM m_admin 
                 WHERE kaisya_code = '#form.c_cd#'
            </cfquery>
            <cfquery datasource="#application.dsn#" name="qGetCurrentTerminal">
                SELECT kaisya_code
                  FROM t_terminal 
                 WHERE kaisya_code = '#form.c_cd#'
            </cfquery>

            <!--- 台数制限内かどうかチェック --->
            <cfif qGetCurrentTerminal.RecordCount GTE qGetLimit.limit_terminal_num>
                <cfreturn 2>
            </cfif>

            <!--- 端末名が重複していないか --->
            <cfquery datasource="#application.dsn#" name="qCheckTerminal">
                SELECT kaisya_code
                  FROM t_terminal 
                 WHERE kaisya_code = '#form.c_cd#'
                   AND terminal_name = '#form.t_name#'
                  <!---  AND date_format(register_date,'%Y/%m/%d %H:%i') = date_format('#form.r_date#','%Y/%m/%d %H:%i') --->
            </cfquery>

            <cfif qCheckTerminal.RecordCount GTE 1>
                <cfreturn 3>
            </cfif>

            <cfquery datasource="#application.dsn#" name="qInsTerminal">
                INSERT INTO t_terminal 
                        (
                        kaisya_code,
                        client_code,
                        terminal_name,
                        register_date
                        )               
                        VALUES 
                        (
                        '#form.c_cd#',
                        <cfif IsDefined('form.cl_cd') and form.cl_cd neq "">'#form.cl_cd#',<cfelse>null,</cfif>
                        '#form.t_name#',
                        '#form.r_date#'
                        )
            </cfquery>
            <cfreturn 1>
        </cffunction>


        <!--- 
        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        端末チェック(アプリ起動時) 

        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
         --->
        <cffunction name="checkTerminal" access="remote" returnFormat="plain">
            <cfquery datasource="#application.dsn#" name="qCheckTerminal">
                SELECT kaisya_code
                  FROM t_terminal 
                 WHERE kaisya_code = '#form.c_cd#'
                   AND terminal_name = '#form.t_name#'
                   AND date_format(register_date,'%Y/%m/%d %H:%i') = date_format('#form.r_date#','%Y/%m/%d %H:%i')
            </cfquery>
            <cfif qCheckTerminal.RecordCount GTE 1>
              <cfquery datasource="#application.dsn#" name="qInsTerminalLog">
                INSERT INTO t_terminal_log 
                        (
                        kaisya_code,
                        terminal_name,
                        access_date
                        )               
                        VALUES 
                        (
                        '#form.c_cd#',
                        '#form.t_name#',
                        now()
                        )
              </cfquery>              
              <cfreturn 1>
            <cfelse>
              <cfreturn 0>
            </cfif>                     
        </cffunction>


        <!--- 事業所マスタ --->
<!---       <cffunction name="getOffice" access="remote" returnFormat="plain">
            <cfquery datasource="#application.dsn#" name="qGetSection">
                SELECT section_code,
                       section_name,
                       section_name_ryaku,
                       post_no,
                       CONCAT(IFNULL(address_1,''), ' ',IFNULL(address_2,'')) as address,
                       tel_no,
                       fax_no,
                       mail_1,
                       mail_2,
                       DATE_FORMAT(up_date,'%Y/%m/%d %H:%i:%s') as up_date,
                       DATE_FORMAT(koushin_date,'%Y/%m/%d %H:%i:%s') as koushin_date                       
                  FROM m_section 
                 WHERE kaisya_code = '#url.c_cd#'
            </cfquery>

            <cfset recordCount = #qGetSection.RecordCount#>
            <cfset data = "">
            <cfset output = "">
            <cfloop index="cnt" from="1" to="#recordCount#">
                <cfset data = #qGetSection.section_code[cnt]# & ","
                             & #qGetSection.section_name[cnt]# & ","
                             & #qGetSection.post_no[cnt]# & ","
                             & #qGetSection.address[cnt]# & ","
                             & #qGetSection.tel_no[cnt]# & ","
                             & #qGetSection.fax_no[cnt]# & ","
                             & #qGetSection.mail_1[cnt]# & ","
                             & #qGetSection.mail_2[cnt]# & ","
                             & #qGetSection.section_name_ryaku[cnt]# & ","
                             & #qGetSection.up_date[cnt]# & ","                                  
                             & #qGetSection.koushin_date[cnt]# & #chr(10)#>         
                <cfset output = #output# & #data#>
            </cfloop>
            <cfreturn #output# >
        </cffunction> --->



        <!--- 事業所マスタ --->
        <cffunction name="getOffice" access="remote" returnFormat="json">
            <cfquery datasource="#application.dsn#" name="qGetSection">
<!---             
                SELECT section_code,
                       section_name,
                       section_name_ryaku,
                       post_no,
                       CONCAT(IFNULL(address_1,''), ' ',IFNULL(address_2,'')) as address,
                       tel_no,
                       fax_no,
                       mail_1,
                       mail_2,
                       DATE_FORMAT(up_date,'%Y/%m/%d %H:%i:%s') as up_date,
                       DATE_FORMAT(koushin_date,'%Y/%m/%d %H:%i:%s') as koushin_date                       
                  FROM m_section 
                 WHERE kaisya_code = '#url.c_cd#'
 --->
                SELECT m_section.section_code,
                       m_section.section_name,
                       m_section.section_name_ryaku,
                       m_section.post_no,
                       CONCAT(IFNULL(m_section.address_1,''), ' ',IFNULL(m_section.address_2,'')) as address,
                       m_section.tel_no,
                       m_section.fax_no,
                       m_section.mail_1,
                       m_section.mail_2,
                       DATE_FORMAT(m_section.up_date,'%Y/%m/%d %H:%i:%s') as up_date,
                       DATE_FORMAT(m_section.koushin_date,'%Y/%m/%d %H:%i:%s') as koushin_date                       
                  FROM m_section LEFT OUTER JOIN t_client ON m_section.kaisya_code = t_client.kaisya_code     
                                                          AND m_section.section_code = t_client.section_code
                 WHERE m_section.kaisya_code = '#url.c_cd#'
                 <cfif IsDefined('url.cl_cd') and url.cl_cd neq ""> 
                   AND t_client.client_code = '#url.cl_cd#'
                 </cfif>

            </cfquery>

            <cfset recordCount = #qGetSection.RecordCount#>
            <cfset dataset = []>
                <cfloop query="qGetSection">
                    <cfset record                      = {} />
                    <cfset record["office_code"]       = "x" & qGetSection.section_code />
                    <cfset record["office_name"]       = "x" & qGetSection.section_name />
                    <cfset record["postal_code"]       = "x" & qGetSection.post_no />
                    <cfset record["address"]           = "x" & qGetSection.address />                       
                    <cfset record["Tel"]               = "x" & qGetSection.tel_no />
                    <cfset record["fax"]               = "x" & qGetSection.fax_no />
                    <cfset record["e_mail1"]           = "x" & qGetSection.mail_1 />
                    <cfset record["e_mail2"]           = "x" & qGetSection.mail_2 />
                    <cfset record["office_short_name"] = "x" & qGetSection.section_name_ryaku />
                    <cfset record["up_date"]           = "x" & qGetSection.up_date />
                    <cfset record["koushin_date"]      = "x" & qGetSection.koushin_date />          
                    <cfset ArrayAppend(dataset, record) />
                </cfloop>
            <cfreturn serializeJSON(dataset) >
        </cffunction>

        <!--- 冷媒マスタ --->
        <cffunction name="getReibai" access="remote" returnFormat="json">
            <cfquery datasource="#application.dsn#" name="qGetReibai">
                SELECT reibai_id,
                       reibai_kind,
                       del_flag,
                       DATE_FORMAT(create_date,'%Y/%m/%d %H:%i:%s') as create_date,
                       DATE_FORMAT(update_date,'%Y/%m/%d %H:%i:%s') as update_date                     
                  FROM m_reibai 
                 WHERE kaisya_code = '#url.c_cd#'
            </cfquery>

            <cfset recordCount = #qGetReibai.RecordCount#>
            <cfset dataset = []>
                <cfloop query="qGetReibai">
                    <cfset record                = {} />
                    <cfset record["reibai_id"]   = "x" & qGetReibai.reibai_id />
                    <cfset record["reibai_kind"] = "x" & qGetReibai.reibai_kind />
                    <cfset record["del_flag"]    = "x" & qGetReibai.del_flag />
                    <cfset record["create_date"] = "x" & qGetReibai.create_date />
                    <cfset record["update_date"] = "x" & qGetReibai.update_date />
                    <cfset ArrayAppend(dataset, record) />
                </cfloop>
            <cfreturn #serializeJSON(dataset)# >
        </cffunction>


<!--- 
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

CFのバグで、シリアライズする際にjsonの型がおかしくなる現象があります。
強制的に文字列にするためデータの頭に「x」を付けています。
　※SQL内で、concat等で文字列を追加してもうまくいかない経緯があったため、
　 CFで付けています。


■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
 --->

        <!--- ユニットマスタ(台帳) --->
    <cffunction name="getUnitLedger" access="remote" returnFormat="json">
    <cfquery datasource="#application.dsn#" name="qGetUnit">
        SELECT
            m_unit.kaisya_code,
            m_unit.unit_code,
            m_unit.unit_name,
            m_unit.client_code,
            m_unit.u_model,
            m_unit.u_manufacturer,
            m_unit.u_frozen_ability,
            m_unit.u_reibai_id,
            REIBAI1.reibai_kind as u_reibai_kind,
            m_unit.u_reibai_jyuten,
            m_unit.u_lubricant_kind,
            m_unit.u_lubricant_jyuten,
            m_unit.u_reibai_id2,
            REIBAI2.reibai_kind as u_reibai_kind2,
            m_unit.u_reibai_jyuten2,
            m_unit.u_lubricant_kind2,
            m_unit.u_lubricant_jyuten2,
            m_unit.f_model,
            m_unit.f_model_date,
            m_unit.f_amount,
            m_unit.f_electric_output,
            m_unit.f_manufacturer,
            m_unit.p_model,
            m_unit.p_diameter,
            m_unit.p_electric_output,
            m_unit.p_manufacturer,
            m_unit.p_mekaseal_model,
            m_unit.a_oil_strainer,
            m_unit.a_suction_strainer,
            m_unit.a_solution_sending,
            m_unit.freon_flag,
            m_unit.freon_type,      
            m_unit.filling_amount,

            m_unit.room_name1,
            m_unit.shuyo_amount1,
            m_unit.shuyo_area1,
            m_unit.setting_temperature1,
            m_unit.cooler_model1,
            m_unit.sending_denjiben_model1,
            m_unit.bochoben_model1,
            m_unit.dryer_model1,

            m_unit.room_name2,
            m_unit.shuyo_amount2,
            m_unit.shuyo_area2,
            m_unit.setting_temperature2,
            m_unit.cooler_model2,
            m_unit.sending_denjiben_model2,
            m_unit.bochoben_model2,
            m_unit.dryer_model2,

            m_unit.room_name3,
            m_unit.shuyo_amount3,
            m_unit.shuyo_area3,
            m_unit.setting_temperature3,
            m_unit.cooler_model3,
            m_unit.sending_denjiben_model3,
            m_unit.bochoben_model3,
            m_unit.dryer_model3,

            m_unit.room_name4,
            m_unit.shuyo_amount4,
            m_unit.shuyo_area4,
            m_unit.setting_temperature4,
            m_unit.cooler_model4,
            m_unit.sending_denjiben_model4,
            m_unit.bochoben_model4,
            m_unit.dryer_model4,

            m_unit.room_name5,
            m_unit.shuyo_amount5,
            m_unit.shuyo_area5,
            m_unit.setting_temperature5,
            m_unit.cooler_model5,
            m_unit.sending_denjiben_model5,
            m_unit.bochoben_model5,
            m_unit.dryer_model5,

            m_unit.room_name6,
            m_unit.shuyo_amount6,
            m_unit.shuyo_area6,
            m_unit.setting_temperature6,
            m_unit.cooler_model6,
            m_unit.sending_denjiben_model6,
            m_unit.bochoben_model6,
            m_unit.dryer_model6,

            m_unit.freezer1,
            m_unit.f_serial_num1,
            m_unit.overhaul_date1,
            date_format(overhaul_date1,'%Y/%m/%d') char_overhaul_date1,
            m_unit.overhaul_time1,
            m_unit.last_overhaul_date1,
            date_format(last_overhaul_date1,'%Y/%m/%d') char_last_overhaul_date1,
            m_unit.before_last_overhaul_date1,
            date_format(before_last_overhaul_date1,'%Y/%m/%d') char_before_last_overhaul_date1,
            <!--- FORMAT(TIMESTAMPDIFF(HOUR,last_overhaul_date1,overhaul_date1),0) AS o_time1, --->
            FORMAT(TIMESTAMPDIFF(HOUR,overhaul_date1,now()),0) AS o_time1,

            m_unit.freezer2,
            m_unit.f_serial_num2,
            m_unit.overhaul_date2,
            date_format(overhaul_date2,'%Y/%m/%d') char_overhaul_date2,
            m_unit.overhaul_time2,
            m_unit.last_overhaul_date2,
            date_format(last_overhaul_date2,'%Y/%m/%d') char_last_overhaul_date2,
            m_unit.before_last_overhaul_date2,
            date_format(before_last_overhaul_date2,'%Y/%m/%d') char_before_last_overhaul_date2,
            <!--- FORMAT(TIMESTAMPDIFF(HOUR,last_overhaul_date2,overhaul_date2),0) AS o_time2, --->
            FORMAT(TIMESTAMPDIFF(HOUR,overhaul_date2,now()),0) AS o_time2,

            m_unit.freezer3,
            m_unit.f_serial_num3,
            m_unit.overhaul_date3,
            date_format(overhaul_date3,'%Y/%m/%d') char_overhaul_date3,
            m_unit.overhaul_time3,
            m_unit.last_overhaul_date3,
            date_format(last_overhaul_date3,'%Y/%m/%d') char_last_overhaul_date3,
            m_unit.before_last_overhaul_date3,
            date_format(before_last_overhaul_date3,'%Y/%m/%d') char_before_last_overhaul_date3,
            <!--- FORMAT(TIMESTAMPDIFF(HOUR,last_overhaul_date3,overhaul_date3),0) AS o_time3, --->
            FORMAT(TIMESTAMPDIFF(HOUR,overhaul_date3,now()),0) AS o_time3,
            date_format(m_unit.create_date,'%Y/%m/%d') create_date,
            date_format(m_unit.update_date,'%Y/%m/%d') update_date,
            m_unit.office_code,
            m_unit.del_flag,
            m_client.client_name,
            m_client.post_no1,
            m_client.address_1,
            m_client.address_2,
            m_client.address_3,
            m_client.tel_no1,
            m_client.fax_no1,
            <cfif application.mysql_ver eq "5.7">
            Y(t_geometory.geo) latitude,
            X(t_geometory.geo) longitude,
            <cfelse>
            ST_Y(t_geometory.geo) latitude,
            ST_X(t_geometory.geo) longitude,                                  
            </cfif>
            m_unit.memo,
            TREPORT.report_cnt
       FROM m_unit LEFT OUTER JOIN m_client ON m_unit.kaisya_code = m_client.kaisya_code AND m_unit.client_code = m_client.client_code 
                   LEFT OUTER JOIN t_geometory ON m_unit.kaisya_code = t_geometory.kaisya_code AND m_unit.client_code = t_geometory.client_code
                   LEFT OUTER JOIN m_reibai REIBAI1 ON m_unit.kaisya_code = REIBAI1.kaisya_code AND m_unit.u_reibai_id = REIBAI1.reibai_id
                   LEFT OUTER JOIN m_reibai REIBAI2 ON m_unit.kaisya_code = REIBAI2.kaisya_code AND m_unit.u_reibai_id2 = REIBAI2.reibai_id
                   LEFT OUTER JOIN (SELECT kaisya_code,
                                        unit_code,
                                        client_code,
                                        count(slip_num) report_cnt
                                   FROM t_report
                                  WHERE del_flag <> 1 
                               GROUP BY kaisya_code,client_code,unit_code) TREPORT ON m_unit.kaisya_code = TREPORT.kaisya_code 
                                                                                  AND m_unit.client_code = TREPORT.client_code 
                                                                                  AND m_unit.unit_code = TREPORT.unit_code
                    <cfif IsDefined('url.cl_cd') and url.cl_cd neq "">                                            
                        INNER JOIN (SELECT distinct t_client.client_code,t_client.kaisya_code 
                                      FROM t_client INNER JOIN (SELECT section_code,kaisya_code 
                                                                   FROM t_client 
                                                                  WHERE kaisya_code = '#url.c_cd#' 
                                                                    AND client_code = '#url.cl_cd#') MCLIENT ON MCLIENT.kaisya_code = t_client.kaisya_code
                                                                                                            AND MCLIENT.section_code = t_client.section_code) TCLIENT ON TCLIENT.kaisya_code = m_unit.kaisya_code
                                                                                                                                                                      AND TCLIENT.client_code = m_unit.client_code                                  
                    </cfif>
      WHERE m_unit.kaisya_code = '#url.c_cd#'
        <!--- AND m_unit.update_date >= '#url.last_recv_datetime#' --->
    </cfquery>

            <cfset recordCount = #qGetUnit.RecordCount#>
            <cfset data = "">
            <cfset output = "">

            <cfset dataset = []>
                <cfloop query="qGetUnit">
                    <cfset record                               = {} />
                    <cfset record["unit"]                       = "x" & qGetUnit.unit_code />
                    <cfset record["unit_name"]                  = "x" & qGetUnit.unit_name />
                    <cfset record["customer_code"]              = "x" & qGetUnit.client_code />
                    <cfset record["customer_name"]              = "x" & qGetUnit.client_name />
                    <cfset record["postal_code"]                = "x" & qGetUnit.post_no1 />                        
                    <cfset record["address"]                    = "x" & qGetUnit.address_1 & " " & qGetUnit.address_2 & " " & qGetUnit.address_3 />
                    <cfset record["tel"]                        = "x" & qGetUnit.tel_no1 />
                    <cfset record["fax"]                        = "x" & qGetUnit.fax_no1 />
                    <cfset record["latitude"]                   = "x" & qGetUnit.latitude />
                    <cfset record["longitude"]                  = "x" & qGetUnit.longitude />
                    <cfset record["u_model"]                    = "x" & qGetUnit.u_model /> 
                    
                    <cfset record["u_manufacturer"]             = "x" & qGetUnit.u_manufacturer />
                    <cfset record["u_frozen_ability"]           = "x" & qGetUnit.u_frozen_ability />
                    <cfset record["u_reibai_id"]                = "x" & qGetUnit.u_reibai_id />
                    <cfset record["u_reibai_id2"]                = "x" & qGetUnit.u_reibai_id2 />
                    <cfset record["u_reibai_kind"]              = "x" & qGetUnit.u_reibai_kind />
                    <cfset record["u_reibai_kind2"]              = "x" & qGetUnit.u_reibai_kind2 />
                    <cfset record["u_reibai_jyuten"]            = "x" & qGetUnit.u_reibai_jyuten />
                    <cfset record["u_reibai_jyuten2"]            = "x" & qGetUnit.u_reibai_jyuten2 />
                    <cfset record["u_lubricant_kind"]           = "x" & qGetUnit.u_lubricant_kind />
                    <cfset record["u_lubricant_kind2"]           = "x" & qGetUnit.u_lubricant_kind2 />
                    <cfset record["u_lubricant_jyuten"]         = "x" & qGetUnit.u_lubricant_jyuten />
                    <cfset record["u_lubricant_jyuten2"]         = "x" & qGetUnit.u_lubricant_jyuten2 />
                    <cfset record["f_model"]                    = "x" & qGetUnit.f_model />
                    <cfset record["f_model_date"]               = "x" & qGetUnit.f_model_date />            
                    <cfset record["f_amount"]                   = "x" & qGetUnit.f_amount />
                    <cfset record["f_electric_output"]          = "x" & qGetUnit.f_electric_output />
                    
                    <cfset record["f_manufacturer"]             = "x" & qGetUnit.f_manufacturer />
                    <cfset record["freon_flag"]                 = "x" & qGetUnit.freon_flag />
                    <cfset record["freon_type"]                 = "x" & qGetUnit.freon_type />
                    <cfset record["filling_amount"]             = "x" & qGetUnit.filling_amount />          
                    <cfset record["p_model"]                    = "x" & qGetUnit.p_model />
                    <cfset record["p_diameter"]                 = "x" & qGetUnit.p_diameter />
                    <cfset record["p_electric_output"]          = "x" & qGetUnit.p_electric_output />
                    <cfset record["p_manufacturer"]             = "x" & qGetUnit.p_manufacturer />
                    <cfset record["p_mekaseal_model"]           = "x" & qGetUnit.p_mekaseal_model />
                    <cfset record["a_oil_strainer"]             = "x" & qGetUnit.a_oil_strainer />
                    
                    <cfset record["a_suction_strainer"]         = "x" & qGetUnit.a_suction_strainer />
                    <cfset record["a_solution_sending"]         = "x" & qGetUnit.a_solution_sending />                  
                    <cfset record["freezer1"]                   = "x" & qGetUnit.freezer1 />
                    <cfset record["f_serial_num1"]              = "x" & qGetUnit.f_serial_num1 />
                    <cfset record["overhaul_date1"]             = "x" & qGetUnit.char_overhaul_date1 />
                    <cfset record["overhaul_time1"]             = "x" & qGetUnit.overhaul_time1 />          
                    <cfset record["last_overhaul_date1"]        = "x" & qGetUnit.char_last_overhaul_date1 />
                    <cfset record["before_last_overhaul_date1"] = "x" & qGetUnit.char_before_last_overhaul_date1 />                 
                    <cfset record["freezer2"]                   = "x" & qGetUnit.freezer2 />
                    <cfset record["f_serial_num2"]              = "x" & qGetUnit.f_serial_num2 />
                    
                    <cfset record["overhaul_date2"]             = "x" & qGetUnit.char_overhaul_date2 />
                    <cfset record["overhaul_time2"]             = "x" & qGetUnit.overhaul_time2 />          
                    <cfset record["last_overhaul_date2"]        = "x" & qGetUnit.char_last_overhaul_date2 />
                    <cfset record["before_last_overhaul_date2"] = "x" & qGetUnit.char_before_last_overhaul_date2 />                 
                    <cfset record["freezer3"]                   = "x" & qGetUnit.freezer3 />
                    <cfset record["f_serial_num3"]              = "x" & qGetUnit.f_serial_num3 />
                    <cfset record["overhaul_date3"]             = "x" & qGetUnit.char_overhaul_date3 />
                    <cfset record["overhaul_time3"]             = "x" & qGetUnit.overhaul_time3 />          
                    <cfset record["last_overhaul_date3"]        = "x" & qGetUnit.char_last_overhaul_date3 />
                    <cfset record["before_last_overhaul_date3"] = "x" & qGetUnit.char_before_last_overhaul_date3 />
                    
                    <cfset record["delete_flag"]                = "x" & qGetUnit.del_flag />            
                    <cfset record["create_date"]                = "x" & qGetUnit.create_date />
                    <cfset record["update_date"]                = "x" & qGetUnit.update_date />
                    <cfset record["report_count"]               = "x" & qGetUnit.report_cnt />
        
                    <cfset ArrayAppend(dataset, record) />
                </cfloop>
            <cfreturn #serializeJSON(dataset)# >

<!--- 

            <cfloop index="cnt" from="1" to="#recordCount#">
                <cfset data = #qGetUnit.unit_code[cnt]# & ","
                             & #qGetUnit.client_code[cnt]# & ","
                             & #qGetUnit.client_name[cnt]# & ","
                             & #qGetUnit.post_no1[cnt]# & ","
                             & #qGetUnit.address_1[cnt]# & " " & #qGetUnit.address_2[cnt]# & " " & #qGetUnit.address_3[cnt]# & ","
                             & #qGetUnit.tel_no1[cnt]# & ","
                             & #qGetUnit.fax_no1[cnt]# & ","
                             & #qGetUnit.latitude[cnt]# & ","
                             & #qGetUnit.longitude[cnt]# & ","
                             & #qGetUnit.u_model[cnt]# & ","
                             
                             & #qGetUnit.u_manufacturer[cnt]# & ","
                             & #qGetUnit.u_frozen_ability[cnt]# & ","
                             & #qGetUnit.u_reibai_kind[cnt]# & ","
                             & #qGetUnit.u_reibai_jyuten[cnt]# & ","
                             & #qGetUnit.u_lubricant_kind[cnt]# & ","
                             & #qGetUnit.u_lubricant_jyuten[cnt]# & ","
                             & #qGetUnit.f_model[cnt]# & ","
                             & #qGetUnit.f_model_date[cnt]# & ","
                             & #qGetUnit.f_amount[cnt]# & ","
                             & #qGetUnit.f_electric_output[cnt]# & ","

                             & #qGetUnit.f_manufacturer[cnt]# & ","
                             & #qGetUnit.freon_flag[cnt]# & ","
                             & #qGetUnit.freon_type[cnt]# & ","
                             & #qGetUnit.filling_amount[cnt]# & ","
                             & #qGetUnit.p_model[cnt]# & ","
                             & #qGetUnit.p_diameter[cnt]# & ","
                             & #qGetUnit.p_electric_output[cnt]# & ","
                             & #qGetUnit.p_manufacturer[cnt]# & ","
                             & #qGetUnit.p_mekaseal_model[cnt]# & ","
                             & #qGetUnit.a_oil_strainer[cnt]# & ","

                             & #qGetUnit.a_suction_strainer[cnt]# & ","
                             & #qGetUnit.a_solution_sending[cnt]# & ","

                             & #qGetUnit.freezer1[cnt]# & ","
                             & #qGetUnit.f_serial_num1[cnt]# & ","
                             & #qGetUnit.char_overhaul_date1[cnt]# & ","
                             & #qGetUnit.overhaul_time1[cnt]# & ","
                             & #qGetUnit.char_last_overhaul_date1[cnt]# & ","
                             & #qGetUnit.char_before_last_overhaul_date1[cnt]# & ","

                             & #qGetUnit.freezer2[cnt]# & ","
                             & #qGetUnit.f_serial_num2[cnt]# & ","
                             & #qGetUnit.char_overhaul_date2[cnt]# & ","
                             & #qGetUnit.overhaul_time2[cnt]# & ","
                             & #qGetUnit.char_last_overhaul_date2[cnt]# & ","
                             & #qGetUnit.char_before_last_overhaul_date2[cnt]# & ","

                             & #qGetUnit.freezer3[cnt]# & ","
                             & #qGetUnit.f_serial_num3[cnt]# & ","
                             & #qGetUnit.char_overhaul_date3[cnt]# & ","
                             & #qGetUnit.overhaul_time3[cnt]# & ","
                             & #qGetUnit.char_last_overhaul_date3[cnt]# & ","
                             & #qGetUnit.char_before_last_overhaul_date3[cnt]# & ","

                             & #qGetUnit.del_flag[cnt]# & ","
                             & #qGetUnit.create_date[cnt]# & ","
                             & #qGetUnit.update_date[cnt]# & #chr(10)#>     
                <cfset output = #output# & #data#>
            </cfloop>
        <cfreturn #output# >
 --->



            
    </cffunction>

        <!--- ユニットマスタ(対象冷蔵室) --->
        <cffunction name="getUnitTargetColdRoom" access="remote" returnFormat="plain">
            <cfquery datasource="#application.dsn#" name="qGetUnitLedger">
                SELECT
                    m_unit.unit_code,
                    m_unit.client_code, 
                    <cfloop index="i" from="1" to="6">
                        m_unit.cold_room_num#i#,                      
                        m_unit.room_name#i#,             
                        m_unit.shuyo_amount#i#,          
                        m_unit.shuyo_area#i#,            
                        m_unit.setting_temperature#i#,   
                        m_unit.cooler_model#i#,          
                        m_unit.sending_denjiben_model#i#,
                        m_unit.bochoben_model#i#,        
                        m_unit.dryer_model#i#,                          
                    </cfloop>
                       DATE_FORMAT(m_unit.create_date,'%Y/%m/%d %H:%i:%s') as create_date,
                       DATE_FORMAT(m_unit.update_date,'%Y/%m/%d %H:%i:%s') as update_date                      
                  FROM m_unit
                    <cfif IsDefined('url.cl_cd') and url.cl_cd neq "">                                            
                        INNER JOIN (SELECT distinct t_client.client_code,t_client.kaisya_code 
                                      FROM t_client INNER JOIN (SELECT section_code,kaisya_code 
                                                                   FROM t_client 
                                                                  WHERE kaisya_code = '#url.c_cd#' 
                                                                    AND client_code = '#url.cl_cd#') MCLIENT ON MCLIENT.kaisya_code = t_client.kaisya_code
                                                                                                            AND MCLIENT.section_code = t_client.section_code) TCLIENT ON TCLIENT.kaisya_code = m_unit.kaisya_code
                                                                                                                                                                      AND TCLIENT.client_code = m_unit.client_code                                  
                    </cfif> 
                 WHERE m_unit.kaisya_code = '#url.c_cd#'
            </cfquery>

            <cfset recordCount = qGetUnitLedger.RecordCount>
            <cfset data = "">
            <cfset output = "">
            <cfloop index="cnt" from="1" to="#recordCount#">
                <cfloop index="i" from="1" to="6">
                    <cfset data = #qGetUnitLedger.unit_code[cnt]# & ","
                                 & #qGetUnitLedger.client_code[cnt]# & ","
                                 & #qGetUnitLedger['cold_room_num' & i][cnt]# & ","
                                 & #qGetUnitLedger['room_name' & i][cnt]# & ","
                                 & #qGetUnitLedger['shuyo_amount' & i][cnt]# & ","
                                 & #qGetUnitLedger['shuyo_area' & i][cnt]# & ","
                                 & #qGetUnitLedger['setting_temperature' & i][cnt]# & ","
                                 & #qGetUnitLedger['cooler_model' & i][cnt]# & ","
                                 & #qGetUnitLedger['sending_denjiben_model' & i][cnt]# & ","
                                 & #qGetUnitLedger['bochoben_model' & i][cnt]# & ","
                                 & #qGetUnitLedger['dryer_model' & i][cnt]# & ","
                                 & #qGetUnitLedger.create_date[cnt]# & ","                                   
                                 & #qGetUnitLedger.update_date[cnt]# & #chr(10)#>           
                    <cfset output = #output# & #data#>
                </cfloop>
            </cfloop>
            <cfreturn #output# >
        </cffunction>


        <!--- 修理履歴 --->
        
        <cffunction name="getTReport" access="remote" returnFormat="json">
            <cfquery datasource="#application.dsn#" name="qGetReport">
                SELECT
                    t_report.slip_num,
                    t_report.client_code,
                    t_report.unit_code,
                    t_report.unit_name,
                    DATE_FORMAT(t_report.work_date,'%Y/%m/%d') work_date,
                    DATE_FORMAT(t_report.start_time, '%H:%i') as start_time,
                    DATE_FORMAT(t_report.end_time, '%H:%i') as end_time,            
                    t_report.target_machinery,
                    t_report.client_name,
                    t_report.name,
                    t_report.office_code,
                    t_report.office_short_name,
                    t_report.work_men,
                    t_report.work_fee,
                    t_report.filling_amount,
                    t_report.filling_amount2,
                    t_report.signature,
                    t_report.work_kubun,                            
                    t_report.claim_kubun,
                    t_report.uketsuke_contents,
                    t_report.state_contents,
                    t_report.cause,
                    t_report.measures,
                    t_report.parts,        
                    t_report.picture1,
                    t_report.p_daytime1,
                    t_report.p_memo1,
                    t_report.picture2,
                    t_report.p_daytime2,
                    t_report.p_memo2,
                    t_report.picture3,
                    t_report.p_daytime3,
                    t_report.p_memo3,
                    t_report.picture4,
                    t_report.p_daytime4,
                    t_report.p_memo4,
                    t_report.decision_flag,
                    t_report.remarks,
                    t_report.freon_flag,
                    t_report.freon_flag2,
                    t_report.freon_type,
                    t_report.freon_type2,
                    t_report.freon_certificate_num,
                    t_report.finish_check,

                    DATE_FORMAT(t_report.modify_work_date,'%Y/%m/%d') modify_work_date,
                    DATE_FORMAT(t_report.modify_start_time,'%Y/%m/%d') modify_start_time,
                    DATE_FORMAT(t_report.modify_end_time,'%Y/%m/%d') modify_end_time,
                    DATE_FORMAT(t_report.modify_target_machinery,'%Y/%m/%d') modify_target_machinery,
                    DATE_FORMAT(t_report.modify_name,'%Y/%m/%d') modify_name,
                    DATE_FORMAT(t_report.modify_office_code,'%Y/%m/%d') modify_office_code,
                    DATE_FORMAT(t_report.modify_work_kubun,'%Y/%m/%d') modify_work_kubun,
                    DATE_FORMAT(t_report.modify_claim_kubun,'%Y/%m/%d') modify_claim_kubun,
                    DATE_FORMAT(t_report.modify_freon_flag,'%Y/%m/%d') modify_freon_flag,
                    DATE_FORMAT(t_report.modify_freon_flag2,'%Y/%m/%d') modify_freon_flag2,
                    DATE_FORMAT(t_report.modify_freon_type,'%Y/%m/%d') modify_freon_type,
                    DATE_FORMAT(t_report.modify_freon_type2,'%Y/%m/%d') modify_freon_type2,
                    DATE_FORMAT(t_report.modify_freon_type,'%Y/%m/%d') modify_freon_type,
                    DATE_FORMAT(t_report.modify_freon_type2,'%Y/%m/%d') modify_freon_type2,
                    DATE_FORMAT(t_report.modify_filling_amount,'%Y/%m/%d') modify_filling_amount,
                    DATE_FORMAT(t_report.modify_filling_amount2,'%Y/%m/%d') modify_filling_amount2,
                    DATE_FORMAT(t_report.modify_uketsuke_contents,'%Y/%m/%d') modify_uketsuke_contents,
                    DATE_FORMAT(t_report.modify_state_contents,'%Y/%m/%d') modify_state_contents,
                    DATE_FORMAT(t_report.modify_cause,'%Y/%m/%d') modify_cause,

                    DATE_FORMAT(t_report.modify_measures,'%Y/%m/%d') modify_measures,
                    DATE_FORMAT(t_report.modify_parts,'%Y/%m/%d') modify_parts,
                    DATE_FORMAT(t_report.modify_remarks,'%Y/%m/%d') modify_remarks,
                    DATE_FORMAT(t_report.modify_finish_check,'%Y/%m/%d') modify_finish_check,
                    DATE_FORMAT(t_report.modify_work_men,'%Y/%m/%d') modify_work_men,

                    t_report.finish_check_item1,
                    DATE_FORMAT(t_report.finish_check_time1, '%H:%i') as finish_check_time1,
                    t_report.finish_check_name1,
                    t_report.finish_check_item2,
                    DATE_FORMAT(t_report.finish_check_time2, '%H:%i') as finish_check_time2,
                    t_report.finish_check_name2,
                    t_report.finish_check_item3,
                    DATE_FORMAT(t_report.finish_check_time3, '%H:%i') as finish_check_time3,
                    t_report.finish_check_name3,
                    t_report.modify_finish_check_item1,
                    DATE_FORMAT(t_report.modify_finish_check_time1, '%H:%i') as modify_finish_check_time1,
                    t_report.modify_finish_check_name1,
                    t_report.modify_finish_check_item2,
                    DATE_FORMAT(t_report.modify_finish_check_time2, '%H:%i') as modify_finish_check_time2,
                    t_report.modify_finish_check_name2,
                    t_report.modify_finish_check_item3,
                    DATE_FORMAT(t_report.modify_finish_check_time3, '%H:%i') as modify_finish_check_time3,
                    t_report.modify_finish_check_name3,
                    t_report.confirm_name1,
                    DATE_FORMAT(t_report.confirm_day1,'%Y/%m/%d') confirm_day1,
                    t_report.confirm_name2,
                    DATE_FORMAT(t_report.confirm_day2,'%Y/%m/%d') confirm_day2,
                    t_report.which_made,


                    t_report.create_date,
                    t_report.update_date,
                    t_report.del_flag,
                    m_client.address_1,
                    m_client.address_2,
                    m_client.address_3,
                    m_client.tel_no1,
                    m_client.fax_no1
                FROM t_report LEFT OUTER JOIN m_client ON t_report.kaisya_code = m_client.kaisya_code AND t_report.client_code = m_client.client_code 
               WHERE t_report.kaisya_code = '#url.c_cd#'
                 AND t_report.unit_code = '#url.u_cd#'
                 
                 <!--- AND t_report.client_code = '#url.cl_cd#' --->
                 
                 <!---これはバグ。
                 AND t_report.last_recv_datetime >= '#url.last_recv_datetime#'
                 --->

                 <!--- 
                 ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
                 全件送信する場合は↓をコメントにする
                 ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
                 --->
                 
                 AND (t_report.create_date >= '#url.last_recv_datetime#'
                    OR t_report.update_date >= '#url.last_recv_datetime#')
                 

            </cfquery>
            <cfset recordCount = #qGetReport.RecordCount#>
            <cfset data = "">
            <cfset output = "">

            <cfset dataset = []>
                <cfloop query="qGetReport">
                    <cfset record                             = {} />
                    <cfset record["unit"]                     = "x" & qGetReport.unit_code />
                    <cfset record["unit_name"]                = "x" & qGetReport.unit_name />
                    <cfset record["slip_num"]                 = "x" & qGetReport.slip_num />
                    <cfset record["date"]                     = "x" & qGetReport.work_date />
                    <cfset record["start_time"]               = "x" & qGetReport.start_time />                      
                    <cfset record["end_time"]                 = "x" & qGetReport.end_time/>
                    <cfset record["target_machinery"]         = "x" & qGetReport.target_machinery />
                    <cfset record["customer_code"]            = "x" & qGetReport.client_code />
                    <cfset record["customer_name"]            = "x" & qGetReport.client_name />
                    <cfset record["name"]                     = "x" & qGetReport.name />
                    <cfset record["office_code"]              = "x" & qGetReport.office_code /> 
                    
                    <cfset record["office_short_name"]        = "x" & qGetReport.office_short_name />
                    <cfset record["signature"]                = "x" & qGetReport.signature />
                    <cfset record["work_kubun"]               = "x" & qGetReport.work_kubun />
                    <cfset record["claim_kubun"]              = "x" & qGetReport.claim_kubun />
                    <cfset record["work_fee"]                 = "x" & qGetReport.work_fee />
                    <cfset record["freon_flag"]               = "x" & qGetReport.freon_flag />
                    <cfset record["freon_flag2"]              = "x" & qGetReport.freon_flag2 />
                    <cfset record["freon_type"]               = "x" & qGetReport.freon_type />
                    <cfset record["freon_type2"]              = "x" & qGetReport.freon_type2 />
                    <cfset record["filling_amount"]           = "x" & qGetReport.filling_amount />
                    <cfset record["filling_amount2"]          = "x" & qGetReport.filling_amount2 />         
                    <cfset record["uketsuke_contents"]        = "x" & qGetReport.uketsuke_contents />
                    <cfset record["state_contents"]           = "x" & qGetReport.state_contents />
                    
                    <cfset record["cause"]                    = "x" & qGetReport.cause />
                    <cfset record["measures"]                 = "x" & qGetReport.measures />
                    <cfset record["use_buhin"]                = "x" & qGetReport.parts />           
                    <cfset record["remarks"]                  = "x" & qGetReport.remarks />
                    <cfset record["finish_check"]             = "x" & qGetReport.finish_check />
                    <cfset record["work_men"]                 = "x" & qGetReport.work_men />
                    
                    <cfset record["modify_work_date"]         = "x" & qGetReport.modify_work_date />
                    <cfset record["modify_start_time"]        = "x" & qGetReport.modify_start_time />
                    <cfset record["modify_end_time"]          = "x" & qGetReport.modify_end_time />
                    <cfset record["modify_target_machinery"]  = "x" & qGetReport.modify_target_machinery />
                    <cfset record["modify_name"]              = "x" & qGetReport.modify_name />
                    <cfset record["modify_office_code"]       = "x" & qGetReport.modify_office_code />
                    <cfset record["modify_work_kubun"]        = "x" & qGetReport.modify_work_kubun />
                    <cfset record["modify_claim_kubun"]       = "x" & qGetReport.modify_claim_kubun />
                    <cfset record["modify_freon_flag"]        = "x" & qGetReport.modify_freon_flag />
                    <cfset record["modify_freon_flag2"]       = "x" & qGetReport.modify_freon_flag2 />
                    <cfset record["modify_freon_type"]        = "x" & qGetReport.modify_freon_type />
                    <cfset record["modify_freon_type2"]       = "x" & qGetReport.modify_freon_type2 />
                    <cfset record["modify_filling_amount"]    = "x" & qGetReport.modify_filling_amount />
                    <cfset record["modify_filling_amount2"]   = "x" & qGetReport.modify_filling_amount2 />
                    <cfset record["modify_uketsuke_contents"] = "x" & qGetReport.modify_uketsuke_contents />
                    <cfset record["modify_state_contents"]    = "x" & qGetReport.modify_state_contents />
                    <cfset record["modify_cause"]             = "x" & qGetReport.modify_cause />
                    <cfset record["modify_measures"]          = "x" & qGetReport.modify_measures />
                    <cfset record["modify_parts"]             = "x" & qGetReport.modify_parts />
                    <cfset record["modify_remarks"]           = "x" & qGetReport.modify_remarks />
                    <cfset record["modify_finish_check"]      = "x" & qGetReport.modify_finish_check />
                    <cfset record["modify_work_men"]          = "x" & qGetReport.modify_work_men />
                    <cfset record["confirm_name1"]            = "x" & qGetReport.confirm_name1 />
                    <cfset record["confirm_day1"]             = "x" & qGetReport.confirm_day1 />
                    <cfset record["confirm_name2"]            = "x" & qGetReport.confirm_name2 />
                    <cfset record["confirm_day2"]             = "x" & qGetReport.confirm_day2 />
                    <cfset record["which_made"]               = "x" & qGetReport.which_made />


                    <cfset record["finish_check_item1"] = "x" & qGetReport.finish_check_item1/>
                    <cfset record["finish_check_time1"] = "x" & qGetReport.finish_check_time1/>
                    <cfset record["finish_check_name1"] = "x" & qGetReport.finish_check_name1/>
                    <cfset record["finish_check_item2"] = "x" & qGetReport.finish_check_item2/>
                    <cfset record["finish_check_time2"] = "x" & qGetReport.finish_check_time2/>
                    <cfset record["finish_check_name2"] = "x" & qGetReport.finish_check_name2/>
                    <cfset record["finish_check_item3"] = "x" & qGetReport.finish_check_item3/>
                    <cfset record["finish_check_time3"] = "x" & qGetReport.finish_check_time3/>
                    <cfset record["finish_check_name3"] = "x" & qGetReport.finish_check_name3/>
                    <cfset record["modify_finish_check_item1"] = "x" & qGetReport.modify_finish_check_item1/>
                    <cfset record["modify_finish_check_time1"] = "x" & qGetReport.modify_finish_check_time1/>
                    <cfset record["modify_finish_check_name1"] = "x" & qGetReport.modify_finish_check_name1/>
                    <cfset record["modify_finish_check_item2"] = "x" & qGetReport.modify_finish_check_item2/>
                    <cfset record["modify_finish_check_time2"] = "x" & qGetReport.modify_finish_check_time2/>
                    <cfset record["modify_finish_check_name2"] = "x" & qGetReport.modify_finish_check_name2/>
                    <cfset record["modify_finish_check_item3"] = "x" & qGetReport.modify_finish_check_item3/>
                    <cfset record["modify_finish_check_time3"] = "x" & qGetReport.modify_finish_check_time3/>
                    <cfset record["modify_finish_check_name3"] = "x" & qGetReport.modify_finish_check_name3/>
                    
                    <cfset record["picture1"]                 = "x" & qGetReport.picture1 />
                    <cfset record["p_daytime1"]               = "x" & qGetReport.p_daytime1 />
                    <cfset record["p_memo1"]                  = "x" & qGetReport.p_memo1 />
                    
                    <cfset record["picture2"]                 = "x" & qGetReport.picture2 />
                    <cfset record["p_daytime2"]               = "x" & qGetReport.p_daytime2 />                  
                    <cfset record["p_memo2"]                  = "x" & qGetReport.p_memo2 />
                    <cfset record["picture3"]                 = "x" & qGetReport.picture3 />
                    <cfset record["p_daytime3"]               = "x" & qGetReport.p_daytime3 />
                    <cfset record["p_memo3"]                  = "x" & qGetReport.p_memo3 />         
                    <cfset record["picture4"]                 = "x" & qGetReport.picture4 />
                    <cfset record["p_daytime4"]               = "x" & qGetReport.p_daytime4 />                  
                    <cfset record["p_memo4"]                  = "x" & qGetReport.p_memo4 />
                    <cfset record["decision_flag"]            = "x" & qGetReport.decision_flag />
                    
                    <cfset record["create_date"]              = "x" & qGetReport.create_date />
                    <cfset record["update_date"]              = "x" & qGetReport.update_date />
                    <cfset record["delete_flag"]              = "x" & qGetReport.del_flag />
        
                    <cfset ArrayAppend(dataset, record) />
                </cfloop>
            <cfreturn serializeJSON(dataset) >



<!--- 
            <cfloop index="cnt" from="1" to="#recordCount#">
                <cfset data = #qGetReport.unit_code[cnt]# & ","
                             & #qGetReport.slip_num[cnt]# & ","
                             & #qGetReport.work_date[cnt]# & ","
                             & #qGetReport.start_time[cnt]# & ","
                             & #qGetReport.end_time[cnt]# & ","
                             & #qGetReport.target_machinery[cnt]# & ","
                             & #qGetReport.client_code[cnt]# & ","
                             & #qGetReport.client_name[cnt]# & ","
                             & #qGetReport.name[cnt]# & ","

                             & #qGetReport.office_code[cnt]# & ","
                             & #qGetReport.office_short_name[cnt]# & ","

                             & #qGetReport.signature[cnt]# & ","
                             & #qGetReport.work_kubun[cnt]# & ","
                             & #qGetReport.claim_kubun[cnt]# & ","
                             & #qGetReport.work_fee[cnt]# & ","
                             & #qGetReport.freon_flag[cnt]# & ","
                             & #qGetReport.freon_type[cnt]# & ","
                             & #qGetReport.filling_amount[cnt]# & ","
                             & #qGetReport.uketsuke_contents[cnt]# & ","    

                             & #qGetReport.state_contents[cnt]# & ","
                             & #qGetReport.cause[cnt]# & ","
                             & #qGetReport.measures[cnt]# & ","
                             & #qGetReport.parts[cnt]# & ","
                             & #qGetReport.remarks[cnt]# & ","
                             & #qGetReport.finish_check[cnt]# & ","
                             & #qGetReport.work_men[cnt]# & ","
                             & #qGetReport.picture1[cnt]# & "," 

                             & #qGetReport.p_daytime1[cnt]# & ","
                             & #qGetReport.p_memo1[cnt]# & ","
                             & #qGetReport.picture2[cnt]# & ","
                             & #qGetReport.p_daytime2[cnt]# & ","
                             & #qGetReport.p_memo2[cnt]# & ","
                             & #qGetReport.picture3[cnt]# & ","
                             & #qGetReport.p_daytime3[cnt]# & ","
                             & #qGetReport.p_memo3[cnt]# & ","  

                             & #qGetReport.picture4[cnt]# & ","
                             & #qGetReport.p_daytime4[cnt]# & ","
                             & #qGetReport.p_memo4[cnt]# & ","
                             & #qGetReport.decision_flag[cnt]# & ","
                             & #qGetReport.create_date[cnt]# & ","
                             & #qGetReport.update_date[cnt]# & #chr(10)#>           
                <cfset output = #output# & #data#>
            </cfloop>
            <cfreturn #output# >

 --->




        </cffunction>







<!--- 
    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

            以下インポート

    ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
 --->



        <!--- 修理履歴 --->

        <!--- 
            ------------------------------------------------------------
                下からもらう引数　url.s_nm, url.c_cd, url.cs_cd
            ------------------------------------------------------------
         --->       
        <cffunction name="setTReport" access="remote" returnFormat="plain">
            <cfquery name="qInsLog" datasource="#application.dsn#" >
              INSERT INTO t_log (log_time,log)VALUES(now(),"1076行#url.s_nm#")
            </cfquery>
            <cfset folder_pass = application.report_dir>
            <cfset separater   = application.separater>
            
            <cfset client_code = url.cs_cd>
            <cfset slip_num    = url.s_nm>
            <cfset kaisya_code = url.c_cd>

            <cfif IsDefined("form.data") and form.data neq "">
                <cfset dt = DeserializeJSON(form.data)>


                <!--- 顧客のフォルダがなければ作成 --->
                <cfif DirectoryExists("#folder_pass##trim(dt.customer_code)#") eq false> 
                    <cfdirectory action = "create" directory = "#folder_pass##trim(dt.customer_code)#" mode ="777">  
                </cfif>
                <!--- 伝票番号のフォルダがなければ作成 --->             
                <cfif DirectoryExists("#folder_pass##trim(dt.customer_code)##separater##slip_num#") eq false> 
                    <cfdirectory action = "create" directory = "#folder_pass##trim(dt.customer_code)##separater##slip_num#" mode ="777">  
                </cfif>                 

                <cfif IsDefined("form.picture1") and #form.picture1# neq "">
                    <cffile action         = "upload"  
                            fileField      = "picture1"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#"  
                            accept         = "image/gif,image/jpeg,image/pjpeg,image/png,image/x-png"  
                            nameConflict   = "Overwrite">                               
                </cfif>

                <cfif IsDefined("form.picture2") and #form.picture2# neq "">
                    <cffile action         = "upload"  
                            fileField      = "picture2"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#"  
                            accept         = "image/gif,image/jpeg,image/pjpeg,image/png,image/x-png"  
                            nameConflict   = "Overwrite">                               
                </cfif>

                <cfif IsDefined("form.picture3") and #form.picture3# neq "">
                    <cffile action         = "upload"  
                            fileField      = "picture3"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#"  
                            accept         = "image/gif,image/jpeg,image/pjpeg,image/png,image/x-png"  
                            nameConflict   = "Overwrite">                               
                </cfif> 
                <cfif IsDefined("form.picture4") and #form.picture4# neq "">
                    <cffile action         = "upload"  
                            fileField      = "picture4"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#"  
                            accept         = "image/gif,image/jpeg,image/pjpeg,image/png,image/x-png"  
                            nameConflict   = "Overwrite">                               
                </cfif>
                <cfif IsDefined("form.signature") and #form.signature# neq "">
                    <cffile action         = "upload"  
                            fileField      = "signature"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#"  
                            accept         = "image/gif,image/jpeg,image/pjpeg,image/png,image/x-png"  
                            nameConflict   = "Overwrite">                               
                </cfif> 
                <cfif IsDefined("form.report_pdf") and #form.report_pdf# neq "">
                    <cffile action         = "upload"  
                            fileField      = "report_pdf"  
                            destination    = "#folder_pass##trim(dt.customer_code)##separater##slip_num#" 
                            nameConflict   = "Overwrite">                               
                </cfif> 




                
                <cfquery datasource="#application.dsn#" name="qGetReport">
                   SELECT slip_num
                     FROM t_report
                    WHERE t_report.kaisya_code = '#kaisya_code#'
                      AND t_report.slip_num = '#url.s_nm#'
                </cfquery>

                <cfif qGetReport.RecordCount LT 1>
                    
                    <cfquery datasource="#application.dsn#" name="qInsReport">
                        INSERT INTO t_report (

                            <cfif trim(dt.unit) neq "">unit_code,</cfif>
                            <cfif trim(dt.unit_name) neq "">unit_name,</cfif>
                            <cfif trim(dt.slip_num) neq "">slip_num,</cfif>
                            <cfif StructKeyExists(dt,"date") and trim(dt.date) neq "">work_date,origin_work_date,</cfif>
                            <cfif StructKeyExists(dt,"start_time") and trim(dt.start_time) neq "">start_time,origin_start_time,</cfif>
                            <cfif StructKeyExists(dt,"end_time") and trim(dt.end_time) neq "">end_time,origin_end_time,</cfif>
                            <cfif StructKeyExists(dt,"target_machinery") and trim(dt.target_machinery) neq "">target_machinery,origin_target_machinery,</cfif>
                            <cfif StructKeyExists(dt,"customer_code") and trim(dt.customer_code) neq "">client_code,</cfif>
                            <cfif StructKeyExists(dt,"customer_name") and trim(dt.customer_name) neq "">client_name,</cfif>
                            <cfif StructKeyExists(dt,"name") and trim(dt.name) neq "">name,origin_name,</cfif>
                            <cfif StructKeyExists(dt,"office_code") and trim(dt.office_code) neq "">office_code,origin_office_code,</cfif>
                            <cfif StructKeyExists(dt,"office_short_name") and trim(dt.office_short_name) neq "">office_short_name,</cfif>
                            <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) eq 1 and trim(dt.signature) neq "">signature,</cfif>
                            <cfif StructKeyExists(dt,"work_kubun") and trim(dt.work_kubun) neq "">work_kubun,origin_work_kubun,</cfif>
                            <cfif StructKeyExists(dt,"claim_kubun") and trim(dt.claim_kubun) neq "">claim_kubun,origin_claim_kubun,</cfif>
                            <cfif StructKeyExists(dt,"work_fee") and trim(dt.work_fee) neq "">work_fee,</cfif>
                            <cfif StructKeyExists(dt,"freon_flag") and trim(dt.freon_flag) neq "">freon_flag,origin_freon_flag,</cfif>
                            <cfif StructKeyExists(dt,"freon_flag2") and trim(dt.freon_flag2) neq "">freon_flag2,origin_freon_flag2,</cfif>
                            <cfif StructKeyExists(dt,"freon_type") and trim(dt.freon_type) neq "">freon_type,origin_freon_type,</cfif>
                            <cfif StructKeyExists(dt,"freon_type2") and trim(dt.freon_type2) neq "">freon_type2,origin_freon_type2,</cfif>
                            <cfif StructKeyExists(dt,"filling_amount") and trim(dt.filling_amount) neq "">filling_amount,origin_filling_amount,</cfif>
                            <cfif StructKeyExists(dt,"filling_amount2") and trim(dt.filling_amount2) neq "">filling_amount2,origin_filling_amount2,</cfif>
                            <cfif StructKeyExists(dt,"uketsuke_contents") and trim(dt.uketsuke_contents) neq "">uketsuke_contents,origin_uketsuke_contents,</cfif>
                            <cfif StructKeyExists(dt,"state_contents") and trim(dt.state_contents) neq "">state_contents,origin_state_contents,</cfif>
                            <cfif StructKeyExists(dt,"cause") and trim(dt.cause) neq "">cause,origin_cause,</cfif>
                            <cfif StructKeyExists(dt,"measures") and trim(dt.measures) neq "">measures,origin_measures,</cfif>
                            <cfif StructKeyExists(dt,"use_buhin") and trim(dt.use_buhin) neq "">parts,origin_parts,</cfif>
                            <cfif StructKeyExists(dt,"remarks") and trim(dt.remarks) neq "">remarks,origin_remarks,</cfif>
                            <cfif StructKeyExists(dt,"finish_check") and trim(dt.finish_check) neq "">finish_check,origin_finish_check,</cfif>
                            <cfif StructKeyExists(dt,"work_men") and trim(dt.work_men) neq "">work_men,origin_work_men,</cfif>

                            <cfif StructKeyExists(dt,"finish_check_item1") and trim(dt.finish_check_item1) neq "">finish_check_item1,origin_finish_check_item1,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_time1") and trim(dt.finish_check_time1) neq "">finish_check_time1,origin_finish_check_time1,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_name1") and trim(dt.finish_check_name1) neq "">finish_check_name1,origin_finish_check_name1,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_item2") and trim(dt.finish_check_item2) neq "">finish_check_item2,origin_finish_check_item2,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_time2") and trim(dt.finish_check_time2) neq "">finish_check_time2,origin_finish_check_time2,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_name2") and trim(dt.finish_check_name2) neq "">finish_check_name2,origin_finish_check_name2,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_item3") and trim(dt.finish_check_item3) neq "">finish_check_item3,origin_finish_check_item3,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_time3") and trim(dt.finish_check_time3) neq "">finish_check_time3,origin_finish_check_time3,</cfif>
                            <cfif StructKeyExists(dt,"finish_check_name3") and trim(dt.finish_check_name3) neq "">finish_check_name3,origin_finish_check_name3,</cfif>






                            <!---
                            <cfif StructKeyExists(dt,"modify_work_date") and trim(dt.modify_work_date) neq "">modify_work_date,</cfif>
                            <cfif StructKeyExists(dt,"modify_start_time") and trim(dt.modify_start_time) neq "">modify_start_time,</cfif>
                            <cfif StructKeyExists(dt,"modify_end_time") and trim(dt.modify_end_time) neq "">modify_end_time,</cfif>
                            <cfif StructKeyExists(dt,"modify_target_machinery") and trim(dt.modify_target_machinery) neq "">modify_target_machinery,</cfif>
                            <cfif StructKeyExists(dt,"modify_name") and trim(dt.modify_name) neq "">modify_name,</cfif>
                            <cfif StructKeyExists(dt,"modify_office_code") and trim(dt.modify_office_code) neq "">modify_office_code,</cfif>
                            <cfif StructKeyExists(dt,"modify_work_kubun") and trim(dt.modify_work_kubun) neq "">modify_work_kubun,</cfif>
                            <cfif StructKeyExists(dt,"modify_claim_kubun") and trim(dt.modify_claim_kubun) neq "">modify_claim_kubun,</cfif>
                            <cfif StructKeyExists(dt,"modify_freon_flag") and trim(dt.modify_freon_flag) neq "">modify_freon_flag,</cfif>
                            <cfif StructKeyExists(dt,"modify_freon_flag2") and trim(dt.modify_freon_flag2) neq "">modify_freon_flag2,</cfif>
                            <cfif StructKeyExists(dt,"modify_freon_type") and trim(dt.modify_freon_type) neq "">modify_freon_type,</cfif>
                            <cfif StructKeyExists(dt,"modify_freon_type2") and trim(dt.modify_freon_type2) neq "">modify_freon_type2,</cfif>
                            <cfif StructKeyExists(dt,"modify_filling_amount") and trim(dt.modify_filling_amount) neq "">modify_filling_amount,</cfif>
                            <cfif StructKeyExists(dt,"modify_filling_amount2") and trim(dt.modify_filling_amount2) neq "">modify_filling_amount2,</cfif>
                            <cfif StructKeyExists(dt,"modify_uketsuke_contents") and trim(dt.modify_uketsuke_contents) neq "">modify_uketsuke_contents,</cfif>
                            <cfif StructKeyExists(dt,"modify_state_contents") and trim(dt.modify_state_contents) neq "">modify_state_contents,</cfif>
                            <cfif StructKeyExists(dt,"modify_cause") and trim(dt.modify_cause) neq "">modify_cause,</cfif>
                            <cfif StructKeyExists(dt,"modify_measures") and trim(dt.modify_measures) neq "">modify_measures,</cfif>
                            <cfif StructKeyExists(dt,"modify_parts") and trim(dt.modify_parts) neq "">modify_parts,</cfif>
                            <cfif StructKeyExists(dt,"modify_remarks") and trim(dt.modify_remarks) neq "">modify_remarks,</cfif>
                            <cfif StructKeyExists(dt,"modify_finish_check") and trim(dt.modify_finish_check) neq "">modify_finish_check,</cfif>
                            <cfif StructKeyExists(dt,"modify_work_men") and trim(dt.modify_work_men) neq "">modify_work_men,</cfif>
                            <cfif StructKeyExists(dt,"confirm_name1") and trim(dt.confirm_name1) neq "">confirm_name1,</cfif>
                            <cfif StructKeyExists(dt,"confirm_day1") and trim(dt.confirm_day1) neq "">confirm_day1,</cfif>
                            <cfif StructKeyExists(dt,"confirm_name2") and trim(dt.confirm_name2) neq "">confirm_name2,</cfif>
                            <cfif StructKeyExists(dt,"confirm_day2") and trim(dt.confirm_day2) neq "">confirm_day2,</cfif>
                            --->


                            <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) neq "">which_made,</cfif>



                            <cfif StructKeyExists(dt,"picture1") and trim(dt.picture1) neq "">picture1,</cfif>
                            <cfif StructKeyExists(dt,"p_daytime1") and trim(dt.p_daytime1) neq "">p_daytime1,</cfif>
                            <cfif StructKeyExists(dt,"p_memo1") and trim(dt.p_memo1) neq "">p_memo1,</cfif>
                            <cfif StructKeyExists(dt,"picture2") and trim(dt.picture2) neq "">picture2,</cfif>
                            <cfif StructKeyExists(dt,"p_daytime2") and trim(dt.p_daytime2) neq "">p_daytime2,</cfif>
                            <cfif StructKeyExists(dt,"p_memo2") and trim(dt.p_memo2) neq "">p_memo2,</cfif>
                            <cfif StructKeyExists(dt,"picture3") and trim(dt.picture3) neq "">picture3,</cfif>
                            <cfif StructKeyExists(dt,"p_daytime3") and trim(dt.p_daytime3) neq "">p_daytime3,</cfif>
                            <cfif StructKeyExists(dt,"p_memo3") and trim(dt.p_memo3) neq "">p_memo3,</cfif>
                            <cfif StructKeyExists(dt,"picture4") and trim(dt.picture4) neq "">picture4,</cfif>
                            <cfif StructKeyExists(dt,"p_daytime4") and trim(dt.p_daytime4) neq "">p_daytime4,</cfif>
                            <cfif StructKeyExists(dt,"p_memo4") and trim(dt.p_memo4) neq "">p_memo4,</cfif>

                            <cfif StructKeyExists(dt,"decision_flag") and trim(dt.decision_flag) neq "">decision_flag,</cfif>
                            <cfif StructKeyExists(dt,"create_date") and trim(dt.create_date) neq "">create_date,</cfif>
                            <cfif StructKeyExists(dt,"create_name") and trim(dt.create_name) neq "">create_name,</cfif>
                            <!---
                            <cfif StructKeyExists(dt,"update_date") and trim(dt.update_date) neq "">update_date,</cfif>
                            --->
                            last_recv_datetime,
                            kaisya_code
                        ) VALUES (
                                        
                                <cfif trim(dt.unit) neq "">'#trim(dt.unit)#',</cfif>
                                <cfif trim(dt.unit_name) neq "">'#trim(dt.unit_name)#',</cfif>
                                <cfif trim(dt.slip_num) neq "">'#trim(dt.slip_num)#',</cfif>
                                <cfif StructKeyExists(dt,"date") and trim(dt.date) neq "">'#trim(dt.date)#','#trim(dt.date)#',</cfif>
                                <cfif StructKeyExists(dt,"start_time") and trim(dt.start_time) neq "">'1900/01/01 #trim(dt.start_time)#','1900/01/01 #trim(dt.start_time)#',</cfif>
                                <cfif StructKeyExists(dt,"end_time") and trim(dt.end_time) neq "">'1900/01/01 #trim(dt.end_time)#','1900/01/01 #trim(dt.end_time)#',</cfif>
                                <cfif StructKeyExists(dt,"target_machinery") and trim(dt.target_machinery) neq "">#trim(dt.target_machinery)#,#trim(dt.target_machinery)#,</cfif>
                                <cfif StructKeyExists(dt,"customer_code") and trim(dt.customer_code) neq "">"#trim(dt.customer_code)#",</cfif>
                                <cfif StructKeyExists(dt,"customer_name") and trim(dt.customer_name) neq "">"#trim(dt.customer_name)#",</cfif>
                                <cfif StructKeyExists(dt,"name") and trim(dt.name) neq "">"#trim(dt.name)#","#trim(dt.name)#",</cfif>
                                <cfif StructKeyExists(dt,"office_code") and trim(dt.office_code) neq "">"#trim(dt.office_code)#","#trim(dt.office_code)#",</cfif>
                                <cfif StructKeyExists(dt,"office_short_name") and trim(dt.office_short_name) neq "">"#trim(dt.office_short_name)#",</cfif>                          
                                <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) eq 1 and trim(dt.signature) neq "">"#trim(dt.signature)#",</cfif>
                                <cfif StructKeyExists(dt,"work_kubun") and trim(dt.work_kubun) neq "">#dt.work_kubun#,#dt.work_kubun#,</cfif>
                                <cfif StructKeyExists(dt,"claim_kubun") and trim(dt.claim_kubun) neq "">#dt.claim_kubun#,#dt.claim_kubun#,</cfif>
                                <cfif StructKeyExists(dt,"work_fee") and trim(dt.work_fee) neq "">#dt.work_fee#,</cfif>
                                <cfif StructKeyExists(dt,"freon_flag") and trim(dt.freon_flag) neq "">#dt.freon_flag#,#dt.freon_flag#,</cfif>
                                <cfif StructKeyExists(dt,"freon_flag2") and trim(dt.freon_flag2) neq "">#dt.freon_flag2#,#dt.freon_flag2#,</cfif>
                                <cfif StructKeyExists(dt,"freon_type") and trim(dt.freon_type) neq "">#dt.freon_type#,#dt.freon_type#,</cfif>
                                <cfif StructKeyExists(dt,"freon_type2") and trim(dt.freon_type2) neq "">#dt.freon_type2#,#dt.freon_type2#,</cfif>
                                <cfif StructKeyExists(dt,"filling_amount") and trim(dt.filling_amount) neq "">#dt.filling_amount#,#dt.filling_amount#,</cfif>
                                <cfif StructKeyExists(dt,"filling_amount2") and trim(dt.filling_amount2) neq "">#dt.filling_amount2#,#dt.filling_amount2#,</cfif>
                                <cfif StructKeyExists(dt,"uketsuke_contents") and trim(dt.uketsuke_contents) neq "">"#trim(dt.uketsuke_contents)#","#trim(dt.uketsuke_contents)#",</cfif>
                                <cfif StructKeyExists(dt,"state_contents") and trim(dt.state_contents) neq "">"#trim(dt.state_contents)#","#trim(dt.state_contents)#",</cfif>
                                <cfif StructKeyExists(dt,"cause") and trim(dt.cause) neq "">"#trim(dt.cause)#","#trim(dt.cause)#",</cfif>
                                <cfif StructKeyExists(dt,"measures") and trim(dt.measures) neq "">"#trim(dt.measures)#","#trim(dt.measures)#",</cfif>
                                <cfif StructKeyExists(dt,"use_buhin") and trim(dt.use_buhin) neq "">"#trim(dt.use_buhin)#","#trim(dt.use_buhin)#",</cfif>
                                <cfif StructKeyExists(dt,"remarks") and trim(dt.remarks) neq "">"#trim(dt.remarks)#","#trim(dt.remarks)#",</cfif>
                                <cfif StructKeyExists(dt,"finish_check") and trim(dt.finish_check) neq "">"#trim(dt.finish_check)#","#trim(dt.finish_check)#",</cfif>
                                <cfif StructKeyExists(dt,"work_men") and trim(dt.work_men) neq "">"#trim(dt.work_men)#","#trim(dt.work_men)#",</cfif>

                                <cfif StructKeyExists(dt,"finish_check_item1") and trim(dt.finish_check_item1) neq "">#dt.finish_check_item1#,#dt.finish_check_item1#,</cfif>
                                <cfif StructKeyExists(dt,"finish_check_time1") and trim(dt.finish_check_time1) neq "">'1900/01/01 #dt.finish_check_time1#','1900/01/01 #dt.finish_check_time1#',</cfif>
                                <cfif StructKeyExists(dt,"finish_check_name1") and trim(dt.finish_check_name1) neq "">'#dt.finish_check_name1#','#dt.finish_check_name1#',</cfif>
                                <cfif StructKeyExists(dt,"finish_check_item2") and trim(dt.finish_check_item2) neq "">#dt.finish_check_item2#,#dt.finish_check_item2#,</cfif>
                                <cfif StructKeyExists(dt,"finish_check_time2") and trim(dt.finish_check_time2) neq "">'1900/01/01 #dt.finish_check_time2#','1900/01/01 #dt.finish_check_time2#',</cfif>
                                <cfif StructKeyExists(dt,"finish_check_name2") and trim(dt.finish_check_name2) neq "">'#dt.finish_check_name2#','#dt.finish_check_name2#',</cfif>
                                <cfif StructKeyExists(dt,"finish_check_item3") and trim(dt.finish_check_item3) neq "">#dt.finish_check_item3#,#dt.finish_check_item3#,</cfif>
                                <cfif StructKeyExists(dt,"finish_check_time3") and trim(dt.finish_check_time3) neq "">'1900/01/01 #dt.finish_check_time3#','1900/01/01 #dt.finish_check_time3#',</cfif>
                                <cfif StructKeyExists(dt,"finish_check_name3") and trim(dt.finish_check_name3) neq "">'#dt.finish_check_name3#','#dt.finish_check_name3#',</cfif>




                                <!---
                                <cfif StructKeyExists(dt,"modify_work_date") and trim(dt.modify_work_date) neq "">"#trim(dt.modify_work_date)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_start_time") and trim(dt.modify_start_time) neq "">"#trim(dt.modify_start_time)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_end_time") and trim(dt.modify_end_time) neq "">"#trim(dt.modify_end_time)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_target_machinery") and trim(dt.modify_target_machinery) neq "">"#trim(dt.modify_target_machinery)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_name") and trim(dt.modify_name) neq "">"#trim(dt.modify_name)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_office_code") and trim(dt.modify_office_code) neq "">"#trim(dt.modify_office_code)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_work_kubun") and trim(dt.modify_work_kubun) neq "">"#trim(dt.modify_work_kubun)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_claim_kubun") and trim(dt.modify_claim_kubun) neq "">"#trim(dt.modify_claim_kubun)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_freon_flag") and trim(dt.modify_freon_flag) neq "">"#trim(dt.modify_freon_flag)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_freon_flag2") and trim(dt.modify_freon_flag2) neq "">"#trim(dt.modify_freon_flag2)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_freon_type") and trim(dt.modify_freon_type) neq "">"#trim(dt.modify_freon_type)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_freon_type2") and trim(dt.modify_freon_type2) neq "">"#trim(dt.modify_freon_type2)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_filling_amount") and trim(dt.modify_filling_amount) neq "">"#trim(dt.modify_filling_amount)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_filling_amount2") and trim(dt.modify_filling_amount2) neq "">"#trim(dt.modify_filling_amount2)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_uketsuke_contents") and trim(dt.modify_uketsuke_contents) neq "">"#trim(dt.modify_uketsuke_contents)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_state_contents") and trim(dt.modify_state_contents) neq "">"#trim(dt.modify_state_contents)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_cause") and trim(dt.modify_cause) neq "">"#trim(dt.modify_cause)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_measures") and trim(dt.modify_measures) neq "">"#trim(dt.modify_measures)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_parts") and trim(dt.modify_parts) neq "">"#trim(dt.modify_parts)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_remarks") and trim(dt.modify_remarks) neq "">"#trim(dt.modify_remarks)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_finish_check") and trim(dt.modify_finish_check) neq "">"#trim(dt.modify_finish_check)#",</cfif>
                                <cfif StructKeyExists(dt,"modify_work_men") and trim(dt.modify_work_men) neq "">"#trim(dt.modify_work_men)#",</cfif>
                                <cfif StructKeyExists(dt,"confirm_name1") and trim(dt.confirm_name1) neq "">"#trim(dt.confirm_name1)#",</cfif>
                                <cfif StructKeyExists(dt,"confirm_day1") and trim(dt.confirm_day1) neq "">"#trim(dt.confirm_day1)#",</cfif>
                                <cfif StructKeyExists(dt,"confirm_name2") and trim(dt.confirm_name2) neq "">"#trim(dt.confirm_name2)#",</cfif>
                                <cfif StructKeyExists(dt,"confirm_day2") and trim(dt.confirm_day2) neq "">"#trim(dt.confirm_day2)#",</cfif>
                                --->

                                <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) neq "">#trim(dt.which_made)#,</cfif>



                                <cfif StructKeyExists(dt,"picture1") and trim(dt.picture1) neq "">"#trim(dt.picture1)#",</cfif>
                                <cfif StructKeyExists(dt,"p_daytime1") and trim(dt.p_daytime1) neq "">'#trim(dt.p_daytime1)#',</cfif>
                                <cfif StructKeyExists(dt,"p_memo1") and trim(dt.p_memo1) neq "">"#trim(dt.p_memo1)#",</cfif>
                                <cfif StructKeyExists(dt,"picture2") and trim(dt.picture2) neq "">"#trim(dt.picture2)#",</cfif>
                                <cfif StructKeyExists(dt,"p_daytime2") and trim(dt.p_daytime2) neq "">'#trim(dt.p_daytime2)#',</cfif>
                                <cfif StructKeyExists(dt,"p_memo2") and trim(dt.p_memo2) neq "">"#trim(dt.p_memo2)#",</cfif>
                                <cfif StructKeyExists(dt,"picture3") and trim(dt.picture3) neq "">"#trim(dt.picture3)#",</cfif>
                                <cfif StructKeyExists(dt,"p_daytime3") and trim(dt.p_daytime3) neq "">'#trim(dt.p_daytime3)#',</cfif>
                                <cfif StructKeyExists(dt,"p_memo3") and trim(dt.p_memo3) neq "">"#trim(dt.p_memo3)#",</cfif>
                                <cfif StructKeyExists(dt,"picture4") and trim(dt.picture4) neq "">"#trim(dt.picture4)#",</cfif>
                                <cfif StructKeyExists(dt,"p_daytime4") and trim(dt.p_daytime4) neq "">'#trim(dt.p_daytime4)#',</cfif>
                                <cfif StructKeyExists(dt,"p_memo4") and trim(dt.p_memo4) neq "">"#trim(dt.p_memo4)#",</cfif>
                                <cfif StructKeyExists(dt,"decision_flag") and trim(dt.decision_flag) neq "">"#trim(dt.decision_flag)#",</cfif>
                                <cfif StructKeyExists(dt,"create_date") and trim(dt.create_date) neq "">"#trim(dt.create_date)#",</cfif>
                                <cfif StructKeyExists(dt,"create_name") and trim(dt.create_name) neq "">"#trim(dt.create_name)#",</cfif>
                                <!---
                                <cfif StructKeyExists(dt,"update_date") and trim(dt.update_date) neq "">"#trim(dt.update_date)#",</cfif>
                                --->
                                now(),                                      
                                '#kaisya_code#'

                                )
                    </cfquery>

                    <cfquery datasource="#application.dsn#" name="qGetMailAddress">
                       SELECT mail
                         FROM m_emp
                        WHERE m_emp.kaisya_code = '#kaisya_code#'
                          AND m_emp.section_code = "#trim(dt.office_code)#"
                          AND (m_emp.role1 = 1
                          OR m_emp.role2 = 1)
                    </cfquery>

                    <cfif qGetMailAddress.RecordCount GTE 1>
                        <cfset to = "">
                        <cfset subject = "【#application.app_name#】作業報告書">
                        <cfloop index="i" from="1" to="#qGetMailAddress.RecordCount#">
                            <cfif i neq qGetMailAddress.RecordCount>
                                <cfset to = to & qGetMailAddress.mail[i] & ",">
                            <cfelse>
                                <cfset to = to & qGetMailAddress.mail[i]>   
                            </cfif>
                            
                        </cfloop>

<cftry>
    

    <cfmail 
 from="no_riplies"
 to="#to#"
 useSSL="true"
 useTLS="true"
 subject= "#subject#"
 server="smtp.gmail.com"
 port="465"
 username="#application.user_name#"
 password="#application.password#"
>
---------------------------------------------------------------------
このメールは#application.app_name#のシステムより自動送信されています。
---------------------------------------------------------------------

作業報告書が新規に作成されました。
システムにログインして内容を確認し、捺印してください。

【#application.app_name#】
#application.server_url#/i_mainte_center/login.cfm

---------------------------------------------------------------------

※報告書の概略
【報告者】#trim(dt.name)#
【伝票No.】#trim(dt.slip_num)#                             
【作業日】#trim(dt.date)#
【お得意先名】#trim(dt.customer_name)#
【ユニット】#trim(dt.unit_name)#
【受付内容】
#trim(dt.uketsuke_contents)#
【処置】
#trim(dt.measures)#

    </cfmail>
    <cfcatch>
        <cfset error = cfcatch.message>
    </cfcatch>
</cftry>

                    </cfif>

                <cfelse>
                    <cfquery datasource="#application.dsn#" name="qUpdReport">
                        UPDATE t_report 
                           SET

                            modify_work_date = (CASE WHEN "#trim(dt.date)#" <> work_date 
                                                      AND "#trim(dt.date)#" <> origin_work_date
                                                     THEN now()
                                                      WHEN "#trim(dt.date)#" = origin_work_date
                                                      THEN NULL                                                    
                                                      ELSE modify_work_date
                                                END),
                            modify_start_time = (CASE WHEN "1900/01/01 #trim(dt.start_time)#" <> start_time 
                                                       AND "1900/01/01 #trim(dt.start_time)#" <> origin_start_time
                                                      THEN now()
                                                      WHEN "1900/01/01 #trim(dt.start_time)#" = origin_start_time
                                                      THEN NULL                                                    
                                                      ELSE modify_start_time
                                                 END),
                            modify_end_time = (CASE WHEN "1900/01/01 #trim(dt.end_time)#" <> end_time 
                                                      AND "1900/01/01 #trim(dt.end_time)#" <> origin_end_time
                                                     THEN now()
                                                     WHEN "1900/01/01 #trim(dt.end_time)#" = origin_end_time
                                                     THEN NULL                                                     
                                                     ELSE modify_end_time
                                               END),
                            
                            modify_target_machinery = (CASE WHEN #trim(dt.target_machinery)# <> target_machinery 
                                                             AND #trim(dt.target_machinery)# <> origin_target_machinery
                                                            THEN now()
                                                            WHEN #trim(dt.target_machinery)# = origin_target_machinery
                                                            THEN NULL                                                      
                                                            ELSE modify_target_machinery
                                                       END),


                            modify_office_code = (CASE WHEN "#trim(dt.office_code)#" <> office_code 
                                                        AND "#trim(dt.office_code)#" <> origin_office_code
                                                       THEN now()
                                                       WHEN "#trim(dt.office_code)#" = origin_office_code
                                                       THEN NULL                                                       
                                                       ELSE modify_office_code
                                                  END),
                            modify_work_kubun = (CASE WHEN #trim(dt.work_kubun)# <> work_kubun 
                                                       AND #trim(dt.work_kubun)# <> origin_work_kubun
                                                      THEN now()
                                                      WHEN #trim(dt.work_kubun)# = origin_work_kubun
                                                      THEN NULL                                                    
                                                      ELSE modify_work_kubun
                                                 END),
                            modify_claim_kubun = (CASE WHEN #trim(dt.claim_kubun)# <> claim_kubun 
                                                       AND #trim(dt.claim_kubun)# <> origin_claim_kubun
                                                      THEN now()
                                                      WHEN #trim(dt.claim_kubun)# = origin_claim_kubun
                                                      THEN NULL                                                    
                                                      ELSE modify_claim_kubun
                                                 END),
                            <cfif trim(dt.name) neq "">
                                modify_name = (CASE WHEN origin_name IS NULL
                                                            OR ("#trim(dt.name)#" <> name 
                                                                AND "#trim(dt.name)#" <> origin_name)
                                                          THEN now()
                                                          WHEN "#trim(dt.name)#" = origin_name
                                                          THEN NULL                                                    
                                                          ELSE modify_name
                                                     END),
                            <cfelse>
                                modify_name = (CASE WHEN name IS NOT NULL
                                                     AND origin_name IS NOT NULL
                                                    THEN now()
                                                    ELSE NULL
                                                     END),                              
                            </cfif>

                            <cfif trim(dt.freon_flag) neq "">
                                modify_freon_flag = (CASE WHEN origin_freon_flag IS NULL
                                                            OR (#trim(dt.freon_flag)# <> freon_flag 
                                                                AND #trim(dt.freon_flag)# <> origin_freon_flag)
                                                          THEN now()
                                                          WHEN #trim(dt.freon_flag)# = origin_freon_flag
                                                          THEN NULL                                                    
                                                          ELSE modify_freon_flag
                                                     END),
                            <cfelse>
                                modify_freon_flag = (CASE WHEN freon_flag IS NOT NULL
                                                           AND origin_freon_flag IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>
                            <cfif trim(dt.freon_flag2) neq "">
                                modify_freon_flag2 = (CASE WHEN origin_freon_flag2 IS NULL
                                                            OR (#trim(dt.freon_flag2)# <> freon_flag2 
                                                                AND #trim(dt.freon_flag2)# <> origin_freon_flag2)
                                                          THEN now()
                                                          WHEN #trim(dt.freon_flag2)# = origin_freon_flag2
                                                          THEN NULL                                                    
                                                          ELSE modify_freon_flag2
                                                     END),
                            <cfelse>
                                modify_freon_flag2 = (CASE WHEN freon_flag2 IS NOT NULL
                                                           AND origin_freon_flag2 IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>

                            <cfif trim(dt.freon_type) neq "">
                                modify_freon_type = (CASE WHEN origin_freon_type IS NULL
                                                            OR (#trim(dt.freon_type)# <> freon_type 
                                                                AND #trim(dt.freon_type)# <> origin_freon_type)
                                                          THEN now()
                                                          WHEN #trim(dt.freon_type)# = origin_freon_type
                                                          THEN NULL                                                    
                                                          ELSE modify_freon_type
                                                     END),
                            <cfelse>
                                modify_freon_type = (CASE WHEN freon_type IS NOT NULL
                                                           AND origin_freon_type IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>

                            <cfif trim(dt.freon_type2) neq "">
                                modify_freon_type2 = (CASE WHEN origin_freon_type2 IS NULL
                                                            OR (#trim(dt.freon_type2)# <> freon_type2 
                                                                AND #trim(dt.freon_type2)# <> origin_freon_type2)
                                                          THEN now()
                                                          WHEN #trim(dt.freon_type2)# = origin_freon_type2
                                                          THEN NULL                                                    
                                                          ELSE modify_freon_type2
                                                     END),
                            <cfelse>
                                modify_freon_type2 = (CASE WHEN freon_type2 IS NOT NULL
                                                           AND origin_freon_type2 IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>


                            <cfif trim(dt.filling_amount) neq "">
                                modify_filling_amount = (CASE WHEN origin_filling_amount IS NULL
                                                            OR (#trim(dt.filling_amount)# <> filling_amount 
                                                                AND #trim(dt.filling_amount)# <> origin_filling_amount)
                                                          THEN now()
                                                          WHEN #trim(dt.filling_amount)# = origin_filling_amount
                                                          THEN NULL                                                    
                                                          ELSE modify_filling_amount
                                                     END),
                            <cfelse>
                                modify_filling_amount = (CASE WHEN filling_amount IS NOT NULL
                                                           AND origin_filling_amount IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>


                            <cfif trim(dt.filling_amount2) neq "">
                                modify_filling_amount2 = (CASE WHEN origin_filling_amount2 IS NULL
                                                            OR (#trim(dt.filling_amount2)# <> freon_type2 
                                                                AND #trim(dt.filling_amount2)# <> origin_filling_amount2)
                                                          THEN now()
                                                          WHEN #trim(dt.filling_amount2)# = origin_filling_amount2
                                                          THEN NULL                                                    
                                                          ELSE modify_filling_amount2
                                                     END),
                            <cfelse>
                                modify_filling_amount2 = (CASE WHEN filling_amount2 IS NOT NULL
                                                           AND origin_filling_amount2 IS NOT NULL
                                                          THEN now()
                                                          ELSE NULL
                                                     END),                              
                            </cfif>



                            <cfif trim(dt.uketsuke_contents) neq "">
                                modify_uketsuke_contents = (CASE WHEN origin_uketsuke_contents IS NULL OR 
                                                                    ("#trim(dt.uketsuke_contents)#" <> uketsuke_contents 
                                                                    AND "#trim(dt.uketsuke_contents)#" <> origin_uketsuke_contents)
                                                                 THEN now()
                                                                 WHEN "#trim(dt.uketsuke_contents)#" = origin_uketsuke_contents
                                                                 THEN NULL                                                     
                                                                 ELSE modify_uketsuke_contents
                                                            END),
                            <cfelse>
                                modify_uketsuke_contents = (CASE WHEN uketsuke_contents IS NOT NULL
                                                                  AND origin_uketsuke_contents IS NOT NULL
                                                                 THEN now()
                                                                 ELSE NULL
                                                            END),                       
                            </cfif>
                            <cfif trim(dt.state_contents) neq "">
                                modify_state_contents = (CASE WHEN origin_state_contents IS NULL OR
                                                              ("#trim(dt.state_contents)#" <> state_contents 
                                                                    AND "#trim(dt.state_contents)#" <> origin_state_contents)
                                                              THEN now()
                                                              WHEN "#trim(dt.state_contents)#" = origin_state_contents
                                                              THEN NULL                                                    
                                                              ELSE modify_state_contents
                                                        END),
                            <cfelse>
                                modify_state_contents = (CASE WHEN origin_state_contents IS NOT NULL
                                                               AND origin_state_contents IS NOT NULL
                                                              THEN now()
                                                              ELSE NULL
                                                         END),                              
                            </cfif>

                            <cfif trim(dt.cause) neq "">
                                modify_cause = (CASE WHEN origin_cause IS NULL OR
                                                      ("#trim(dt.cause)#" <> cause 
                                                            AND "#trim(dt.cause)#" <> origin_cause)
                                                      THEN now()
                                                      WHEN "#trim(dt.cause)#" = origin_cause
                                                      THEN NULL                                                    
                                                      ELSE modify_cause
                                                END),
                            <cfelse>
                                modify_cause = (CASE WHEN origin_cause IS NOT NULL
                                                      AND origin_cause IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <cfif trim(dt.measures) neq "">
                                modify_measures = (CASE WHEN origin_measures IS NULL OR
                                                      ("#trim(dt.measures)#" <> measures 
                                                            AND "#trim(dt.measures)#" <> origin_measures)
                                                      THEN now()
                                                      WHEN "#trim(dt.measures)#" = origin_measures
                                                      THEN NULL                                                    
                                                      ELSE modify_measures
                                                END),
                            <cfelse>
                                modify_measures = (CASE WHEN origin_measures IS NOT NULL
                                                      AND origin_measures IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif trim(dt.use_buhin) neq "">
                                modify_parts = (CASE WHEN origin_parts IS NULL OR
                                                      ("#trim(dt.use_buhin)#" <> parts 
                                                            AND "#trim(dt.use_buhin)#" <> origin_parts)
                                                      THEN now()
                                                      WHEN "#trim(dt.use_buhin)#" = origin_parts
                                                      THEN NULL                                                    
                                                      ELSE modify_parts
                                                END),
                            <cfelse>
                                modify_parts = (CASE WHEN origin_parts IS NOT NULL
                                                      AND origin_parts IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif trim(dt.remarks) neq "">
                                modify_remarks = (CASE WHEN origin_remarks IS NULL OR
                                                      ("#trim(dt.remarks)#" <> remarks 
                                                            AND "#trim(dt.remarks)#" <> origin_remarks)
                                                      THEN now()
                                                      WHEN "#trim(dt.remarks)#" = origin_remarks
                                                      THEN NULL                                                    
                                                      ELSE modify_remarks
                                                END),
                            <cfelse>
                                modify_remarks = (CASE WHEN origin_remarks IS NOT NULL
                                                      AND origin_remarks IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif trim(dt.finish_check) neq "">
                                modify_finish_check = (CASE WHEN origin_finish_check IS NULL OR
                                                      ("#trim(dt.finish_check)#" <> finish_check 
                                                            AND "#trim(dt.finish_check)#" <> origin_finish_check)
                                                      THEN now()
                                                      WHEN "#trim(dt.finish_check)#" = origin_finish_check
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check
                                                END),
                            <cfelse>
                                modify_finish_check = (CASE WHEN origin_finish_check IS NOT NULL
                                                      AND origin_finish_check IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif trim(dt.work_men) neq "">
                                modify_work_men = (CASE WHEN origin_work_men IS NULL OR
                                                      ("#trim(dt.work_men)#" <> work_men 
                                                            AND "#trim(dt.work_men)#" <> origin_work_men)
                                                      THEN now()
                                                      WHEN "#trim(dt.work_men)#" = origin_work_men
                                                      THEN NULL                                                    
                                                      ELSE modify_work_men
                                                END),
                            <cfelse>
                                modify_work_men = (CASE WHEN origin_work_men IS NOT NULL
                                                      AND origin_work_men IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <!---finish_check系はアップデートなし--->
                            <!---
                            <cfif StructKeyExists(dt,"finish_check_item1") and trim(dt.finish_check_item1) neq "">
                                modify_finish_check_item1 = (CASE WHEN origin_finish_check_item1 IS NULL OR
                                                      (#trim(dt.finish_check_item1)# <> finish_check_item1 
                                                            AND #trim(dt.finish_check_item1)# <> origin_finish_check_item1)
                                                      THEN now()
                                                      WHEN #trim(dt.finish_check_item1)# = origin_finish_check_item1
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_item1
                                                END),
                            <cfelse>
                                modify_finish_check_item1 = (CASE WHEN origin_finish_check_item1 IS NOT NULL
                                                      AND origin_finish_check_item1 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif StructKeyExists(dt,"finish_check_item2") and trim(dt.finish_check_item2) neq "">
                                modify_finish_check_item2 = (CASE WHEN origin_finish_check_item2 IS NULL OR
                                                      (#trim(dt.finish_check_item2)# <> finish_check_item2 
                                                            AND #trim(dt.finish_check_item2)# <> origin_finish_check_item2)
                                                      THEN now()
                                                      WHEN #trim(dt.finish_check_item2)# = origin_finish_check_item2
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_item2
                                                END),
                            <cfelse>
                                modify_finish_check_item2 = (CASE WHEN origin_finish_check_item2 IS NOT NULL
                                                      AND origin_finish_check_item2 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>


                            <cfif StructKeyExists(dt,"finish_check_item3") and trim(dt.finish_check_item3) neq "">
                                modify_finish_check_item3 = (CASE WHEN origin_finish_check_item3 IS NULL OR
                                                      (#trim(dt.finish_check_item3)# <> finish_check_item3 
                                                            AND #trim(dt.finish_check_item3)# <> origin_finish_check_item3)
                                                      THEN now()
                                                      WHEN #trim(dt.finish_check_item3)# = origin_finish_check_item3
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_item3
                                                END),
                            <cfelse>
                                modify_finish_check_item3 = (CASE WHEN origin_finish_check_item3 IS NOT NULL
                                                      AND origin_finish_check_item3 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>


                            <cfif StructKeyExists(dt,"finish_check_time1") and trim(dt.finish_check_time1) neq "">
                                modify_finish_check_time1 = (CASE WHEN '1900/01/01 #trim(dt.finish_check_time1)#' <> finish_check_time1 
                                                           AND '1900/01/01 #trim(dt.finish_check_time1)#' <> origin_finish_check_time1
                                                          THEN now()
                                                          WHEN '#trim(dt.finish_check_time1)#' = origin_finish_check_time1
                                                          THEN NULL                                                    
                                                          ELSE modify_finish_check_time1
                                                     END),
                            <cfelse>
                                modify_finish_check_time1 = (CASE WHEN origin_finish_check_time1 IS NOT NULL
                                                      AND origin_finish_check_time1 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <cfif StructKeyExists(dt,"finish_check_time2") and trim(dt.finish_check_time2) neq "">
                                modify_finish_check_time2 = (CASE WHEN '1900/01/01 #trim(dt.finish_check_time2)#' <> finish_check_time2 
                                                           AND '1900/01/01 #trim(dt.finish_check_time2)#' <> origin_finish_check_time2
                                                          THEN now()
                                                          WHEN '#trim(dt.finish_check_time2)#' = origin_finish_check_time2
                                                          THEN NULL                                                    
                                                          ELSE modify_finish_check_time2
                                                     END),
                            <cfelse>
                                modify_finish_check_time2 = (CASE WHEN origin_finish_check_time2 IS NOT NULL
                                                      AND origin_finish_check_time2 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <cfif StructKeyExists(dt,"finish_check_time3") and trim(dt.finish_check_time3) neq "">
                                modify_finish_check_time3 = (CASE WHEN '1900/01/01 #trim(dt.finish_check_time3)#' <> finish_check_time3 
                                                           AND '1900/01/01 #trim(dt.finish_check_time3)#' <> origin_finish_check_time3
                                                          THEN now()
                                                          WHEN '#trim(dt.finish_check_time3)#' = origin_finish_check_time3
                                                          THEN NULL                                                    
                                                          ELSE modify_finish_check_time3
                                                     END),
                            <cfelse>
                                modify_finish_check_time3 = (CASE WHEN origin_finish_check_time3 IS NOT NULL
                                                      AND origin_finish_check_time3 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>


                            <cfif StructKeyExists(dt,"finish_check_time1") and trim(dt.finish_check_time1) neq "">
                                modify_finish_check_time1 = (CASE WHEN origin_finish_check_time1 IS NULL OR
                                                      ("#trim(dt.finish_check_time1)#" <> finish_check_time1 
                                                            AND "#trim(dt.finish_check_time1)#" <> origin_finish_check_time1)
                                                      THEN now()
                                                      WHEN "#trim(dt.finish_check_time1)#" = origin_finish_check_time1
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_time1
                                                END),
                            <cfelse>
                                modify_finish_check_time1 = (CASE WHEN origin_finish_check_time1 IS NOT NULL
                                                      AND origin_finish_check_time1 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>

                            <cfif StructKeyExists(dt,"finish_check_name1") and trim(dt.finish_check_name1) neq "">
                                modify_finish_check_name1 = (CASE WHEN origin_finish_check_name1 IS NULL OR
                                                      ("#trim(dt.finish_check_name1)#" <> finish_check_name1 
                                                            AND "#trim(dt.finish_check_name1)#" <> origin_finish_check_name1)
                                                      THEN now()
                                                      WHEN "#trim(dt.finish_check_name1)#" = origin_finish_check_name1
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_name1
                                                END),
                            <cfelse>
                                modify_finish_check_name1 = (CASE WHEN origin_finish_check_name1 IS NOT NULL
                                                      AND origin_finish_check_name1 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <cfif StructKeyExists(dt,"finish_check_name2") and trim(dt.finish_check_name2) neq "">
                                modify_finish_check_name2 = (CASE WHEN origin_finish_check_name2 IS NULL OR
                                                      ("#trim(dt.finish_check_name2)#" <> finish_check_name2 
                                                            AND "#trim(dt.finish_check_name2)#" <> origin_finish_check_name2)
                                                      THEN now()
                                                      WHEN "#trim(dt.finish_check_name2)#" = origin_finish_check_name2
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_name2
                                                END),
                            <cfelse>
                                modify_finish_check_name2 = (CASE WHEN origin_finish_check_name2 IS NOT NULL
                                                      AND origin_finish_check_name2 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            <cfif StructKeyExists(dt,"finish_check_name3") and trim(dt.finish_check_name3) neq "">
                                modify_finish_check_name3 = (CASE WHEN origin_finish_check_name3 IS NULL OR
                                                      ("#trim(dt.finish_check_name3)#" <> finish_check_name3 
                                                            AND "#trim(dt.finish_check_name3)#" <> origin_finish_check_name3)
                                                      THEN now()
                                                      WHEN "#trim(dt.finish_check_name3)#" = origin_finish_check_name3
                                                      THEN NULL                                                    
                                                      ELSE modify_finish_check_name3
                                                END),
                            <cfelse>
                                modify_finish_check_name3 = (CASE WHEN origin_finish_check_name3 IS NOT NULL
                                                      AND origin_finish_check_name3 IS NOT NULL
                                                     THEN now()
                                                     ELSE NULL
                                                END),                               
                            </cfif>
                            --->



                            work_date         = <cfif trim(dt.date) neq "">'#trim(dt.date)#',</cfif>
                            start_time        = <cfif trim(dt.start_time) neq "">'1900/01/01 #trim(dt.start_time)#',<cfelse>null,</cfif>
                            end_time          = <cfif trim(dt.end_time) neq "">'1900/01/01 #trim(dt.end_time)#',<cfelse>null,</cfif>
                            target_machinery  = <cfif trim(dt.target_machinery) neq "">#trim(dt.target_machinery)#,<cfelse>null,</cfif>
                            client_code       = <cfif trim(dt.customer_code) neq "">"#trim(dt.customer_code)#",<cfelse>null,</cfif>
                            client_name       = <cfif trim(dt.customer_name) neq "">"#trim(dt.customer_name)#",<cfelse>null,</cfif>
                            
                            name              = <cfif trim(dt.name) neq "">"#trim(dt.name)#",<cfelse>null,</cfif>
                            office_code       = <cfif trim(dt.office_code) neq "">"#trim(dt.office_code)#",<cfelse>null,</cfif>
                            office_short_name = <cfif trim(dt.office_short_name) neq "">"#trim(dt.office_short_name)#",<cfelse>null,</cfif>
                            
                            
                            
                            work_kubun        = <cfif trim(dt.work_kubun) neq "">#trim(dt.work_kubun)#,<cfelse>null,</cfif>
                            claim_kubun       = <cfif trim(dt.claim_kubun) neq "">#trim(dt.claim_kubun)#,<cfelse>null,</cfif>
                            work_fee          = <cfif trim(dt.work_fee) neq "">#trim(dt.work_fee)#,<cfelse>null,</cfif>
                            freon_flag        = <cfif trim(dt.freon_flag) neq "">#trim(dt.freon_flag)#,<cfelse>null,</cfif>
                            freon_flag2        = <cfif trim(dt.freon_flag2) neq "">#trim(dt.freon_flag2)#,<cfelse>null,</cfif>
                            freon_type        = <cfif trim(dt.freon_type) neq "">#trim(dt.freon_type)#,<cfelse>null,</cfif>
                            freon_type2        = <cfif trim(dt.freon_type2) neq "">#trim(dt.freon_type2)#,<cfelse>null,</cfif>
                            filling_amount    = <cfif trim(dt.filling_amount) neq "">#trim(dt.filling_amount)#,<cfelse>null,</cfif>
                            filling_amount2    = <cfif trim(dt.filling_amount2) neq "">#trim(dt.filling_amount2)#,<cfelse>null,</cfif>
                            uketsuke_contents = <cfif trim(dt.uketsuke_contents) neq "">"#trim(dt.uketsuke_contents)#",<cfelse>null,</cfif>
                            state_contents    = <cfif trim(dt.state_contents) neq "">"#trim(dt.state_contents)#",<cfelse>null,</cfif>
                            cause             = <cfif trim(dt.cause) neq "">"#trim(dt.cause)#",<cfelse>null,</cfif>
                            measures          = <cfif trim(dt.measures) neq "">"#trim(dt.measures)#",<cfelse>null,</cfif>
                            parts             = <cfif trim(dt.use_buhin) neq "">"#trim(dt.use_buhin)#",<cfelse>null,</cfif>
                            remarks           = <cfif trim(dt.remarks) neq "">"#trim(dt.remarks)#",<cfelse>null,</cfif>
                            finish_check      = <cfif trim(dt.finish_check) neq "">"#trim(dt.finish_check)#",<cfelse>null,</cfif>
                            work_men          = <cfif trim(dt.work_men) neq "">"#trim(dt.work_men)#",<cfelse>null,</cfif>




                        <!---

                            confirm_name1 = (CASE WHEN "#trim(dt.confirm_name1)#" <> confirm_name1 
                                                        AND "#trim(dt.confirm_name1)#" <> origin_confirm_name1
                                                       THEN now()
                                                       ELSE NULL
                                                  END)
                            confirm_day1 = (CASE WHEN "#trim(dt.confirm_day1)#" <> confirm_day1 
                                                        AND "#trim(dt.confirm_day1)#" <> origin_confirm_day1
                                                       THEN now()
                                                       ELSE NULL
                                                  END)
                            confirm_name2 = (CASE WHEN "#trim(dt.confirm_name2)#" <> confirm_name2 
                                                        AND "#trim(dt.confirm_name2)#" <> origin_confirm_name2
                                                       THEN now()
                                                       ELSE NULL
                                                  END)
                            confirm_day2 = (CASE WHEN "#trim(dt.confirm_day2)#" <> confirm_day2 
                                                        AND "#trim(dt.confirm_day2)#" <> origin_confirm_day2
                                                       THEN now()
                                                       ELSE NULL
                                                  END)
                            --->
                            <!---
                            <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) neq "">
                                which_made = #trim(dt.which_made)#,
                            <cfelse>
                                which_made = 1,
                            </cfif>
                             --->

                            <cfif StructKeyExists(dt,"which_made") and trim(dt.which_made) eq 1>
                                signature         = <cfif trim(dt.signature) neq "">"#trim(dt.signature)#",<cfelse>null,</cfif>
                                picture1          = <cfif StructKeyExists(dt,"picture1") and trim(dt.picture1) neq "">"#trim(dt.picture1)#",<cfelse>null,</cfif>
                                p_daytime1        = <cfif StructKeyExists(dt,"p_daytime1") and trim(dt.p_daytime1) neq "">'#trim(dt.p_daytime1)#',<cfelse>null,</cfif>
                                p_memo1           = <cfif StructKeyExists(dt,"p_memo1") and trim(dt.p_memo1) neq "">"#trim(dt.p_memo1)#",<cfelse>null,</cfif>
                                picture2          = <cfif StructKeyExists(dt,"picture2") and trim(dt.picture2) neq "">"#trim(dt.picture2)#",<cfelse>null,</cfif>
                                p_daytime2        = <cfif StructKeyExists(dt,"p_daytime2") and trim(dt.p_daytime2) neq "">'#trim(dt.p_daytime2)#',<cfelse>null,</cfif>
                                p_memo2           = <cfif StructKeyExists(dt,"p_memo2") and trim(dt.p_memo2) neq "">"#trim(dt.p_memo2)#",<cfelse>null,</cfif>
                                picture3          = <cfif StructKeyExists(dt,"picture3") and trim(dt.picture3) neq "">"#trim(dt.picture3)#",<cfelse>null,</cfif>
                                p_daytime3        = <cfif StructKeyExists(dt,"p_daytime3") and trim(dt.p_daytime3) neq "">'#trim(dt.p_daytime3)#',<cfelse>null,</cfif>
                                p_memo3           = <cfif StructKeyExists(dt,"p_memo3") and trim(dt.p_memo3) neq "">"#trim(dt.p_memo3)#",<cfelse>null,</cfif>
                                picture4          = <cfif StructKeyExists(dt,"picture4") and trim(dt.picture4) neq "">"#trim(dt.picture4)#",<cfelse>null,</cfif>
                                p_daytime4        = <cfif StructKeyExists(dt,"p_daytime4") and trim(dt.p_daytime4) neq "">'#trim(dt.p_daytime4)#',<cfelse>null,</cfif>
                                p_memo4           = <cfif StructKeyExists(dt,"p_memo4") and trim(dt.p_memo4) neq "">"#trim(dt.p_memo4)#",<cfelse>null,</cfif>
                            </cfif>
                            decision_flag     = <cfif StructKeyExists(dt,"decision_flag") and trim(dt.decision_flag) neq "">#trim(dt.decision_flag)#,<cfelse>0,</cfif>
                            update_date       = <cfif StructKeyExists(dt,"update_date") and trim(dt.update_date) neq "">"#trim(dt.update_date)#",<cfelse>null,</cfif>
                            update_name       = <cfif StructKeyExists(dt,"update_name") and trim(dt.update_name) neq "">"#trim(dt.update_name)#",<cfelse>null,</cfif>
                            last_recv_datetime = now()
                    WHERE kaisya_code = "#kaisya_code#" 
                      AND slip_num    = "#slip_num#"
                    </cfquery>


                    <!--- 更新の場合はフロン証明書を作らない --->
                    <cfreturn 1>                    
                </cfif>

        <!--- 
            ------------------------------------------------------------
                ここからフロン証明書の処理


                ■証明書の採番ルール
                ・8桁。
                ・最初の2桁が西暦の下２桁。例：2015年は15。
                ・次の2桁が事業所コードの下２桁。例：KN83(関東PM)は83。
                ・次の1桁は、「1」が充填、「2」が回収。
                ・最後の３桁は001からの通し番号。
                ※最後の３桁は西暦ごと、事業所ごと、充填、回収ごとに001から採番。

            ------------------------------------------------------------
         --->

                
                <cfset reibai_count = 0>
                <cfset reibai_count2 = 0>
                <!--- 冷媒の充填か回収があった場合 --->
                <cfif #trim(dt.freon_flag)# eq 1 or #trim(dt.freon_flag2)# eq 1>
                    
                    <cfif #trim(dt.freon_type)# neq "">
                        <cfquery datasource="#application.dsn#" name="qGetReibai">
                           SELECT m_reibai.reibai_kind,
                                  m_reibai.gwp
                             FROM m_reibai
                            WHERE m_reibai.kaisya_code = '#kaisya_code#'
                              AND m_reibai.freon_flag = 1
                              AND m_reibai.reibai_id = IFNULL(#trim(dt.freon_type)#,"")
                        </cfquery>
                        <cfset reibai_count = qGetReibai.RecordCount>
                    </cfif>

                    <cfif #trim(dt.freon_type2)# neq "">
                        <cfquery datasource="#application.dsn#" name="qGetReibai2">
                           SELECT m_reibai.reibai_kind,
                                  m_reibai.gwp
                             FROM m_reibai
                            WHERE m_reibai.kaisya_code = '#kaisya_code#'
                              AND m_reibai.freon_flag = 1
                              AND m_reibai.reibai_id = IFNULL(#trim(dt.freon_type2)#,"")
                        </cfquery>
                        <cfset reibai_count2 = qGetReibai2.RecordCount>
                    </cfif>             

                    <!--- フロンの場合 --->
                    <cfif reibai_count GTE 1 OR reibai_count2 GTE 1>
                        <cfset today = #DateFormat(Now(), "yyyy/mm/dd")#>

                        <cfset looop_count = 1>
                        <cfset cnum1 = #Mid(today,3,2)#>
                        <cfset cnum2 = #Right(trim(dt.office_code),2)#>
                        <cfset cnum3 = 1>
                        <!--- 回収の場合は2 --->
                        <cfif trim(dt.freon_flag2) eq 1>
                            <cfset cnum3 = 2>
                        </cfif>
                        <!--- 1回の修理でフロンの充填と回収がある場合 --->
                        <cfif reibai_count GTE 1 AND reibai_count2 GTE 1>
                            <cfset looop_count = 2>
                        </cfif> 

                        <!--- この修理でフロン証明書の作成履歴があるかどうか --->
                        <cfquery datasource="#application.dsn#" name="qGetFreon">
                           SELECT t_freon_certification.kaisya_code
                             FROM t_freon_certification
                            WHERE t_freon_certification.kaisya_code = '#kaisya_code#'
                              AND t_freon_certification.slip_num = '#url.s_nm#'
                        </cfquery>

                        <cfquery datasource="#application.dsn#" name="qGetUnit">
                          SELECT m_company.kaisya_name,
                                 m_company.tel_no kaisya_tel,
                                 CONCAT(IFNULL(m_company.address_1,"")," ",IFNULL(m_company.address_2,"")) kaisya_address,
                                 m_client.client_name,
                                 m_unit.u_model,
                                 m_unit.unit_name,
                                 m_unit.u_serial_number, 
                                 CONCAT(IFNULL(m_client.address_1,"")," ",IFNULL(m_client.address_2,"")," ",IFNULL(m_client.address_3,"")) shozai_address,
                                 m_client.address_2 shozai_office,
                                 m_area_management.registered_num,
                                 m_area_management.area_code,
                                 m_area_management.area_name
                            FROM m_unit LEFT OUTER JOIN m_client ON m_unit.kaisya_code = m_client.kaisya_code AND m_unit.client_code = m_client.client_code
                                        LEFT OUTER JOIN m_area_management ON m_unit.kaisya_code = m_area_management.kaisya_code AND m_unit.area_code = m_area_management.area_code
                                        LEFT OUTER JOIN m_company ON m_unit.kaisya_code = m_company.kaisya_code
                           WHERE m_unit.kaisya_code = '#kaisya_code#'
                             AND m_unit.client_code = "#trim(dt.customer_code)#"
                             AND m_unit.unit_code = '#trim(dt.unit)#'                           
                        </cfquery>

                        <cfset registered_num = qGetUnit.registered_num>


                        <!--- 
                        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

                            ローカルルール
                            地域番号で東京都PMの13か東京都EMの14で固定されていることと
                            事業所番号で関東エンジがTN30、関東プラントマーケティングがKN83であることが前提


                        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
                         --->

                        <!--- 東京PMか東京EMの場合は報告書の事務所を確認し、関東PMだっら東京PM、関東EMなら東京EMにする --->
                        <cfif qGetUnit.area_code eq 13 or  qGetUnit.area_code eq 14>
                            <cfif trim(dt.office_code) neq "" and trim(dt.office_code) eq "KN30"><!--- 関東エンジサービス --->
                                <cfquery datasource="#application.dsn#" name="qGetRegisteredNum">
                                    SELECT m_area_management.registered_num 
                                      FROM m_area_management
                                     WHERE m_area_management.kaisya_code = '#kaisya_code#'
                                       AND m_area_management.area_code = 13 
                                </cfquery>                          
                                <cfset registered_num = qGetRegisteredNum.registered_num>
                            <cfelseif trim(dt.office_code) neq "" and trim(dt.office_code) eq "KN83"><!--- 関東プラントマーケティング営業所 --->
                                <cfquery datasource="#application.dsn#" name="qGetRegisteredNum">
                                    SELECT m_area_management.registered_num 
                                      FROM m_area_management
                                     WHERE m_area_management.kaisya_code = '#kaisya_code#'
                                       AND m_area_management.area_code = 14 
                                </cfquery>                          
                                <cfset registered_num = qGetRegisteredNum.registered_num>                               
                            </cfif>                         
                        </cfif>
                        <!--- 
                        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

                            ローカルルールここまで
                            
                        ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
                         --->

                        <cfloop index="i" from="1" to="#looop_count#">
                            <cfif looop_count neq 1><!--- フロンで充填と回収がある場合(1周目充填、2周目回収) --->                              
                                <cfset cnum3 = i>
                            </cfif>

                            <cfset first_five_digit_of_new_c_cum = cnum1 & cnum2 & cnum3>

                            <cfif qGetFreon.RecordCount LT 1>
                                <cfquery datasource="#application.dsn#" name="qGetNewCNum">
                                   SELECT COUNT(t_freon_certification.kaisya_code) + 1 new_last_3digit
                                     FROM t_freon_certification
                                    WHERE t_freon_certification.kaisya_code = '#kaisya_code#'
                                      AND LEFT(t_freon_certification.certificate_num,5) = CAST(#first_five_digit_of_new_c_cum# AS UNSIGNED) 
                                </cfquery>
                                <cfset new_c_cum = first_five_digit_of_new_c_cum & NumberFormat(qGetNewCNum.new_last_3digit,"000")>
                                
                                <cfquery datasource="#application.dsn#" name="qInsFreon">
                                    INSERT INTO t_freon_certification 
                                                (
                                                kaisya_code,
                                                certificate_num,
                                                unit_code,
                                                unit_name,
                                                client_code,
                                                client_name,
                                                slip_num,
                                                reibai_id,
                                                reibai_kind,
                                                filling_amount,
                                                work_situation,
                                                gwp,
                                                filling_date,
                                                shozai_address,
                                                shozai_office,
                                                machine_managing_code,
                                                u_model,
                                                u_serial_number,
                                                kaisya_address,
                                                kaisya_name,
                                                kaisya_tel,
                                                section_code,
                                                area_name,
                                                registered_num,
                                                status_flag,
                                                recieve_time

                                        ) VALUES (
                                                '#kaisya_code#',
                                                 #new_c_cum#,
                                                <cfif #trim(dt.unit)# neq "">'#trim(dt.unit)#',<cfelse>null,</cfif>
                                                <cfif #trim(dt.unit)# neq "">'#qGetUnit.unit_name#',<cfelse>null,</cfif>
                                                "#trim(dt.customer_code)#",
                                                <cfif #qGetUnit.client_name# neq "">'#qGetUnit.client_name#',<cfelse>null,</cfif>
                                                "#slip_num#",
                                                <cfif i eq 1 and reibai_count GTE 1>
                                                    #trim(dt.freon_type)#,
                                                    "#trim(qGetReibai.reibai_kind)#",
                                                    #trim(dt.filling_amount)#,
                                                    1,
                                                    #trim(qGetReibai.gwp)#,
                                                <cfelse>
                                                    #trim(dt.freon_type2)#,
                                                    "#trim(qGetReibai2.reibai_kind)#",
                                                    #trim(dt.filling_amount2)#,
                                                    2,
                                                    #trim(qGetReibai2.gwp)#,                                                
                                                </cfif>
                                                <cfif #trim(dt.date)# neq "">'#trim(dt.date)#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.shozai_address# neq "">'#qGetUnit.shozai_address#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.shozai_office# neq "">'#qGetUnit.shozai_office#',<cfelse>null,</cfif>
                                                <cfif trim(dt.unit) neq "">'#qGetUnit.unit_name#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.u_model# neq "">'#qGetUnit.u_model#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.u_serial_number# neq "">'#qGetUnit.u_serial_number#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.kaisya_address# neq "">'#qGetUnit.kaisya_address#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.kaisya_name# neq "">'#qGetUnit.kaisya_name#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.kaisya_tel# neq "">'#qGetUnit.kaisya_tel#',<cfelse>null,</cfif>

                                                '#trim(dt.office_code)#',
                                                <cfif #qGetUnit.area_name# neq "">'#qGetUnit.area_name#',<cfelse>null,</cfif>
                                                <cfif #qGetUnit.registered_num# neq "">'#registered_num#',<cfelse>null,</cfif>
                                                0,
                                                now()
                                        )
                                </cfquery>
                            <cfelse>

                                <!--- アップデートは行わないがある場合はここで処理 --->

                            </cfif>


                            
                        </cfloop>

                    </cfif>
                </cfif><!--- 冷媒の充填か回収があった場合の終わり --->

            </cfif><!--- フォームにデータがあるかないかの終わり --->


            <!--- ここから修理データの処理 --->


<!--- 
            <cfif IsDefined("form.data") and #form.data# neq "">
                <cfset arr_data = Listtoarray(#form.data#, ",", true)>

                <cfquery datasource="#application.dsn#" name="qGetReport">
                   SELECT slip_num
                     FROM t_report
                    WHERE t_report.kaisya_code = '#kaisya_code#'
                      AND t_report.slip_num = '#url.s_nm#'
                </cfquery>





                <cfif qGetReport.RecordCount LT 1>
                    
                    <cfquery datasource="#application.dsn#" name="qInsReport">
                        INSERT INTO t_report (

                            <cfif #trim(arr_data[1])# neq "">unit_code,</cfif>
                            <cfif #trim(arr_data[2])# neq "">slip_num,</cfif>
                            <cfif #trim(arr_data[3])# neq "">work_date,</cfif>
                            <cfif #trim(arr_data[4])# neq "">start_time,</cfif>
                            <cfif #trim(arr_data[5])# neq "">end_time,</cfif>
                            <cfif #trim(arr_data[6])# neq "">target_machinery,</cfif>
                            <cfif #trim(arr_data[7])# neq "">client_code,</cfif>
                            <cfif #trim(arr_data[8])# neq "">client_name,</cfif>
                            <cfif #trim(arr_data[9])# neq "">name,</cfif>

                            <cfif #trim(arr_data[10])# neq "">office_code,</cfif>
                            <cfif #trim(arr_data[11])# neq "">office_short_name,</cfif>

                            <cfif #trim(arr_data[12])# neq "">signature,</cfif>

                            <cfif #trim(arr_data[13])# neq "">work_kubun,</cfif>
                            <cfif #trim(arr_data[14])# neq "">claim_kubun,</cfif>
                            <cfif #trim(arr_data[15])# neq "">work_fee,</cfif>
                            <cfif #trim(arr_data[16])# neq "">freon_flag,</cfif>
                            <cfif #trim(arr_data[17])# neq "">freon_type,</cfif>
                            <cfif #trim(arr_data[18])# neq "">filling_amount,</cfif>
                            <cfif #trim(arr_data[19])# neq "">uketsuke_contents,</cfif>
                            <cfif #trim(arr_data[20])# neq "">state_contents,</cfif>
                            <cfif #trim(arr_data[21])# neq "">cause,</cfif>
                            <cfif #trim(arr_data[22])# neq "">measures,</cfif>

                            <cfif #trim(arr_data[23])# neq "">parts,</cfif>
                            <cfif #trim(arr_data[24])# neq "">remarks,</cfif>
                            <cfif #trim(arr_data[25])# neq "">finish_check,</cfif>
                            <cfif #trim(arr_data[26])# neq "">work_men,</cfif>

                            <cfif #trim(arr_data[27])# neq "">picture1,</cfif>
                            <cfif #trim(arr_data[28])# neq "">p_daytime1,</cfif>
                            <cfif #trim(arr_data[29])# neq "">p_memo1,</cfif>

                            <cfif #trim(arr_data[30])# neq "">picture2,</cfif>
                            <cfif #trim(arr_data[31])# neq "">p_daytime2,</cfif>
                            <cfif #trim(arr_data[32])# neq "">p_memo2,</cfif>

                            <cfif #trim(arr_data[33])# neq "">picture3,</cfif>
                            <cfif #trim(arr_data[34])# neq "">p_daytime3,</cfif>
                            <cfif #trim(arr_data[35])# neq "">p_memo3,</cfif>

                            <cfif #trim(arr_data[36])# neq "">picture4,</cfif>
                            <cfif #trim(arr_data[37])# neq "">p_daytime4,</cfif>
                            <cfif #trim(arr_data[38])# neq "">p_memo4,</cfif>
                            <cfif #trim(arr_data[39])# neq "">decision_flag,</cfif>

                            <cfif #trim(arr_data[40])# neq "">create_date,</cfif>
                            <cfif #trim(arr_data[41])# neq "">update_date,</cfif>
                            last_recv_datetime,
                            kaisya_code

                        ) VALUES (
                                        
                            <cfif #trim(arr_data[1])# neq "">'#trim(arr_data[1])#',</cfif>
                            <cfif #trim(arr_data[2])# neq "">#trim(arr_data[2])#,</cfif>
                            <cfif #trim(arr_data[3])# neq "">'#trim(arr_data[3])#',</cfif>
                            <cfif #trim(arr_data[4])# neq "">'1900/01/01 #trim(arr_data[4])#',</cfif>
                            <cfif #trim(arr_data[5])# neq "">'1900/01/01 #trim(arr_data[5])#',</cfif>
                            <cfif #trim(arr_data[6])# neq "">#trim(arr_data[6])#,</cfif>

                            <cfif #trim(arr_data[7])# neq "">"#trim(arr_data[7])#",</cfif>
                            <cfif #trim(arr_data[8])# neq "">"#trim(arr_data[8])#",</cfif>
                            <cfif #trim(arr_data[9])# neq "">"#trim(arr_data[9])#",</cfif>

                            <cfif #trim(arr_data[10])# neq "">"#trim(arr_data[10])#",</cfif>
                            <cfif #trim(arr_data[11])# neq "">"#trim(arr_data[11])#",</cfif>                            


                            <cfif #trim(arr_data[12])# neq "">"#trim(arr_data[12])#",</cfif>

                            <cfif #trim(arr_data[13])# neq "">#arr_data[13]#,</cfif>
                            <cfif #trim(arr_data[14])# neq "">#arr_data[14]#,</cfif>
                            <cfif #trim(arr_data[15])# neq "">#arr_data[15]#,</cfif>
                            <cfif #trim(arr_data[16])# neq "">#arr_data[16]#,</cfif>
                            <cfif #trim(arr_data[17])# neq "">#arr_data[17]#,</cfif>
                            <cfif #trim(arr_data[18])# neq "">#arr_data[18]#,</cfif>
                            <cfif #trim(arr_data[19])# neq "">"#trim(arr_data[19])#",</cfif>
                            <cfif #trim(arr_data[20])# neq "">"#trim(arr_data[20])#",</cfif>
                            <cfif #trim(arr_data[21])# neq "">"#trim(arr_data[21])#",</cfif>
                            <cfif #trim(arr_data[22])# neq "">"#trim(arr_data[22])#",</cfif>

                            <cfif #trim(arr_data[23])# neq "">"#trim(arr_data[23])#",</cfif>
                            <cfif #trim(arr_data[24])# neq "">"#trim(arr_data[24])#",</cfif>
                            <cfif #trim(arr_data[25])# neq "">"#trim(arr_data[25])#",</cfif>
                            <cfif #trim(arr_data[26])# neq "">"#trim(arr_data[26])#",</cfif>

                            <cfif #trim(arr_data[27])# neq "">"#trim(arr_data[27])#",</cfif>
                            <cfif #trim(arr_data[28])# neq "">'#trim(arr_data[28])#',</cfif>
                            <cfif #trim(arr_data[29])# neq "">"#trim(arr_data[29])#",</cfif>

                            <cfif #trim(arr_data[30])# neq "">"#trim(arr_data[30])#",</cfif>
                            <cfif #trim(arr_data[31])# neq "">'#trim(arr_data[31])#',</cfif>
                            <cfif #trim(arr_data[32])# neq "">"#trim(arr_data[32])#",</cfif>

                            <cfif #trim(arr_data[33])# neq "">"#trim(arr_data[33])#",</cfif>
                            <cfif #trim(arr_data[34])# neq "">'#trim(arr_data[34])#',</cfif>
                            <cfif #trim(arr_data[35])# neq "">"#trim(arr_data[35])#",</cfif>

                            <cfif #trim(arr_data[36])# neq "">"#trim(arr_data[36])#",</cfif>
                            <cfif #trim(arr_data[37])# neq "">'#trim(arr_data[37])#',</cfif>
                            <cfif #trim(arr_data[38])# neq "">#arr_data[38]#,</cfif>
                            <cfif #trim(arr_data[39])# neq "">"#trim(arr_data[39])#",</cfif>

                            <cfif #trim(arr_data[40])# neq "">"#trim(arr_data[40])#",</cfif>
                            <cfif #trim(arr_data[41])# neq "">"#trim(arr_data[41])#",</cfif>
                            now(),                                      
                            '#kaisya_code#'

                                    )
                    </cfquery>

                <cfelse>
                    <cfquery datasource="#application.dsn#" name="qUpdReport">
                        UPDATE t_report 
                           SET 
                            work_date          = <cfif #trim(arr_data[3])# neq "">'#trim(arr_data[3])#',</cfif>
                            start_time         = <cfif #trim(arr_data[4])# neq "">'1900/01/01 #trim(arr_data[4])#',</cfif>
                            end_time           = <cfif #trim(arr_data[5])# neq "">'1900/01/01 #trim(arr_data[5])#',</cfif>
                            target_machinery   = <cfif #trim(arr_data[6])# neq "">#trim(arr_data[6])#,</cfif>
                            client_code        = <cfif #trim(arr_data[7])# neq "">"#trim(arr_data[7])#",</cfif>
                            
                            name               = <cfif #trim(arr_data[9])# neq "">"#trim(arr_data[9])#",</cfif>
                            office_code          = <cfif #trim(arr_data[10])# neq "">"#trim(arr_data[10])#",</cfif>
                            office_code          = <cfif #trim(arr_data[11])# neq "">"#trim(arr_data[11])#",</cfif>


                            signature          = <cfif #trim(arr_data[12])# neq "">"#trim(arr_data[12])#",</cfif>
                            work_kubun         = <cfif #trim(arr_data[13])# neq "">#trim(arr_data[13])#,</cfif>
                            claim_kubun        = <cfif #trim(arr_data[14])# neq "">#trim(arr_data[14])#,</cfif>
                            work_fee           = <cfif #trim(arr_data[15])# neq "">#trim(arr_data[15])#,</cfif>
                            freon_flag         = <cfif #trim(arr_data[16])# neq "">#trim(arr_data[16])#,</cfif>
                            freon_type         = <cfif #trim(arr_data[17])# neq "">#trim(arr_data[17])#,</cfif>
                            filling_amount     = <cfif #trim(arr_data[18])# neq "">#trim(arr_data[18])#,</cfif>
                            uketsuke_contents  = <cfif #trim(arr_data[19])# neq "">"#trim(arr_data[19])#",</cfif>
                            state_contents     = <cfif #trim(arr_data[20])# neq "">"#trim(arr_data[20])#",</cfif>
                            cause              = <cfif #trim(arr_data[21])# neq "">"#trim(arr_data[21])#",</cfif>
                            measures           = <cfif #trim(arr_data[22])# neq "">"#trim(arr_data[22])#",</cfif>
                            parts              = <cfif #trim(arr_data[23])# neq "">"#trim(arr_data[23])#",</cfif>
                            remarks            = <cfif #trim(arr_data[24])# neq "">"#trim(arr_data[24])#",</cfif>
                            finish_check       = <cfif #trim(arr_data[25])# neq "">"#trim(arr_data[25])#",</cfif>
                            work_men           = <cfif #trim(arr_data[26])# neq "">"#trim(arr_data[26])#",</cfif>
                            picture1           = <cfif #trim(arr_data[27])# neq "">"#trim(arr_data[27])#",</cfif>
                            p_daytime1         = <cfif #trim(arr_data[28])# neq "">'#trim(arr_data[28])#',</cfif>
                            p_memo1            = <cfif #trim(arr_data[29])# neq "">"#trim(arr_data[29])#",</cfif>
                            picture2           = <cfif #trim(arr_data[30])# neq "">"#trim(arr_data[30])#",</cfif>
                            p_daytime2         = <cfif #trim(arr_data[31])# neq "">'#trim(arr_data[31])#',</cfif>
                            p_memo2            = <cfif #trim(arr_data[32])# neq "">"#trim(arr_data[32])#",</cfif>
                            picture3           = <cfif #trim(arr_data[33])# neq "">"#trim(arr_data[33])#",</cfif>
                            p_daytime3         = <cfif #trim(arr_data[34])# neq "">'#trim(arr_data[34])#',</cfif>
                            p_memo3            = <cfif #trim(arr_data[35])# neq "">"#trim(arr_data[35])#",</cfif>
                            picture4           = <cfif #trim(arr_data[36])# neq "">"#trim(arr_data[36])#",</cfif>
                            p_daytime4         = <cfif #trim(arr_data[37])# neq "">'#trim(arr_data[37])#',</cfif>
                            p_memo4            = <cfif #trim(arr_data[38])# neq "">"#trim(arr_data[38])#",</cfif>
                            decision_flag     = <cfif #trim(arr_data[39])# neq "">#trim(arr_data[39])#,</cfif>
                            create_date        = <cfif #trim(arr_data[40])# neq "">"#trim(arr_data[40])#",</cfif>
                            update_date        = <cfif #trim(arr_data[41])# neq "">"#trim(arr_data[41])#",</cfif>
                            last_recv_datetime = now()
                    WHERE kaisya_code = "#kaisya_code#" 
                      AND slip_num    = "#slip_num#"
                    </cfquery>                  
                </cfif>
            </cfif>
            <cfset output = 1>
            <cfreturn output > --->
            <cfreturn 1>

        </cffunction>                                                                                                                   
</cfcomponent>


