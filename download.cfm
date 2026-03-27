<cfoutput>
	<cfif StructKeyExists(URL, "f") and URL.f neq "">
		<cfset download_file_name = url.f>
		<cfif StructKeyExists(URL, "fnm") and URL.fnm neq "">
			<cfset download_file_name = url.fnm>
		</cfif>
		<cfheader name="Content-Disposition" value="attachment; filename=#download_file_name#" charset="shift-jis">
		<cfcontent type="text/csv" file="#Application.temp_path##Application.path_delimiter##url.f#" deletefile="no">
	</cfif>
</cfoutput>
