<cfinclude template = "init.cfm">
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />


</head>
<title><cfoutput>#lang_src.menu.item#</cfoutput></title>
	<link href="images/favicon.ico" rel="shortcut icon">
	<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">
	<!--- <link rel="stylesheet" href="css/base/jquery.ui.base.css" /> --->
	<link rel="stylesheet" href="css/base/jquery.ui.theme.css" />
	<link rel="stylesheet" href="css/base/jquery.ui.datepicker.css" />
	<link rel="stylesheet" href="css/base/jquery.ui.core.css" />	
    <link href="css/shopcenter.css" rel="stylesheet" type="text/css">
	
    
	<style>
	
	
		
/*		.header_area {  
		    position: fixed !important;  
		    position: absolute;  
		    top: 0;  
		    left: 0;  
		    width: 100%;  
		    height: 110px;  
		    background-image:url(images/mokume1490x900.jpeg);  
		    z-index: 1;  
		}*/  
		/** html div#contents_area{  
		    height: 100%;  
		    overflow: auto;  
		} 
*/
		th, td { white-space: nowrap; }
    	div.dataTables_wrapper {
        /*width: 1200px;*/
        margin: 0 auto;
    }
    td.selected_product{
    	background-color: rgba(250,255,194,1.0);
    	height:50px;
    }
    .no_sale_back{
    	width:150px;
    	/*background-color:#ef857d;*/
    }
　/*ノーマル*/
	#pageNav1{	
		}
	#pageNav1 li {
		display: table-cell;
	}
	#pageNav1 li a {
		margin:0px 0px 0px 0px;
		padding: 5px 15px;
		background-image:url(images/gray70.png);
		text-decoration: none;
		vertical-align: middle;
		color:rgb(102,102,102);
	}
	#pageNav1 li span{
		color:rgb(60,60,60);
		margin:0px 3px 5px 0px;
		padding: 5px 15px;
		background: #fff;
		text-decoration: none;
		vertical-align: middle;
		}
	#pageNav1 li a:hover {
		color: rgb(145,69,75);
		border-color: #00f;
		background-color: rgb(255,219,217);
		}
		
	#pageNav2{	
		width:900px;
		text-align:left;
		margin:15px 0px 5px 0px;
		}
	#pageNav2 li {
		display: table-cell;
		padding:0;
		border-right: rgb(255,255,255) solid 1px;
		}
	#pageNav2 li a {
		display:inline-block;
		margin:0px 0.5px 5px 0px;
		padding:5px 10px;
		background-image:url(images/gray70.png);
		text-decoration: none;
		vertical-align: middle;
		color:rgb(102,102,102);
		}
	/*#pageNav2 li span{
		margin:0px 3px 5px 0px;
	padding: 5px 10px;
	background: #fff;
	}*/
	#pageNav2 li a:hover {
		color: rgb(145,69,75);
		border-color: #00f;
		background-color: rgb(255,219,217);
		}
	#pageNav2 li a:visited{
		color: rgb(145,69,75);
		border-color: #00f;
		background-color: rgb(255,219,217);
		}
		
		.list_bt2{
		font-size:16px;
		line-height: 40px;
		width:170px;
		height:40px;
		margin:10px;
		background-color:rgb(204,204,204);
		float:left;
		}
		input.list_bt2{
		font-size:16px;
		line-height:20px;
		width:170px;
		height:40px;
		border:none;
		background:none;
		-webkit-appearance:none;
		}

/*	.table-me tr:nth-child(even) td {
	    background-color: rgba(206,243,245,0.8);
	}
	.table-me tr:nth-child(odd) td {
	    background-color: white;
	}
	.table-me tr:hover  td {
	    background-color: rgba(255,255,255,0.1);
	}*/
	.even {
		background-color: rgba(206,243,245,0.8);
	}

	.odd {
		background-color: white;
	}	
	.sort{
		cursor:pointer;
	}
	</style>
<cfif IsDefined("session.member_id") eq false>
	<cflocation url="login.cfm">
