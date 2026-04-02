<cfsetting showdebugoutput="false">
<cfinclude template="init.cfm">

<cfset searchStaffCode = "">
<cfif StructKeyExists(URL, "search_staff_code")>
    <cfset searchStaffCode = Trim(URL.search_staff_code)>
</cfif>

<cfset searchStaffName = "">
<cfif StructKeyExists(URL, "search_staff_name")>
    <cfset searchStaffName = Trim(URL.search_staff_name)>
</cfif>

<cfset searchMailAddress = "">
<cfif StructKeyExists(URL, "search_mail_address")>
    <cfset searchMailAddress = Trim(URL.search_mail_address)>
</cfif>

<cfset searchAuthorityLevel = "">
<cfif StructKeyExists(URL, "search_authority_level")>
    <cfset searchAuthorityLevel = Trim(URL.search_authority_level)>
</cfif>

<cfset searchUseFlag = "">
<cfif StructKeyExists(URL, "search_use_flag")>
    <cfset searchUseFlag = Trim(URL.search_use_flag)>
</cfif>

<cfset sortField = "">
<cfif StructKeyExists(URL, "sortField")>
    <cfset sortField = Trim(URL.sortField)>
</cfif>

<cfset sortOrder = "asc">
<cfif StructKeyExists(URL, "sortOrder") AND LCase(Trim(URL.sortOrder)) eq "desc">
    <cfset sortOrder = "desc">
</cfif>

<cfset orderBySql = "m_staff.staff_code">

<cfif sortField eq "staff_name">
    <cfset orderBySql = "m_staff.staff_name">
<cfelseif sortField eq "mail_address">
    <cfset orderBySql = "m_staff.mail_address">
<cfelseif sortField eq "authority_level">
    <cfset orderBySql = "m_staff.authority_level">
<cfelseif sortField eq "use_flag">
    <cfset orderBySql = "m_staff.use_flag">
<cfelseif sortField eq "create_datetime">
    <cfset orderBySql = "m_staff.create_datetime">
<cfelseif sortField eq "update_datetime">
    <cfset orderBySql = "m_staff.update_datetime">
<cfelse>
    <cfset orderBySql = "m_staff.staff_code">
</cfif>

<cfif sortOrder eq "desc">
    <cfset orderBySql = orderBySql & " DESC">
<cfelse>
    <cfset orderBySql = orderBySql & " ASC">
</cfif>

<cfset filtering = " WHERE 1 = 1 ">

<cfif searchStaffCode neq "">
    <cfset filtering = filtering & " AND m_staff.staff_code = '" & Replace(searchStaffCode, "'", "''", "all") & "'">
</cfif>

<cfif searchStaffName neq "">
    <cfset filtering = filtering & " AND (m_staff.staff_name LIKE '%" & Replace(searchStaffName, "'", "''", "all") & "%' OR m_staff.staff_kana LIKE '%" & Replace(searchStaffName, "'", "''", "all") & "%')">
</cfif>

<cfif searchMailAddress neq "">
    <cfset filtering = filtering & " AND m_staff.mail_address LIKE '%" & Replace(searchMailAddress, "'", "''", "all") & "%'">
</cfif>

<cfif searchAuthorityLevel neq "">
    <cfset filtering = filtering & " AND m_staff.authority_level = '" & Replace(searchAuthorityLevel, "'", "''", "all") & "'">
</cfif>

<cfif searchUseFlag eq "0" OR searchUseFlag eq "1">
    <cfset filtering = filtering & " AND m_staff.use_flag = " & Val(searchUseFlag)>
</cfif>

<cfset export_file_name = "社員マスタ" & DateFormat(Now(), "yyyymmdd") & "_" & TimeFormat(Now(), "HHmmss") & ".csv">
<cfset export_file = Application.temp_path & Application.path_delimiter & export_file_name>

<cfset header_data = "社員コード,社員名,社員名カナ,権限レベル,権限名,メールアドレス,電話番号,使用区分,最終ログイン日時,備考,作成日時,作成者コード,作成者名,更新日時,更新者コード,更新者名">
<cffile
    action="write"
    file="#export_file#"
    output="#header_data#"
    mode="777"
    charset="shift_jis">

<cfset pageSql = "
SELECT
    IFNULL(m_staff.staff_code, ''),
    IFNULL(m_staff.staff_name, ''),
    IFNULL(m_staff.staff_kana, ''),
    IFNULL(CAST(m_staff.authority_level AS CHAR), ''),
    IFNULL(
        CASE
            WHEN m_staff.authority_level = 9 THEN '管理者'
            WHEN m_staff.authority_level = 1 THEN '一般'
            ELSE ''
        END
    , ''),
    IFNULL(m_staff.mail_address, ''),
    IFNULL(m_staff.tel_no, ''),
    IFNULL(CASE WHEN m_staff.use_flag = 1 THEN '使用中' ELSE '停止' END, ''),
    IFNULL(DATE_FORMAT(m_staff.last_login_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(m_staff.note, ''),
    IFNULL(DATE_FORMAT(m_staff.create_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(m_staff.create_staff_code, ''),
    IFNULL(m_staff.create_staff_name, ''),
    IFNULL(DATE_FORMAT(m_staff.update_datetime, '%Y/%m/%d %H:%i:%s'), ''),
    IFNULL(m_staff.update_staff_code, ''),
    IFNULL(m_staff.update_staff_name, '')
FROM
    m_staff
#PreserveSingleQuotes(filtering)#
ORDER BY
    #PreserveSingleQuotes(orderBySql)#
">

<cfset ed = createObject("component", "training.hara.com.export_db")>
<cfset error_txt = ed.expDb(export_file, pageSql, "append")>

<cfif Trim(error_txt) neq "">
    <cfcontent type="text/plain; charset=UTF-8" reset="true">
    <cfoutput>CSVエクスポート中にエラーが発生しました。
#error_txt#</cfoutput>
    <cfabort>
</cfif>

<cflocation
    url="download.cfm?f=#URLEncodedFormat(export_file_name)#&fnm=#URLEncodedFormat(export_file_name)#"
    addtoken="false">