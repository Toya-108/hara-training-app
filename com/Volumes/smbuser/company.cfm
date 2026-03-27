<!DOCTYPE html>
<html lang="ja">
<head>
    <cfset css_file = "company.css?12">
    <cfset left_header_title = "会社概要">
    <cfinclude template="header3.cfm">
    <style>
	    .ie_width_a{
	    	width:117px;
	    	letter-spacing:20px;
	    }
	    .ie_width_b{
	    	width:97px;
	    	letter-spacing:10px;
	    }	    	    
	    .ie_width_b2{
	    	width:120px;
	    	letter-spacing:4px;
	    }
	    .ie_width_b3{
	    	width:96px;
	    	letter-spacing:4px;
	    }
	    .ie_width_c{
	    	width:194px;
	    	letter-spacing:4px;
	    }
	    .ie_width_d{
	    	width:158px;
	    }	    	    	    	    	    
	    .ie_width_e{
	    	width:174px;
	    }
	    .ie_width_f{
	    	width:173px;
	    	letter-spacing:0.1px;
	    }
	    .ie_width_g{
	    	width:180px;
	    	letter-spacing:24px;
	    }

	    .ch_width_a{
	    	width:60px;
	    	/* letter-spacing:19px; */
	    }

	    .ch_width_b{
	    	width:97px;
	    	letter-spacing:9px;
	    }
	    .ch_width_b2{
	    	width:105px;
	    	letter-spacing:4px;
	    }

	    .ch_width_b3{
	    	width:92px;
	    	letter-spacing:4px;
	    }

	    .ch_width_c{
	    	width:199px;
	    	letter-spacing:4px;
	    }
	    .ch_width_d{
	    	width:152px;
	    }	    	    	    	    	    
	    .ch_width_e{
	    	width:180px;
	    }
	    .ch_width_f{
	    	width:172px;
	    	letter-spacing:0.1px;
	    }

	    .ch_width_g{
	    	width:173px;
	    	letter-spacing:24px;
	    }


	    .ie_mice{
	    	letter-spacing:0.8px;
	    }
	    .ch_mice{
	    	letter-spacing:0.1px;
	    }
      span.yakushoku{
        /* font-weight:500; */
        font-family:san-serif;
        /* font-size:17px; */
        /* color:rgba(30,30,30,1.00); */
      }

    </style>


    <header>
        <cfoutput>
        <div class="swiper-container">
            <div class="swiper-wrapper">
                <div class="swiper-slide">
                    <img src="#application.base_url#image/main-visual-1-2.jpg?12" alt="ヘッダー画像" class="main-visual pc" id="pc">
                    <img src="#application.base_url#image/keyvisual_sp_1_2.jpg?12" alt="ヘッダー画像" class="main-visual sp" id="sp">
                </div>
                <div class="swiper-slide">
                    <img src="#application.base_url#image/main-visual-2-2.jpg?12" alt="ヘッダー画像" class="main-visual pc" id="pc">
                    <img src="#application.base_url#image/keyvisual_sp_2_2.png?122" alt="ヘッダー画像" class="main-visual sp" id="sp">
                </div>
                <div class="swiper-slide">
                    <img src="#application.base_url#image/main-visual-3-2.jpg?12" alt="ヘッダー画像" class="main-visual pc" id="pc">
                    <img src="#application.base_url#image/keyvisual_sp_3_2.jpg?12" alt="ヘッダー画像" class="main-visual sp" id="sp">
                </div>
            </div>
        </div>
        </cfoutput>
        
        
    </header>

</head>
<body>
  <cfinclude template="common_body.cfm">
    <cfoutput>
        <nav class="breadcrum fade">
            <ul>
                <a href="#application.base_url#">
                    <li>TOP</li>
                </a>
                <span class="migi">></span>
                <a href="#application.base_url#company">
                    <li><span>会社概要</span></li>
                </a>
            </ul>
        </nav>

    </cfoutput>
    
    <!-- ========== /header ========== -->
    
		<div class="title">Company</div>
	
<p class="text" id="pc">“「政」と「官」と「民」との知の懸け橋”として</p>
<p class="text" id="pc">国家政策やナショナルプロジェクトの敷衍化を支え、国家知の創造を目指す</p>
<p class="text" id="pc">幹部・上級管理職の事業遂行支援事業。</p>
<p class="text" id="pc">半世紀にわたり　1万6千回以上</p>
<p class="text" id="pc">少人数によるプライベートな雰囲気のセミナーを開催</p>
<p class="text" id="pc">延べ2万人を超える講師陣が</p>
<p class="text" id="pc">45万人を超える参加者に熱く語り続けてまいりました。</p>
<p class="text" id="pc">私たちＪＰＩ（日本計画研究所）は</p>
<p class="text" id="pc">「新しい時代を切り拓く水先案内人」「羅針盤」で</p>
<p class="text" id="pc">あり続けます。</p>