</cfif>
<body>
<div class="sky">
<div class="cloud2">
	
	
		<div align="left" id="contentsArea">
        <cfquery name="qGetAdmin" datasource="#application.dsn#">
            SELECT m_currency.decimal_place,m_admin.division_flag
              FROM m_admin LEFT OUTER JOIN m_currency ON m_admin.currency_id = m_currency.currency_id   
             WHERE member_id = "#session.member_id#"
        </cfquery>				
		<!--- 今日 --->
		<!--- <cfset today = DateFormat(now(), "yyyy/mm/dd")> --->
		<!--- 削除から戻った場合 --->

		<cfif StructKeyExists(url,"frm_del") and url.frm_del eq 1>
			<cfset form.search = 3>
		    <cfset form.product_id_list = url.il>
		</cfif>
		<cfif Isdefined("URL.sort_flg") is false>
			<cfset sort_flg = 1>
		<cfelse>
			<cfset sort_flg = URL.sort_flg>
		</cfif>
		<cfif IsDefined("session.decimal_place")>
			<cfset decimal_place = session.decimal_place>
		<cfelse>
	
			<cfset decimal_place = qGetAdmin.decimal_place>
		</cfif>

			<cfif StructKeyExists(form,"search") eq false>
				<cfset form.search = 2>
			</cfif>
		    		
			<cfif StructKeyExists(form,"search") eq false or form.search eq 1 or (StructKeyExists(url,"sch") and url.sch eq 1)>
				<cfinclude template = "general_settings.cfm">
				<cfset form.search = 1>

				<cfquery datasource="#application.dsn#" name="qGetDivision">
					SELECT division_id,
						   division_name
					 FROM  m_division
					 WHERE member_id = '#session.member_id#' AND del_flag = 0 
					ORDER BY LPAD(division_id, 10, '0')
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qGetLine">
					SELECT line_id,
						   line_name
					 FROM  m_line
					 WHERE member_id = '#session.member_id#' AND del_flag = 0 
					ORDER BY LPAD(line_id, 10, '0')
				</cfquery>				
				<!--- セレクト用 --->
				<cfset opt = "">
				<cfset opt_line = "">
				<cfloop index="i" from="1" to="#qGetDivision.RecordCount#">
					<cfset opt = opt & "<option value='#qGetDivision.division_id[i]#'>#qGetDivision.division_id[i]#&nbsp;#qGetDivision.division_name[i]#</option>">
				</cfloop>
				<cfloop index="i" from="1" to="#qGetLine.RecordCount#">
					<cfset opt_line = opt_line & "<option value='#qGetLine.line_id[i]#'>#qGetLine.line_id[i]#&nbsp;#qGetLine.line_name[i]#</option>">
				</cfloop>
			<cfelseif form.search eq 2 or form.search eq 3>
				<cfquery datasource="#application.dsn#" name="qGetProduct">
				  SELECT m_product.division_id,
				         m_division.division_name,
				         m_product.line_id,
				         m_line.line_name,
				         m_product.class_id,
				         m_product.product_id,
				         CONCAT("'",CONCAT(m_product.product_id,"'")) char_product_id,
				         m_jan.jan as jan1,				         
				         <!--- LEFT(m_product.product_name,10) product_name, --->
				         m_product.product_name,
				         FORMAT(m_product.unit_price_include_tax,#decimal_place#) as unit_price_include_tax,
				         m_product.last_sales_date,
				         m_product.create_date,
				         m_product.modify_date,
				         m_product.img_ext,
				         DATE_FORMAT(m_product.last_sales_date,'%d/%m/%Y %H:%i') as char_last_sales_date,
				         DATE_FORMAT(m_product.create_date,'%d/%m/%y %H:%i') as char_create_date,
				         DATE_FORMAT(m_product.modify_date,'%d/%m/%y %H:%i') as char_modify_date
				    FROM m_product LEFT OUTER JOIN m_jan ON m_product.member_id = m_jan.member_id AND m_product.product_id = m_jan.product_id
				                   LEFT OUTER JOIN m_division         ON m_product.member_id = m_division.member_id AND m_product.division_id = m_division.division_id
				                   LEFT OUTER JOIN m_line         ON m_product.member_id = m_line.member_id AND m_product.line_id = m_line.line_id				                   
					   		<cfif StructKeyExists(form,"jan1") and form.jan1 neq "">
						   		,( SELECT distinct m_jan.member_id,
			                   								m_jan.product_id
				                                       FROM m_jan
				                                      WHERE m_jan.member_id = '#session.member_id#' AND
				                                      		m_jan.del_flag = 0 AND
				                                            m_jan.jan LIKE '%#trim(form.jan1)#%' ) JAN 
						   	</cfif>
				   WHERE m_product.member_id = '#session.member_id#' 
				     AND m_product.del_flag = 0
				     AND m_jan.del_flag = 0
				     AND m_jan.sort_order = 1
				    
					   		<cfif StructKeyExists(form,"jan1") and form.jan1 neq "">
					   			and m_product.member_id = JAN.member_id
					   			and m_product.product_id = JAN.product_id
						   	</cfif>
				   <cfif form.search eq 2>
					   	<cfscript>
					   		if(StructKeyExists(form,"division_id") and form.division_id neq ""){
					   			WriteOutput(" AND LPAD(m_product.division_id, 10, '0') = LPAD('#form.division_id#', 10, '0')");
					   			};
					   		if(StructKeyExists(form,"line_id") and form.line_id neq ""){
					   			WriteOutput(" AND LPAD(m_product.line_id, 10, '0') = LPAD('#form.line_id#', 10, '0')");
					   			};
					   		if(StructKeyExists(form,"product_id") and form.product_id neq ""){
					   			WriteOutput(" AND LPAD(m_product.product_id, 20, '0') = LPAD('#form.product_id#', 20, '0')");
					   			};
					   		if(StructKeyExists(form,"product_name") and form.product_name neq ""){
					   			WriteOutput(" AND (m_product.product_name LIKE '%#trim(form.product_name)#%'
					   							OR m_product.product_name_kana LIKE '%#trim(form.product_name)#%')");
					   			};
					   		if(StructKeyExists(form,"unit_price_include_tax") and form.unit_price_include_tax neq ""){
					   			WriteOutput(" AND m_product.unit_price_include_tax = '#form.unit_price_include_tax#'");
					   			};
					   		if(StructKeyExists(form,"last_sales_date") and form.last_sales_date neq ""){
					   			WriteOutput(" AND m_product.last_sales_date = '#form.last_sales_date#'");
					   			};
					   		if(StructKeyExists(form,"create_date") and form.create_date neq ""){
					   			WriteOutput(" AND m_product.create_date = '#form.create_date#'");
					   			};
					   		if(StructKeyExists(form,"modify_date") and form.modify_date neq ""){
					   			WriteOutput(" AND m_product.modify_date = '#form.modify_date#'");
					   			};
					   		// 一定期間売れていないものの検索
					   		if(StructKeyExists(url,"nsl") and url.nsl neq "" and url.kkn neq 0){
					   			WriteOutput(" AND m_product.last_sales_date +interval " & #url.kkn# & " month <= now() AND m_product.create_date +interval " & #url.kkn# & " month <= now()");
					   		}else{
					   			if(StructKeyExists(url,"nsl") and url.nsl neq "" and url.kkn eq 0){
					   				WriteOutput(" AND m_product.last_sales_date IS NULL");
					   			}
					   		};
					   	</cfscript>


				   </cfif>
				   <cfif StructKeyExists(session,"product_id_list") and session.product_id_list neq "">
				   	<!--- AND (
				   		<cfloop index = "index_name" list='#form.product_id_list#'>
					   		 m_product.product_id = '#index_name#' OR
				   		</cfloop>
				   	0 <> 0) --->
				   	 <!--- AND m_product.product_id IN(#PreserveSingleQuotes(form.product_id_list)#) --->


				   		<cfset loop_cnt = 1>
				   		AND m_product.product_id IN(
				   		<cfloop index="id" list="#session.product_id_list#">
				   			<cfif loop_cnt neq 1>
					   			,
				   			</cfif>
				   			'#id#'
					   		<cfset loop_cnt = loop_cnt + 1>
				   		</cfloop>
					   		)
				   	 
				   </cfif>


				  				   
				<cfscript>
					switch(sort_flg){
						case "1":
							WriteOutput("ORDER BY LPAD(m_product.product_id, 20, 0)");
							break;
						case "2":
							WriteOutput("ORDER BY LPAD(m_product.product_id, 20, 0) DESC");
							break;							
						case "3":
							WriteOutput("ORDER BY LPAD(m_product.division_id, 10, '0')");
							break;
						case "4":
							WriteOutput("ORDER BY LPAD(m_product.division_id, 10, '0') DESC");
							break;							
						case "5":
							WriteOutput("ORDER BY m_product.product_name");
							break;
						case "6":
							WriteOutput("ORDER BY m_product.product_name DESC");
							break;							
						case "7":
							WriteOutput("ORDER BY m_product.unit_price_include_tax");
							break;
						case "8":
							WriteOutput("ORDER BY m_product.unit_price_include_tax DESC");
							break;

						case "9":
							WriteOutput("ORDER BY m_product.img_ext");
							break;
						case "10":
							WriteOutput("ORDER BY m_product.img_ext DESC");
							break;
						case "11":
							WriteOutput("ORDER BY LPAD(m_product.line_id, 10, '0')");
							break;
						case "12":
							WriteOutput("ORDER BY LPAD(m_product.line_id, 10, '0') DESC");
							break;
						case "13":
							WriteOutput("ORDER BY LPAD(jan1, 20, 0)");
							break;
						case "14":
							WriteOutput("ORDER BY LPAD(jan1, 20, 0) DESC");
							break;																												
						default:
							WriteOutput("ORDER BY LPAD(m_product.product_id, 20, 0)");
					}
				</cfscript>			   		   
				</cfquery>
			</cfif>
			<!--- 選択された商品コードをJSでここに挿入 --->
			<input type="hidden" id="selectedProductID" value="">				
			<!--- ajax用のmember_id --->
			<cfoutput>
				<input type="hidden" name="mem_id" id="mem_id" value="#session.member_id#">
				<input type="hidden" id="language" value="#session.language#">
			</cfoutput>
			<form action="master_product.cfm" name="master_product" method="post" >
            	<cfoutput>
					<div class="header_area no_print">
	                	<div class="topmenu"  style=" overflow:hidden;" >	
	                    	<div style="height:60px; margin-left:auto; margin-right:auto;">
	                    
	                    
							
							<!--<div style="color:white;font-size:x-large;margin-left:10px;text-align:center;">Item</div>-->
		
									<!--- form.searchが1の場合は検索項目入力の画面 --->
									<cfif form.search eq 1>
										<div style="float:left;">
					                        <table class="bt_table" cellpadding="0" cellspacing="0" >
					                   			<tr>
					                   				<td align="center" style="padding-top:8px;">
														<input type="button" value="" class="m_button3" style="background-image:url(images/menu_bt3.png); width:30px; height:30px;"  onclick="back_to_menu()">
													</td>
												</tr>
					                    		<tr>
					                    			<td>#lang_src.btn.menu#</td>
					                    		</tr>
					                    	</table>
				                    	</div>
				                    
											<!--<input type="button" value="Menu" class="m_button" onclick="back_to_menu()">-->

				                        <div style="float:right;">    
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px; ">
														<input type="submit" value="" name="search_btn" class="m_button3 search_btn" style="background-image: url(images/search_bt6.png); width:30px; height:30px; " target="_self">
													</td>
												</tr>
												<tr>
													<td >#lang_src.btn.search#</td>
												</tr>
				                    		</table>
											<!--<input type="submit" value="　　Search　　" name="search_btn" class="m_button search_btn" target="_self">-->
				                            
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px; ">
				                    					<input type="button" value="" name="input_btn" class="m_button3 input_btn" style="background-image: url(images/tsuika_bt3.png); width:30px; height:30px; " onclick="to_input('sinki');">
				                    				</td>
				                    			</tr>
				                    			<tr>
				                    				<td >#lang_src.btn.add#</td>
				                    			</tr>
				                    		</table>
											<!--<input type="button" value="Add" name="input_btn" class="m_button input_btn" onclick="to_input('sinki');">-->
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px; ">
				                            			<input type="button" value="" name="import_btn" class="m_button3 import_btn" style="background-image: url(images/import_bt2.png); width:30px; height:30px; " onclick="to_import();">
				                            		</td>
				                            	</tr>
				                            	<tr>
				                            		<td >#lang_src.btn.import#</td>
				                            	</tr>
				                            </table>
											<!--<input type="button" value="Import" name="import_btn" class="m_button import_btn" onclick="to_import();">-->
				                            
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px; ">
				                            			<input type="button" value="" name="input_btn" class="m_button3 import_btn" style="background-image: url(images/import_bt2.png); width:30px; height:30px; " onclick="to_export('only_column_names');">
				                            		</td>
				                            	</tr>
				                            	<tr>
				                            		<td >#lang_src.btn.import_format#</td>
				                            	</tr>
				                            </table>
											<!--<input type="button" value="Format file for imports" name="input_btn" class="m_button input_btn" style="width:220px;" onclick="to_export('only_column_names');">-->
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px;">
				                            			<input type="button" value=""  class="m_button3 no_sale_back" style="background-image: url(images/search_red_bt1.png); width:30px; height:30px;" onClick="toggleNosale()">
				                            		</td>
				                            	</tr>
				                            	<tr>
				                            		<td >#lang_src.btn.last_sales_day#</td>
				                            	</tr>
				                            </table>
											<!--<input type="button" value ="Search from the last sales day" class="m_button no_sale_back" onClick="toggleNosale()">-->
											<span class="select-box1">
					                            <label>
													<select class="m_button no_sale no_sale_back" style="display:none; margin-top:15px; margin-left:20px; height:30px; width:130px;" id="nosale_kikan" name="nosale_kikan">
													  <option value="1">More than 1 month</option>
															<option value="3">More than 3 month</option>
															<option value="6">More than half year</option>
															<option value="12" selected="selected">More than 1 year</option>
															<option value="24">More than 2 year</option>
															<option value="36">More than 3 year</option>
															<option value="0">No Sale</option>
						                            </select>
					                             </label>
				                            </span>
				                            <input type="button" value="#lang_src.btn.search#" onclick="no_sale()" style="display:none;width:100px;" class="m_button4 no_sale no_sale_back">
				                        </div>
												
										<input type="hidden" value="2" name="search" id="search">
										<div style="margin-left:40%; margin-right:40%;">
											<span style="color:  rgba(0,37,93,1.00); font-size:24px; line-height:60px;  text-align:center;  vertical-align:middle;">#lang_src.menu.item#</span>
										</div>

									<cfelse>
				                        <div style="float:left;">
					                        <table class="bt_table" cellpadding="0" cellspacing="0" >
					                        	<tr>
					                        		<td align="center" style="padding-top:8px;">
					                        			<input type="button" value="" class="m_button3" style="background-image:url(images/menu_bt3.png); width:30px; height:30px;"  onclick="back_to_menu()">
					                   				</td>
					                   			</tr>
					                    		<tr>
					                    			<td>#lang_src.btn.menu#</td>
					                    		</tr>
					                    	</table>
				                    	</div>
				                    
											<!--<input type="button" value="Menu" class="m_button" onclick="back_to_menu()">-->
											<!--- <input type="button" value="　　検　索　　" name="search_btn" class="m_button search_btn" onclick="to_master();"> --->
				                        <div style="float:right;">    
					                        <table class="bt_table"  cellpadding="0" cellspacing="0" >
					                        	<tr>
					                        		<td align="center" style="padding-top:8px; ">
					                        			<input type="button" value="" oname="search_btn" class="m_button3 search_btn" style="background-image: url(images/search_bt6.png); width:30px; height:30px; " onclick="to_master2();">
					                   				</td>
					                   			</tr>
					                    		<tr>
					                    			<td >#lang_src.btn.search#</td>
					                    		</tr>
					                    	</table>
											<!--<input type="button" value="　　Search　　" name="search_btn" class="m_button search_btn" onclick="to_master2();">-->

											<table class="bt_table"  cellpadding="0" cellspacing="0" >
				                    			<tr>
				                    				<td align="center" style="padding-top:8px; ">
				                    					<input type="button" value="" name="input_btn" class="m_button3 input_btn" style="background-image: url(images/tsuika_bt3.png); width:30px; height:30px; " onclick="to_input('sinki');">
				                   					</td>
				                   				</tr>
				                    			<tr>
				                    				<td >#lang_src.btn.add#</td>
				                    			</tr>
				                    		</table>
				                            
				                            <!--<input type="button" value="Add" name="input_btn" class="m_button input_btn" onclick="to_input('sinki');">-->
				                            
				                            
										<cfif qGetProduct.RecordCount GTE 1><!--- 該当データがあった場合 --->
						                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3 input_btn"  
						                   style="background-image: url(images/shosai_bt3.png); width:30px; height:30px; " onclick="to_input('syousai');">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.details#</td></tr>
						                    </table>
														<!--<input type="button" value="Details" name="input_btn" class="m_button input_btn" onclick="to_input('syousai');">-->
						                                <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3 input_btn"  
						                   style="background-image: url(images/hukusei_bt3.png); width:30px; height:30px; " onclick="to_copy();">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.copy#</td></tr>
						                    </table>
														<!--<input type="button" value="Copy" name="input_btn" class="m_button input_btn" onclick="to_copy();">-->
						                                <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3 input_btn"  
						                   style="background-image: url(images/delete_bt3.png); width:30px; height:30px; " onclick="to_del();">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.delete#</td></tr>
						                    </table>
														<!--<input type="button" value="Delete" name="input_btn" class="m_button input_btn" onclick="to_del();">-->
<!--- 						                                <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3"  
						                   style="background-image: url(images/delete_all_bt2.png); width:30px; height:30px; " onclick="to_selected_list();">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.delete_all#</td></tr>
						                    </table> --->
														<!--<input type="button" value="Delete All" name="input_btn" class="m_button" onclick="to_selected_list();">-->
														<!--- <input type="button" value="印刷" name="input_btn" class="m_button input_btn" onclick="to_print();"> --->
						                                <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3 input_btn"  
						                   style="background-image: url(images/print_bt2.png); width:30px; height:30px; " onclick="printByBrowser();">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.print#</td></tr>
						                    </table>
				                            <table class="bt_table"  cellpadding="0" cellspacing="0" >
				                            	<tr>
				                            		<td align="center" style="padding-top:8px; ">
				                            			<input type="button" value="" name="import_btn" class="m_button3 import_btn" style="background-image: url(images/import_bt2.png); width:30px; height:30px; " onclick="to_import();">
				                            		</td>
				                            	</tr>
				                            	<tr>
				                            		<td >#lang_src.btn.import#</td>
				                            	</tr>
				                            </table>			                    
														<!--<input type="button" value="Print" name="input_btn" class="m_button input_btn" onclick="printByBrowser();">-->
						                                
						                                <table class="bt_table"  cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px; ">
						                    <input type="button" value="" name="input_btn" class="m_button3 input_btn"  
						                   style="background-image: url(images/export_bt3.png); width:30px; height:30px; " onclick="to_export();">
						                   </td></tr>
						                    <tr><td >#lang_src.btn.export#</td></tr>
						                    </table>
						                    <!--- <input type="hidden" value="1" name="search" id="search"> --->
														<!--<input type="button" value="Export" name="input_btn" class="m_button input_btn" onclick="to_export();">-->
										<cfelse>
														<!--- <input type="button" value="戻る" class="m_button search_btn" onclick="to_master();"> --->
	<!--- 					                    <table class="bt_table" cellpadding="0" cellspacing="0" >
						                    <tr><td align="center" style="padding-top:8px;">
						                   <input type="button" value="" class="m_button3 search_btn" 
						                   style="background-image: url(images/back_bt1.png); width:30px; height:30px;"  onclick="to_master2();">
						                   </td></tr>
						                    <tr><td>Back</td></tr>
						                    </table> --->
														<!--<input type="button" value="Back" class="m_button search_btn" onclick="to_master2();">-->
										</cfif>
											<cfif form.search eq 2 and IsDefined("url.sch")>
												<input type="hidden" value="1" name="search" id="search">
											<cfelse>
												<input type="hidden" value="2" name="search" id="search">
											</cfif>
											
									
										</div>
										<div style="margin-left:40%; margin-right:40%;">
											<span style="color: rgba(50,27,2,1.00); font-size:24px; line-height:60px;  text-align:center;  vertical-align:middle;">#lang_src.menu.item#</span>
										</div>
								</cfif>                    
	                    		</div>
	                    </div>
					</div>
				</cfoutput>
	<cfif form.search neq 1>		
	    <cfif IsDefined("URL.eq_page") is false>
	        <cfset page_no = 1>
	        <cfset before = 0>
	        <cfset after = 2>
	        <cfset page_flg = 1>
	    <cfelse>
	    	<cfset page_flg = url.eq_page>
	    	<cfif page_flg NEQ 1>
	<!---
	    	<cfif IsDefined("Form.keyword") is FALSE>
	--->
				<cfset page_no = Int(URL.eq_page)>
	            <cfset before = Int(URL.eq_page) - 1>
	            <cfset after = Int(URL.eq_page) + 1>
	        <cfelse>
				<cfset page_no = 1>
	            <cfset before = 0>
	            <cfset after = 2>
	        </cfif>
	    </cfif>
		<!--- 表示する行数を指定する --->
	    <cfset MaxRows = 15>
	    <!--- 表示開始行番号の設定 --->
	    <cfset s_page = (MaxRows * (page_no - 1)) + 1>
	    <!--- 表示終了行番号の設定 --->
	    <cfset e_page = (MaxRows * page_no)>
	    <!--- 検索行数のページ番号の総数の設定 --->
	    <!--- 変更必須--->
	    <cfset int_count = Int(qGetProduct.RecordCount / MaxRows)>
	    <cfset buffer = qGetProduct.RecordCount / MaxRows>
	    <cfset last_page = Ceiling(buffer)>
	    <cfif int_count LT buffer>
	        <cfset count_end = Int(qGetProduct.RecordCount / MaxRows) + 1>
	    <cfelse>
	        <cfset count_end = Int(qGetProduct.RecordCount / MaxRows)>
	    </cfif>
	    <!--- 表示するページ番号の開始位置の設定 --->
	    <cfset op_str = page_no - 4>
	    <!--- 表示するページ番号の終了位置の設定 --->
	    <cfif op_str LT 1>
	        <cfset op_str = 1>
	        <cfset op_end = 10>
	    <cfelse>
	        <cfset op_end = page_no + 5>
	    </cfif>
	    <cfif op_end GT count_end>
	        <cfset op_end = count_end>
	        <cfset op_str = count_end - 9>
	        <cfif op_str LT 1><cfset op_str = 1></cfif>
	    </cfif>
		<!---<cfif IsDefined("Form.section_name") is false>
			<cfset Form.section_name = "">
	    </cfif>--->
			<!--- タブ初期値設定 --->

	</cfif>		
                       
                
				<div align="center" style="height:500px; margin-left:auto; margin-right:auto;<cfif form.search eq 1>margin-top:30px;</cfif>" id="contents_area">

							
					<div style="width:980px;margin-top:10px;">
					    <cfif form.search neq 1 and 0 LT qGetProduct.RecordCount>
					    	<cfoutput>
						        <cfset search_t_width = 300 + (40 * ((op_end - op_str) + 1))>
						         <div style="font-size:10px;width:980px;" align="right">
						         	<cfif 0 LT qGetProduct.RecordCount>
						                <cfset search_t_width = 280 + (40 * ((op_end - op_str) + 1))>
											<ul id="pageNav1" width="#search_t_width#">					 				  	  
							                    <li>
							                    	<a onclick="changePage(1)">TOP</a>
							                    </li>
							                    	<cfif page_no eq 1>
							                        	<li>&nbsp;</li>
							                    	<cfelse>
							                        	<li>
							                        		<a onclick="changePage(#before#)">Prev</a>
							                        	</li>
							                    	</cfif>
							                    		<cfloop index="Counter" from="#op_str#" to="#op_end#">
							                        		<li>
							                            		<cfif page_no is Counter>
							                                		<li><span>#Counter#</span></li>
							                    				<cfelse>
							                                		<a onclick="changePage(#Counter#)">#Counter#</a>
							                            		</cfif>
							                        		</li>
							                    		</cfloop>
							            			<cfif page_no IS op_end>
							                			<li>&nbsp;</li>
							            			<cfelse>
							                        	<li>
							                        		<a onclick="changePage(#after#)">Next</a>
							                        	</li>
							            			</cfif>
							                        	<li>
							                        		<a onclick="changePage(#last_page#)">END</a>
							                        	</li>	                   
											</ul>
									</cfif>
								</div>
							</cfoutput>
						</cfif>						
						<table cellpadding="0" cellspacing="0" border="0" class="table-me" id="table_id" style="border-collapse: collapse; font-size: small;display:none;width:980px;">
							<cfoutput>
								<thead style="background-color:white;">
									<tr>
										<cfif form.search eq 2 or form.search eq 3>
											<th width="50" align='center'>&nbsp;
												<cfif sort_flg eq 10>
													<a onclick="changeSort(9)" class="sort">#lang_src.term.image#
														<img src="images/sort_desc.png" border="0">
													</a>
												<cfelseif sort_flg eq 9>
													<a onclick="changeSort(10)" class="sort">#lang_src.term.image#
														<img src="images/sort_asc.png" border="0">
													</a>
												<cfelse>
													<a onclick="changeSort(9)" class="sort">#lang_src.term.image#
														<img src="images/sort_both.png" border="0">
													</a>
												</cfif>
											</th>
										</cfif>									
										<th width="60" align='center'>
											<cfif sort_flg eq 2>
												<a onclick="changeSort(1)" class="sort">#lang_src.term.item_code#
													<img src="images/sort_desc.png" border="0">
												</a>
											<cfelseif sort_flg eq 1>
												<a onclick="changeSort(2)" class="sort">#lang_src.term.item_code#
													<img src="images/sort_asc.png" border="0">
												</a>
											<cfelse>
												<a onclick="changeSort(1)" class="sort">#lang_src.term.item_code#
													<img src="images/sort_both.png" border="0">
												</a>
											</cfif>
										</th>
										<th width="60" align='center'>
											<cfif sort_flg eq 14>
												<a onclick="changeSort(13)" class="sort">SKU
													<img src="images/sort_desc.png" border="0">
												</a>
											<cfelseif sort_flg eq 13>
												<a onclick="changeSort(14)" class="sort">SKU
													<img src="images/sort_asc.png" border="0">
												</a>
											<cfelse>
												<a onclick="changeSort(13)" class="sort">SKU
													<img src="images/sort_both.png" border="0">
												</a>
											</cfif>
										</th>				
										<th width="100" align='center'>&nbsp;
											<cfif sort_flg eq 4>
												<a onclick="changeSort(3)" class="sort">#lang_src.term.category#
													<img src="images/sort_desc.png" border="0">
												</a>
											<cfelseif sort_flg eq 3>
												<a onclick="changeSort(4)" class="sort">#lang_src.term.category#
													<img src="images/sort_asc.png" border="0">
												</a>
											<cfelse>
												<a onclick="changeSort(3)" class="sort">#lang_src.term.category#
													<img src="images/sort_both.png" border="0">
												</a>
											</cfif>
										</th>



										<cfif qGetAdmin.division_flag eq 2 or  qGetAdmin.division_flag eq 3>
											<th width="100" align='center'>&nbsp;
												<cfif sort_flg eq 12>
													<a onclick="changeSort(11)" class="sort">#lang_src.term.line#
														<img src="images/sort_desc.png" border="0">
													</a>
												<cfelseif sort_flg eq 11>
													<a onclick="changeSort(12)" class="sort">#lang_src.term.line#
														<img src="images/sort_asc.png" border="0">
													</a>
												<cfelse>
													<a onclick="changeSort(11)" class="sort">#lang_src.term.line#
														<img src="images/sort_both.png" border="0">
													</a>
												</cfif>
											</th>
										</cfif>
										<!--- <th width="60">SKU&nbsp;</th> --->
										<th width="200" align='center'>&nbsp;
											<cfif sort_flg eq 6>
												<a onclick="changeSort(5)" class="sort">#lang_src.term.item_name#
													<img src="images/sort_desc.png" border="0">
												</a>
											<cfelseif sort_flg eq 5>
												<a onclick="changeSort(6)" class="sort">#lang_src.term.item_name#
													<img src="images/sort_asc.png" border="0">
												</a>
											<cfelse>
												<a onclick="changeSort(5)" class="sort">#lang_src.term.item_name#
													<img src="images/sort_both.png" border="0">
												</a>
											</cfif>
										</th>
										<th width="60" align='center'>&nbsp;
											<cfif sort_flg eq 8>
												<a onclick="changeSort(7)" class="sort">#lang_src.term.price_include_tax#
													<img src="images/sort_desc.png" border="0">
												</a>
											<cfelseif sort_flg eq 7>
												<a onclick="changeSort(8)" class="sort">#lang_src.term.price_include_tax#
													<img src="images/sort_asc.png" border="0">
												</a>
											<cfelse>
												<a onclick="changeSort(7)" class="sort">#lang_src.term.price_include_tax#
													<img src="images/sort_both.png" border="0">
												</a>
											</cfif>
										</th>
										
										<!--- <th width="60">Recent Sales&nbsp;</th> --->
										<!--- <th width="60">Registered&nbsp;</th>
										<th width="60" height="30">Modified&nbsp;</th> --->
									</tr>
								</thead>
							</cfoutput>
							<cfif form.search eq 1>
								<cflock scope="Session" timeout="2" type="exclusive">
									<cfset session.product_id_list = "">
								</cflock>
								<tbody>
									<tr>
										<td align="left"><input type="text" name="product_id"></td>
										<td align="left"><input type="text" name="jan1"></td>
										<td align="left">&nbsp;
											<select name="division_id">
												<option value="" selected="selected"></option>
												<cfscript>
													WriteOutput(opt);
												</cfscript>
												<!--- <cfoutput>#opt#</cfoutput> --->
											</select>
										</td>
										<cfif qGetAdmin.division_flag eq 2 or qGetAdmin.division_flag eq 3>
										<td align="left">&nbsp;
											<select name="line_id">
												<option value="" selected="selected"></option>
												<cfscript>
													WriteOutput(opt_line);
												</cfscript>
												<!--- <cfoutput>#opt#</cfoutput> --->
											</select>
										</td>
										</cfif>
										<!--- <td align="center"><input type="text" name="jan1"></td> --->
										<td align="left"><input type="text" name="product_name"></td>
										<td align="left"><input type="text" name="unit_price_include_tax"></td>
<!--- 										<td align="left">
											<input type="text" class="jquery-ui-datepicker" name="last_sales_date">
										</td> --->
<!--- 										<td align="left">
											<input type="text" class="jquery-ui-datepicker" name="create_date">
										</td>
										<td align="left">
											<input type="text" class="jquery-ui-datepicker" name="modify_date">
										</td> --->
									</tr>
								</tbody>
							<cfelseif form.search eq 2 or form.search eq 3>
								<div id='loading'><img src='images/kid.GIF'></div>
								<tbody>
									<cfset loop_count = qGetProduct.RecordCount>
									<cfset product_id_list = ArrayToList(qGetProduct["product_id"],",")>
									<cflock scope="Session" timeout="2" type="exclusive">
										<cfset session.product_id_list = product_id_list>
									</cflock>
									<cfscript>

										for (cnt=s_page;cnt lte e_page;cnt++){
											if(cnt gt loop_count){
												break;
											}
											img_ext = "";
											if(qGetAdmin.division_flag == 1){
												if(qGetProduct.img_ext[cnt] != ""){
													img_ext = "product_img/" & session.member_id & "/" & qGetProduct.product_id[cnt] & "." & qGetProduct.img_ext[cnt] & "?" & DatePart("l",now());
													a = "<tr><td align='center' style='width:60px;'><img width='60' height='30' border='0' src='" & img_ext & "'></td><td>" & qGetProduct.product_id[cnt] & "</td><td>" & qGetProduct.jan1[cnt] & "</td><td>" & qGetProduct.division_id[cnt] & "." & qGetProduct.division_name[cnt] & "</td><td>" & qGetProduct.product_name[cnt] & "</td><td align='right'>" & qGetProduct.unit_price_include_tax[cnt] & "</td></tr>";
												}else{
													img_ext = "images/item_img.png";
													a = "<tr><td align='center' style='width:60px;'><img width='60' height='30' border='0' src='" & img_ext & "'></td><td>" & qGetProduct.product_id[cnt] & "</td><td>" & qGetProduct.jan1[cnt] & "</td><td>" & qGetProduct.division_id[cnt] & "." & qGetProduct.division_name[cnt] & "</td><td>" & qGetProduct.product_name[cnt] & "</td><td align='right'>" & qGetProduct.unit_price_include_tax[cnt] & "</td></tr>";
												}
											}else{

												if(qGetProduct.img_ext[cnt] != ""){
													img_ext = "product_img/" & session.member_id & "/" & qGetProduct.product_id[cnt] & "." & qGetProduct.img_ext[cnt] & "?" & DatePart("l",now());
													a = "<tr><td align='center' style='width:60px;'><img width='60' height='30' border='0' src='" & img_ext & "'></td><td>" & qGetProduct.product_id[cnt] & "</td><td>" & qGetProduct.jan1[cnt] & "</td><td>" & qGetProduct.division_id[cnt] & "." & qGetProduct.division_name[cnt] & "</td><td>" & qGetProduct.line_id[cnt] & "." & qGetProduct.line_name[cnt] & "</td><td>" & qGetProduct.product_name[cnt] & "</td><td align='right'>" & qGetProduct.unit_price_include_tax[cnt] & "</td></tr>";
												}else{
													img_ext = "images/item_img.png";
													a = "<tr><td align='center' style='width:60px;'><img width='60' height='30' border='0' src='" & img_ext & "'></td><td>" & qGetProduct.product_id[cnt] & "</td><td>" & qGetProduct.jan1[cnt] & "</td><td>" & qGetProduct.division_id[cnt] & "." & qGetProduct.division_name[cnt] & "</td><td>" & qGetProduct.line_id[cnt] & "." & qGetProduct.line_name[cnt] & "</td><td>" & qGetProduct.product_name[cnt] & "</td><td align='right'>" & qGetProduct.unit_price_include_tax[cnt] & "</td></tr>";
												}												
											}



											
											//a = "<tr><td>" & qGetProduct.product_id[cnt] & "</td><td>" & qGetProduct.division_id[cnt] & "." & qGetProduct.division_name[cnt] & "</td><td>" & qGetProduct.product_name[cnt] & "</td><td align='right'>" & qGetProduct.unit_price_include_tax[cnt] & "</td><td>" & qGetProduct.char_create_date[cnt] & "</td><td>" & qGetProduct.char_modify_date[cnt] & "</td></tr>";
											
											WriteOutput(a);
										};
									</cfscript>
								</tbody>
								<cfif loop_count LT 1>
									<input type='hidden' id='data_cnt' value="0">
								<cfelse>
									<input type='hidden' id='data_cnt' value="1">
								</cfif>
								<cfoutput>
									<input type='hidden' id='loop_count' value='#loop_count#'>
									<!--- <input type='hidden' name='product_id_list' value='#session.product_id_list#'> --->

									<input type='hidden' name='sort_flg' id='sort_flg' value='#sort_flg#'>
									<input type='hidden' name='eq_page' id='eq_page' value='#page_flg#'>
								</cfoutput>									
							</cfif>
						</table>							
					</div>

				</div>
			</form>
		</div>
		<cfoutput><input type="hidden" id="search_mode" value="#search#"></cfoutput>
		
	
	<script src="js/jquery-1.8.2.min.js"></script>
	<script src="js/jquery-ui.min.js?"></script>
	<script src="js/jquery.dataTables.min.js"></script>
	<script src="js/FixedHeader.js"></script>	

	<!--- <script src="js/master_product.min.js?3"></script> --->
	<script>
var LANG_SRC;
$(document).ready(function(){
	var lang = $("#language").val();
	$.getJSON("lang/term-" + lang + ".json", function (data) {
	  LANG_RSC = data;
		$( '.jquery-ui-datepicker' ) . datepicker({
			dateFormat: LANG_RSC.format.date_form_js,
		    beforeShow: function(input, inst){
		      inst.dpDiv.css({marginTop: 10 + 'px', marginLeft: -100 + 'px'});
		    }	    		
		});	  
	});  	
	$("tr:odd td").addClass("odd");
	$("tr:even td").addClass("even");

		 // var tbl = $('#table_id').dataTable( {	 	
			// "bPaginate"    : false,
			// "bLengthChange": true,
			// "bFilter"      : false,
			// "bSort"        : true,
			// "bInfo"        : false,
			// "bAutoWidth"   : false,
			// "scrollX"      :"780px"
		 //  });
		function makeTable(){
			var d = $.Deferred();
	 		document.getElementById('table_id').style.display = 'table';
	 		//document.getElementById('loading').style.display = 'none';
			//$('#table_id').show('fast')
			$('#loading').remove()	 
			//d.resolve()
			return d.promise()
		}

		 makeTable()
	

	  //tdの1番めの要素のテキストが商品コード

	  	if($('#search_mode').val() == 2 || $('#search_mode').val() == 3){
		 	$('#table_id tbody').on('click', 'tr', function () {
		  		$('.selected_product').removeClass("selected_product");
	        	var product_id = $('td', this).eq(1).text();

	        	if(product_id != ""){
		        	$('#selectedProductID').val(product_id);
		        	$('td',this).addClass("selected_product");
	        	}

	    	} );
		  	$('#table_id tbody').on('dblclick', 'tr', function () {

		  		$('.selected_product').removeClass("selected_product");

	        	var product_id = $('td', this).eq(1).text();
		        	if(product_id != ""){
		        		$('#selectedProductID').val(product_id);
		        		$('td',this).addClass("selected_product");
		        	var lct = $('#loop_count').val();
		        		document.master_product.target = "_self"
						document.master_product.method="post";
						document.master_product.action = "master_product_detail.cfm?p_id=" + product_id + "&lct=" + lct;
						document.master_product.submit();
						}
	    	} );
		  }
	  
  
	});

		function to_input(a){
			if(a != "sinki"){
				var pid = $('#selectedProductID').val();
				var lct = $('#loop_count').val();
					if(pid != ""){
						document.master_product.target = "_self"
						document.master_product.method="post";
						document.master_product.action = "master_product_detail.cfm?p_id=" + pid + "&lct=" + lct;
						document.master_product.submit();
					}else{
						alert(LANG_RSC.phrase.please_select);
					}
			}else{
				location.href = "master_product_input.cfm"
			}
		};
		function no_sale(){
			var kikan = document.master_product.nosale_kikan.value;
			document.master_product.target = "_self"
			document.master_product.method="post";
			document.master_product.action = "master_product.cfm?nsl=1&kkn=" + kikan;
			document.master_product.submit();			
		}
		function to_del(){			
			var pid = $('#selectedProductID').val();
			var lct = $('#loop_count').val();
			var mem_id = $('#mem_id').val();
			var eq_page = $("#eq_page").val();
			var sort_flg = $("#sort_flg").val();
				if(pid != ""){
		            $.ajax({
		                url:"input_check.cfc?method=pDelCheck",
						dataType: "text",
						data: {p_id:pid,member_id:mem_id},
						type: "POST",
		                success: function(a){
							if(a == 100){
								alert("You cannot delete this, because this is in stock.");
								return false;
							}else{
								if(a == 2){
									alert(LANG_RSC.phrase.no_delete_plu);
									return false;
								}else{
									if(a == 3){
										alert("You cannot delete this, because this item is in the stocking slip dealing within two years.");
										return false;
									}else{
										if(a == 4){
											alert(LANG_RSC.phrase.no_delete_sales_slip);
											return false;	
										}else{
											if(a == 5){
												alert("You cannot delete this, because this item is in the disposal slip dealing within two years.");
												return false;	
											}else{
												var cfm = confirm(LANG_RSC.phrase.sure_delete)
												if(cfm){
												document.master_product.target = "_self"	
												document.master_product.method="post";
												document.master_product.action = "master_product_action.cfm?p_id=" + pid + "&lct=" + lct + "&act=3" + "&sort_flg=" + sort_flg + "&eq_page=" + eq_page;
												document.master_product.submit();
												}
											}
										}
									}
								} 
							}
		             },
		                error: function(e){
		                		alert(LANG_RSC.phrase.something_went_wrong);
		                }
		            });					
				}else{
					alert(LANG_RSC.phrase.please_select);
				}
			
		};
		function to_copy(){			
			var pid = $('#selectedProductID').val();
			var lct = $('#loop_count').val();
			var eq_page = $("#eq_page").val();
			var sort_flg = $("#sort_flg").val();			
				if(pid != ""){
					document.master_product.target = "_self"
					document.master_product.method="post";
					document.master_product.action = "master_product_input.cfm?p_id=" + pid + "&lct=" + lct + "&cpy" + "&sort_flg=" + sort_flg + "&eq_page=" + eq_page;
					document.master_product.submit();
				}else{
					alert(LANG_RSC.phrase.please_select);
				}			
		};

		function to_print(){
			window.open("about:blank","master_product_print");
			document.master_product.target = "master_product_print";
			document.master_product.method="post";
			document.master_product.action = "master_product_print.cfm";
			document.master_product.submit();			
		}
		
		function to_import(){
			location.href="data_import.cfm?imp_flg=1";			
		}		
		function to_export(a){
			if(a == 'only_column_names'){

				location.href="master_product_export_action.cfm?only_column_names=1";
				// document.master_product.target = "_self"
				// document.master_product.method="post";
				// document.master_product.action = "master_product_export_action.cfm?only_column_names=1";
				// document.master_product.submit();				
			}else{
				document.master_product.target = "_self"
				document.master_product.method="post";
				document.master_product.action = "master_product_export_action.cfm";
				document.master_product.submit();				
			}
			
		}
		
		function to_selected_list(){
			var lct = $('#loop_count').val();
			document.master_product.target = "_self" 
			document.master_product.method="post";
			document.master_product.action = "master_product_selected_list.cfm?lct=" + lct;
			document.master_product.submit();			
			
		}
		
		function back_to_menu(){
			location.href="main.cfm";
		};
		function to_master(){
			location.href="master_product.cfm";
		}
		
		function toggleNosale(){
			$('.no_sale').toggle()
		}
		function printByBrowser(){
			window.print()
		}
		function changeSort(sort_flg){
			var eq_page = $("#eq_page").val();
			document.master_product.target = "_self";
			document.master_product.method="post";
			document.master_product.action = "master_product.cfm?sort_flg=" + sort_flg + "&eq_page=" + eq_page;
			document.master_product.submit();			
		}
		function changePage(eq_page){
			var sort_flg = $("#sort_flg").val();
			document.master_product.target = "_self";
			document.master_product.method="post";
			document.master_product.action = "master_product.cfm?sort_flg=" + sort_flg + "&eq_page=" + eq_page;
			document.master_product.submit();			
		}	
	</script>
	<script>

		function to_master2(){
			location.href="master_product.cfm?sch=1";
		}
		//画面サイズを取ってtopmenuクラスの幅を指定
		function getWindowSizeAndResize() {
			var sW,sH,s;
			sW = window.innerWidth;
			sH = window.innerHeight;
			$(".topmenu").attr("width",sW);
		}

		$(document).on("ready",function(){
			var osVer;
			osVer = "iPad";
			if (navigator.userAgent.indexOf(osVer)>0){
				$("body").css("width","980px")
			}			
			var timer = false;
			getWindowSizeAndResize()
			$(window).resize(function() {
			    if(timer){
			        clearTimeout(timer);
			    }
			    timer = setTimeout(function() {
			        getWindowSizeAndResize()
			   }, 200);
			});				
		});		
	</script>
	<!--- <script src="js/master_product.js?2"></script> --->
		
</div>
</div>
</body>
</html>