<!DOCTYPE html>
<cfinclude template = "init.cfm">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#lang_src.menu.payment_type#</cfoutput></title>
</head>

<body>
<cfoutput>
	<cfset used_ids = []>
	<cfloop index="cnt" from="1" to="30">
		<cfset used_ids[cnt] = "">
		<cfif StructKeyExists(Form,"receipt_method_id_" & cnt) and Form["receipt_method_id_" & cnt] neq "">
			<cfset used_ids[cnt] = Form["receipt_method_id_" & cnt]>
			<!--- <cfset ArrayAppend(used_ids,Form["receipt_method_id_" & cnt])>#Form["receipt_method_id_" & cnt]# --->
		</cfif>							
	</cfloop>

<!--- 	<cfloop index="i" from="1" to="30">
		<cfset used_ids[i] = "">
	</cfloop> --->

	<cftransaction>
		<!--- セーブポイントをセットする前にqueryが必要っぽいのでこれを --->
		<cfquery datasource="#application.dsn#" name="qGetReceiptMethod">
			SELECT receipt_method_id FROM m_receipt_method_sales WHERE member_id = "#session.member_id#"
		</cfquery>

		<!--- セーブポイントセット --->
		<cftransaction action="setsavepoint" savepoint="before_delete"/>
	

		<cfquery datasource="#application.dsn#" name="qDelDiscountPrice">
			DELETE FROM m_receipt_method_sales WHERE member_id = "#session.member_id#"
		</cfquery>

		<cfif IsDefined("url.line_num") and url.line_num neq 0>
			<cfset line_num = url.line_num>
			<cfset count = 0>
			<cfloop index="i" from="1" to="#line_num#">
				<cfif StructKeyExists(Form,"receipt_method_name1_" & i) and Form["receipt_method_name1_" & i] neq ""
				   or StructKeyExists(Form,"receipt_method_name2_" & i) and Form["receipt_method_name2_" & i] neq ""
				   or StructKeyExists(Form,"receipt_method_name3_" & i) and Form["receipt_method_name3_" & i] neq "">
					<cfif !StructKeyExists(Form,"receipt_method_id_" & i) or Form["receipt_method_id_" & i] eq "">
						<cfloop index="new_id" from="1" to="30">
							<cfset is_used_id = ArrayContains(used_ids,new_id)>
							<cfif !is_used_id>
								<cfset Form["receipt_method_id_" & i] = new_id>
								<cfset ArrayAppend(used_ids,new_id)>
								<cfbreak>
							</cfif>
						</cfloop>												
					</cfif>

					<cfset count ++>
					<cftry>
						<cfquery datasource="#application.dsn#" name="qInsertPaymentMethod">
							INSERT INTO m_receipt_method_sales 
									(
										member_id,
										receipt_method_id,
										receipt_method_name,
										receipt_method_name1,
										receipt_method_name2,
										receipt_method_name3,
										receipt_method_name4,
										receipt_method_name5,
										receipt_method_name6,
										sort_order,
										tw_remove_from_ui_flag,
										changeable_flag,
										function_num,
										amount_input_flag,
										payment_amount,
										multiple_method_flag,
										<!---money_on_hand_flag, --->
										
										over_payable_flag,
										memo,
										create_date,
										create_account,
										create_person										
									)VALUES(
										'#session.member_id#',
										"#Form["receipt_method_id_" & i]#",
										<cfif StructKeyExists(Form,"receipt_method_name" & i) and Form["receipt_method_name" & i] neq "">
											"#Form["receipt_method_name" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name1_" & i) and Form["receipt_method_name1_" & i] neq "">
											"#Form["receipt_method_name1_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name2_" & i) and Form["receipt_method_name2_" & i] neq "">
											"#Form["receipt_method_name2_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name3_" & i) and Form["receipt_method_name3_" & i] neq "">
											"#Form["receipt_method_name3_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name4_" & i) and Form["receipt_method_name4_" & i] neq "">
											"#Form["receipt_method_name4_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name5_" & i) and Form["receipt_method_name5_" & i] neq "">
											"#Form["receipt_method_name5_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										<cfif StructKeyExists(Form,"receipt_method_name6_" & i) and Form["receipt_method_name6_" & i] neq "">
											"#Form["receipt_method_name6_" & i]#",
										<cfelse>
											NULL,
										</cfif>
										#count#,
										<cfif StructKeyExists(Form,"tw_remove_from_ui_flag" & i) and Form["tw_remove_from_ui_flag" & i] neq "">
											"#Form["tw_remove_from_ui_flag" & i]#",
										<cfelse>
											1,
										</cfif>										
										
										<cfif StructKeyExists(Form,"function_num" & i) and Form["function_num" & i] eq 84> <!--- 釣り有りは84固定 --->
										1,
										<cfelse>
										0,
										</cfif>
										"#Form["function_num" & i]#",
										<cfif StructKeyExists(Form,"payment_amount" & i) and (Form["payment_amount" & i] neq "" or Form["payment_amount" & i] neq 0)>
											<!--- 金額が入っていたらフラグ1 --->
											1,
											#Form["payment_amount" & i]#,
										<cfelse>
											0,
											0,
										</cfif>
										"#Form["multiple_method_flag" & i]#",
										<!--- "#Form["money_on_hand_flag" & i]#", --->
										"#Form["over_payable_flag" & i]#",
										<cfif StructKeyExists(Form,"memo" & i) and Form["memo" & i] neq "">
											'#Form["memo" & i]#',
										<cfelse>
											NULL,
										</cfif>
										ADDTIME(UTC_TIMESTAMP(),"#session.utc_offset#"),
										'#session.employee_id#',
										concat(ifnull('#session.employee_last_name#',''),' ',ifnull('#session.employee_first_name#',''))
									)										
						</cfquery>
						<cfcatch type="database">
							<cflog type="error" file="shopcenter" text="file:master_payment_method_action---エラー:#cfcatch.queryError#">
							<cftransaction action="rollback" savepoint="before_delete"/>		
							Unexpected Error
							<a href="master_payment_method_input.cfm">戻る</a>
							<cfabort>								
						</cfcatch>																	
					</cftry>	
				</cfif>
			</cfloop>
		</cfif>
	</cftransaction>

</cfoutput>

<cflocation url="master_payment_method.cfm" addtoken="false">
</body>
</html>