<p class="text" id="sp">“「政」と「官」と「民」との</p>
<p class="text" id="sp">知の懸け橋”として国家政策や</p>
<p class="text" id="sp">ナショナルプロジェクトの敷衍化を支え</p>
<p class="text" id="sp">国家知の創造を目指す</p>
<p class="text" id="sp">幹部・上級管理職の事業遂行支援事業。</p>
<p class="text" id="sp">半世紀にわたり　1万5千回以上</p>
<p class="text" id="sp">少人数によるプライベートな</p>
<p class="text" id="sp">雰囲気のセミナーを開催</p>
<p class="text" id="sp">延べ2万人を超える講師陣が</p>
<p class="text" id="sp">45万人を超える参加者に</p>
<p class="text" id="sp">熱く語り続けてまいりました。</p>
<p class="text" id="sp">私たちＪＰＩ（日本計画研究所）は</p>
<p class="text" id="sp">「新しい時代を切り拓く水先案内人」</p>
<p class="text" id="sp">「羅針盤」であり続けます。</p>

		
	
<table class="company" width="" border="0">
  <tbody>
    <tr>
      <th>名称</th>
		<td>株式会社JPI（日本計画研究所）</td>
    </tr>
	  <tr>
      <th>英文名</th>
		<td>Japan Planning Institute（JPI）</td>
    </tr>
	  <tr>
      <th>設立</th>
		<td>1974年（昭和49年）１０月</td>
    </tr>
	  <tr>
      <th>資本金</th>
		<td>5,000万円</td>
    </tr>
	  <tr>
      <th>取引銀行</th>
		  <td><small>三井住友銀行本店営業部</small><br>
			  <small>三菱UFJ銀行麹町中央支店</small></td>
    </tr>

	  <tr>
      <th>役　員</th>
		<td>
			<!--- <ul class="namelist"><li><small>取締役会長</small></li><li>武内&nbsp;一忠</li></ul> --->
			<ul class="namelist"><li><small>代表取締役社長</small></li><li>武内&nbsp;利枝</li></ul>
			<!--- <ul class="namelist"><li><small>取 締 役<span class="mini">(&nbsp;グ&nbsp;ロ&nbsp;ー&nbsp;バ&nbsp;ル&nbsp;事&nbsp;業&nbsp;開&nbsp;発&nbsp;担&nbsp;当&nbsp;)</span></small>大前&nbsp;&nbsp;毅</li></ul> --->
			<ul class="namelist"><li><small>取 締 役</small>武内&nbsp;龍太郎</li></ul>
      <ul class="namelist"><li><small>取 締 役</small>大前&nbsp;毅</li></ul>
			<!--- <ul class="namelist"><li><small>編集局　企画開発部門　&nbsp;&nbsp;主任研究員</small></li><li>吉澤&nbsp;文美</li></ul> --->
			<ul class="namelist"><li><small>編集局　企画開発部門<span class="yakushoku" id="person2" style="text-align:right;display:inline-block;">研究員</span></small></li><li>中島&nbsp;千世</li></ul>
			<ul class="namelist"><li><small>編集局　企画開発部門<span class="yakushoku" id="person11" style="text-align:right;display:inline-block;">研究員</span></small></li><li>萩原&nbsp;玲子</li></ul>
      <ul class="namelist"><li><small>編集局　企画開発部門<span class="yakushoku" id="person3" style="text-align:right;display:inline-block;">研究員</span></small></li><li>吉澤&nbsp;文美</li></ul>
			<!--- <ul class="namelist"><li><small>編集局　企画開発部門<span id="person3" style="text-align:right;display:inline-block;">研究員</span></small></li><li>渡辺&nbsp;桂子</li></ul> --->
            <!--- <ul class="namelist"><li><small>編集局　企画開発部門　<span id="person3" style="text-align:right;display:inline-block;">企画参与</span></small></li><li>周藤&nbsp;敏雄</li></ul> --->
			<ul class="namelist"><li><small style="letter-spacing:0.1px;">マーケティング・ビジネス戦略局</small></li></ul>
      <ul class="namelist"><li><small style="letter-spacing:0.1px;">マーチャンダイジング事業部</small></li></ul>				
			<!--- <ul class="namelist" style=""><li><small style="letter-spacing:0.1px;">CMO（チーフマーチャンダイジングオフィサー）</small></li><li>武内&nbsp;龍太郎</li></ul> --->
			<ul class="namelist" style=""><li><small style="letter-spacing:0.1px;"><span class="" id="person12" style="display:inline-block;letter-spacing:1.5px;margin-left:30px">主任研究員</span></small></li><li>町村&nbsp;ルミ子</li></ul>
      <ul class="namelist" style=""><li><small style="letter-spacing:0.1px;"><span class="" id="person5" style="display:inline-block;letter-spacing:1.5px;margin-left:30px">主任研究員</span></small></li><li>飯島&nbsp;幸世</li></ul>
      <ul class="namelist"><li><small style="letter-spacing:0.1px;">デジタルマーケティング事業部</small></li></ul>
      <!--- <ul class="namelist" style=""><li><small style="letter-spacing:0.1px;">CMO（チーフマーケティングオフィサー）</small></li><li>真田&nbsp;美恵子</li></ul> --->
      

      
			<!--- <ul class="namelist" style=""><li><small style="letter-spacing:0.1px;">デジタルマーケティング事業部<span class="yakushoku" id="person13" style="text-align:right;display:inline-block;">主任研究員</span></small></li><li>真田&nbsp;美恵子</li></ul> --->
			<!--- <ul class="namelist"><li><small>営業・マーケティング局<span id="person4" style="text-align:right;display: inline-block;">次&thinsp;長</span></small></li><li>武藤&nbsp;哲</li></ul> --->
			<!--- <ul class="namelist"><li><small>役&nbsp;員&nbsp;室<span id="person5" style="text-align:right;display:inline-block;">社長秘書&thinsp;兼&thinsp;業務担当</span></small></li><li>藤木&nbsp;高子</li></ul> --->
			<!--- <ul class="namelist"><li><small>役&nbsp;員&nbsp;室<span id="person5" style="text-align:right;display:inline-block;">社長秘書&thinsp;兼&thinsp;総務担当</span></small></li><li>萩原&nbsp;玲子</li></ul> --->
			<!--- <ul class="namelist"><li><small>ＭＩＣＥ事業部<span id="person6" style="text-align:right;display: inline-block;">Ｍ&thinsp;Ｃ</span></small></li><li>渡辺&nbsp;桂子</li></ul>
			<ul class="namelist"><li><small>ＭＩＣＥ事業部<span id="person7" style="text-align:right;display: inline-block;">Ｍ&thinsp;Ｃ</span></small></li><li>三木&nbsp;成美</li></ul>
			 --->
