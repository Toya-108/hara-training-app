document.addEventListener("DOMContentLoaded", function () {
    // ===== ① 要素取得 =====
    var form = document.getElementById("login_form");
    var staffCodeInput = document.getElementById("staff_code");
    var passwordInput = document.getElementById("password");
    var togglePassword = document.getElementById("toggle_password");
    var loginButton = document.getElementById("login_button");

    // 必要な要素が取れない場合は処理を止める
    if (!form || !staffCodeInput || !passwordInput || !loginButton) {
        console.error("ログイン画面の必要要素が見つかりません。");
        return;
    }

    // ===== ② パスワード表示切替 =====
    if (togglePassword) {
        togglePassword.addEventListener("change", function () {
            passwordInput.type = togglePassword.checked ? "text" : "password";
        });
    }

    // ===== ③ フォーム送信時 =====
    form.addEventListener("submit", async function (event) {
        event.preventDefault();

        // submit時に最終チェックを行う
        var isOk = validateLoginForm();
        if (!isOk) {
            return;
        }

        // 入力チェックOKならログイン処理実行
        await loginProcess();
    });

    // ===== ④ 入力チェック =====
    function validateLoginForm() {
        var staffCode = staffCodeInput.value != null ? staffCodeInput.value.trim() : "";
        var password = passwordInput.value != null ? passwordInput.value.trim() : "";

        // ユーザー名未入力チェック
        if (staffCode === "") {
            showAlert("ユーザー名を入力してください。", "warning").then(function () {
                staffCodeInput.focus();
            });
            return false;
        }

        // パスワード未入力チェック
        if (password === "") {
            showAlert("パスワードを入力してください。", "warning").then(function () {
                passwordInput.focus();
            });
            return false;
        }

        // ユーザー名桁数チェック
        if (staffCode.length > 20) {
            showAlert("ユーザー名は20文字以内で入力してください。", "warning").then(function () {
                staffCodeInput.focus();
            });
            return false;
        }

        // パスワード桁数チェック
        if (password.length > 100) {
            showAlert("パスワードは100文字以内で入力してください。", "warning").then(function () {
                passwordInput.focus();
            });
            return false;
        }

        return true;
    }

    // ===== ⑤ ログイン処理 =====
    async function loginProcess() {
        // 通信中はボタンを押せないようにする
        setLoading(true);

        try {
            // ===== ⑤-1 フォームデータ作成 =====
            var formData = new FormData(form);

            // ===== ⑤-2 ログインAPI呼び出し =====
            var loginResponse = await fetch("./login.cfc?method=authenticate&returnformat=json", {
                method: "POST",
                body: formData
            });

            // HTTPエラーチェック
            if (!loginResponse.ok) {
                throw new Error("HTTPエラー");
            }

            // ===== ⑤-3 レスポンスをJSONに変換 =====
            var loginResult = await loginResponse.json();

            // ===== ⑤-4 ログイン成功チェック =====
            // 成功時は status = 0
            if (Number(loginResult.status) === 0) {
                // 成功時はメニューへ遷移
                window.location.href = "./menu.cfm";
                return;
            }

            // ===== ⑤-5 ログイン失敗時 =====
            await showAlert(loginResult.message || "ログインに失敗しました。", "error");

        } catch (error) {
            // ===== ⑤-6 エラー処理 =====
            console.error(error);
            await showAlert("通信エラーが発生しました。", "error");

        } finally {
            // ===== ⑤-7 後処理 =====
            // 成功でも失敗でも最後に必ず実行
            setLoading(false);
        }
    }

    // ===== ⑥ アラート表示 =====
    function showAlert(message, icon) {
        if (typeof Swal !== "undefined" && Swal.fire) {
            return Swal.fire({
                text: message,
                icon: icon,
                confirmButtonText: "OK",
                confirmButtonColor: "#3F5B4B"
            });
        } else {
            alert(message);
            return Promise.resolve();
        }
    }

    // ===== ⑦ ローディング制御 =====
    function setLoading(flag) {
        loginButton.disabled = flag;
        loginButton.textContent = flag ? "認証中..." : "ログイン";
    }
});