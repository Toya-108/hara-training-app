<cfcomponent>
	<cfheader name="Access-Control-Allow-Origin" value="*" />
	<cfsetting showDebugOutput="No">
	<!--- 下部側へ送信 --->
		
		<!--- 商品マスタ ---> 
		<cffunction name="getProduct" access="remote" returnFormat="plain">

            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset,m_admin.tax_rate 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfif qGetOffset.RecordCount LT 1>
               <cfset output = "">
	           <cfreturn output> 
            </cfif>
            

            <cfset utc_offset = qGetOffset.utc_offset>

			<cfset shop_id = url.sp_id>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = qGetNow.now>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_product AS lsd,
					   case when last_send_date_product <= send_all_setting_date
					        then 1
					        else 0
					   end as send_all
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' AND shop_id ='#shop_id#' AND regi_id ='#url.r_id#'
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qGetProduct">
				  SELECT m_jan.jan,
				  		 m_jan.sort_order,   
				         m_product.product_id,   
				         m_product.product_name,   
				         m_product.product_name_kana,   
				         m_product.receipt_name,   
				         m_product.receipt_name_kana,   
				         m_product.plu_name,   
				         m_product.plu_name_kana,
				         m_product.plu_name2,   
				         m_product.plu_name2_kana,			            
				         m_product.maker_name,   
				         m_product.maker_name_kana,   
				         m_product.standard_name,   
				         m_product.standard_name_kana,   
				         m_product.division_id,   
				         m_product.depart_id,   
				         m_product.line_id,   
				         m_product.class_id,   
				         m_product.product_category_id,   
				         m_product.supplier_id, 
				         m_product.maker_price, 
				         <!--- 
				          -- m_product.unit_cost,  
				         -- m_product.unit_price_without_tax,   
				         -- m_product.unit_price_include_tax,   
				         -- m_product.unit_price_tax,   
				         -- m_product.qty_per_carton,
				         --->
				         CASE WHEN m_shop_tanka.unit_price_without_tax is null
				              THEN m_product.unit_price_without_tax
				              ELSE m_shop_tanka.unit_price_without_tax
				         END AS unit_price_without_tax, 
				         CASE WHEN m_shop_tanka.unit_price_include_tax is null
				              THEN m_product.unit_price_include_tax
				              ELSE m_shop_tanka.unit_price_include_tax 
				         END AS unit_price_include_tax, 
				         CASE WHEN m_shop_tanka.unit_price_tax is null
				              THEN m_product.unit_price_tax
				              ELSE m_shop_tanka.unit_price_tax
			         	 END AS unit_price_tax, 
				         CASE WHEN m_shop_tanka.qty_per_carton is null
				              THEN m_product.qty_per_carton
				              ELSE m_shop_tanka.qty_per_carton
			         	 END AS qty_per_carton, 

				         CASE WHEN m_shop_tanka.unit_cost is null
				              THEN m_product.unit_cost
				              ELSE m_shop_tanka.unit_cost
			         	 END AS unit_cost,
			         	 m_shop_tanka.handling_type, 				            
				         m_product.tax_class,   
				         m_product.shelflabel_type,
				         CASE WHEN m_shop_printer.printer_map_id IS NULL AND m_shop_printer_div.printer_map_id IS NULL THEN 0
				              ELSE 1 
				            END AS cook_flag,				         
				         <!---m_product.last_sales_date,--->
				         DATE_FORMAT(m_product.last_sales_date,'%Y/%m/%d %H:%i:%s') as last_sales_date,    
				         m_product.memo,  
				         DATE_FORMAT(m_product.create_date,'%Y/%m/%d %H:%i:%s') as create_date,   
				         m_product.create_account,   
				         m_product.create_person,
				         DATE_FORMAT(m_product.modify_date,'%Y/%m/%d %H:%i:%s') as modify_date,   
				         m_product.modify_account,   
				         m_product.modify_person,  
				         m_jan.del_flag,  
				         m_product.point_flag,
				         m_product.regi_input_minus_flag,
				         m_product.img_ext,
				         m_product.printer_id,
				         m_product.limit_num,
				         m_product.retail_form,
				         m_product.fb_form,
				         CASE WHEN m_shop_printer.printer_map_id IS NULL THEN m_shop_printer_div.printer_map_id 
				              ELSE m_shop_printer.printer_map_id 
				            END AS printer_map_id,
				         m_product.tax_div,
				         CASE WHEN m_product.tax_rate IS NOT NULL THEN m_product.tax_rate
				              ELSE #qGetOffset.tax_rate#
				         END AS tax_rate,
				         CASE WHEN m_shop_tanka.handling_type = 9 THEN 0 ELSE m_jan.plu_disp_order END AS plu_disp_order, <!--- handling_typeが9だったらplu_disp_orderを0にする(マスターをそのままボタンにする場合非表示になる。) --->				            
				    	 m_jan.plu_color_red,
				    	 m_jan.plu_color_green,
				    	 m_jan.plu_color_blue
				    FROM m_product LEFT OUTER JOIN m_shop_printer ON m_product.member_id = m_shop_printer.member_id AND m_product.product_id = m_shop_printer.product_id AND m_shop_printer.shop_id = '#shop_id#'
				                   LEFT OUTER JOIN m_shop_printer_div ON m_product.member_id = m_shop_printer_div.member_id AND m_product.division_id = m_shop_printer_div.division_id AND m_shop_printer_div.shop_id = '#shop_id#',   
				         m_jan,				         
				         m_shop_tanka   
				   WHERE m_product.member_id = m_jan.member_id AND 
				         m_product.product_id = m_jan.product_id AND
				 		 m_jan.member_id = m_shop_tanka.member_id AND  
				         m_jan.product_id = m_shop_tanka.product_id AND			          				         
				         m_product.member_id = '#url.m_id#' AND
				         m_shop_tanka.shop_id = '#shop_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_jan.modify_date >= '#qGetLastSendDate.lsd#' OR m_jan.create_date >= '#qGetLastSendDate.lsd#' OR m_jan.del_date >= '#qGetLastSendDate.lsd#')
						 </cfif>								 
				 </cfquery>

				 	<cfset recordCount = qGetProduct.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
				 	<cfset up_items = "AND 1 = 1">
					<cfloop index="cnt" from="1" to="#recordCount#">
						<!--- 店舗の単価を取得 --->
<!--- 						<cfquery datasource="#application.dsn#" name="qGetShopTanka">
						  SELECT m_shop_tanka.shop_id,
						  		 m_shop_tanka.handling_type,
						         m_shop_tanka.unit_cost,
					  		     m_shop_tanka.unit_price_without_tax,
						         m_shop_tanka.unit_price_include_tax,
						         m_shop_tanka.unit_price_tax,		         
						         m_shop_tanka.qty_per_carton
						    FROM m_shop_tanka
						   WHERE m_shop_tanka.member_id = '#session.member_id#'
						     AND m_shop_tanka.shop_id = '#url.sp_id#'                           
						     AND m_shop_tanka.product_id = '#qGetProduct.product_id[cnt]#'                        
						</cfquery> --->

				 		<!--- 店舗別単価用変数 --->