<!--- 
			<ul class="namelist"><li><small>ＭＩＣＥ事業局<span class="yakushoku" id="person7" style="text-align:right;display: inline-block;">局&thinsp;長</span></small></li><li>服部&nbsp;幸加</li></ul>
       --->
			<!--- <ul class="namelist"><li><small>ブランド戦略局<span id="person12" style="text-align:right;display: inline-block;">局&thinsp;長</span></small></li><li>板谷&nbsp;友香里</li></ul> --->
			<!--- <ul class="namelist"><li><small class="mice">ＭＩＣＥ事業部<span id="person6" class="mc_mice" style="text-align:right;display:inline-block;">Ｍ&thinsp;Ｃ(&thinsp;Master of ceremonies&thinsp;)</span></small></li><li>渡辺&nbsp;桂子</li></ul> --->
			<!---
			<ul class="namelist"><li><small class="mice">ＭＩＣＥ事業部<span id="person7" class="mc_mice" style="text-align:right;display:inline-block;">Ｍ&thinsp;Ｃ(&thinsp;Master of ceremonies&thinsp;)</span></small></li><li>三木&nbsp;成美</li></ul>
			<ul class="namelist"><li><small class="mice">ＭＩＣＥ事業部<span id="person9" class="mc_mice" style="text-align:right;display:inline-block;">Ｍ&thinsp;Ｃ(&thinsp;Master of ceremonies&thinsp;)</span></small></li><li>藤本&nbsp;有賀</li></ul>
			<ul class="namelist"><li><small class="mice">ＭＩＣＥ事業部<span id="person10" class="mc_mice" style="text-align:right;display:inline-block;">Ｍ&thinsp;Ｃ(&thinsp;Master of ceremonies&thinsp;)</span></small></li><li>金子&nbsp;明香</li></ul>
			--->
			<ul class="namelist"><li><small>制作業務局<span class="yakushoku" id="person8" style="text-align:right;display: inline-block;">クリエーター</span></small></li><li>焼広&nbsp;怜美</li></ul>
			<ul class="namelist"><li><small>監&nbsp;査&nbsp;役</small></li><li>荒木&nbsp;清子</li></ul>			
