// ===== 定数定義 =====
const inventoryCategoryMap = {
    "1": "食品",
    "2": "雑貨",
    "3": "日用品",
    "4": "衣料",
    "5": "小物"
};

document.addEventListener("DOMContentLoaded", function () {
    const searchForm = document.getElementById("search_form");
    const clearButton = document.getElementById("clear_button");
    const listBody = document.getElementById("inventory_list_body");
    const pagination = document.getElementById("pagination");
    const listInfo = document.getElementById("list_info");

    const summaryItemCount = document.getElementById("summary_item_count");
    const summaryTotalQty = document.getElementById("summary_total_qty");
    const summaryLowStockCount = document.getElementById("summary_low_stock_count");

    const sortButtons = document.querySelectorAll(".sort-button");

    const adjustModal = document.getElementById("adjust_modal");
    const modalItemInfo = document.getElementById("modal_item_info");
    const modalCloseButton = document.getElementById("modal_close_button");
    const saveAdjustButton = document.getElementById("save_adjust_button");

    const adjustItemCode = document.getElementById("adjust_item_code");
    const adjustType = document.getElementById("adjust_type");
    const adjustQty = document.getElementById("adjust_qty");
    const adjustSafetyStockQty = document.getElementById("adjust_safety_stock_qty");
    const adjustCurrentQtyPreview = document.getElementById("adjust_current_qty_preview");
    const adjustReason = document.getElementById("adjust_reason");

    const searchItemCode = document.getElementById("search_item_code");
    const searchJanCode = document.getElementById("search_jan_code");
    const searchKeyword = document.getElementById("search_keyword");
    const searchItemCategory = document.getElementById("search_item_category");
    const searchStockStatus = document.getElementById("search_stock_status");
    const searchQtyFrom = document.getElementById("search_qty_from");
    const searchQtyTo = document.getElementById("search_qty_to");
    const searchSafetyStockOnly = document.getElementById("search_safety_stock_only");

    const homeButton = document.getElementById("home-btn");

    let searchState = {
        item_code: "",
        jan_code: "",
        keyword: "",
        item_category: "",
        stock_status: "",
        qty_from: "",
        qty_to: "",
        safety_stock_only: "0",
        page: 1,
        page_size: 10,
        sort_column: "item_code",
        sort_order: "asc"
    };

    let currentRows = [];
    let currentTargetRow = null;

    initialize();

    async function initialize() {
        bindEvents();
        await loadInventoryList();
    }

    function bindEvents() {
        searchForm.addEventListener("submit", async function (event) {
            event.preventDefault();
            updateSearchStateFromForm();
            searchState.page = 1;
            await loadInventoryList();
        });

        clearButton.addEventListener("click", async function () {
            clearSearchForm();
            updateSearchStateFromForm();
            searchState.page = 1;
            searchState.sort_column = "item_code";
            searchState.sort_order = "asc";
            await loadInventoryList();
        });

        sortButtons.forEach(function (button) {
            button.addEventListener("click", async function () {
                const sortColumn = button.dataset.sortColumn;
                if (!sortColumn) {
                    return;
                }

                if (searchState.sort_column === sortColumn) {
                    searchState.sort_order = searchState.sort_order === "asc" ? "desc" : "asc";
                } else {
                    searchState.sort_column = sortColumn;
                    searchState.sort_order = "asc";
                }

                searchState.page = 1;
                await loadInventoryList();
            });
        });

        modalCloseButton.addEventListener("click", closeAdjustModal);

        adjustModal.addEventListener("click", function (event) {
            if (event.target === adjustModal) {
                closeAdjustModal();
            }
        });

        saveAdjustButton.addEventListener("click", async function () {
            await saveInventoryAdjustment();
        });

        if (homeButton) {
            homeButton.addEventListener("click", function () {
                location.href = "menu.cfm";
            });
        }
    }

    function updateSearchStateFromForm() {
        searchState.item_code = searchItemCode.value.trim();
        searchState.jan_code = searchJanCode.value.trim();
        searchState.keyword = searchKeyword.value.trim();
        searchState.item_category = searchItemCategory.value;
        searchState.stock_status = searchStockStatus.value;
        searchState.qty_from = searchQtyFrom.value.trim();
        searchState.qty_to = searchQtyTo.value.trim();
        searchState.safety_stock_only = searchSafetyStockOnly.value;
    }

    function clearSearchForm() {
        searchItemCode.value = "";
        searchJanCode.value = "";
        searchKeyword.value = "";
        searchItemCategory.value = "";
        searchStockStatus.value = "";
        searchQtyFrom.value = "";
        searchQtyTo.value = "";
        searchSafetyStockOnly.value = "0";
    }

    function buildInventoryListFormData() {
        const formData = new FormData();
        formData.append("item_code", searchState.item_code);
        formData.append("jan_code", searchState.jan_code);
        formData.append("keyword", searchState.keyword);
        formData.append("item_category", searchState.item_category);
        formData.append("stock_status", searchState.stock_status);
        formData.append("qty_from", searchState.qty_from);
        formData.append("qty_to", searchState.qty_to);
        formData.append("safety_stock_only", searchState.safety_stock_only);
        formData.append("page", String(searchState.page));
        formData.append("page_size", String(searchState.page_size));
        formData.append("sort_column", searchState.sort_column);
        formData.append("sort_order", searchState.sort_order);
        return formData;
    }

    async function postInventoryApi(methodName, formData) {
        const response = await fetch(
            "https://tudmweb3.bestcloud.jp/training/hara/inventory.cfc?method=" + methodName + "&returnformat=json",
            {
                method: "POST",
                body: formData
            }
        );

        return await response.json();
    }

    async function loadInventoryList() {
        try {
            listBody.innerHTML = '<tr><td colspan="9">データを読み込み中です。</td></tr>';
            pagination.innerHTML = "";

            const formData = buildInventoryListFormData();
            const data = await postInventoryApi("getInventoryList", formData);

            if (data.status !== 0) {
                showAlert(data.message || "在庫一覧の取得に失敗しました。", "error");
                listBody.innerHTML = '<tr><td colspan="9">データの取得に失敗しました。</td></tr>';
                renderSummary({});
                return;
            }

            currentRows = Array.isArray(data.results && data.results.rows) ? data.results.rows : [];
            renderList(currentRows);
            renderSummary((data.results && data.results.summary) || {});
            renderPagination((data.results && data.results.pagination) || {});
        } catch (error) {
            console.error(error);
            showAlert("在庫一覧の取得中にエラーが発生しました。", "error");
            listBody.innerHTML = '<tr><td colspan="9">データの取得に失敗しました。</td></tr>';
            renderSummary({});
            pagination.innerHTML = "";
        }
    }

    function renderList(rows) {
        if (!Array.isArray(rows) || rows.length === 0) {
            listBody.innerHTML = '<tr><td colspan="9">該当する在庫データがありません。</td></tr>';
            listInfo.textContent = "0件表示";
            return;
        }

        const html = rows.map(function (row, index) {
            const stockStatusLabel = getStockStatusLabel(row);
            const qtyClass = getQtyClass(row);
            const itemCategoryName = row.item_category_name || inventoryCategoryMap[String(row.item_category || "")] || "";

            return `
                <tr data-row-index="${index}">
                    <td>${escapeHtml(row.item_code || "")}</td>
                    <td>${escapeHtml(row.jan_code || "")}</td>
                    <td>${escapeHtml(row.item_name || "")}</td>
                    <td>${escapeHtml(itemCategoryName)}</td>
                    <td class="qty-cell ${qtyClass}">${formatNumber(row.current_qty)}</td>
                    <td>${formatNumber(row.safety_stock_qty)}</td>
                    <td>${escapeHtml(stockStatusLabel)}</td>
                    <td>${escapeHtml(row.update_datetime || "")}</td>
                    <td>
                        <button type="button" class="row-action-button" data-adjust-index="${index}">調整</button>
                    </td>
                </tr>
            `;
        }).join("");

        listBody.innerHTML = html;

        const rowButtons = listBody.querySelectorAll("[data-adjust-index]");
        rowButtons.forEach(function (button) {
            button.addEventListener("click", function (event) {
                event.stopPropagation();
                const index = Number(button.dataset.adjustIndex);
                const row = currentRows[index];
                if (row) {
                    openAdjustModal(row);
                }
            });
        });

        const tableRows = listBody.querySelectorAll("tr[data-row-index]");
        tableRows.forEach(function (tr) {
            tr.addEventListener("click", function () {
                const index = Number(tr.dataset.rowIndex);
                const row = currentRows[index];
                if (row) {
                    openAdjustModal(row);
                }
            });
        });
    }

    function renderSummary(summary) {
        summaryItemCount.textContent = formatNumber(summary.item_count || 0);
        summaryTotalQty.textContent = formatNumber(summary.total_qty || 0);
        summaryLowStockCount.textContent = formatNumber(summary.low_stock_count || 0);
    }

    function renderPagination(paginationInfo) {
        const currentPage = Number(paginationInfo.current_page || 1);
        const totalPages = Number(paginationInfo.total_pages || 1);
        const totalCount = Number(paginationInfo.total_count || 0);

        listInfo.textContent = `全${formatNumber(totalCount)}件 / ${formatNumber(currentPage)}ページ目`;

        if (totalPages <= 1) {
            pagination.innerHTML = "";
            return;
        }

        let html = "";
        html += `<button type="button" class="page-button" data-page="${currentPage - 1}" ${currentPage <= 1 ? "disabled" : ""}>前へ</button>`;

        const startPage = Math.max(1, currentPage - 2);
        const endPage = Math.min(totalPages, currentPage + 2);

        for (let page = startPage; page <= endPage; page++) {
            html += `<button type="button" class="page-button ${page === currentPage ? "active" : ""}" data-page="${page}">${page}</button>`;
        }

        html += `<button type="button" class="page-button" data-page="${currentPage + 1}" ${currentPage >= totalPages ? "disabled" : ""}>次へ</button>`;

        pagination.innerHTML = html;

        const pageButtons = pagination.querySelectorAll("[data-page]");
        pageButtons.forEach(function (button) {
            button.addEventListener("click", async function () {
                const page = Number(button.dataset.page);
                if (!page || page < 1 || page === searchState.page) {
                    return;
                }

                searchState.page = page;
                await loadInventoryList();
            });
        });
    }

    function openAdjustModal(row) {
        currentTargetRow = row;

        adjustItemCode.value = row.item_code || "";
        adjustType.value = "1";
        adjustQty.value = "";
        adjustSafetyStockQty.value = row.safety_stock_qty != null ? row.safety_stock_qty : 0;
        adjustCurrentQtyPreview.value = formatNumber(row.current_qty || 0);
        adjustReason.value = "";

        modalItemInfo.innerHTML = `
            <div><strong>商品コード：</strong>${escapeHtml(row.item_code || "")}</div>
            <div><strong>JANコード：</strong>${escapeHtml(row.jan_code || "")}</div>
            <div><strong>商品名：</strong>${escapeHtml(row.item_name || "")}</div>
            <div><strong>現在庫数：</strong>${formatNumber(row.current_qty || 0)}</div>
        `;

        adjustModal.classList.add("is-open");
    }

    function closeAdjustModal() {
        adjustModal.classList.remove("is-open");
        currentTargetRow = null;
    }

    function buildSaveAdjustmentFormData(qtyValue, safetyStockQtyValue) {
        const formData = new FormData();
        formData.append("item_code", adjustItemCode.value);
        formData.append("change_type", adjustType.value);
        formData.append("change_qty", qtyValue);
        formData.append("safety_stock_qty", safetyStockQtyValue === "" ? "0" : safetyStockQtyValue);
        formData.append("reason", adjustReason.value.trim());
        return formData;
    }

    async function saveInventoryAdjustment() {
        try {
            if (!currentTargetRow) {
                showAlert("対象データが選択されていません。", "warning");
                return;
            }

            const qtyValue = adjustQty.value.trim();
            const safetyStockQtyValue = adjustSafetyStockQty.value.trim();

            if (qtyValue === "") {
                showAlert("数量を入力してください。", "warning");
                adjustQty.focus();
                return;
            }

            if (!isNumeric(qtyValue)) {
                showAlert("数量は数値を入力してください。", "warning");
                adjustQty.focus();
                return;
            }

            if (safetyStockQtyValue !== "" && !isNumeric(safetyStockQtyValue)) {
                showAlert("安全在庫数は数値を入力してください。", "warning");
                adjustSafetyStockQty.focus();
                return;
            }

            const confirmed = await Swal.fire({
                title: "在庫を更新しますか？",
                text: "入力内容で在庫数を更新します。",
                icon: "question",
                showCancelButton: true,
                confirmButtonText: "更新する",
                cancelButtonText: "キャンセル",
                confirmButtonColor: "#3F5B4B"
            });

            if (!confirmed.isConfirmed) {
                return;
            }

            const formData = buildSaveAdjustmentFormData(qtyValue, safetyStockQtyValue);
            const data = await postInventoryApi("saveInventoryAdjustment", formData);

            if (data.status !== 0) {
                showAlert(data.message || "在庫更新に失敗しました。", "error");
                return;
            }

            await Swal.fire({
                title: "更新しました。",
                text: data.message || "在庫を更新しました。",
                icon: "success",
                confirmButtonColor: "#3F5B4B"
            });

            closeAdjustModal();
            await loadInventoryList();
        } catch (error) {
            console.error(error);
            showAlert("在庫更新中にエラーが発生しました。", "error");
        }
    }

    function getStockStatusLabel(row) {
        const currentQty = Number(row.current_qty || 0);
        const safetyStockQty = Number(row.safety_stock_qty || 0);

        if (currentQty <= 0) {
            return "在庫ゼロ";
        }

        if (currentQty <= safetyStockQty) {
            return "不足";
        }

        return "通常";
    }

    function getQtyClass(row) {
        const currentQty = Number(row.current_qty || 0);
        const safetyStockQty = Number(row.safety_stock_qty || 0);

        if (currentQty <= 0) {
            return "zero-stock";
        }

        if (currentQty <= safetyStockQty) {
            return "low-stock";
        }

        return "";
    }

    function formatNumber(value) {
        const num = Number(value || 0);
        return num.toLocaleString("ja-JP");
    }

    function isNumeric(value) {
        return /^-?\d+$/.test(value);
    }

    function escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#39;");
    }

    function showAlert(message, icon) {
        Swal.fire({
            title: message,
            icon: icon || "info",
            confirmButtonColor: "#3F5B4B"
        });
    }
});