<!--- 						<cfset unit_cost              = "">
						<cfset unit_price_without_tax = "">
						<cfset unit_price_include_tax = "">
						<cfset unit_price_tax         = "">
						<cfset qty_per_carton         = "">
						<cfset del_flag               = #qGetProduct.del_flag[cnt]#>

						<cfif #qGetShopTanka.RecordCount# GTE 1>
							<cfset unit_cost              = #qGetShopTanka.unit_cost#>
							<cfset unit_price_without_tax = #qGetShopTanka.unit_price_without_tax#>
							<cfset unit_price_include_tax = #qGetShopTanka.unit_price_include_tax#>
							<cfset unit_price_tax         = #qGetShopTanka.unit_price_tax#>
							<cfset qty_per_carton         = #qGetShopTanka.qty_per_carton#>
						<cfelse>
							<cfset unit_cost              = #qGetProduct.unit_cost#>
							<cfset unit_price_without_tax = #qGetProduct.unit_price_without_tax#>
							<cfset unit_price_include_tax = #qGetProduct.unit_price_include_tax#>
							<cfset unit_price_tax         = #qGetProduct.unit_price_tax#>
							<cfset qty_per_carton         = #qGetProduct.qty_per_carton#>
						</cfif> --->

						<cfset del_flag = qGetProduct.del_flag[cnt]>

						<!--- 店舗別の取扱が「非取扱」の場合del_flagを1に --->
						<cfif qGetProduct.handling_type[cnt] eq 9>
							<cfset del_flag = 1>
						</cfif>

						<cfset data = "">  
						<cfset data = 1 & ","
									 & shop_id & ","
									 & qGetProduct.jan[cnt] & ","
									 & qGetProduct.product_id[cnt] & ","
									 & qGetProduct.product_name[cnt] & ","									 
									 & qGetProduct.product_name_kana[cnt] & "," 
									 & qGetProduct.receipt_name[cnt] & ","
									 & qGetProduct.receipt_name_kana[cnt] & ","
									 & qGetProduct.plu_name[cnt] & ","
									 & qGetProduct.plu_name_kana[cnt] & ","
									 & qGetProduct.maker_name[cnt] & ","
									 & qGetProduct.maker_name_kana[cnt] & ","
									 & qGetProduct.standard_name[cnt] & ","
									 & qGetProduct.standard_name_kana[cnt] & ","
									 & qGetProduct.division_id[cnt] & ","
									 & qGetProduct.depart_id[cnt] & ","
									 & qGetProduct.line_id[cnt] & ","
									 & qGetProduct.class_id[cnt] & ","
									 & qGetProduct.product_category_id[cnt] & ","
									 & ","
									 & ","
									 & qGetProduct.tax_class[cnt] & ","
									 & qGetProduct.supplier_id[cnt] & ","
									 & qGetProduct.unit_cost[cnt] & ","
									 & qGetProduct.maker_price[cnt] & ","
									 & qGetProduct.unit_price_without_tax[cnt] & ","
									 & qGetProduct.unit_price_include_tax[cnt] & ","
									 & qGetProduct.unit_price_tax[cnt] & ","
									 & qGetProduct.qty_per_carton[cnt] & ","									 
									 & qGetProduct.shelflabel_type[cnt] & ","
									 & qGetProduct.cook_flag[cnt] & ","
									 & qGetProduct.last_sales_date[cnt] & ","
									 & qGetProduct.memo[cnt] & ","
									 & qGetProduct.create_date[cnt] & ","
									 & qGetProduct.create_account[cnt] & ","
									 & qGetProduct.create_person[cnt] & ","
									 & qGetProduct.modify_date[cnt] & ","
									 & qGetProduct.modify_account[cnt] & ","
									 & qGetProduct.modify_person[cnt] & ","
									 & del_flag & ","
									 & qGetProduct.point_flag[cnt] & ","
									 & qGetProduct.regi_input_minus_flag[cnt] & ","
									 & qGetProduct.plu_name2[cnt] & ","
									 & qGetProduct.plu_name2_kana[cnt] & ","
									 & qGetProduct.sort_order[cnt] & ","
									 & qGetProduct.img_ext[cnt] & ","
									 & qGetProduct.printer_id[cnt] & ","
									 & qGetProduct.limit_num[cnt] & ","
									 & qGetProduct.retail_form[cnt] & ","
									 & qGetProduct.fb_form[cnt] & ","
									 & qGetProduct.printer_map_id[cnt] & ","
									 & qGetProduct.tax_div[cnt] & ","

									 & qGetProduct.tax_rate[cnt] & ","
									 & qGetProduct.plu_disp_order[cnt] & ","
									 & qGetProduct.plu_color_red[cnt] & ","
									 & qGetProduct.plu_color_green[cnt] & ","
									 & qGetProduct.plu_color_blue[cnt] & chr(10)>
						<cfset output = output & data>

						<cfset up_items = up_items & " OR m_jan.jan ='" & qGetProduct.jan[cnt] & "'">
<!--- 					<cfquery datasource="#application.dsn#" name="qUpdJan">
						  UPDATE m_jan  
	  						SET send_flag    = 1,   
					  			send_date = '#now#',  
								send_person  = 'AUTO'  
						  WHERE member_id = '#url.m_id#'
						    AND m_jan.jan = '#qGetProduct.jan[cnt]#'								     
					</cfquery>
									 --->																
					</cfloop>


					<!--- 送信したらm_janの送信フラグを1に。 --->
<!--- 					<cfif recordCount GTE 1>
						<cfquery datasource="#application.dsn#" name="qUpdJan">
							  UPDATE m_jan  
		  						SET send_flag    = 1,   
						  			send_date = '#now#',  
									send_person  = 'AUTO'  
							  WHERE member_id = '#url.m_id#'
							    #PreserveSingleQuotes(up_items)#								     
						</cfquery>						
					</cfif> --->

					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_product = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id = '#shop_id#'								     
				</cfquery>				 	
			<cfreturn output >
		</cffunction>
		
		<!--- 部門マスタ --->
		<cffunction name="getDivision" access="remote" returnFormat="plain">
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<cfset shop_id = url.sp_id>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_division AS lsd,
					   CASE WHEN last_send_date_division <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#' 
				   AND shop_id ='#shop_id#'
			</cfquery>

			<cfquery datasource="#application.dsn#" name="qGetDivision">
				  SELECT m_division.division_id,   
				         m_division.division_name,   
				         m_division.division_name_kana,   
				         m_division.receipt_division_name,
				         m_division.printer_id,
				         m_division.tax_div,
				         m_division.tax_rate,  
				         m_division.create_date,   
				         m_division.create_account,   
				         m_division.create_person,   
				         m_division.modify_date,   
				         m_division.modify_account,   
				         m_division.modify_person,  
				         m_division.del_flag,
				         m_division.plu_disp_order,
				         m_division.plu_color_red,
				         m_division.plu_color_green,
				         m_division.plu_color_blue  
				    FROM m_division  
				   WHERE m_division.member_id = '#url.m_id#'
				   		<!--- m_division.send_flag = 0--->
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_division.modify_date >= '#qGetLastSendDate.lsd#' OR m_division.create_date >= '#qGetLastSendDate.lsd#' OR m_division.del_date >= '#qGetLastSendDate.lsd#')
						 </cfif>						   			 				 
			</cfquery>
				 	<cfset recordCount = qGetDivision.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
				 	<cfset up_items = "AND 1 = 1">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetDivision.division_id[cnt] & ","
										 & qGetDivision.division_name[cnt] & ","
										 & qGetDivision.division_name_kana[cnt] & ","									 
										 & qGetDivision.receipt_division_name[cnt] & "," 
										 & qGetDivision.create_date[cnt] & ","
										 & qGetDivision.create_account[cnt] & ","
										 & qGetDivision.create_person[cnt] & ","
										 & qGetDivision.modify_date[cnt] & ","
										 & qGetDivision.modify_account[cnt] & ","
										 & qGetDivision.modify_person[cnt] & ","
										 & qGetDivision.del_flag[cnt] & ","
										 & qGetDivision.printer_id[cnt] & ","
										 & qGetDivision.tax_div[cnt] & ","
										 & qGetDivision.tax_rate[cnt] & ","
										 & qGetDivision.plu_disp_order[cnt] & ","
										 & qGetDivision.plu_color_red[cnt] & ","
										 & qGetDivision.plu_color_green[cnt] & ","
										 & qGetDivision.plu_color_blue[cnt] & chr(10)>							 
							<cfset output = output & data>
							<!--- <cfset up_items = up_items & " OR m_division.division_id ='" & qGetDivision.division_id[cnt] & "'">	 --->																
					</cfloop>
