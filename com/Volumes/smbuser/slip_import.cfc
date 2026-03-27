<cfcomponent>
	<cfsetting showDebugOutput="No" >
	<cffunction name="insSlip" access="remote" returnFormat="plain">
		<cfoutput>
			<cfset slip_log = "売上伝票受信:">
			<cfif IsDefined("form.member") and form.member neq "">
				<cfset slip_log = slip_log & URLDecode(form.member)>
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
				   	'#slip_log#'
				   	)
			</cfquery>
			<cfquery datasource="#application.dsn#" name="qTakeLog2">
				 INSERT INTO t_log  
				   (
				   	log_time,
				   	log
				   	)VALUES(
				   	now(),
				   	SUBSTRING('#rq_data.content#',1,4500)
				   	)
			</cfquery>
			<!--- 
				------------------------------------------------------------------------------------------
				form.dataがデータ(カンマ区切りのリスト)、form.nameが日時などの情報、form.memberがmember_id、form.shopがshop_id
				------------------------------------------------------------------------------------------			
			--->
			
			<!--- エンコードされた%は%25になる。 --->
			<cfset escaped_data = replace(form.data,"%25","","all")>
			<!--- 下から送られてくるデータ --->
			<cfset data_list = URLDecode(escaped_data,"utf-8")>
			<!--- 行数カウント --->
			<cfset cnt = 0>
			
			<!--- ヘッダでエラーが起きた場合、明細も飛ばすために使用 --->
			<cfset error_slip_num = "000">

			<!--- <cfset today = now()> --->

	        <cfquery name="qGetOffSet" datasource="#application.dsn#">
	            SELECT DATE_FORMAT(ADDTIME(UTC_TIMESTAMP(),m_time_zone.utc_offset),'%Y/%m/%d') as today,
	                   m_admin.country_id,
	                   m_time_zone.utc_offset
	              FROM m_admin LEFT OUTER JOIN m_time_zone ON m_admin.time_zone_id = m_time_zone.time_zone_id   
	             WHERE member_id = '#URLDecode(form.member)#'
	        </cfquery>

	        <cfset today = qGetOffSet.today>
	        <cfset utc_offset = qGetOffSet.utc_offset>	        			
			
			<!--- ループ開始 --->
			<cfloop index="data" list="#data_list#" delimiters="#chr(10)#">
				<cfset cnt = cnt + 1>
				<cftransaction>
					<!--- 配列に変換 --->
					<cfset arr_data = Listtoarray(data, ",", true)>
					<cfif IsDefined("arr_data") eq false><cfbreak></cfif>
						<!--- エラーが出た場合、その伝票のヘッダまでロールバックするため、セーブポイント名を伝票番号に設定 --->
						<cfif arr_data[1] eq "H">
							<cfset savepoint = trim(arr_data[3])>
							<cfset skip = false>
						</cfif>
						<!--- セーブポイントをセットする前にqueryが必要っぽいのでこれを --->
						<cfquery datasource="#application.dsn#" name="DummyQueryForSetSavePoint">
							select 1 from dual
						</cfquery>
						<!--- セーブポイントセット --->
						<cftransaction action="setsavepoint" savepoint="#savepoint#"/>
												
							<!--- ここからヘッダの処理 --->
							<cfif arr_data[1] eq "H">
								<!--- 売上日の日付の形式が不正の場合ログに残して伝票の登録を飛ばす --->					
								<cfif IsDate(trim(arr_data[4])) eq false>
			                    	<!--- ログ取得 --->
				                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
									<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "売上日エラー" & " " &  arr_data[4] &  Chr(10)>
										<!--- その月のテキストファイルがあるかどうかの判定 --->
										<cfif FileExists(#log_file#)>
											<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
										<cfelse>
											<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
										</cfif>
										<cfset error_slip_num = trim(arr_data[3])>						
									<cfcontinue>
								</cfif>
								<!--- 取引日時の日付の形式が不正の場合ログに残して伝票の登録を飛ばす --->
								<cfif arr_data[15] neq "">					
									<cfif IsDate(trim(arr_data[15])) eq false>
				                    	<!--- ログ取得 --->
					                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
										<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "取引日エラー" & " " &  arr_data[15] &  Chr(10)>
											<!--- その月のテキストファイルがあるかどうかの判定 --->
											<cfif FileExists(log_file)>
												<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
											<cfelse>
												<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
											</cfif>
											<cfset error_slip_num = trim(arr_data[3])>						
										<cfcontinue>
									</cfif>
								</cfif>					
								<!--- 作成日の日付の形式が不正の場合ログに残して伝票の登録を飛ばす --->
								<cfif arr_data[45] neq "">					
									<cfif IsDate(trim(arr_data[45])) eq false>
				                    	<!--- ログ取得 --->
					                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
										<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "作成日エラー" & " " &  arr_data[45] &  Chr(10)>
											<!--- その月のテキストファイルがあるかどうかの判定 --->
											<cfif FileExists(log_file)>
												<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
											<cfelse>
												<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
											</cfif>
											<cfset error_slip_num = trim(arr_data[3])>						
										<cfcontinue>
									</cfif>
								</cfif>
								<!--- 更新日の日付の形式が不正の場合ログに残して伝票の登録を飛ばす --->
								<cfif arr_data[48] neq "">					
									<cfif IsDate(trim(arr_data[48])) eq false>
				                    	<!--- ログ取得 --->
					                	<cfset log_file = "#application.log_dir#" & DateFormat(today, "yyyy-mm") & ".txt">
										<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "更新日エラー" & " " &  arr_data[48] &  Chr(10)>
											<!--- その月のテキストファイルがあるかどうかの判定 --->
											<cfif FileExists(#log_file#)>
												<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
											<cfelse>
												<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
											</cfif>	
											<cfset error_slip_num = trim(arr_data[3])>					
										<cfcontinue>
									</cfif>
								</cfif>					
													
								<cfquery datasource="#application.dsn#" name="chkSlipNum">
									select slip_num,
									       uniform_invoice_seq_num,
									       DATE_FORMAT(t_slip.sales_date,'%Y/%m/%d') as char_sales_date 
									  from t_slip 
									 where member_id = '#URLDecode(form.member)#' and slip_num = '#trim(arr_data[3])#'
								</cfquery>
									<!--- 伝票番号が存在する場合ヘッダと明細を削除。(その後通常処理でインサート) --->
									<cfif chkSlipNum.RecordCount GTE 1>
										<!---
										<!--- 同じ日付の場合スルー --->
										<cfif DateCompare('#chkSlipNum.char_sales_date#','#arr_data[4]#','d') eq 0>								
					                    	<!--- ログ取得 --->
						                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
											<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "取込済み伝票のため、スキップします。（伝票番号：#arr_data[3]#）" &  Chr(10)>
												<!--- その月のテキストファイルがあるかどうかの判定 --->
												<cfif FileExists(log_file)>
													<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
												<cfelse>
													<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
												</cfif>	
												<cfset error_slip_num = arr_data[3]>					
											<cfcontinue>
										<!--- 違う日付の場合削除。後にインサート --->
										<cfelse>
										--->
																		

										<!--- ヘッダと明細を削除 --->
										<cftry>
											<!--- 台湾の場合、すでに統一発票が空でなく、統一発票が空の場合スキップ --->
<!--- 											<cfif arr_data[1] eq "H" and qGetOffSet.country_id eq 6 and chkSlipNum.uniform_invoice_seq_num neq "" and ArrayIsDefined(arr_data, 100) and arr_data[100] eq "">
												<cfset skip = true>
											</cfif> --->
											<cfif skip>
							                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
												<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "スキップします。（伝票番号：#arr_data[3]#）" &  Chr(10)>
												<!--- その月のテキストファイルがあるかどうかの判定 --->
												<cfif FileExists(log_file)>
													<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
												<cfelse>
													<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
												</cfif>															
											<cfelse>
												<cfquery datasource="#application.dsn#" name="delSlip">
													delete from t_slip where member_id = '#URLDecode(form.member)#' and slip_num = '#trim(arr_data[3])#' 
												</cfquery>
												<cfquery datasource="#application.dsn#" name="delSlipDetail">
													delete from t_slip_detail where member_id = '#URLDecode(form.member)#' and slip_num = '#trim(arr_data[3])#' 
												</cfquery>
							                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
												<cfset log_output = URLDecode(form.name) & " " & cnt & "行目" & "重複伝票を削除しました" & "対象伝票番号:#arr_data[3]##now()#" & Chr(10)>
												<!--- その月のテキストファイルがあるかどうかの判定 --->
												<cfif FileExists(log_file)>
													<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
												<cfelse>
													<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
												</cfif>																																																									
											</cfif>
											<cfcatch type="Database">
												<cftransaction action="rollback" savepoint="#savepoint#"/>
							                    	<!--- ログ取得 --->
								                	<cfset log_file = "#application.log_dir#" & DateFormat(today, "yyyy-mm") & ".txt">
													<cfset log_output = URLDecode(form.name) & " " & cnt & "行目" & "重複伝票の削除に失敗しました" & "対象伝票:#arr_data[3]#" & Chr(10)>
														<!--- その月のテキストファイルがあるかどうかの判定 --->
														<cfif FileExists(#log_file#)>
															<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
														<cfelse>
															<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
														</cfif>
														<cfset error_slip_num = arr_data[3]>						
													<cfcontinue>																												
											</cfcatch>											
										</cftry>																										
									</cfif> 
									<!---</cfif>--->
									
									<!--- 相殺伝票＆対象伝票番号がNOT NULLの場合、対象伝票の伝票区分を3（削除）にする --->
									<cfif trim(arr_data[51]) eq 2 and trim(arr_data[39]) neq "">
										<cftry>
											<cfquery datasource="#application.dsn#" name="updSlipDiv">
												update t_slip set slip_division = 3 where member_id = '#URLDecode(form.member)#' and slip_num = '#trim(arr_data[39])#' 
											</cfquery>
												<cfcatch type="Database">
													<cftransaction action="rollback" savepoint="#savepoint#"/>
								                    	<!--- ログ取得 --->
									                	<cfset log_file = "#application.log_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
														<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "伝票テーブル（伝票区分）を更新中にエラーが発生しました" & " " &  "対象伝票:#arr_data[39]#" & " " &  "データ:#data#" &  Chr(10)>
															<!--- その月のテキストファイルがあるかどうかの判定 --->
															<cfif FileExists(#log_file#)>
																<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
															<cfelse>
																<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
															</cfif>
															<cfset error_slip_num = trim(arr_data[3])>						
														<cfcontinue>																												
												</cfcatch>									
										</cftry>
									</cfif>
									
										<!--- 明細側に入れるための作成日等 --->
										<cfset sp_id = trim(arr_data[2])><!--- 店舗番号 --->	
										<cfset s_num = trim(arr_data[3])><!--- 伝票番号 --->
										<cfset s_date = arr_data[4]><!--- 売上日 --->								
										
										<cfif arr_data[45] neq "">
											<cfset c_date = arr_data[45]>
										<cfelse>
											<cfset c_date = "">
										</cfif>
										<cfif arr_data[46] neq "">
											<cfset c_account = arr_data[46]>
										<cfelse>
											<cfset c_account = "">
										</cfif>
										<cfif arr_data[47] neq "">
											<cfset c_person = arr_data[47]>
										<cfelse>
											<cfset c_person = "">
										</cfif>
										<cfif #arr_data[48]# neq "">
											<cfset m_date = arr_data[48]>
										<cfelse>
											<cfset m_date = "">
										</cfif>
										<cfif arr_data[49] neq "">
											<cfset m_account = arr_data[49]>
										<cfelse>
											<cfset m_account = "">
										</cfif>
										<cfif arr_data[50] neq "">
											<cfset m_person = arr_data[50]>
										<cfelse>
											<cfset m_person = "">
										</cfif>					
									
									<cftry>
										<cfif !skip>
											<cfquery datasource="#application.dsn#" name="insSlip">
												insert into t_slip 
															(
															member_id,
															shop_id,														
															slip_num,
															sales_division,
															<cfif arr_data[4] neq "">sales_date,</cfif>
															<cfif arr_data[5] neq "">regi_id,</cfif>
															<cfif arr_data[6] neq "">customer_id,</cfif>
															<cfif arr_data[7] neq "">customer_last_name,</cfif>
															<cfif arr_data[8] neq "">customer_first_name,</cfif>
															<cfif arr_data[9] neq "">customer_last_name_kana,</cfif>
															<cfif arr_data[10] neq "">customer_first_name_kana,</cfif>
															<cfif arr_data[11] neq "">tax_rate,</cfif>
															<cfif arr_data[12] neq "">tax_class,</cfif>
															<cfif arr_data[13] neq "">tax_rounding,</cfif>
															<cfif arr_data[14] neq "">price_rounding,</cfif>
															<cfif arr_data[15] neq "">torihiki_datetime,</cfif>
															<cfif arr_data[16] neq "">receipt_display_datetime,</cfif>
															<cfif arr_data[17] neq "">subtotal_qty,</cfif>
															<cfif arr_data[18] neq "">subtotal_amount_without_tax,</cfif>
															<cfif arr_data[19] neq "">subtotal_amount_include_tax,</cfif>
															<cfif arr_data[20] neq "">subtotal_amount_tax,</cfif>
															<cfif arr_data[21] neq "">subtotal_price_discount_amount,</cfif>
															<cfif arr_data[22] neq "">subtotal_discount_rate,</cfif>
															<cfif arr_data[23] neq "">subtotal_percent_discount_amount,</cfif>
															<cfif arr_data[24] neq "">total_amount_without_tax,</cfif>
															<cfif arr_data[25] neq "">total_amount_include_tax,</cfif>
															<cfif arr_data[26] neq "">total_amount_tax,</cfif>
															<cfif arr_data[27] neq "">receipt_amount0,</cfif>
															<cfif arr_data[28] neq "">receipt_amount1,deposit1,</cfif>
															<cfif arr_data[29] neq "">receipt_amount2,deposit2,</cfif>
															<cfif arr_data[30] neq "">receipt_amount3,deposit3,</cfif>
															<cfif arr_data[31] neq "">receipt_amount4,deposit4,</cfif>
															<cfif arr_data[32] neq "">receipt_amount5,deposit5,</cfif>
															<cfif arr_data[33] neq "">receipt_amount6,deposit6,</cfif>
															<cfif arr_data[34] neq "">receipt_amount7,deposit7,</cfif>
															<cfif arr_data[35] neq "">receipt_amount8,deposit8,</cfif>
															<cfif arr_data[36] neq "">receipt_amount9,deposit9,</cfif>
															<cfif arr_data[37] neq "">receipt_amount10,deposit10,</cfif>
															<cfif arr_data[38] neq "">change_amount,</cfif>
															<cfif arr_data[39] neq "">target_slip_num,</cfif>
															<cfif arr_data[40] neq "">before_shopping_point,</cfif>
															<cfif arr_data[41] neq "">add_shopping_point,</cfif>
															<cfif arr_data[42] neq "">use_shopping_point,</cfif>
															<cfif arr_data[43] neq "">shopping_point,</cfif>
															<cfif arr_data[44] neq "">memo,</cfif>
															<cfif arr_data[45] neq "">create_date,</cfif>
															<cfif arr_data[46] neq "">create_account,</cfif>
															<cfif arr_data[47] neq "">create_person,</cfif>
															<cfif arr_data[48] neq "">modify_date,</cfif>
															<cfif arr_data[49] neq "">modify_account,</cfif>
															<cfif arr_data[50] neq "">modify_person,</cfif>
															<cfif arr_data[51] neq "">slip_division,</cfif>
															<cfif arr_data[52] neq "">deposit0,</cfif>
															<cfif arr_data[53] neq "">gift_cert_change_amount,</cfif>
															<cfif arr_data[54] neq "">gift_cert_no_change_amount,</cfif>
															<cfif arr_data[55] neq "">gross_amount_without_tax,</cfif>
															<cfif arr_data[56] neq "">gross_amount_include_tax,</cfif>
															<cfif arr_data[57] neq "">gross_amount_tax,</cfif>
															<cfif arr_data[58] neq "">include_tax_sales,</cfif>
															<cfif arr_data[59] neq "">include_tax_amount,</cfif>
															<cfif arr_data[60] neq "">infox_kid,</cfif>
															<cfif arr_data[61] neq "">infox_company_id,</cfif>									
															<cfif arr_data[62] neq "">infox_card_division,</cfif>
															<cfif arr_data[63] neq "">infox_card_encode_company_id,</cfif>
															<cfif arr_data[64] neq "">infox_card_encode_customer_id,</cfif>
															<cfif arr_data[65] neq "">infox_card_encode_expiration,</cfif>
															<!--- <cfif #arr_data[66]# neq "">infox_customer_id,</cfif> クレジットカード用のIDで、19桁までしか入らずエラーが出ていたため一旦コメント --->
															<cfif arr_data[67] neq "">infox_product_id,</cfif>
															<cfif arr_data[68] neq "">infox_amount,</cfif>
															<cfif arr_data[69] neq "">infox_tax_etc,</cfif>
															<cfif arr_data[70] neq "">infox_slip_num,</cfif>
															<cfif arr_data[71] neq "">infox_approve_num,</cfif>
															<cfif arr_data[72] neq "">infox_payment_division,</cfif>
															<cfif arr_data[73] neq "">infox_payment_start_month,</cfif>
															<cfif arr_data[74] neq "">infox_payment_first_amount,</cfif>
															<cfif arr_data[75] neq "">infox_payment_division_times,</cfif>
															<cfif arr_data[76] neq "">infox_payment_bonus_times,</cfif>
															<cfif arr_data[77] neq "">infox_payment_bonus_month,</cfif>
															<cfif arr_data[78] neq "">infox_payment_bonus_amount,</cfif>
															<cfif arr_data[79] neq "">infox_debit_bank_code,</cfif>
															<cfif arr_data[80] neq "">infox_debit_branch_code,</cfif>
															<cfif arr_data[81] neq "">infox_debit_card_division,</cfif>
															<cfif arr_data[82] neq "">infox_debit_account_num,</cfif>
															<cfif arr_data[83] neq "">infox_credit_seq_num,</cfif>
															<cfif arr_data[84] neq "">infox_debit_seq_num,</cfif>													
															<cfif arr_data[85] neq "">infox_payment_bonus_month2,</cfif>
															<cfif arr_data[86] neq "">infox_payment_bonus_month3,</cfif>
															<cfif arr_data[87] neq "">infox_payment_bonus_month4,</cfif>
															<cfif arr_data[88] neq "">infox_payment_bonus_month5,</cfif>
															<cfif arr_data[89] neq "">infox_payment_bonus_month6,</cfif>									
															<cfif arr_data[90] neq "">infox_payment_bonus_amount2,</cfif>
															<cfif arr_data[91] neq "">infox_payment_bonus_amount3,</cfif>
															<cfif arr_data[92] neq "">infox_payment_bonus_amount4,</cfif>									
															<cfif arr_data[93] neq "">infox_payment_bonus_amount5,</cfif>
															<cfif arr_data[94] neq "">infox_payment_bonus_amount6,</cfif>
															<cfif arr_data[95] neq "">daily_seq_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 96) and arr_data[96] neq "">group_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 97) and arr_data[97] neq "">guest_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 98) and arr_data[98] neq "">table_id,</cfif>
															<cfif ArrayIsDefined(arr_data, 99) and arr_data[99] neq "">table_name,</cfif>
															<cfif ArrayIsDefined(arr_data, 100) and arr_data[100] neq "">uniform_invoice_seq_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 101) and arr_data[101] neq "">uniform_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 102) and arr_data[102] neq "">order_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 103) and arr_data[103] neq "">service_charge_rate,</cfif>
															<cfif ArrayIsDefined(arr_data, 104) and arr_data[104] neq "">service_charge,</cfif>
															<cfif ArrayIsDefined(arr_data, 105) and arr_data[105] neq "">service_charge_flag,</cfif>
															<cfif ArrayIsDefined(arr_data, 106) and arr_data[106] neq "">discount_price_preset_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 107) and arr_data[107] neq "">discount_price_name,</cfif>
															<cfif ArrayIsDefined(arr_data, 108) and arr_data[108] neq "">discount_rate_preset_num,</cfif>
															<cfif ArrayIsDefined(arr_data, 109) and arr_data[109] neq "">discount_rate_name,</cfif>
															<cfif ArrayIsDefined(arr_data, 110) and arr_data[110] neq "">pointable_amount,</cfif>
															<cfif ArrayIsDefined(arr_data, 111) and arr_data[111] neq "">deposit_point_amount,</cfif>

															<cfif ArrayIsDefined(arr_data, 112) and arr_data[112] neq "">tax_div,</cfif>
															<cfif ArrayIsDefined(arr_data, 113) and arr_data[113] neq "">tax_rate2,</cfif>
															<cfif ArrayIsDefined(arr_data, 114) and arr_data[114] neq "">tax_rate3,</cfif>
															<cfif ArrayIsDefined(arr_data, 115) and arr_data[115] neq "">tax_rate4,</cfif>
															<cfif ArrayIsDefined(arr_data, 116) and arr_data[116] neq "">tax_rate5,</cfif>
															<cfif ArrayIsDefined(arr_data, 117) and arr_data[117] neq "">tax_rate6,</cfif>
															<cfif ArrayIsDefined(arr_data, 118) and arr_data[118] neq "">include_tax_sales2,</cfif>
															<cfif ArrayIsDefined(arr_data, 119) and arr_data[119] neq "">include_tax_amount2,</cfif>
															<cfif ArrayIsDefined(arr_data, 120) and arr_data[120] neq "">include_tax_sales3,</cfif>
															<cfif ArrayIsDefined(arr_data, 121) and arr_data[121] neq "">include_tax_amount3,</cfif>
															<cfif ArrayIsDefined(arr_data, 122) and arr_data[122] neq "">include_tax_sales4,</cfif>
															<cfif ArrayIsDefined(arr_data, 123) and arr_data[123] neq "">include_tax_amount4,</cfif>
															<cfif ArrayIsDefined(arr_data, 124) and arr_data[124] neq "">include_tax_sales5,</cfif>
															<cfif ArrayIsDefined(arr_data, 125) and arr_data[125] neq "">include_tax_amount5,</cfif>
															<cfif ArrayIsDefined(arr_data, 126) and arr_data[126] neq "">include_tax_sales6,</cfif>
															<cfif ArrayIsDefined(arr_data, 127) and arr_data[127] neq "">include_tax_amount6,</cfif>
															<cfif ArrayIsDefined(arr_data, 128) and arr_data[128] neq "">exclude_tax_sales,</cfif>
															<cfif ArrayIsDefined(arr_data, 129) and arr_data[129] neq "">exclude_tax_amount,</cfif>
															<cfif ArrayIsDefined(arr_data, 130) and arr_data[130] neq "">exclude_tax_sales2,</cfif>
															<cfif ArrayIsDefined(arr_data, 131) and arr_data[131] neq "">exclude_tax_amount2,</cfif>
															<cfif ArrayIsDefined(arr_data, 132) and arr_data[132] neq "">exclude_tax_sales3,</cfif>
															<cfif ArrayIsDefined(arr_data, 133) and arr_data[133] neq "">exclude_tax_amount3,</cfif>
															<cfif ArrayIsDefined(arr_data, 134) and arr_data[134] neq "">exclude_tax_sales4,</cfif>
															<cfif ArrayIsDefined(arr_data, 135) and arr_data[135] neq "">exclude_tax_amount4,</cfif>
															<cfif ArrayIsDefined(arr_data, 136) and arr_data[136] neq "">exclude_tax_sales5,</cfif>
															<cfif ArrayIsDefined(arr_data, 137) and arr_data[137] neq "">exclude_tax_amount5,</cfif>
															<cfif ArrayIsDefined(arr_data, 138) and arr_data[138] neq "">exclude_tax_sales6,</cfif>
															<cfif ArrayIsDefined(arr_data, 139) and arr_data[139] neq "">exclude_tax_amount6,</cfif>
															<cfif ArrayIsDefined(arr_data, 140) and arr_data[140] neq "">credit_last_4digits,</cfif>
															<cfif ArrayIsDefined(arr_data, 141) and arr_data[141] neq "">e_inv_carrier_id,</cfif>
															recv_date,
															recv_person																	
															)
															values
															(
															'#URLDecode(form.member)#',
															'#trim(arr_data[2])#',
															'#trim(arr_data[3])#',
															1,
															<cfif arr_data[4] neq "">'#trim(arr_data[4])#',</cfif>
															<cfif arr_data[5] neq "">'#trim(arr_data[5])#',</cfif>
															<cfif arr_data[6] neq "">'#trim(arr_data[6])#',</cfif>
															<cfif arr_data[7] neq "">'#trim(arr_data[7])#',</cfif>
															<cfif arr_data[8] neq "">'#trim(arr_data[8])#',</cfif>
															<cfif arr_data[9] neq "">'#trim(arr_data[9])#',</cfif>
															<cfif arr_data[10] neq "">'#trim(arr_data[10])#',</cfif>
															<cfif arr_data[11] neq "">#trim(arr_data[11])#,</cfif>
															<cfif arr_data[12] neq "">#trim(arr_data[12])#,</cfif>
															<cfif arr_data[13] neq "">#trim(arr_data[13])#,</cfif>
															<cfif arr_data[14] neq "">#trim(arr_data[14])#,</cfif>
															<cfif arr_data[15] neq "">'#arr_data[15]#',</cfif>
															<cfif arr_data[16] neq "">'#arr_data[16]#',</cfif>
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
															<cfif arr_data[28] neq "">#trim(arr_data[28])#,#trim(arr_data[28])#,</cfif>
															<cfif arr_data[29] neq "">#trim(arr_data[29])#,#trim(arr_data[29])#,</cfif>
															<cfif arr_data[30] neq "">#trim(arr_data[30])#,#trim(arr_data[30])#,</cfif>
															<cfif arr_data[31] neq "">#trim(arr_data[31])#,#trim(arr_data[31])#,</cfif>
															<cfif arr_data[32] neq "">#trim(arr_data[32])#,#trim(arr_data[32])#,</cfif>
															<cfif arr_data[33] neq "">#trim(arr_data[33])#,#trim(arr_data[33])#,</cfif>
															<cfif arr_data[34] neq "">#trim(arr_data[34])#,#trim(arr_data[34])#,</cfif>
															<cfif arr_data[35] neq "">#trim(arr_data[35])#,#trim(arr_data[35])#,</cfif>
															<cfif arr_data[36] neq "">#trim(arr_data[36])#,#trim(arr_data[36])#,</cfif>
															<cfif arr_data[37] neq "">#trim(arr_data[37])#,#trim(arr_data[37])#,</cfif>
															<cfif arr_data[38] neq "">#trim(arr_data[38])#,</cfif>
															<cfif arr_data[39] neq "">'#trim(arr_data[39])#',</cfif>
															<cfif arr_data[40] neq "">#trim(arr_data[40])#,</cfif>
															<cfif arr_data[41] neq "">#trim(arr_data[41])#,</cfif>
															<cfif arr_data[42] neq "">#trim(arr_data[42])#,</cfif>
															<cfif arr_data[43] neq "">#trim(arr_data[43])#,</cfif>
															<cfif arr_data[44] neq "">'#trim(arr_data[44])#',</cfif>
															<cfif arr_data[45] neq "">'#arr_data[45]#',</cfif>
															<cfif arr_data[46] neq "">'#trim(arr_data[46])#',</cfif>
															<cfif arr_data[47] neq "">'#trim(arr_data[47])#',</cfif>
															<cfif arr_data[48] neq "">'#arr_data[48]#',</cfif>
															<cfif arr_data[49] neq "">'#trim(arr_data[49])#',</cfif>
															<cfif arr_data[50] neq "">'#trim(arr_data[50])#',</cfif>
															<cfif arr_data[51] neq "">#trim(arr_data[51])#,</cfif>
															<cfif arr_data[52] neq "">#trim(arr_data[52])#,</cfif>
															<cfif arr_data[53] neq "">#trim(arr_data[53])#,</cfif>
															<cfif arr_data[54] neq "">#trim(arr_data[54])#,</cfif>
															<cfif arr_data[55] neq "">#trim(arr_data[55])#,</cfif>
															<cfif arr_data[56] neq "">#trim(arr_data[56])#,</cfif>
															<cfif arr_data[57] neq "">#trim(arr_data[57])#,</cfif>
															<cfif arr_data[58] neq "">#trim(arr_data[58])#,</cfif>
															<cfif arr_data[59] neq "">#trim(arr_data[59])#,</cfif>
															<cfif arr_data[60] neq "">'#trim(arr_data[60])#',</cfif>
															<cfif arr_data[61] neq "">'#trim(arr_data[61])#',</cfif>									
															<cfif arr_data[62] neq "">#trim(arr_data[62])#,</cfif>
															<cfif arr_data[63] neq "">'#trim(arr_data[63])#',</cfif>
															<cfif arr_data[64] neq "">'#trim(arr_data[64])#',</cfif>
															<cfif arr_data[65] neq "">'#trim(arr_data[65])#',</cfif>
															<!--- <cfif #arr_data[66]# neq "">'#trim(arr_data[66])#',</cfif> --->
															<cfif arr_data[67] neq "">'#trim(arr_data[67])#',</cfif>
															
															<cfif arr_data[68] neq "">#trim(arr_data[68])#,</cfif>
															<cfif arr_data[69] neq "">#trim(arr_data[69])#,</cfif>
															<cfif arr_data[70] neq "">'#trim(arr_data[70])#',</cfif>
															<cfif arr_data[71] neq "">'#trim(arr_data[71])#',</cfif>
															<cfif arr_data[72] neq "">#trim(arr_data[72])#,</cfif>
															<cfif arr_data[73] neq "">#trim(arr_data[73])#,</cfif>
															<cfif arr_data[74] neq "">#trim(arr_data[74])#,</cfif>
															<cfif arr_data[75] neq "">#trim(arr_data[75])#,</cfif>
															<cfif arr_data[76] neq "">#trim(arr_data[76])#,</cfif>
															<cfif arr_data[77] neq "">#trim(arr_data[77])#,</cfif>
															<cfif arr_data[78] neq "">#trim(arr_data[78])#,</cfif>
															<cfif arr_data[79] neq "">'#trim(arr_data[79])#',</cfif>
															<cfif arr_data[80] neq "">'#trim(arr_data[80])#',</cfif>
															<cfif arr_data[81] neq "">#trim(arr_data[81])#,</cfif>
															<cfif arr_data[82] neq "">'#trim(arr_data[82])#',</cfif>
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

															<cfif ArrayIsDefined(arr_data, 96) and arr_data[96] neq "">#arr_data[96]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 97) and arr_data[97] neq "">#arr_data[97]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 98) and arr_data[98] neq "">#arr_data[98]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 99) and arr_data[99] neq "">'#arr_data[99]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 100) and arr_data[100] neq "">'#arr_data[100]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 101) and arr_data[101] neq "">'#arr_data[101]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 102) and arr_data[102] neq "">'#arr_data[102]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 103) and arr_data[103] neq "">#arr_data[103]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 104) and arr_data[104] neq "">#arr_data[104]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 105) and arr_data[105] neq "">#arr_data[105]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 106) and arr_data[106] neq "">#arr_data[106]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 107) and arr_data[107] neq "">'#arr_data[107]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 108) and arr_data[108] neq "">#arr_data[108]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 109) and arr_data[109] neq "">'#arr_data[109]#',</cfif>
															<cfif ArrayIsDefined(arr_data, 110) and arr_data[110] neq "">#arr_data[110]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 111) and arr_data[111] neq "">#arr_data[111]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 112) and arr_data[112] neq "">#arr_data[112]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 113) and arr_data[113] neq "">#arr_data[113]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 114) and arr_data[114] neq "">#arr_data[114]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 115) and arr_data[115] neq "">#arr_data[115]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 116) and arr_data[116] neq "">#arr_data[116]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 117) and arr_data[117] neq "">#arr_data[117]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 118) and arr_data[118] neq "">#arr_data[118]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 119) and arr_data[119] neq "">#arr_data[119]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 120) and arr_data[120] neq "">#arr_data[120]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 121) and arr_data[121] neq "">#arr_data[121]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 122) and arr_data[122] neq "">#arr_data[122]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 123) and arr_data[123] neq "">#arr_data[123]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 124) and arr_data[124] neq "">#arr_data[124]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 125) and arr_data[125] neq "">#arr_data[125]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 126) and arr_data[126] neq "">#arr_data[126]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 127) and arr_data[127] neq "">#arr_data[127]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 128) and arr_data[128] neq "">#arr_data[128]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 129) and arr_data[129] neq "">#arr_data[129]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 130) and arr_data[130] neq "">#arr_data[130]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 131) and arr_data[131] neq "">#arr_data[131]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 132) and arr_data[132] neq "">#arr_data[132]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 133) and arr_data[133] neq "">#arr_data[133]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 134) and arr_data[134] neq "">#arr_data[134]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 135) and arr_data[135] neq "">#arr_data[135]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 136) and arr_data[136] neq "">#arr_data[136]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 137) and arr_data[137] neq "">#arr_data[137]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 138) and arr_data[138] neq "">#arr_data[138]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 139) and arr_data[139] neq "">#arr_data[139]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 140) and arr_data[140] neq "">#arr_data[140]#,</cfif>
															<cfif ArrayIsDefined(arr_data, 141) and arr_data[141] neq "">'#arr_data[141]#',</cfif>
															ADDTIME(UTC_TIMESTAMP(),'#utc_offset#'),
															'AUTO'
															)
											</cfquery>
												
										</cfif>
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = "#application.log_dir#" & #DateFormat(today, "yyyy-mm")# & ".txt">
												<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "伝票を挿入中にエラーが発生しました" & " " &  "対象伝票:#arr_data[3]#" & " " &  "データ:#data#" & " " & "SQLエラー:#cfcatch.queryError#" &  #Chr(10)#>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(#log_file#)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
													</cfif>	
													<cfset error_slip_num = arr_data[3]>					
												<cfcontinue>												
										</cfcatch>											
									</cftry>
							<!--- 明細の取り込み --->
							<cfelseif arr_data[1] eq "D">							
								<cfif error_slip_num eq trim(arr_data[2])>
									<cfcontinue>
								</cfif>
								<cftry>
									<cfif !skip>
										<cfquery datasource="#application.dsn#" name="insSlipDetail">
											insert into t_slip_detail 
														(
														shop_id,
														slip_num,<!--- 2 --->
														<cfif arr_data[3] neq "">seq_num,</cfif>
														<cfif arr_data[4] neq "">division_id,</cfif>
														<cfif arr_data[5] neq "">division_name,</cfif>
														<cfif arr_data[6] neq "">depart_id,</cfif>
														<cfif arr_data[7] neq "">depart_name,</cfif>
														<cfif arr_data[8] neq "">line_id,</cfif>
														<cfif arr_data[9] neq "">line_name,</cfif>
														<cfif arr_data[10] neq "">class_id,</cfif>
														<cfif arr_data[11] neq "">class_name,</cfif>
														<cfif arr_data[12] neq "">product_id,</cfif>
														<cfif arr_data[13] neq "">jan,</cfif>
														<cfif arr_data[14] neq "">maker_name,</cfif>
														<cfif arr_data[15] neq "">maker_name_kana,</cfif>
														<cfif arr_data[16] neq "">product_name,</cfif>
														<cfif arr_data[17] neq "">product_name_kana,</cfif>
														<cfif arr_data[18] neq "">receipt_name,</cfif>
														<cfif arr_data[19] neq "">receipt_name_kana,</cfif>
														<cfif arr_data[20] neq "">standard_name,</cfif>
														<cfif arr_data[21] neq "">standard_name_kana,</cfif>
														<cfif arr_data[22] neq "">tax_class,</cfif>
														<cfif arr_data[23] neq "">mm_num,</cfif>
														<cfif arr_data[24] neq "">mm_set_discount_price,</cfif>
														<cfif arr_data[25] neq "">mm_set_qty,</cfif>
														<cfif arr_data[26] neq "">mm_count,</cfif>
														<cfif arr_data[27] neq "">mm_show_count,</cfif>
														<cfif arr_data[28] neq "">mm_discount_price,</cfif>
														<cfif arr_data[29] neq "">supplier_id,</cfif>
														<cfif arr_data[30] neq "">qty,</cfif>
														<cfif arr_data[31] neq "">unit_cost,</cfif>
					<!---									<cfif arr_data[32] neq "">unit_cost_without_tax,</cfif>
														<cfif arr_data[33] neq "">unit_cost_tax,</cfif> --->
														<cfif arr_data[34] neq "">cost,</cfif>
					<!---									<cfif arr_data[35] neq "">cost_without_tax,</cfif>
														<cfif arr_data[36] neq "">cost_tax,</cfif> --->
														<cfif arr_data[37] neq "">original_unit_price_without_tax,</cfif>
														<cfif arr_data[38] neq "">original_unit_price_include_tax,</cfif>
														<cfif arr_data[39] neq "">original_unit_price_tax,</cfif>
														<cfif arr_data[40] neq "">price_discount_amount,</cfif>
														<cfif arr_data[41] neq "">discount_rate,</cfif>
														<cfif arr_data[42] neq "">percent_discount_amount,</cfif>
														<cfif arr_data[43] neq "">unit_price_without_tax,</cfif>
														<cfif arr_data[44] neq "">unit_price_include_tax,</cfif>
														<cfif arr_data[45] neq "">unit_price_tax,</cfif>
														<cfif arr_data[46] neq "">sales_amount_without_tax,</cfif>
														<cfif arr_data[47] neq "">sales_amount_include_tax,</cfif>
														<cfif arr_data[48] neq "">sales_amount_tax,</cfif>
														<cfif arr_data[49] neq "">fix_sales_amount_without_tax,</cfif>
														<cfif arr_data[50] neq "">fix_sales_amount_include_tax,</cfif>
														<cfif arr_data[51] neq "">fix_sales_amount_tax,</cfif>
														<cfif arr_data[52] neq "">return_qty,</cfif>
														<cfif arr_data[53] neq "">return_amount_without_tax,</cfif>
														<cfif arr_data[54] neq "">return_amount_include_tax,</cfif>
														<cfif arr_data[55] neq "">return_amount_tax,</cfif>
														<cfif ArrayIsDefined(arr_data, 56) and arr_data[56] neq "">discount_unit_price,</cfif>

														<cfif ArrayIsDefined(arr_data, 57) and arr_data[57] neq "">option_id,</cfif>
														<cfif ArrayIsDefined(arr_data, 58) and arr_data[58] neq "">option_name,</cfif>
														<cfif ArrayIsDefined(arr_data, 59) and arr_data[59] neq "">property_id,</cfif>
														<cfif ArrayIsDefined(arr_data, 60) and arr_data[60] neq "">property_name,</cfif>
														<cfif ArrayIsDefined(arr_data, 61) and arr_data[61] neq "">option_tax_class,</cfif>
														<cfif ArrayIsDefined(arr_data, 62) and arr_data[62] neq "">message_id,</cfif>
														<cfif ArrayIsDefined(arr_data, 63) and arr_data[63] neq "">message,</cfif>
														<cfif ArrayIsDefined(arr_data, 64) and arr_data[64] neq "">option_flag,</cfif>
														<cfif ArrayIsDefined(arr_data, 65) and arr_data[65] neq "">option_seq_no,</cfif>
														<cfif ArrayIsDefined(arr_data, 66) and arr_data[66] neq "">cook_flag,</cfif>
														<cfif ArrayIsDefined(arr_data, 67) and arr_data[67] neq "">printer_map_id,</cfif>
														<cfif ArrayIsDefined(arr_data, 68) and arr_data[68] neq "">select_method,</cfif>

														<cfif ArrayIsDefined(arr_data, 69) and arr_data[69] neq "">discount_price_preset_num,</cfif>
														<cfif ArrayIsDefined(arr_data, 70) and arr_data[70] neq "">discount_price_name,</cfif>
														<cfif ArrayIsDefined(arr_data, 71) and arr_data[71] neq "">discount_rate_preset_num,</cfif>
														<cfif ArrayIsDefined(arr_data, 72) and arr_data[72] neq "">discount_rate_name,</cfif>
														<cfif ArrayIsDefined(arr_data, 73) and arr_data[73] neq "">detail_division,</cfif>
														
														<cfif ArrayIsDefined(arr_data, 74) and arr_data[74] neq "">reduced_tax_rate_flag,</cfif>
														<cfif ArrayIsDefined(arr_data, 75) and arr_data[75] neq "">tax_div,</cfif>
														<cfif ArrayIsDefined(arr_data, 76) and arr_data[76] neq "">tax_rate,</cfif>

														<cfif c_date neq "">create_date,</cfif>
														<cfif c_account neq "">create_account,</cfif>
														<cfif c_person neq "">create_person,</cfif>
														<cfif m_date neq "">modify_date,</cfif>
														<cfif m_account neq "">modify_account,</cfif>
														<cfif m_person neq "">modify_person,</cfif>
														member_id																					
														)
														values
														(														
														'#sp_id#',
														'#trim(arr_data[2])#',
														<cfif arr_data[3] neq "">#trim(arr_data[3])#,</cfif>
														<cfif arr_data[4] neq "">'#trim(arr_data[4])#',</cfif><!--- 部門コード --->
														<cfif arr_data[5] neq "">'#trim(arr_data[5])#',</cfif>
														<cfif arr_data[6] neq "">'#trim(arr_data[6])#',</cfif><!--- デパートコード --->
														<cfif arr_data[7] neq "">'#trim(arr_data[7])#',</cfif><!--- デパート名 --->
														<cfif arr_data[8] neq "">'#trim(arr_data[8])#',</cfif>
														<cfif arr_data[9] neq "">'#trim(arr_data[9])#',</cfif>
														<cfif arr_data[10] neq "">'#trim(arr_data[10])#',</cfif>
														<cfif arr_data[11] neq "">'#trim(arr_data[11])#',</cfif>
														<cfif arr_data[12] neq "">'#trim(arr_data[12])#',</cfif>
														<cfif arr_data[13] neq "">'#trim(arr_data[13])#',</cfif>
														<cfif arr_data[14] neq "">'#trim(arr_data[14])#',</cfif>
														<cfif arr_data[15] neq "">'#trim(arr_data[15])#',</cfif>
														<cfif arr_data[16] neq "">'#trim(arr_data[16])#',</cfif>
														<cfif arr_data[17] neq "">'#trim(arr_data[17])#',</cfif>
														<cfif arr_data[18] neq "">'#trim(arr_data[18])#',</cfif>
														<cfif arr_data[19] neq "">'#trim(arr_data[19])#',</cfif>
														<cfif arr_data[20] neq "">'#trim(arr_data[20])#',</cfif>
														<cfif arr_data[21] neq "">'#trim(arr_data[21])#',</cfif>
														<cfif arr_data[22] neq "">#trim(arr_data[22])#,</cfif>
														<cfif arr_data[23] neq "">#trim(arr_data[23])#,</cfif>
														<cfif arr_data[24] neq "">#trim(arr_data[24])#,</cfif>
														<cfif arr_data[25] neq "">#trim(arr_data[25])#,</cfif>
														<cfif arr_data[26] neq "">#trim(arr_data[26])#,</cfif>
														<cfif arr_data[27] neq "">#trim(arr_data[27])#,</cfif>
														<cfif arr_data[28] neq "">'#trim(arr_data[28])#',</cfif>
														<cfif arr_data[29] neq "">'#trim(arr_data[29])#',</cfif>
														<cfif arr_data[30] neq "">#trim(arr_data[30])#,</cfif>
														<cfif arr_data[31] neq "">#trim(arr_data[31])#,</cfif>
				<!---										<cfif #arr_data[32]# neq "">#trim(arr_data[32])#,</cfif>
														<cfif #arr_data[33]# neq "">#trim(arr_data[33])#,</cfif> --->
														<cfif arr_data[34] neq "">#trim(arr_data[34])#,</cfif>
				<!---										<cfif #arr_data[35]# neq "">#trim(arr_data[35])#,</cfif>
														<cfif #arr_data[36]# neq "">#trim(arr_data[36])#,</cfif> --->
														<cfif arr_data[37] neq "">#trim(arr_data[37])#,</cfif>
														<cfif arr_data[38] neq "">#trim(arr_data[38])#,</cfif>
														<cfif arr_data[39] neq "">#trim(arr_data[39])#,</cfif>
														<cfif arr_data[40] neq "">#trim(arr_data[40])#,</cfif>
														<cfif arr_data[41] neq "">#trim(arr_data[41])#,</cfif>
														<cfif arr_data[42] neq "">#trim(arr_data[42])#,</cfif>
														<cfif arr_data[43] neq "">#trim(arr_data[43])#,</cfif>
														<cfif arr_data[44] neq "">'#trim(arr_data[44])#',</cfif>
														<cfif arr_data[45] neq "">'#trim(arr_data[45])#',</cfif>
														<cfif arr_data[46] neq "">'#trim(arr_data[46])#',</cfif>
														<cfif arr_data[47] neq "">'#trim(arr_data[47])#',</cfif>
														<cfif arr_data[48] neq "">'#trim(arr_data[48])#',</cfif>
														<cfif arr_data[49] neq "">'#trim(arr_data[49])#',</cfif>
														<cfif arr_data[50] neq "">'#trim(arr_data[50])#',</cfif>
														<cfif arr_data[51] neq "">#trim(arr_data[51])#,</cfif>
														<cfif arr_data[52] neq "">#trim(arr_data[52])#,</cfif>
														<cfif arr_data[53] neq "">#trim(arr_data[53])#,</cfif>
														<cfif arr_data[54] neq "">#trim(arr_data[54])#,</cfif>
														<cfif arr_data[55] neq "">#trim(arr_data[55])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 56) and arr_data[56] neq "">#trim(arr_data[56])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 57) and arr_data[57] neq "">#trim(arr_data[57])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 58) and arr_data[58] neq "">'#trim(arr_data[58])#',</cfif>
														<cfif ArrayIsDefined(arr_data, 59) and arr_data[59] neq "">#trim(arr_data[59])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 60) and arr_data[60] neq "">'#trim(arr_data[60])#',</cfif>
														<cfif ArrayIsDefined(arr_data, 61) and arr_data[61] neq "">#trim(arr_data[61])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 62) and arr_data[62] neq "">#trim(arr_data[62])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 63) and arr_data[63] neq "">'#trim(arr_data[63])#',</cfif>
														<cfif ArrayIsDefined(arr_data, 64) and arr_data[64] neq "">#trim(arr_data[64])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 65) and arr_data[65] neq "">#trim(arr_data[65])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 66) and arr_data[66] neq "">#trim(arr_data[66])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 67) and arr_data[67] neq "">#trim(arr_data[67])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 68) and arr_data[68] neq "">#trim(arr_data[68])#,</cfif>

														<cfif ArrayIsDefined(arr_data, 69) and arr_data[69] neq "">#trim(arr_data[69])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 70) and arr_data[70] neq "">'#trim(arr_data[70])#',</cfif>
														<cfif ArrayIsDefined(arr_data, 71) and arr_data[71] neq "">#trim(arr_data[71])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 72) and arr_data[72] neq "">'#trim(arr_data[72])#',</cfif>
														<cfif ArrayIsDefined(arr_data, 73) and arr_data[73] neq "">#trim(arr_data[73])#,</cfif>

														<cfif ArrayIsDefined(arr_data, 74) and arr_data[74] neq "">#trim(arr_data[74])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 75) and arr_data[75] neq "">#trim(arr_data[75])#,</cfif>
														<cfif ArrayIsDefined(arr_data, 76) and arr_data[76] neq "">#trim(arr_data[76])#,</cfif>												
														
														<cfif c_date neq "">'#c_date#',</cfif>
														<cfif c_account neq "">'#c_account#',</cfif>
														<cfif c_person neq "">'#c_person#',</cfif>
														<cfif m_date neq "">'#m_date#',</cfif>
														<cfif m_account neq "">'#m_account#',</cfif>
														<cfif m_person neq "">'#m_person#',</cfif>
														'#URLDecode(form.member)#'																																										
														)
										
										</cfquery>


									</cfif>
									<!--- ロールバック --->
									<cfcatch type="Database">
										<cftransaction action="rollback" savepoint="#savepoint#"/>
					                    	<!--- ログ取得 --->
						                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
											<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "明細を更新中にエラーが発生しました" & " " & "SQLエラー:#cfcatch.queryError#" & " " &"対象伝票番号:#s_num#" & " " & "対象行番号:#arr_data[3]#" & " " &  "データ:#data#" &  Chr(10)>
												<!--- その月のテキストファイルがあるかどうかの判定 --->
												<cfif FileExists(log_file)>
													<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
												<cfelse>
													<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
												</cfif>												
												<cfset error_slip_num = trim(arr_data[2])>						
											<cfcontinue>
									</cfcatch>									
								</cftry>
								
								
								<!--- 商品コードの最終販売日(最終売上日が売上日より前の場合) --->
								<cftry>
									<cfquery datasource="#application.dsn#" name="updLastSalesDate">
										UPDATE m_product  
										  SET last_sales_date = '#s_date#'  
										WHERE member_id = '#URLDecode(form.member)#' 
										  AND m_product.product_id = '#arr_data[12]#' 
										  AND IFNULL(m_product.last_sales_date, '1900/01/01') < '#trim(arr_data[4])#'
									</cfquery>
										<!--- ロールバック --->
										<cfcatch type="Database">
											<cftransaction action="rollback" savepoint="#savepoint#"/>
						                    	<!--- ログ取得 --->
							                	<cfset log_file = application.log_dir & DateFormat(today, "yyyy-mm") & ".txt">
												<cfset log_output = URLDecode(form.name) & " " & "#cnt#行目" & "最終日売上日の更新中にエラーがでました" & " " &  "対象伝票番号:#s_num#" & " " &  "データ:#data#" &  Chr(10)>
													<!--- その月のテキストファイルがあるかどうかの判定 --->
													<cfif FileExists(log_file)>
														<cffile action="append" file="#log_file#" output="#log_output#" charset="utf-8" mode = "777">
													<cfelse>
														<cffile action="write" file="#log_file#"  output="#log_output#" charset="utf-8" mode = "777">
													</cfif>														
													<cfset error_slip_num = trim(arr_data[2])>					
												<cfcontinue>												
										</cfcatch>							
								</cftry>							
								
							</cfif>	
												
						
				</cftransaction>
				
						
			</cfloop>
				
			<cfreturn 1 >
		</cfoutput>
	</cffunction>	
</cfcomponent>

