component{
	This.name="Hara";
	This.clientmanagement="yes";
	This.sessionmanagement="yes";
	This.sessiontimeout=CreateTimeSpan(365,0,0,0);
	This.datasource="haradb";
	This.pageencoding="UTF-8";

	// リクエストごとに実行
	function onRequestStart(){

		// 再起動後削除
		Application.path_delimiter = "/";

		Application.server_address = "https://tudmweb3.bestcloud.jp";
		Application.asset_url = "https://tudmweb3.bestcloud.jp/training/hara";
		
		// CFのシステムログのパス
		Application.syslog_path = "/opt/ColdFusion/cfusion/logs/";


	}
}
