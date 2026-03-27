<cfinclude template = "init.cfm">

<!--- screen_type --->
<cfset DETAIL = 1>
<cfset ADD = 2>
<cfset COPY = 3>
<cfset MODIFY = 4>

<cfif StructKeyExists(Form,"screen_type") and Form.screen_type neq "">
	<cfset screen_type = Form.screen_type>
<cfelse>
	<cfset screen_type = 1>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
		<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0">
<head>

<cfset company_code = "">
<cfset company_name = "">
<cfset postal_code = "">
<cfset address1 = "">
<cfset address2 = "">
<cfset tel_no = "">
<cfset fax_no = "">
<cfset memo = "">
<cfset char_create_datetime = "">
<cfset create_staff_code = "">
<cfset create_staff_name = "">
<cfset char_update_datetime = "">
<cfset update_staff_code = "">
<cfset update_staff_name = "">


<cfquery name="qGetAdmin">
	SELECT m_admin.company_code,
	       m_admin.company_name,
	       m_admin.postal_code,
	       m_admin.address1,
	       m_admin.address2,
	       m_admin.tel_no,
	       m_admin.fax_no,
	       m_admin.memo,
	       m_admin.create_datetime,
	       DATE_FORMAT(m_admin.create_datetime,'%Y/%m/%d %H:%i') char_create_datetime,
	       m_admin.create_staff_code,
	       m_admin.create_staff_name,
	       m_admin.update_datetime,
	       DATE_FORMAT(m_admin.update_datetime,'%Y/%m/%d %H:%i') char_update_datetime,
	       m_admin.update_staff_code,
	       m_admin.update_staff_name
	  FROM m_admin 
</cfquery>


<cfif screen_type eq COPY>
	<cfset bumon_code = "">

<cfelse>
	<cfset company_code = qGetAdmin.company_code>

</cfif>

<cfset company_name = qGetAdmin.company_name>
<cfset postal_code = qGetAdmin.postal_code>
<cfset address1 = qGetAdmin.address1>
<cfset address2 = qGetAdmin.address2>
<cfset tel_no = qGetAdmin.tel_no>
<cfset fax_no = qGetAdmin.fax_no>
<cfset memo = qGetAdmin.memo>
<cfset char_create_datetime = qGetAdmin.char_create_datetime>
<cfset create_staff_code = qGetAdmin.create_staff_code>
<cfset create_staff_name = qGetAdmin.create_staff_name>
<cfset char_update_datetime = qGetAdmin.char_update_datetime>
<cfset update_staff_code = qGetAdmin.update_staff_code>
<cfset update_staff_name = qGetAdmin.update_staff_name>





<cfquery name="qGetAuthority">
	  SELECT IFNULL(m_authority.m_staff_modify_flag, 0) as modify_flag
	    FROM m_staff LEFT OUTER JOIN m_authority ON m_staff.authority_code = m_authority.authority_code
	   WHERE m_staff.staff_code = <cfqueryparam value = "#Session.staff_code#" cfsqltype="cf_sql_varchar" maxlength="8">
</cfquery>

<cfif qGetAuthority.RecordCount gt 0>
	<cfset auth_modify_flag = qGetAuthority.modify_flag>
<cfelse>
	<cfset auth_modify_flag = 0>
</cfif>


<cfquery name="qGetAuthorityList">
	  SELECT m_authority.authority_code AS list_authority_code,
	         m_authority.authority_name AS list_authority_name
		FROM m_authority
	ORDER BY LPAD(m_authority.authority_code, 10, '0')
