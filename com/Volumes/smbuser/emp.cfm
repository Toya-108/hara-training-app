
<!--- 検索用の編集の初期化 --->
<cfset search_input = "">
<cfset search_dept = "">
<cfset search_status = "">
<cfset search_emp_type = "">

<!--- URL変数が存在し、かつ空じゃない場合検索ワードをセット --->
<cfif StructKeyExists(url,"sinput") and url.sinput neq "">
  <cfset search_input = url.sinput>
<cfelse>
 <cfif StructKeyExists(form,"search_input") and form.search_input neq "">
  <cfset search_input = form.search_input>
 </cfif> 
</cfif>

<cfif StructKeyExists(url,"sdpt") and url.sdpt neq "">
  <cfset search_dept = url.sdpt>
<cfelse>
 <cfif StructKeyExists(form,"search_dept") and form.search_dept neq "">
  <cfset search_dept = form.search_dept>
 </cfif> 
</cfif>

<cfif StructKeyExists(url,"sstatus") and url.sstatus neq "">
  <cfset search_status = url.sstatus>
<cfelse>
 <cfif StructKeyExists(form,"search_status") and form.search_status neq "">
  <cfset search_status = form.search_status>
 </cfif>
</cfif>

<cfif StructKeyExists(url,"semp_type") and url.semp_type neq "">
  <cfset search_emp_type = url.semp_type>
<cfelse>
 <cfif StructKeyExists(form,"search_emp_type") and form.search_emp_type neq "">
  <cfset search_emp_type = form.search_emp_type>
 </cfif>
</cfif>

<!--- 社員マスタから一覧用のデータを取得 --->
<cfquery name="empMaster">
select m_emp.emp_code ecode,
       concat(last_name,' ',`first_name`) ename,
       m_department.department_name dname,
       date_format(m_emp.create_date,'%Y/%m/%d') cdate,
       m_emp.status,
       m_emp.emp_type,
       case when m_emp.emp_type =1 then '社員'
            when m_emp.emp_type =2 then '契約社員'
            when m_emp.emp_type =3 then '派遣社員'
            when m_emp.emp_type =4 then 'パート'
            else ''
            end as char_emp_type,
       case when m_emp.status = 1 then '在職'
            when m_emp.status = 2 then '休職'
            when m_emp.status = 9 then '退職'
            else ''
            end as char_status
  from m_emp left join m_department on m_emp.department_code = m_department.department_code
  where 1 = 1
 <cfif search_input neq ""> 
 <cfset search_input = replace(search_input,"　"," ","all")>
 <cfset search_arr = []>
 <cfset search_arr = ListToArray(search_input," ")>
  <cfloop index="search_input"array="#search_arr#">
    
  
     and (m_emp.last_name like <cfqueryparam value="%#search_input#%" cfsqltype="CF_SQL_VARCHAR" maxlength="30"> 
     or m_emp.first_name like <cfqueryparam value="%#search_input#%" cfsqltype="CF_SQL_VARCHAR" maxlength="30">
     or m_emp.emp_code like <cfqueryparam value="%#search_input#%" cfsqltype="CF_SQL_VARCHAR" maxlength="30">
         )
     </cfloop>
 </cfif>
 <cfif search_dept neq "">
     and m_emp.department_code = <cfqueryparam value="#search_dept#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">
 </cfif>
 <cfif search_status neq "">
     and m_emp.status = <cfqueryparam value="#search_status#" cfsqltype="CF_SQL_TINYINT" maxlength="3">
 </cfif>
  <cfif search_emp_type neq "">
     and m_emp.emp_type = <cfqueryparam value="#search_emp_type#" cfsqltype="CF_SQL_TINYINT" maxlength="3">
 </cfif>
 order by status,emp_code
</cfquery>

<!--- 部署選択用のデータを部署マスタから取得 --->
<cfquery name="qGetDept">
  select department_code dcode,
         department_name dname
    from m_department
</cfquery>



