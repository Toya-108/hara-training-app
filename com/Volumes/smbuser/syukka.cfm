<cfinclude template = "init.cfm">

<!DOCTYPE html>
<html lang="ja">
  <cfoutput>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <cfinclude template="common/css.cfm">
    
    <title>出荷デモ</title>
    <style type="text/css">
      .styled {
        border: 0;
        line-height: 2.5;
        /*padding: 0 50px;*/
        font-size: 2rem;
        text-align: center;
        color: white;
        /*text-shadow: 1px 1px 1px ##000;*/
        border-radius: 10px;
        background-color: blue;
        background-image: linear-gradient(to top left, rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2) 30%, rgba(0, 0, 0, 0));
        box-shadow:
        inset 2px 2px 3px rgba(255, 255, 255, 0.6),
        inset -2px -2px 3px rgba(0, 0, 0, 0.6);
      }
    </style>
  </head>

  <body>

    <div class="wrap" style="margin-top:100px;">
      <!--- 昨日の日付をyyyymmddでセット --->
      <cfset yesterday = dateAdd("d", -1, now())>
      <cfset yesterday = dateFormat(yesterday, "yyyymmdd")>
      

      <div style="text-align:center;">
        <a href="fds://?factory_id=001&course_id=13051&status=&deliverydate=#yesterday#">
          <button class="favorite styled" type="button" style="width:10em;">出発</button>
        </a>
      </div>
      <div style="margin:15px;">
      <div style="text-align:center;">
        <a href="fds://?factory_id=001&course_id=13051&status=1&deliverydate=#yesterday#">
          <button class="favorite styled" type="button" style="width:10em;">納品完了時</button>
        </a>
      </div>

<!---       <div style="text-align:center;"><a href="fds://?factory_id=bbb&course_id=aaa&status=">存在しないコード</a></div>
      <div style="text-align:center;"><a href="fds://?factory_id=001&course_id=13051&status=">通常時</a></div>
      <div style="text-align:center;"><a href="fds://?factory_id=001&course_id=13051&status=1">納品完了時</a></div>
 --->
    </div><!--- wrap --->
    </form>
    </cfoutput>
    <cfinclude template="common/js.cfm">
  </body>
</html>