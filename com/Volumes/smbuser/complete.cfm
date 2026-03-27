<!DOCTYPE html>
<html lang="ja">
<!--- 申込者 1:社員 2:会員 3:トークン --->
<cfif IsDefined("session.emp_code") and session.emp_code neq "">
  <cfset applier = 1>
<cfelseif IsDefined("session.customer_code") and session.customer_code neq "">
  <cfset applier = 2>
<cfelse>
  <cfset applier = 3>
</cfif>
<head>
    <cfset css_file = "complete.css">
    <cfoutput>
        <link rel="stylesheet" href="#application.base_url#css2/tmail.css">
    </cfoutput>
    <cfinclude template="header3.cfm">
</head>
<body>
    <cfoutput>
        <cfif IsDefined("url.kind") and url.kind eq 1>
            <div class="contents">
                <div class="title_contents">
                    <nav class="breadcrum fade">
                        &nbsp;
<!---                         <ul>
                            <a href="#application.base_url#">
                                <li>TOP</li>
                            </a>
                            <span class="migi">></span>
                            <a href="#application.base_url#signup/complete?kind=1">
                                <li><span>メールアドレス登録完了</span></li>
                            </a>
                        </ul> --->
                    </nav>

                    <div class="signup_title">
                        メールアドレス登録完了
                    </div>
                    <div class="signup_area">
                      
                        <div class="signup_flow" id="pc">    
                          <span style="color:##D44F1C;">1.メールアドレス登録&nbsp;&nbsp;</span>
                          <span style="color:##d3d3d3;">&nbsp;&nbsp;-&nbsp;&nbsp;2.会員情報入力</span>
                          <span style="color:##d3d3d3;">&nbsp;&nbsp;-&nbsp;&nbsp;3.入力内容確認</span>
                          <span style="color:##d3d3d3;">&nbsp;&nbsp;-&nbsp;&nbsp;4.会員登録完了</span>
                        </div>

                        <div class="signup_flow" id="sp">    
                          <span style="color:##D44F1C;">1.メールアドレス登録</span>
                          <span style="color:##d3d3d3;">2.会員情報入力</span>
                          <span style="color:##d3d3d3;">3.入力内容確認</span>
                          <span style="color:##d3d3d3;">4.会員登録完了</span>
                        </div>
                        <div class="contents_container">
                            お申込み有り難うございます。<br>
                            メールアドレスの登録が完了しました<br><br>
                            なお、現在は仮登録の状態です。<br>
                            お手数ですが、確認メールを送信しましたので内容をご確認いただき、<br>
                            お手続きを進めてください。<br><br>
                            また、しばらくしてもメールが届かない場合、<br>
                            一度迷惑メール用のメールボックス等をご確認いただき、<br>
                            それでも見当たらないようであれば、<br>
                            お手数をおかけしますが、その旨下記までご連絡いただければ幸いです。<br><br>
                            ◆お問い合わせ：TEL:03-5793-9765<br>
                              　　　　　　　　FAX:03-5793-9766
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#seminar_list'">セミナーを選ぶ</button>
                        </div>
                      
                    </div>
                </div>
            </div>            
        
        <cfelseif IsDefined("url.kind") and url.kind eq 2>
            <nav class="breadcrum fade">
                &nbsp;
