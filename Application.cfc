component {
	This.name = "Hara";
	This.clientmanagement = "yes";
	This.sessionmanagement = "yes";
	This.sessiontimeout = CreateTimeSpan(365,0,0,0);
	This.datasource = "haradb";
	This.pageencoding = "UTF-8";

	function onRequestStart() {

		Application.path_delimiter = "/";

		Application.server_address = "https://tudmweb3.bestcloud.jp";
		Application.asset_url = "https://tudmweb3.bestcloud.jp/training/hara";

		// URLではなくサーバー上の実パスにする
		Application.root_path = "/var/www/html/training/hara";
		Application.temp_path = Application.root_path & Application.path_delimiter & "temp";

		// export用
		Application.export_db_sh = Application.root_path & Application.path_delimiter & "sh" & Application.path_delimiter & "export_db.sh";

		// DB接続情報
		Application.db_user = "hara";
		Application.db_pass = "haraApp1392##";
		Application.db_host = "tudmweb3.bestcloud.jp";
		Application.db_name = "haradb";

		// CFのシステムログのパス
		Application.syslog_path = "/opt/ColdFusion/cfusion/logs/";
	}
}