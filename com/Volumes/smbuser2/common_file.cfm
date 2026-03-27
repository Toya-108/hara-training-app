
	<!--- tempフォルダにランダムフォルダ作成後、ファイルコピー --->
	<cfscript>
		randomCFC=CreateObject("component","common_file");
		random = randomCFC.getRandom();
	</cfscript>
	<cfquery datasource="#application.dsn#" name="qGetInfo">			
	  select m_emp.company_code,
	  		m_emp.emp_code,
	  		m_emp.emp_name_l,
	  		m_emp.emp_name_f,
	  		m_emp.authority,
	  		m_company.file_directory
		from m_emp,m_company 
	   where m_emp.emp_code = '#session.emp_code#'
	   	 and m_emp.company_code = '#session.company_code#'
	     and m_emp.company_code = m_company.company_code		
	</cfquery>
	<cfset fn = URLDecode(url.fn)>
	<cfset pt = URLDecode(url.pt)>
	<cfset temp_dir = application.temp_dir & random & application.delimiter>
	<cfset ext = ListToArray(fn,".")[2]>
	<cfif !DirectoryExists(temp_dir)>
	    <cfdirectory action="create" directory="#temp_dir#" mode="777">
	</cfif>
	<!--- <cfset file_name = DateFormat(now(), "yyyymmdd") & TimeFormat(now(), "HHmmss") & "." & ext> --->
	<cfset file_name = fn>
	<cfset destination_file = temp_dir & file_name>
	<cfset source = qGetInfo.file_directory & pt & application.delimiter & fn>
<!--- 	<cfif url.ccd eq "app">
		<cfset source = qGetCustomer.application_file>
	<cfelseif url.ccd eq "wd">
		<cfset source = qGetCustomer.withdrawal_file>
	<cfelse>
		<cfset source = application.contract_dir & qGetCustomer.temp_customer_code & "_" & url.ccd & "." & ext>
	</cfif>
 --->
 	<cfoutput>#source#</cfoutput>
	<cfif FileExists(source)>
		<cffile 
		action = "copy" 
		destination = "#destination_file#" 
		source = "#source#" 
		mode = "777">
		<cfoutput>
			<cflocation url="#application.base_url#/temp/#random#/#file_name#">
		</cfoutput>
	</cfif>

	<!--- ランダムフォルダを削除 --->
	<cfthread name="delTemp">
		<cfscript>
			del_span = 120000;//2分
			sleep(del_span);
			randomCFC.delDir(temp_dir);
		</cfscript>		
	</cfthread>

