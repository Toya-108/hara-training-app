<cfcomponent>
  <cffunction name="expDb" access="public" returnformat="plain">
    <cfargument name="dist_dir">
    <cfargument name="sql">
    <cfargument name="output_type" default="write">

    <cfset var sh = '#Application.db_user# #Application.db_pass# #Application.db_host# #Application.db_name# "#PreserveSingleQuotes(sql)#" #dist_dir# #output_type#'>
    <cfset var errorOut = "">

    <!--- stdoutは受け取らない（JVM OOM対策） --->
    <cfexecute
      name="#Application.export_db_sh#"
      arguments="#sh#"
      errorVariable="errorOut"
      timeout="300"
    />

    <cfreturn errorOut>
  </cffunction>
</cfcomponent>