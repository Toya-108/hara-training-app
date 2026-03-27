<cfinclude template = "init.cfm">
<!DOCTYPE html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#lang_src.menu.payment_type#</cfoutput></title>
	<link rel="stylesheet" href="css/base/jquery.ui.all.css" />
	<link rel="stylesheet" href="css/shopcenter.css?20150603" />
	<link rel="stylesheet" href="css/jquery.mouseinfobox.css?2223" />	
	<link href="images/favicon.ico" rel="shortcut icon">
	<script type="text/javascript" charset="utf8" src="js/jquery-1.8.2.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui.min.js"></script>
	<script type="text/javascript" src="js/shopcenter.js"></script>
	<script type="text/javascript" charset="utf8" src="js/jquery.mouseinfobox.js"></script>
	<style>
		td { background-color: rgba(255,255,255,0.8);}
		body{  
		    margin: 0;  
		    padding: 0;  
		}  
		* html body{  
		    overflow: hidden;  
		}   
		.header_area {  
		   /* position: fixed !important;  
		    position: absolute;  
		    top: 0;  
		    left: 0;  
		    width: 100%;  
		    height: 110px;  
		    background-image:url(images/mokume1490x900.jpeg);  
		    z-index: 1; */ 
		}  
		* html div#contents_area{  
		    height: 100%;  
		    overflow: auto;  
		}
		th, td { white-space: nowrap; }
    	div.dataTables_wrapper {
        width: 1024px;
        margin: 0 auto;
    }
    .selected_thing{
    	background-color:#E2FF89;
    	height:40px;
    }				
	</style>