</cfquery>

	<cfif CGI.HTTP_REFERER CONTAINS "menu.cfm">
		<cfset hd_title="基本設定">
	<cfelse>
		<cfset hd_title="基本設定">
	</cfif>
	<cfoutput>
		<title>#hd_title#</title>
	</cfoutput>

	<cfinclude template="common/css.cfm">
	<cfinclude template="svg.cfm">

	<style>
	body{background: linear-gradient(360deg, #ffffff, #c5f8ff, #7ed4ff);}


		.menu_icon {
		width: 55px;
		height: 40px;
		line-height: 1.5;
		fill: rgb(255, 255, 255);
		vertical-align: middle;
		}


		.menu_bt{
			width:10%;
			min-width:100px;
			margin: 0 auto;
			border: none;
			font-size: 14px;
			text-align:center;
			padding:20px 5px 5px;
			background: linear-gradient(to bottom, rgba(135,224,253,1) 0%,rgba(89,202,255,1) 2%,rgba(88,148,252,1) 98%,rgba(7,147,255,1) 100%); 
			box-shadow: 0px 15px 8px rgba(0, 131, 213, 0.236);
			border-bottom:solid 2px rgb(0, 92, 185,0.8) ;
			border-radius:10px;
			color: rgb(255, 255, 255);
			transition: 0.5s;
		}
		.menu_bt:hover{
			background: linear-gradient(to bottom, rgba(135,224,253,1) 0%,rgba(33,184,255,1) 2%,rgba(44,120,249,1) 98%,rgb(38, 53, 255) 100%); 
			box-shadow: 0px 5px 10px rgba(101, 108, 119, 0.4);
			border-bottom:solid 1px rgb(0, 92, 185,1.0) ;
			color: rgb(255, 255, 255);
			transition: 0.3s;
			margin-top: 10px;
		}
		.menu_bt p{
			padding:0;
			padding-top:6px;
			margin:0;
			text-align:center;
		}


		.design_list{
			border:1px solid rgb(65, 135, 255);
		}
		.design_list li:first-child{background:rgb(235,235,235);border-top:none;}
		.design_list li{
			padding:15px;
			background:white;
			border-top: solid 1px rgb(123, 172, 255);
			}
		.design_input{
			border:solid 1px rgb(199, 199, 199);
			padding:7px 10px;
			margin:0;
			border-radius:3px;
		}
		.design_input:focus {
			outline:none;
				color: #3d3d3d;
				border: rgb(76, 146, 252) solid 1px;
				background:rgb(241, 251, 255);
				}

		/* -------------------テーブルCSS------------------------ */
		.design_table{
			margin:20px auto;
			border:1px solid rgb(65, 135, 255);
		}
		.design_table tbody td{
			padding:10px;
			background:white;
			border-top: solid 1px rgb(123, 172, 255);
			}
			.design_table th,td {
				border:solid 1px rgb(123, 172, 255);
				padding:10px;
			}
			.design_table th {
				background:rgb(229, 254, 220);
				width:125px;
			}
			.center_name {
				height:50px;

			}
			.wrap {
				width:500px;
				padding-top:50px;
			}
			/* .design_table{
			width:80%;
			margin:20px auto;
			border:1px solid rgb(65, 135, 255);
		}
		.design_table thead th{
			background:rgb(229, 254, 220);
			padding:10px;
			border-bottom:1px solid rgb(65, 135, 255);
		}
		.design_table tbody tr:first-child td{
			background:rgb(235, 235, 235);
			border-top:none;
		}
		.design_table tbody td{
			padding:10px;
			background:white;
			border-top: solid 1px rgb(123, 172, 255);
			} */


		/* -------------------チェックボックスCSS------------------------ */

		.checkbox01 {
			position: relative;
			padding-left: 16px;
			top: -3px;
		}

		/*inputを非表示にする*/
		.checkbox01 input {
			position: absolute;
			z-index: -1;
			opacity: 0;
		}

		/*選択されてない時のチェックボックス背景	*/
		.checkbox01_bg {
			position: absolute;
			top: 1px;
			left: 0;
			height: 16px;
			width: 16px;
			background: rgb(234, 251, 255);
			border: rgb(170, 201, 255) solid 1px;
			border-radius:3px;
		}

		.checkbox01:hover input~.checkbox01_bg,
		.checkbox01 input:focus~.checkbox01_bg {
			/* background: rgb(65, 135, 255); */
			border: rgb(143, 184, 255) solid 2px;
			cursor: pointer;
		}

		/*選択時のチェックボックス背景色	*/
		.checkbox01 input:checked~.checkbox01_bg {
			background: rgb(228, 245, 255);
		}

		/*チェックされてない時は見えないように非表示する。	*/
		.checkbox01_bg:after{
			content: '';
			position: absolute;
			display: none;
		}

		/*	チェックボックスを選択した時のチェック部分をブロック化して見せる*/
		.checkbox01 input:checked~.checkbox01_bg:after {
			display: block;
		}

		/*チェック部分*/
		.checkbox01_bg:after {
			left: 5px;
			top: 1px;
			width: 3px;
			height:10px;
			border: solid #004dd3;
			border-width: 0 2px 2px 0;
			transform: rotate(45deg);
		}
		/* チェックを押された後のボックス枠 */
		.checkbox01 input:checked~.checkbox01_bg{
			border: rgb(143, 184, 255) solid 2px;
		}

		.svg_icon{
		width: 16px;
		height: 16px;
		fill: rgb(0, 102, 170);
		}
		.svg_icon:hover{opacity: 0.5;}

		.postcode_icon{
			color:#d2691e;
			padding-right:10px;
		}
	</style>

</head>

<body>
<cfoutput>
	<!--- 詳細画面 --->
	<cfif screen_type eq DETAIL>
		<cfset hd_title="基本設定">
		<cfset hd_btn_back="">
		<cfif auth_modify_flag eq 1>
<!---			<cfset hd_btn_modify="">--->
		</cfif>

	<!--- 編集画面 --->
	<cfelseif screen_type eq MODIFY>
		<cfset hd_title="基本設定 変更">
		<cfset hd_btn_cancel="">
		<cfset hd_btn_update="">
	</cfif>

	<cfset hd_btn_back="menu">
	<cfinclude template = "header.cfm">
		

<div class="wrap">
	

<cfset company_name = qGetAdmin.company_name>
<cfset postal_code = qGetAdmin.postal_code>
<cfset address1 = qGetAdmin.address1>
<cfset address2 = qGetAdmin.address2>
<cfset tel_no = qGetAdmin.tel_no>
<cfset fax_no = qGetAdmin.fax_no>
<cfset memo = qGetAdmin.memo>
<cfset char_create_datetime = qGetAdmin.char_create_datetime>
<cfset create_staff_code = qGetAdmin.create_staff_code>
<cfset create_staff_name = qGetAdmin.create_staff_name>
<cfset char_update_datetime = qGetAdmin.char_update_datetime>
<cfset update_staff_code = qGetAdmin.update_staff_code>
<cfset update_staff_name = qGetAdmin.update_staff_name>

<cfif screen_type eq DETAIL>
	
	<table class="design_table" style="width:500px;">
	<tr>
		<th class="center_name">センター名</th>
		<td style="font-size:18px;">#company_name#</td>
	</tr>
	</table>

	<table class="design_table" style="width:500px;">
	<tr>
		<th rowspan="2">住　所</th>
		<td><a class="postcode_icon">〒</a>#postal_code#</td>
	</tr>
	<tr>
		<td>#address1#</td>
	</tr>
	<!--- <tr>
		<td>#address2#</td>
	</tr> --->
	</table>

	<table class="design_table" style="margin-left:0;" >
	<tr>
		<th style="width:105px;">T E L</th>
		<td style="width:130px;">#tel_no#</td>
	</tr>
<tr>
		<th>F A X</th>
		<td>#fax_no#</td>
	</tr>
	</table>
</cfif>

	
</div>

</cfoutput>

<img src="images/leaf.png" width="400" height="345" alt="leaf" style="position:fixed; z-index:-1; bottom:0; opacity:0.6;">
</body>
</html>
