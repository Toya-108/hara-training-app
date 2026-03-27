<cfcomponent>
	<cffunction name="expDb" access="public"  returnformat = "plain">
		<cfargument name="dist_dir"><!--- /var/www/html/freshdas --->
		<cfargument name="sql">
		<cfargument name="output_type" default="write"><!--- write:上書き append:追記 --->

		<cfset sh = '#Application.db_user# #Application.db_pass# #Application.db_host# #Application.db_name# "#PreserveSingleQuotes(sql)#" #dist_dir# #output_type#' >	

		<cfset result = "">

<!--- mysql -uxxx -pxxx -h xxx.xxx.xxx.xxx xxxdb -e "`SELECT * FROM m_admin`" | sed -e 's/\t/,/g' > /var/tmp/test.csv --->
		<cfexecute name="#Application.export_db_sh#" arguments="#sh#" variable="standardOut" errorVariable="errorOut" timeout="300"/>
		<cfset result = errorOut>

		<cfreturn result>
	</cffunction>
</cfcomponent>
