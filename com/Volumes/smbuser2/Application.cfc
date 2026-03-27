component{
  This.name="test";
  This.clientmanagement="yes";
  This.sessionmanagement="yes";
  This.sessiontimeout=CreateTimeSpan(7,0,0,0);
  This.datasource="testdb";
  This.pageencoding="UTF-8";
	//※アプリケーションが起動したときに１回しか実行されないため、変更したらCFを再起動すること！ 例：systemctl restart cf2018
  function onApplicationStart(){
    // Application.server_address = "https://tudmweb.bestcloud.jp";
    // Application.asset_url = "https://tudmweb.bestcloud.jp/test";
    Application.dir_separator = "/";
    //ドキュメントルート
    Application.document_root = "/var/www/html";
    //システムパス
    Application.system_dir = "/var/www/html/test";
    //一時用ファイルパス
    // Application.temp_dir = Application.system_dir & "/temp";

		//cfm、js、cfc間で使用するデータ区切り文字
		Application.val_delimiter = chr(7);

    // Application.api_key = "AIzaSyAa9wFkSuAXII-jK92mBicemwZXb7X3Lgo";
    // Application.google_geo_url = "https://maps.googleapis.com/maps/api/geocode/json";

    // Application.sms_key = "px_9LgZyzmbGD2G3cL0ch16Z1Y0454";
    // Application.aws_sms_url = "https://mlwtppw2277qk5avwe7zg7wetq0yxbvo.lambda-url.ap-northeast-1.on.aws/";    

  }
  //リクエストごとに実行
  function onRequestStart(){
    // Application.server_address = "https://tudmweb.bestcloud.jp";
    // Application.asset_url = "https://tudmweb.bestcloud.jp/test";
    Application.dir_separator = "/";
    //ドキュメントルート
    Application.document_root = "/var/www/html";
    //システムパス
    Application.system_dir = "/var/www/html/test";
    //一時用ファイルパス
    // Application.temp_dir = Application.system_dir & "/temp";
    //画像保存用ファイルパス
    // Application.support_path = "/var/local/test/";


    //Application.asset_url = "https://tudmweb.bestcloud.jp/test";
    Application.val_delimiter = chr(7);
    Application.delimiter = "/";

    // Application.api_key = "AIzaSyAa9wFkSuAXII-jK92mBicemwZXb7X3Lgo";
    // Application.google_geo_url = "//maps.googleapis.com/maps/api/geocode/json";

    // Application.sms_key = "px_9LgZyzmbGD2G3cL0ch16Z1Y0454";
    // Application.aws_sms_url = "https://mlwtppw2277qk5avwe7zg7wetq0yxbvo.lambda-url.ap-northeast-1.on.aws/";

    // Application.developing_flag = true;



  }
}
