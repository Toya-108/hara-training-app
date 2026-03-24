document.addEventListener("DOMContentLoaded", function () {
    var form = document.getElementById("add_slip_form");
    var addRowButton = document.getElementById("add_row_btn");
    var clearButton = document.getElementById("clear_btn");
    var saveButton = document.getElementById("save_btn");
    var itemTableBody = document.getElementById("item_table_body");
    var messageArea = document.getElementById("form_message");

    var backButton = document.getElementById('back-btn');

    // 取引先モーダル関連
    var supplierModal = document.getElementById("supplier_modal");
    var closeSupplierModalButton = document.getElementById("close_supplier_modal_btn");
    var supplierSearchButton = document.getElementById("modal_supplier_search_btn");
    var supplierClearButton = document.getElementById("modal_supplier_clear_btn");
    var supplierTableBody = document.getElementById("supplier_table_body");

    // 取引先入力欄
    var supplierDisplayInput = document.getElementById("supplier_display");
    var supplierCodeInput = document.getElementById("supplier_code");
    var supplierNameInput = document.getElementById("supplier_name");
    var supplierOpenTriggers = document.querySelectorAll(".supplier-open-trigger");

    CommonValidation.setupRequiredValidation(form);

    bindEnterMoveEvents();
    bindEnterMoveEventsForTable();
    bindItemCodeAutoFill();
    bindDatePicker();

    // 行追加
    if (addRowButton) {
        addRowButton.addEventListener("click", function () {
            addItemRow();
        });
    }

    // クリア
    if (clearButton) {
        clearButton.addEventListener("click", async function () {
            var result = await Swal.fire({
                title: "入力内容をクリアしますか？",
                text: "現在の入力内容は破棄されます。",
                icon: "question",
                showCancelButton: true,
                confirmButtonText: "クリアする",
                cancelButtonText: "戻る",
                confirmButtonColor: "#8A8175",
                cancelButtonColor: "#3F5B4B",
                reverseButtons: true
            });

            if (!result.isConfirmed) {
                return;
            }

            form.reset();
            clearMessage();
            clearAllFieldErrors();
            resetItemRows();
            clearSupplierSelection();
        });
    }

    // 明細削除
    if (itemTableBody) {
        itemTableBody.addEventListener("click", async function (event) {
            if (!event.target.classList.contains("delete-row-btn")) {
                return;
            }

            await deleteItemRow(event.target);
        });
    }

    // 取引先モーダルを開く
    supplierOpenTriggers.forEach(function (element) {
        element.addEventListener("click", function () {
            openSupplierModal();
        });
    });

    // 取引先モーダルを閉じる
    if (closeSupplierModalButton) {
        closeSupplierModalButton.addEventListener("click", function () {
            closeSupplierModal();
        });
    }

    // 背景クリックでモーダルを閉じる
    if (supplierModal) {
        supplierModal.addEventListener("click", function (event) {
            if (event.target === supplierModal) {
                closeSupplierModal();
            }
        });
    }

    // 取引先検索
    if (supplierSearchButton) {
        supplierSearchButton.addEventListener("click", function () {
            searchSupplierList();
        });
    }

    // 取引先検索クリア
    if (supplierClearButton) {
        supplierClearButton.addEventListener("click", function () {
            var modalSearchSupplierCode = document.getElementById("modal_search_supplier_code");
            var modalSearchSupplierName = document.getElementById("modal_search_supplier_name");

            if (modalSearchSupplierCode) {
                modalSearchSupplierCode.value = "";
            }

            if (modalSearchSupplierName) {
                modalSearchSupplierName.value = "";
            }
        });
    }

    // Enterで取引先検索しない
    var modalSearchSupplierCode = document.getElementById("modal_search_supplier_code");
    var modalSearchSupplierName = document.getElementById("modal_search_supplier_name");

    disableEnterSubmit(modalSearchSupplierCode);
    disableEnterSubmit(modalSearchSupplierName);

    // 取引先選択
    if (supplierTableBody) {
        supplierTableBody.addEventListener("click", function (event) {
            if (event.target.classList.contains("select-supplier-btn")) {
                var selectedSupplierCode = event.target.dataset.supplierCode || "";
                var selectedSupplierName = event.target.dataset.supplierName || "";

                setSupplierSelection(selectedSupplierCode, selectedSupplierName);
                closeSupplierModal();
            }
        });
    }

    // 登録
    if (form) {
        form.addEventListener("submit", async function (event) {
            event.preventDefault();

            clearMessage();

            var isValid = CommonValidation.validateRequiredFields(form);
            if (!isValid) {
                await Swal.fire({
                    title: "入力内容を確認してください",
                    text: "未入力の必須項目があります。",
                    icon: "warning",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#3F5B4B"
                });
                return;
            }

            var detailList = collectDetailList();

            if (detailList.length === 0) {
                await Swal.fire({
                    title: "明細を確認してください",
                    text: "明細を1行以上入力してください。",
                    icon: "warning",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#3F5B4B"
                });
                return;
            }

            var detailErrorMessage = getDetailErrorMessage(detailList);
            if (detailErrorMessage !== "") {
                await Swal.fire({
                    title: "明細を確認してください",
                    text: detailErrorMessage,
                    icon: "warning",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#3F5B4B"
                });
                return;
            }

            var confirmResult = await Swal.fire({
                title: "この内容で伝票を登録しますか？",
                icon: "question",
                showCancelButton: true,
                confirmButtonText: "登録する",
                cancelButtonText: "戻る",
                confirmButtonColor: "#3F5B4B",
                cancelButtonColor: "#8A8175",
                reverseButtons: true
            });

            if (!confirmResult.isConfirmed) {
                return;
            }

            var requestBody = {
                slip_date: getValue("slip_date"),
                supplier_code: getValue("supplier_code"),
                supplier_name: getValue("supplier_name"),
                delivery_date: getValue("delivery_date"),
                memo: getValue("memo"),
                detail_list: detailList
            };

            setSaveButtonLoading(true);

            try {
                var response = await fetch("add_slip.cfc?method=saveSlip&returnformat=json", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(requestBody)
                });

                if (!response.ok) {
                    throw new Error("HTTPエラー: " + response.status);
                }

                var result = await response.json();

                if (Number(result.status) === 0) {
                    form.reset();
                    resetItemRows();
                    clearSupplierSelection();
                    clearAllFieldErrors();
                    clearMessage();

                    await Swal.fire({
                        title: "登録完了",
                        text: result.message || "伝票を登録しました。",
                        icon: "success",
                        confirmButtonText: "OK",
                        confirmButtonColor: "#3F5B4B"
                    });
                } else {
                    await Swal.fire({
                        title: "登録失敗",
                        text: result.message || "登録に失敗しました。",
                        icon: "error",
                        confirmButtonText: "OK",
                        confirmButtonColor: "#B84A4A"
                    });
                }
            } catch (error) {
                console.error(error);

                await Swal.fire({
                    title: "通信エラー",
                    text: "通信エラーが発生しました。",
                    icon: "error",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#B84A4A"
                });
            } finally {
                setSaveButtonLoading(false);
            }
        });
    }

    // ----------------------------
    // 関数
    // ----------------------------

    function disableEnterSubmit(input) {
        if (!input) {
            return;
        }

        input.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
            }
        });
    }

    function openSupplierModal() {
        if (!supplierModal) {
            return;
        }

        supplierModal.classList.add("is-open");
        searchSupplierList();
    }

    function closeSupplierModal() {
        if (!supplierModal) {
            return;
        }

        supplierModal.classList.remove("is-open");
    }

    function searchSupplierList() {
        var searchCode = getValue("modal_search_supplier_code");
        var searchName = getValue("modal_search_supplier_name");

        if (!supplierTableBody) {
            return;
        }

        supplierTableBody.innerHTML = `
            <tr>
                <td colspan="4" class="loading_text">読み込み中です...</td>
            </tr>
        `;

        fetch("m_supplier.cfc?method=getSupplierList&returnformat=json", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                search_supplier_code: searchCode,
                search_supplier_name: searchName
            })
        })
        .then(function (response) {
            if (!response.ok) {
                throw new Error("HTTPエラー: " + response.status);
            }

            return response.json();
        })
        .then(function (result) {
            renderSupplierTable(result);
        })
        .catch(function (error) {
            console.error(error);

            supplierTableBody.innerHTML = `
                <tr>
                    <td colspan="4" class="error_text">取引先一覧の取得に失敗しました。</td>
                </tr>
            `;
        });
    }

    function renderSupplierTable(result) {
        if (!supplierTableBody) {
            return;
        }

        if (!result || Number(result.status) !== 1) {
            supplierTableBody.innerHTML = `
                <tr>
                    <td colspan="4" class="error_text">${escapeHtml(result && result.message ? result.message : "取引先一覧の取得に失敗しました。")}</td>
                </tr>
            `;
            return;
        }

        if (!result.results || result.results.length === 0) {
            supplierTableBody.innerHTML = `
                <tr>
                    <td colspan="4" class="loading_text">該当データがありません。</td>
                </tr>
            `;
            return;
        }

        var html = "";

        result.results.forEach(function (supplier) {
            html += `
                <tr>
                    <td>${escapeHtml(supplier.supplier_code || "")}</td>
                    <td>${escapeHtml(supplier.supplier_name || "")}</td>
                    <td>${escapeHtml(supplier.delivery_company || "")}</td>
                    <td>
                        <button
                            type="button"
                            class="select-supplier-btn"
                            data-supplier-code="${escapeHtml(supplier.supplier_code || "")}"
                            data-supplier-name="${escapeHtml(supplier.supplier_name || "")}"
                        >
                            選択
                        </button>
                    </td>
                </tr>
            `;
        });

        supplierTableBody.innerHTML = html;
    }

    function setSupplierSelection(code, name) {
        if (supplierCodeInput) {
            supplierCodeInput.value = code;
        }

        if (supplierNameInput) {
            supplierNameInput.value = name;
        }

        if (supplierDisplayInput) {
            if (code !== "" && name !== "") {
                supplierDisplayInput.value = code + " " + name;
            } else if (code !== "") {
                supplierDisplayInput.value = code;
            } else {
                supplierDisplayInput.value = name;
            }

            CommonValidation.clearFieldError(supplierDisplayInput);
        }

        clearMessage();
    }

    function clearSupplierSelection() {
        if (supplierCodeInput) {
            supplierCodeInput.value = "";
        }

        if (supplierNameInput) {
            supplierNameInput.value = "";
        }

        if (supplierDisplayInput) {
            supplierDisplayInput.value = "";
            CommonValidation.clearFieldError(supplierDisplayInput);
        }
    }

    function collectDetailList() {
        var detailList = [];

        if (!itemTableBody) {
            return detailList;
        }

        var rows = itemTableBody.querySelectorAll("tr");

        rows.forEach(function (row) {
            var itemCodeInput = row.querySelector('input[name="item_code[]"]');
            var itemNameInput = row.querySelector('input[name="item_name[]"]');
            var qtyInput = row.querySelector('input[name="qty[]"]');
            var unitPriceInput = row.querySelector('input[name="unit_price[]"]');

            var itemCode = itemCodeInput ? itemCodeInput.value.trim() : "";
            var itemName = itemNameInput ? itemNameInput.value.trim() : "";
            var qty = qtyInput ? qtyInput.value.trim() : "";
            var unitPrice = unitPriceInput ? unitPriceInput.value.trim() : "";

            if (itemCode !== "" || itemName !== "" || qty !== "" || unitPrice !== "") {
                detailList.push({
                    item_code: itemCode,
                    item_name: itemName,
                    qty: qty,
                    unit_price: unitPrice
                });
            }
        });

        return detailList;
    }

    function getDetailErrorMessage(detailList) {
        for (var i = 0; i < detailList.length; i++) {
            var detail = detailList[i];

            if (detail.item_code === "") {
                return (i + 1) + "行目の商品コードを入力してください。";
            }

            if (detail.item_name === "") {
                return (i + 1) + "行目の商品名を入力してください。";
            }

            if (detail.qty === "") {
                return (i + 1) + "行目の数量を入力してください。";
            }

            if (detail.unit_price === "") {
                return (i + 1) + "行目の単価を入力してください。";
            }

            if (Number(detail.qty) <= 0) {
                return (i + 1) + "行目の数量は1以上を入力してください。";
            }

            if (Number(detail.unit_price) < 0) {
                return (i + 1) + "行目の単価は0以上を入力してください。";
            }
        }

        return "";
    }

    function addItemRow() {
        if (!itemTableBody) {
            return;
        }

        var rowHtml = `
            <tr>
                <td><input type="text" name="item_code[]" class="item-code" maxlength="20"></td>
                <td><input type="text" name="item_name[]" class="item-name" maxlength="100"></td>
                <td><input type="text" name="qty[]" class="qty" min="1" step="1"></td>
                <td><input type="text" name="unit_price[]" class="price" min="0" step="0.01"></td>
                <td>
                    <button type="button" class="table-btn sub delete-row-btn">削除</button>
                </td>
            </tr>
        `;

        itemTableBody.insertAdjacentHTML("beforeend", rowHtml);
    }

    async function deleteItemRow(button) {
        if (!itemTableBody) {
            return;
        }

        var rows = itemTableBody.querySelectorAll("tr");

        if (rows.length <= 1) {
            await Swal.fire({
                title: "削除できません",
                text: "明細行は1行以上必要です。",
                icon: "warning",
                confirmButtonText: "OK",
                confirmButtonColor: "#3F5B4B"
            });
            return;
        }

        var result = await Swal.fire({
            title: "この明細行を削除しますか？",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "削除する",
            cancelButtonText: "戻る",
            confirmButtonColor: "#B84A4A",
            cancelButtonColor: "#8A8175",
            reverseButtons: true
        });

        if (!result.isConfirmed) {
            return;
        }

        var targetRow = button.closest("tr");
        if (targetRow) {
            targetRow.remove();
        }
    }

    function resetItemRows() {
        if (!itemTableBody) {
            return;
        }

        itemTableBody.innerHTML = `
            <tr>
                <td><input type="text" name="item_code[]" class="item-code" maxlength="20"></td>
                <td><input type="text" name="item_name[]" class="item-name" maxlength="100"></td>
                <td><input type="number" name="qty[]" class="qty" min="1" step="1"></td>
                <td><input type="number" name="unit_price[]" class="price" min="0" step="0.01"></td>
                <td>
                    <button type="button" class="table-btn sub delete-row-btn">削除</button>
                </td>
            </tr>
        `;
    }

    function setSaveButtonLoading(flag) {
        if (!saveButton) {
            return;
        }

        saveButton.disabled = flag;

        if (flag) {
            saveButton.textContent = "登録中...";
        } else {
            saveButton.textContent = "登録";
        }
    }

    function showErrorMessage(message) {
        if (!messageArea) {
            return;
        }

        messageArea.textContent = message;
        messageArea.className = "message-area error is-visible";
    }

    function showSuccessMessage(message) {
        if (!messageArea) {
            return;
        }

        messageArea.textContent = message;
        messageArea.className = "message-area success is-visible";
    }

    function clearMessage() {
        if (!messageArea) {
            return;
        }

        messageArea.textContent = "";
        messageArea.className = "message-area";
    }

    function clearAllFieldErrors() {
        if (!form) {
            return;
        }

        var errorInputs = form.querySelectorAll(".is-error");
        var errorMessages = form.querySelectorAll(".field-error");

        errorInputs.forEach(function (input) {
            input.classList.remove("is-error");
        });

        errorMessages.forEach(function (message) {
            message.classList.remove("is-visible");
            message.textContent = "";
        });
    }

    function getValue(id) {
        var element = document.getElementById(id);

        if (!element) {
            return "";
        }

        return element.value.trim();
    }

    function escapeHtml(value) {
        if (value === null || value === undefined) {
            return "";
        }

        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function bindEnterMoveEvents() {
        const inputs = document.querySelectorAll(
            "#slip_date, #supplier_display, #delivery_date, #memo"
        );

        inputs.forEach(function (input, index) {
            input.addEventListener("keydown", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();

                    if (index < inputs.length - 1) {
                        inputs[index + 1].focus();
                    }
                }
            });
        });
    }

    function bindEnterMoveEventsForTable() {
        const table = document.getElementById("item_table_body");

        if (!table) return;

        table.addEventListener("keydown", function (event) {
            if (event.key !== "Enter") return;

            const inputs = table.querySelectorAll("input");
            const currentIndex = Array.from(inputs).indexOf(event.target);

            if (currentIndex === -1) return;

            event.preventDefault();

            if (currentIndex < inputs.length - 1) {
                inputs[currentIndex + 1].focus();
            }
        });
    }

    function bindItemCodeAutoFill() {
        const table = document.getElementById("item_table_body");
        if (!table) return;

        table.addEventListener("blur", async function (event) {
            if (!event.target.classList.contains("item-code")) return;

            const itemCode = event.target.value.trim();
            if (!itemCode) return;

            const row = event.target.closest("tr");
            const itemNameInput = row.querySelector(".item-name");
            const priceInput = row.querySelector(".price");

            try {
                const response = await fetch("add_slip.cfc?method=getItemByCode&returnformat=json", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        item_code: itemCode
                    })
                });

                const rawText = await response.text();
                const data = JSON.parse(rawText);

                if (data.status === 0) {
                    itemNameInput.value = data.results.item_name || "";
                    priceInput.value = data.results.gentanka || "";
                } else {
                    itemNameInput.value = "";
                    itemNameInput.textContent = "";
                    priceInput.value = "";
                    priceInput.textContent = "";

                    await Swal.fire({
                        title: "商品が見つかりません",
                        text: data.message || "商品が見つかりません。",
                        icon: "warning",
                        confirmButtonText: "OK",
                        confirmButtonColor: "#3F5B4B"
                    });

                }
            } catch (error) {
                console.error("商品取得エラー:", error);

                await Swal.fire({
                    title: "商品取得エラー",
                    text: "商品取得に失敗しました。",
                    icon: "error",
                    confirmButtonText: "OK",
                    confirmButtonColor: "#B84A4A"
                });
            }
        }, true);
    }

    function bindDatePicker() {
        if (typeof flatpickr === "undefined") {
            console.error("flatpickr が読み込まれていません。");
            return;
        }

        flatpickr(".js-date-picker", {
            locale: "ja",
            dateFormat: "Y-m-d",
            altInput: true,
            altFormat: "Y年m月d日",
            altInputClass: "form-input flatpickr-display-input",
            allowInput: false,
            disableMobile: true,
            monthSelectorType: "static",
            prevArrow: "<span aria-hidden='true'>‹</span>",
            nextArrow: "<span aria-hidden='true'>›</span>"
        });
    }

    backButton.addEventListener('click', function(){
        location.href = 'menu.cfm';
    })

});