<!--- <cfif IsDefined("Session.staff_code") eq false>
  <cflocation url="login.cfm">
</cfif>  --->
<cfset source = application.syslog_path & url.f_name>
<cfheader name="Content-Disposition" value="attachment; filename=#url.f_name#" charset="utf-8">
<cfcontent type="text/xml" file="#source#" deletefile="no">