<!--- 					<cfif recordCount GTE 1>
						<cfquery datasource="#application.dsn#" name="qUpdDivision">
							  UPDATE m_division  
		  						SET send_flag    = 1,   
						  			send_date = '#now#',  
									send_person  = 'AUTO'  
							  WHERE member_id = '#url.m_id#'
							    #PreserveSingleQuotes(up_items)#								     
						</cfquery>
					</cfif> --->

				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_division = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>		

		<!--- ラインマスタ --->
		<cffunction name="getLine" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_line AS lsd,
					   CASE WHEN last_send_date_line <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetLine">
				SELECT m_line.line_id,   
					   m_line.line_name,   
					   m_line.line_name_kana,   
					   m_line.division_id,   
					   m_line.depart_id,   
					   m_line.create_date,   
					   m_line.create_account,   
					   m_line.create_person,   
					   m_line.modify_date,   
					   m_line.modify_account,   
					   m_line.modify_person,  
					   m_line.del_flag,
				       m_line.plu_disp_order,
				       m_line.plu_color_red,
				       m_line.plu_color_green,
				       m_line.plu_color_blue 					     
				  FROM m_line  
				 WHERE m_line.member_id = '#url.m_id#'
					   <!---m_line.send_flag = 0	--->
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_line.modify_date >= '#qGetLastSendDate.lsd#' OR m_line.create_date >= '#qGetLastSendDate.lsd#' OR m_line.del_date >= '#qGetLastSendDate.lsd#')
					 </cfif>					   							 
				 </cfquery>
				 	<cfset recordCount = #qGetLine.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetLine.line_id[cnt]# & ","
										 & #qGetLine.line_name[cnt]# & ","
										 & #qGetLine.line_name_kana[cnt]# & ","									 
										 & #qGetLine.division_id[cnt]# & ","
										 & #qGetLine.depart_id[cnt]# & ","
										 & #qGetLine.create_date[cnt]# & ","
										 & #qGetLine.create_account[cnt]# & ","
										 & #qGetLine.create_person[cnt]# & ","
										 & #qGetLine.modify_date[cnt]# & ","
										 & #qGetLine.modify_account[cnt]# & ","
										 & #qGetLine.modify_person[cnt]# & ","
										 & #qGetLine.del_flag[cnt]# & ","
										 & #qGetLine.plu_disp_order[cnt]# & ","
										 & #qGetLine.plu_color_red[cnt]# & ","
										 & #qGetLine.plu_color_green[cnt]# & ","
										 & #qGetLine.plu_color_blue[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>

								
							
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdLine">
								  UPDATE m_line  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_line.line_id = '#qGetLine.line_id[cnt]#'
							</cfquery> --->
																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_line = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>


		<!--- クラスマスタ --->
		<cffunction name="getClass" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = qGetNow.now>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_class AS lsd,
					   CASE WHEN last_send_date_class <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetClass">
				SELECT m_class.class_id,   
				       m_class.class_name,   
				       m_class.class_name_kana,   
				       m_class.division_id,   
				       m_class.depart_id,   
				       m_class.line_id,   
				       m_class.create_date,   
				       m_class.create_account,   
				       m_class.create_person,   
				       m_class.modify_date,   
				       m_class.modify_account,   
				       m_class.modify_person,  
				       m_class.del_flag  
				  FROM m_class  
				 WHERE m_class.member_id = '#url.m_id#'
					   <!---m_class.send_flag = 0---> 		
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_class.modify_date >= '#qGetLastSendDate.lsd#' OR m_class.create_date >= '#qGetLastSendDate.lsd#' OR m_class.del_date >= '#qGetLastSendDate.lsd#')
					 </cfif>						 
				 </cfquery>
				 	<cfset recordCount = #qGetClass.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetClass.class_id[cnt]# & ","
										 & #qGetClass.class_name[cnt]# & ","
										 & #qGetClass.class_name_kana[cnt]# & ","									 
										 & #qGetClass.division_id[cnt]# & ","
										 & #qGetClass.depart_id[cnt]# & ","
										 & #qGetClass.line_id[cnt]# & ","
										 & #qGetClass.create_date[cnt]# & ","
										 & #qGetClass.create_account[cnt]# & ","
										 & #qGetClass.create_person[cnt]# & ","
										 & #qGetClass.modify_date[cnt]# & ","
										 & #qGetClass.modify_account[cnt]# & ","
										 & #qGetClass.modify_person[cnt]# & ","
										 & #qGetClass.del_flag[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdClass">
								  UPDATE m_class  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_class.class_id = '#qGetClass.class_id[cnt]#'
							</cfquery> --->
																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_class = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>
		
		<!--- 担当者マスタ --->
		<cffunction name="getEmployee" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = qGetNow.now>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_employee AS lsd,
					   CASE WHEN last_send_date_employee <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#'
				   AND shop_id ='#shop_id#' 
				   AND regi_id ='#url.r_id#'
				   <!--- 
				   AND shop_id ='#shop_id#'
				    --->
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qGetEmployee">
				  SELECT m_employee.employee_id,   
				         m_employee.employee_last_name,   
				         m_employee.employee_first_name,   
				         m_employee.employee_last_name_kana,   
				         m_employee.employee_first_name_kana,   
				         m_employee.employment_type,   
				         m_employee.dept,   
				         m_employee.post,   
				         m_employee.zip_code,   
				         m_employee.address1,   
				         m_employee.address2,   
				         m_employee.address1_kana,   
				         m_employee.address2_kana,   
				         m_employee.phone,   
				         m_employee.cell_phone,   
				         m_employee.fax,   
				         m_employee.email,   
				         m_employee.birthday,   
				         m_employee.sex,   
				         m_employee.blood_type,   
				         m_employee.enter_date,   
				         m_employee.resign_date,   
				         ifnull(m_employee.pos_authority_id,0) as pos_authority_id,   
				         m_employee.pos_login_id,   
				         m_employee.pos_login_password,   
				         m_employee.admin_flag,   
				         m_employee.memo,   
				         m_employee.create_date,   
				         m_employee.create_account,   
				         m_employee.create_person,   
				         m_employee.modify_date,   
				         m_employee.modify_account,   
				         m_employee.modify_person,  
				         m_employee.del_flag  
				    FROM m_employee,
				         ( SELECT COUNT(m_employee.employee_id) as e_count
				             FROM m_employee
				            WHERE member_id = '#url.m_id#'
						 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
				         	AND (m_employee.modify_date >= '#qGetLastSendDate.lsd#' OR m_employee.create_date >= '#qGetLastSendDate.lsd#' OR m_employee.del_date >= '#qGetLastSendDate.lsd#')
						 </cfif>) ME 
				   WHERE ME.e_count > 0
				   AND m_employee.member_id = '#url.m_id#'
				   AND m_employee.pos_login_id IS NOT NULL AND m_employee.pos_login_password IS NOT NULL
					  <!---
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_employee.modify_date >= '#qGetLastSendDate.lsd#' OR m_employee.create_date >= '#qGetLastSendDate.lsd#' OR m_employee.del_date >= '#qGetLastSendDate.lsd#')
					 </cfif>
					--->



					 <!---					     		
					 <cfif #shop_id# neq "">
			         	AND (m_employee.shop_id IS NULL OR m_employee.shop_id = "#shop_id#")
					 </cfif>
					 --->						 
			</cfquery>
				 	<cfset recordCount = #qGetEmployee.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetEmployee.employee_id[cnt]# & ","
										 & #qGetEmployee.employee_last_name[cnt]# & ","
										 & #qGetEmployee.employee_first_name[cnt]# & ","									 
										 & #qGetEmployee.employee_last_name_kana[cnt]# & ","
										 & #qGetEmployee.employee_first_name_kana[cnt]# & ","
										 & #qGetEmployee.employment_type[cnt]# & ","
										 & #qGetEmployee.dept[cnt]# & ","
										 & #qGetEmployee.post[cnt]# & ","
										 & #qGetEmployee.zip_code[cnt]# & ","
										 & #qGetEmployee.address1[cnt]# & ","
										 & #qGetEmployee.address2[cnt]# & ","
										 & #qGetEmployee.address1_kana[cnt]# & ","
										 & #qGetEmployee.address2_kana[cnt]# & ","
										 & #qGetEmployee.phone[cnt]# & ","
										 & #qGetEmployee.cell_phone[cnt]# & ","
										 & #qGetEmployee.admin_flag[cnt]# & ","
										 & #qGetEmployee.fax[cnt]# & ","
										 & #qGetEmployee.email[cnt]# & ","
										 & #qGetEmployee.birthday[cnt]# & ","
										 & #qGetEmployee.sex[cnt]# & ","
										 & #qGetEmployee.blood_type[cnt]# & ","
										 & #qGetEmployee.enter_date[cnt]# & ","
										 & #qGetEmployee.resign_date[cnt]# & ","										 
										 & #qGetEmployee.pos_login_id[cnt]# & ","
										 & #qGetEmployee.pos_login_password[cnt]# & ","
										 & #qGetEmployee.pos_authority_id[cnt]# & ","										 
										 & #qGetEmployee.memo[cnt]# & ","
										 & #qGetEmployee.create_date[cnt]# & ","
										 & #qGetEmployee.create_account[cnt]# & ","
										 & #qGetEmployee.create_person[cnt]# & ","
										 & #qGetEmployee.modify_date[cnt]# & ","
										 & #qGetEmployee.modify_account[cnt]# & ","
										 & #qGetEmployee.modify_person[cnt]# & ","
										 & #qGetEmployee.del_flag[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>						
								
							
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdEmployee">
								  UPDATE m_employee  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_employee.employee_id = '#qGetEmployee.employee_id[cnt]#'
							</cfquery>	 --->																
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_employee = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>									 
			<cfreturn #output# >
		</cffunction>
		
		<!--- 機能マスタ --->
		<cffunction name="getFunction" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_function AS lsd,
					   CASE WHEN last_send_date_function <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>

			<cfquery datasource="#application.dsn#" name="qGetFunction">
				SELECT m_function.function_num,   
					   m_function.function_name,   
					   m_function.create_date,   
					   m_function.create_account,   
					   m_function.create_person,   
					   m_function.modify_date,   
					   m_function.modify_account,   
					   m_function.modify_person  
				  FROM m_function,
					( SELECT COUNT(m_function.function_num) as function_count
						FROM m_function
					   WHERE member_id = '#url.m_id#' <!---AND m_function.send_flag = 0--->
					 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
			         	AND (m_function.modify_date >= '#qGetLastSendDate.lsd#' OR m_function.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>					   
					    ) MF 
				 WHERE member_id = '#url.m_id#' AND MF.function_count > 0		
						 
				 </cfquery>
				 	<cfset recordCount = qGetFunction.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetFunction.function_num[cnt] & ","
										 & qGetFunction.function_name[cnt] & ","
										 & qGetFunction.create_date[cnt] & ","
										 & qGetFunction.create_account[cnt] & ","
										 & qGetFunction.create_person[cnt] & ","
										 & qGetFunction.modify_date[cnt] & ","
										 & qGetFunction.modify_account[cnt] & ","
										 & qGetFunction.modify_person[cnt] & chr(10)>								 
							<cfset output = output & data>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdFunction">
								 UPDATE m_function  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_function.function_num = '#qGetFunction.function_num[cnt]#'
							</cfquery> --->																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_function = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'							     
				</cfquery>				 
			<cfreturn output >
		</cffunction>
		
		<!--- キーボードマスタ --->
		<cffunction name="getKeyboad" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_keyboard AS lsd,
					   CASE WHEN last_send_date_keyboard <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetKeyboad">
				  SELECT m_keyboad.regi_id,   
				         m_keyboad.key_num,   
				         m_keyboad.function_num,   
				         m_keyboad.create_date,   
				         m_keyboad.create_account,   
				         m_keyboad.create_person,   
				         m_keyboad.modify_date,   
				         m_keyboad.modify_account,   
				         m_keyboad.modify_person,  
				         m_keyboad.color_r,  
				         m_keyboad.color_g,  
				         m_keyboad.color_b  
				    FROM m_keyboad,   
				         ( SELECT m_keyboad.regi_id,
				                  COUNT(m_keyboad.key_num) as key_count
				             FROM m_keyboad
				            WHERE member_id = '#url.m_id#'  AND regi_id ='#url.r_id#'  AND shop_id ='#shop_id#'<!---AND m_keyboad.send_flag = 0--->
						 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
				         	AND (m_keyboad.modify_date >= '#qGetLastSendDate.lsd#' OR m_keyboad.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>								
				         GROUP BY m_keyboad.regi_id ) MK 
				   WHERE member_id = '#url.m_id#' AND 
				         m_keyboad.regi_id = MK.regi_id AND
				         m_keyboad.shop_id = '#shop_id#' AND
				         m_keyboad.regi_id = '#url.r_id#' AND
				         MK.key_count > 0		
						 
				 </cfquery>
				 	<cfset recordCount = #qGetKeyboad.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetKeyboad.regi_id[cnt]# & ","
										 & #qGetKeyboad.key_num[cnt]# & ","
										 & #qGetKeyboad.function_num[cnt]# & ","								 										 										 
										 & #qGetKeyboad.create_date[cnt]# & ","
										 & #qGetKeyboad.create_account[cnt]# & ","
										 & #qGetKeyboad.create_person[cnt]# & ","
										 & #qGetKeyboad.modify_date[cnt]# & ","
										 & #qGetKeyboad.modify_account[cnt]# & ","
										 & #qGetKeyboad.modify_person[cnt]# & ","
										 & #qGetKeyboad.color_r[cnt]# & ","
										 & #qGetKeyboad.color_g[cnt]# & ","
										 & #qGetKeyboad.color_b[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdKeyboad">
								 UPDATE m_keyboad  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_keyboad.regi_id = '#qGetKeyboad.regi_id[cnt]#'
								    AND shop_id = '#shop_id#'
									AND key_num = '#qGetKeyboad.key_num[cnt]#'
							</cfquery> --->																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_keyboard = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>
		
		<!--- PLUマスタ --->
		<cffunction name="getPlu" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_plu AS lsd,
					   CASE WHEN last_send_date_plu <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetPlu">
				  SELECT m_plu.regi_id,   
				         m_plu.page_num,   
				         m_plu.plu_num,   
				         m_plu.page_name,   
				         m_plu.jan,
				         m_plu.color_red,
				         m_plu.color_green,
				         m_plu.color_blue,
				         m_plu.page_color_red,
				         m_plu.page_color_green,
				         m_plu.page_color_blue,
				         m_plu.image_flag,				            
				         m_plu.create_date,   
				         m_plu.create_account,   
				         m_plu.create_person,   
				         m_plu.modify_date,   
				         m_plu.modify_account,   
				         m_plu.modify_person,
						 MJAN.plu_name,
						 MJAN.plu_name2,
						 MJAN.img_ext				           
				    FROM m_plu LEFT OUTER JOIN 
				    					(SELECT m_jan.member_id,m_jan.jan,m_jan.product_id,m_product.plu_name,m_product.plu_name2,m_product.img_ext 
				    					   FROM m_jan LEFT OUTER JOIN m_product ON m_jan.member_id = m_product.member_id 
				    					                          			   AND m_jan.product_id = m_product.product_id
				    					   WHERE m_jan.member_id = '#url.m_id#' 
				    					) MJAN 
				    		   ON m_plu.member_id = MJAN.member_id AND m_plu.jan = MJAN.jan,
				         ( SELECT m_plu.regi_id,m_plu.member_id,
				                  COUNT(m_plu.plu_num) as plu_count
				             FROM m_plu
				            WHERE m_plu.member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'<!---AND m_plu.send_flag = 0--->
						 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
				         	AND (m_plu.modify_date >= '#qGetLastSendDate.lsd#' OR m_plu.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>																
				         GROUP BY m_plu.regi_id ) MP 
				   WHERE m_plu.member_id = MP.member_id AND 
				         m_plu.regi_id = MP.regi_id AND
				         m_plu.member_id = '#url.m_id#' AND
						 m_plu.regi_id = '#url.r_id#' AND
						 m_plu.shop_id ='#shop_id#' AND
				         MP.plu_count > 0		
						 
				 </cfquery>
				 	<cfset recordCount = qGetPlu.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetPlu.regi_id[cnt] & ","
										 & qGetPlu.page_num[cnt] & ","
										 & qGetPlu.plu_num[cnt] & ","
										 & qGetPlu.page_name[cnt] & ","
										 & qGetPlu.jan[cnt] & ","
										 & qGetPlu.create_date[cnt] & ","
										 & qGetPlu.create_account[cnt] & ","
										 & qGetPlu.create_person[cnt] & ","
										 & qGetPlu.modify_date[cnt] & ","
										 & qGetPlu.modify_account[cnt] & ","
										 & qGetPlu.modify_person[cnt] & ","
										 & qGetPlu.color_red[cnt] & ","
										 & qGetPlu.color_green[cnt] & ","
										 & qGetPlu.color_blue[cnt] & ","
										 & qGetPlu.page_color_red[cnt] & ","
										 & qGetPlu.page_color_green[cnt] & ","
										 & qGetPlu.page_color_blue[cnt] & ","
										 & qGetPlu.plu_name[cnt] & ","
										 & qGetPlu.plu_name2[cnt] & ","
										 & qGetPlu.image_flag[cnt] & ","
										 & qGetPlu.img_ext[cnt] & chr(10)
										 >								 
							<cfset output = output & data>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdPLU">
								 UPDATE m_plu  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND regi_id = '#qGetPlu.regi_id[cnt]#'
									AND page_num = '#qGetPlu.page_num[cnt]#'
									AND plu_num = '#qGetPlu.plu_num[cnt]#'
							</cfquery>	 --->																
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_plu = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>		

		<!--- 管理マスタ --->
		<cffunction name="getAdmin" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>			
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_admin AS lsd,
					   DATE_FORMAT(limit_date,'%Y/%m/%d') as char_limit_date,					  
					   CASE WHEN last_send_date_admin <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				 FROM m_regi 
				WHERE member_id = '#url.m_id#' 
				  AND regi_id ='#url.r_id#'
				  AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetAdmin">	
				  SELECT m_shop.shop_id,   
				         m_shop.shop_name_ryaku shop_name,
				         m_shop.shop_name official_shop_name,   
				         RTRIM(LTRIM(CONCAT(IFNULL(m_shop.address1, ''),' ',IFNULL(m_shop.address2, '')))) as shop_address,   
				         m_shop.phone,   
				         m_shop.fax,
				         DATE_FORMAT(m_shop.open_time,'%H:%i') as open_time,
				         DATE_FORMAT(m_shop.close_time,'%H:%i') as close_time,
				         m_regi.customer_display_flag,
				         m_regi.credit_interlock_flag,   
				         m_admin.receipt_word,   
				         m_admin.admin_num,   
				         m_admin.tax_rate,   
				         m_admin.tax_rounding,   
				         m_admin.price_rounding,   
				         m_admin.tax_class,   
				         m_admin.stock_flag,   
				         m_admin.merge_flag,   
				         m_admin.cook_flag,   
				         m_admin.unit_price_discount_flag,   
				         m_admin.unit_percent_discount_flag,   
				         m_admin.amount_price_discount_flag,   
				         m_admin.amount_percent_discount_flag,   
				         m_admin.exchange_flag,   
				         m_admin.modify_price_flag,   
				         m_admin.receipt_auto_print_flag,   
				         m_admin.receipt_flag,   
				         m_admin.sound_flag,   
				         m_admin.return_flag,   
				         m_admin.open_change_flag,   
				         m_admin.change_total,   
				         m_admin.change_10000,   
				         m_admin.change_5000,   
				         m_admin.change_2000,   
				         m_admin.change_1000,   
				         m_admin.change_500,   
				         m_admin.change_100,   
				         m_admin.change_50,   
				         m_admin.change_10,   
				         m_admin.change_5,   
				         m_admin.change_1,   
				         m_admin.point_flag,   
				         m_admin.point_per_amount,   
				         m_admin.amount_per_point,   
				         m_admin.point_unit,   
				         m_admin.point_border,  
				         m_admin.logo_file_name,
				         m_admin.close_change_flag,   
				         m_admin.receipt_layout_type,
				         m_admin.tax_calc_first_flag,
				         m_admin.division_flag,
				         m_admin.in_store_code,
				         m_admin.product_id_digit,
				         m_admin.debate_flag,
				         m_regi.regi_mode,
				         m_currency.decimal_place,
				         m_admin.pos_login_timeout,
				         m_admin.country_id,
				         m_admin.service_charge_rate,
				         m_admin.service_charge_flag,
				         m_admin.service_charge_rounding,
				         
				         CASE WHEN m_shop.uniform_num IS NOT NULL 
				              THEN m_shop.uniform_num 
				              ELSE m_admin.uniform_num
				              END AS uniform_num,
				         
				         m_admin.uniform_invoice_flag,
				         m_admin.uniform_invoice_detail_print_flag,
				         m_admin.ui_amount_0_print_class,
				         m_admin.opt_cnt_print_flag,
				         m_admin.kitchen_order_1by1_cut_flag,
				         m_admin.staff_login_confirm_flag,
				         m_admin.receipt_rtn_print_flag,
				         m_admin.bill_rtn_print_flag,
				         m_admin.timecard_flag,
				         m_admin.timecard_disp_sec_flag,
				         m_admin.table_amount_disp_flag,
				         m_admin.receipt_merge_flag,
				         DATE_FORMAT(m_admin.work_date_switching_time,'%H:%i') work_date_switching_time,
				         <!---m_admin.work_date_switching_time,--->
				         m_admin.conlux_use_flag,
				         m_admin.use_multiple_tax_rate,
				         m_admin.tax_rate2,
				         m_admin.tax_rate3,
				         m_admin.tax_rate4,
				         m_admin.tax_rate5,
				         m_admin.tax_rate6,
				         m_admin.use_glory_changing_machine,
				         m_regi.changing_machine_div,
				         m_admin.plu_kubun,
				         m_admin.table_layout_custom_flag,
				         m_admin.input_credit_number,
				         m_regi.e_inv_key_number,
				         m_admin.e_inv_safety_num,
				         m_admin.e_inv_get_date,
				         m_admin.e_inv_tax_kubun,
				         m_admin.ask_pass_for_cancel_flag,

				         m_admin.order_summary_print_flag,
				         m_admin.coupon_print_flag,
				         m_admin.coupon_detail_print_flag,
				         m_admin.plu_page_send_over_cate_flag,
				         m_admin.ko_item_size_kbn,
				         m_shop.e_inv_aes_key,
				         m_admin.tax_calc_method,
				         m_admin.tax_print_flag,
				         m_shop.cash_payout_in_closing_flag,
				         m_regi.auto_change_lower_limit_1,
				         m_regi.auto_change_lower_limit_5,
				         m_regi.auto_change_lower_limit_10,
				         m_regi.auto_change_lower_limit_50,
				         m_regi.auto_change_lower_limit_100,
				         m_regi.auto_change_lower_limit_500,
				         m_regi.auto_change_lower_limit_1000,
				         m_regi.auto_change_lower_limit_5000,
				         m_regi.auto_change_lower_limit_10000
				    FROM m_shop,   
				         m_admin,
						 m_regi,
						 m_currency  
				   WHERE m_admin.member_id = m_shop.member_id AND
				   		 m_admin.member_id = m_regi.member_id AND
				   		 m_shop.shop_id = m_regi.shop_id AND
				   		 m_admin.currency_id = m_currency.currency_id AND
						 m_admin.member_id = '#url.m_id#' AND <!---m_admin.admin_num = 1 AND--->
						 m_regi.regi_id = '#url.r_id#' AND
						 m_shop.shop_id = '#shop_id#'
				         <!---( m_shop.send_flag = 0 OR m_admin.send_flag = 0 OR m_regi.send_flag = 0 )--->
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (
							 	(m_admin.modify_date >= '#qGetLastSendDate.lsd#' OR m_admin.create_date >= '#qGetLastSendDate.lsd#') OR 
							 	(m_shop.modify_date >= '#qGetLastSendDate.lsd#' OR m_shop.create_date >= '#qGetLastSendDate.lsd#') OR
								(m_regi.modify_date >= '#qGetLastSendDate.lsd#' OR m_regi.create_date >= '#qGetLastSendDate.lsd#') 
								 )
						 </cfif>						 							 
				 </cfquery>
				 	<cfset recordCount = qGetAdmin.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetAdmin.shop_name[cnt] & ","
										 & qGetAdmin.shop_address[cnt] & ","
										 & qGetAdmin.phone[cnt] & ","
										 & qGetAdmin.fax[cnt] & ","
										 & qGetAdmin.receipt_word[cnt] & ","
										 & qGetAdmin.tax_rate[cnt] & ","
										 & qGetAdmin.tax_rounding[cnt] & ","
										 & qGetAdmin.price_rounding[cnt] & ","
										 & qGetAdmin.tax_class[cnt] & ","
										 & qGetAdmin.stock_flag[cnt] & ","
										 & qGetAdmin.merge_flag[cnt] & ","										 
										 & qGetAdmin.cook_flag[cnt] & ","
										 & qGetAdmin.unit_percent_discount_flag[cnt] & ","
										 & qGetAdmin.unit_price_discount_flag[cnt] & ","
										 & qGetAdmin.amount_percent_discount_flag[cnt] & ","
										 & qGetAdmin.amount_price_discount_flag[cnt] & ","
										 & qGetAdmin.exchange_flag[cnt] & ","
										 & qGetAdmin.modify_price_flag[cnt] & ","
										 & qGetAdmin.receipt_auto_print_flag[cnt] & ","
										 & qGetAdmin.receipt_flag[cnt] & ","
										 & qGetAdmin.sound_flag[cnt] & ","
										 & qGetAdmin.return_flag[cnt] & ","
										 & qGetAdmin.open_change_flag[cnt] & ","
										 & qGetAdmin.change_total[cnt] & ","
										 & qGetAdmin.change_10000[cnt] & ","
										 & qGetAdmin.change_5000[cnt] & ","
										 & qGetAdmin.change_2000[cnt] & ","
										 & qGetAdmin.change_1000[cnt] & ","
										 & qGetAdmin.change_500[cnt] & ","
										 & qGetAdmin.change_100[cnt] & ","
										 & qGetAdmin.change_50[cnt] & ","
										 & qGetAdmin.change_10[cnt] & ","
										 & qGetAdmin.change_5[cnt] & ","										 										 
										 & qGetAdmin.change_1[cnt] & ","
										 & qGetAdmin.point_flag[cnt] & ","
										 & qGetAdmin.point_per_amount[cnt] & ","
										 & qGetAdmin.amount_per_point[cnt] & ","
										 & qGetAdmin.point_unit[cnt] & ","
										 & qGetAdmin.point_border[cnt] & ","										 										 										 										 									 										 										 
										 & qGetAdmin.logo_file_name[cnt] & ","
										 & qGetAdmin.close_change_flag[cnt] & ","
										 & qGetAdmin.receipt_layout_type[cnt] & ","
										 & qGetAdmin.tax_calc_first_flag[cnt] & "," 										 										 
										 & qGetAdmin.open_time[cnt] & ","
										 & qGetAdmin.close_time[cnt] & ","
										 & qGetLastSendDate.char_limit_date & ","
										 & qGetAdmin.division_flag[cnt] & ","
										 & qGetAdmin.customer_display_flag[cnt] & ","
										 & qGetAdmin.credit_interlock_flag[cnt] & ","
										 & qGetAdmin.in_store_code[cnt] & ","
										 & qGetAdmin.product_id_digit[cnt] & ","
										 & qGetAdmin.debate_flag[cnt] & ","
										 & qGetAdmin.regi_mode[cnt] & ","
										 & qGetAdmin.decimal_place[cnt] & ","
										 & 1 & ","
										 & qGetAdmin.pos_login_timeout[cnt] & ","
										 & qGetAdmin.country_id[cnt] & ","
										 & qGetAdmin.service_charge_rate[cnt] & ","
										 & qGetAdmin.uniform_num[cnt] & ","
										 & qGetAdmin.service_charge_flag[cnt] & ","
										 & qGetAdmin.service_charge_rounding[cnt] & ","
										 & qGetAdmin.uniform_invoice_flag[cnt] & ","
										 & qGetAdmin.uniform_invoice_detail_print_flag[cnt] & ","
										 & qGetAdmin.ui_amount_0_print_class[cnt] & ","
										 & qGetAdmin.opt_cnt_print_flag[cnt] & ","
										 & qGetAdmin.kitchen_order_1by1_cut_flag[cnt] & ","
										 & qGetAdmin.staff_login_confirm_flag[cnt] & ","
										 & qGetAdmin.receipt_rtn_print_flag[cnt] & ","
										 & qGetAdmin.bill_rtn_print_flag[cnt] & ","
										 & qGetAdmin.timecard_flag[cnt] & ","
										 & qGetAdmin.timecard_disp_sec_flag[cnt] & ","
										 & qGetAdmin.table_amount_disp_flag[cnt] & ","
										 & qGetAdmin.official_shop_name[cnt] & ","
										 & qGetAdmin.receipt_merge_flag[cnt] & ","
										 & qGetAdmin.work_date_switching_time[cnt] & ","
										 & qGetAdmin.conlux_use_flag[cnt] & ","

										 & qGetAdmin.use_multiple_tax_rate[cnt] & ","
										 & qGetAdmin.tax_rate2[cnt] & ","
										 & qGetAdmin.tax_rate3[cnt] & ","
										 & qGetAdmin.tax_rate4[cnt] & ","
										 & qGetAdmin.tax_rate5[cnt] & ","
										 & qGetAdmin.tax_rate6[cnt] & ","
										 & qGetAdmin.uniform_num[cnt] & ","
										 & qGetAdmin.changing_machine_div[cnt] & ","
										 & qGetAdmin.plu_kubun[cnt] & ","
										 & qGetAdmin.input_credit_number[cnt] & ","
										 & qGetAdmin.table_layout_custom_flag[cnt] & ","
										 & qGetAdmin.e_inv_key_number[cnt] & ","
										 & qGetAdmin.e_inv_safety_num[cnt] & ","
										 & qGetAdmin.e_inv_get_date[cnt] & ","

										 & qGetAdmin.ask_pass_for_cancel_flag[cnt] & ","
										 & qGetAdmin.order_summary_print_flag[cnt] & ","
										 & qGetAdmin.coupon_print_flag[cnt] & ","
										 & qGetAdmin.coupon_detail_print_flag[cnt] & ","
										 & qGetAdmin.plu_page_send_over_cate_flag[cnt] & ","
										 & qGetAdmin.ko_item_size_kbn[cnt] & ","

										 & qGetAdmin.e_inv_aes_key[cnt] & ","
										 & qGetAdmin.tax_calc_method[cnt] & ","
										 & qGetAdmin.tax_print_flag[cnt] & ","

										 & qGetAdmin.cash_payout_in_closing_flag[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_1[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_5[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_10[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_50[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_100[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_500[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_1000[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_5000[cnt] & ","
										 & qGetAdmin.auto_change_lower_limit_10000[cnt] & chr(10)>
										 
							<cfset output = output & data>

							<cfquery datasource="#application.dsn#" name="qUpdAdmin">
								 UPDATE m_admin  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND admin_num = '#qGetAdmin.admin_num[cnt]#'
							</cfquery>
							<cfquery datasource="#application.dsn#" name="qUpdShop">
								 UPDATE m_shop  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND shop_id = '#qGetAdmin.shop_id[cnt]#'
							</cfquery>
							<cfquery datasource="#application.dsn#" name="qUpdRegi">
								 UPDATE m_regi  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND regi_id = '#url.r_id#'
								    AND shop_id ='#shop_id#'
							</cfquery>																															
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_admin = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>									 
			<cfreturn output >
		</cffunction>

		<!--- 値引マスタ --->
		<cffunction name="getDiscountPrice" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_discount_price AS lsd,
					   CASE WHEN last_send_date_discount_price <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetDiscountPrice">
				SELECT m_discount_price.preset_num,
					 m_discount_price.discount_name,   
				     m_discount_price.discount_price,   
				     m_discount_price.create_date,   
				     m_discount_price.create_account,   
				     m_discount_price.create_person,   
				     m_discount_price.modify_date,   
				     m_discount_price.modify_account,   
				     m_discount_price.modify_person  
				FROM m_discount_price,   
				     ( SELECT COUNT(m_discount_price.preset_num) as discount_count
				         FROM m_discount_price
				        WHERE m_discount_price.member_id = '#url.m_id#' <!---AND m_discount_price.send_flag = 0 --->
						 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
				         	AND (m_discount_price.modify_date >= '#qGetLastSendDate.lsd#' OR m_discount_price.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>						
						) MD 
				WHERE m_discount_price.member_id = '#url.m_id#' AND MD.discount_count > 0					 
			</cfquery>
				 	<cfset recordCount = #qGetDiscountPrice.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & #qGetDiscountPrice.preset_num[cnt]# & ","
										 & #qGetDiscountPrice.discount_price[cnt]# & ","
										 & #qGetDiscountPrice.create_date[cnt]# & ","
										 & #qGetDiscountPrice.create_account[cnt]# & ","
										 & #qGetDiscountPrice.create_person[cnt]# & ","
										 & #qGetDiscountPrice.modify_date[cnt]# & ","
										 & #qGetDiscountPrice.modify_account[cnt]# & ","
										 & qGetDiscountPrice.modify_person[cnt] & ","
										 & qGetDiscountPrice.discount_name[cnt] & chr(10)>								 
							<cfset output = output & data>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdDiscountPrice">
								  UPDATE m_discount_price  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_discount_price.preset_num = '#qGetDiscountPrice.preset_num[cnt]#'
							</cfquery>	 --->																
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_discount_price = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>
		
		<!--- 割引マスタ --->
		<cffunction name="getDiscountRate" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_discount_rate AS lsd,
					   CASE WHEN last_send_date_discount_rate <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetDiscountRate">
				SELECT m_discount_rate.preset_num,   
				     m_discount_rate.discount_rate,
				     m_discount_rate.discount_name,   
				     m_discount_rate.create_date,   
				     m_discount_rate.create_account,   
				     m_discount_rate.create_person,   
				     m_discount_rate.modify_date,   
				     m_discount_rate.modify_account,   
				     m_discount_rate.modify_person  
				FROM m_discount_rate,   
				     ( SELECT COUNT(m_discount_rate.preset_num) as discount_count
				         FROM m_discount_rate
				        WHERE m_discount_rate.member_id = '#url.m_id#' <!---AND m_discount_rate.send_flag = 0---> 
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_discount_rate.modify_date >= '#qGetLastSendDate.lsd#' OR m_discount_rate.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>						
						) MD 
				WHERE m_discount_rate.member_id = '#url.m_id#' AND MD.discount_count > 0
					 
			</cfquery>
				 	<cfset recordCount = #qGetDiscountRate.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetDiscountRate.preset_num[cnt]# & ","
										 & #qGetDiscountRate.discount_rate[cnt]# & ","
										 & #qGetDiscountRate.create_date[cnt]# & ","
										 & #qGetDiscountRate.create_account[cnt]# & ","
										 & #qGetDiscountRate.create_person[cnt]# & ","
										 & #qGetDiscountRate.modify_date[cnt]# & ","
										 & #qGetDiscountRate.modify_account[cnt]# & ","
										 & #qGetDiscountRate.modify_person[cnt]# & ","
										 & #qGetDiscountRate.discount_name[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdDiscountRate">
								  UPDATE m_discount_rate  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_discount_rate.preset_num = '#qGetDiscountRate.preset_num[cnt]#'
							</cfquery> --->																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_discount_rate = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn #output# >
		</cffunction>

		
		<!--- 入出金理由マスタ --->
		<cffunction name="getMoneyInoutReason" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_money_inout_reason AS lsd,
					   CASE WHEN last_send_date_money_inout_reason <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetMoneyInoutReason">				
				SELECT m_money_inout_reason.money_inout_reason_num,   
				     m_money_inout_reason.money_inout_reason_name,   
				     m_money_inout_reason.create_date,   
				     m_money_inout_reason.create_account,   
				     m_money_inout_reason.create_person,   
				     m_money_inout_reason.modify_date,   
				     m_money_inout_reason.modify_account,   
				     m_money_inout_reason.modify_person   
				FROM m_money_inout_reason,   
				     ( SELECT COUNT(m_money_inout_reason.money_inout_reason_num) as reason_count
				         FROM m_money_inout_reason
				        WHERE m_money_inout_reason.member_id = '#url.m_id#' <!---AND m_money_inout_reason.send_flag = 0---> 
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_money_inout_reason.modify_date >= '#qGetLastSendDate.lsd#' OR m_money_inout_reason.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>						
						) MR 
				WHERE m_money_inout_reason.member_id = '#url.m_id#' AND MR.reason_count > 0									 
			</cfquery>
			
				 	<cfset recordCount = #qGetMoneyInoutReason.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetMoneyInoutReason.money_inout_reason_num[cnt]# & ","
										 & #qGetMoneyInoutReason.money_inout_reason_name[cnt]# & ","
										 & #qGetMoneyInoutReason.create_date[cnt]# & ","
										 & #qGetMoneyInoutReason.create_account[cnt]# & ","
										 & #qGetMoneyInoutReason.create_person[cnt]# & ","
										 & #qGetMoneyInoutReason.modify_date[cnt]# & ","
										 & #qGetMoneyInoutReason.modify_account[cnt]# & ","
										 & #qGetMoneyInoutReason.modify_person[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdMoneyInoutReason">
								  UPDATE m_money_inout_reason  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE member_id = '#url.m_id#'
								    AND m_money_inout_reason.money_inout_reason_num = '#qGetMoneyInoutReason.money_inout_reason_num[cnt]#'
							</cfquery> --->																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_money_inout_reason = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>									 
			<cfreturn #output# >
		</cffunction>
		
		
		<!--- プリンタマスタ(全顧客共通のためmember_id不要) --->
		<cffunction name="getPrinter" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_printer AS lsd,
					   CASE WHEN last_send_date_printer <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'
			</cfquery>			
			<cfquery datasource="#application.dsn#" name="qGetPrinter">				
				SELECT m_printer.printer_id,   
				     m_printer.printer_maker_name,   
				     m_printer.printer_name,
				     m_printer.ios,
				     m_printer.android,
				     m_printer.windows,
				     m_printer.sort_order,
				     m_printer.memo,
				     m_printer.journal,
				     m_printer.kitchen,
				     m_printer.uniform,
				     m_printer.create_date,   
				     m_printer.create_account,   
				     m_printer.create_person,   
				     m_printer.modify_date,   
				     m_printer.modify_account,   
				     m_printer.modify_person,
				     m_printer.con_kubun   
				FROM m_printer,   
				     ( SELECT COUNT(m_printer.printer_id) as printer_count
				         FROM m_printer
				        WHERE 0=0
				          AND member_id = "#url.m_id#" 
					 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
			         	AND (m_printer.modify_date >= '#qGetLastSendDate.lsd#' OR m_printer.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>				        
				        ) MP 
				WHERE m_printer.member_id = "#url.m_id#" AND MP.printer_count > 0									 
			</cfquery>
			
				 	
				 	<cfset recordCount = qGetPrinter.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetPrinter.printer_id[cnt] & ","
										 & qGetPrinter.printer_maker_name[cnt] & ","
										 & qGetPrinter.printer_name[cnt] & ","
										 & qGetPrinter.memo[cnt] & ","
										 & qGetPrinter.con_kubun[cnt] & ","
										 & qGetPrinter.sort_order[cnt] & ","
										 & qGetPrinter.ios[cnt] & ","
										 & qGetPrinter.android[cnt] & ","
										 & qGetPrinter.windows[cnt] & ","
										 & qGetPrinter.journal[cnt] & ","
										 & qGetPrinter.kitchen[cnt] & ","
										 & qGetPrinter.uniform[cnt] & chr(10)>							 
							<cfset output = output & data>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdPrinter">
								  UPDATE m_printer  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE m_printer.printer_id = '#qGetPrinter.printer_id[cnt]#'
							</cfquery> --->																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_printer = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>									 
			<cfreturn output >
		</cffunction>														



		<!--- クレジットマスタ(全顧客共通のためmember_id不要) --->
		<cffunction name="getCredit" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>
			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = qGetNow.now>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_credit AS lsd,
					   CASE WHEN last_send_date_credit <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all				 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'
			</cfquery>			
			<cfquery datasource="#application.dsn#" name="qGetCredit">				
				SELECT 
					 m_credit.credit_id,  
				     m_credit.credit_name,
				     m_credit.create_date,   
				     m_credit.create_account,   
				     m_credit.create_person,   
				     m_credit.modify_date,   
				     m_credit.modify_account,   
				     m_credit.modify_person   
				FROM m_credit,   
				     ( SELECT COUNT(m_credit.credit_id) as credit_count
				         FROM m_credit
				        WHERE m_credit.member_id = '#url.m_id#'
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_credit.modify_date >= '#qGetLastSendDate.lsd#' OR m_credit.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>				        
				        ) MC 
				WHERE m_credit.member_id = '#url.m_id#' AND MC.credit_count > 0									 
			</cfquery>
			
				 	<cfset recordCount = #qGetCredit.RecordCount#>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = #shop_id# & ","
										 & #qGetCredit.credit_id[cnt]# & ","
										 & #qGetCredit.credit_name[cnt]# & ","
										 & #qGetCredit.create_date[cnt]# & "," 
										 & #qGetCredit.create_account[cnt]# & ","
										 & #qGetCredit.create_person[cnt]# & "," 
										 & #qGetCredit.modify_date[cnt]# & ","
										 & #qGetCredit.modify_account[cnt]# & ","   
										 & #qGetCredit.modify_person[cnt]# & #chr(10)#>								 
							<cfset output = #output# & #data#>
						
<!--- 							<cfquery datasource="#application.dsn#" name="qUpdCredit">
								  UPDATE m_credit  
			  						SET send_flag    = 1,   
							  			send_date = '#now#',  
										send_person  = 'AUTO'  
								  WHERE m_credit.member_id = '#url.m_id#' AND m_credit.credit_id = '#qGetCredit.credit_id[cnt]#'
							</cfquery> --->																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_credit = '#now#'  
					  WHERE member_id = '#url.m_id#' AND regi_id ='#url.r_id#' AND shop_id ='#shop_id#'								     
				</cfquery>									 
			<cfreturn #output# >
		</cffunction>

		<!--- オプションマスタ --->
		<cffunction name="getOption" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_option AS lsd,
					   CASE WHEN last_send_date_option <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all,
					   regi_mode					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#'
				   AND shop_id ='#shop_id#' 
				   AND regi_id ='#url.r_id#'
				   
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetOption">
				SELECT m_option.option_id,   
					   m_option.option_name,   
					   m_option.product_id,   
					   m_option.select_method, 
					   m_option.create_date,  
					   m_option.create_account,   
					   m_option.create_person,   
					   m_option.modify_date,   
					   m_option.modify_account,   
					   m_option.modify_person,  
					   m_option.del_flag  
				  FROM m_option ,
				  	  ( SELECT COUNT(m_option.option_id) as option_count
				         FROM m_option
				        WHERE m_option.member_id = '#url.m_id#'
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_option.modify_date >= '#qGetLastSendDate.lsd#' OR m_option.create_date >= '#qGetLastSendDate.lsd#')
					 </cfif>				        
				        ) MC 
				        WHERE m_option.member_id = '#url.m_id#' AND MC.option_count > 0
					<!--- レジモードがリテールの場合送らないようにする --->				     
				     <cfif qGetLastSendDate.regi_mode eq 1 or qGetLastSendDate.regi_mode eq 4>
					     AND 1 = 0
				     </cfif>					   							 
				 </cfquery>
				 	<cfset recordCount = qGetOption.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetOption.option_id[cnt] & ","
										 & qGetOption.option_name[cnt] & ","
										 & qGetOption.product_id[cnt] & ","									 
										 & qGetOption.select_method[cnt] & ","
										 & qGetOption.create_date[cnt] & ","
										 & qGetOption.create_account[cnt] & ","
										 & qGetOption.create_person[cnt] & ","
										 & qGetOption.modify_date[cnt] & ","
										 & qGetOption.modify_account[cnt] & ","
										 & qGetOption.modify_person[cnt] & ","
										 & qGetOption.del_flag[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_option = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>

		<!--- プロパティマスタ --->
		<cffunction name="getProperty" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_property AS lsd,
					   CASE WHEN last_send_date_property <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all,
					   regi_mode					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetProperty">
				SELECT m_property.property_id,   
					   m_property.property_name,
					   m_property.property_short_name,   
					   m_property.option_id,   
					   m_property.unit_price_without_tax,
					   m_property.unit_price_include_tax,
					   m_property.unit_price_tax,
					   m_product.tax_class, 
					   m_property.create_date,   
					   m_property.create_account,   
					   m_property.create_person,   
					   m_property.modify_date,   
					   m_property.modify_account,   
					   m_property.modify_person,  
					   m_property.del_flag,
					   m_property.product_id  
				  FROM m_property LEFT OUTER JOIN m_product ON m_property.member_id = m_product.member_id
													        AND m_property.product_id = m_product.product_id
					   ,( SELECT COUNT(m_property.property_id) as property_count
				         FROM m_property
				        WHERE m_property.member_id = '#url.m_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_property.modify_date >= '#qGetLastSendDate.lsd#' OR m_property.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>				        
				        ) MP 
				        WHERE m_property.member_id = '#url.m_id#' AND MP.property_count > 0
					     <cfif qGetLastSendDate.regi_mode eq 1 or qGetLastSendDate.regi_mode eq 4>
						     AND 1 = 0
					     </cfif>				        
				 </cfquery>				 
				 	<cfset recordCount = qGetProperty.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetProperty.property_id[cnt] & ","
										 & qGetProperty.property_name[cnt] & ","
										 & qGetProperty.option_id[cnt] & ","									 
										 & qGetProperty.tax_class[cnt] & ","
										 & qGetProperty.unit_price_without_tax[cnt] & ","
										 & qGetProperty.unit_price_include_tax[cnt] & ","
										 & qGetProperty.unit_price_tax[cnt] & ","
										 & qGetProperty.create_date[cnt] & ","
										 & qGetProperty.create_account[cnt] & ","
										 & qGetProperty.create_person[cnt] & ","
										 & qGetProperty.modify_date[cnt] & ","
										 & qGetProperty.modify_account[cnt] & ","
										 & qGetProperty.modify_person[cnt] & ","
										 & qGetProperty.del_flag[cnt] & ","
										 & qGetProperty.product_id[cnt] & ","
										 & qGetProperty.property_short_name[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_property = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>

		<!--- メッセージマスタ --->
		<cffunction name="getMessage" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_message AS lsd,
					   CASE WHEN last_send_date_message <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetMessage">
				SELECT m_message.message_id,   
					   m_message.message, 
					   m_message.create_date,   
					   m_message.create_account,   
					   m_message.create_person,   
					   m_message.modify_date,   
					   m_message.modify_account,   
					   m_message.modify_person,  
					   m_message.del_flag
				  FROM m_message,
				       ( SELECT COUNT(m_message.message_id) as message_count
				         FROM m_message
				        WHERE m_message.member_id = '#url.m_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_message.modify_date >= '#qGetLastSendDate.lsd#' OR m_message.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>				        
				        ) MS 
				        WHERE m_message.member_id = '#url.m_id#' AND MS.message_count > 0					   
				 <!---  
				  FROM m_message
				 WHERE m_message.member_id = '#url.m_id#'
					   <!---m_message.send_flag = 0	--->
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_message.modify_date >= '#qGetLastSendDate.lsd#' OR m_message.create_date >= '#qGetLastSendDate.lsd#' OR m_message.del_date >= '#qGetLastSendDate.lsd#')
					 </cfif>
					 	--->
				 </cfquery>
				 	<cfset recordCount = qGetMessage.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetMessage.message_id[cnt] & ","
										 & qGetMessage.message[cnt] & ","
										 & qGetMessage.create_date[cnt] & ","
										 & qGetMessage.create_account[cnt] & ","
										 & qGetMessage.create_person[cnt] & ","
										 & qGetMessage.modify_date[cnt] & ","
										 & qGetMessage.modify_account[cnt] & ","
										 & qGetMessage.modify_person[cnt] & ","
										 & qGetMessage.del_flag[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_message = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>


		<!--- テーブルマスタ --->
		<cffunction name="getTable" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_table AS lsd,
					   CASE WHEN last_send_date_message <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetTable">
				SELECT m_table.table_id,   
					   m_table.table_name,
					   m_table.seat_num,
					   m_table.color_red,
					   m_table.color_green,
					   m_table.color_blue,
					   m_table.create_date,   
					   m_table.create_account,   
					   m_table.create_person,   
					   m_table.modify_date,   
					   m_table.modify_account,   
					   m_table.modify_person,  
					   m_table.del_flag  
				  FROM m_table,
				       ( SELECT COUNT(m_table.table_id) as table_count
				         FROM m_table
				        WHERE m_table.member_id = '#url.m_id#'
				         AND m_table.shop_id ='#shop_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_table.modify_date >= '#qGetLastSendDate.lsd#' OR m_table.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>				        
				        ) MT 
				        WHERE m_table.member_id = '#url.m_id#'
				         AND m_table.shop_id ='#shop_id#' 
				         AND MT.table_count > 0
				  <!--- 
				  FROM m_table 
				 WHERE m_table.member_id = '#url.m_id#'
					   <!---m_table.send_flag = 0	--->
					 <cfif #qGetLastSendDate.lsd# neq "" AND #qGetLastSendDate.send_all# neq 1>
			         	AND (m_table.modify_date >= '#qGetLastSendDate.lsd#' OR m_table.create_date >= '#qGetLastSendDate.lsd#' OR m_table.del_date >= '#qGetLastSendDate.lsd#')
					 </cfif>
					 	--->					   							 
				 </cfquery>
				 	<cfset recordCount = qGetTable.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetTable.table_id[cnt] & ","
										 & qGetTable.table_name[cnt] & ","
										 & qGetTable.seat_num[cnt] & ","
										 & qGetTable.create_date[cnt] & ","
										 & qGetTable.create_account[cnt] & ","
										 & qGetTable.create_person[cnt] & ","
										 & qGetTable.modify_date[cnt] & ","
										 & qGetTable.modify_account[cnt] & ","
										 & qGetTable.modify_person[cnt] & ","
										 & qGetTable.del_flag[cnt] & ","
										 & qGetTable.color_red[cnt] & ","
										 & qGetTable.color_green[cnt] & ","
										 & qGetTable.color_blue[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_table = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>

		<!--- プリンタマッピングマスタ --->
		<cffunction name="getPrinterMapping" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_printer_mapping AS lsd,
					   CASE WHEN last_send_date_printer_mapping <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetPrinterMapping">
				SELECT m_printer_mapping.printer_map_id,   
					   m_printer_mapping.printer_map_name, 
					   m_printer_mapping.printer_id,
					   m_printer_mapping.device_name
				  FROM m_printer_mapping,
				       ( SELECT COUNT(m_printer_mapping.printer_map_id) as cnt
				         FROM m_printer_mapping
				        WHERE m_printer_mapping.member_id = '#url.m_id#' AND m_printer_mapping.shop_id ='#shop_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_printer_mapping.modify_date >= '#qGetLastSendDate.lsd#' OR m_printer_mapping.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>				        
				        ) MS 
				        WHERE m_printer_mapping.member_id = '#url.m_id#' AND m_printer_mapping.shop_id ='#shop_id#' AND MS.cnt > 0
				 </cfquery>
				 	<cfset recordCount = qGetPrinterMapping.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = shop_id & ","
										 & qGetPrinterMapping.printer_map_id[cnt] & ","
										 & qGetPrinterMapping.printer_map_name[cnt] & ","
										 & qGetPrinterMapping.printer_id[cnt] & ","
										 & qGetPrinterMapping.device_name[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
					
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_printer_mapping = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>



		<!--- 支払い方法マスタ --->
		<cffunction name="getPayment" access="remote" returnFormat="plain">
			<cfset shop_id = url.sp_id>
            <cfquery name="qGetOffset" datasource="#application.dsn#">
                SELECT m_time_zone.utc_offset 
                  FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
                 WHERE member_id = "#url.m_id#"
            </cfquery>
            <cfset utc_offset = qGetOffset.utc_offset>

			<!--- アプリ立ち上げの一発目は必ず全受信にする --->
			<cfif StructKeyExists(url, "all") and url.all eq 1>
				<cfquery name="qUpdSendAllFlag" datasource="#application.dsn#">
					UPDATE m_regi 
					   SET send_all_setting_date = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
					       send_all_setting_person = "system"
				     WHERE member_id = '#url.m_id#' AND shop_id = '#shop_id#'  AND regi_id = '#url.r_id#'
				</cfquery>				
			</cfif>			
			<cfquery datasource="#application.dsn#" name="qGetNow">
				SELECT ADDTIME(UTC_TIMESTAMP(),"#utc_offset#") AS now FROM dual
			</cfquery>
			<cfset now = #qGetNow.now#>						
			<cfquery datasource="#application.dsn#" name="qGetLastSendDate">
				SELECT last_send_date_payment_method AS lsd,
					   CASE WHEN last_send_date_payment_method <= send_all_setting_date
					        then 1
					        else 0
					   END AS send_all					 
				  FROM m_regi 
				 WHERE member_id = '#url.m_id#' 
				   AND regi_id ='#url.r_id#'
				   AND shop_id ='#shop_id#'
			</cfquery>
						
			<cfquery datasource="#application.dsn#" name="qGetPaymentMethod">
				SELECT 
					   m_receipt_method_sales.receipt_method_id,
						m_receipt_method_sales.receipt_method_name1,
						m_receipt_method_sales.receipt_method_name2,
						m_receipt_method_sales.receipt_method_name3,
						m_receipt_method_sales.receipt_method_name4,
						m_receipt_method_sales.receipt_method_name5,
						m_receipt_method_sales.receipt_method_name6,
						m_receipt_method_sales.sort_order,
						m_receipt_method_sales.tw_remove_from_ui_flag,
						m_receipt_method_sales.changeable_flag,
						m_receipt_method_sales.function_num,
						m_receipt_method_sales.amount_input_flag,
						m_receipt_method_sales.multiple_method_flag,
						m_receipt_method_sales.money_on_hand_flag,
						m_receipt_method_sales.color_red,
						m_receipt_method_sales.color_green,
						m_receipt_method_sales.color_blue,
						m_receipt_method_sales.payment_amount,
						m_receipt_method_sales.memo,
						DATE_FORMAT(m_receipt_method_sales.create_date,'%Y/%m/%d %H:%i:%s') as create_date, 
						m_receipt_method_sales.create_account,
						m_receipt_method_sales.create_person,
						DATE_FORMAT(m_receipt_method_sales.modify_date,'%Y/%m/%d %H:%i:%s') as modify_date,
						m_receipt_method_sales.modify_account,
						m_receipt_method_sales.modify_person
				  FROM m_receipt_method_sales,
				       ( SELECT COUNT(m_receipt_method_sales.receipt_method_id) as cnt
				         FROM m_receipt_method_sales
				        WHERE m_receipt_method_sales.member_id = '#url.m_id#'
						 <cfif qGetLastSendDate.lsd neq "" AND qGetLastSendDate.send_all neq 1>
				         	AND (m_receipt_method_sales.modify_date >= '#qGetLastSendDate.lsd#' OR m_receipt_method_sales.create_date >= '#qGetLastSendDate.lsd#')
						 </cfif>				        
				        ) MS 
				        WHERE m_receipt_method_sales.member_id = '#url.m_id#' AND MS.cnt > 0
				        ORDER BY LPAD(m_receipt_method_sales.receipt_method_id, 10, 0)
				        LIMIT 8
				 </cfquery>
				 	<cfset recordCount = qGetPaymentMethod.RecordCount>
				 	<cfset output = "">
				 	<cfset query= "">
					<cfloop index="cnt" from="1" to="#recordCount#">
							<cfset data = "">  
							<cfset data = qGetPaymentMethod.receipt_method_id[cnt] & ","
										& qGetPaymentMethod.function_num[cnt] & ","
										& qGetPaymentMethod.sort_order[cnt] & ","
										& qGetPaymentMethod.receipt_method_name1[cnt] & ","
										& qGetPaymentMethod.receipt_method_name2[cnt] & ","
										& qGetPaymentMethod.receipt_method_name3[cnt] & ","
										& qGetPaymentMethod.receipt_method_name4[cnt] & ","
										& qGetPaymentMethod.receipt_method_name5[cnt] & ","
										& qGetPaymentMethod.receipt_method_name6[cnt] & ","
										& qGetPaymentMethod.changeable_flag[cnt] & ","
										& qGetPaymentMethod.amount_input_flag[cnt] & ","
										& qGetPaymentMethod.multiple_method_flag[cnt] & ","
										& qGetPaymentMethod.money_on_hand_flag[cnt] & ","
										& qGetPaymentMethod.color_red[cnt] & ","
										& qGetPaymentMethod.color_green[cnt] & ","
										& qGetPaymentMethod.color_blue[cnt] & ","
										& qGetPaymentMethod.create_date[cnt] & ","
										& qGetPaymentMethod.create_account[cnt] & ","
										& qGetPaymentMethod.create_person[cnt] & ","
										& qGetPaymentMethod.modify_date[cnt] & ","
										& qGetPaymentMethod.modify_account[cnt] & ","
										& qGetPaymentMethod.modify_person & ","
										& qGetPaymentMethod.payment_amount[cnt] & ","
										& qGetPaymentMethod.tw_remove_from_ui_flag[cnt] & chr(10)>								 
							<cfset output = output & data>																	
					</cfloop>
				<!--- 最後にm_regiの最終送信日を現在時間に。 --->	
				<cfquery datasource="#application.dsn#" name="qUpdRegi">
					  UPDATE m_regi  
  						SET last_send_date_payment_method = '#now#'  
					  WHERE member_id = '#url.m_id#'
					    AND regi_id ='#url.r_id#'
					    AND shop_id ='#shop_id#'								     
				</cfquery>				 
			<cfreturn output >
		</cffunction>
</cfcomponent>


