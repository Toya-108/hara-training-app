<cfinclude template = "init.cfm">
<!DOCTYPE html>
<head>
<!--- <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> --->
<meta name="viewport" content="width=1200">
<title><cfoutput>#lang_src.menu.slip_list#</cfoutput></title>
	<link href="images/favicon.ico" rel="shortcut icon">
	<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">
	<!--- <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css"> --->
	<link rel="stylesheet" href="css/base/jquery.ui.all.css" />
	<link rel="stylesheet" href="css/shopcenter.css?2016" />
	<!---<script type="text/javascript" charset="utf8" src="js/FixedHeader.js"></script>--->

	<style>

table {
  border-collapse: collapse;
  border-spacing: 0;
}
		td { 
			background-color: rgba(255,255,255,0.8);
			filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0,StartColorStr=#99ffffff,EndColorStr=#99ffffff);/*IE8以下用*/
		
		}

		th, td { white-space: nowrap;}
    	div.dataTables_wrapper {
        /*
width: 1200px;
*/
        margin: 0 auto;
    }
    td.selected_thing{
    	background-color:#E2FF89;
    	height:40px;
    }

/*
    input.search_btn{
    	background-image:url("images/ic_search_24px.svg");
    	 background-repeat:no-repeat;
    	 height: 30px;
    	 width:30px;
    	 background-color:white;
    	}
*/
/*
    input.input_btn{
    	background-image:url("images/ic_add_box_24px.svg");
    	 background-repeat:no-repeat;
    	 height: 30px;
    	 width:30px;
    	 background-color:white;
    	}
*/
	.jquery-ui-datepicker { z-index: 10000 !important; }
	
	.scrollHead{ float:left; }
	.scrollBody{ float:left; height:500px; overflow:auto; }
	.scrollFoot { clear:left;} 
	
	
	.tab{
		/*
overflow:hidden;
*/
		list-style-type: none;
		}
		li{list-style-type: none;}
	.tab li{background:#ccc; padding:5px 25px; float:left; margin-right:1px;}
	.tab li.select{background:rgba(62,141,116,0.8);
				   filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0,StartColorStr=#3e8d74,EndColorStr=#3e8d74);/*IE8以下用*/
				   border:1px solid;border-bottom:none;border-color:#dcdcdc
				   }
	/*
.content li{background:#eee; padding:20px;}
*/
	.hide {display:none;}	
	
	
	
	table.dataTable thead th {
	padding: 3px 10px;
	border: rgba(22,88,143,0.5) solid 1px;
	
}

table.dataTable tfoot th {
	padding: 3px 18px 3px 10px;
		
	
}

table.dataTable td {
	padding: 3px 10px;
}	
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
		.even {
			background-color: rgba(206,243,245,0.8);
		}

		.odd {
			background-color: white;
		}


/*	.slip_list tr:nth-child(even) td {
	    background-color: rgba(206,243,245,0.8);
	}
	.slip_list tr:nth-child(odd) td {
	    background-color: white;
	}*/


	.sort{
		cursor:pointer;
	}		
	</style>
	

</head>
<body>
<div class="sky">
<div class="cloud">
	
		<cfoutput>
		<cfif StructKeyExists(session,"member_id") eq false>
			<cflocation url="login.cfm">
		</cfif>
		
		<!--- 今日の日付() --->
		<!--- <cfset today = DateFormat(now(), "yyyy/mm/dd")> --->
		<!--- タイムゾーン対応 --->
		<cfset arr_offset = ListToArray(session.utc_offset,":")>
		<cfset h_offset = Int(arr_offset[1])/>
		<cfset m_offset = Int(arr_offset[2])/>
		<cfset now = DateAdd("n",m_offset,DateAdd("h",h_offset,DateConvert('local2Utc',now())))>

		<cfset today = LSDateFormat(now, lang_src.format.date_form_cf)>
		<cfset decimal_place = session.decimal_place>
		<cfif Isdefined("URL.sort_flg") is false>
			<cfset sort_flg = 2>
		<cfelse>
			<cfset sort_flg = URL.sort_flg>
		</cfif>
		<!--- 小数点対応	 --->
		<cfset decimal_place = session.decimal_place>
		<cfscript>
			d_format = "0";
			if(decimal_place >= 1){
				d_format = "0.";
				for(i = 0;i< decimal_place;i++){
					d_format &= "0";
				}
			}				
		</cfscript>		
		<div id="contentsArea;">
		 
			<!--- フォーム変数初期化 --->
	
			<cfscript>
				input_count = 0;
					
				if(StructKeyExists(form,"jan") eq false){
					form.jan = "";
						if(StructKeyExists(url,"j") eq false){
							url.j = form.jan;
						};
				}else{
					url.j = form.jan;
					input_count+=1;
				};
				
				if(StructKeyExists(form,"product_id") eq false){form.product_id = "";if(StructKeyExists(url,"pid") eq false){url.pid = form.product_id;};}else{url.pid = form.product_id;input_count+=1;};
				if(StructKeyExists(form,"product_name") eq false){form.product_name = "";if(StructKeyExists(url,"pnm") eq false){url.pnm = form.product_name;};}else{url.pnm = form.product_name;input_count+=1;};
				if(StructKeyExists(form,"sales_date_from") eq false){form.sales_date_from = "";if(StructKeyExists(url,"sd_f") eq false){url.sd_f = form.sales_date_from;};}else{url.sd_f = form.sales_date_from;input_count+=1;};
				
				
				if(StructKeyExists(form,"shop_id") eq false){form.shop_id = "";if(StructKeyExists(url,"sp_id") eq false){url.sp_id = form.shop_id;};}else{url.sp_id = form.shop_id;input_count+=1;};
				if(StructKeyExists(form,"sales_date_to") eq false){form.sales_date_to = "";if(StructKeyExists(url,"sd_t") eq false){url.sd_t = form.sales_date_to;};}else{url.sd_t = form.sales_date_to;input_count+=1;};
				if(StructKeyExists(form,"regi_id_from") eq false){form.regi_id_from = "";if(StructKeyExists(url,"rid_f") eq false){url.rid_f = form.regi_id_from;};}else{url.rid_f = form.regi_id_from;input_count+=1;};
				if(StructKeyExists(form,"regi_id_to") eq false){form.regi_id_to = "";if(StructKeyExists(url,"rid_t") eq false){url.rid_t = form.regi_id_to;};}else{url.rid_t = form.regi_id_to;input_count+=1;};
				if(StructKeyExists(form,"slip_num_from") eq false){form.slip_num_from = "";if(StructKeyExists(url,"snum_f") eq false){url.snum_f = form.slip_num_from;};}else{url.snum_f = form.slip_num_from;input_count+=1;};
				if(StructKeyExists(form,"slip_num_to") eq false){form.slip_num_to = "";if(StructKeyExists(url,"snum_t") eq false){url.snum_t = form.slip_num_to;};}else{url.snum_t = form.slip_num_to;input_count+=1;};
				if(StructKeyExists(form,"slip_division") eq false){form.slip_division = "";if(StructKeyExists(url,"slpdiv") eq false){url.slpdiv = form.slip_division;};}else{url.slpdiv = form.slip_division;};
				if(StructKeyExists(form,"sales_division") eq false){form.sales_division = "";if(StructKeyExists(url,"slsdiv") eq false){url.slsdiv = form.sales_division;};}else{url.slsdiv = form.sales_division;};
				if(StructKeyExists(form,"create_date_from") eq false){form.create_date_from = "";if(StructKeyExists(url,"cd_f") eq false){url.cd_f = form.create_date_from;};}else{url.cd_f = form.create_date_from;input_count+=1;};
				if(StructKeyExists(form,"create_date_to") eq false){form.create_date_to = "";if(StructKeyExists(url,"cd_t") eq false){url.cd_t = form.create_date_to;};}else{url.cd_t = form.create_date_to;input_count+=1;};
				if(StructKeyExists(form,"create_account") eq false){form.create_account = "";if(StructKeyExists(url,"ca") eq false){url.ca = form.create_account;};}else{url.ca = form.create_account;input_count+=1;};
				if(StructKeyExists(form,"create_person") eq false){form.create_person = "";if(StructKeyExists(url,"cp") eq false){url.cp = form.create_person;};}else{url.cp = form.create_person;input_count+=1;};
				if(StructKeyExists(form,"torihiki_datetime_from") eq false){form.torihiki_datetime_from = "";if(StructKeyExists(url,"td_f") eq false){url.td_f = form.torihiki_datetime_from;};}else{url.td_f = form.torihiki_datetime_from;input_count+=1;};
				if(StructKeyExists(form,"torihiki_datetime_to") eq false){form.torihiki_datetime_to = "";if(StructKeyExists(url,"td_t") eq false){url.td_t = form.torihiki_datetime_to;};}else{url.td_t = form.torihiki_datetime_to;input_count+=1;};
				if(StructKeyExists(form,"uniform_invoice") eq false){form.uniform_invoice = "";if(StructKeyExists(url,"ui") eq false){url.ui = form.uniform_invoice;};}else{url.ui = form.uniform_invoice;input_count+=1;};
				
				
				/*
				
				if(isDefined("url.j") and url.j neq "" and isDefined("form.j") eq false)
					{
						form.jan = url.j;
					}
					else{
						if(isDefined("form.jan") eq false)
						{
							form.jan = "";
						}else{
							input_count+=1;
						};
					};*/
					
					
	/*				
				//以下は、↑と同じ構文。
				if(isDefined("url.pid") and url.pid neq "" and isDefined("form.product_id") eq false){form.product_id = url.pid;}else{if(isDefined("form.product_id") eq false){form.product_id = "";}else{input_count+=1;};};
				if(isDefined("url.pnm") and url.pnm neq "" and isDefined("form.product_name") eq false){form.product_name = url.pnm;}else{if(isDefined("form.product_name") eq false){form.product_name = "";}else{input_count+=1;};};
				if(isDefined("url.sd_f") and url.sd_f neq "" and isDefined("form.sales_date_from") eq false){form.sales_date_from = "url.sd_f";}else{if(isDefined("form.sales_date_from") eq false){form.sales_date_from = "";}else{input_count+=1;};};
				if(isDefined("url.sd_t") and url.sd_t neq "" and isDefined("form.sales_date_to") eq false){form.sales_date_to = url.sd_t;}else{if(isDefined("form.sales_date_to") eq false){form.sales_date_to = "";}else{input_count+=1;};};
				if(isDefined("url.rid_f") and url.rid_f neq "" and isDefined("form.regi_id_from") eq false){form.regi_id_from = url.rid_f;}else{if(isDefined("form.regi_id_from") eq false){form.regi_id_from = "";}else{input_count+=1;};};
				if(isDefined("url.rid_t") and url.rid_t neq "" and isDefined("form.regi_id_to") eq false){form.regi_id_to = url.rid_t;}else{if(isDefined("form.regi_id_to") eq false){form.regi_id_to = "";}else{input_count+=1;};};
				if(isDefined("url.snum_f") and url.snum_f neq "" and isDefined("form.slip_num_from") eq false){form.slip_num_from = url.snum_f;}else{if(isDefined("form.slip_num_from") eq false){form.slip_num_from = "";}else{input_count+=1;};};
				if(isDefined("url.snum_t") and url.snum_t neq "" and isDefined("form.slip_num_to") eq false){form.slip_num_to = url.snum_t;}else{if(isDefined("form.slip_num_to") eq false){form.slip_num_to = "";}else{input_count+=1;};};
				if(isDefined("url.slpdiv") and url.slpdiv neq "" and isDefined("form.slip_division") eq false){form.slip_division = url.slpdiv;}else{if(isDefined("form.slip_division") eq false){form.slip_division = "";}else{input_count+=1;};};
				if(isDefined("url.slsdiv") and url.slsdiv neq "" and isDefined("form.sales_division") eq false){form.sales_division = url.slsdiv;}else{if(isDefined("form.sales_division") eq false){form.sales_division = "";}else{input_count+=1;};};
				if(isDefined("url.cd_f") and url.cd_f neq "" and isDefined("form.create_date_from") eq false){form.create_date_from = url.cd_f;}else{if(isDefined("form.create_date_from") eq false){form.create_date_from = "";}else{input_count+=1;};};
				if(isDefined("url.cd_t") and url.cd_t neq "" and isDefined("form.create_date_to") eq false){form.create_date_to = url.cd_t;}else{if(isDefined("form.create_date_to") eq false){form.create_date_to = "";}else{input_count+=1;};};
				if(isDefined("url.ca") and url.ca neq "" and isDefined("form.create_account") eq false){form.create_account = url.ca;}else{if(isDefined("form.create_account") eq false){form.create_account = "";}else{input_count+=1;};};
				if(isDefined("url.cp") and url.cp neq "" and isDefined("form.create_person") eq false){form.create_person = url.cp;}else{if(isDefined("form.create_person") eq false){form.create_person = "";}else{input_count+=1;};};
				if(isDefined("url.td_f") and url.td_f neq "" and isDefined("form.torihiki_datetime_from") eq false){form.torihiki_datetime_from = url.td_f;}else{if(isDefined("form.torihiki_datetime_from") eq false){form.torihiki_datetime_from = "";}else{input_count+=1;};};
				if(isDefined("url.td_t") and url.td_t neq "" and isDefined("form.torihiki_datetime_to") eq false){form.torihiki_datetime_to = url.td_t;}else{if(isDefined("form.torihiki_datetime_to") eq false){form.torihiki_datetime_to = "";}else{input_count+=1;};};		
	*/	
		
				//検索欄に入力した項目がなければ今日の日付をセット
				if(input_count eq 0 and (StructKeyExists(session,"slip_id_list") eq false or session.slip_id_list eq "") and form.sales_date_from eq ""){
					url.sd_f = "#today#";
				};
				
			</cfscript>

			<cfquery datasource="#application.dsn#" name="qGetAdmin">
				SELECT receipt_layout_type,country_id,cash_rounding_flag
				  FROM m_admin
				 WHERE member_id = '#session.member_id#'
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qGetEmployee">
				SELECT employee_id,
					   <cfif lang_src.format.isFamilyNameFirst>
					   	concat(ifnull(employee_last_name,' '),ifnull(employee_first_name,' ')) as emp_name
					   <cfelse>
					    concat(ifnull(employee_first_name,' '),ifnull(employee_last_name,' ')) as emp_name
					   </cfif>
				 FROM  m_employee
				 WHERE member_id = '#session.member_id#'
				   AND del_flag = 0
				   AND emp_type = 1 
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qGetShopForSelect" >
				SELECT m_shop.shop_id,
					   m_shop.shop_name_ryaku shop_name 
			      FROM m_shop
			      WHERE m_shop.member_id = '#session.member_id#'
					AND m_shop.shop_type = 2
					AND m_shop.active_flag = 1			      			 				
			</cfquery>


			<cfquery datasource="#application.dsn#" name="qGetRegiForSelect" >
				SELECT m_regi.shop_id,
					   m_regi.regi_id,
					   m_regi.regi_name 
			      FROM m_regi
			     WHERE m_regi.member_id = '#session.member_id#'
			</cfquery>

			<cfquery datasource="#application.dsn#" name="qGetRegi" >
				SELECT m_regi.shop_id,
					   m_regi.regi_id,
					   m_regi.regi_name 
			      FROM m_regi
			     WHERE m_regi.member_id = '#session.member_id#'
					   <cfif StructKeyExists(form,"shop_id") and form.shop_id neq "">
					   	AND m_regi.shop_id = '#form.shop_id#'
					   </cfif>			     
			</cfquery>	
			<cfquery datasource="#application.dsn#" name="qGetReceiptMethod" >
				SELECT receipt_method_name#session.language# receipt_method_name 
			      FROM m_receipt_method_sales
			     WHERE member_id = '#session.member_id#'
			  ORDER BY LPAD(receipt_method_id, 10, '0')
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qGetSlip">
				  SELECT t_slip.sales_date,
				  		 t_slip.shop_id,   
				         DATE_FORMAT(t_slip.sales_date,'#lang_src.format.date_form_sql#') as char_sales_date,   
				         t_slip.regi_id,   
				         t_slip.slip_division,
				         CASE t_slip.slip_division WHEN 1 THEN '#lang_src.term.sales_slip#' WHEN 2 THEN '#lang_src.term.offset_slip#' WHEN 3 THEN '#lang_src.term.delete_slip#' WHEN 4 THEN '#lang_src.term.return_slip#' END as char_slip_division,
				         t_slip.sales_division,   
				         CASE t_slip.sales_division WHEN 1 THEN 'POS' WHEN 2 THEN 'Mail order' WHEN 3 THEN 'TEL' WHEN 4 THEN 'Facilities use ticket' WHEN 5 THEN 'Bridal' END as char_sales_division,
				         t_slip.customer_id,
				         <cfif lang_src.format.isFamilyNameFirst>
					        RTRIM(LTRIM(CONCAT(IFNULL(t_slip.customer_last_name, ''),' ',IFNULL(t_slip.customer_first_name, '')))) as customer_name, 
					     <cfelse>
					        RTRIM(LTRIM(CONCAT(IFNULL(t_slip.customer_first_name, ''),' ',IFNULL(t_slip.customer_last_name, '')))) as customer_name, 
				         </cfif>   
				          
				         t_slip.daily_list_date,   
				         DATE_FORMAT(t_slip.daily_list_date,'#lang_src.format.date_form_sql# %H:%i:%s') as char_daily_list_date,   
				         t_slip.slip_num,
				         t_slip.uniform_invoice_seq_num,   
				         t_slip.tax_rate,   
				         DATE_FORMAT(t_slip.torihiki_datetime,'#lang_src.format.date_form_sql# %H:%i') as char_torihiki_datetime,
				         t_slip.torihiki_datetime torihiki_datetime,   
				         COUNT(DISTINCT t_slip_detail.jan) as jan_count,
				         t_slip.subtotal_qty,   
				         SUM(t_slip_detail.price_discount_amount) as price_discount_amount,   
				         SUM(t_slip_detail.percent_discount_amount) as percent_discount_amount,   
				         SUM(t_slip_detail.mm_discount_price) as mm_discount_price,   
				         SUM(t_slip_detail.cost) as cost,   
				
	<!---			         t_slip.subtotal_amount_without_tax,   
				         t_slip.subtotal_amount_include_tax,   
				         t_slip.subtotal_amount_tax,   
				         t_slip.subtotal_price_discount_amount,   
				         t_slip.subtotal_discount_rate,   
				         t_slip.subtotal_percent_discount_amount, --->  
				         FORMAT(t_slip.total_amount_without_tax,#decimal_place#) total_amount_without_tax,   
				         FORMAT(t_slip.total_amount_include_tax,#decimal_place#) total_amount_include_tax,
				         <!--- t_slip.total_amount_include_tax raw_total_amount_include_tax, --->
				         REPLACE(FORMAT(t_slip.total_amount_include_tax,#decimal_place#),',','') raw_total_amount_include_tax,

				         FORMAT((IFNULL(t_slip.service_charge,0) + t_slip.total_amount_include_tax),#decimal_place#) char_total_amount_include_tax,   
				         FORMAT(t_slip.total_amount_tax,#decimal_place#) total_amount_tax,   
				         REPLACE(FORMAT(t_slip.receipt_amount0,#decimal_place#),',','') receipt_amount0,   
				         REPLACE(FORMAT(t_slip.receipt_amount1,#decimal_place#),',','') receipt_amount1,   
				         REPLACE(FORMAT(t_slip.receipt_amount2,#decimal_place#),',','') receipt_amount2,   
				         REPLACE(FORMAT(t_slip.receipt_amount3,#decimal_place#),',','') receipt_amount3,   
				         REPLACE(FORMAT(t_slip.receipt_amount4,#decimal_place#),',','') receipt_amount4,   
				         REPLACE(FORMAT(t_slip.receipt_amount5,#decimal_place#),',','') receipt_amount5,   
				         REPLACE(FORMAT(t_slip.receipt_amount6,#decimal_place#),',','') receipt_amount6,   
				         REPLACE(FORMAT(t_slip.receipt_amount7,#decimal_place#),',','') receipt_amount7,   
				         REPLACE(FORMAT(t_slip.receipt_amount8,#decimal_place#),',','') receipt_amount8,
				         REPLACE(FORMAT(t_slip.receipt_amount9,#decimal_place#),',','') receipt_amount9,
				         REPLACE(FORMAT(t_slip.receipt_amount10,#decimal_place#),',','') receipt_amount10,
				         REPLACE(FORMAT(t_slip.receipt_amount11,#decimal_place#),',','') receipt_amount11,
				         REPLACE(FORMAT(t_slip.receipt_amount12,#decimal_place#),',','') receipt_amount12,   
		<!---		         t_slip.receipt_amount9,   
				         t_slip.receipt_amount10,   
				         t_slip.receipt_amount11,   
				         t_slip.receipt_amount12,   
				         t_slip.receipt_amount13,   
				         t_slip.before_shopping_point,   
				         t_slip.add_shopping_point,   
				         t_slip.use_shopping_point,   
				         t_slip.shopping_point,   
				         t_slip.memo,   --->
				         FORMAT(t_slip.cash_rounding_amount,#decimal_place#) cash_rounding_amount,
				         t_slip.create_date,   
				         DATE_FORMAT(t_slip.create_date,'#lang_src.format.date_form_sql# %H:%i:%s') as char_create_date,   
				         t_slip.create_account,   
				         t_slip.create_person 
				         <!---  
				         t_slip.modify_date,   
				         DATE_FORMAT(t_slip.modify_date,'%Y/%m/%d %H:%i:%s') as char_modify_date,   
				         t_slip.modify_account,   
				         t_slip.modify_person,            
				         CAST(t_slip.regi_id        AS SIGNED) as num_regi_id,
				         CAST(t_slip.customer_id    AS SIGNED) as num_customer_id,
				         CAST(t_slip.create_account AS SIGNED) as num_create_account,
				         CAST(t_slip.modify_account AS SIGNED) as num_modify_account--->			
				    FROM t_slip			         
				         <cfscript>
							if(StructKeyExists(url,"j") and url.j neq "" or (StructKeyExists(url,"pid") and url.pid neq "") or (StructKeyExists(url,"pnm") and url.pnm neq "")){
								
								 condition = "";
								
						   		if(StructKeyExists(url,"j") and url.j neq ""){				   			
						   			condition = condition & "AND TPSD.jan = '#url.j#'";				   			
						   			};
						   			
						   		if(StructKeyExists(url,"pid") and url.pid neq ""){
						   			condition = condition & "AND LPAD(TPSD.product_id, 20, '0') = LPAD('#url.pid#', 20, '0')";				   			
						   			};
						   		if(StructKeyExists(url,"pnm") and url.pnm neq ""){
						   			condition = condition & "AND (TPSD.product_name LIKE '%#trim(url.pnm)#%' OR TPSD.product_name_kana LIKE '%#trim(url.pnm)#%')";				   			
						   			};
						   			
						   			WriteOutput(" INNER JOIN (SELECT DISTINCT slip_num,member_id,shop_id FROM t_slip_detail TPSD WHERE TPSD.member_id = '#session.member_id#' #preserveSingleQuotes(condition)#) TPSD2 ON t_slip.member_id = TPSD2.member_id AND t_slip.shop_id = TPSD2.shop_id AND t_slip.slip_num = TPSD2.slip_num" );				   			
					   			}					 	 
						 </cfscript>
						 ,
						 t_slip_detail
				           
				   WHERE t_slip.member_id = '#session.member_id#' 
				     AND t_slip.member_id = t_slip_detail.member_id
				     AND t_slip.shop_id = t_slip_detail.shop_id 
				     AND t_slip.slip_num = t_slip_detail.slip_num
	
				   	<cfscript>
				   		if(StructKeyExists(url,"sd_f") and url.sd_f neq ""){
				   			WriteOutput(" AND t_slip.sales_date >= STR_TO_DATE('#url.sd_f#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"sd_t") and url.sd_t neq ""){
				   			WriteOutput(" AND t_slip.sales_date <= STR_TO_DATE('#url.sd_t#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"sp_id") and url.sp_id neq ""){
				   			WriteOutput(" AND LPAD(t_slip.shop_id, 10, '0') = LPAD('#url.sp_id#', 10, '0')");
				   			};	
				   		if(StructKeyExists(url,"rid_f") and url.rid_f neq ""){
				   			WriteOutput(" AND LPAD(t_slip.regi_id, 10, '0') >= LPAD(#url.rid_f#, 10, '0')");
				   			};
				   		if(StructKeyExists(url,"rid_t") and url.rid_t neq ""){
				   			WriteOutput(" AND LPAD(t_slip.regi_id, 10, '0') <= LPAD(#url.rid_t#, 10, '0')");
				   			};
	
				   		if(StructKeyExists(url,"snum_f") and url.snum_f neq ""){
				   			WriteOutput(" AND CAST(t_slip.slip_num AS SIGNED) >= '#url.snum_f#'");
				   			};
				   		if(StructKeyExists(url,"snum_t") and url.snum_t neq ""){
				   			WriteOutput(" AND CAST(t_slip.slip_num AS SIGNED) <= '#url.snum_t#'");
				   			};
				   			
				   		if(StructKeyExists(url,"slpdiv") and url.slpdiv neq ""){
				   			WriteOutput(" AND t_slip.slip_division in (#url.slpdiv#)");
				   			};
				   		if(StructKeyExists(url,"slsdiv") and url.slsdiv neq ""){
				   			WriteOutput(" AND t_slip.sales_division in (#url.slsdiv#)");
				   			};
				   			
				   		if(StructKeyExists(url,"cd_f") and url.cd_f neq ""){
				   			WriteOutput(" AND t_slip.create_date >= '#url.cd_f#'");
				   			};
				   		if(StructKeyExists(url,"cd_t") and url.cd_t neq ""){
				   			WriteOutput(" AND t_slip.create_date <= '#url.cd_t#'");
				   			};			   						   						   			
				   						   			
				   		if(StructKeyExists(url,"ca") and url.ca neq ""){
				   			WriteOutput(" AND t_slip.create_account = '#url.ca#'");
				   			};
				   		if(StructKeyExists(url,"cp") and url.cp neq ""){
				   			WriteOutput(" AND t_slip.create_person LIKE '%#trim(url.cp)#%'");
				   			};
				   			
				   		if(StructKeyExists(url,"td_f") and url.td_f neq ""){
				   			WriteOutput(" AND CAST(t_slip.torihiki_datetime AS DATE) >= STR_TO_DATE('#url.td_f#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"td_t") and url.td_t neq ""){
				   			WriteOutput(" AND CAST(t_slip.torihiki_datetime AS DATE) <= STR_TO_DATE('#url.td_t#','#lang_src.format.date_form_sql#')");
				   			};			   			
				   		if(StructKeyExists(url,"ui") and url.ui neq ""){
				   			WriteOutput(" AND t_slip.uniform_invoice_seq_num LIKE '%#trim(url.ui)#%'");
				   			};				   			
				   			
	/*			   		if(isDefined("url.modify_date_from") and url.modify_date_from neq ""){
				   			WriteOutput(" AND t_slip.modify_date >= '#url.modify_date_from#'");
				   			};
				   		if(isDefined("url.modify_date_to") and url.modify_date_to neq ""){
				   			WriteOutput(" AND t_slip.modify_date <= '#url.modify_date_to#'");
				   			};			   						   						   			
				   						   			
				   		if(isDefined("url.modify_account") and url.modify_account neq ""){
				   			WriteOutput(" AND t_slip.modify_account = '#url.modify_account#'");
				   			};
				   		if(isDefined("url.modify_person") and url.modify_person neq ""){
				   			WriteOutput(" AND t_slip.modify_person LIKE '%#trim(url.modify_person)#%'");
				   			};
	*/	
			   			
	/*					
						if(isDefined("url.jan") and url.jan neq "" or (isDefined("url.product_id") and url.product_id neq "") or (isDefined("url.product_name") and url.product_name neq "")){
							
							 condition = "";
							
					   		if(isDefined("url.jan") and url.jan neq ""){				   			
					   			condition = condition & "AND TPSD.jan = '#url.jan#'";				   			
					   			};
					   			
					   		if(isDefined("url.product_id") and url.product_id neq ""){
					   			condition = condition & "AND LPAD(TPSD.product_id, 20, '0') = LPAD('#url.product_id#', 20, '0')";				   			
					   			};
					   		if(isDefined("url.product_name") and url.product_name neq ""){
					   			condition = condition & "AND (TPSD.product_name LIKE '%#trim(url.product_name)#%' OR TPSD.product_name_kana LIKE '%#trim(url.product_name)#%')";				   			
					   			};
					   			
					   			WriteOutput(" AND EXISTS (SELECT * FROM t_slip_detail TPSD WHERE t_slip_detail.member_id = '#session.member_id#' #preserveSingleQuotes(condition)#)" );				   			
				   			}
				   			*/			   						   			
				   	</cfscript>
	
			   <!---詳細画面から戻った場合、伝票番号のリストから一覧を表示 --->
			   
				   <cfif StructKeyExists(session,"slip_id_list") and #session.slip_id_list# neq "" and StructKeyExists(url,"frm_detail")>
				   		AND t_slip.slip_num IN(#session.slip_id_list#)
				   </cfif>
	
			   
				GROUP BY
				         t_slip.sales_date, 
				         t_slip.shop_id,   
				         t_slip.regi_id,   
				         t_slip.slip_division,
				         t_slip.sales_division,   
				         t_slip.customer_id,   
				         <cfif lang_src.format.isFamilyNameFirst>
					        RTRIM(LTRIM(CONCAT(IFNULL(t_slip.customer_last_name, ''),' ',IFNULL(t_slip.customer_first_name, '')))), 
					     <cfelse>
					        RTRIM(LTRIM(CONCAT(IFNULL(t_slip.customer_first_name, ''),' ',IFNULL(t_slip.customer_last_name, '')))), 
				         </cfif>  
				         t_slip.slip_num,
				         t_slip.uniform_invoice_seq_num,   
				         t_slip.tax_rate,   
				         t_slip.torihiki_datetime,   
				         t_slip.subtotal_qty,
				         <!---   
				         t_slip.subtotal_amount_without_tax,   
				         t_slip.subtotal_amount_include_tax,   
				         t_slip.subtotal_amount_tax,   
				         t_slip.subtotal_price_discount_amount,   
				         t_slip.subtotal_discount_rate,   
				         t_slip.subtotal_percent_discount_amount,
				         --->   
				         t_slip.total_amount_without_tax,   
				         t_slip.total_amount_include_tax,
				         FORMAT((IFNULL(t_slip.service_charge,0) + t_slip.total_amount_include_tax),#decimal_place#),   
				         t_slip.total_amount_tax,
				            
				         t_slip.receipt_amount0,   
				         t_slip.receipt_amount1,   
				         t_slip.receipt_amount2,   
				         t_slip.receipt_amount3,   
				         t_slip.receipt_amount4,   
				         t_slip.receipt_amount5,   
				         t_slip.receipt_amount6,   
				         t_slip.receipt_amount7,   
				         t_slip.receipt_amount8,   
				    <!---     t_slip.receipt_amount9,   
				         t_slip.receipt_amount10,   
				         t_slip.receipt_amount11,   
				         t_slip.receipt_amount12,   
				         t_slip.receipt_amount13, 
				          
				         t_slip.before_shopping_point,   
				         t_slip.add_shopping_point,   
				         t_slip.use_shopping_point,   
				         t_slip.shopping_point,   
				         t_slip.memo, 
				         --->
				         t_slip.cash_rounding_amount,   
				         t_slip.create_date,   
				         t_slip.create_account,   
				         t_slip.create_person,   
				         t_slip.modify_date,   
				         t_slip.modify_account,   
				         t_slip.modify_person
				<cfscript>
						switch(sort_flg){
							case "1":
								WriteOutput("ORDER BY t_slip.torihiki_datetime,LPAD(t_slip.slip_num, 20, '0')");
								break;
							case "2":
								WriteOutput("ORDER BY t_slip.torihiki_datetime DESC,LPAD(t_slip.slip_num, 20, '0')");
								break;
							case "3":
								WriteOutput("ORDER BY t_slip.sales_date DESC");
								break;
							case "4":
								WriteOutput("ORDER BY t_slip.sales_date");
								break;
							case "5":
								WriteOutput("ORDER BY LPAD(t_slip.shop_id, 10, '0')");
								break;
							case "6":
								WriteOutput("ORDER BY LPAD(t_slip.shop_id, 10, '0') DESC");
								break;

							case "7":
								WriteOutput("ORDER BY LPAD(t_slip.regi_id, 10, '0')");
								break;
							case "8":
								WriteOutput("ORDER BY LPAD(t_slip.regi_id, 10, '0') DESC");
								break;
							case "9":
								WriteOutput("ORDER BY LPAD(t_slip.slip_num, 20, '0')");
								break;
							case "10":
								WriteOutput("ORDER BY LPAD(t_slip.slip_num, 20, '0') DESC");
								break;
							case "11":
								WriteOutput("ORDER BY t_slip.slip_division");
								break;
							case "12":
								WriteOutput("ORDER BY t_slip.slip_division DESC");
								break;

							case "13":
								WriteOutput("ORDER BY COUNT(DISTINCT t_slip_detail.jan) ");
								break;
							case "14":
								WriteOutput("ORDER BY COUNT(DISTINCT t_slip_detail.jan) DESC");
								break;
							case "15":
								WriteOutput("ORDER BY t_slip.subtotal_qty");
								break;
							case "16":
								WriteOutput("ORDER BY t_slip.subtotal_qty DESC");
								break;
							case "17":
								WriteOutput("ORDER BY t_slip.total_amount_include_tax");
								break;
							case "18":
								WriteOutput("ORDER BY t_slip.total_amount_include_tax DESC");
								break;
							case "19":
								WriteOutput("ORDER BY LPAD(t_slip.create_account, 10, '0')");
								break;
							case "20":
								WriteOutput("ORDER BY LPAD(t_slip.create_account, 10, '0') DESC");
								break;
							case "21":
								WriteOutput("ORDER BY LPAD(t_slip.uniform_invoice_seq_num, 10, '0')");
								break;
							case "22":
								WriteOutput("ORDER BY LPAD(t_slip.uniform_invoice_seq_num, 10, '0') DESC");
								break;
						}


				</cfscript>			         		   
			</cfquery>

<!---
■■■■■■■■■■■■■■■■■■
チムニー提出用の途中
■■■■■■■■■■■■■■■■■■

SELECT CASE WHEN option_flag = 0 
            THEN product_name 
            else property_name 
            END AS product_namt 
  FROM t_slip,t_slip_detail
				   WHERE t_slip.member_id = '73007300' 
				     AND t_slip.member_id = t_slip_detail.member_id
				     AND t_slip.shop_id = t_slip_detail.shop_id 
				     AND t_slip.slip_num = t_slip_detail.slip_num
				     AND t_slip_detail.fix_sales_amount_include_tax <> 0
--->

		<cfif IsDefined("url.exp_flg") and url.exp_flg eq 2>
	
			<cfquery datasource="#application.dsn#" name="qGetSlipDetail">
				SELECT 
				     t_slip.sales_date,   
				     DATE_FORMAT(t_slip.sales_date,'#getLang("format","date_form_sql")#') as char_sales_date,   
				     t_slip.shop_id, 
				     t_slip.regi_id,   
				     t_slip.slip_division,
				     CASE t_slip.slip_division WHEN 1 THEN '#lang_src.term.sales_slip#' WHEN 2 THEN '#lang_src.term.offset_slip#' WHEN 3 THEN '#lang_src.term.delete_slip#' WHEN 4 THEN '#lang_src.term.return_slip#' END as char_slip_division,
				     t_slip.sales_division,   
				     t_slip.daily_list_date,   
				     DATE_FORMAT(t_slip.daily_list_date,'#getLang("format","date_form_sql")# %H:%i:%s') as char_daily_list_date,   
				     t_slip.slip_num,   
				     t_slip_detail.tax_rate,   
				     DATE_FORMAT(t_slip.torihiki_datetime,'#getLang("format","date_form_sql")# %H:%i') as char_torihiki_datetime, 
				     t_slip.torihiki_datetime,  
				     t_slip.subtotal_qty,   
				     t_slip.subtotal_amount_without_tax,   
				     t_slip.subtotal_amount_include_tax,   
				     t_slip.subtotal_amount_tax,   
				     t_slip.subtotal_price_discount_amount,   
				     t_slip.subtotal_discount_rate,   
				     t_slip.subtotal_percent_discount_amount,   
				     t_slip.total_amount_without_tax,   
				     t_slip.total_amount_include_tax,   
				     t_slip.total_amount_tax,   

				     t_slip.memo,   
				     t_slip.create_date,   
				     DATE_FORMAT(t_slip.create_date,'#getLang("format","date_form_sql")# %H:%i') as char_create_date,   
				     t_slip.create_account,   
				     t_slip.create_person,   
				     t_slip.modify_date,   
				     DATE_FORMAT(t_slip.modify_date,'#getLang("format","date_form_sql")# %H:%i:%s') as char_modify_date,   
				     t_slip.modify_account,   
				     t_slip.modify_person,   
				
				     t_slip_detail.seq_num,   
				     t_slip_detail.line_num,   
				     t_slip_detail.line_division,   
				     t_slip_detail.division_id,   
				     t_slip_detail.division_name,   
	<!---
				     t_slip_detail.depart_id,   
				     t_slip_detail.depart_name,   
				     t_slip_detail.line_id,   
				     t_slip_detail.line_name,   
				     t_slip_detail.class_id,   
				     t_slip_detail.class_name,   
	--->			     t_slip_detail.product_id,   
				     t_slip_detail.jan,   
				     t_slip_detail.maker_name,   
				     t_slip_detail.product_name,   
				     t_slip_detail.receipt_name,   
				     t_slip_detail.standard_name,   
				     t_slip_detail.tax_class,   
	<!---			     t_slip_detail.mm_num,   
				     t_slip_detail.mm_set_qty,   
				     t_slip_detail.mm_set_discount_price,   
				     t_slip_detail.mm_show_count,   
				     t_slip_detail.mm_discount_price,--->   
				     t_slip_detail.qty_per_carton,   
				     t_slip_detail.qty,   
				     t_slip_detail.unit,   
				     t_slip_detail.cost,   
				     REPLACE(FORMAT(t_slip_detail.unit_cost,#decimal_place#),',','') unit_cost,
				     REPLACE(FORMAT(t_slip_detail.original_unit_price_include_tax,#decimal_place#),',','') original_unit_price_include_tax,
				     REPLACE(FORMAT(t_slip_detail.original_unit_price_without_tax,#decimal_place#),',','') original_unit_price_without_tax,
				     REPLACE(FORMAT(t_slip_detail.price_discount_amount,#decimal_place#),',','') price_discount_amount,
				     t_slip_detail.discount_rate,   
				     REPLACE(FORMAT(t_slip_detail.percent_discount_amount,#decimal_place#),',','') percent_discount_amount,
				     REPLACE(FORMAT(t_slip_detail.unit_price_without_tax,#decimal_place#),',','') unit_price_without_tax,
				     REPLACE(FORMAT(t_slip_detail.unit_price_include_tax,#decimal_place#),',','') unit_price_include_tax,

				     REPLACE(FORMAT(t_slip_detail.fix_sales_amount_include_tax,#decimal_place#),',','') fix_sales_amount_include_tax,
				     REPLACE(FORMAT(t_slip_detail.fix_sales_amount_without_tax,#decimal_place#),',','') fix_sales_amount_without_tax,
				     REPLACE(FORMAT(t_slip_detail.fix_sales_amount_tax,#decimal_place#),',','') fix_sales_amount_tax
				
				    FROM t_slip			         
				         <cfscript>
							if(isDefined("url.j") and url.j neq "" or (isDefined("url.pid") and url.pid neq "") or (isDefined("url.pnm") and url.pnm neq "")){
								
								 condition = "";
								
						   		if(isDefined("url.j") and url.j neq ""){				   			
						   			condition = condition & "AND TPSD.jan = '#url.j#'";				   			
						   			};
						   			
						   		if(isDefined("url.pid") and url.pid neq ""){
						   			condition = condition & "AND LPAD(TPSD.product_id, 20, '0') = LPAD('#url.pid#', 20, '0')";				   			
						   			};
						   		if(isDefined("url.pnm") and url.pnm neq ""){
						   			condition = condition & "AND (TPSD.product_name LIKE '%#trim(url.pnm)#%' OR TPSD.product_name_kana LIKE '%#trim(url.pnm)#%')";				   			
						   			};
						   			
						   			WriteOutput(" INNER JOIN (SELECT DISTINCT slip_num,member_id FROM t_slip_detail TPSD WHERE TPSD.member_id = '#session.member_id#' #preserveSingleQuotes(condition)#) TPSD2 ON t_slip.member_id = TPSD2.member_id AND t_slip.slip_num = TPSD2.slip_num" );				   			
					   			}					 	 
						 </cfscript>
						 ,
						 t_slip_detail
				           
				   WHERE t_slip.member_id = '#session.member_id#' 
				     AND t_slip.slip_num = t_slip_detail.slip_num 

				   	<cfscript>
				   		if(StructKeyExists(url,"sd_f") and url.sd_f neq ""){
				   			WriteOutput(" AND t_slip.sales_date >= STR_TO_DATE('#url.sd_f#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"sd_t") and url.sd_t neq ""){
				   			WriteOutput(" AND t_slip.sales_date <= STR_TO_DATE('#url.sd_t#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"sp_id") and url.sp_id neq ""){
				   			WriteOutput(" AND LPAD(t_slip.shop_id, 10, '0') = LPAD('#url.sp_id#', 10, '0')");
				   			};	
				   		if(StructKeyExists(url,"rid_f") and url.rid_f neq ""){
				   			WriteOutput(" AND LPAD(t_slip.regi_id, 10, '0') >= LPAD(#url.rid_f#, 10, '0')");
				   			};
				   		if(StructKeyExists(url,"rid_t") and url.rid_t neq ""){
				   			WriteOutput(" AND LPAD(t_slip.regi_id, 10, '0') <= LPAD(#url.rid_t#, 10, '0')");
				   			};

				   		if(StructKeyExists(url,"snum_f") and url.snum_f neq ""){
				   			WriteOutput(" AND CAST(t_slip.slip_num AS SIGNED) >= '#url.snum_f#'");
				   			};
				   		if(StructKeyExists(url,"snum_t") and url.snum_t neq ""){
				   			WriteOutput(" AND CAST(t_slip.slip_num AS SIGNED) <= '#url.snum_t#'");
				   			};
				   			
				   		if(StructKeyExists(url,"slpdiv") and url.slpdiv neq ""){
				   			WriteOutput(" AND t_slip.slip_division in (#url.slpdiv#)");
				   			};
				   		if(StructKeyExists(url,"slsdiv") and url.slsdiv neq ""){
				   			WriteOutput(" AND t_slip.sales_division in (#url.slsdiv#)");
				   			};
				   			
				   		if(StructKeyExists(url,"cd_f") and url.cd_f neq ""){
				   			WriteOutput(" AND t_slip.create_date >= '#url.cd_f#'");
				   			};
				   		if(StructKeyExists(url,"cd_t") and url.cd_t neq ""){
				   			WriteOutput(" AND t_slip.create_date <= '#url.cd_t#'");
				   			};			   						   						   			
				   						   			
				   		if(StructKeyExists(url,"ca") and url.ca neq ""){
				   			WriteOutput(" AND t_slip.create_account = '#url.ca#'");
				   			};
				   		if(StructKeyExists(url,"cp") and url.cp neq ""){
				   			WriteOutput(" AND t_slip.create_person LIKE '%#trim(url.cp)#%'");
				   			};
				   			
				   		if(StructKeyExists(url,"td_f") and url.td_f neq ""){
				   			WriteOutput(" AND CAST(t_slip.torihiki_datetime AS DATE) >= STR_TO_DATE('#url.td_f#','#lang_src.format.date_form_sql#')");
				   			};
				   		if(StructKeyExists(url,"td_t") and url.td_t neq ""){
				   			WriteOutput(" AND CAST(t_slip.torihiki_datetime AS DATE) <= STR_TO_DATE('#url.td_t#','#lang_src.format.date_form_sql#')");
				   			};			   			
				   		if(StructKeyExists(url,"ui") and url.ui neq ""){
				   			WriteOutput(" AND t_slip.uniform_invoice_seq_num LIKE '%#trim(url.ui)#%'");
				   			};				   			
				   			
	/*			   		if(isDefined("url.modify_date_from") and url.modify_date_from neq ""){
				   			WriteOutput(" AND t_slip.modify_date >= '#url.modify_date_from#'");
				   			};
				   		if(isDefined("url.modify_date_to") and url.modify_date_to neq ""){
				   			WriteOutput(" AND t_slip.modify_date <= '#url.modify_date_to#'");
				   			};			   						   						   			
				   						   			
				   		if(isDefined("url.modify_account") and url.modify_account neq ""){
				   			WriteOutput(" AND t_slip.modify_account = '#url.modify_account#'");
				   			};
				   		if(isDefined("url.modify_person") and url.modify_person neq ""){
				   			WriteOutput(" AND t_slip.modify_person LIKE '%#trim(url.modify_person)#%'");
				   			};
	*/	
			   			
	/*					
						if(isDefined("url.jan") and url.jan neq "" or (isDefined("url.product_id") and url.product_id neq "") or (isDefined("url.product_name") and url.product_name neq "")){
							
							 condition = "";
							
					   		if(isDefined("url.jan") and url.jan neq ""){				   			
					   			condition = condition & "AND TPSD.jan = '#url.jan#'";				   			
					   			};
					   			
					   		if(isDefined("url.product_id") and url.product_id neq ""){
					   			condition = condition & "AND LPAD(TPSD.product_id, 20, '0') = LPAD('#url.product_id#', 20, '0')";				   			
					   			};
					   		if(isDefined("url.product_name") and url.product_name neq ""){
					   			condition = condition & "AND (TPSD.product_name LIKE '%#trim(url.product_name)#%' OR TPSD.product_name_kana LIKE '%#trim(url.product_name)#%')";				   			
					   			};
					   			
					   			WriteOutput(" AND EXISTS (SELECT * FROM t_slip_detail TPSD WHERE t_slip_detail.member_id = '#session.member_id#' #preserveSingleQuotes(condition)#)" );				   			
				   			}
				   			*/			   						   			
				   	</cfscript>
		
					<cfscript>
							switch(sort_flg){
								case "1":
									WriteOutput("ORDER BY t_slip.torihiki_datetime,LPAD(t_slip.slip_num, 20, '0'),t_slip_detail.seq_num");
									break;
								case "2":
									WriteOutput("ORDER BY t_slip.torihiki_datetime DESC,LPAD(t_slip.slip_num, 20, '0'),t_slip_detail.seq_num");
									break;
								case "3":
									WriteOutput("ORDER BY t_slip.sales_date DESC,t_slip_detail.seq_num");
									break;
								case "4":
									WriteOutput("ORDER BY t_slip.sales_date,t_slip_detail.seq_num");
									break;
								case "5":
									WriteOutput("ORDER BY LPAD(t_slip.shop_id, 10, '0'),t_slip_detail.seq_num");
									break;
								case "6":
									WriteOutput("ORDER BY LPAD(t_slip.shop_id, 10, '0') DESC,t_slip_detail.seq_num");
									break;

								case "7":
									WriteOutput("ORDER BY LPAD(t_slip.regi_id, 10, '0'),t_slip_detail.seq_num");
									break;
								case "8":
									WriteOutput("ORDER BY LPAD(t_slip.regi_id, 10, '0') DESC,t_slip_detail.seq_num");
									break;
								case "9":
									WriteOutput("ORDER BY LPAD(t_slip.slip_num, 20, '0'),t_slip_detail.seq_num");
									break;
								case "10":
									WriteOutput("ORDER BY LPAD(t_slip.slip_num, 20, '0') DESC,t_slip_detail.seq_num");
									break;
								case "11":
									WriteOutput("ORDER BY t_slip.slip_division,t_slip_detail.seq_num");
									break;
								case "12":
									WriteOutput("ORDER BY t_slip.slip_division DESC,t_slip_detail.seq_num");
									break;

								case "13":
									WriteOutput("ORDER BY COUNT(DISTINCT t_slip_detail.jan),t_slip_detail.seq_num ");
									break;
								case "14":
									WriteOutput("ORDER BY COUNT(DISTINCT t_slip_detail.jan) DESC,t_slip_detail.seq_num");
									break;
								case "15":
									WriteOutput("ORDER BY t_slip.subtotal_qty,t_slip_detail.seq_num");
									break;
								case "16":
									WriteOutput("ORDER BY t_slip.subtotal_qty DESC,t_slip_detail.seq_num");
									break;
								case "17":
									WriteOutput("ORDER BY t_slip.total_amount_include_tax,t_slip_detail.seq_num");
									break;
								case "18":
									WriteOutput("ORDER BY t_slip.total_amount_include_tax DESC,t_slip_detail.seq_num");
									break;
								case "19":
									WriteOutput("ORDER BY LPAD(t_slip.create_account, 10, '0'),t_slip_detail.seq_num");
									break;
								case "20":
									WriteOutput("ORDER BY LPAD(t_slip.create_account, 10, '0') DESC,t_slip_detail.seq_num");
									break;
								case "21":
									WriteOutput("ORDER BY LPAD(t_slip.uniform_invoice_seq_num, 10, '0'),t_slip_detail.seq_num");
									break;
								case "22":
									WriteOutput("ORDER BY LPAD(t_slip.uniform_invoice_seq_num, 10, '0') DESC,t_slip_detail.seq_num");
									break;
							}


					</cfscript>	
				   	
	
			   <!---詳細画面から戻った場合、伝票番号のリストから一覧を表示 --->
			   
				   <cfif IsDefined("form.id_list") and #form.id_list# neq "" and IsDefined("url.frm_detail")>
				   		AND t_slip.slip_num IN(#form.id_list#)
				   </cfif>
			</cfquery>
		</cfif>						   
			
				
				
				<!---<cfinclude template="header.cfm" >--->
				<!--- 選択されたコードをJSでここに挿入 --->
				<input type="hidden" id="selectedID" value="">
					
				<!--- ajax用のmember_id --->
				<input type="hidden" name="mem_id" id="mem_id" value="#session.member_id#">
				
				<!--- URL変数 --->
				<cfscript>
					url_var = "";
					url_var = url_var & "j=#url.j#&";
					url_var = url_var & "sp_id=#url.sp_id#&";
					url_var = url_var & "pid=#url.pid#&";
					url_var = url_var & "pnm=#url.pnm#&";
					url_var = url_var & "sd_f=#url.sd_f#&";
					url_var = url_var & "sd_t=#url.sd_t#&";
					url_var = url_var & "rid_f=#url.rid_f#&";
					url_var = url_var & "rid_t=#url.rid_t#&";
					url_var = url_var & "snum_f=#url.snum_f#&";
					url_var = url_var & "snum_t=#url.snum_t#&";
					url_var = url_var & "slpdiv=#url.slpdiv#&";
					url_var = url_var & "slsdiv=#url.slsdiv#&";
					url_var = url_var & "cd_f=#url.cd_f#&";
					url_var = url_var & "cd_t=#url.cd_t#&";
					url_var = url_var & "ca=#url.ca#&";
					url_var = url_var & "cp=#url.cp#&";
					url_var = url_var & "td_f=#url.td_f#&";
					url_var = url_var & "td_t=#url.td_t#&";
					url_var = url_var & "ui=#url.ui#&";				


					opt_shop = "";
					slen = qGetShopForSelect.RecordCount;
					for(i = 1;i<=slen; i++){
						if(form.shop_id eq qGetShopForSelect.shop_id[i]){
							opt_shop = opt_shop & "<option value='" & qGetShopForSelect.shop_id[i] & "' selected='selected'>" & qGetShopForSelect.shop_id[i] & "&nbsp;" & qGetShopForSelect.shop_name[i] & "</option>";
						}else{
							opt_shop = opt_shop & "<option value='" & qGetShopForSelect.shop_id[i] & "'>" & qGetShopForSelect.shop_id[i] & "&nbsp;" & qGetShopForSelect.shop_name[i] & "</option>";
						}
					}

					opt_regi_f = "";
					len = qGetRegi.RecordCount;
					for(i = 1;i<=len; i++){
						if(url.rid_f eq qGetRegi.regi_id[i]){
							opt_regi_f = opt_regi_f & "<option value='" & qGetRegi.regi_id[i] & "' selected='selected'>" & qGetRegi.regi_id[i] & "&nbsp;" & qGetRegi.regi_name[i] & "</option>";
						}else{
							opt_regi_f = opt_regi_f & "<option value='" & qGetRegi.regi_id[i] & "'>" & qGetRegi.regi_id[i] & "&nbsp;" & qGetRegi.regi_name[i] & "</option>";
						}
					}
					opt_regi_t = "";
					len = qGetRegi.RecordCount;
					for(i = 1;i<=len; i++){
						if(url.rid_t eq qGetRegi.regi_id[i]){
							opt_regi_t = opt_regi_t & "<option value='" & qGetRegi.regi_id[i] & "' selected='selected'>" & qGetRegi.regi_id[i] & "&nbsp;" & qGetRegi.regi_name[i] & "</option>";
						}else{
							opt_regi_t = opt_regi_t & "<option value='" & qGetRegi.regi_id[i] & "'>" & qGetRegi.regi_id[i] & "&nbsp;" & qGetRegi.regi_name[i] & "</option>";
						}
					}

					opt_emp = "";
					len = qGetEmployee.RecordCount;
					for(i = 1;i<=len; i++){
						if(url.ca eq qGetEmployee.employee_id[i]){
							opt_emp  = opt_emp & "<option value='" & qGetEmployee.employee_id[i] & "' selected='selected'>" & qGetEmployee.employee_id[i] & "&nbsp;" & qGetEmployee.emp_name[i] & "</option>";
						}else{
							opt_emp  = opt_emp & "<option value='" & qGetEmployee.employee_id[i] & "'>" & qGetEmployee.employee_id[i] & "&nbsp;" & qGetEmployee.emp_name[i] & "</option>";
						}
					}
				</cfscript>	

<!--- 				<cfset opt_shop = "">
				<cfloop index="i" from="1" to="#qGetShopForSelect.RecordCount#">
					<cfif form.shop_id eq qGetShopForSelect.shop_id[i]>
						<cfset opt_shop &= "<option value='#qGetShopForSelect.shop_id[i]#' selected='selected'>#qGetShopForSelect.shop_id[i]#&nbsp;#qGetShopForSelect.shop_name[i]#</option>">
					<cfelse>
						<cfset opt_shop &= "<option value='#qGetShopForSelect.shop_id[i]#'>#qGetShopForSelect.shop_id[i]#&nbsp;#qGetShopForSelect.shop_name[i]#</option>">
					</cfif> 
				</cfloop>
				<cfset opt_regi_f = "">
				<cfloop index="i" from="1" to="#qGetRegi.RecordCount#">
					<cfif url.rid_f eq qGetRegi.regi_id[i]>
						<cfset opt_regi_f &= "<option value='#qGetRegi.regi_id[i]#' selected='selected'>#qGetRegi.regi_id[i]#&nbsp;#qGetRegi.regi_name[i]#</option>">
					<cfelse>
						<cfset opt_regi_f &= "<option value='#qGetRegi.regi_id[i]#'>#qGetRegi.regi_id[i]#&nbsp;#qGetRegi.regi_name[i]#</option>">
					</cfif> 
				</cfloop> --->


<!--- 				<cfset opt_regi_t = "">
				<cfloop index="i" from="1" to="#qGetRegi.RecordCount#">
					<cfif url.rid_t eq qGetRegi.regi_id[i]>
						<cfset opt_regi_t &= "<option value='#qGetRegi.regi_id[i]#' selected='selected'>#qGetRegi.regi_id[i]#&nbsp;#qGetRegi.regi_name[i]#</option>">
					<cfelse>
						<cfset opt_regi_t &= "<option value='#qGetRegi.regi_id[i]#'>#qGetRegi.regi_id[i]#&nbsp;#qGetRegi.regi_name[i]#</option>">
					</cfif> 
				</cfloop>
 				<cfset opt_emp = "">
				<cfloop index="i" from="1" to="#qGetEmployee.RecordCount#">
					<cfif url.ca eq qGetEmployee.employee_id[i]>
						<cfset opt_emp &= "<option value='#qGetEmployee.employee_id[i]#' selected='selected'>#qGetEmployee.employee_id[i]#&nbsp;#qGetEmployee.emp_name[i]#</option>">
					<cfelse>
						<cfset opt_emp &= "<option value='#qGetEmployee.employee_id[i]#'>#qGetEmployee.employee_id[i]#&nbsp;#qGetEmployee.emp_name[i]#</option>">
					</cfif> 
				</cfloop>				
--->




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
	    <cfset MaxRows = 100>
	    <!--- 表示開始行番号の設定 --->
	    <cfset s_page = (MaxRows * (page_no - 1)) + 1>
	    <!--- 表示終了行番号の設定 --->
	    <cfset e_page = (MaxRows * page_no)>
	    <!--- 検索行数のページ番号の総数の設定 --->
	    <!--- 変更必須--->
	    <cfset int_count = Int(qGetSlip.RecordCount / MaxRows)>
	    <cfset buffer = qGetSlip.RecordCount / MaxRows>
	    <cfset last_page = Ceiling(buffer)>
	    <cfif int_count LT buffer>
	        <cfset count_end = Int(qGetSlip.RecordCount / MaxRows) + 1>
	    <cfelse>
	        <cfset count_end = Int(qGetSlip.RecordCount / MaxRows)>
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
				<form action="t_slip.cfm?#url_var#" name="t_slip" method="post">
	                <div class="topmenu"  style=" overflow:hidden;" >	
	                    <div style="height:60px; margin-left:auto; margin-right:auto;">
	                    	<div style="float:left;">
								<table class="bt_table" cellpadding="0" cellspacing="0" >
		                    		<tr>
		                    			<td align="center" style="padding-top:8px;">
		                   					<input type="button" value="" class="m_button3  back_menu_btn" style="background-image:url(images/menu_bt3.png); width:30px; height:30px;"  onclick="back_to_menu()">
		                   				</td>
		                   			</tr>
		                    		<tr>
		                    			<td>#lang_src.btn.menu#</td>
		                    		</tr>
		                    	</table>
	                    	</div>
	                        <!--<input type="button" value="Menu" class="m_button back_menu_btn" onclick="back_to_menu()">-->
	                        
		                    <div style="float:right;">     
								<table class="bt_table"  cellpadding="0" cellspacing="0" >
									<tr><td align="center" style="padding-top:8px; ">
									<input type="button" value="" id='search_btn' name="search_btn"  class="m_button3 search_btn" onClick="searchSlip()"
									style="background-image: url(images/search_bt6.png); width:30px; height:30px;">
									</td></tr>
									<tr><td >#lang_src.btn.search#</td></tr>
								</table>
								<!--<input type="button" value="Search" id='search_btn' name="search_btn" class="m_button search_btn" onClick="searchSlip()">-->
								<!---<input type="button" value="追加" name="input_btn" class="input_btn" onclick="to_input('sinki');">--->
								<table class="bt_table"  cellpadding="0" cellspacing="0" >
									<tr><td align="center" style="padding-top:8px; ">
									<input type="button" value="" name="input_btn" class="m_button3 input_btn"  
									style="background-image: url(images/shosai_bt3.png); width:30px; height:30px; " onclick="to_input('syousai');">
									</td></tr>
									<tr><td >#lang_src.btn.details#</td></tr>
								</table>
								<table class="bt_table"  cellpadding="0" cellspacing="0" >
									<tr>
										<td align="center" style="padding-top:8px; ">
											<input type="button" value="" name="search_btn" class="m_button3" style="background-image: url(images/export_bt3.png); width:30px; height:30px; " onclick="exportData()">
										</td>
									</tr>
									<tr>
										<td >#lang_src.btn.export#</td>
									</tr>
								</table>								
		                	</div>
		                    <div style="margin-left:40%; margin-right:40%;">
		                        <span style="color:rgba(0,37,93,1.00); font-size:24px; line-height:60px;vertical-align:middle;">
		                        	#lang_src.menu.slip_list#
		                        </span>
		                	</div>                	
							<!--<input type="button" value="Details" name="input_btn" class="m_button input_btn" onclick="to_input('syousai');">-->
		
		
							<!---<input type="button" value="印刷" name="input_btn" class="input_btn" onclick="to_print();">--->
							<!---<input type="button" value="エクスポート" name="input_btn" class="input_btn" onclick="to_export();">--->
							<input type="hidden" value="1" name="search" id="search">
		
				
	               		</div>
	               </div>
               		<input type="hidden" id="language" value="#session.language#">
					<input type="hidden" name="shop_id_list" id="shop_id_list" value="#ArrayToList(qGetRegiForSelect["shop_id"],",")#">
					<input type="hidden" name="regi_id_list" id="regi_id_list" value="#ArrayToList(qGetRegiForSelect["regi_id"],",")#">
					<input type="hidden" name="regi_name_list" id="regi_name_list" value="#ArrayToList(qGetRegiForSelect["regi_name"],",")#">
					<div align="center"  style="margin-left:auto; margin-right:auto;">
						<div style="margin-top:20px;" id="search_contents">						
							<table cellpadding="0" cellspacing="0" border="0" class="table-me"  style="border-collapse: collapse; font-size: x-small;width:1024px;">													
								<tr>
									<th  width="60" height="15"  align="left">#lang_src.term.sales_day#&nbsp;</th>
										<td colspan="3" align="left">
											<input type="text" class="jquery-ui-datepicker" name="sales_date_from" value="#LSDateFormat(url.sd_f,lang_src.format.date_form_cf)#" size="10">〜
											<input type="text" class="jquery-ui-datepicker" name="sales_date_to" value="#LSDateFormat(url.sd_t,lang_src.format.date_form_cf)#" size="10">
										</td>
										<th width="60" height="15"  align="left"><font size="1">#lang_src.term.slip_division#</font></th>
										<td colspan="2" align="left">
											<input type="checkbox" name="slip_division" value="1" <cfif url.slpdiv neq "" and ListFind(url.slpdiv,1) neq 0>checked="checked"<cfelse></cfif>>#lang_src.term.sales#
											<input type="checkbox" name="slip_division" value="2" <cfif url.slpdiv neq "" and ListFind(url.slpdiv,2) neq 0>checked="checked"<cfelse></cfif>>#lang_src.term.return#
											<input type="checkbox" name="slip_division" value="3" <cfif url.slpdiv neq "" and ListFind(url.slpdiv,3) neq 0>checked="checked"<cfelse></cfif>>#lang_src.term.delete_slip#<!--- reversal and correcting / Delete --->
										</td>
										<th width="60" height="15"  align="center" colspan="1">#lang_src.term.item_code#&nbsp;</th>
										<td width="120" >
											<input type="text" name="product_id" value="#url.pid#" maxlength="20" size="20">
										</td>									
	<!--- 									<th width="90" height="15"  align="left"><font size="1">販売区分</font></th>
										<td align="left">
											<input type="checkbox" name="sales_division" value="1" <cfif url.slsdiv neq "" and ListFind(url.slsdiv,1) neq 0>checked="checked"<cfelse></cfif>>POS
											<input type="checkbox" name="sales_division" value="2" <cfif url.slsdiv neq "" and ListFind(url.slsdiv,2) neq 0>checked="checked"<cfelse></cfif>>通販
											<input type="checkbox" name="sales_division" value="3" <cfif url.slsdiv neq "" and ListFind(url.slsdiv,3) neq 0>checked="checked"<cfelse></cfif>>電話
											<input type="checkbox" name="sales_division" value="4" <cfif url.slsdiv neq "" and ListFind(url.slsdiv,4) neq 0>checked="checked"<cfelse></cfif>>施設利用券
											<!---<input type="checkbox" name="sales_division" value="5" <cfif #url.slsdiv# neq "" and ListFind(#url.slsdiv#,5) neq 0>checked="checked"<cfelse></cfif>>ブライダル--->
										</td> --->
										<th width="60" height="15"  align="center" colspan="1">#lang_src.term.item_name#&nbsp;</th>
										<td width="120">
											<input type="text" name="product_name" value="#url.pnm#" maxlength="20" size="20">
										</td>																					
								</tr>
								<tr>
									<th  width="60" height="15"  align="left">#lang_src.term.store#&nbsp;</th>
										<td colspan="3" align="left" style="border-right:1px ##E3E3E3 solid;">
	                                     <div class="select-box1" style="vertical-align:middle;">
	                                		<label> 
												<select name="shop_id" id="shop_id" onchange="changeShop(this.value)" style="width:120px; height:22px; padding-left:10px;">
													<option value="" selected="selected">#lang_src.term.all_stores#</option>
													#opt_shop#
												</select>
	                                        </label>
	                                        </div>			                   				                   			                   		
										</td>
			
									<th width="60" height="15"  align="center" colspan="1">#lang_src.term.slip_number#&nbsp;</th>
									<td colspan="2" width="120" >
										<input type="text" name="slip_num_from" value="#url.snum_f#" maxlength="18" size="10">〜
										<input type="text" name="slip_num_to" value="#url.snum_t#" maxlength="18" size="10">
									</td>
	                                <th width="60" height="15"  align="left">#lang_src.term.trading_day#&nbsp;</th>
										<td align="left">
											<input type="text" class="jquery-ui-datepicker" name="torihiki_datetime_from" value="#LSDateFormat(url.td_f,lang_src.format.date_form_cf)#" size="10">〜
											<input type="text" class="jquery-ui-datepicker" name="torihiki_datetime_to" value="#LSDateFormat(url.td_t,lang_src.format.date_form_cf)#" size="10">
										</td>						
									
									<th width="60" height="15"  align="center" colspan="1">#lang_src.term.sku#&nbsp;</th>
									<td width="120" style="border-top:1px ##E3E3E3 solid;">
										<input type="text" name="jan" value="#url.j#" maxlength="20" size="20">
									</td>							
								</tr>
								<tr>
									<th width="60" height="15"  align="center" colspan="1">POS</th>
									<td width="120" style="border-top:1px ##E3E3E3 solid;">	
	                                 <div class="select-box1" align="center"  style="vertical-align:middle;">
	                                <label> 
			                   			<select name="regi_id_from" id="regi_id_from" style="width:100px; height:22px; padding-left:5px;">
				                   			<cfif StructKeyExists(form,"shop_id") and form.shop_id neq "">											
												<option value="" selected="selected"></option>
												#opt_regi_f#											
											</cfif>
										</select>
	                                    </label>
	                                    </div>
	                                    </td>
	                                    <td>
	                                  	                   			                   		
										〜
	                                    </td>
	                                    <td>
	                                     <div class="select-box1" align="center"  style="vertical-align:middle;">
	                                <label> 
			                   			<select name="regi_id_to" id="regi_id_to" style="width:100px; height:22px; padding-left:5px;">
				                   			<cfif StructKeyExists(form,"shop_id") and form.shop_id neq "">											
												<option value="" selected="selected"></option>
												#opt_regi_t#											
											</cfif>
										</select>
	                                    </label>
	                                    </div>

									</td>						
									<th width="60" height="15"  align="left">#lang_src.term.sales_staff#&nbsp;</th>
									<td  align="left">
		                                <div class="select-box1" style="vertical-align:middle;">
			                                <label> 
					                   			<select name="create_account" style="width:120px; height:22px; padding-left:10px;">			                   														
													<option value="" selected="selected"></option>
													#opt_emp#
												</select>
			                                </label>
		                                </div>
	                                </td>
	                                    <td>
				                   		<input type="text" name="create_person" value="#url.cp#" maxlength="20" size="10">		                   			                   		
									</td>		
									<th width="60" height="15"  align="left">
										<cfif qGetAdmin.country_id eq 6>
											#lang_src.term.uniform_invoice#
										</cfif>
									</th>
									<td width="60" >
										<cfif qGetAdmin.country_id eq 6>
											<input type="text" name="uniform_invoice" value="#url.ui#" maxlength="15" size="15">
										</cfif>
									</td>	
									<th width="60" height="15"  align="center" colspan="1"></th>
									<td width="60" ></td>											
								</tr>
							</table>
						</div>
					

	<!---						<ul class="tab">
								<li class="select"><font color='white'>伝票別</font></li>
								<!---<li><font color='white'>明細別</font></li>--->
							</ul>	--->
						
						<div>
							<ul class="content" style="padding:0;" >
								<li>				
								    <cfif 0 LT qGetSlip.RecordCount>
								        <cfset search_t_width = 300 + (40 * ((op_end - op_str) + 1))>
								         <div style="font-size:10px;width:1024px;margin-bottom:10px;" align="right">
								         	<cfif 0 LT qGetSlip.RecordCount>
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
									</cfif>									
										<table cellpadding="0" cellspacing="0" border="0" class="table-me  slip_list" id="table_id" style="border-collapse: collapse; font-size: xx-small;border:none; margin:0;width:1024px;">
											<thead style="background-color:white;text-align:center;">
												<tr>
													<th width="110" align='center' style="word-wrap:break-word;overflow-wrap:break-word;">&nbsp;
														<cfif sort_flg eq 2>
															<a onclick="changeSort(1)" class="sort">#lang_src.term.trading_date_time#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 1>
															<a onclick="changeSort(2)" class="sort">#lang_src.term.trading_date_time#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(1)" class="sort">#lang_src.term.trading_date_time#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>

													<th width="90">
														<cfif sort_flg eq 4>
															<a onclick="changeSort(3)" class="sort">#lang_src.term.sales_day#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 3>
															<a onclick="changeSort(4)" class="sort">#lang_src.term.sales_day#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(3)" class="sort">#lang_src.term.sales_day#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
													<th width="30">
														<cfif sort_flg eq 6>
															<a onclick="changeSort(5)" class="sort">#lang_src.term.store#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 5>
															<a onclick="changeSort(6)" class="sort">#lang_src.term.store#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(5)" class="sort">#lang_src.term.store#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>														
													</th>
													<th width="30">														
														<cfif sort_flg eq 8>
															<a onclick="changeSort(7)" class="sort">POS
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 7>
															<a onclick="changeSort(8)" class="sort">POS
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(7)" class="sort">POS
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
													<th width="90">
														<cfif sort_flg eq 10>
															<a onclick="changeSort(9)" class="sort">#lang_src.term.slip_number#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 9>
															<a onclick="changeSort(10)" class="sort">#lang_src.term.slip_number#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(9)" class="sort">#lang_src.term.slip_number#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
													<!--- 台湾の場合統一発票の番号を表示 --->
													<cfif qGetAdmin.country_id eq 6>
														<th width="90">
															<cfif sort_flg eq 22>
																<a onclick="changeSort(21)" class="sort">#lang_src.term.uniform_invoice#
																	<img src="images/sort_desc.png" border="0">
																</a>
															<cfelseif sort_flg eq 21>
																<a onclick="changeSort(22)" class="sort">#lang_src.term.uniform_invoice#
																	<img src="images/sort_asc.png" border="0">
																</a>
															<cfelse>
																<a onclick="changeSort(21)" class="sort">#lang_src.term.uniform_invoice#
																	<img src="images/sort_both.png" border="0">
																</a>
															</cfif>
														</th>														
													</cfif>
													
													<th width="40">
														<cfif sort_flg eq 12>
															<a onclick="changeSort(11)" class="sort">#lang_src.term.slip_division#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 11>
															<a onclick="changeSort(12)" class="sort">#lang_src.term.slip_division#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(11)" class="sort">#lang_src.term.slip_division#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
													<!--- <th width="60">販売区分&nbsp;</th> --->
													<!--- <th width="30">VAT</th> --->
													<th width="30">
														<cfif sort_flg eq 14>
															<a onclick="changeSort(13)" class="sort">#lang_src.term.item#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 13>
															<a onclick="changeSort(14)" class="sort">#lang_src.term.item#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(13)" class="sort">#lang_src.term.item#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
<!--- 													<th width="">
														<cfif sort_flg eq 16>
															<a onclick="changeSort(15)" class="sort">#lang_src.term.total_amount#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 15>
															<a onclick="changeSort(16)" class="sort">#lang_src.term.total_amount#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(15)" class="sort">#lang_src.term.total_amount#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th> --->
													<!--- <th width="120">Gross Sales<br>(Tax Excl.)</th>
													<th width="120">Gross Sales<br>(Tax)</th> --->
													<th width="120">
														<cfif sort_flg eq 18>
															<a onclick="changeSort(17)" class="sort">#lang_src.term.gross_sales#<br>(#lang_src.term.in_tax#)
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 17>
															<a onclick="changeSort(18)" class="sort">#lang_src.term.gross_sales#<br>(#lang_src.term.in_tax#)
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(17)" class="sort">#lang_src.term.gross_sales#<br>(#lang_src.term.in_tax#)
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>
													</th>
													<th width="63" height="30">
														<cfif sort_flg eq 20>
															<a onclick="changeSort(19)" class="sort">#lang_src.term.sales_staff#
																<img src="images/sort_desc.png" border="0">
															</a>
														<cfelseif sort_flg eq 19>
															<a onclick="changeSort(20)" class="sort">#lang_src.term.sales_staff#
																<img src="images/sort_asc.png" border="0">
															</a>
														<cfelse>
															<a onclick="changeSort(19)" class="sort">#lang_src.term.sales_staff#
																<img src="images/sort_both.png" border="0">
															</a>
														</cfif>													
													</th>
												</tr>
											</thead>
											
											<cfset loop_count = qGetSlip.RecordCount>
											<cfset max_count = 2000>

											<cfset even_bg_color = "rgba(206,243,245,0.8)">
											<cfset odd_bg_color = "white">
<!--- 											<cfif loop_count GTE max_count>
												<cfset loop_count = max_count>
													<font color="red">The applicable number beyond #loop_count# save it, and display it to #loop_count# cases.
												</font>
											</cfif> --->
											<!---<cfif loop_count GTE max_count><cfset loop_count = max_count><font color="red">該当件数が#loop_count#件を超えたため、#loop_count#件まで表示しています。</font></cfif>--->
																	
											<input type='hidden' id='loop_count' value='#loop_count#'>
	<!---										<cfscript>
												for (cnt=1;cnt lte loop_count;cnt=cnt+1){
													WriteOutput("<input type='hidden' name='id_list' value='#qGetSlip.slip_num[cnt]#'>");
															};
											</cfscript>--->
											
											<tbody style="">
												<cfset slip_id_list = ''>
												<cfset session.slip_id_list = ArrayToList(qGetSlip["slip_num"],",")>
												<cfscript>


													if(qGetAdmin.country_id == 6){//台湾向けは統一発票の表示がある。
														for (cnt=s_page;cnt lte e_page;cnt++){
															if(cnt gt loop_count){
																break;
															}
															WriteOutput("<tr class='list_tr'><td data-sort='" & qGetSlip.torihiki_datetime[cnt] & "' width='104' height='20'>" & qGetSlip.char_torihiki_datetime[cnt] & "</td><td width='82' data-sort='" & qGetSlip.sales_date[cnt] & "'>" & qGetSlip.char_sales_date[cnt] & "</td><td width='31'>" & qGetSlip.shop_id[cnt] & "</td><td width='30'>" & qGetSlip.regi_id[cnt] & "</td><td width='84'>" & qGetSlip.slip_num[cnt] & "</td><td width='84'>" & qGetSlip.uniform_invoice_seq_num[cnt] & "</td><td width='116'>" & qGetSlip.char_slip_division[cnt] & "</td><td width='31' align='right'>" & qGetSlip.jan_count[cnt] & "</td><td width='116' align='right'>" & qGetSlip.char_total_amount_include_tax[cnt] & "</td><td width='60'>" & qGetSlip.create_person[cnt] & "</td></tr>");
														};														
													}else{
														for (cnt=s_page;cnt lte e_page;cnt++){
															if(cnt gt loop_count){
																break;
															}

															WriteOutput("<tr class='list_tr'><td data-sort='" & qGetSlip.torihiki_datetime[cnt] & "' width='104' height='20'>" & qGetSlip.char_torihiki_datetime[cnt] & "</td><td width='82' data-sort='" & qGetSlip.sales_date[cnt] & "'>" & qGetSlip.char_sales_date[cnt] & "</td><td width='31'>" & qGetSlip.shop_id[cnt] & "</td><td width='30'>" & qGetSlip.regi_id[cnt] & "</td><td width='84'>" & qGetSlip.slip_num[cnt] & "</td><td width='116'>" & qGetSlip.char_slip_division[cnt] & "</td><td width='31' align='right'>" & qGetSlip.jan_count[cnt] & "</td><td width='116' align='right'>" & qGetSlip.char_total_amount_include_tax[cnt] & "</td><td width='60'>" & qGetSlip.create_person[cnt] & "</td></tr>");
														};														
													}

												</cfscript>
		
											</tbody>
											<!--- <input type='hidden' name='id_list' value='#id_list#'> --->
											<input type='hidden' name='sort_flg' id='sort_flg' value='#sort_flg#'>
											<input type='hidden' name='eq_page' id='eq_page' value='#page_flg#'>

	<!--- 										<tfoot>
												<tr><td colspan="12"></td></tr>
											</tfoot> --->												
										</table>
								</li>
	<!---							<li class="hide">
									<div style="float:left;overflow:auto;">
										<table cellpadding="0" cellspacing="0" border="0" id="table_id_detail" align="left" style="border-collapse: collapse; font-size: xx-small;">
											<thead class="scrollHead" style="background-color:white;width:2000px">
												<tr>
													<th width="100" height="30"  align="center">取引(入力)日時&nbsp;</th>
													<th width="100" height="30"  align="center">売上日&nbsp;</th>
													<th width="70" height="30"  align="center">レジ番号&nbsp;</th>
													<th width="200" height="30"  align="center">伝票番号&nbsp;</th>
													<th width="100" height="30"  align="center">伝票区分&nbsp;</th>
													<th width="100" height="30"  align="center">販売区分&nbsp;</th>
													<th width="100" height="30"  align="center">商品コード&nbsp;</th>
													<th width="200" height="30"  align="center">JANコード&nbsp;</th>
													<th width="250" height="30"  align="center">商品名&nbsp;</th>
													<th width="250" height="30"  align="center">レシート品名&nbsp;</th>
													<th width="100" height="30"  align="center">数量&nbsp;</th>
													<th width="100" height="30"  align="center">売単価(税込)&nbsp;</th>
													<th width="100" height="30"  align="center">売単価(税抜)&nbsp;</th>
													<th width="100" height="30"  align="center">取引担当者&nbsp;</th>
												</tr>
											</thead>
											
											<cfset loop_count_detail = #qGetSlipDetail.RecordCount#>
											<input type='hidden' id='loop_count_detail' value='#loop_count_detail#'>
											<tbody class="scrollBody"style="width:2000px">
												<cfscript>
													for (cnt=1;cnt lte loop_count_detail;cnt=cnt+1){
														WriteOutput("
															<tr class='list_tr'>
																<td width='100' align='left'>#qGetSlipDetail.char_torihiki_datetime[cnt]#</td>
																<td width='100' align='left'>#qGetSlipDetail.char_sales_date[cnt]#</td>
																<td width='70' align='left'>#qGetSlipDetail.regi_id[cnt]#</td>
																<td width='200' align='left'>#qGetSlipDetail.slip_num[cnt]#</td>
																<td width='100' align='left'>#qGetSlipDetail.char_slip_division[cnt]#</td>
																<td width='100' align='left'>#qGetSlipDetail.char_sales_division[cnt]#</td>
																<td width='100' align='left'>#qGetSlipDetail.product_id[cnt]#</td>
																<td width='200' align='left'>&nbsp;#qGetSlipDetail.jan[cnt]#</td>
																<td width='250' align='left'>#qGetSlipDetail.product_name[cnt]#</td>																								
																<td width='250' align='left'>#qGetSlipDetail.receipt_name[cnt]#</td>
																<td width='100' align='right'>#qGetSlipDetail.qty[cnt]#&nbsp;</td>
																<td width='100' align='right'>&nbsp;&nbsp;#qGetSlipDetail.unit_price_without_tax[cnt]#</td>
																<td width='100' align='right'>#qGetSlipDetail.unit_price_include_tax[cnt]#</td>														
																<td width='100' align='left'>#qGetSlipDetail.create_person[cnt]#</td>
															</tr>
														");
												};
												</cfscript>
		
											</tbody>
											<tfoot>
												<tr><td colspan="12"></td></tr>
											</tfoot>												
										</table>
									</div>
								</li>--->
							</ul><!--- /タブ用 --->
						</div>					
					</div>
				</form>
		</div>

					<cfif IsDefined("url.exp_flg") and url.exp_flg eq 1>
				        <cfif DirectoryExists(application.export_dir & session.member_id & "/t_slip") is false>
				        	<cfset create_dir = application.export_dir & session.member_id & "/t_slip">
				            <cfdirectory action="create" directory="#create_dir#" mode="777">
				        </cfif>
						<cfset today = DateFormat(now, lang_src.format.date_form_cf2)>
						<cfset filename = application.export_dir & "t_slip_" & today & TimeFormat(now, "hhmmss") & ".csv">
						
							<cfif qGetAdmin.country_id eq 6>
								<cfset header = lang_src.term.trading_date_time & "," 
								              & lang_src.term.sales_day & "," 
								              & lang_src.term.store & ","
								              & "POS,"
								              & lang_src.term.slip_number & ","
								              & lang_src.term.uniform_invoice & ","
								              & lang_src.term.slip_division & ","
								              & lang_src.term.item & "," 
								              & lang_src.term.gross_sales & "(" & lang_src.term.in_tax & ")" & ","
								              & lang_src.term.sales_staff>
								<cfif qGetAdmin.cash_rounding_flag eq 1>
									<cfset header = header & lang_src.term.rounding_adjust & "," & lang_src.term.adjusted_total>
								</cfif>


							<cfelse>
								<cfset header = lang_src.term.trading_date_time & "," 
								              & lang_src.term.sales_day & "," 
								              & lang_src.term.store & ","
								              & "POS,"
								              & lang_src.term.slip_number & ","
								              & lang_src.term.slip_division & ","
								              & lang_src.term.item & "," 
								              & lang_src.term.gross_sales & "(" & lang_src.term.in_tax & ")" & ","
								              & lang_src.term.sales_staff & ",">
								
								<cfif qGetAdmin.cash_rounding_flag eq 1>
									<cfset header = header & lang_src.term.rounding_adjust & "," & lang_src.term.adjusted_total & ",">
								</cfif>
								<cfset header = header & getLang("term","cash") & ",">
								<cfif qGetReceiptMethod.RecordCount gte 12>
									<cfset method_loop = 12>
								</cfif>								
								<cfloop index="i" from="1" to="#method_loop#">
									<cfset header = header & qGetReceiptMethod.receipt_method_name[i]>
									<cfif i neq qGetReceiptMethod.RecordCount>
										<cfset header = header & ",">
									</cfif>
								</cfloop>																              
							</cfif>


							<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">
								<cfloop index="cnt" from="1" to="#qGetSlip.RecordCount#">
									<cfset data = "">
										<cfif qGetAdmin.country_id eq 6>
											<cfset data =   qGetSlip.char_torihiki_datetime[cnt] & ","
														  & qGetSlip.char_sales_date[cnt] & ","
														  & qGetSlip.shop_id[cnt] & ","
														  & qGetSlip.regi_id[cnt] & ","
														  & qGetSlip.slip_num[cnt] & ","
														  & qGetSlip.uniform_invoice_seq_num[cnt] & ","
														  & qGetSlip.char_slip_division[cnt] & ","
														  & qGetSlip.jan_count[cnt] & ","
														  & qGetSlip.raw_total_amount_include_tax[cnt] & ","
														  & qGetSlip.create_person[cnt]>
											<cfif qGetAdmin.cash_rounding_flag eq 1>
												<cfset adjusted_total = qGetSlip.raw_total_amount_include_tax[cnt] - qGetSlip.cash_rounding_amount[cnt]>
												<cfset data = data & "," & qGetSlip.cash_rounding_amount[cnt] & "," & adjusted_total>											
											</cfif>														  											
										<cfelse>
											<cfset data =   qGetSlip.char_torihiki_datetime[cnt] & ","
														  & qGetSlip.char_sales_date[cnt] & ","
														  & qGetSlip.shop_id[cnt] & ","
														  & qGetSlip.regi_id[cnt] & ","
														  & qGetSlip.slip_num[cnt] & ","
														  & qGetSlip.char_slip_division[cnt] & ","
														  & qGetSlip.jan_count[cnt] & ","
														  & qGetSlip.raw_total_amount_include_tax[cnt] & ","
														  & qGetSlip.create_person[cnt] & ",">
											<cfif qGetAdmin.cash_rounding_flag eq 1>
												<cfset adjusted_total = qGetSlip.raw_total_amount_include_tax[cnt] - qGetSlip.cash_rounding_amount[cnt]>
												<cfset data = data & qGetSlip.cash_rounding_amount[cnt] & "," & adjusted_total & ",">
											</cfif>
											<cfset data = data & qGetSlip.receipt_amount0[cnt] & ",">
											<cfif qGetReceiptMethod.RecordCount gte 12>
												<cfset method_loop = 12>
											</cfif>
											<cfloop index="i" from="1" to="#method_loop#">
												<cfset data = data & qGetSlip["receipt_amount" & i][cnt]>
												<cfif i neq qGetReceiptMethod.RecordCount>
													<cfset data = data & ",">
												</cfif>
											</cfloop>
										</cfif>
												 
									<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
								</cfloop>

						
								<!--- <cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#"> --->
							<!--- CSVダウンロード処理 --->
								<!---<cfheader name="Content-Disposition" value="attachment; filename=取引精算_#today#.csv" charset="#lang_src.format.export_charset#>--->
								<cfheader name="Content-Disposition" value="attachment; filename=transaction_#today#.csv" charset="#lang_src.format.export_charset#">
								<cfcontent type="text/csv" file="#filename#" deletefile="yes">
					<cfelseif IsDefined("url.exp_flg") and url.exp_flg eq 2>
				        <cfif DirectoryExists(application.export_dir & session.member_id & "/t_slip_detail") is false>
				        	<cfset create_dir = application.export_dir & session.member_id & "/t_slip_detail">
				            <cfdirectory action="create" directory="#create_dir#" mode="777">
				        </cfif>
						<cfset today = DateFormat(now, lang_src.format.date_form_cf2)>
						<cfset filename = application.export_dir & "t_slip_detail_" & today & TimeFormat(now, "hhmmss") & ".csv">

								<cfset header = lang_src.term.trading_date_time & "," 
								              & lang_src.term.sales_day & "," 
								              & lang_src.term.store & ","
								              & "POS,"
								              & lang_src.term.slip_number & ","
								              & "Seq No." & ","
								              & lang_src.term.slip_division & ","
								              & getLang("term","category_code") & ","
								              & getLang("term","category") & ","
								              & getLang("term","sku") & ","
								              & getLang("term","product_name") & ","
								              & getLang("term","standard_unit_price") & ","
								              & getLang("term","tax_rate") & ","
								              & getLang("term","qty") & ","
								              & getLang("term","sales_unit_price_ex_tax") & ","
								              & getLang("term","sales_unit_price_in_tax") & ","
								              
								              & getLang("term","discount_price_on_item") & ","
								              & getLang("term","discount_rate") & ","
								              & getLang("term","discount_rate_on_item") & ","
								              
								              & getLang("term","amount") & "(" & getLang("term","ex_tax") & ")" & ","
								              & getLang("term","amount") & "(" & getLang("term","in_tax") & ")" & ","
								              & "VAT"
								              >

							<cffile action="write" file="#filename#" output="#header#" charset="#lang_src.format.export_charset#">
								<cfloop index="cnt" from="1" to="#qGetSlipDetail.RecordCount#">
									<cfset data = "">

											<cfset data =   qGetSlipDetail.char_torihiki_datetime[cnt] & ","
														  & qGetSlipDetail.char_sales_date[cnt] & ","
														  & qGetSlipDetail.shop_id[cnt] & ","
														  & qGetSlipDetail.regi_id[cnt] & ","
														  & qGetSlipDetail.slip_num[cnt] & ","
														  & qGetSlipDetail.seq_num[cnt] & ","
														  & qGetSlipDetail.char_slip_division[cnt] & ","

														  & qGetSlipDetail.division_id[cnt] & ","
														  & qGetSlipDetail.division_name[cnt] & ","
														  & qGetSlipDetail.jan[cnt] & ","
														  & qGetSlipDetail.product_name[cnt] & ","
														  & qGetSlipDetail.unit_price_include_tax[cnt] & ","
														  & qGetSlipDetail.tax_rate[cnt] & ","
														  & qGetSlipDetail.qty[cnt] & ","
														  & qGetSlipDetail.original_unit_price_without_tax[cnt] & ","
														  & qGetSlipDetail.original_unit_price_include_tax[cnt] & ","
														  & qGetSlipDetail.price_discount_amount[cnt] & ","
														  & qGetSlipDetail.discount_rate[cnt] & ","
														  & qGetSlipDetail.percent_discount_amount[cnt] & ","
														  & qGetSlipDetail.fix_sales_amount_without_tax[cnt] & ","
														  & qGetSlipDetail.fix_sales_amount_include_tax[cnt] & ","
														  & qGetSlipDetail.fix_sales_amount_tax[cnt]
														  >												 
									<cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#">	
								</cfloop>

								<!--- <cffile action="append" file="#filename#" output="#data#" charset="#lang_src.format.export_charset#"> --->
							<!--- CSVダウンロード処理 --->
								<!---<cfheader name="Content-Disposition" value="attachment; filename=取引精算_#today#.csv" charset="#lang_src.format.export_charset#>--->
								<cfheader name="Content-Disposition" value="attachment; filename=transaction_#today#.csv" charset="#lang_src.format.export_charset#">
								<cfcontent type="text/csv" file="#filename#" deletefile="yes">
					</cfif>


		</cfoutput>
	
	<script type="text/javascript" charset="utf8" src="js/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui.min.js"></script>
	<!---<script type="text/javascript" src="js/datepicker-ja.js"></script>--->
	<script type="text/javascript" charset="utf8" src="//cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
	<!---
	<script type="text/javascript" charset="utf8" src="//cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
	--->

	<script>
	var LANG_RSC;
	jQuery( function() {
		$("tr:odd td").addClass("odd");
		$("tr:even td").addClass("even");

		var lang = $("#language").val();

		$.getJSON("lang/term-" + lang + ".json", function (data) {
	      	LANG_RSC = data;			
	    	jQuery( '.jquery-ui-datepicker' ) . datepicker({
	    		//dateFormat: 'yy/mm/dd',
	    		dateFormat: LANG_RSC.format.date_form_js,
	    	});

    	});
    	//search_menu()

    var table = $('#table_id');

	 // var tbl = table.dataTable( {
		// "bPaginate"    : false,
		// "bLengthChange": true,
		// "bDeferRender" :true,
		// "bFilter"      : false,
		// "bSort"        : true,
		// "bInfo"        : false,
		// "bAutoWidth"   : false,
		// "scrollX"      :"780px"			
	 //  });
	 //  tbl.fnSort( [ [0,'desc']] );
	  //document.getElementById('table_id').style.display = 'table'
	 
	 //table.show('fast');
	 // $("#scrollHead").show('fast')
	 // $("#scrollBody").show('fast')
			//$('#loading').remove()	 



/*明細用

	 var tbl_detail = $('#table_id_detail').dataTable( {
	    "bPaginate": false,
	    "bLengthChange": true,
	    "bFilter": false,
	    "bSort": true,
	    "bInfo": false,
	    "bAutoWidth": false,
	    "scrollX":"780px"
			
	  });
	  tbl_detail.fnSort( [ [0,'desc']] );


*/

/*
		jQuery(function() {
			$('.tab li').click(function() {
				var index = $('.tab li').index(this);
				$('.content li').css('display','none');
				$('.content li').eq(index).css('display','block');
				$('.tab li').removeClass('select');
				$(this).addClass('select')
			});
		});	
*/
		
	  //tdの3番めの要素のテキストが伝票番号
	  if($('#search').val() == 1){
	  	$('#table_id tbody').on('click', 'tr', function () {
	  		
			$('.selected_thing').removeClass("selected_thing");
        	var id = $('td', this).eq(4).text();
        	if(id != ""){
	        	$('#selectedID').val(id);
	        	//$('td',this).attr("class","selected_thing");
	        	$('td',this).attr('class', function(index, classNames) {
	        		return classNames + ' selected_thing';
				});
        	}

    	} );
	  	$('#table_id tbody').on('dblclick', 'tr', function () {

	  		$('.selected_thing').removeClass("selected_thing");

        	var id = $('td', this).eq(4).text();
	        	if(id != ""){
	        		$('#selectedID').val(id);
	        		$('td',this).addClass("selected_thing");
	        	var lct = $('#loop_count').val();
					document.t_slip.method="post";
					document.t_slip.action = "t_slip_detail.cfm?s_num=" + id + "&lct=" + lct;
					document.t_slip.submit();
					}
    	} );
    }
		
	  //new FixedHeader( tbl);
	});



   //  	function search_menu(){
   //  		var show_flag = 0
			// $("#search_btn").mouseover(function(){
			// 	if(show_flag == 0){
			// 		$('#search_contents').show();
			// 		show_flag = 1
			// 	}else{
			// 		$('#search_contents').hide();
			// 		show_flag = 0
			// 	}
			// })	    		    		
   //  	}		
		function to_input(a){
			if(a != "sinki"){
				var id = $('#selectedID').val();
				var lct = $('#loop_count').val();
					if(id != ""){
						document.t_slip.method="post";
						document.t_slip.action = "t_slip_detail.cfm?s_num=" + id + "&lct=" + lct;
						document.t_slip.submit();
					}else{
						alert("Please select a slip.");
					}
			}else{
				location.href = "t_slip_input.cfm"
			}
		};

/*
		function to_copy(){			
			var id = $('#selectedID').val();
			var lct = $('#loop_count').val();
				if(id != ""){
					document.t_slip.method="post";
					document.t_slip.action = "t_slip_input.cfm?s_num=" + id + "&lct=" + lct + "&cpy";
					document.t_slip.submit();
				}else{
					alert("ラインを選択してください。");
				}			
		};
*/

/*
		function to_print(){
			window.open("about:blank","master_line_print");
			document.master_line.target = "master_line_print";
			document.master_line.method="post";
			document.master_line.action = "master_line_print.cfm";
			document.master_line.submit();			
		}
*/
		
/*
		function to_export(){
			document.master_line.method="post";
			document.master_line.action = "master_line_export_action.cfm";
			document.master_line.submit();			
		}
*/
		function back_to_menu(){
			location.href="main.cfm";
		};	
		function searchSlip(){
			document.t_slip.method="post";
			document.t_slip.action = "t_slip.cfm";
			document.t_slip.submit();				
		}
		jQuery( function() {
			var shop_id = $('#shop_id').val(),
				regi_id_from = $('#regi_id_from').val(),
				regi_id_to = $('#regi_id_to').val();
			 if(shop_id){
			 	changeShop(shop_id);
			 }
				 $('#regi_id_from').val(regi_id_from);
				 $('#regi_id_to').val(regi_id_to);
			 
		} );		
		function changeShop(shop_id){
			var shop_id_list = $('#shop_id_list').val(),
				regi_id_list = $('#regi_id_list').val(),
				regi_name_list =  $('#regi_name_list').val()

				//配列に変換
				var shop_id_arr            = shop_id_list.split(',');
				var regi_id_arr            = regi_id_list.split(',');
				var regi_name_arr          = regi_name_list.split(',');
				var op = "<option value = ''></option>";

				for(var i = 0,regi_len = regi_id_arr.length;i<regi_len;i++){
					if(!shop_id){
						continue;
					}					
					if(shop_id_arr[i] != shop_id){
						continue;
					}

					op += "<option value = '" + regi_id_arr[i] + "'>" + regi_id_arr[i] + " " + regi_name_arr[i] + "</option>"
				}
				console.log(op)
				$('#regi_id_from').html('').append(op)			
				$('#regi_id_to').html('').append(op)			
		}
		function exportData(sort_flg){
			var sort_flg = $("#sort_flg").val();
			document.t_slip.target = "_self";
			document.t_slip.method="post";
			document.t_slip.action = "t_slip.cfm?exp_flg=1&sort_flg=" + sort_flg;
			document.t_slip.submit();			
		}
		function changeSort(sort_flg){
			var eq_page = $("#eq_page").val();
			document.t_slip.target = "_self";
			document.t_slip.method="post";
			document.t_slip.action = "t_slip.cfm?sort_flg=" + sort_flg + "&eq_page=" + eq_page;
			document.t_slip.submit();			
		}
		function changePage(eq_page){
			var sort_flg = $("#sort_flg").val();
			document.t_slip.target = "_self";
			document.t_slip.method="post";
			document.t_slip.action = "t_slip.cfm?sort_flg=" + sort_flg + "&eq_page=" + eq_page;
			document.t_slip.submit();			
		}
		//画面サイズを取ってtopmenuクラスの幅を指定
		function getWindowSizeAndResize() {
			var sW,sH,s;
			sW = window.innerWidth;
			sH = window.innerHeight;
			$(".topmenu").attr("width",sW);
		}

		$(document).on("ready",function(){
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
</div>
</div>
</body>
</html>