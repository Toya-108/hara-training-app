document.addEventListener('DOMContentLoaded', function () {

    // ===== 要素を取得 =====
    var form = document.getElementById('login_form');
    var passwordInput = document.getElementById('password');
    var togglePassword = document.getElementById('toggle_password');
    var loginButton = document.getElementById('login_button');

    togglePassword.addEventListener('change', function () {
        if (togglePassword.checked) {
            passwordInput.type = 'text';
        } else {
            passwordInput.type = 'password';
        }
    });

    // ===== ログインボタン押下時 =====
    form.addEventListener('submit', function (event) {
        event.preventDefault(); // ページリロード防止

        // 必須チェック
        var isOk = CommonValidation.validateRequiredFields(form);
        if (!isOk) {
            showAlert('未入力の項目があります。', 'warning');
            return;
        }

        // ログイン処理実行
        loginProcess();
    });

    // ===== ログイン処理 =====
    function loginProcess() {
        setLoading(true);

        var formData = new FormData(form);

        fetch('./login.cfc?method=authenticate&returnformat=json', {
            method: 'POST',
            body: formData
        })
        .then(function (response) {
            if (!response.ok) {
                throw new Error('HTTPエラー');
            }

            return response.json();
        })
        .then(function (result) {
            if (Number(result.status) === 1) {
                // 成功 → JSで画面遷移
                window.location.href = './menu.cfm';
            } else {
                // 失敗
                showAlert(result.message || 'ログインに失敗しました。', 'error');
            }
        })
        .catch(function (error) {
            console.error(error);
            showAlert('通信エラーが発生しました。', 'error');
        })
        .finally(function () {
            setLoading(false);
        });
    }

    // ===== SweetAlert2表示 =====
    function showAlert(message, icon) {
        Swal.fire({
            text: message,
            icon: icon,
            confirmButtonText: 'OK'
        });
    }

    // ===== ローディング制御 =====
    function setLoading(flag) {
        loginButton.disabled = flag;

        if (flag) {
            loginButton.textContent = '認証中...';
        } else {
            loginButton.textContent = 'ログイン';
        }
    }

    function validateRequiredField(field) {
        var label = field.dataset.label || field.name || 'この項目';
        var value = (field.value || '').trim();

        clearFieldError(field);

        if (value === '') {
            showFieldError(field, label + 'を入力してください。');
            return false;
        }

        return true;
    }

});