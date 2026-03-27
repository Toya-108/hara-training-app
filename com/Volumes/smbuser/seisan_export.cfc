<cfcomponent>
	<cfheader name="Access-Control-Allow-Origin" value="*" />
	<cfsetting showDebugOutput="No">
	<cffunction name="getSeisanJan" access="remote" returnFormat="plain">
		<cfset order_mode = 5><!--- オーダー端末は端末数にカウントしない --->
		<cfquery datasource="#application.dsn#" name="qGetRegi">
			SELECT regi_id FROM m_regi WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND regi_mode <> #order_mode#
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qGetSeisanComplete">
			SELECT member_id FROM t_seisan_torihiki WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND t_seisan_torihiki.sales_date = '#url.s_date#'
		</cfquery>
		<cfset regi_num            = qGetRegi.RecordCount>
		<cfset seisan_complete_num = qGetSeisanComplete.RecordCount>

		<cfquery datasource="#application.dsn#" name="qGetSeisanJan">
		 SELECT t_seisan_jan.jan,   
				t_seisan_jan.product_id,   
				MPRODUCT.product_name,   
				MPRODUCT.division_id,
				MPRODUCT.division_name,
				<!--- SUM(t_seisan_jan.sales_customer) sum_sales_customer,  --->  
				SUM(t_seisan_jan.sales_qty) sum_sales_qty,
				SUM(t_seisan_jan.net_sales_amount_include_tax) sum_net_sales_amount_include_tax
				FROM t_seisan_jan LEFT OUTER JOIN (SELECT m_product.product_id,
														  m_product.product_name,
														  m_product.division_id,
														  m_product.member_id,
														  m_division.division_name
												     FROM m_product LEFT OUTER JOIN m_division ON m_product.member_id = m_division.member_id
												          									  AND m_product.division_id = m_division.division_id
												     WHERE  m_product.member_id  = '#url.m_id#'
												     ) MPRODUCT ON t_seisan_jan.product_id = MPRODUCT.product_id
													           AND t_seisan_jan.member_id  = MPRODUCT.member_id  
				WHERE t_seisan_jan.member_id  = '#url.m_id#'
				  AND t_seisan_jan.sales_date = '#url.s_date#'
				  AND t_seisan_jan.shop_id    = '#url.sp_id#'   
			 GROUP BY t_seisan_jan.jan,   
				      t_seisan_jan.product_id,   
				      MPRODUCT.product_name,
				      MPRODUCT.division_name, 
				      MPRODUCT.division_id
		</cfquery>

	 	<cfset recordCount = qGetSeisanJan.RecordCount>
	 	<cfset output = "">

		<cfloop index="cnt" from="1" to="#recordCount#">
			<!--- 売り上げ数が0以下の場合飛ばす(返品などで相殺したもの) --->
				<cfif qGetSeisanJan.sum_sales_qty[cnt] lt 1>
					<cfcontinue>
				</cfif>
				<cfset data = "">  
				<cfset data = qGetSeisanJan.Jan[cnt] & ","
							 & qGetSeisanJan.product_id[cnt] & ","
							 & qGetSeisanJan.product_name[cnt] & ","
							 & qGetSeisanJan.division_id[cnt] & ","
							 & qGetSeisanJan.division_name[cnt] & ","
							 & qGetSeisanJan.sum_sales_qty[cnt] & ","
							 & qGetSeisanJan.sum_net_sales_amount_include_tax[cnt] & ","
							 & regi_num & ","
							 & seisan_complete_num &
							 #chr(10)#>								 
				<cfset output = output & data>																															
		</cfloop>		
		<cfreturn output >
	</cffunction>	


	<cffunction name="getSeisanDivision" access="remote" returnFormat="plain">
		<cfset order_mode = 5><!--- オーダー端末は端末数にカウントしない --->
		<cfquery datasource="#application.dsn#" name="qGetRegi">
			SELECT regi_id FROM m_regi WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND regi_mode <> #order_mode#
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qGetSeisanComplete">
			SELECT member_id FROM t_seisan_torihiki WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND t_seisan_torihiki.sales_date = '#url.s_date#'
		</cfquery>
		<cfset regi_num            = qGetRegi.RecordCount>
		<cfset seisan_complete_num = qGetSeisanComplete.RecordCount>		
		<cfquery datasource="#application.dsn#" name="qGetSeisanDivision">
		 SELECT t_seisan_division.division_id,
		        m_division.division_name,
				SUM(t_seisan_division.sales_qty) sum_sales_qty, 
				SUM(t_seisan_division.net_sales_amount_include_tax) sum_net_sales_amount_include_tax
				FROM t_seisan_division LEFT OUTER JOIN m_division ON t_seisan_division.member_id  = m_division.member_id
													             AND t_seisan_division.division_id = m_division.division_id 
				WHERE t_seisan_division.member_id  = '#url.m_id#'
				  AND t_seisan_division.sales_date = '#url.s_date#'
				  AND t_seisan_division.shop_id    = '#url.sp_id#'   
			 GROUP BY t_seisan_division.division_id,
				      m_division.division_name
		</cfquery>

	 	<cfset recordCount = qGetSeisanDivision.RecordCount>
	 	<cfset output = "">

		<cfloop index="cnt" from="1" to="#recordCount#">
				<!--- 売り上げ数が0以下の場合飛ばす(返品などで相殺したもの) --->
				<cfif qGetSeisanDivision.sum_sales_qty[cnt] lt 1>
					<cfcontinue>
				</cfif>			
				<cfset data = "">  
				<cfset data = qGetSeisanDivision.division_id[cnt] & ","
							 & qGetSeisanDivision.division_name[cnt] & ","
							 & qGetSeisanDivision.sum_sales_qty[cnt] & ","
							 & qGetSeisanDivision.sum_net_sales_amount_include_tax[cnt] & ","
							 & regi_num & ","
							 & seisan_complete_num &							 
							 #chr(10)#>								 
				<cfset output = output & data>																															
		</cfloop>		
		<cfreturn output >
	</cffunction>

	<cffunction name="getNikkei" access="remote" returnFormat="plain">
		 <cfset order_mode = 5><!--- オーダー端末は端末数にカウントしない --->
		<cfquery datasource="#application.dsn#" name="qGetRegi">
			SELECT regi_id FROM m_regi WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND regi_mode <> #order_mode#
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qGetSeisanComplete">
			SELECT member_id FROM t_seisan_torihiki WHERE member_id = '#url.m_id#' AND shop_id = '#url.sp_id#' AND t_seisan_torihiki.sales_date = '#url.s_date#'
		</cfquery>
		<cfset regi_num            = qGetRegi.RecordCount>
		<cfset seisan_complete_num = qGetSeisanComplete.RecordCount>		
		<cfquery datasource="#application.dsn#" name="qGetSeisan">
			SELECT
				 SUM(t_seisan_torihiki.sales_customer) as sales_customer,
		         SUM(t_seisan_torihiki.total_gross_sales_include_tax) as total_gross_sales_include_tax,
		         SUM(t_seisan_torihiki.total_tax) as total_tax,
		         SUM(t_seisan_torihiki.total_net_sales_include_tax) as total_net_sales_include_tax,
		         SUM(t_seisan_torihiki.receipt_amount0) as receipt_amount0,
		         SUM(t_seisan_torihiki.receipt_times0) as receipt_times0,
		         SUM(t_seisan_torihiki.close_amount1) as close_amount1,   
		         SUM(t_seisan_torihiki.receipt_times1) as receipt_times1,   
		         SUM(t_seisan_torihiki.close_amount2) as close_amount2,   
		         SUM(t_seisan_torihiki.receipt_times2) as receipt_times2,   
		         SUM(t_seisan_torihiki.close_amount3) as close_amount3,   
		         SUM(t_seisan_torihiki.receipt_times3) as receipt_times3,   
		         SUM(t_seisan_torihiki.close_amount4) as close_amount4,   
		         SUM(t_seisan_torihiki.receipt_times4) as receipt_times4,   
		         SUM(t_seisan_torihiki.close_amount5) as close_amount5,   
		         SUM(t_seisan_torihiki.receipt_times5) as receipt_times5,   
		         SUM(t_seisan_torihiki.close_amount6) as close_amount6,   
		         SUM(t_seisan_torihiki.receipt_times6) as receipt_times6,   
		         SUM(t_seisan_torihiki.close_amount7) as close_amount7,   
		         SUM(t_seisan_torihiki.receipt_times7) as receipt_times7,   
		         SUM(t_seisan_torihiki.close_amount8) as close_amount8,   
		         SUM(t_seisan_torihiki.receipt_times8) as receipt_times8, 
		         SUM(t_seisan_torihiki.disposal_qty) as disposal_qty,   
		         SUM(t_seisan_torihiki.disposal_cost) as disposal_cost,   
		         SUM(t_seisan_torihiki.price_discount_qty) as price_discount_qty,   
		         SUM(t_seisan_torihiki.price_discount_amount) as price_discount_amount,   
		         SUM(t_seisan_torihiki.return_qty) as return_qty,   
		         SUM(t_seisan_torihiki.return_amount_include_tax) as return_amount_include_tax,   
		         SUM(t_seisan_torihiki.sales_qty) as sales_qty,   
		         SUM(t_seisan_torihiki.close_change_10000) as close_change_10000,   
		         SUM(t_seisan_torihiki.close_change_5000) as close_change_5000,   
		         SUM(t_seisan_torihiki.close_change_2000) as close_change_2000,   
		         SUM(t_seisan_torihiki.close_change_1000) as close_change_1000,   
		         SUM(t_seisan_torihiki.close_change_500) as close_change_500,   
		         SUM(t_seisan_torihiki.close_change_100) as close_change_100, 
				 SUM(t_seisan_torihiki.close_change_50) as close_change_50,   
		         SUM(t_seisan_torihiki.close_change_10) as close_change_10, 
		         SUM(t_seisan_torihiki.close_change_5) as close_change_5,   
		         SUM(t_seisan_torihiki.close_change_1) as close_change_1,   
		         SUM(t_seisan_torihiki.close_change_total) as close_change_total,   
		         SUM(t_seisan_torihiki.receipt_amount1) as receipt_amount1,   
		         SUM(t_seisan_torihiki.receipt_amount2) as receipt_amount2,   
		         SUM(t_seisan_torihiki.receipt_amount3) as receipt_amount3,   
		         SUM(t_seisan_torihiki.receipt_amount4) as receipt_amount4,   
		         SUM(t_seisan_torihiki.receipt_amount5) as receipt_amount5,   
		         SUM(t_seisan_torihiki.receipt_amount6) as receipt_amount6,   
		         SUM(t_seisan_torihiki.receipt_amount7) as receipt_amount7,   
		         SUM(t_seisan_torihiki.receipt_amount8) as receipt_amount8,   
		         SUM(t_seisan_torihiki.in_amount) as in_amount,   
		         SUM(t_seisan_torihiki.out_amount) as out_amount, 
				 SUM(t_seisan_torihiki.gift_cert_change_amount) as gift_cert_change_amount,   
		         SUM(t_seisan_torihiki.gift_cert_no_change_amount) as gift_cert_no_change_amount, 
		         SUM(t_seisan_torihiki.subtotal_discount_times) as subtotal_discount_times,   
		         SUM(t_seisan_torihiki.subtotal_discount_amount) as subtotal_discount_amount,   
		         SUM(t_seisan_torihiki.change_amount) as change_amount,
		         SUM(t_seisan_torihiki.total_service_charge) as total_service_charge,
		         SUM(t_seisan_torihiki.open_change_total) as open_change_total
		    FROM t_seisan_torihiki		         		           
		   WHERE t_seisan_torihiki.member_id = '#url.m_id#'
		     AND t_seisan_torihiki.shop_id = '#url.sp_id#'
		     AND t_seisan_torihiki.sales_date = '#url.s_date#'
		</cfquery>
	 	<cfset output = "">
		<cfset data = "">  
		<cfset data = qGetSeisan.sales_customer & ","
					 & qGetSeisan.total_gross_sales_include_tax & ","
					 & qGetSeisan.total_tax & ","
					 & qGetSeisan.total_net_sales_include_tax & ","
					 & qGetSeisan.receipt_amount0 & ","
					 & qGetSeisan.receipt_times0 & ","
					 & qGetSeisan.close_amount1 & ","
					 & qGetSeisan.receipt_times1 & ","
					 & qGetSeisan.close_amount2 & ","
					 & qGetSeisan.receipt_times2 & ","
					 & qGetSeisan.close_amount3 & ","
					 & qGetSeisan.receipt_times3 & ","
					 & qGetSeisan.close_amount4 & ","
					 & qGetSeisan.receipt_times4 & ","
					 & qGetSeisan.close_amount5 & ","
					 & qGetSeisan.receipt_times5 & ","
					 & qGetSeisan.close_amount6 & ","
					 & qGetSeisan.receipt_times6 & ","
					 & qGetSeisan.close_amount7 & ","
					 & qGetSeisan.receipt_times7 & ","
					 & qGetSeisan.close_amount8 & ","
					 & qGetSeisan.receipt_times8 & ","
					 & qGetSeisan.disposal_qty & ","
					 & qGetSeisan.disposal_cost & ","
					 & qGetSeisan.price_discount_qty & ","
					 & qGetSeisan.price_discount_amount & ","
					 & qGetSeisan.return_qty & ","
					 & qGetSeisan.return_amount_include_tax & ","
					 & qGetSeisan.sales_qty & ","
					 & qGetSeisan.close_change_10000 & ","
					 & qGetSeisan.close_change_5000 & ","
					 & qGetSeisan.close_change_2000 & ","
					 & qGetSeisan.close_change_1000 & ","
					 & qGetSeisan.close_change_500 & ","
					 & qGetSeisan.close_change_100 & ","
					 & qGetSeisan.close_change_50 & ","
					 & qGetSeisan.close_change_10 & ","
					 & qGetSeisan.close_change_5 & ","
					 & qGetSeisan.close_change_1 & ","
					 & qGetSeisan.close_change_total & ","
					 & qGetSeisan.receipt_amount1 & ","
					 & qGetSeisan.receipt_amount2 & ","
					 & qGetSeisan.receipt_amount3 & ","
					 & qGetSeisan.receipt_amount4 & ","
					 & qGetSeisan.receipt_amount5 & ","
					 & qGetSeisan.receipt_amount6 & ","
					 & qGetSeisan.receipt_amount7 & ","
					 & qGetSeisan.receipt_amount8 & ","
					 & qGetSeisan.in_amount & ","
					 & qGetSeisan.out_amount & ","
					 & qGetSeisan.gift_cert_change_amount & ","
					 & qGetSeisan.gift_cert_no_change_amount & ","
					 & qGetSeisan.subtotal_discount_times & ","
					 & qGetSeisan.subtotal_discount_amount & ","
					 & qGetSeisan.change_amount & ","
					 & regi_num & ","
					 & seisan_complete_num & ","
					 & qGetSeisan.total_service_charge & ","
					 & qGetSeisan.open_change_total>								 
		<cfset output = output & data>																															

		<cfreturn output >
	</cffunction>
					
</cfcomponent>