<!---                 <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#signup/complete?kind=2">
                        <li><span>会員登録完了</span></li>
                    </a>
                </ul>
 --->            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title">
                        会員登録完了
                    </div>
                    <div class="signup_area">
                      
                        <div class="signup_flow" id="pc">    
                          <span style="color:##d3d3d3;">1.メールアドレス登録&nbsp;&nbsp;</span>
                          <span style="color:##d3d3d3;">&nbsp;&nbsp;-&nbsp;&nbsp;2.会員情報入力</span>
                          <span style="color:##d3d3d3;">&nbsp;&nbsp;-&nbsp;&nbsp;3.入力内容確認</span>
                          <span style="color:##D44F1C;">&nbsp;&nbsp;-&nbsp;&nbsp;4.会員登録完了</span>
                        </div>

                        <div class="signup_flow" id="sp">    
                          <span style="color:##d3d3d3;">1.メールアドレス登録</span>
                          <span style="color:##d3d3d3;">2.会員情報入力</span>
                          <span style="color:##d3d3d3;">3.入力内容確認</span>
                          <span style="color:##D44F1C;">4.会員登録完了</span>
                        </div>
                        <div class="contents_container">
                          ご登録いただき誠にありがとうございます。<br>
                          確認メールを送信しましたので内容をご確認ください。<br><br>
                          なお、しばらくしてもメールが届かない場合、<br>
                          一度迷惑メール用のメールボックス等をご確認いただき、<br>
                          それでも見当たらないようであれば、<br>
                          お手数をおかけしますが、その旨下記までご連絡いただければ幸いです。<br><br>
                          ◆お問い合わせ：TEL:03-5793-9765<br>
                          　　　　　　　　FAX:03-5793-9766
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#seminar_list'">セミナーを選ぶ</button>
                        </div>
                      
                    </div>
                </div>
            </div>
        <cfelseif IsDefined("url.kind") and url.kind eq 3><!--- アンケート --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#complete?kind=3">
                        <li><span>アンケート送信完了</span></li>
                    </a>
                </ul>
            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title">
                        アンケート送信済み
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                          貴重なご意見を賜りましてありがとうございます。<br><br>
                          ◆お問い合わせ：TEL:03-5793-9765<br>
                          　　　　　　　　FAX:03-5793-9766
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#'">トップページへ</button>
                        </div>
                      
                    </div>
                </div>
            </div>

        <cfelseif IsDefined("url.kind") and url.kind eq 4><!--- パスワード再設定 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#complete?kind=4">
                        <li><span>パスワードの再設定</span></li>
                    </a>
                </ul>
            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title">
                        パスワードの再設定
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                        パスワード再設定用のご案内メールを送信しました。<br>
                        メール本文中のURLをクリックしてお手続きを行って下さい 。<br><br>
                         <!---  ◆お問い合わせ：TEL:03-5793-9765<br>
                          　　　　　　　　FAX:03-5793-9766 --->
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#'">トップページへ</button>
                        </div>
                      
                    </div>
                </div>
            </div>

        <cfelseif IsDefined("url.kind") and url.kind eq 5><!--- パスワード再設定完了 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#complete?kind=5">
                        <li><span>パスワードの再設定完了</span></li>
                    </a>
                </ul>
            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title">
                        パスワードの再設定完了
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                        パスワードの再設定が完了しました。<br><br>
                          ◆お問い合わせ：TEL:03-5793-9765<br>
                          　　　　　　　　FAX:03-5793-9766
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#login'">ログイン</button>
                        </div>
                      
                    </div>
                </div>
            </div>
        <cfelseif IsDefined("url.kind") and url.kind eq 6><!--- レジュメ入力完了 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                &nbsp;
            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title" style="margin-bottom:20px;">
                        レジュメ入力完了
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                        ご多忙の折、ご送信いただきましてありがとうございます。<br>
                        なお、現在のパスワードは無効になりましたので、もし修正等がございましたら、下記までご連絡ください。<br><br>
                        <cfscript>
                          structClear(session);
                        </cfscript>
                          ◆お問い合わせ：TEL:03-5793-9765<br>
                          　　　　　　　　FAX:03-5793-9766
                        </div>
<!---                         <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#login'">ログイン</button>
                        </div> --->
                      
                    </div>
                </div>
            </div>

        <cfelseif IsDefined("url.kind") and url.kind eq 7><!--- 問い合わせ完了 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#complete?kind=7">
                        <li><span>問合せ受付</span></li>
                    </a>
                </ul>
            </nav>

            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title" style="margin-bottom:20px;">
                        問合せ受付
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                            お問合せを頂きまして、ありがとうございます。<br><br>
                            内容を確認致しまして、担当者よりご連絡致しますので今しばらくお待ち下さい。<br>
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#'">トップページへ</button>
                        </div>
                      
                    </div>
                </div>
            </div>
        <cfelseif IsDefined("url.kind") and url.kind eq 8><!--- 会員情報変更終了 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                &nbsp;
            </nav>
            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title">
                        会員情報更新完了
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#'">トップページへ</button>
                        </div>
                      
                    </div>
                </div>
            </div>
        <cfelse><!--- 申し込み完了 --->
            <!--- ↓これを消さないように。消すと表示がおかしくなる --->
            <nav class="breadcrum fade">
                &nbsp;
<!---                 <ul>
                    <a href="#application.base_url#">
                        <li>TOP</li>
                    </a>
                    <span class="migi">></span>
                    <a href="#application.base_url#signup/complete?kind=4">
                        <li><span>お申込み完了</span></li>
                    </a>
                </ul> --->
            </nav>

            <div class="contents">
                <div class="title_contents">
                    <div class="signup_title" style="margin-bottom:20px;">
                        お申込み完了
                    </div>
                    
                    <div class="signup_area">
                        <div class="contents_container">
                            <cfif applier eq 1>
                            お申し込みが完了しました。<br><br>
                            続けてお申し込みする場合は、セミナーを選択して同様にお手続きしてください。
                            <cfelse>
                              お申し込みいただきましてありがとうございます。<br>
                              受付メールを送信しましたので内容をご確認ください。<br>
                              なお、しばらくしてもメールが届かない場合、<br>
                              一度迷惑メール用のメールボックス等をご確認いただき、<br>
                              それでも見当たらないようであれば、<br>
                              お手数をおかけしますが、その旨下記までご連絡いただければ幸いです。<br><br>
                              ◆お問い合わせ：TEL:03-5793-9765<br>
                              　　　　　　　　FAX:03-5793-9766
                            </cfif>
                        </div>
                        <div class="contents_btn">
                          <button class="bt_g1" onclick="location.href='#application.base_url#seminar_list'">セミナーを選ぶ</button>
                        </div>                      
                    </div>
                </div>
            </div>


        </cfif>

    </cfoutput>
<cfinclude template="footer3.cfm">
</body>
</html>


<!-- Localized -->
<!-- Localized -->