</head>
<body>
<div class="sky">
<div class="cloud">
	
	<cfif IsDefined("session.member_id") eq false>
		<cflocation url="login.cfm">
	</cfif>
		<div align="left" id="contentsArea">
			<cfset decimal_place = session.decimal_place>
 
 		<!--- 一度でも売上のある支払い方法は削除したり内容を変更したりできないのでそれをチェックする目的 --->
		<cfquery datasource="#application.dsn#" name="qGetStatus">
			SELECT
				SUM(receipt_amount1) receipt_amount1,
				SUM(receipt_amount2) receipt_amount2,
				SUM(receipt_amount3) receipt_amount3,
				SUM(receipt_amount4) receipt_amount4,
				SUM(receipt_amount5) receipt_amount5,
				SUM(receipt_amount6) receipt_amount6,
				SUM(receipt_amount7) receipt_amount7,
				SUM(receipt_amount8) receipt_amount8,
				SUM(receipt_amount9) receipt_amount9,
				SUM(receipt_amount10) receipt_amount10,
				SUM(receipt_amount11) receipt_amount11,
				SUM(receipt_amount12) receipt_amount12,
				SUM(receipt_amount13) receipt_amount13,
				SUM(receipt_amount14) receipt_amount14,
				SUM(receipt_amount15) receipt_amount15,
				SUM(receipt_amount16) receipt_amount16,
				SUM(receipt_amount17) receipt_amount17,
				SUM(receipt_amount18) receipt_amount18,
				SUM(receipt_amount19) receipt_amount19,
				SUM(receipt_amount20) receipt_amount20,
				SUM(receipt_amount21) receipt_amount21,
				SUM(receipt_amount22) receipt_amount22,
				SUM(receipt_amount23) receipt_amount23,
				SUM(receipt_amount24) receipt_amount24,
				SUM(receipt_amount25) receipt_amount25,
				SUM(receipt_amount26) receipt_amount26,
				SUM(receipt_amount27) receipt_amount27,
				SUM(receipt_amount28) receipt_amount28,
				SUM(receipt_amount29) receipt_amount29,
				SUM(receipt_amount30) receipt_amount30
			FROM t_slip
			WHERE member_id = '#session.member_id#'
		</cfquery>




		<cfquery datasource="#application.dsn#" name="qGetPayment">
				      SELECT m_receipt_method_sales.member_id,
							m_receipt_method_sales.receipt_method_id,
							m_receipt_method_sales.receipt_method_name,
							m_receipt_method_sales.receipt_method_name1,
							m_receipt_method_sales.receipt_method_name2,
							m_receipt_method_sales.receipt_method_name3,
							m_receipt_method_sales.receipt_method_name4,
							m_receipt_method_sales.receipt_method_name5,
							m_receipt_method_sales.receipt_method_name6,
							m_receipt_method_sales.sort_order,
							CASE WHEN m_receipt_method_sales.tw_remove_from_ui_flag = 0 THEN ''
							     WHEN m_receipt_method_sales.tw_remove_from_ui_flag = 1 THEN '#lang_src.term.deduct#'
							     ELSE ''
							 END AS char_tw_remove_from_ui_flag,
							tw_remove_from_ui_flag,
							m_receipt_method_sales.changeable_flag,
							m_receipt_method_sales.function_num,
							CASE WHEN m_receipt_method_sales.function_num = 28 THEN '#lang_src.term.credit#'
							     WHEN m_receipt_method_sales.function_num = 84 THEN '#lang_src.term.other_payment_method#'
							     WHEN m_receipt_method_sales.function_num = 85 THEN '#lang_src.term.other_payment_method#(#lang_src.term.no_change#)'
							     WHEN m_receipt_method_sales.function_num = 9999 THEN '#lang_src.term.not_in_use#'
							ELSE '#lang_src.term.not_in_use#'
							END AS char_function_num,
							m_receipt_method_sales.amount_input_flag,
							m_receipt_method_sales.multiple_method_flag,
							CASE WHEN m_receipt_method_sales.multiple_method_flag = 0 THEN '#lang_src.term.ng#'
							     WHEN m_receipt_method_sales.multiple_method_flag = 1 THEN '#lang_src.term.ok#'
							ELSE '#lang_src.term.ng#'
							END AS char_multiple_method_flag,
							m_receipt_method_sales.money_on_hand_flag,
							m_receipt_method_sales.color_red,
							m_receipt_method_sales.color_green,
							m_receipt_method_sales.color_blue,
							REPLACE(FORMAT(m_receipt_method_sales.payment_amount,#decimal_place#),',','') char_payment_amount,
							m_receipt_method_sales.payment_amount,
							m_receipt_method_sales.memo,
							m_receipt_method_sales.create_date,
							m_receipt_method_sales.create_account,
							m_receipt_method_sales.create_person,
							m_receipt_method_sales.modify_date,
							DATE_FORMAT(m_receipt_method_sales.modify_date,'%Y/%m/%d') as char_modify_date,
							m_receipt_method_sales.modify_account,
							m_receipt_method_sales.modify_person,
							CASE WHEN m_receipt_method_sales.over_payable_flag = 0 THEN '#lang_src.term.ng#'
							     WHEN m_receipt_method_sales.over_payable_flag = 1 THEN '#lang_src.term.ok#'
							   END AS char_over_payable_flag,
							m_receipt_method_sales.over_payable_flag
					    FROM m_receipt_method_sales
					   WHERE m_receipt_method_sales.member_id = '#session.member_id#'
					ORDER BY m_receipt_method_sales.sort_order ASC
		</cfquery>

			<cfoutput>
				<!---<cfinclude template="header.cfm" >--->
				<!--- 選択されたコードをJSでここに挿入 --->
				<input type="hidden" id="selectedID" value="">
					
				<!--- ajax用のmember_id --->
				<input type="hidden" name="mem_id" id="mem_id" value="#session.member_id#">
				<input type="hidden" id="language" value="#session.language#">
	
				<form name="master_payment_method" method="post">
                
                	<div class="header_area">
						<div class="topmenu"  style=" overflow:hidden;" >		
	                    	<div style="height:60px; margin-left:auto; margin-right:auto;">
	                    		<!--<div style="color:white;font-size:x-large;text-align:center;">Reason of Deposit and Withdrawal</div>-->
								<div style="float:left;">
									<table class="bt_table" cellpadding="0" cellspacing="0" >
										<tr>
											<td align="center" style="padding-top:8px;">
												<input type="button" value="" class="m_button3" style="background-image:url(images/cancel_bt2.png); width:30px; height:30px;"  onclick="back_to_detail();">	
											</td>
										</tr>
										<tr>
											<td height="20">#lang_src.btn.cancel#</td>
										</tr>
									</table>								
								</div>

								<div style="float:right;">
									<!--<input type="button" value="Add" name="input_btn" class="m_button input_btn" onclick="to_input('sinki');">-->
									<table class="bt_table"  cellpadding="0" cellspacing="0" >
										<tr>
											<td align="center" style="padding-top:8px; ">
												<input type="button" value="" id="update_btn" name="input_btn" class="m_button3 input_btn" style="background-image: url(images/shosai_bt3.png); width:30px; height:30px; ">
											</td>
										</tr>
										<tr>
											<td >#lang_src.btn.update#</td>
										</tr>
									</table>
                				</div>
								<input type="hidden" value="1" name="search" id="search">
	                            <div style="margin-left:40%; margin-right:40%;">
	                                <span style="color:  rgba(0,37,93,1.00); font-size:24px; line-height:60px;vertical-align:middle;">
	                                	#lang_src.menu.payment_type#
	                                </span>
	                        	</div>							
	                            
							</div>
						</div>
					</div>
                    
                    <div style="clear:both;"></div>
					<div style="height:500px; margin-top:20px;" id="contents_area">
						<div style="margin-right:auto;;margin-left:1%;">
							<div style="float:left;margin-bottom:20px;">
								<div>
									<table cellpadding="0" cellspacing="0" border="0" id="table_id" class="table-me" align="left" style="border-collapse: collapse; font-size: small;width:960px;margin-left:20px;">
										<thead style="background-color:white;">
											<tr>
												<th width="20" align="center"><span id="add_line" style="cursor:pointer">＋</span>&nbsp;</th>
												<th align="center">#lang_src.term.japanese#<img src="images/help_icon.png" style="width:12px;height:12px;" class="info-box" title="Japanese name for POS and Shop Center."></th>
												<th align="center">#lang_src.term.english#<img src="images/help_icon.png" style="width:12px;height:12px;" class="info-box" title="English name for POS and Shop Center."></th>
												<th align="center">#lang_src.term.chinese#<img src="images/help_icon.png" style="width:12px;height:12px;" class="info-box" title="Chinese name for POS and Shop Center."></th>
												<th align="center">#lang_src.term.payment_type#</th>
												<th align="center">#lang_src.term.mixed_payment#</th>
												<th align="center">#lang_src.term.over_charge#</th>
												<th align="center">#lang_src.term.fixed_amount#&nbsp;<img src="images/help_icon.png" style="width:12px;height:12px;" class="info-box" title="In case the coupon has fixed amount;<br>or 0 for unfixed."></th>
												<th align="center">#lang_src.term.uniform_invoice#</th>
												<th align="center">#lang_src.term.note#</th>
												<th width="20" align="center">#lang_src.term.delete#&nbsp;</th>
											</tr>

										</thead>
										<cfset loop_count = qGetPayment.RecordCount>
										<input type='hidden' id='loop_count' value='#loop_count#'>
										<tbody id="tbody">
											<cfif qGetPayment.RecordCount GTE 1>
												<cfloop index="cnt" from="1" to="#qGetPayment.RecordCount#">
													<cfset unchangeble = false>
													<cfif qGetStatus['receipt_amount' & cnt][1] GTE 1>
														<cfset unchangeble = true>
													</cfif>
													<tr class='list_tr'>
														<input type="hidden" name="receipt_method_id_#cnt#" class="receipt_method_id" value='#qGetPayment.receipt_method_id[cnt]#'>
														<td align='center' class='list_no'>
															#qGetPayment.sort_order[cnt]#												
														</td>
														<td align='left'>
															<input name='receipt_method_name1_#cnt#' class='no_comma receipt_method_name1' type='text' value='#qGetPayment.receipt_method_name1[cnt]#' style='width:100px;' maxlength="30">
														</td>
														<td align='left'>
															<input name='receipt_method_name2_#cnt#' class='no_comma receipt_method_name2' type='text' value='#qGetPayment.receipt_method_name2[cnt]#' style='width:100px;' maxlength="30">
														</td>
														<td align='left'>
															<input name='receipt_method_name3_#cnt#' class='no_comma receipt_method_name3' type='text' value='#qGetPayment.receipt_method_name3[cnt]#' style='width:100px;' maxlength="30">
														</td>
														<td align='left'>
															<select name="function_num#cnt#" class='function_num'>
																<option value="9999"<cfif qGetPayment.function_num[cnt] eq 9999 or qGetPayment.function_num[cnt] eq 0 or qGetPayment.function_num[cnt] eq "">selected</cfif>>#lang_src.term.not_in_use#</option>
																<option value="28" <cfif qGetPayment.function_num[cnt] eq 28>selected<cfelseif unchangeble>disabled</cfif> >#lang_src.term.credit#</option>
																<option value="84"<cfif qGetPayment.function_num[cnt] eq 84>selected<cfelseif unchangeble>disabled</cfif>>#lang_src.term.other_payment_method#</option>
																<option value="85"<cfif qGetPayment.function_num[cnt] eq 85>selected<cfelseif unchangeble>disabled</cfif>>#lang_src.term.other_payment_method#(#lang_src.term.no_change#)</option>
															</select>
														</td>
														<td align='left'>
															<select name="multiple_method_flag#cnt#" class='multiple_method_flag' >
																<option value="1"<cfif qGetPayment.multiple_method_flag[cnt] eq 1>selected</cfif>>#lang_src.term.ok#</option>
																<option value="0"<cfif qGetPayment.multiple_method_flag[cnt] eq 0>selected</cfif>>#lang_src.term.ng#</option>
															</select>
														</td>
														<td align='left'>
															<select name="over_payable_flag#cnt#" class='over_payable_flag' >
																<option value="1"<cfif qGetPayment.over_payable_flag[cnt] eq 1>selected<cfelseif unchangeble>disabled</cfif>>#lang_src.term.ok#</option>
																<option value="0"<cfif qGetPayment.over_payable_flag[cnt] eq 0>selected<cfelseif unchangeble>disabled</cfif>>#lang_src.term.ng#</option>
															</select>
														</td>
														<td align='left'>
															<input name='payment_amount#cnt#' class='no_comma payment_amount price' type='text' value='#qGetPayment.char_payment_amount[cnt]#' style='width:120px;text-align:right;' maxlength="30"<cfif unchangeble>readonly</cfif> >
														</td>														

														<td align='left'>
															<select name="tw_remove_from_ui_flag#cnt#" class='tw_remove_from_ui_flag'>
								
																<option value="0"<cfif qGetPayment.tw_remove_from_ui_flag[cnt] eq 0>selected<cfelseif  unchangeble>disabled</cfif>>#lang_src.term.normal#</option>
																<option value="1"<cfif qGetPayment.tw_remove_from_ui_flag[cnt] eq 1>selected<cfelseif  unchangeble>disabled</cfif>>#lang_src.term.deduct#</option>
															</select>
														</td>
														<td align='left'>
															<input name='memo#cnt#' class='no_comma memo' type='text' value='#qGetPayment.memo[cnt]#' style='width:120px;;' maxlength="30">
														</td>																												
														<td width="20" align='center'>
															<cfif qGetStatus['receipt_amount' & cnt][1] LT 1>
																<input class='line_del_btn' type='button' value='×'>
															<cfelse>
																#lang_src.term.undeletable#<img src="images/help_icon.png" style="width:12px;height:12px;" class="info-box" title="There is a sales data.">
																<input class='line_del_btn' type='button' value='×' style="display:none;" disabled>
															</cfif>
															
														</td>																									
													</tr>													
												</cfloop>									
											</cfif>
										</tbody>
									</table>
								</div>
							</div>
							
						</div>
					</div>
				</form>
			</cfoutput>
		</div>
<script>
	var LANG_RSC;
	function update(){
		location.href = "master_payment_method_input.cfm"
	};

	function back_to_menu(){
		location.href="menu_master.cfm";
	};
	function back_to_detail(){
		location.href="master_payment_method.cfm"
	}

	//画面サイズを取ってtopmenuクラスの幅を指定
	function getWindowSizeAndResize() {
		var sW,sH,s;
		sW = window.innerWidth;
		sH = window.innerHeight;
		$(".topmenu").attr("width",sW);
	}
	$(document).on("ready",function(){
		var lang = $("#language").val();
		$.getJSON("lang/term-" + lang + ".json", function (data) {
	      LANG_RSC = data;  
		
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
			$('#tbody').sortable({ cursor: 'move',opacity : 0.5,scrollSpeed : 50}).on('sortupdate',function () {
			  	$(".list_no").each(function(new_line_no){
			  		$(this).text(+new_line_no + 1);
			  	})
				$(".receipt_method_id").each(function(new_line_no){
					$(this).attr("name","receipt_method_id_" + (+new_line_no + 1));
				})		  	
				$(".receipt_method_name1").each(function(new_line_no){
					$(this).attr("name","receipt_method_name1_" + (+new_line_no + 1));
				})
				$(".receipt_method_name2").each(function(new_line_no){
					$(this).attr("name","receipt_method_name2_" + (+new_line_no + 1));
				})
				$(".receipt_method_name3").each(function(new_line_no){
					$(this).attr("name","receipt_method_name3_" + (+new_line_no + 1));
				})
				$(".function_num").each(function(new_line_no){
					$(this).attr("name","function_num" + (+new_line_no + 1));
				})
				$(".multiple_method_flag").each(function(new_line_no){
					$(this).attr("name","multiple_method_flag" + (+new_line_no + 1));
				})
				$(".over_payable_flag").each(function(new_line_no){
					$(this).attr("name","over_payable_flag" + (+new_line_no + 1));
				})
				$(".payment_amount").each(function(new_line_no){
					$(this).attr("name","payment_amount" + (+new_line_no + 1));
				})
				$(".memo").each(function(new_line_no){
					$(this).attr("name","memo" + (+new_line_no + 1));
				})
				$(".tw_remove_from_ui_flag").each(function(new_line_no){
					$(this).attr("name","tw_remove_from_ui_flag" + (+new_line_no + 1));
				})
			});

			$("#update_btn").on("click",function(){
				var cfm = confirm(LANG_RSC.phrase.sure_update)
				var line_num = $(".list_tr").length;
				if(cfm){
					document.master_payment_method.method="post";
					document.master_payment_method.action = "master_payment_method_action.cfm?line_num=" + line_num;
					document.master_payment_method.submit();					
				}


			});
		});
		$('.info-box').infoBox({
			animation: ['opacity', 'bottom'], //アニメーション 透過と位置
			animDuration: "fast", //アニメーション速度
			offsetX: 10, //x位置
			offsetY: 50, //y位置
			bottomPos: true, //bottomから表示するか
			rightPos: false //rightから表示するか
		})		

	})

	.on("blur",".price",function(){
		  	var a = $(this).val();
		  	var numcheck = numCheck(a);
		  	if(numcheck == 1){
		  	}else{
		  		$(this).val('').focus();
				alert(LANG_RSC.phrase.only_number);
				return false;	  		
		  	}		  	
	})
	.on("blur",".no_comma",function(){
	  	var a = $(this).val()
		if (a.indexOf(',') != -1) {
		alert(LANG_RSC.phrase.no_comma);
			var commmacutName = a.split(",").join("");
			$(this).val(commmacutName).focus();
		    return false;
		}		  	
	}).on("click","#add_line",function(){
		var list_num = $(".list_tr").length;
		if(list_num >= 30){
			alert(LANG_RSC.phrase.over_max_registration)
			return false;
		}
		var new_list_num = +list_num + 1;
			var new_line = "<tr class='list_tr'>";
			    new_line += "<input type='hidden' name='receipt_method_id_" + new_list_num + "' value='' class='receipt_method_id'>";
			    new_line += "<td align='center' class='list_no'>" + new_list_num + "</td>";
			    new_line += "<td><input type='text' name='receipt_method_name1_" + new_list_num + "' class='no_comma receipt_method_name1' style='width:100px;'></td>";
			    new_line += "<td><input type='text' name='receipt_method_name2_" + new_list_num + "' class='no_comma receipt_method_name2' style='width:100px;'></td>";
			    new_line += "<td><input type='text' name='receipt_method_name3_" + new_list_num + "' class='no_comma receipt_method_name3' style='width:100px;'></td>";
			    new_line += "<td><select name='function_num" + new_list_num + "' class='no_comma function_num' ><option value='9999'>" + LANG_RSC.term.not_in_use + "</option><option value='28'>" + LANG_RSC.term.credit + "</option><option value='84'>" + LANG_RSC.term.other_payment_method + "</option><option value='85'>" + LANG_RSC.term.other_payment_method + "(" + LANG_RSC.term.no_change + ")" +"</option></select></td>";
			    new_line += "<td><select name='multiple_method_flag" + new_list_num + "' class='no_comma multiple_method_flag' ><option value='1'>" + LANG_RSC.term.ok + "</option><option value='0'>" + LANG_RSC.term.ng + "</option></select></td>";
			    new_line += "<td><select name='over_payable_flag" + new_list_num + "' class='no_comma over_payable_flag' ><option value='1'>" + LANG_RSC.term.ok + "</option><option value='0'>" + LANG_RSC.term.ng + "</option></select></td>";
			    new_line += "<td><input name='payment_amount" + new_list_num + "' class='no_comma payment_amount price' type='text' value='0' style='width:120px;text-align:right;' maxlength='30'></td>";
			    new_line += "<td><select name='tw_remove_from_ui_flag" + new_list_num + "' class='no_comma tw_remove_from_ui_flag' ><option value='0'>" + LANG_RSC.term.normal + "</option><option value='1'>" + LANG_RSC.term.deduct + "</option></select></td>";
			    new_line += "<td><input name='memo" + new_list_num + "' class='no_comma memo' type='text' value='' style='width:120px;text-align:right;' maxlength='30'></td>";
			    new_line += "<td width='20' align='center'><input class='line_del_btn' type='button' value='×'></td>";
			    new_line += "</tr>";

			$("#tbody").append(new_line);
		})
	 .on("click",".line_del_btn",function(){
	  	var idx = $(".line_del_btn").index(this);
	  	$(".list_tr").eq(idx).remove();
	  	$(".list_no").each(function(new_line_no){
	  		$(this).text(+new_line_no + 1);
	  	})
		$(".receipt_method_id").each(function(new_line_no){
			$(this).attr("name","receipt_method_id_" + (+new_line_no + 1));
		})
		$(".receipt_method_name1").each(function(new_line_no){
			$(this).attr("name","receipt_method_name1_" + (+new_line_no + 1));
		})
		$(".receipt_method_name2").each(function(new_line_no){
			$(this).attr("name","receipt_method_name2_" + (+new_line_no + 1));
		})
		$(".receipt_method_name3").each(function(new_line_no){
			$(this).attr("name","receipt_method_name3_" + (+new_line_no + 1));
		})
		$(".function_num").each(function(new_line_no){
			$(this).attr("name","function_num" + (+new_line_no + 1));
		})
		$(".multiple_method_flag").each(function(new_line_no){
			$(this).attr("name","multiple_method_flag" + (+new_line_no + 1));
		})
		$(".over_payable_flag").each(function(new_line_no){
			$(this).attr("name","over_payable_flag" + (+new_line_no + 1));
		})
		$(".payment_amount").each(function(new_line_no){
			$(this).attr("name","payment_amount" + (+new_line_no + 1));
		})
		$(".memo").each(function(new_line_no){
			$(this).attr("name","memo" + (+new_line_no + 1));
		})
		$(".tw_remove_from_ui_flag").each(function(new_line_no){
			$(this).attr("name","tw_remove_from_ui_flag" + (+new_line_no + 1));
		})
	});

</script>	
</div>
</div>
</body>
</html>