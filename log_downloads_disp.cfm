<!--- <cfif IsDefined("Session.staff_code") eq false>
  <cflocation url="login.cfm">
</cfif>  --->
<cfset source = application.syslog_path & url.f_name>
<cffile action="read" file="#source#" variable="data" >
<cfset data = replace(data,'<!-','＜!!!!-','all')>
<cfoutput>
  <cfloop index="lpc" list="#data#" delimiters="#Chr(13)##Chr(10)#">
    
      <span style="font-size:10px">#lpc#</span><br>
    
  </cfloop>
</cfoutput>