<!DOCTYPE html>
<html>
  <head>
    <style type="text/css">
     .gray{
      background-color:gray
     }
     .yellow{
      background-color:yellow
     }
    </style>
    <link rel="stylesheet" type="text/css" href="css/test.css?2021052401">
    <link rel="stylesheet" type="text/javascript" href="js/test.js">
    <meta charset="utf-8">
    <title>社員マスタ</title>

  </head>
  <body>

    <h2>社員マスタ</h2>

    <cfoutput>
  　<form id="search_form" name="search_form">
      <input id="search_input" name="search_input" maxlength="30" value="#search_input#">
      <select name="search_dept">
        <option value="">部署を選択</option>
            <cfloop index = "i" from = "1" to = "#qGetDept.recordcount#">                
                <option value="#qGetDept.dcode[i]#" <cfif search_dept eq qGetDept.dcode[i]>selected="selected"</cfif>  >#qGetDept.dcode[i]#&nbsp;#qGetDept.dname[i]#</option>
            </cfloop>
      </select>
      <select name="search_status" id="search_status">
          <option value="">在職区分を選択</option>
          <option value="1"<cfif search_status eq 1>selected="selected"</cfif>>在職</option>
          <option value="2"<cfif search_status eq 2>selected="selected"</cfif>>休職</option>
          <option value="9"<cfif search_status eq 9>selected="selected"</cfif>>退職</option>
      </select>

      <!--- ラジオボタン用のためコメントアウト --->
<!---         <input type="radio" name="search_status" value=""<cfif search_status eq "">checked="checked"</cfif>/>すべて
        <input type="radio" name="search_status" value="1"<cfif search_status eq 1>checked="checked"</cfif>/>在職
        <input type="radio" name="search_status" value="2"<cfif search_status eq 2>checked="checked"</cfif>/>休職
        <input type="radio" name="search_status" value="9"<cfif search_status eq 9>checked="checked"</cfif>/>退職 --->
      <select name="search_emp_type" id="search_emp_type">
          <option value="">勤務形態を選択</option>
          <option value="1"<cfif search_emp_type eq 1>selected="selected"</cfif>>社員</option>
          <option value="2"<cfif search_emp_type eq 2>selected="selected"</cfif>>契約社員</option>
          <option value="3"<cfif search_emp_type eq 3>selected="selected"</cfif>>派遣社員</option>
          <option value="4"<cfif search_emp_type eq 4>selected="selected"</cfif>>パート</option>
      </select>
      <input id="search_btn" name="search_btn" type="button" value="検索">
      
    </form>
　　 <table border="1"> 
     <tr>
      <th>
       <input id="create_btn" type="button" value="+" onclick="moveInput()">
      </th>
      <th>
       社員名
      </th>
      <th>
        勤務形態
      <th>
       部署
      </th>
      <th>
        ステータス
      </th>
      <th>
       登録日
      </th>
     </tr>
      <cfif #empMaster.recordcount# gte 1>
       <cfloop index = "i" from = "1" to = "#empMaster.recordcount#">
        <!--- ステータスによって背景色用のクラスを指定する --->
        <cfset bg_class = "">
        <cfif empMaster.status[i] eq 9>
           <cfset bg_class = "gray">
        <cfelseif empMaster.status[i] eq 2>
           <cfset bg_class = "yellow">
        </cfif>
         <tr class="#bg_class#">
          <td>
            <a href="emp_input.cfm?ecd=#empMaster.ecode[i]#&act=3&sinput=#search_input#&sdpt=#search_dept#&sstatus=#search_status#&semp_type=#search_emp_type#">#empMaster.ecode[i]#</a>
          </td>
          <td>
            #empMaster.ename[i]#
          </td>
          <td>
            #empMaster.char_emp_type[i]#
          </td>
          <td>
            #empMaster.dname[i]#
          </td>
          <td>
            #empMaster.char_status[i]#
          </td>
          <td>
            #empMaster.cdate[i]#
          </td>
         </tr>
       </cfloop>
       <cfelse>
        <tr>
          <td colspan="6">
            データはありません。
          </td>
        </tr>  
       </cfif>
    </table>
    </cfoutput>
     <script type="text/javascript"src="js/jquery-3.6.0.min.js"></script>
   <script>
    $(document).ready(function(){
        $("#search_btn").on("click",function(){
            document.search_form.method = "post"
            document.search_form.action = "emp.cfm"
            document.search_form.submit()
        })
    })
    function moveInput(){
      location.href = "emp_input.cfm?act=1"
    }

   </script>
  </body>
</html>