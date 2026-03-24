<!--- <cfif IsDefined("Session.staff_code") eq false>
  <cflocation url="login.cfm">
</cfif>	 --->
<link href="css/base.css" rel="stylesheet" type="text/css">
<!--- /opt/coldfusion2023/cfusion/logs/ --->
<cfdirectory 
directory="#Application.syslog_path#" 
name="log_list"
sort="name">
<html>
  <body>
    <cfoutput>
      <table style="margin:20px">
        <tr>
          <th>
            ファイル名
          </th>
          <th>
            ダウンロード
          </th>
          <th>
            サイズ
          </th>
          <th>
            更新日
          </th>
          
        </tr>	
        <cfloop query="#log_list#">
		
          <tr>
            <td class="r_td">
              <a style="text-decoration:none" href="log_downloads_disp.cfm?f_name=#URLEncodedFormat(log_list.name)#" target="_blank" rel="noopener noreferrer">&nbsp;#log_list.name#</a>
            </td>
            <td>
              <a style="text-decoration:none" href="log_downloads_action.cfm?f_name=#URLEncodedFormat(log_list.name)#">&nbsp;ダウンロード</a>
            </td>
            <td style="text-align:right">
              #NumberFormat(log_list.size/1000,0.0)#&nbsp;K&nbsp;
            </td>
            <td>
              &nbsp;#dateTimeFormat(log_list.dateLastModified, "yyyy/mm/dd HH:nn:ss:l")#
            </td>            
          </tr>	
        </cfloop>
      </table>
    </cfoutput>
  </body>

</html>
