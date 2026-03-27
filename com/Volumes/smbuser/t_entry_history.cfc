<cfcomponent>
	<cfheader name="Access-Control-Allow-Origin" value="*" />
	<cfsetting showDebugOutput="No">

	<cfinclude template="init.cfm">

	<cffunction name="exportHistory" access="remote" output="false" returnFormat="json">
		<cfset result = {}>
		<cfset result["status"] = 0>
		<cfset result["message"] = "">
		<cfset result["file_name"] = "">

		<cfif StructKeyExists(Form, "list_screen") and
		      StructKeyExists(Form, "filtering") and
		      StructKeyExists(Form, "order_by")>

			<cfset list_screen = Form.list_screen>
			<cfset filtering = Form.filtering>
			<cfset order_by = Form.order_by>

			<cflog file="Buns-Survey" type="Information" text="入店履歴エクスポート　担当者：#Session.staff_code#　filtering：#Form.filtering#">

<!--- 			<cfif list_screen eq 1>
				<cfset sql = "">
			<cfelse> --->

				<cfset sql = "
							  SELECT CONCAT(date_format(t_entry_history.entry_datetime, '%Y/%m/%d'), ' ', time_format(t_entry_history.entry_datetime, '%H:%i')) as char_entry_datetime,
							         IFNULL(m_area.area_name, ''),
							         IFNULL(m_shop.shop_name, ''),
							         IFNULL(t_entry_history.entry_staff_name, '')
							    FROM t_entry_history LEFT OUTER JOIN (m_shop LEFT OUTER JOIN m_area ON m_shop.area_code = m_area.area_code) ON t_entry_history.shop_code = m_shop.shop_code
							   WHERE 1 = 1
							         #PreserveSingleQuotes(filtering)#
							  ORDER BY #PreserveSingleQuotes(order_by)#">

			<!--- </cfif> --->

			<cfset dir = Application.temp_dir>
			<cfif !DirectoryExists(dir)>
				<cfdirectory action="create" directory="#dir#" mode="777">
			</cfif>
			<cfset now  = now()>
			<cfset day  = DateFormat(now, "yyyymmdd")>
			<cfset time = TimeFormat(now, "HHnnss")>

			<cfset file_name = "entry_history_" & Session.staff_code & "_" & day & time & ".csv">
			<cfset export_file = dir & Application.dir_separator & file_name>

			<cfset header_data = "入店日時," &
								"地域名," &
								"店舗名," &
								"ドライバー名">

			<cffile action="write" file="#export_file#" output="#header_data#" charset="utf-8" mode="777">

			<cfif sql neq "">
				<cfset ed = CreateObject("component","com.export_db")>				
				<cfset expdb_result = ed.expDb(export_file,sql,"append")>	
			</cfif>
			<cfset result["file_name"] = file_name />


		<cfelse>
			<cflog file="Buns-Survey" type="Error" text="入店履歴エクスポート　担当者：#Session.staff_code#　Form変数エラー">
			<cfset result["status"] = 1 />
			<cfset result["message"] = "内部エラーが発生しました。" />
		</cfif>


	  <cfreturn serializeJSON(result)>
	</cffunction>
</cfcomponent>
