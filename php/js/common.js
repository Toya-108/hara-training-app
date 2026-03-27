// ==========================================================
// common.js
// ==========================================================
// このファイルは、複数画面で共通して使えそうなJavaScript関数を
// まとめるためのファイルです。
//
// 今回は以下をまとめています。
// ・メッセージ表示
// ・必須入力チェック
// ・FormData作成
//
// window.CommonApp = {...} にしている理由:
// どの画面のJSからでも
//   CommonApp.showMessage(...)
// のように使えるようにするためです。
// ==========================================================

window.CommonApp = {
    // ------------------------------------------------------
    // メッセージ表示
    // ------------------------------------------------------
    // 関数名:
    //   showMessage
    //
    // 引数:
    //   messageText → 画面に表示したい文言
    //   iconType    → 'success', 'error', 'warning' など
    //
    // SweetAlert2 を使って、見やすいポップアップを出します。
    showMessage: function (messageText, iconType) {
        Swal.fire({
            text: messageText,
            icon: iconType,
            confirmButtonText: 'OK'
        });
    },

    // ------------------------------------------------------
    // 必須入力チェック
    // ------------------------------------------------------
    // 関数名:
    //   checkRequiredInput
    //
    // 引数:
    //   inputData
    //     → 入力値をまとめたオブジェクト
    //        例:
    //        {
    //          staff_code: 'A001',
    //          password: 'abc'
    //        }
    //
    //   checkItemList
    //     → どの項目を必須にするかの一覧
    //        例:
    //        [
    //          { name: 'staff_code', label: 'ユーザー名' },
    //          { name: 'password', label: 'パスワード' }
    //        ]
    //
    // 戻り値:
    //   {
    //     allInputOk: true / false,
    //     errorMessageData: {
    //       staff_code: '',
    //       password: 'パスワードを入力してください。'
    //     }
    //   }
    //
    // こうして共通関数にしておくと、
    // ログイン画面以外でも同じ考え方で必須チェックができます。
    checkRequiredInput: function (inputData, checkItemList) {
        var allInputOk = true;
        var errorMessageData = {};

        checkItemList.forEach(function (oneItem) {
            var itemName = oneItem.name;
            var itemLabel = oneItem.label;
            var inputValue = '';

            // 対象の値が存在すれば取り出す
            if (inputData[itemName] !== undefined && inputData[itemName] !== null) {
                inputValue = String(inputData[itemName]).trim();
            }

            // 空ならエラーメッセージを設定
            if (inputValue === '') {
                errorMessageData[itemName] = itemLabel + 'を入力してください。';
                allInputOk = false;
            } else {
                errorMessageData[itemName] = '';
            }
        });

        return {
            allInputOk: allInputOk,
            errorMessageData: errorMessageData
        };
    },

    // ------------------------------------------------------
    // FormData作成
    // ------------------------------------------------------
    // 関数名:
    //   createFormData
    //
    // 引数:
    //   inputData → 送信したいデータのオブジェクト
    //
    // 戻り値:
    //   FormData オブジェクト
    //
    // fetch で POST 送信する時に使います。
    // オブジェクトをそのまま送るのではなく、
    // FormData に詰め替えて送っています。
    createFormData: function (inputData) {
        var sendFormData = new FormData();

        Object.keys(inputData).forEach(function (keyName) {
            sendFormData.append(keyName, inputData[keyName]);
        });

        return sendFormData;
    }
};