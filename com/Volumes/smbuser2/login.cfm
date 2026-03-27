<cfinclude template="init.cfm">

<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!--- <meta name=viewport content="width=device-width, initial-scale=1"> --->
<meta name="viewport" content="width=1762">

<link rel="stylesheet" type="text/css" href="css/base/jquery.ui.all.css">
<link rel="stylesheet" type="text/css" href="css/style.css?18091202">
<link rel="stylesheet" type="text/css" href="css/jquery.mouseinfobox.css">
<link rel="shortcut icon" href="image/favicon.ico">

<title>ログイン</title>
</head>

<body>

<header class="header">
	<ul class="d-menu">
		<li style="width:100%; text-align:left; padding:10px 0px 0px 20px; position:absolute;">
			<a href="##"><img src="image/logo.svg" width="140" height="26"></a>
		</li>
		<li style="width:100%; line-height: 50px; text-align: center;">
			<cfoutput>
			利&nbsp;用&nbsp;状&nbsp;況&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(Now(),'yyyy/mm/dd')# (#Mid(DayofWeekAsString(DayofWeek(Now())), 1, 1)#)
			</cfoutput>
		</li>
	</ul>
</header>


<cfoutput>
<cfscript>
	structClear(session);
</cfscript>

<form name="login_form">
	<input type="hidden" id="p-default-pass" value="#Application.default_password#">
	<input type="hidden" value="#Application.server_address#" id="server_url">
	
	<div style="width:350px; margin: 120px auto 30px;" align="center">
		<div style="display:table-cell;" >
			<input type="radio" name="login_type" class="radio-input" id="radio-01" value="1" checked="checked" >
			<label for="radio-01">スタッフ用&nbsp;&nbsp;&nbsp;</label>
			<input type="radio" name="login_type" class="radio-input" id="radio-02" value="2">
			<label for="radio-02">会員用</label>			
		</div>
	</div>
	<div>
		<label2>&nbsp;I&nbsp;&nbsp;D</label2>
		<input type="text" id="p-id" class="w50 p-tab-index" maxlength="100">
	</div>
	<div>
        <label2>&nbsp;Password</label2>
		<input type="password" id="p-pass" class="w50 p-tab-index" maxlength="40">
	</div>
	
	<div id="p-login-btn" class="bt1">
		ロ　グ　イ　ン
	</div>
</form>

</cfoutput>


<script src="js/jquery-1.9.1.min.js"></script>
<script src="js/fastclick.js"></script>
<script src="js/jquery-ui.js"></script>
<script src="js/jquery.ui.datepicker-ja.js"></script>
<script src="js/jquery.mouseinfobox.js"></script>
<!--- <script src="js/login.min.js?19071201"></script> --->
<script src="js/login.js?1"></script>


</body>
</html>
