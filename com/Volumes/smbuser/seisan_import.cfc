<cfcomponent>
	<cfheader name="Access-Control-Allow-Origin" value="*" />
	<cfsetting showDebugOutput="No">
	<cffunction name="insSeisanTorihiki" access="remote" returnFormat="plain">
		
		<!--- 
			------------------------------------------------------------------------------------------
			form.dataがデータ(カンマ区切りのリスト)、URLDecode(form.name)が日時などの情報、form.memberがmember_id、form.shopがshop_id 
			------------------------------------------------------------------------------------------			
		--->

		<cfset rcv_log = "取引精算データ受信:">
		<cfif IsDefined("form.member") and form.member neq "">
			<cfset rcv_log = rcv_log & URLDecode(form.member)>
		</cfif>
		<cfset rq_data = GetHttpRequestData()>
		<cfset rq_data.content = URLDecode(rq_data.content)>			
		<cfquery datasource="#application.dsn#" name="qTakeLog">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	"#rcv_log#"
			   	)
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qTakeLog2">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	SUBSTRING("#URLDecode(rq_data.content)#",1,4500)
			   	)
		</cfquery>

			
		<!--- 下から送られてくるデータ --->
		<cfset data_list = URLDecode(form.data)>
		<!--- 行数カウント --->
		<cfset cnt = 0>

        <cfquery name="qGetOffSet" datasource="#application.dsn#">
            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,m_time_zone.utc_offset
              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
             WHERE member_id = '#URLDecode(form.member)#'
        </cfquery>

        <cfset today = qGetOffSet.today>
        <cfset utc_offset = qGetOffSet.utc_offset>
		
		<!--- ループ開始 --->
		<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
			<cfset cnt = #cnt# + 1>
			<cftransaction>
				<!--- 配列に変換 --->
				<cfset arr_data = Listtoarray(data, ",", true)>
				<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
					<!--- エラーが出た場合、そのレジの最初にロールバックするため、セーブポイント名をレジIDに設定 --->
					<cfset savepoint = #trim(arr_data[3])#>
					
					<cftry>
						<cfquery datasource="#application.dsn#" name="qGetSeisanTorihiki">
							select regi_id from t_seisan_torihiki where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#'
						</cfquery>
							<!--- ロールバック --->
							<cfcatch type="Database">
								
			                    	<!--- ログ取得 --->
				                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
									<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "レジIDの検索中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" & #Chr(10)#>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
										</cfif>
																
									<cfcontinue>												
							</cfcatch>												
					</cftry>	
					
					
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
							<cfif #qGetSeisanTorihiki.RecordCount# LT 1>
								<cftry>
									<cfquery datasource="#application.dsn#" name="insSeisanTorihiki">
										INSERT INTO t_seisan_torihiki  
														( 
														member_id,
														shop_id,														
														sales_date,
														regi_id,
														<cfif #arr_data[4]# neq "">total_gross_sales_include_tax,</cfif>
														<cfif #arr_data[5]# neq "">product_total_sales,</cfif>
														<cfif #arr_data[6]# neq "">product_sales,</cfif>
														<cfif #arr_data[7]# neq "">total_include_tax,</cfif>
														<cfif #arr_data[8]# neq "">total_tax,</cfif>
														<cfif #arr_data[9]# neq "">sales_qty,</cfif>
														<cfif #arr_data[10]# neq "">sales_customer,</cfif>
														<cfif #arr_data[11]# neq "">product_minus_amount,</cfif>
														<cfif #arr_data[12]# neq "">price_discount_amount,</cfif>
															
														<cfif #arr_data[13]# neq "">price_discount_qty,</cfif>
														<cfif #arr_data[14]# neq "">percent_discount_qty,</cfif>
														<cfif #arr_data[15]# neq "">percent_discount_amount,</cfif>
														<cfif #arr_data[16]# neq "">total_net_sales_without_tax,</cfif>
														<cfif #arr_data[17]# neq "">include_tax_sales,</cfif>
														<cfif #arr_data[18]# neq "">include_tax_amount,</cfif>
														<cfif #arr_data[19]# neq "">include_tax_times,</cfif>
														<cfif #arr_data[20]# neq "">total_include_tax_times,</cfif>
														<cfif #arr_data[21]# neq "">total_tax_times,</cfif>
														<cfif #arr_data[22]# neq "">total_qty,</cfif>
														<cfif #arr_data[23]# neq "">total_customer,</cfif>
														<cfif #arr_data[24]# neq "">cash_amount,</cfif>
														<cfif #arr_data[25]# neq "">cash_times,</cfif>
														<cfif #arr_data[26]# neq "">except_cash_amount,</cfif>
														<cfif #arr_data[27]# neq "">except_cash_times,</cfif>
														<cfif #arr_data[28]# neq "">cash_balance,</cfif>
														<cfif #arr_data[29]# neq "">ten_thousand_number,</cfif>
														<cfif #arr_data[30]# neq "">credit_amount,</cfif>
														<cfif #arr_data[31]# neq "">credit_times,</cfif>
														<cfif #arr_data[32]# neq "">regi_minus_amount,</cfif>
														<cfif #arr_data[33]# neq "">regi_minus_times,</cfif>
														<cfif #arr_data[34]# neq "">cancel_amount,</cfif>
														<cfif #arr_data[35]# neq "">cancel_times,</cfif>
														<cfif #arr_data[36]# neq "">lump_cancel_amount,</cfif>
														<cfif #arr_data[37]# neq "">lump_cancel_times,</cfif>
														<cfif #arr_data[38]# neq "">point_amount,</cfif>
														<cfif #arr_data[39]# neq "">point_times,</cfif>
														<cfif #arr_data[40]# neq "">shopping_point,</cfif>
														<cfif #arr_data[41]# neq "">coupon_issue_amount,</cfif>
														<cfif #arr_data[42]# neq "">coupon_issue_times,</cfif>
														<cfif #arr_data[43]# neq "">service_point_amount,</cfif>
														<cfif #arr_data[44]# neq "">service_point_times,</cfif>
														<cfif #arr_data[45]# neq "">plus_point_correct_amount,</cfif>
														<cfif #arr_data[46]# neq "">plus_point_correct_times,</cfif>
														<cfif #arr_data[47]# neq "">revenue_stamp_issue_times,</cfif>
														<cfif #arr_data[48]# neq "">training_mode_amount,</cfif>
														<cfif #arr_data[49]# neq "">subtotal_discount_amount,</cfif>
														<cfif #arr_data[50]# neq "">subtotal_discount_times,</cfif>
														<cfif #arr_data[51]# neq "">price_discount_times,</cfif>
														<cfif #arr_data[52]# neq "">percent_discount_times,</cfif>
														<cfif #arr_data[53]# neq "">return_qty,</cfif>
														<cfif #arr_data[54]# neq "">return_amount_include_tax,</cfif>
														<cfif #arr_data[55]# neq "">return_times,</cfif>
														<cfif #arr_data[56]# neq "">in_amount,</cfif>
														<cfif #arr_data[57]# neq "">out_amount,</cfif>
														<cfif #arr_data[58]# neq "">receipt_times0,</cfif>
														<cfif #arr_data[59]# neq "">receipt_times1,</cfif>
														<cfif #arr_data[60]# neq "">receipt_times2,</cfif>
														<cfif #arr_data[61]# neq "">receipt_times3,</cfif>									
														<cfif #arr_data[62]# neq "">receipt_times4,</cfif>
														<cfif #arr_data[63]# neq "">receipt_times5,</cfif>
														<cfif #arr_data[64]# neq "">receipt_times6,</cfif>
														<cfif #arr_data[65]# neq "">receipt_times7,</cfif>
														<cfif #arr_data[66]# neq "">receipt_times8,</cfif>
														<cfif #arr_data[67]# neq "">receipt_times9,</cfif>
														<cfif #arr_data[68]# neq "">receipt_times10,</cfif>
															
														<cfif #arr_data[69]# neq "">receipt_amount0,</cfif>
														<cfif #arr_data[70]# neq "">receipt_amount1,</cfif>
														<cfif #arr_data[71]# neq "">receipt_amount2,</cfif>
														<cfif #arr_data[72]# neq "">receipt_amount3,</cfif>
														<cfif #arr_data[73]# neq "">receipt_amount4,</cfif>
														<cfif #arr_data[74]# neq "">receipt_amount5,</cfif>
														<cfif #arr_data[75]# neq "">receipt_amount6,</cfif>
														<cfif #arr_data[76]# neq "">receipt_amount7,</cfif>
														<cfif #arr_data[77]# neq "">receipt_amount8,</cfif>
														<cfif #arr_data[78]# neq "">receipt_amount9,</cfif>													
														<cfif #arr_data[79]# neq "">receipt_amount10,</cfif>
														<cfif #arr_data[80]# neq "">change_amount,</cfif>	
														<cfif #arr_data[81]# neq "">gift_cert_change_amount,</cfif>
														<cfif #arr_data[82]# neq "">gift_cert_no_change_amount,</cfif>
														<cfif #arr_data[83]# neq "">return_amount_without_tax,</cfif>
														<cfif #arr_data[84]# neq "">return_amount_tax,</cfif>													
														<cfif #arr_data[85]# neq "">disposal_qty,</cfif>
														<cfif #arr_data[86]# neq "">disposal_cost,</cfif>
														<cfif #arr_data[87]# neq "">cost,</cfif>
														<cfif #arr_data[88]# neq "">profit_amount,</cfif>
														<cfif #arr_data[89]# neq "">total_gross_sales_without_tax,</cfif>									
														<cfif #arr_data[90]# neq "">total_net_sales_include_tax,</cfif>
														<cfif #arr_data[91]# neq "">open_change_total,</cfif>
														<cfif #arr_data[92]# neq "">open_change_10000,</cfif>									
														<cfif #arr_data[93]# neq "">open_change_5000,</cfif>
														<cfif #arr_data[94]# neq "">open_change_2000,</cfif>
														<cfif #arr_data[95]# neq "">open_change_1000,</cfif>
														<cfif #arr_data[96]# neq "">open_change_500,</cfif>
														<cfif #arr_data[97]# neq "">open_change_100,</cfif>
														<cfif #arr_data[98]# neq "">open_change_50,</cfif>
														<cfif #arr_data[99]# neq "">open_change_10,</cfif>
														<cfif #arr_data[100]# neq "">open_change_5,</cfif>
														<cfif #arr_data[101]# neq "">open_change_1,</cfif>
														<cfif #arr_data[102]# neq "">close_change_total,</cfif>
														<cfif #arr_data[103]# neq "">close_change_10000,</cfif>				  
														<cfif #arr_data[104]# neq "">close_change_5000,</cfif>
														<cfif #arr_data[105]# neq "">close_change_2000,</cfif>
														<cfif #arr_data[106]# neq "">close_change_1000,</cfif>
														<cfif #arr_data[107]# neq "">close_change_500,</cfif>
														<cfif #arr_data[108]# neq "">close_change_100,</cfif>
														<cfif #arr_data[109]# neq "">close_change_50,</cfif>
														<cfif #arr_data[110]# neq "">close_change_10,</cfif>				  
														<cfif #arr_data[111]# neq "">close_change_5,</cfif>
														<cfif #arr_data[112]# neq "">close_change_1,</cfif>
														<cfif #arr_data[113]# neq "">close_amount1,</cfif>
														<cfif #arr_data[114]# neq "">close_amount2,</cfif>
														<cfif #arr_data[115]# neq "">close_amount3,</cfif>
														<cfif #arr_data[116]# neq "">close_amount4,</cfif>				  
														<cfif #arr_data[117]# neq "">close_amount5,</cfif>
														<cfif #arr_data[118]# neq "">close_amount6,</cfif>
														<cfif #arr_data[119]# neq "">close_amount7,</cfif>
														<cfif #arr_data[120]# neq "">close_amount8,</cfif>
														<cfif #arr_data[121]# neq "">close_amount9,</cfif>
														<cfif #arr_data[122]# neq "">close_amount10,</cfif>				  
														<cfif #arr_data[123]# neq "">difference_amount0,</cfif>
														<cfif #arr_data[124]# neq "">difference_amount1,</cfif>
														<cfif #arr_data[125]# neq "">difference_amount2,</cfif>
														<cfif #arr_data[126]# neq "">difference_amount3,</cfif>
														<cfif #arr_data[127]# neq "">difference_amount4,</cfif>
														<cfif #arr_data[128]# neq "">difference_amount5,</cfif>				  
														<cfif #arr_data[129]# neq "">difference_amount6,</cfif>
														<cfif #arr_data[130]# neq "">difference_amount7,</cfif>
														<cfif #arr_data[131]# neq "">difference_amount8,</cfif>
														<cfif #arr_data[132]# neq "">difference_amount9,</cfif>
														<cfif #arr_data[133]# neq "">difference_amount10,</cfif>
														<cfif ArrayIsDefined(arr_data, 134) and arr_data[134] neq "">group_num,</cfif>
														<cfif ArrayIsDefined(arr_data, 135) and arr_data[135] neq "">total_service_charge,</cfif>
														create_date,
														create_person
					  									) 
					  									value
														(
														'#URLDecode(form.member)#',
														'#trim(arr_data[1])#',
														'#trim(arr_data[2])#', 
														'#trim(arr_data[3])#',
														<cfif arr_data[4] neq "">#trim(arr_data[4])#,</cfif>
														<cfif arr_data[5] neq "">#trim(arr_data[5])#,</cfif>
														<cfif arr_data[6] neq "">#trim(arr_data[6])#,</cfif>
														<cfif arr_data[7] neq "">#trim(arr_data[7])#,</cfif>
														<cfif arr_data[8] neq "">#trim(arr_data[8])#,</cfif>
														<cfif arr_data[9] neq "">#trim(arr_data[9])#,</cfif>
														<cfif arr_data[10] neq "">#trim(arr_data[10])#,</cfif>
														<cfif arr_data[11] neq "">#trim(arr_data[11])#,</cfif>
														<cfif arr_data[12] neq "">#trim(arr_data[12])#,</cfif>
														<cfif arr_data[13] neq "">#trim(arr_data[13])#,</cfif>
														<cfif arr_data[14] neq "">#trim(arr_data[14])#,</cfif>
														<cfif arr_data[15] neq "">#trim(arr_data[15])#,</cfif>
														<cfif arr_data[16] neq "">#trim(arr_data[16])#,</cfif>
														<cfif arr_data[17] neq "">#trim(arr_data[17])#,</cfif>
														<cfif arr_data[18] neq "">#trim(arr_data[18])#,</cfif>
														<cfif arr_data[19] neq "">#trim(arr_data[19])#,</cfif>
														<cfif arr_data[20] neq "">#trim(arr_data[20])#,</cfif>
														<cfif arr_data[21] neq "">#trim(arr_data[21])#,</cfif>
														<cfif arr_data[22] neq "">#trim(arr_data[22])#,</cfif>
														<cfif arr_data[23] neq "">#trim(arr_data[23])#,</cfif>
														<cfif arr_data[24] neq "">#trim(arr_data[24])#,</cfif>
														<cfif arr_data[25] neq "">#trim(arr_data[25])#,</cfif>
														<cfif arr_data[26] neq "">#trim(arr_data[26])#,</cfif>
														<cfif arr_data[27] neq "">#trim(arr_data[27])#,</cfif>
														<cfif arr_data[28] neq "">#trim(arr_data[28])#,</cfif>
														<cfif arr_data[29] neq "">#trim(arr_data[29])#,</cfif>
														<cfif arr_data[30] neq "">#trim(arr_data[30])#,</cfif>
														<cfif arr_data[31] neq "">#trim(arr_data[31])#,</cfif>
														<cfif arr_data[32] neq "">#trim(arr_data[32])#,</cfif>
														<cfif arr_data[33] neq "">#trim(arr_data[33])#,</cfif>
														<cfif arr_data[34] neq "">#trim(arr_data[34])#,</cfif>
														<cfif arr_data[35] neq "">#trim(arr_data[35])#,</cfif>
														<cfif arr_data[36] neq "">#trim(arr_data[36])#,</cfif>
														<cfif arr_data[37] neq "">#trim(arr_data[37])#,</cfif>
														<cfif arr_data[38] neq "">#trim(arr_data[38])#,</cfif>
														<cfif arr_data[39] neq "">#trim(arr_data[39])#,</cfif>
														<cfif arr_data[40] neq "">#trim(arr_data[40])#,</cfif>
														<cfif arr_data[41] neq "">#trim(arr_data[41])#,</cfif>
														<cfif arr_data[42] neq "">#trim(arr_data[42])#,</cfif>
														<cfif arr_data[43] neq "">#trim(arr_data[43])#,</cfif>
														<cfif arr_data[44] neq "">#trim(arr_data[44])#,</cfif>
														<cfif arr_data[45] neq "">#trim(arr_data[45])#,</cfif>
														<cfif arr_data[46] neq "">#trim(arr_data[46])#,</cfif>
														<cfif arr_data[47] neq "">#trim(arr_data[47])#,</cfif>
														<cfif arr_data[48] neq "">#trim(arr_data[48])#,</cfif>
														<cfif arr_data[49] neq "">#trim(arr_data[49])#,</cfif>
														<cfif arr_data[50] neq "">#trim(arr_data[50])#,</cfif>
														<cfif arr_data[51] neq "">#trim(arr_data[51])#,</cfif>
														<cfif arr_data[52] neq "">#trim(arr_data[52])#,</cfif>
														<cfif arr_data[53] neq "">#trim(arr_data[53])#,</cfif>
														<cfif arr_data[54] neq "">#trim(arr_data[54])#,</cfif>
														<cfif arr_data[55] neq "">#trim(arr_data[55])#,</cfif>
														<cfif arr_data[56] neq "">#trim(arr_data[56])#,</cfif>
														<cfif arr_data[57] neq "">#trim(arr_data[57])#,</cfif>
														<cfif arr_data[58] neq "">#trim(arr_data[58])#,</cfif>
														<cfif arr_data[59] neq "">#trim(arr_data[59])#,</cfif>
														<cfif arr_data[60] neq "">#trim(arr_data[60])#,</cfif>
														<cfif arr_data[61] neq "">#trim(arr_data[61])#,</cfif>									
														<cfif arr_data[62] neq "">#trim(arr_data[62])#,</cfif>
														<cfif arr_data[63] neq "">#trim(arr_data[63])#,</cfif>
														<cfif arr_data[64] neq "">#trim(arr_data[64])#,</cfif>
														<cfif arr_data[65] neq "">#trim(arr_data[65])#,</cfif>
														<cfif arr_data[66] neq "">#trim(arr_data[66])#,</cfif>
														<cfif arr_data[67] neq "">#trim(arr_data[67])#,</cfif>
												
														<cfif arr_data[68] neq "">#trim(arr_data[68])#,</cfif>
														<cfif arr_data[69] neq "">#trim(arr_data[69])#,</cfif>
														<cfif arr_data[70] neq "">#trim(arr_data[70])#,</cfif>
														<cfif arr_data[71] neq "">#trim(arr_data[71])#,</cfif>
														<cfif arr_data[72] neq "">#trim(arr_data[72])#,</cfif>
														<cfif arr_data[73] neq "">#trim(arr_data[73])#,</cfif>
														<cfif arr_data[74] neq "">#trim(arr_data[74])#,</cfif>
														<cfif arr_data[75] neq "">#trim(arr_data[75])#,</cfif>
														<cfif arr_data[76] neq "">#trim(arr_data[76])#,</cfif>
														<cfif arr_data[77] neq "">#trim(arr_data[77])#,</cfif>
														<cfif arr_data[78] neq "">#trim(arr_data[78])#,</cfif>
														<cfif arr_data[79] neq "">#trim(arr_data[79])#,</cfif>
														<cfif arr_data[80] neq "">#trim(arr_data[80])#,</cfif>
														<cfif arr_data[81] neq "">#trim(arr_data[81])#,</cfif>
														<cfif arr_data[82] neq "">#trim(arr_data[82])#,</cfif>
														<cfif arr_data[83] neq "">#trim(arr_data[83])#,</cfif>
														<cfif arr_data[84] neq "">#trim(arr_data[84])#,</cfif>
														<cfif arr_data[85] neq "">#trim(arr_data[85])#,</cfif>
														<cfif arr_data[86] neq "">#trim(arr_data[86])#,</cfif>
														<cfif arr_data[87] neq "">#trim(arr_data[87])#,</cfif>
														<cfif arr_data[88] neq "">#trim(arr_data[88])#,</cfif>									
														<cfif arr_data[89] neq "">#trim(arr_data[89])#,</cfif>
														<cfif arr_data[90] neq "">#trim(arr_data[90])#,</cfif>
														<cfif arr_data[91] neq "">#trim(arr_data[91])#,</cfif>									
														<cfif arr_data[92] neq "">#trim(arr_data[92])#,</cfif>
														<cfif arr_data[93] neq "">#trim(arr_data[93])#,</cfif>
														<cfif arr_data[94] neq "">#trim(arr_data[94])#,</cfif>
														<cfif arr_data[95] neq "">#trim(arr_data[95])#,</cfif>
													
														<cfif arr_data[96] neq "">#trim(arr_data[96])#,</cfif>
														<cfif arr_data[97] neq "">#trim(arr_data[97])#,</cfif>
														<cfif arr_data[98] neq "">#trim(arr_data[98])#,</cfif>
														<cfif arr_data[99] neq "">#trim(arr_data[99])#,</cfif>
														<cfif arr_data[100] neq "">#trim(arr_data[100])#,</cfif>
														<cfif arr_data[101] neq "">#trim(arr_data[101])#,</cfif>
														<cfif arr_data[102] neq "">#trim(arr_data[102])#,</cfif>
														<cfif arr_data[103] neq "">#trim(arr_data[103])#,</cfif>				  
														<cfif arr_data[104] neq "">#trim(arr_data[104])#,</cfif>
														<cfif arr_data[105] neq "">#trim(arr_data[105])#,</cfif>
														<cfif arr_data[106] neq "">#trim(arr_data[106])#,</cfif>
														<cfif arr_data[107] neq "">#trim(arr_data[107])#,</cfif>
														<cfif arr_data[108] neq "">#trim(arr_data[108])#,</cfif>
														<cfif arr_data[109] neq "">#trim(arr_data[109])#,</cfif>
														<cfif arr_data[110] neq "">#trim(arr_data[110])#,</cfif>				  
														<cfif arr_data[111] neq "">#trim(arr_data[111])#,</cfif>
														<cfif arr_data[112] neq "">#trim(arr_data[112])#,</cfif>
														<cfif arr_data[113] neq "">#trim(arr_data[113])#,</cfif>
														<cfif arr_data[114] neq "">#trim(arr_data[114])#,</cfif>
														<cfif arr_data[115] neq "">#trim(arr_data[115])#,</cfif>
														<cfif arr_data[116] neq "">#trim(arr_data[116])#,</cfif>				  
														<cfif arr_data[117] neq "">#trim(arr_data[117])#,</cfif>
														<cfif arr_data[118] neq "">#trim(arr_data[118])#,</cfif>
														<cfif arr_data[119] neq "">#trim(arr_data[119])#,</cfif>
														<cfif arr_data[120] neq "">#trim(arr_data[120])#,</cfif>
														<cfif arr_data[121] neq "">#trim(arr_data[121])#,</cfif>
														<cfif arr_data[122] neq "">#trim(arr_data[122])#,</cfif>				  
														<cfif arr_data[123] neq "">#trim(arr_data[123])#,</cfif>
														<cfif arr_data[124] neq "">#trim(arr_data[124])#,</cfif>
														<cfif arr_data[125] neq "">#trim(arr_data[125])#,</cfif>
														<cfif arr_data[126] neq "">#trim(arr_data[126])#,</cfif>
														<cfif arr_data[127] neq "">#trim(arr_data[127])#,</cfif>
														<cfif arr_data[128] neq "">#trim(arr_data[128])#,</cfif>				  
														<cfif arr_data[129] neq "">#trim(arr_data[129])#,</cfif>
														<cfif arr_data[130] neq "">#trim(arr_data[130])#,</cfif>
														<cfif arr_data[131] neq "">#trim(arr_data[131])#,</cfif>
														<cfif arr_data[132] neq "">#trim(arr_data[132])#,</cfif>
														<cfif arr_data[133] neq "">#trim(arr_data[133])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 134) and arr_data[134] neq "">#trim(arr_data[134])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 135) and arr_data[135] neq "">#trim(arr_data[135])#,</cfif>															
														ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
														'AUTO'				
														)
									</cfquery>
																	
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "取引精算データの取り込み中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#"  & " " &  "データ:#data#" & " " & "SQL文:#cfcatch.Sql#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
												 --->
												<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in inserting t_seisan_torihiki " & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#"  & " " &  "データ:#data#" & " " & "SQL文:#cfcatch.Sql#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
													</cfif>
																			
												<cfcontinue>												
										</cfcatch>
								</cftry>
							<cfelse>
								<cftry>									
								<cfquery datasource="#application.dsn#" name="updSeisanTorihiki">
									update t_seisan_torihiki
									   set
											member_id                     = '#URLDecode(form.member)#',														
											sales_date                    = '#trim(arr_data[2])#',
											regi_id                       = '#trim(arr_data[3])#',
											total_gross_sales_include_tax = <cfif #arr_data[4]# neq "">#arr_data[4]#,<cfelse>0,</cfif>
											product_total_sales           = <cfif #arr_data[5]# neq "">#arr_data[5]#,<cfelse>0,</cfif>
											product_sales                 = <cfif #arr_data[6]# neq "">#arr_data[6]#,<cfelse>0,</cfif>
											total_include_tax             = <cfif #arr_data[7]# neq "">#arr_data[7]#,<cfelse>0,</cfif>
											total_tax                     = <cfif #arr_data[8]# neq "">#arr_data[8]#,<cfelse>0,</cfif>
											sales_qty                     = <cfif #arr_data[9]# neq "">#arr_data[9]#,<cfelse>0,</cfif>
											sales_customer                = <cfif #arr_data[10]# neq "">#arr_data[10]#,<cfelse>0,</cfif>
											product_minus_amount          = <cfif #arr_data[11]# neq "">#arr_data[11]#,<cfelse>0,</cfif>
											price_discount_amount         = <cfif #arr_data[12]# neq "">#arr_data[12]#,<cfelse>0,</cfif>
											
											price_discount_qty            = <cfif #arr_data[13]# neq "">#arr_data[13]#,<cfelse>0,</cfif>
											percent_discount_qty          = <cfif #arr_data[14]# neq "">#arr_data[14]#,<cfelse>0,</cfif>
											percent_discount_amount       = <cfif #arr_data[15]# neq "">#arr_data[15]#,<cfelse>0,</cfif>
											total_net_sales_without_tax   = <cfif #arr_data[16]# neq "">#arr_data[16]#,<cfelse>0,</cfif>
											include_tax_sales             = <cfif #arr_data[17]# neq "">#arr_data[17]#,<cfelse>0,</cfif>
											include_tax_amount            = <cfif #arr_data[18]# neq "">#arr_data[18]#,<cfelse>0,</cfif>
											include_tax_times             = <cfif #arr_data[19]# neq "">#arr_data[19]#,<cfelse>0,</cfif>
											total_include_tax_times       = <cfif #arr_data[20]# neq "">#arr_data[20]#,<cfelse>0,</cfif>
											total_tax_times               = <cfif #arr_data[21]# neq "">#arr_data[21]#,<cfelse>0,</cfif>
											total_qty                     = <cfif #arr_data[22]# neq "">#arr_data[22]#,<cfelse>0,</cfif>
											total_customer                = <cfif #arr_data[23]# neq "">#arr_data[23]#,<cfelse>0,</cfif>
											cash_amount                   = <cfif #arr_data[24]# neq "">#arr_data[24]#,<cfelse>0,</cfif>
											cash_times                    = <cfif #arr_data[25]# neq "">#arr_data[25]#,<cfelse>0,</cfif>
											except_cash_amount            = <cfif #arr_data[26]# neq "">#arr_data[26]#,<cfelse>0,</cfif>
											except_cash_times             = <cfif #arr_data[27]# neq "">#arr_data[27]#,<cfelse>0,</cfif>
											cash_balance                  = <cfif #arr_data[28]# neq "">#arr_data[28]#,<cfelse>0,</cfif>
											ten_thousand_number           = <cfif #arr_data[29]# neq "">#arr_data[29]#,<cfelse>0,</cfif>
											credit_amount                 = <cfif #arr_data[30]# neq "">#arr_data[30]#,<cfelse>0,</cfif>
											credit_times                  = <cfif #arr_data[31]# neq "">#arr_data[31]#,<cfelse>0,</cfif>
											regi_minus_amount             = <cfif #arr_data[32]# neq "">#arr_data[32]#,<cfelse>0,</cfif>
											regi_minus_times              = <cfif #arr_data[33]# neq "">#arr_data[33]#,<cfelse>0,</cfif>
											cancel_amount                 = <cfif #arr_data[34]# neq "">#arr_data[34]#,<cfelse>0,</cfif>
											cancel_times                  = <cfif #arr_data[35]# neq "">#arr_data[35]#,<cfelse>0,</cfif>
											lump_cancel_amount            = <cfif #arr_data[36]# neq "">#arr_data[36]#,<cfelse>0,</cfif>
											lump_cancel_times             = <cfif #arr_data[37]# neq "">#arr_data[37]#,<cfelse>0,</cfif>
											point_amount                  = <cfif #arr_data[38]# neq "">#arr_data[38]#,<cfelse>0,</cfif>
											point_times                   = <cfif #arr_data[39]# neq "">#arr_data[39]#,<cfelse>0,</cfif>
											shopping_point                = <cfif #arr_data[40]# neq "">#arr_data[40]#,<cfelse>0,</cfif>
											coupon_issue_amount           = <cfif #arr_data[41]# neq "">#arr_data[41]#,<cfelse>0,</cfif>
											coupon_issue_times            = <cfif #arr_data[42]# neq "">#arr_data[42]#,<cfelse>0,</cfif>
											service_point_amount          = <cfif #arr_data[43]# neq "">#arr_data[43]#,<cfelse>0,</cfif>
											service_point_times           = <cfif #arr_data[44]# neq "">#arr_data[44]#,<cfelse>0,</cfif>
											plus_point_correct_amount     = <cfif #arr_data[45]# neq "">#arr_data[45]#,<cfelse>0,</cfif>
											plus_point_correct_times      = <cfif #arr_data[46]# neq "">#arr_data[46]#,<cfelse>0,</cfif>
											revenue_stamp_issue_times     = <cfif #arr_data[47]# neq "">#arr_data[47]#,<cfelse>0,</cfif>
											training_mode_amount          = <cfif #arr_data[48]# neq "">#arr_data[48]#,<cfelse>0,</cfif>
											subtotal_discount_amount      = <cfif #arr_data[49]# neq "">#arr_data[49]#,<cfelse>0,</cfif>
											subtotal_discount_times       = <cfif #arr_data[50]# neq "">#arr_data[50]#,<cfelse>0,</cfif>
											price_discount_times          = <cfif #arr_data[51]# neq "">#arr_data[51]#,<cfelse>0,</cfif>
											percent_discount_times        = <cfif #arr_data[52]# neq "">#arr_data[52]#,<cfelse>0,</cfif>
											return_qty                    = <cfif #arr_data[53]# neq "">#arr_data[53]#,<cfelse>0,</cfif>
											return_amount_include_tax     = <cfif #arr_data[54]# neq "">#arr_data[54]#,<cfelse>0,</cfif>
											return_times                  = <cfif #arr_data[55]# neq "">#arr_data[55]#,<cfelse>0,</cfif>
											in_amount                     = <cfif #arr_data[56]# neq "">#arr_data[56]#,<cfelse>0,</cfif>
											out_amount                    = <cfif #arr_data[57]# neq "">#arr_data[57]#,<cfelse>0,</cfif>
											receipt_times0                = <cfif #arr_data[58]# neq "">#arr_data[58]#,<cfelse>0,</cfif>
											receipt_times1                = <cfif #arr_data[59]# neq "">#arr_data[59]#,<cfelse>0,</cfif>
											receipt_times2                = <cfif #arr_data[60]# neq "">#arr_data[60]#,<cfelse>0,</cfif>
											receipt_times3                = <cfif #arr_data[61]# neq "">#arr_data[61]#,<cfelse>0,</cfif>									
											receipt_times4                = <cfif #arr_data[62]# neq "">#arr_data[62]#,<cfelse>0,</cfif>
											receipt_times5                = <cfif #arr_data[63]# neq "">#arr_data[63]#,<cfelse>0,</cfif>
											receipt_times6                = <cfif #arr_data[64]# neq "">#arr_data[64]#,<cfelse>0,</cfif>
											receipt_times7                = <cfif #arr_data[65]# neq "">#arr_data[65]#,<cfelse>0,</cfif>
											receipt_times8                = <cfif #arr_data[66]# neq "">#arr_data[66]#,<cfelse>0,</cfif>
											receipt_times9                = <cfif #arr_data[67]# neq "">#arr_data[67]#,<cfelse>0,</cfif>
											receipt_times10               = <cfif #arr_data[68]# neq "">#arr_data[68]#,<cfelse>0,</cfif>
											
											receipt_amount0               = <cfif #arr_data[69]# neq "">#arr_data[69]#,<cfelse>0,</cfif>
											receipt_amount1               = <cfif #arr_data[70]# neq "">#arr_data[70]#,<cfelse>0,</cfif>
											receipt_amount2               = <cfif #arr_data[71]# neq "">#arr_data[71]#,<cfelse>0,</cfif>
											receipt_amount3               = <cfif #arr_data[72]# neq "">#arr_data[72]#,<cfelse>0,</cfif>
											receipt_amount4               = <cfif #arr_data[73]# neq "">#arr_data[73]#,<cfelse>0,</cfif>
											receipt_amount5               = <cfif #arr_data[74]# neq "">#arr_data[74]#,<cfelse>0,</cfif>
											receipt_amount6               = <cfif #arr_data[75]# neq "">#arr_data[75]#,<cfelse>0,</cfif>
											receipt_amount7               = <cfif #arr_data[76]# neq "">#arr_data[76]#,<cfelse>0,</cfif>
											receipt_amount8               = <cfif #arr_data[77]# neq "">#arr_data[77]#,<cfelse>0,</cfif>
											receipt_amount9               = <cfif #arr_data[78]# neq "">#arr_data[78]#,<cfelse>0,</cfif>													
											receipt_amount10              = <cfif #arr_data[79]# neq "">#arr_data[79]#,<cfelse>0,</cfif>
											change_amount                 = <cfif #arr_data[80]# neq "">#arr_data[80]#,<cfelse>0,</cfif>	
											gift_cert_change_amount       = <cfif #arr_data[81]# neq "">#arr_data[81]#,<cfelse>0,</cfif>
											gift_cert_no_change_amount    = <cfif #arr_data[82]# neq "">#arr_data[82]#,<cfelse>0,</cfif>
											return_amount_without_tax     = <cfif #arr_data[83]# neq "">#arr_data[83]#,<cfelse>0,</cfif>
											return_amount_tax             = <cfif #arr_data[84]# neq "">#arr_data[84]#,<cfelse>0,</cfif>													
											disposal_qty                  = <cfif #arr_data[85]# neq "">#arr_data[85]#,<cfelse>0,</cfif>
											disposal_cost                 = <cfif #arr_data[86]# neq "">#arr_data[86]#,<cfelse>0,</cfif>
											cost                          = <cfif #arr_data[87]# neq "">#arr_data[87]#,<cfelse>0,</cfif>
											profit_amount                 = <cfif #arr_data[88]# neq "">#arr_data[88]#,<cfelse>0,</cfif>
											total_gross_sales_without_tax = <cfif #arr_data[89]# neq "">#arr_data[89]#,<cfelse>0,</cfif>									
											total_net_sales_include_tax   = <cfif #arr_data[90]# neq "">#arr_data[90]#,<cfelse>0,</cfif>
											open_change_total             = <cfif #arr_data[91]# neq "">#arr_data[91]#,<cfelse>0,</cfif>
											open_change_10000             = <cfif #arr_data[92]# neq "">#arr_data[92]#,<cfelse>0,</cfif>									
											open_change_5000              = <cfif #arr_data[93]# neq "">#arr_data[93]#,<cfelse>0,</cfif>
											open_change_2000              = <cfif #arr_data[94]# neq "">#arr_data[94]#,<cfelse>0,</cfif>
											open_change_1000              = <cfif #arr_data[95]# neq "">#arr_data[95]#,<cfelse>0,</cfif>
											open_change_500               = <cfif #arr_data[96]# neq "">#arr_data[96]#,<cfelse>0,</cfif>
											open_change_100               = <cfif #arr_data[97]# neq "">#arr_data[97]#,<cfelse>0,</cfif>
											open_change_50                = <cfif #arr_data[98]# neq "">#arr_data[98]#,<cfelse>0,</cfif>
											open_change_10                = <cfif #arr_data[99]# neq "">#arr_data[99]#,<cfelse>0,</cfif>
											open_change_5                 = <cfif #arr_data[100]# neq "">#arr_data[100]#,<cfelse>0,</cfif>
											open_change_1                 = <cfif #arr_data[101]# neq "">#arr_data[101]#,<cfelse>0,</cfif>
											close_change_total            = <cfif #arr_data[102]# neq "">#arr_data[102]#,<cfelse>0,</cfif>
											close_change_10000            = <cfif #arr_data[103]# neq "">#arr_data[103]#,<cfelse>0,</cfif>				  
											close_change_5000             = <cfif #arr_data[104]# neq "">#arr_data[104]#,<cfelse>0,</cfif>
											close_change_2000             = <cfif #arr_data[105]# neq "">#arr_data[105]#,<cfelse>0,</cfif>
											close_change_1000             = <cfif #arr_data[106]# neq "">#arr_data[106]#,<cfelse>0,</cfif>
											close_change_500              = <cfif #arr_data[107]# neq "">#arr_data[107]#,<cfelse>0,</cfif>
											open_change_100               = <cfif #arr_data[108]# neq "">#arr_data[108]#,<cfelse>0,</cfif>
											close_change_50               = <cfif #arr_data[109]# neq "">#arr_data[109]#,<cfelse>0,</cfif>
											close_change_10               = <cfif #arr_data[110]# neq "">#arr_data[110]#,<cfelse>0,</cfif>				  
											close_change_5                = <cfif #arr_data[111]# neq "">#arr_data[111]#,<cfelse>0,</cfif>
											close_change_1                = <cfif #arr_data[112]# neq "">#arr_data[112]#,<cfelse>0,</cfif>
											close_amount1                 = <cfif #arr_data[113]# neq "">#arr_data[113]#,<cfelse>0,</cfif>
											close_amount2                 = <cfif #arr_data[114]# neq "">#arr_data[114]#,<cfelse>0,</cfif>
											close_amount3                 = <cfif #arr_data[115]# neq "">#arr_data[115]#,<cfelse>0,</cfif>
											close_amount4                 = <cfif #arr_data[116]# neq "">#arr_data[116]#,<cfelse>0,</cfif>				  
											close_amount5                 = <cfif #arr_data[117]# neq "">#arr_data[117]#,<cfelse>0,</cfif>
											close_amount6                 = <cfif #arr_data[118]# neq "">#arr_data[118]#,<cfelse>0,</cfif>
											close_amount7                 = <cfif #arr_data[119]# neq "">#arr_data[119]#,<cfelse>0,</cfif>
											close_amount8                 = <cfif #arr_data[120]# neq "">#arr_data[120]#,<cfelse>0,</cfif>
											close_amount9                 = <cfif #arr_data[121]# neq "">#arr_data[121]#,<cfelse>0,</cfif>
											close_amount10                = <cfif #arr_data[122]# neq "">#arr_data[122]#,<cfelse>0,</cfif>				  
											difference_amount0            = <cfif #arr_data[123]# neq "">#arr_data[123]#,<cfelse>0,</cfif>
											difference_amount1            = <cfif #arr_data[124]# neq "">#arr_data[124]#,<cfelse>0,</cfif>
											difference_amount2            = <cfif #arr_data[125]# neq "">#arr_data[125]#,<cfelse>0,</cfif>
											difference_amount3            = <cfif #arr_data[126]# neq "">#arr_data[126]#,<cfelse>0,</cfif>
											difference_amount4            = <cfif #arr_data[127]# neq "">#arr_data[127]#,<cfelse>0,</cfif>
											difference_amount5            = <cfif #arr_data[128]# neq "">#arr_data[128]#,<cfelse>0,</cfif>				  
											difference_amount6            = <cfif #arr_data[129]# neq "">#arr_data[129]#,<cfelse>0,</cfif>
											difference_amount7            = <cfif #arr_data[130]# neq "">#arr_data[130]#,<cfelse>0,</cfif>
											difference_amount8            = <cfif #arr_data[131]# neq "">#arr_data[131]#,<cfelse>0,</cfif>
											difference_amount9            = <cfif #arr_data[132]# neq "">#arr_data[132]#,<cfelse>0,</cfif>
											difference_amount10           = <cfif #arr_data[133]# neq "">#arr_data[133]#,<cfelse>0,</cfif>
											group_num                     = <cfif ArrayIsDefined(arr_data, 134) and arr_data[134] neq "">#arr_data[134]#,<cfelse>0,</cfif>
											total_service_charge          = <cfif ArrayIsDefined(arr_data, 135) and arr_data[135] neq "">#arr_data[135]#,<cfelse>0,</cfif>
											modify_date                   = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
											modify_person                 = 'AUTO'
									where  member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and sales_date = '#trim(arr_data[2])#' and regi_id = '#trim(arr_data[3])#'									
								</cfquery>
								<!--- 精算データの更新 --->	
																	
											<!--- ロールバック --->
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
													<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "取引精算データの更新中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQL文:#cfcatch.Sql#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
												 	 --->
												 	 <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in updating t_seisan_torihiki " & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQL文:#cfcatch.Sql#" & " " &  "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
														<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
														</cfif>
																				
													<cfcontinue>												
											</cfcatch>
								</cftry>								
								
							</cfif>
						</cftransaction>			
		</cfloop>
			
		<cfreturn 1 >
	</cffunction>
	
	
	<!--- 部門精算 --->
	<cffunction name="insSeisanDivision" access="remote" returnFormat="plain">
		<cfset rcv_log = "部門精算データ受信:">
		<cfif IsDefined("form.member") and form.member neq "">
			<cfset rcv_log = rcv_log & URLDecode(form.member)>
		</cfif>
		<cfset rq_data = GetHttpRequestData()>
		<cfset rq_data.content = URLDecode(rq_data.content)>			
		<cfquery datasource="#application.dsn#" name="qTakeLog">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	"#rcv_log#"
			   	)
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qTakeLog2">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	SUBSTRING("#URLDecode(rq_data.content)#",1,4500)
			   	)
		</cfquery>				
		<!--- 下から送られてくるデータ --->
		<cfset data_list = URLDecode(form.data)>
		<!--- 行数カウント --->
		<cfset cnt = 0>

		<!--- <cfset today = now()> --->
        <cfquery name="qGetOffSet" datasource="#application.dsn#">
            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,m_time_zone.utc_offset
              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
             WHERE member_id = '#URLDecode(form.member)#'
        </cfquery>

        <cfset today = qGetOffSet.today>
        <cfset utc_offset = qGetOffSet.utc_offset>

		<!--- ループ開始 --->
		<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
			<cfset cnt = #cnt# + 1>
			<cftransaction>
				<!--- 配列に変換 --->
				<cfset arr_data = Listtoarray(#data#, ",", true)>
				<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
					<!--- エラーが出た場合、そのレジの最初にロールバックするため、セーブポイント名をレジIDに設定 --->
					<cfset savepoint = #trim(arr_data[3])#>
					<cftry>
						<cfquery datasource="#application.dsn#" name="qGetSeisanDivision">
							select regi_id from t_seisan_division where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and division_id = '#trim(arr_data[4])#'
						</cfquery>
							<!--- ロールバック --->
							<cfcatch type="Database">
			                    	<!--- ログ取得 --->
				                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
									<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "レジIDの検索中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
										</cfif>
																
									<cfcontinue>												
							</cfcatch>												
					</cftry>					
					
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
							<cfif #qGetSeisanDivision.RecordCount# LT 1>
									<cftry>
										<cfquery datasource="#application.dsn#" name="insSeisanDivision">
											INSERT INTO t_seisan_division  
															( 
															member_id,
															shop_id,														
															sales_date,
															regi_id,
															division_id,													
															<cfif #arr_data[5]# neq "">sales_customer,</cfif>
															<cfif #arr_data[6]# neq "">sales_qty,</cfif>													
															<cfif #arr_data[7]# neq "">gross_sales_amount_include_tax,</cfif>
															<cfif #arr_data[8]# neq "">nonstandard_sales_qty,</cfif>
															<cfif #arr_data[9]# neq "">nonstandard_sales_amount,</cfif>
															<cfif #arr_data[10]# neq "">loss_qty,</cfif>
															<cfif #arr_data[11]# neq "">loss_amount,</cfif>
															<cfif #arr_data[12]# neq "">price_discount_qty,</cfif>														
															<cfif #arr_data[13]# neq "">price_discount_amount,</cfif>
															<cfif #arr_data[14]# neq "">price_discount_qty2,</cfif>
															<cfif #arr_data[15]# neq "">price_discount_amount2,</cfif>
															<cfif #arr_data[16]# neq "">disposal_qty,</cfif>
															<cfif #arr_data[17]# neq "">disposal_cost,</cfif>
															<cfif #arr_data[18]# neq "">return_qty,</cfif>
															<cfif #arr_data[19]# neq "">return_amount_include_tax,</cfif>
															<cfif #arr_data[20]# neq "">profit_amount,</cfif>
															<cfif #arr_data[21]# neq "">nonstandard_profit_amount,</cfif>
															<cfif #arr_data[22]# neq "">gross_sales_amount_without_tax,</cfif>
															<cfif #arr_data[23]# neq "">gross_sales_amount_tax,</cfif>
															<cfif #arr_data[24]# neq "">return_amount_without_tax,</cfif>
															<cfif #arr_data[25]# neq "">return_amount_tax,</cfif>
															<cfif #arr_data[26]# neq "">cost,</cfif>
															<cfif #arr_data[27]# neq "">net_sales_amount_without_tax,</cfif>
															<cfif #arr_data[28]# neq "">net_sales_amount_include_tax,</cfif>
															<cfif #arr_data[29]# neq "">net_sales_amount_tax,</cfif>
															create_date,
															create_person
						  									) 
						  									value
															(
															'#URLDecode(form.member)#',
															'#trim(arr_data[1])#',
															'#trim(arr_data[2])#',
															'#trim(arr_data[3])#',
															'#trim(arr_data[4])#',
															<cfif #arr_data[5]# neq "">#trim(arr_data[5])#,</cfif>
															<cfif #arr_data[6]# neq "">#trim(arr_data[6])#,</cfif>
															<cfif #arr_data[7]# neq "">#trim(arr_data[7])#,</cfif>
															<cfif #arr_data[8]# neq "">#trim(arr_data[8])#,</cfif>
															<cfif #arr_data[9]# neq "">#trim(arr_data[9])#,</cfif>
															<cfif #arr_data[10]# neq "">#trim(arr_data[10])#,</cfif>
															<cfif #arr_data[11]# neq "">#trim(arr_data[11])#,</cfif>
															<cfif #arr_data[12]# neq "">#trim(arr_data[12])#,</cfif>
															<cfif #arr_data[13]# neq "">#trim(arr_data[13])#,</cfif>
															<cfif #arr_data[14]# neq "">#trim(arr_data[14])#,</cfif>
															<cfif #arr_data[15]# neq "">#trim(arr_data[15])#,</cfif>
															<cfif #arr_data[16]# neq "">#trim(arr_data[16])#,</cfif>
															<cfif #arr_data[17]# neq "">#trim(arr_data[17])#,</cfif>
															<cfif #arr_data[18]# neq "">#trim(arr_data[18])#,</cfif>
															<cfif #arr_data[19]# neq "">#trim(arr_data[19])#,</cfif>
															<cfif #arr_data[20]# neq "">#trim(arr_data[20])#,</cfif>
															<cfif #arr_data[21]# neq "">#trim(arr_data[21])#,</cfif>
															<cfif #arr_data[22]# neq "">#trim(arr_data[22])#,</cfif>
															<cfif #arr_data[23]# neq "">#trim(arr_data[23])#,</cfif>
															<cfif #arr_data[24]# neq "">#trim(arr_data[24])#,</cfif>
															<cfif #arr_data[25]# neq "">#trim(arr_data[25])#,</cfif>
															<cfif #arr_data[26]# neq "">#trim(arr_data[26])#,</cfif>
															<cfif #arr_data[27]# neq "">#trim(arr_data[27])#,</cfif>
															<cfif #arr_data[28]# neq "">#trim(arr_data[28])#,</cfif>
															<cfif #arr_data[29]# neq "">#trim(arr_data[29])#,</cfif>					
															ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
															'AUTO'				
															)
										</cfquery>
	
										<!--- 精算データの取り込み --->

																	
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "部門精算データの取り込み中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" &  #Chr(10)#>
												 --->
												<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in inserting t_seisan_division" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
												
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
													</cfif>
																			
												<cfcontinue>												
										</cfcatch>
								</cftry>
							<cfelse>
									<cftry>
										<cfquery datasource="#application.dsn#" name="updSeisanDivision">						
											
											update  t_seisan_division
											   set
													member_id                      = '#URLDecode(form.member)#',														
													sales_date                     = '#trim(arr_data[2])#',
													regi_id                        = '#trim(arr_data[3])#',
													division_id                    = '#trim(arr_data[4])#',
													sales_customer                 = <cfif #arr_data[5]# neq "">#arr_data[5]#,<cfelse>null,</cfif>
													sales_qty                      = <cfif #arr_data[6]# neq "">#arr_data[6]#,<cfelse>null,</cfif>
													gross_sales_amount_include_tax = <cfif #arr_data[7]# neq "">#arr_data[7]#,<cfelse>null,</cfif>
													nonstandard_sales_qty          = <cfif #arr_data[8]# neq "">#arr_data[8]#,<cfelse>null,</cfif>
													nonstandard_sales_amount       = <cfif #arr_data[9]# neq "">#arr_data[9]#,<cfelse>null,</cfif>
													loss_qty                       = <cfif #arr_data[10]# neq "">#arr_data[10]#,<cfelse>null,</cfif>
													loss_amount                    = <cfif #arr_data[11]# neq "">#arr_data[11]#,<cfelse>null,</cfif>
													price_discount_qty             = <cfif #arr_data[12]# neq "">#arr_data[12]#,<cfelse>null,</cfif>
													
													price_discount_amount          = <cfif #arr_data[13]# neq "">#arr_data[13]#,<cfelse>null,</cfif>
													price_discount_qty2            = <cfif #arr_data[14]# neq "">#arr_data[14]#,<cfelse>null,</cfif>
													price_discount_amount2         = <cfif #arr_data[15]# neq "">#arr_data[15]#,<cfelse>null,</cfif>
													disposal_qty                   = <cfif #arr_data[16]# neq "">#arr_data[16]#,<cfelse>0,</cfif>
													disposal_cost                  = <cfif #arr_data[17]# neq "">#arr_data[17]#,<cfelse>0,</cfif>
													return_qty                     = <cfif #arr_data[18]# neq "">#arr_data[18]#,<cfelse>null,</cfif>
													return_amount_include_tax      = <cfif #arr_data[19]# neq "">#arr_data[19]#,<cfelse>null,</cfif>
													profit_amount                  = <cfif #arr_data[20]# neq "">#arr_data[20]#,<cfelse>null,</cfif>
													nonstandard_profit_amount      = <cfif #arr_data[21]# neq "">#arr_data[21]#,<cfelse>null,</cfif>
													gross_sales_amount_without_tax = <cfif #arr_data[22]# neq "">#arr_data[22]#,<cfelse>null,</cfif>
													gross_sales_amount_tax         = <cfif #arr_data[23]# neq "">#arr_data[23]#,<cfelse>null,</cfif>
													return_amount_without_tax      = <cfif #arr_data[24]# neq "">#arr_data[24]#,<cfelse>null,</cfif>
													return_amount_tax              = <cfif #arr_data[25]# neq "">#arr_data[25]#,<cfelse>null,</cfif>
													cost                           = <cfif #arr_data[26]# neq "">#arr_data[26]#,<cfelse>null,</cfif>
													net_sales_amount_without_tax   = <cfif #arr_data[27]# neq "">#arr_data[27]#,<cfelse>null,</cfif>
													net_sales_amount_include_tax   = <cfif #arr_data[28]# neq "">#arr_data[28]#,<cfelse>null,</cfif>
													net_sales_amount_tax           = <cfif #arr_data[29]# neq "">#arr_data[29]#,<cfelse>null,</cfif>
													modify_date                    = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
													modify_person                  = 'AUTO'
												  where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and	sales_date = '#trim(arr_data[2])#' and regi_id = '#trim(arr_data[3])#' and division_id = '#trim(arr_data[4])#'
												   								
										</cfquery>
										<!--- 精算データの更新 --->	
																		
											<!--- ロールバック --->
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
													<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in updating t_seisan_division" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" &   #Chr(10)#>
													
														<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
														</cfif>																				
													<cfcontinue>												
											</cfcatch>
									</cftry>								
								
							</cfif>
						</cftransaction>			
		</cfloop>
			
		<cfreturn 1 >
	</cffunction>

	<!--- ライン精算 --->
	<cffunction name="insSeisanLine" access="remote" returnFormat="plain">
		<cfset rcv_log = "ライン精算データ受信:">
		<cfif IsDefined("form.member") and form.member neq "">
			<cfset rcv_log = rcv_log & URLDecode(form.member)>
		</cfif>
		<cfset rq_data = GetHttpRequestData()>
		<cfset rq_data.content = URLDecode(rq_data.content)>			
		<cfquery datasource="#application.dsn#" name="qTakeLog">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	"#rcv_log#"
			   	)
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qTakeLog2">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	SUBSTRING("#URLDecode(rq_data.content)#",1,4500)
			   	)
		</cfquery>				
		<!--- 下から送られてくるデータ --->
		<cfset data_list = URLDecode(form.data)>
		<!--- 行数カウント --->
		<cfset cnt = 0>

		<!--- <cfset today = now()> --->
        <cfquery name="qGetOffSet" datasource="#application.dsn#">
            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,m_time_zone.utc_offset
              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
             WHERE member_id = '#URLDecode(form.member)#'
        </cfquery>

        <cfset today = qGetOffSet.today>
        <cfset utc_offset = qGetOffSet.utc_offset>

		<!--- ループ開始 --->
		<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
			<cfset cnt = #cnt# + 1>
			<cftransaction>
				<!--- 配列に変換 --->
				<cfset arr_data = Listtoarray(#data#, ",", true)>
				<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
					<!--- エラーが出た場合、そのレジの最初にロールバックするため、セーブポイント名をレジIDに設定 --->
					<cfset savepoint = #trim(arr_data[3])#>
					
					<cftry>
						<cfquery datasource="#application.dsn#" name="qGetSeisanLine">
							select regi_id from t_seisan_line where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and line_id = '#trim(arr_data[4])#'
						</cfquery>
							<!--- ロールバック --->
							<cfcatch type="Database">
								
			                    	<!--- ログ取得 --->
				                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
									<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "レジIDの検索中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
										</cfif>
																
									<cfcontinue>												
							</cfcatch>												
					</cftry>	
					
					
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
							<cfif #qGetSeisanLine.RecordCount# LT 1>
								<cftry>
									<cfquery datasource="#application.dsn#" name="insSeisanLine">
										INSERT INTO t_seisan_line  
														( 
														member_id,
														shop_id,														
														sales_date,
														regi_id,
														line_id,
														<cfif #arr_data[5]# neq "">division_id,</cfif>
														<cfif #arr_data[6]# neq "">depart_id,</cfif>
														<cfif #arr_data[7]# neq "">sales_customer,</cfif>
														<cfif #arr_data[8]# neq "">sales_qty,</cfif>
														<cfif #arr_data[9]# neq "">gross_sales_amount_include_tax,</cfif>
														<cfif #arr_data[10]# neq "">nonstandard_sales_qty,</cfif>
														<cfif #arr_data[11]# neq "">nonstandard_sales_amount,</cfif>
														<cfif #arr_data[12]# neq "">loss_qty,</cfif>															
														<cfif #arr_data[13]# neq "">loss_amount,</cfif>
														<cfif #arr_data[14]# neq "">price_discount_qty,</cfif>
														<cfif #arr_data[15]# neq "">price_discount_amount,</cfif>
														<cfif #arr_data[16]# neq "">price_discount_qty2,</cfif>
														<cfif #arr_data[17]# neq "">price_discount_amount2,</cfif>
														<cfif #arr_data[18]# neq "">disposal_qty,</cfif>
														<cfif #arr_data[19]# neq "">disposal_cost,</cfif>
														<cfif #arr_data[20]# neq "">return_qty,</cfif>
														<cfif #arr_data[21]# neq "">return_amount_include_tax,</cfif>
														<cfif #arr_data[22]# neq "">profit_amount,</cfif>
														<cfif #arr_data[23]# neq "">nonstandard_profit_amount,</cfif>
														<cfif #arr_data[24]# neq "">gross_sales_amount_without_tax,</cfif>
														<cfif #arr_data[25]# neq "">gross_sales_amount_tax,</cfif>
														<cfif #arr_data[26]# neq "">return_amount_without_tax,</cfif>
														<cfif #arr_data[27]# neq "">return_amount_tax,</cfif>
														<cfif #arr_data[28]# neq "">cost,</cfif>
														<cfif #arr_data[29]# neq "">net_sales_amount_without_tax,</cfif>
														<cfif #arr_data[30]# neq "">net_sales_amount_include_tax,</cfif>
														<cfif #arr_data[31]# neq "">net_sales_amount_tax,</cfif>
														create_date,
														create_person
					  									) 
					  									value
														(
														'#URLDecode(form.member)#',
														'#trim(arr_data[1])#',
														'#trim(arr_data[2])#',
														'#trim(arr_data[3])#',
														'#trim(arr_data[4])#',
														<cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',</cfif>
														<cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',</cfif>
														<cfif #arr_data[7]# neq "">#trim(arr_data[7])#,</cfif>
														<cfif #arr_data[8]# neq "">#trim(arr_data[8])#,</cfif>
														<cfif #arr_data[9]# neq "">#trim(arr_data[9])#,</cfif>
														<cfif #arr_data[10]# neq "">#trim(arr_data[10])#,</cfif>
														<cfif #arr_data[11]# neq "">#trim(arr_data[11])#,</cfif>
														<cfif #arr_data[12]# neq "">#trim(arr_data[12])#,</cfif>
														<cfif #arr_data[13]# neq "">#trim(arr_data[13])#,</cfif>
														<cfif #arr_data[14]# neq "">#trim(arr_data[14])#,</cfif>
														<cfif #arr_data[15]# neq "">#trim(arr_data[15])#,</cfif>
														<cfif #arr_data[16]# neq "">#trim(arr_data[16])#,</cfif>
														<cfif #arr_data[17]# neq "">#trim(arr_data[17])#,</cfif>
														<cfif #arr_data[18]# neq "">#trim(arr_data[18])#,</cfif>
														<cfif #arr_data[19]# neq "">#trim(arr_data[19])#,</cfif>
														<cfif #arr_data[20]# neq "">#trim(arr_data[20])#,</cfif>
														<cfif #arr_data[21]# neq "">#trim(arr_data[21])#,</cfif>
														<cfif #arr_data[22]# neq "">#trim(arr_data[22])#,</cfif>
														<cfif #arr_data[23]# neq "">#trim(arr_data[23])#,</cfif>
														<cfif #arr_data[24]# neq "">#trim(arr_data[24])#,</cfif>
														<cfif #arr_data[25]# neq "">#trim(arr_data[25])#,</cfif>
														<cfif #arr_data[26]# neq "">#trim(arr_data[26])#,</cfif>
														<cfif #arr_data[27]# neq "">#trim(arr_data[27])#,</cfif>
														<cfif #arr_data[28]# neq "">#trim(arr_data[28])#,</cfif>
														<cfif #arr_data[29]# neq "">#trim(arr_data[29])#,</cfif>
														<cfif #arr_data[30]# neq "">#trim(arr_data[30])#,</cfif>
														<cfif #arr_data[31]# neq "">#trim(arr_data[31])#,</cfif>
														ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
														'AUTO'				
														)
									</cfquery>
																	
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "ライン精算データの取り込み中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" &  #Chr(10)#>
												 --->
												<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in inserting t_seisan_line" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
													</cfif>
																			
												<cfcontinue>												
										</cfcatch>
								</cftry>
							<cfelse>
								<cftry>									
									<cfquery datasource="#application.dsn#" name="updSeisanLine">
										update t_seisan_line
										   set
												member_id                      = '#URLDecode(form.member)#',														
												sales_date                     = '#trim(arr_data[2])#',
												regi_id                        = '#trim(arr_data[3])#',
												line_id                        = '#trim(arr_data[4])#',
												division_id                    = <cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',<cfelse>null,</cfif>
												depart_id                      = <cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',<cfelse>null,</cfif>
												sales_customer                 = <cfif #arr_data[7]# neq "">#arr_data[7]#,<cfelse>null,</cfif>
												sales_qty                      = <cfif #arr_data[8]# neq "">#arr_data[8]#,<cfelse>null,</cfif>
												gross_sales_amount_include_tax = <cfif #arr_data[9]# neq "">#arr_data[9]#,<cfelse>null,</cfif>
												nonstandard_sales_qty          = <cfif #arr_data[10]# neq "">#arr_data[10]#,<cfelse>null,</cfif>
												nonstandard_sales_amount       = <cfif #arr_data[11]# neq "">#arr_data[11]#,<cfelse>null,</cfif>
												loss_qty                       = <cfif #arr_data[12]# neq "">#arr_data[12]#,<cfelse>null,</cfif>
												
												loss_amount                    = <cfif #arr_data[13]# neq "">#arr_data[13]#,<cfelse>null,</cfif>
												price_discount_qty             = <cfif #arr_data[14]# neq "">#arr_data[14]#,<cfelse>null,</cfif>
												price_discount_amount          = <cfif #arr_data[15]# neq "">#arr_data[15]#,<cfelse>null,</cfif>
												price_discount_qty2            = <cfif #arr_data[16]# neq "">#arr_data[16]#,<cfelse>null,</cfif>
												price_discount_amount2         = <cfif #arr_data[17]# neq "">#arr_data[17]#,<cfelse>null,</cfif>
												disposal_qty                   = <cfif #arr_data[18]# neq "">#arr_data[18]#,<cfelse>0,</cfif>
												disposal_cost                  = <cfif #arr_data[19]# neq "">#arr_data[19]#,<cfelse>0,</cfif>
												return_qty                     = <cfif #arr_data[20]# neq "">#arr_data[20]#,<cfelse>null,</cfif>
												return_amount_include_tax      = <cfif #arr_data[21]# neq "">#arr_data[21]#,<cfelse>null,</cfif>
												profit_amount                  = <cfif #arr_data[22]# neq "">#arr_data[22]#,<cfelse>null,</cfif>
												nonstandard_profit_amount      = <cfif #arr_data[23]# neq "">#arr_data[23]#,<cfelse>null,</cfif>
												gross_sales_amount_without_tax = <cfif #arr_data[24]# neq "">#arr_data[24]#,<cfelse>null,</cfif>
												gross_sales_amount_tax         = <cfif #arr_data[25]# neq "">#arr_data[25]#,<cfelse>null,</cfif>
												return_amount_without_tax      = <cfif #arr_data[26]# neq "">#arr_data[26]#,<cfelse>null,</cfif>
												return_amount_tax              = <cfif #arr_data[27]# neq "">#arr_data[27]#,<cfelse>null,</cfif>
												cost                           = <cfif #arr_data[28]# neq "">#arr_data[28]#,<cfelse>null,</cfif>
												net_sales_amount_without_tax   = <cfif #arr_data[29]# neq "">#arr_data[29]#,<cfelse>null,</cfif>
												net_sales_amount_include_tax   = <cfif #arr_data[30]# neq "">#arr_data[30]#,<cfelse>null,</cfif>
												net_sales_amount_tax           = <cfif #arr_data[31]# neq "">#arr_data[31]#,<cfelse>null,</cfif>																									
												modify_date                    = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
												modify_person                  = 'AUTO'
												  where member_id = '#URLDecode(form.member)#'and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and line_id = '#trim(arr_data[4])#'									
									</cfquery>
									<!--- 精算データの更新 --->	
																	
											<!--- ロールバック --->
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
													<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "ライン精算データの更新中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" &  #Chr(10)#>
													 --->
													<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in updating t_seisan_line" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>

													 	<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
														</cfif>
																				
													<cfcontinue>												
											</cfcatch>
								</cftry>								
								
							</cfif>
						</cftransaction>			
		</cfloop>
			
		<cfreturn 1 >
	</cffunction>

	<!--- クラス精算 --->
	<cffunction name="insSeisanClass" access="remote" returnFormat="plain">
		<cfset rcv_log = "クラス精算データ受信:">
		<cfif IsDefined("form.member") and form.member neq "">
			<cfset rcv_log = rcv_log & URLDecode(form.member)>
		</cfif>
		<cfset rq_data = GetHttpRequestData()>
		<cfset rq_data.content = URLDecode(rq_data.content)>			
		<cfquery datasource="#application.dsn#" name="qTakeLog">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	"#rcv_log#"
			   	)
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qTakeLog2">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	SUBSTRING("#URLDecode(rq_data.content)#",1,4500)
			   	)
		</cfquery>				
		<!--- 下から送られてくるデータ --->
		<cfset data_list = URLDecode(form.data)>
		<!--- 行数カウント --->
		<cfset cnt = 0>

		<!--- <cfset today = now()> --->

        <cfquery name="qGetOffSet" datasource="#application.dsn#">
            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,m_time_zone.utc_offset
              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
             WHERE member_id = '#URLDecode(form.member)#'
        </cfquery>

        <cfset today = qGetOffSet.today>
        <cfset utc_offset = qGetOffSet.utc_offset>
		
		<!--- ループ開始 --->
		<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
			<cfset cnt = #cnt# + 1>
			<cftransaction>
				<!--- 配列に変換 --->
				<cfset arr_data = Listtoarray(#data#, ",", true)>
				<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
					<!--- エラーが出た場合、そのレジの最初にロールバックするため、セーブポイント名をレジIDに設定 --->
					<cfset savepoint = #trim(arr_data[3])#>
					
					<cftry>
						<cfquery datasource="#application.dsn#" name="qGetSeisanClass">
							select regi_id from t_seisan_class where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and class_id = '#trim(arr_data[4])#'
						</cfquery>
							<!--- ロールバック --->
							<cfcatch type="Database">
								
			                    	<!--- ログ取得 --->
				                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
									<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "レジIDの検索中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" & " " &  "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
										</cfif>
																
									<cfcontinue>												
							</cfcatch>												
					</cftry>	
					
					
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
							<cfif #qGetSeisanClass.RecordCount# LT 1>
								<cftry>
									<cfquery datasource="#application.dsn#" name="insSeisanClass">
										INSERT INTO t_seisan_class  
														( 
														member_id,
														shop_id,														
														sales_date,
														regi_id,
														class_id,
														<cfif #arr_data[5]# neq "">division_id,</cfif>
														<cfif #arr_data[6]# neq "">depart_id,</cfif>
														<cfif #arr_data[7]# neq "">line_id,</cfif>
														<cfif #arr_data[8]# neq "">sales_customer,</cfif>
														<cfif #arr_data[9]# neq "">sales_qty,</cfif>
														<cfif #arr_data[10]# neq "">gross_sales_amount_include_tax,</cfif>
														<cfif #arr_data[11]# neq "">nonstandard_sales_qty,</cfif>
														<cfif #arr_data[12]# neq "">nonstandard_sales_amount,</cfif>															
														<cfif #arr_data[13]# neq "">loss_qty,</cfif>
														<cfif #arr_data[14]# neq "">loss_amount,</cfif>
														<cfif #arr_data[15]# neq "">price_discount_qty,</cfif>
														<cfif #arr_data[16]# neq "">price_discount_amount,</cfif>
														<cfif #arr_data[17]# neq "">price_discount_qty2,</cfif>
														<cfif #arr_data[18]# neq "">price_discount_amount2,</cfif>
														<cfif #arr_data[19]# neq "">disposal_qty,</cfif>
														<cfif #arr_data[20]# neq "">disposal_cost,</cfif>
														<cfif #arr_data[21]# neq "">return_qty,</cfif>
														<cfif #arr_data[22]# neq "">return_amount_include_tax,</cfif>
														<cfif #arr_data[23]# neq "">profit_amount,</cfif>
														<cfif #arr_data[24]# neq "">nonstandard_profit_amount,</cfif>
														<cfif #arr_data[25]# neq "">fp_status,</cfif>
														<cfif #arr_data[26]# neq "">gross_sales_amount_without_tax,</cfif>
														<cfif #arr_data[27]# neq "">gross_sales_amount_tax,</cfif>
														<cfif #arr_data[28]# neq "">return_amount_without_tax,</cfif>
														<cfif #arr_data[29]# neq "">return_amount_tax,</cfif>
														<cfif #arr_data[30]# neq "">cost,</cfif>
														<cfif #arr_data[31]# neq "">net_sales_amount_without_tax,</cfif>
														<cfif #arr_data[32]# neq "">net_sales_amount_include_tax,</cfif>
														<cfif #arr_data[33]# neq "">net_sales_amount_tax,</cfif>
														create_date,
														create_person
					  									) 
					  									value
														(
														'#URLDecode(form.member)#',
														'#trim(arr_data[1])#',
														'#trim(arr_data[2])#',
														'#trim(arr_data[3])#',
														'#trim(arr_data[4])#',
														<cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',</cfif>
														<cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',</cfif>
														<cfif #arr_data[7]# neq "">'#trim(arr_data[7])#',</cfif>
														<cfif #arr_data[8]# neq "">#trim(arr_data[8])#,</cfif>
														<cfif #arr_data[9]# neq "">#trim(arr_data[9])#,</cfif>
														<cfif #arr_data[10]# neq "">#trim(arr_data[10])#,</cfif>
														<cfif #arr_data[11]# neq "">#trim(arr_data[11])#,</cfif>
														<cfif #arr_data[12]# neq "">#trim(arr_data[12])#,</cfif>
														<cfif #arr_data[13]# neq "">#trim(arr_data[13])#,</cfif>
														<cfif #arr_data[14]# neq "">#trim(arr_data[14])#,</cfif>
														<cfif #arr_data[15]# neq "">#trim(arr_data[15])#,</cfif>
														<cfif #arr_data[16]# neq "">#trim(arr_data[16])#,</cfif>
														<cfif #arr_data[17]# neq "">#trim(arr_data[17])#,</cfif>
														<cfif #arr_data[18]# neq "">#trim(arr_data[18])#,</cfif>
														<cfif #arr_data[19]# neq "">#trim(arr_data[19])#,</cfif>
														<cfif #arr_data[20]# neq "">#trim(arr_data[20])#,</cfif>
														<cfif #arr_data[21]# neq "">#trim(arr_data[21])#,</cfif>
														<cfif #arr_data[22]# neq "">#trim(arr_data[22])#,</cfif>
														<cfif #arr_data[23]# neq "">#trim(arr_data[23])#,</cfif>
														<cfif #arr_data[24]# neq "">#trim(arr_data[24])#,</cfif>
														<cfif #arr_data[25]# neq "">#trim(arr_data[25])#,</cfif>
														<cfif #arr_data[26]# neq "">#trim(arr_data[26])#,</cfif>
														<cfif #arr_data[27]# neq "">#trim(arr_data[27])#,</cfif>
														<cfif #arr_data[28]# neq "">#trim(arr_data[28])#,</cfif>
														<cfif #arr_data[29]# neq "">#trim(arr_data[29])#,</cfif>
														<cfif #arr_data[30]# neq "">#trim(arr_data[30])#,</cfif>
														<cfif #arr_data[31]# neq "">#trim(arr_data[31])#,</cfif>
														<cfif #arr_data[32]# neq "">#trim(arr_data[32])#,</cfif>
														<cfif #arr_data[33]# neq "">#trim(arr_data[33])#,</cfif>
														ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
														'AUTO'				
														)
									</cfquery>
																	
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "精算データの取り込み中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " &  "データ:#data#" &  #Chr(10)#>
												 --->
												<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in inserting t_seisan_class" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
													</cfif>
																			
												<cfcontinue>												
										</cfcatch>
								</cftry>
							<cfelse>
								<cftry>									
									<cfquery datasource="#application.dsn#" name="updSeisanClass">
										update t_seisan_class
										   set
												member_id                      = '#URLDecode(form.member)#',														
												sales_date                     = '#trim(arr_data[2])#',
												regi_id                        = '#trim(arr_data[3])#',
												class_id                       = '#trim(arr_data[4])#',
												division_id                    = <cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',<cfelse>null,</cfif>
												depart_id                      = <cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',<cfelse>null,</cfif>
												line_id                        = <cfif #arr_data[7]# neq "">#trim(arr_data[7])#,<cfelse>null,</cfif>
												sales_customer                 = <cfif #arr_data[8]# neq "">#arr_data[8]#,<cfelse>null,</cfif>
												sales_qty                      = <cfif #arr_data[9]# neq "">#arr_data[9]#,<cfelse>null,</cfif>
												gross_sales_amount_include_tax = <cfif #arr_data[10]# neq "">#arr_data[10]#,<cfelse>null,</cfif>
												nonstandard_sales_qty          = <cfif #arr_data[11]# neq "">#arr_data[11]#,<cfelse>null,</cfif>
												nonstandard_sales_amount       = <cfif #arr_data[12]# neq "">#arr_data[12]#,<cfelse>null,</cfif>
												
												loss_qty                       = <cfif #arr_data[13]# neq "">#arr_data[13]#,<cfelse>null,</cfif>
												loss_amount                    = <cfif #arr_data[14]# neq "">#arr_data[14]#,<cfelse>null,</cfif>
												price_discount_qty             = <cfif #arr_data[15]# neq "">#arr_data[15]#,<cfelse>null,</cfif>
												price_discount_amount          = <cfif #arr_data[16]# neq "">#arr_data[16]#,<cfelse>null,</cfif>
												price_discount_qty2            = <cfif #arr_data[17]# neq "">#arr_data[17]#,<cfelse>null,</cfif>
												price_discount_amount2         = <cfif #arr_data[18]# neq "">#arr_data[18]#,<cfelse>null,</cfif>
												disposal_qty                   = <cfif #arr_data[19]# neq "">#arr_data[19]#,<cfelse>0,</cfif>
												disposal_cost                  = <cfif #arr_data[20]# neq "">#arr_data[20]#,<cfelse>0,</cfif>
												return_qty                     = <cfif #arr_data[21]# neq "">#arr_data[21]#,<cfelse>null,</cfif>
												return_amount_include_tax      = <cfif #arr_data[22]# neq "">#arr_data[22]#,<cfelse>null,</cfif>
												profit_amount                  = <cfif #arr_data[23]# neq "">#arr_data[23]#,<cfelse>null,</cfif>
												nonstandard_profit_amount      = <cfif #arr_data[24]# neq "">#arr_data[24]#,<cfelse>null,</cfif>
												fp_status                      = <cfif #arr_data[25]# neq "">#arr_data[25]#,<cfelse>null,</cfif>
												gross_sales_amount_without_tax = <cfif #arr_data[26]# neq "">#arr_data[26]#,<cfelse>null,</cfif>
												gross_sales_amount_tax         = <cfif #arr_data[27]# neq "">#arr_data[27]#,<cfelse>null,</cfif>
												return_amount_without_tax      = <cfif #arr_data[28]# neq "">#arr_data[28]#,<cfelse>null,</cfif>
												return_amount_tax              = <cfif #arr_data[29]# neq "">#arr_data[29]#,<cfelse>null,</cfif>
												cost                           = <cfif #arr_data[30]# neq "">#arr_data[30]#,<cfelse>null,</cfif>
												net_sales_amount_without_tax   = <cfif #arr_data[31]# neq "">#arr_data[31]#,<cfelse>null,</cfif>
												net_sales_amount_include_tax   = <cfif #arr_data[32]# neq "">#arr_data[32]#,<cfelse>null,</cfif>
												net_sales_amount_tax           = <cfif #arr_data[33]# neq "">#arr_data[33]#,<cfelse>null,</cfif>																										
												modify_date                    = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
												modify_person                  = 'AUTO'	
												  where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and class_id = '#trim(arr_data[4])#'	
														
														
																						
									</cfquery>
									<!--- 精算データの更新 --->	
																	
											<!--- ロールバック --->
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
													<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in updating t_seisan_class" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
													
														<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
														</cfif>
																				
													<cfcontinue>												
											</cfcatch>
								</cftry>								
								
							</cfif>
						</cftransaction>			
		</cfloop>
			
		<cfreturn 1 >
	</cffunction>
	
	
	<!--- 単品精算 --->
	<cffunction name="insSeisanJan" access="remote" returnFormat="plain">
		<cfset rcv_log = "単品精算データ受信:">
		<cfif IsDefined("form.member") and form.member neq "">
			<cfset rcv_log = rcv_log & URLDecode(form.member)>
		</cfif>
		<cfset rq_data = GetHttpRequestData()>
		<cfset rq_data.content = URLDecode(rq_data.content)>			
		<cfquery datasource="#application.dsn#" name="qTakeLog">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	"#rcv_log#"
			   	)
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qTakeLog2">
			 INSERT INTO t_log  
			   (
			   	log_time,
			   	log
			   	)VALUES(
			   	now(),
			   	SUBSTRING("#URLDecode(rq_data.content)#",1,4500)
			   	)
		</cfquery>			
		<!--- 下から送られてくるデータ --->
		<cfset data_list = URLDecode(form.data)>
		<!--- 行数カウント --->
		<cfset cnt = 0>

		<!--- <cfset today = now()> --->

        <cfquery name="qGetOffSet" datasource="#application.dsn#">
            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,m_time_zone.utc_offset
              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
             WHERE member_id = '#URLDecode(form.member)#'
        </cfquery>

        <cfset today = qGetOffSet.today>
        <cfset utc_offset = qGetOffSet.utc_offset>
		
		<!--- ループ開始 --->
		<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
			<cfset cnt = #cnt# + 1>
			<cftransaction>
				<!--- 配列に変換 --->
				<cfset arr_data = Listtoarray(#data#, ",", true)>
				<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
					<!--- エラーが出た場合、そのレジの最初にロールバックするため、セーブポイント名をレジIDに設定 --->
					<cfset savepoint = #trim(arr_data[3])#>
					
					<cftry>
						<cfquery datasource="#application.dsn#" name="qGetSeisanJan">
							select regi_id from t_seisan_jan where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and jan = '#trim(arr_data[4])#'
						</cfquery>
							<!--- ロールバック --->
							<cfcatch type="Database">
								
			                    	<!--- ログ取得 --->
				                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
									<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "レジIDの検索中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " & "jan:#arr_data[4]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
										</cfif>
																
									<cfcontinue>												
							</cfcatch>												
					</cftry>	
					
					
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
							<cfif #qGetSeisanJan.RecordCount# LT 1>
								<cftry>
									<cfquery datasource="#application.dsn#" name="insSeisanJan">
										INSERT INTO t_seisan_jan  
														( 
														member_id,
														shop_id,														
														sales_date,
														regi_id,
														jan,
														<cfif #arr_data[5]# neq "">product_id,</cfif>
														<cfif #arr_data[6]# neq "">product_name,</cfif>
														<cfif #arr_data[7]# neq "">product_name_kana,</cfif>
														<cfif #arr_data[8]# neq "">division_id,</cfif>
														<cfif #arr_data[9]# neq "">depart_id,</cfif>
														<cfif #arr_data[10]# neq "">line_id,</cfif>
														<cfif #arr_data[11]# neq "">class_id,</cfif>
														<cfif #arr_data[12]# neq "">sale_discrimination,</cfif>
															
														<cfif #arr_data[13]# neq "">event_id,</cfif>
														<cfif #arr_data[14]# neq "">mm_id,</cfif>
														<cfif #arr_data[15]# neq "">select_seisan_no,</cfif>
														<cfif #arr_data[16]# neq "">ones_company_id,</cfif>
														<cfif #arr_data[17]# neq "">unit_price_without_tax,</cfif>
														<cfif #arr_data[18]# neq "">unit_price_include_tax,</cfif>
														<cfif #arr_data[19]# neq "">unit_price_tax,</cfif>
														<cfif #arr_data[20]# neq "">sales_customer,</cfif>
														<cfif #arr_data[21]# neq "">sales_qty,</cfif>
														<cfif #arr_data[22]# neq "">gross_sales_amount_include_tax,</cfif>
														<cfif #arr_data[23]# neq "">price_discount_qty,</cfif>
														<cfif #arr_data[24]# neq "">price_discount_amount,</cfif>
														<cfif #arr_data[25]# neq "">price_discount_qty2,</cfif>
														<cfif #arr_data[26]# neq "">price_discount_amount2,</cfif>
														<cfif #arr_data[27]# neq "">mm_qty,</cfif>
														<cfif #arr_data[28]# neq "">mm_price_discount_amount,</cfif>
														<cfif #arr_data[29]# neq "">disposal_qty,</cfif>
														<cfif #arr_data[30]# neq "">disposal_cost,</cfif>
														<cfif #arr_data[31]# neq "">return_qty,</cfif>
														<cfif #arr_data[32]# neq "">return_amount_include_tax,</cfif>
														<cfif #arr_data[33]# neq "">fp_status1,</cfif>
														<cfif #arr_data[34]# neq "">fp_status2,</cfif>
														<cfif #arr_data[35]# neq "">fp_status3,</cfif>
														<cfif #arr_data[36]# neq "">gross_sales_amount_without_tax,</cfif>
														<cfif #arr_data[37]# neq "">gross_sales_amount_tax,</cfif>
														<cfif #arr_data[38]# neq "">return_amount_without_tax,</cfif>
														<cfif #arr_data[39]# neq "">return_amount_tax,</cfif>
														<cfif #arr_data[40]# neq "">supplier_id,</cfif>
														<cfif #arr_data[41]# neq "">unit_cost,</cfif>
														<cfif #arr_data[42]# neq "">cost,</cfif>
														<cfif #arr_data[43]# neq "">profit_amount,</cfif>
														<cfif #arr_data[44]# neq "">net_sales_amount_without_tax,</cfif>
														<cfif #arr_data[45]# neq "">net_sales_amount_include_tax,</cfif>
														<cfif #arr_data[46]# neq "">net_sales_amount_tax,</cfif>
														<!---<cfif #arr_data[47]# neq "">maker_name,</cfif>
														<cfif #arr_data[48]# neq "">standard_name,</cfif>
														<cfif #arr_data[49]# neq "">disposal_unit_cost,</cfif>--->														
														create_date,
														create_person
					  									) 
					  									value
														(
														'#URLDecode(form.member)#',
														'#trim(arr_data[1])#',
														'#trim(arr_data[2])#',
														'#trim(arr_data[3])#',
														'#trim(arr_data[4])#',
														<cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',</cfif>
														<cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',</cfif>
														<cfif #arr_data[7]# neq "">'#trim(arr_data[7])#',</cfif>
														<cfif #arr_data[8]# neq "">'#trim(arr_data[8])#',</cfif>
														<cfif #arr_data[9]# neq "">'#trim(arr_data[9])#',</cfif>
														<cfif #arr_data[10]# neq "">'#trim(arr_data[10])#',</cfif>
														<cfif #arr_data[11]# neq "">'#trim(arr_data[11])#',</cfif>
														<cfif #arr_data[12]# neq "">'#trim(arr_data[12])#',</cfif>
														<cfif #arr_data[13]# neq "">'#trim(arr_data[13])#',</cfif>
														<cfif #arr_data[14]# neq "">'#trim(arr_data[14])#',</cfif>
														<cfif #arr_data[15]# neq "">'#trim(arr_data[15])#',</cfif>
														<cfif #arr_data[16]# neq "">'#trim(arr_data[16])#',</cfif>
														<cfif #arr_data[17]# neq "">#trim(arr_data[17])#,</cfif>
														<cfif #arr_data[18]# neq "">#trim(arr_data[18])#,</cfif>
														<cfif #arr_data[19]# neq "">#trim(arr_data[19])#,</cfif>
														<cfif #arr_data[20]# neq "">#trim(arr_data[20])#,</cfif>
														<cfif #arr_data[21]# neq "">#trim(arr_data[21])#,</cfif>
														<cfif #arr_data[22]# neq "">#trim(arr_data[22])#,</cfif>
														<cfif #arr_data[23]# neq "">#trim(arr_data[23])#,</cfif>
														<cfif #arr_data[24]# neq "">#trim(arr_data[24])#,</cfif>
														<cfif #arr_data[25]# neq "">#trim(arr_data[25])#,</cfif>
														<cfif #arr_data[26]# neq "">#trim(arr_data[26])#,</cfif>
														<cfif #arr_data[27]# neq "">#trim(arr_data[27])#,</cfif>
														<cfif #arr_data[28]# neq "">#trim(arr_data[28])#,</cfif>
														<cfif #arr_data[29]# neq "">#trim(arr_data[29])#,</cfif>
														<cfif #arr_data[30]# neq "">#trim(arr_data[30])#,</cfif>
														<cfif #arr_data[31]# neq "">#trim(arr_data[31])#,</cfif>
														<cfif #arr_data[32]# neq "">#trim(arr_data[32])#,</cfif>
														<cfif #arr_data[33]# neq "">'#trim(arr_data[33])#',</cfif>
														<cfif #arr_data[34]# neq "">'#trim(arr_data[34])#',</cfif>
														<cfif #arr_data[35]# neq "">#trim(arr_data[35])#,</cfif>
														<cfif #arr_data[36]# neq "">#trim(arr_data[36])#,</cfif>
														<cfif #arr_data[37]# neq "">#trim(arr_data[37])#,</cfif>
														<cfif #arr_data[38]# neq "">#trim(arr_data[38])#,</cfif>
														<cfif #arr_data[39]# neq "">#trim(arr_data[39])#,</cfif>
														<cfif #arr_data[40]# neq "">#trim(arr_data[40])#,</cfif>
														<cfif #arr_data[41]# neq "">#trim(arr_data[41])#,</cfif>
														<cfif #arr_data[42]# neq "">'#trim(arr_data[42])#',</cfif>
														<cfif #arr_data[43]# neq "">#trim(arr_data[43])#,</cfif>
														<cfif #arr_data[44]# neq "">#trim(arr_data[44])#,</cfif>
														<cfif #arr_data[45]# neq "">#trim(arr_data[45])#,</cfif>
														<cfif #arr_data[46]# neq "">#trim(arr_data[46])#,</cfif>
														<!---<cfif #arr_data[47]# neq "">#trim(arr_data[47])#,</cfif>
														<cfif #arr_data[48]# neq "">#trim(arr_data[48])#,</cfif>
														<cfif #arr_data[49]# neq "">#trim(arr_data[49])#,</cfif>--->
														ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
														'AUTO'				
														)
									</cfquery>
																	
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "単品精算データの取り込み中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " & "jan:#arr_data[4]#" & " " &  "データ:#data#" &  #Chr(10)#>
												 --->
												<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in inserting t_seisan_jan" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " & "jan:#arr_data[4]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
													</cfif>
																			
												<cfcontinue>												
										</cfcatch>
								</cftry>
							<cfelse>
								<cftry>									
									<cfquery datasource="#application.dsn#" name="updSeisanJan">
										 update t_seisan_jan
										    set member_id = '#URLDecode(form.member)#',														
												sales_date                     = '#trim(arr_data[2])#',
												regi_id                        = '#trim(arr_data[3])#',
												jan                            = '#trim(arr_data[4])#',
												product_id                     = <cfif #arr_data[5]# neq "">'#trim(arr_data[5])#',<cfelse>null,</cfif>
												product_name                   = <cfif #arr_data[6]# neq "">'#trim(arr_data[6])#',<cfelse>null,</cfif>
												product_name_kana              = <cfif #arr_data[7]# neq "">'#trim(arr_data[7])#',<cfelse>null,</cfif>
												division_id                    = <cfif #arr_data[8]# neq "">'#trim(arr_data[8])#',<cfelse>null,</cfif>
												depart_id                      = <cfif #arr_data[9]# neq "">'#trim(arr_data[9])#',<cfelse>null,</cfif>
												line_id                        = <cfif #arr_data[10]# neq "">'#trim(arr_data[10])#',<cfelse>null,</cfif>
												class_id                       = <cfif #arr_data[11]# neq "">'#trim(arr_data[11])#',<cfelse>null,</cfif>
												sale_discrimination            = <cfif #arr_data[12]# neq "">'#trim(arr_data[12])#',<cfelse>null,</cfif>
												
												event_id                       = <cfif #arr_data[13]# neq "">'#trim(arr_data[13])#',<cfelse>null,</cfif>
												mm_id                          = <cfif #arr_data[14]# neq "">'#trim(arr_data[14])#',<cfelse>null,</cfif>
												select_seisan_no               = <cfif #arr_data[15]# neq "">'#trim(arr_data[15])#',<cfelse>null,</cfif>
												ones_company_id                = <cfif #arr_data[16]# neq "">'#trim(arr_data[16])#',<cfelse>null,</cfif>
												unit_price_without_tax         = <cfif #arr_data[17]# neq "">#arr_data[17]#,<cfelse>null,</cfif>
												unit_price_include_tax         = <cfif #arr_data[18]# neq "">#arr_data[18]#,<cfelse>null,</cfif>
												unit_price_tax                 = <cfif #arr_data[19]# neq "">#arr_data[19]#,<cfelse>null,</cfif>
												sales_customer                 = <cfif #arr_data[20]# neq "">#arr_data[20]#,<cfelse>null,</cfif>
												sales_qty                      = <cfif #arr_data[21]# neq "">#arr_data[21]#,<cfelse>null,</cfif>
												gross_sales_amount_include_tax = <cfif #arr_data[22]# neq "">#arr_data[22]#,<cfelse>null,</cfif>
												price_discount_qty             = <cfif #arr_data[23]# neq "">#arr_data[23]#,<cfelse>null,</cfif>
												price_discount_amount          = <cfif #arr_data[24]# neq "">#arr_data[24]#,<cfelse>null,</cfif>
												price_discount_qty2            = <cfif #arr_data[25]# neq "">#arr_data[25]#,<cfelse>null,</cfif>
												price_discount_amount2         = <cfif #arr_data[26]# neq "">#arr_data[26]#,<cfelse>null,</cfif>
												mm_qty                         = <cfif #arr_data[27]# neq "">#arr_data[27]#,<cfelse>null,</cfif>
												mm_price_discount_amount       = <cfif #arr_data[28]# neq "">#arr_data[28]#,<cfelse>null,</cfif>
												disposal_qty                   = <cfif #arr_data[29]# neq "">#arr_data[29]#,<cfelse>0,</cfif>
												disposal_cost                  = <cfif #arr_data[30]# neq "">#arr_data[30]#,<cfelse>0,</cfif>
												return_qty                     = <cfif #arr_data[31]# neq "">#arr_data[31]#,<cfelse>null,</cfif>
												return_amount_include_tax      = <cfif #arr_data[32]# neq "">#arr_data[32]#,<cfelse>null,</cfif>
												fp_status1                     = <cfif #arr_data[33]# neq "">'#trim(arr_data[33])#',<cfelse>null,</cfif>
												fp_status2                     = <cfif #arr_data[34]# neq "">'#trim(arr_data[34])#',<cfelse>null,</cfif>
												fp_status3                     = <cfif #arr_data[35]# neq "">#arr_data[35]#,<cfelse>null,</cfif>
												gross_sales_amount_without_tax = <cfif #arr_data[36]# neq "">#arr_data[36]#,<cfelse>null,</cfif>
												gross_sales_amount_tax         = <cfif #arr_data[37]# neq "">#arr_data[37]#,<cfelse>null,</cfif>
												return_amount_without_tax      = <cfif #arr_data[38]# neq "">#arr_data[38]#,<cfelse>null,</cfif>
												return_amount_tax              = <cfif #arr_data[39]# neq "">#arr_data[39]#,<cfelse>null,</cfif>
												supplier_id                    = <cfif #arr_data[40]# neq "">#arr_data[40]#,<cfelse>null,</cfif>
												unit_cost                      = <cfif #arr_data[41]# neq "">#arr_data[41]#,<cfelse>null,</cfif>
												cost                           = <cfif #arr_data[42]# neq "">'#trim(arr_data[42])#',<cfelse>null,</cfif>
												profit_amount                  = <cfif #arr_data[43]# neq "">#arr_data[43]#,<cfelse>null,</cfif>
												net_sales_amount_without_tax   = <cfif #arr_data[44]# neq "">#arr_data[44]#,<cfelse>null,</cfif>
												net_sales_amount_include_tax   = <cfif #arr_data[45]# neq "">#arr_data[45]#,<cfelse>null,</cfif>
												net_sales_amount_tax           = <cfif #arr_data[46]# neq "">#arr_data[46]#,<cfelse>null,</cfif>
												<!---maker_name                = <cfif #arr_data[47]# neq "">#arr_data[47]#,<cfelse>null,</cfif>
												standard_name                  = <cfif #arr_data[48]# neq "">#arr_data[48]#,<cfelse>null,</cfif>
												disposal_unit_cost             = <cfif #arr_data[49]# neq "">#arr_data[49]#,<cfelse>null,</cfif>--->													
												modify_date                    = ADDTIME(UTC_TIMESTAMP(),"#utc_offset#"),
												modify_person                  = 'AUTO'
												where member_id = '#URLDecode(form.member)#' and shop_id = '#trim(arr_data[1])#' and regi_id = '#trim(arr_data[3])#' and sales_date = '#trim(arr_data[2])#' and jan = '#trim(arr_data[4])#'									
									</cfquery>
									<!--- 単品精算データの更新 --->	
																	
											<!--- ロールバック --->
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.seisan_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
													<!--- <cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "単品精算データの更新中にエラーが発生しました" & " " &  "売上日:#arr_data[2]#" & " " & "レジID:#arr_data[3]#" & " " & "jan:#arr_data[4]#" & " " &  "データ:#data#" & " " & "SQL文:#cfcatch.Sql#" & " " &  "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
													 --->
													<cfset log_output = #URLDecode(form.name)# & " " & "#cnt#行目" & "error in updating t_seisan_jan" & " " &  "sales_date:#arr_data[2]#" & " " & "regi_id:#arr_data[3]#" & " " & "jan:#arr_data[4]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" & #Chr(10)#>
													
														<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8">
														</cfif>
																				
													<cfcontinue>												
											</cfcatch>
								</cftry>								
								
							</cfif>
						</cftransaction>			
		</cfloop>
			
		<cfreturn 1 >
	</cffunction>	
					
</cfcomponent>

