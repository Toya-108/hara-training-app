<cfif NOT StructKeyExists(session, "staffCode") OR session.staffCode eq "">
	<cflocation url="login.cfm" addToken="no">
</cfif>