<!--- 			<ul class="namelist"><li><small>役員室　社長秘書　</small></li><li>船津&nbsp;恵津子</li></ul>
			<ul class="namelist"><li><small>役員室・制作局・経理局　所&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;管　</small></li><li>野口&nbsp;明子</li></ul>
			<ul class="namelist"><li><small>監&nbsp;査&nbsp;役</small></li><li>荒木&nbsp;清子</li></ul> --->
			
		  </td>
    </tr>
	  <tr>
      <th>顧　問</th>
      <td><ul class="namelist"><li><small>弁&nbsp;護&nbsp;士</small></li><li>鵜澤&nbsp;亜紀子</li></ul>
        <ul class="namelist"><li><small>税&nbsp;理&nbsp;士</small></li><li>清和&nbsp;邦子</li></ul>
        <ul class="namelist"><li><small>特定社会保険労務士</small></li><li>小泉&nbsp;正典</li></ul>

      </td>
    </tr>
  </tbody>
</table>
<table class="company1" width="" border="0">
	<tr>
		<td>
			<div>
        <div class="fl_container">
          <div class="fl">
            <p class="text title_text">国内・提携機関：<span class="jihyou">株式会社 時 評 社</span></p>
            <p class="text">中央省庁等の「人と政策」に関する情報をはじめ</p>
            <p class="text">主要官庁幹部の政策に関する論文、全省庁の人事・横顔を伝え続け創業50有余年の歴史、</p>
            <p class="text">出版の枠を越えた行政総合情報カンパニー</p>
            <p class="text">〒100-0013東京都千代田区霞が関3-4-2</p>
            <p class="text">商工会館・弁理士会館ビル6F</p>
            <p class="text">TEL：03-3580-6633　FAX：03-3580-6634</p>
            <p class="text"><a href="http://www.jihyo.co.jp/" target="_blank">https://www.jihyo.co.jp/</a></p>

          </div>
          <div class="fl">
                    <p class="text title_text">英国・提携機関：<span>ＥＪＥＦ</span></p>
            <p class="text">本物にこだわる大人のための、由緒正しい英国語学スクール</p>
            
            <p class="text">「ビジネス英語コース」「外交官コース」「中央省庁コース」「大学・大学院準備コース」他</p>
            <p class="text">Lane End, High Wycombe, Buckinghamshire HP14 3HH England</p>
            <p class="text">TEL: +44-(0)1494-882091 　FAX: +44-(0)1494-882321</p>
            <p class="text"><a href="https://www.ejef.co.uk/" target="_blank">https://www.ejef.co.uk/</a></p>
          </div>
        </div>
			</div>
		</td>	
	</tr>
</table>
    <cfoutput>
      <div class="company_banar" style="margin-bottom:100px;">
          <div>
            <img src="#application.base_url#image/Image_78cbd96.jpg">
          </div>
          <div style="margin-top:30px;font-size:17px;">
            交通のご案内など弊社へのアクセスの詳細は<a href="#application.base_url#/access" style="color:blue;">こちら</a>のページをご確認ください。
          </div>
      </div>


    </cfoutput>


    <div class="footer">
            
    </div>
  <cfinclude template="footer3.cfm">
<cfoutput>
	<script type="text/javascript" src="#application.base_url#js/jquery-1.9.1.min.js"></script>
</cfoutput>

<script>
  	$(document).on("ready",function(){
		var userAgent = window.navigator.userAgent.toLowerCase();

		if(userAgent.indexOf('msie') != -1 || userAgent.indexOf('trident') != -1 ) {
			//IE
			$("#person1").addClass("ie_width_a");
			$("#person2").addClass("ie_width_a");
			$("#person3").addClass("ch_width_a");
			$("#person4").addClass("ie_width_b2");
			$("#person5").addClass("ie_width_c");
			$("#person6").addClass("ie_width_f");
			$("#person7").addClass("ie_width_g");
			$("#person8").addClass("ie_width_e");
			$("#person9").addClass("ie_width_f");
			$("#person10").addClass("ie_width_f");
			$("#person11").addClass("ie_width_a");
			$("#person12").addClass("ie_width_g");
			$("#person13").addClass("ie_width_b3");
			$(".mice").addClass("ie_mice");
			$(".mc_mice").css("font-size","12px");

		// } else if(userAgent.indexOf('edge') != -1) {

		} else {
			$("#person1").addClass("ch_width_a");
			$("#person2").addClass("ch_width_a");
			$("#person3").addClass("ch_width_a");
			$("#person4").addClass("ch_width_b2");
			$("#person5").addClass("ch_width_c");
			$("#person6").addClass("ch_width_f");
			$("#person7").addClass("ch_width_g");
			$("#person8").addClass("ch_width_e");
			$("#person9").addClass("ch_width_f");
			$("#person10").addClass("ch_width_f");
			$("#person11").addClass("ch_width_a");
			$("#person12").addClass("ch_width_g");
			$("#person13").addClass("ch_width_b3");
			$(".mice").addClass("ch_mice");
			$(".mc_mice").css("font-size","10px");

			
		}   		
	});
</script>

</body>
</html>


<!-- Localized -->