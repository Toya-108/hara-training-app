<cfcomponent displayname="Login" output="false">

    <cffunction name="authenticate" access="remote" returntype="struct" returnformat="json" output="false">

        <!--- 戻り値用 --->
        <cfset var result = {}>

        <!--- 受け取り用 --->
        <cfset var staffCode = "">
        <cfset var password = "">

        <!--- クエリ結果用 --->
        <cfset var qGetStaff = "">

        <!--- 初期値を1つずつ設定 --->
        <cfset result["status"] = 0>
        <cfset result["message"] = "">

            <!--- ユーザー名を取得 --->
            <cfif StructKeyExists(Form, "staff_code")>
                <cfset staffCode = Trim(Form.staff_code)>
            </cfif>

            <!--- パスワードを取得 --->
            <cfif StructKeyExists(Form, "password")>
                <cfset password = Trim(Form.password)>
            </cfif>

            <!--- ユーザー名の必須チェック --->
            <cfif staffCode eq "">
                <cfset result["message"] = "ユーザー名を入力してください。">
                <cfreturn result>
            </cfif>

            <!--- パスワードの必須チェック --->
            <cfif password eq "">
                <cfset result["message"] = "パスワードを入力してください。">
                <cfreturn result>
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

            <cfcatch>
                <cflog file="HARA_TRAINING_APP" type="Error" text="tudmweb3 トレーニングApp　社員取得エラー　#cfcatch.queryError# #cfcatch.SQL#">
                <cfset result["status"] = 0>
                <cfset result["message"] = "ログイン処理中にエラーが発生しました。">
            </cfcatch>
        </cftry>

            <!--- ユーザーが見つからない場合 --->
            <cfif qGetStaff.recordCount eq 0>
                <cfset result["message"] = "ユーザー名またはパスワードが正しくありません。">
                <cfreturn result>
            </cfif>

            <!--- 使用不可ユーザーの場合 --->
            <cfif qGetStaff.use_flag neq 1>
                <cfset result["message"] = "このユーザーは現在使用できません。管理者へ確認してください。">
                <cfreturn result>
            </cfif>

            <!---
                本来は BCrypt や PBKDF2 などを使うのが望ましいです。
                今回はサンプルとして SHA-256 で比較しています。
            --->
            <cfif qGetStaff.login_password_hash neq Hash(password, "SHA-256")>
                <cfset result["message"] = "ユーザー名またはパスワードが正しくありません。">
                <cfreturn result>
            </cfif>

            <!--- セッションにログイン情報を保存 --->
            <cfset session.isLoggedIn = true>
            <cfset session.staffId = qGetStaff.staff_code>
            <cfset session.staffCode = qGetStaff.staff_code>
            <cfset session.staffName = qGetStaff.staff_name>
            <cfset session.authorityLevel = qGetStaff.authority_level>

            <!--- ログイン成功 --->
            <cfset result["status"] = 1>
            <cfset result["message"] = "ログインに成功しました。">
        <cfreturn result>

    </cffunction>

</cfcomponent>