<cfinclude template = "init.cfm">
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<head>
</head>
<body>
		<cfinclude template = "general_settings.cfm">
		<cfif IsDefined("session.decimal_place")>
			<cfset decimal_place = session.decimal_place>
		<cfelse>
	        <cfquery name="qGetAdmin" datasource="#application.dsn#">
	            SELECT m_currency.decimal_place 
	              FROM m_admin LEFT OUTER JOIN m_currency ON m_admin.currency_id = m_currency.currency_id   
	             WHERE member_id = "#session.member_id#"
	        </cfquery>		
			<cfset decimal_place = qGetAdmin.decimal_place>
		</cfif>	
		<cfquery datasource="#application.dsn#" name="qGetProduct">
		  SELECT m_product.division_id,
		         m_division.division_name,
		         <!---m_product.depart_id,--->
		         <!---m_depart.depart_name,--->
		         m_product.line_id,
		         m_line.line_name,
		         m_product.class_id,
		         m_class.class_name,
		         m_product.product_id,
		         JAN1.jan as jan1,
		         JAN2.jan as jan2,
		         JAN3.jan as jan3,
		         JAN4.jan as jan4,
		         JAN5.jan as jan5,
		         JAN6.jan as jan6,
		         JAN7.jan as jan7,
		         JAN8.jan as jan8,
		         JAN9.jan as jan9,
		         JAN10.jan as jan10,
		         m_product.maker_name,
		         m_product.maker_name_kana,
		         m_product.product_name,
		         m_product.product_name_kana,
		         m_product.receipt_name,
		         m_product.receipt_name_kana,
		         m_product.plu_name,
		         m_product.plu_name2,
		         m_product.plu_name_kana,
		         m_product.plu_name2_kana,
		         m_product.standard_name,
		         m_product.standard_name_kana,
		         m_product.volume,
		         m_product.alcohol_category_id,
		         m_alcohol_category.alcohol_category_name,
		         m_product.product_category_id,
		         m_product_category.product_category_name,
		         m_product.supplier_id,
		         m_supplier.supplier_name,
		         m_product.unit_cost,
		         REPLACE(FORMAT(m_product.maker_price,#decimal_place#),',','') maker_price,
		         REPLACE(FORMAT(m_product.unit_price_without_tax,#decimal_place#),',','') unit_price_without_tax,
		         REPLACE(FORMAT(m_product.unit_price_include_tax,#decimal_place#),',','') unit_price_include_tax,
		         REPLACE(FORMAT(m_product.unit_price_tax,#decimal_place#),',','') unit_price_tax,		         
		         m_product.qty_per_carton,
		         m_product.unit,
		         m_product.regi_input_minus_flag,
		         m_product.purchase_type,
		         case m_product.purchase_type when 1 then "買取"
				 		                      when 2 then "委託"
				 end char_purchase_type,
		         case  m_product.tax_class when 1 then "内税"
				 		                   when 2 then "外税"
				 		                   when 3 then "非課税"
				 end char_tax_class,
		         m_product.tax_class,
		         m_product.shelflabel_type,
		         m_product.cook_flag,
		         m_product.point_flag,
		         m_product.stock_flag,
		         case m_product.stock_flag when 0 then ""
				 		                   when 1 then "●"
				 end char_stock_flag,
		         m_product.last_sales_date,
		         DATE_FORMAT(m_product.last_sales_date,'#lang_src.format.date_form_sql#') as char_last_sales_date,
		         m_product.memo,
		         m_product.create_date,
		         DATE_FORMAT(m_product.create_date,'#lang_src.format.date_form_sql#') as char_create_date,
		         m_product.create_account,
		         m_product.create_person,
		         m_product.modify_date,
		         DATE_FORMAT(m_product.modify_date,'#lang_src.format.date_form_sql#') as char_modify_date,
		         m_product.modify_account,
		         m_product.modify_person,
		         CAST(m_product.division_id         AS SIGNED) as num_division_id,
		         <!---CAST(m_product.depart_id           AS SIGNED) as num_depart_id,--->
		         CAST(m_product.line_id             AS SIGNED) as num_line_id,
		         CAST(m_product.class_id            AS SIGNED) as num_class_id,
		         CAST(m_product.alcohol_category_id AS SIGNED) as num_alcohol_category_id,
		         CAST(m_product.product_category_id AS SIGNED) as num_product_category_id,
		         CAST(m_product.supplier_id         AS SIGNED) as num_supplier_id,
		         CAST(m_product.create_account      AS SIGNED) as num_create_account,
		         CAST(m_product.modify_account      AS SIGNED) as num_modify_account

		    FROM m_product LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                                            m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 1 ) JAN1 ON m_product.member_id = JAN1.member_id AND m_product.product_id = JAN1.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
	                   								m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 2 ) JAN2 ON m_product.member_id = JAN2.member_id AND m_product.product_id = JAN2.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 3 ) JAN3 ON m_product.member_id = JAN3.member_id AND m_product.product_id = JAN3.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 4 ) JAN4 ON m_product.member_id = JAN4.member_id AND m_product.product_id = JAN4.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 5 ) JAN5 ON m_product.member_id = JAN5.member_id AND m_product.product_id = JAN5.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 6 ) JAN6 ON m_product.member_id = JAN6.member_id AND m_product.product_id = JAN6.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 7 ) JAN7 ON m_product.member_id = JAN7.member_id AND m_product.product_id = JAN7.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 8 ) JAN8 ON m_product.member_id = JAN8.member_id AND m_product.product_id = JAN8.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 9 ) JAN9 ON m_product.member_id = JAN9.member_id AND m_product.product_id = JAN9.product_id
		                   LEFT OUTER JOIN ( SELECT m_jan.member_id,
		                   							m_jan.product_id,
		                                            m_jan.jan
		                                       FROM m_jan
		                                      WHERE m_jan.member_id = '#session.member_id#' AND 
		                                            m_jan.del_flag = 0 AND
		                                            m_jan.sort_order = 10 ) JAN10 ON m_product.member_id = JAN10.member_id AND m_product.product_id = JAN10.product_id

		                   LEFT OUTER JOIN m_division         ON m_product.member_id = m_division.member_id AND m_product.division_id = m_division.division_id
		                   <!---LEFT OUTER JOIN m_depart           ON m_product.member_id   = m_depart.member_id AND m_product.depart_id   = m_depart.depart_id--->
		                   LEFT OUTER JOIN m_line             ON m_product.member_id     = m_line.member_id AND m_product.line_id     = m_line.line_id
		                   LEFT OUTER JOIN m_class            ON m_product.member_id    = m_class.member_id AND m_product.class_id    = m_class.class_id
		                   LEFT OUTER JOIN m_alcohol_category ON m_product.member_id = m_alcohol_category.member_id AND m_product.alcohol_category_id = m_alcohol_category.alcohol_category_id
		                   LEFT OUTER JOIN m_product_category ON m_product.member_id = m_product_category.member_id AND m_product.product_category_id = m_product_category.product_category_id
		                   LEFT OUTER JOIN m_supplier         ON m_product.member_id = m_supplier.member_id AND m_product.supplier_id = m_supplier.supplier_id

		   WHERE m_product.member_id = '#session.member_id#' AND m_product.del_flag = 0	
		   	   <cfif IsDefined("url.only_column_names")>
			   	   AND 0 <> 0
		   	   </cfif>	   
			   <cfif IsDefined("session.product_id_list") and #session.product_id_list# neq "">
			   	AND(
			   		<cfloop index = "index_name" list='#session.product_id_list#'>
				   		 m_product.product_id = '#index_name#' OR
			   		</cfloop>
			   	0 <> 0)
			   </cfif>

		</cfquery>


		<cfoutput>
			<cfset recordCount = qGetProduct.RecordCount>

	        <cfif DirectoryExists(#application.export_dir# & #session.member_id# & "/master_product") is false>
	        	<cfset create_dir = #application.export_dir# & #session.member_id# & "/master_product">
	            <cfdirectory action="create" directory="#create_dir#" mode="777">
	        </cfif>			

			<!--- <cfset today = DateFormat(Now(), "ddmmyyyy")> --->

			<!--- タイムゾーン対応 --->
			<cfset arr_offset = ListToArray(session.utc_offset,":")>
			<cfset h_offset = Int(arr_offset[1])/>
			<cfset m_offset = Int(arr_offset[2])/>
			<cfset now = DateAdd("n",m_offset,DateAdd("h",h_offset,DateConvert('local2Utc',now())))>
			<cfset today = DateFormat(now, "#lang_src.format.date_form_cf2#")>


			<cfset filename = #application.export_dir# & "master_product_" & #today# & #TimeFormat(now, "hhmmss")# & ".csv">
			<cfif #qGetAdminSettings.division_flag# eq 1>
				<cfset header = "#lang_src.term.category_code#*,#lang_src.term.item_code#*,#lang_src.term.sku#*(#lang_src.phrase.digit_13#),#lang_src.term.maker#,#lang_src.term.item_name#*,#lang_src.term.sales_unit#,#lang_src.term.purchase_price#*,#lang_src.term.sales_unit_price_ex_tax#*,#lang_src.term.sales_unit_price_in_tax#*,#lang_src.term.tax#*,#lang_src.term.proper_price#,#lang_src.term.tax_indication#(1:#lang_src.term.tax_included# 2:#lang_src.term.tax_excluded# 3:#lang_src.term.tax_free#)*,#lang_src.term.name_for_receipt#*,#lang_src.term.key_name#(#lang_src.term.upper#),#lang_src.term.key_name#(#lang_src.term.lower#),#lang_src.term.unit#,#lang_src.term.volume#,SKU2,SKU3,SKU4,SKU5,SKU6,SKU7,SKU8,SKU9,SKU10,#lang_src.term.note#">				
				<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">					
					<cfloop index="cnt" from="1" to="#recordCount#">
						<cfset data = "">
							<cfset data = #qGetProduct.division_id[cnt]# & ","
										 & #qGetProduct.product_id[cnt]# & ","
										 & #qGetProduct.jan1[cnt]# & ","
										 & #qGetProduct.maker_name[cnt]# & "," 
										 & #qGetProduct.product_name[cnt]# & ","
										 <!--- & #qGetProduct.product_name_kana[cnt]# & "," --->
										 & #qGetProduct.standard_name[cnt]# & ","
										 & #qGetProduct.unit_cost[cnt]# & ","
										 & #qGetProduct.unit_price_without_tax[cnt]# & ","
										 & #qGetProduct.unit_price_include_tax[cnt]# & ","
										 & #qGetProduct.unit_price_tax[cnt]# & ","
										 & #qGetProduct.maker_price[cnt]# & ","
										 & #qGetProduct.tax_class[cnt]# & ","
										 & #qGetProduct.receipt_name[cnt]# & ","
										 <!--- & #qGetProduct.receipt_name_kana[cnt]# & "," --->
										 & #qGetProduct.plu_name[cnt]# & ","
										 & #qGetProduct.plu_name2[cnt]# & ","
										 & #qGetProduct.unit[cnt]# & ","
										 <!--- & #qGetProduct.division_name[cnt]# & "," --->
										 <!--- & #qGetProduct.alcohol_category_id[cnt]# & "," --->
										 <!--- & #qGetProduct.alcohol_category_name[cnt]# & "," --->
										 <!--- & #qGetProduct.product_category_id[cnt]# & "," --->
										 <!--- & #qGetProduct.product_category_name[cnt]# & "," --->
										 & #qGetProduct.volume[cnt]# & ","
										 <!--- & #qGetProduct.char_last_sales_date[cnt]# & "," --->
										 & #qGetProduct.jan2[cnt]# & ","
										 & #qGetProduct.jan3[cnt]# & ","
										 & #qGetProduct.jan4[cnt]# & ","
										 & #qGetProduct.jan5[cnt]# & ","
										 & #qGetProduct.jan6[cnt]# & ","
										 & #qGetProduct.jan7[cnt]# & ","
										 & #qGetProduct.jan8[cnt]# & ","
										 & #qGetProduct.jan9[cnt]# & ","
										 & #qGetProduct.jan10[cnt]# & ","
										 & #qGetProduct.memo[cnt]#
										 <!--- & #qGetProduct.char_create_date[cnt]# & ","
										 & #qGetProduct.create_account[cnt]# & ","
										 & #qGetProduct.create_person[cnt]# & ","
										 & #qGetProduct.modify_date[cnt]# & ","
										 & #qGetProduct.modify_account[cnt]# & ","
										 & #qGetProduct.modify_person[cnt]# --->
										 >
									 
						<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
					</cfloop>			
			<cfelseif #qGetAdminSettings.division_flag# eq 2>				
				<cfset header = "#lang_src.term.category_code#*,#lang_src.term.item_code#*,#lang_src.term.sku#*(#lang_src.phrase.digit_13#),#lang_src.term.maker#,#lang_src.term.item_name#*,#lang_src.term.sales_unit#,#lang_src.term.purchase_price#*,#lang_src.term.sales_unit_price_ex_tax#*,#lang_src.term.sales_unit_price_in_tax#*,#lang_src.term.tax#*,#lang_src.term.proper_price#,#lang_src.term.tax_indication#(1:#lang_src.term.tax_included# 2:#lang_src.term.tax_excluded# 3:#lang_src.term.tax_free#)*,#lang_src.term.name_for_receipt#*,#lang_src.term.key_name#(#lang_src.term.upper#),#lang_src.term.key_name#(#lang_src.term.lower#),#lang_src.term.unit#,#lang_src.term.line_code#,#lang_src.term.volume#,SKU2,SKU3,SKU4,SKU5,SKU6,SKU7,SKU8,SKU9,SKU10,#lang_src.term.note#">
				<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">					
					<cfloop index="cnt" from="1" to="#recordCount#">
						<cfset data = "">					
							<cfset data = #qGetProduct.division_id[cnt]# & ","
										 & #qGetProduct.product_id[cnt]# & ","
										 & #qGetProduct.jan1[cnt]# & ","
										 & #qGetProduct.maker_name[cnt]# & "," 
										 & #qGetProduct.product_name[cnt]# & ","
										 <!--- & #qGetProduct.product_name_kana[cnt]# & "," --->
										 & #qGetProduct.standard_name[cnt]# & ","
										 & #qGetProduct.unit_cost[cnt]# & ","
										 & #qGetProduct.unit_price_without_tax[cnt]# & ","
										 & #qGetProduct.unit_price_include_tax[cnt]# & ","
										 & #qGetProduct.unit_price_tax[cnt]# & ","
										 & #qGetProduct.maker_price[cnt]# & ","
										 & #qGetProduct.tax_class[cnt]# & ","
										 & #qGetProduct.receipt_name[cnt]# & ","
										 <!--- & #qGetProduct.receipt_name_kana[cnt]# & "," --->
										 & #qGetProduct.plu_name[cnt]# & ","
										 & #qGetProduct.plu_name2[cnt]# & ","
										 & #qGetProduct.unit[cnt]# & ","
										 <!--- & #qGetProduct.division_name[cnt]# & "," --->
										 & #qGetProduct.line_id[cnt]# & ","
										 <!--- & #qGetProduct.line_name[cnt]# & "," --->
										 <!--- & #qGetProduct.alcohol_category_id[cnt]# & ","
										 & #qGetProduct.alcohol_category_name[cnt]# & ","
										 & #qGetProduct.product_category_id[cnt]# & ","
										 & #qGetProduct.product_category_name[cnt]# & "," --->
										 & #qGetProduct.volume[cnt]# & ","
										 <!--- & #qGetProduct.char_last_sales_date[cnt]# & "," --->
										 & #qGetProduct.jan2[cnt]# & ","
										 & #qGetProduct.jan3[cnt]# & ","
										 & #qGetProduct.jan4[cnt]# & ","
										 & #qGetProduct.jan5[cnt]# & ","
										 & #qGetProduct.jan6[cnt]# & ","
										 & #qGetProduct.jan7[cnt]# & ","
										 & #qGetProduct.jan8[cnt]# & ","
										 & #qGetProduct.jan9[cnt]# & ","
										 & #qGetProduct.jan10[cnt]# & ","
										 & #qGetProduct.memo[cnt]#
										 <!--- & #qGetProduct.char_create_date[cnt]# & ","
										 & #qGetProduct.create_account[cnt]# & ","
										 & #qGetProduct.create_person[cnt]# & ","
										 & #qGetProduct.modify_date[cnt]# & ","
										 & #qGetProduct.modify_account[cnt]# & ","
										 & #qGetProduct.modify_person[cnt]# --->
										 >
									 
						<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
					</cfloop>			
			<cfelseif #qGetAdminSettings.division_flag# eq 3>
				<cfset header = "#lang_src.term.category_code#*,#lang_src.term.class_code#,#lang_src.term.item_code#*,#lang_src.term.sku#*(#lang_src.phrase.digit_13#),#lang_src.term.maker#,#lang_src.term.item_name#*,#lang_src.term.sales_unit#,#lang_src.term.purchase_price#*,#lang_src.term.sales_unit_price_ex_tax#*,#lang_src.term.sales_unit_price_in_tax#*,#lang_src.term.tax#*,#lang_src.term.proper_price#,#lang_src.term.tax_indication#(1:#lang_src.term.tax_included# 2:#lang_src.term.tax_excluded# 3:#lang_src.term.tax_free#)*,#lang_src.term.name_for_receipt#*,#lang_src.term.key_name#(#lang_src.term.upper#),#lang_src.term.key_name#(#lang_src.term.lower#),#lang_src.term.unit#,#lang_src.term.line_code#,#lang_src.term.volume#,SKU2,SKU3,SKU4,SKU5,SKU6,SKU7,SKU8,SKU9,SKU10,#lang_src.term.note#">
				<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">					
					<cfloop index="cnt" from="1" to="#recordCount#">
						<cfset data = "">
							<cfset data = #qGetProduct.division_id[cnt]# & ","
										 & #qGetProduct.class_id[cnt]# & ","
										 <!--- & #qGetProduct.class_name[cnt]# & "," --->
										 & #qGetProduct.product_id[cnt]# & ","
										 & #qGetProduct.jan1[cnt]# & ","
										 & #qGetProduct.maker_name[cnt]# & "," 
										 & #qGetProduct.product_name[cnt]# & ","
										 <!--- & #qGetProduct.product_name_kana[cnt]# & "," --->
										 & #qGetProduct.standard_name[cnt]# & ","
										 & #qGetProduct.unit_cost[cnt]# & ","
										 & #qGetProduct.unit_price_without_tax[cnt]# & ","
										 & #qGetProduct.unit_price_include_tax[cnt]# & ","
										 & #qGetProduct.unit_price_tax[cnt]# & ","
										 & #qGetProduct.maker_price[cnt]# & ","
										 & #qGetProduct.tax_class[cnt]# & ","
										 & #qGetProduct.receipt_name[cnt]# & ","
										 <!--- & #qGetProduct.receipt_name_kana[cnt]# & "," --->
										 & #qGetProduct.plu_name[cnt]# & ","
										 & #qGetProduct.plu_name2[cnt]# & ","
										 & #qGetProduct.unit[cnt]# & ","
										 <!--- & #qGetProduct.division_name[cnt]# & "," --->
										 & #qGetProduct.line_id[cnt]# & ","
										 <!--- & #qGetProduct.line_name[cnt]# & ","
										 & #qGetProduct.alcohol_category_id[cnt]# & ","
										 & #qGetProduct.alcohol_category_name[cnt]# & ","
										 & #qGetProduct.product_category_id[cnt]# & ","
										 & #qGetProduct.product_category_name[cnt]# & "," --->
										 & #qGetProduct.volume[cnt]# & ","
										 <!--- & #qGetProduct.char_last_sales_date[cnt]# & "," --->
										 & #qGetProduct.jan2[cnt]# & ","
										 & #qGetProduct.jan3[cnt]# & ","
										 & #qGetProduct.jan4[cnt]# & ","
										 & #qGetProduct.jan5[cnt]# & ","
										 & #qGetProduct.jan6[cnt]# & ","
										 & #qGetProduct.jan7[cnt]# & ","
										 & #qGetProduct.jan8[cnt]# & ","
										 & #qGetProduct.jan9[cnt]# & ","
										 & #qGetProduct.jan10[cnt]# & ","
										 & #qGetProduct.memo[cnt]#
										 <!--- & #qGetProduct.char_create_date[cnt]# & ","
										 & #qGetProduct.create_account[cnt]# & ","
										 & #qGetProduct.create_person[cnt]# & ","
										 & #qGetProduct.modify_date[cnt]# & ","
										 & #qGetProduct.modify_account[cnt]# & ","
										 & #qGetProduct.modify_person[cnt]# --->
										 >
									 
						<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
					</cfloop>			
			</cfif>



				<!--- CSVダウンロード処理 --->

				
					<cfif IsDefined("url.only_column_names")><!--- フォーマットファイルのダウンロードの場合 --->
						<cfset f_nm = "Item_Master_Import_Format.csv">
					<cfelse>
						<cfset f_nm = "Item_Master_#today#.csv">
					</cfif>

					<cfheader name="Content-Disposition" value="attachment; filename=#f_nm#" charset="#lang_src.format.export_charset#">
					<cfcontent type="text/csv" file="#filename#" deletefile="yes">


<!--- 元のやつ --->
<!--- 				<cfset header = "部門コード,クラスコード,クラス名,商品コード,JANコード1,メーカー,商品名,商品名(ｶﾅ),規格,仕入先コード,仕入先名,仕入単価,売単価(税抜),売単価(税込),売単価(消費税),メーカー希望価格,税区分(1:内税 2:外税 3非課税),レシート品名,レシート品名(ｶﾅ),PLU名(上段),PLU名(下段),入数,単位,レジ入力時記号,部門名,ラインコード,ライン名,酒区分コード,酒区分名,商品区分コード,商品区分名,内容量,仕入形態,シェルフラベル区分,調理,ポイント管理,最終売上日,JANコード2,JANコード3,JANコード4,JANコード5,JANコード6,JANコード7,JANコード8,JANコード9,JANコード10,備考,登録日時,登録担当者コード,登録担当者,変更日時,変更担当者コード,変更担当者名">
				<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">					
					<cfloop index="cnt" from="1" to="#recordCount#">
						<cfset data = "">
							<cfset data = #qGetProduct.division_id[cnt]# & ","
										 & #qGetProduct.class_id[cnt]# & ","
										 & #qGetProduct.class_name[cnt]# & ","
										 & #qGetProduct.product_id[cnt]# & ","
										 & #qGetProduct.jan1[cnt]# & ","
										 & #qGetProduct.maker_name[cnt]# & "," 
										 & #qGetProduct.product_name[cnt]# & ","
										 & #qGetProduct.product_name_kana[cnt]# & ","
										 & #qGetProduct.standard_name[cnt]# & ","
										 & #qGetProduct.supplier_id[cnt]# & ","
										 & #qGetProduct.supplier_name[cnt]# & ","
										 & #qGetProduct.unit_cost[cnt]# & ","
										 & #qGetProduct.unit_price_without_tax[cnt]# & ","
										 & #qGetProduct.unit_price_include_tax[cnt]# & ","
										 & #qGetProduct.unit_price_tax[cnt]# & ","
										 & #qGetProduct.maker_price[cnt]# & ","
										 & #qGetProduct.tax_class[cnt]# & ","
										 & #qGetProduct.receipt_name[cnt]# & ","
										 & #qGetProduct.receipt_name_kana[cnt]# & ","
										 & #qGetProduct.plu_name[cnt]# & ","
										 & #qGetProduct.plu_name2[cnt]# & ","
										 & #qGetProduct.qty_per_carton[cnt]# & ","
										 & #qGetProduct.unit[cnt]# & ","
										 & #qGetProduct.regi_input_minus_flag[cnt]# & ","
										 & #qGetProduct.division_name[cnt]# & ","
										 & #qGetProduct.line_id[cnt]# & ","
										 & #qGetProduct.line_name[cnt]# & ","
										 & #qGetProduct.alcohol_category_id[cnt]# & ","
										 & #qGetProduct.alcohol_category_name[cnt]# & ","
										 & #qGetProduct.product_category_id[cnt]# & ","
										 & #qGetProduct.product_category_name[cnt]# & ","
										 & #qGetProduct.volume[cnt]# & ","
										 & #qGetProduct.purchase_type[cnt]# & ","
										 & #qGetProduct.shelflabel_type[cnt]# & ","
										 & #qGetProduct.cook_flag[cnt]# & ","
										 & #qGetProduct.point_flag[cnt]# & ","
										 & #qGetProduct.last_sales_date[cnt]# & ","
										 & #qGetProduct.jan2[cnt]# & ","
										 & #qGetProduct.jan3[cnt]# & ","
										 & #qGetProduct.jan4[cnt]# & ","
										 & #qGetProduct.jan5[cnt]# & ","
										 & #qGetProduct.jan6[cnt]# & ","
										 & #qGetProduct.jan7[cnt]# & ","
										 & #qGetProduct.jan8[cnt]# & ","
										 & #qGetProduct.jan9[cnt]# & ","
										 & #qGetProduct.jan10[cnt]# & ","
										 & #qGetProduct.memo[cnt]# & ","
										 & #qGetProduct.char_create_date[cnt]# & ","
										 & #qGetProduct.create_account[cnt]# & ","
										 & #qGetProduct.create_person[cnt]# & ","
										 & #qGetProduct.modify_date[cnt]# & ","
										 & #qGetProduct.modify_account[cnt]# & ","
										 & #qGetProduct.modify_person[cnt]#>
									 
						<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
					</cfloop> --->


				
		</cfoutput>
</body>
</html>