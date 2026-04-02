(function (window, document) {
    "use strict";

    const ValidationCommon = {
        initialize: function () {
            this.initBlurValidation();
        },

        initBlurValidation: function () {
            document.addEventListener("blur", async (event) => {
                const input = event.target;

                if (!input || !input.classList) {
                    return;
                }

                const title = input.getAttribute("title") || "この項目";
                const rawValue = input.value != null ? input.value.trim() : "";

                // 1. 必須チェック
                if (input.classList.contains("required-check")) {
                    if (rawValue === "") {
                        await this.showAlert(title + "は必須です。");
                        input.focus();
                        return;
                    }
                }

                // 空欄なら、required以外はチェックしない
                if (rawValue === "") {
                    return;
                }

                // 2. 数値チェック
                if (input.classList.contains("num-check")) {
                    const normalizedValue = rawValue.replace(/,/g, "");
                    const isNumeric = /^-?\d+(\.\d+)?$/.test(normalizedValue);

                    if (!isNumeric) {
                        await this.showAlert(title + "には数値を入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }
                }

                // 3. 整数チェック
                if (input.classList.contains("int-check")) {
                    const normalizedValue = rawValue.replace(/,/g, "");
                    const isInteger = /^-?\d+$/.test(normalizedValue);

                    if (!isInteger) {
                        await this.showAlert(title + "には整数を入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }
                }

                // 4. 正の数チェック
                if (input.classList.contains("positive-num-check")) {
                    const normalizedValue = rawValue.replace(/,/g, "");
                    const numericValue = Number(normalizedValue);

                    if (isNaN(numericValue) || numericValue <= 0) {
                        await this.showAlert(title + "には0より大きい数値を入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }
                }

                // 5. 最大桁数チェック
                if (input.classList.contains("maxlen-check")) {
                    let maxLength = input.getAttribute("maxlength");
                    maxLength = maxLength ? parseInt(maxLength, 10) : null;

                    if (maxLength && rawValue.length > maxLength) {
                        await this.showAlert(title + "は" + maxLength + "文字以内で入力してください。");
                        input.focus();
                        return;
                    }
                }

                // 6. 半角数字限定チェック
                if (input.classList.contains("half-num-check")) {
                    const isHalfNumber = /^[0-9]+$/.test(rawValue);

                    if (!isHalfNumber) {
                        await this.showAlert(title + "には半角数字のみ入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }
                }

                // 7. 英数字記号の形式チェック
                if (input.classList.contains("pattern-check")) {
                    const pattern = input.getAttribute("data-pattern");

                    if (pattern) {
                        const regex = new RegExp(pattern);

                        if (!regex.test(rawValue)) {
                            const message = input.getAttribute("data-pattern-message") || (title + "の入力形式が正しくありません。");
                            await this.showAlert(message);
                            input.focus();
                            return;
                        }
                    }
                }

                // 8. 日付形式チェック（yyyy-mm-dd）
                if (input.classList.contains("date-check")) {
                    if (!this.isValidDate(rawValue)) {
                        await this.showAlert(title + "は yyyy-mm-dd 形式で正しく入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }
                }

                // 9. メールアドレス形式チェック
                if (input.classList.contains("mail-check")) {
                    const isMail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(rawValue);

                    if (!isMail) {
                        await this.showAlert(title + "の形式が正しくありません。");
                        input.focus();
                        return;
                    }
                }

                // 10. 範囲チェック
                if (input.classList.contains("range-check")) {
                    const normalizedValue = rawValue.replace(/,/g, "");
                    const numericValue = Number(normalizedValue);
                    const minValue = input.getAttribute("data-min");
                    const maxValue = input.getAttribute("data-max");

                    if (isNaN(numericValue)) {
                        await this.showAlert(title + "には数値を入力してください。");
                        input.value = "";
                        input.focus();
                        return;
                    }

                    if (minValue !== null && minValue !== "" && numericValue < Number(minValue)) {
                        await this.showAlert(title + "は" + minValue + "以上で入力してください。");
                        input.focus();
                        return;
                    }

                    if (maxValue !== null && maxValue !== "" && numericValue > Number(maxValue)) {
                        await this.showAlert(title + "は" + maxValue + "以下で入力してください。");
                        input.focus();
                        return;
                    }
                }

            }, true);
        },

        validateRequiredFields: function (form) {
            if (!form) {
                return true;
            }

            const requiredInputs = form.querySelectorAll(".required-check");
            let firstInvalidInput = null;

            requiredInputs.forEach((input) => {
                const value = input.value != null ? input.value.trim() : "";

                if (value === "") {
                    if (!firstInvalidInput) {
                        firstInvalidInput = input;
                    }
                }
            });

            if (firstInvalidInput) {
                firstInvalidInput.focus();
                return false;
            }

            return true;
        },

        clearFieldError: function (input) {
            if (!input) {
                return;
            }

            input.classList.remove("is-error");
        },

        isValidDate: function (value) {
            if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
                return false;
            }

            const parts = value.split("-");
            const year = parseInt(parts[0], 10);
            const month = parseInt(parts[1], 10);
            const day = parseInt(parts[2], 10);

            const date = new Date(year, month - 1, day);

            return (
                date.getFullYear() === year &&
                date.getMonth() === month - 1 &&
                date.getDate() === day
            );
        },

        showAlert: async function (message) {
            if (typeof Swal !== "undefined" && Swal.fire) {
                await Swal.fire({
                    title: "入力内容を確認してください",
                    text: message,
                    icon: "warning",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#3F5B4B"
                });
            } else {
                alert(message);
            }
        }
    };

    // 既存コードとの互換用
    window.ValidationCommon = ValidationCommon;
    window.CommonValidation = ValidationCommon;

    document.addEventListener("DOMContentLoaded", function () {
        ValidationCommon.initialize();
    });

})(window, document);