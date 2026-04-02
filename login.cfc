<cfcomponent displayname="Login" output="false">

    <cffunction name="authenticate" access="remote" returntype="struct" returnformat="json" output="false">

        <!--- 戻り値用 --->
        <cfset var result = {}>

        <!--- 受け取り用 --->
        <cfset var staffCode = "">
        <cfset var password = "">

        <!--- クエリ結果用 --->
        <cfset var qGetStaff = "">

        <!--- 初期値 --->
        <!--- 成功時は0、エラー時は1 --->
        <cfset result["status"] = 0>
        <cfset result["message"] = "">

        <!--- 入力値取得 --->
        <cfif StructKeyExists(Form, "staff_code")>
            <cfset staffCode = Trim(Form.staff_code)>
        </cfif>

        <cfif StructKeyExists(Form, "password")>
            <cfset password = Trim(Form.password)>
        </cfif>

        <cftry>
            <!--- 該当ユーザーを取得 --->
            <cfquery name="qGetStaff">
                SELECT
                    staff_code,
                    staff_name,
                    login_password_hash,
                    authority_level,
                    use_flag
                FROM
                    m_staff
                WHERE
                    staff_code = <cfqueryparam value="#staffCode#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfcatch type="database">
                <cflog file="HARA_TRAINING_APP" type="Error" text="tudmweb3 トレーニングApp　社員取得エラー　#cfcatch.SQL# #cfcatch.QueryError#">
                <cfset result["status"] = 1>
                <cfset result["message"] = "ログイン処理中にエラーが発生しました。">
                <cfreturn result>
            </cfcatch>
        </cftry>

        <!--- ユーザーが見つからない場合 --->
        <cfif qGetStaff.recordCount eq 0>
            <cfset result["status"] = 1>
            <cfset result["message"] = "ユーザー名またはパスワードが正しくありません。">
            <cfreturn result>
        </cfif>

        <!--- 使用不可ユーザーの場合 --->
        <cfif qGetStaff.use_flag neq 1>
            <cfset result["status"] = 1>
            <cfset result["message"] = "このユーザーは現在使用できません。管理者へ確認してください。">
            <cfreturn result>
        </cfif>

        <!---
            パスワードは BCrypt ハッシュで照合する。
            DBには generateBCryptHash() で作成した文字列が保存されている前提。
        --->
        <cfif NOT verifyBCryptHash(password, qGetStaff.login_password_hash)>
            <cfset result["status"] = 1>
            <cfset result["message"] = "ユーザー名またはパスワードが正しくありません。">
            <cfreturn result>
        </cfif>

        <!--- セッションにログイン情報を保存 --->
        <cfset session.isLoggedIn = true>
        <cfset session.staffCode = qGetStaff.staff_code>
        <cfset session.staffName = qGetStaff.staff_name>
        <cfset session.authorityLevel = qGetStaff.authority_level>

        <!--- ログイン成功 --->
        <cfset result["status"] = 0>
        <cfset result["message"] = "ログインに成功しました。">

        <cfreturn result>

    </cffunction>

</cfcomponent>