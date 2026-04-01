document.addEventListener("DOMContentLoaded", function () {
    const form = document.getElementById("report_search_form");
    const clearButton = document.getElementById("clear_button");
    const reportType = document.getElementById("report_type");
    const columnGroupKey = document.getElementById("column_group_key");
    const tableBody = document.getElementById("report_table_body");
    const loadingArea = document.getElementById("loading_area");

    const summarySlipCount = document.getElementById("summary_slip_count");
    const summaryTotalQty = document.getElementById("summary_total_qty");
    const summaryTotalAmount = document.getElementById("summary_total_amount");
    const summaryRowCount = document.getElementById("summary_row_count");

    const exportButton = document.getElementById('export-button');
    const homeButton = document.getElementById('home-btn');

    // ===== 日付ピッカー =====
    if (typeof flatpickr !== "undefined") {
        flatpickr(".datepicker", {
            locale: "ja",
            dateFormat: "Y/m/d",
            allowInput: true
        });
    }

    // ===== 集計区分に応じて見出し変更 =====
    function updateGroupKeyLabel() {
        const value = reportType.value;

        if (value === "day") {
            columnGroupKey.textContent = "日付";
        } else if (value === "supplier") {
            columnGroupKey.textContent = "取引先";
        } else if (value === "item") {
            columnGroupKey.textContent = "商品";
        } else if (value === "status") {
            columnGroupKey.textContent = "状態";
        } else {
            columnGroupKey.textContent = "集計キー";
        }
    }

    // ===== 数値フォーマット =====
    function formatNumber(value) {
        const num = Number(value || 0);
        return num.toLocaleString();
    }

    function formatCurrency(value) {
        const num = Number(value || 0);
        return "¥" + num.toLocaleString();
    }

    // ===== HTMLエスケープ =====
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

    // ===== サマリー描画 =====
    function renderSummary(summary, rowCount) {
        summarySlipCount.textContent = formatNumber(summary.total_slip_count) + "件";
        summaryTotalQty.textContent = formatNumber(summary.total_qty);
        summaryTotalAmount.textContent = formatCurrency(summary.total_amount);
        summaryRowCount.textContent = formatNumber(rowCount) + "行";
    }

    // ===== テーブル描画 =====
    function renderTable(results) {
        if (!results || results.length === 0) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="4" class="report-empty">該当データがありません。</td>
                </tr>
            `;
            return;
        }

        let html = "";

        results.forEach(function (row) {
            html += `
                <tr>
                    <td>${escapeHtml(row.group_key)}</td>
                    <td>${formatNumber(row.slip_count)}</td>
                    <td>${formatNumber(row.total_qty)}</td>
                    <td>${formatCurrency(row.total_amount)}</td>
                </tr>
            `;
        });

        tableBody.innerHTML = html;
    }

    // ===== ローディング表示 =====
    function setLoading(isLoading) {
        if (isLoading) {
            loadingArea.style.display = "block";
        } else {
            loadingArea.style.display = "none";
        }
    }

    // ===== 初期表示に戻す =====
    function resetDisplay() {
        tableBody.innerHTML = `
            <tr>
                <td colspan="4" class="report-empty">検索条件を指定して「集計する」を押してください。</td>
            </tr>
        `;

        summarySlipCount.textContent = "0件";
        summaryTotalQty.textContent = "0";
        summaryTotalAmount.textContent = "¥0";
        summaryRowCount.textContent = "0行";
    }

    // ===== 条件取得 =====
    function getSearchParams() {
        return {
            slip_date_from: document.getElementById("slip_date_from").value,
            slip_date_to: document.getElementById("slip_date_to").value,
            delivery_date_from: document.getElementById("delivery_date_from").value,
            delivery_date_to: document.getElementById("delivery_date_to").value,
            supplier_code: document.getElementById("supplier_code").value,
            item_keyword: document.getElementById("item_keyword").value,
            status: document.getElementById("status").value,
            report_type: document.getElementById("report_type").value
        };
    }

    // ===== FormData作成 =====
    function createFormData(params) {
        const formData = new FormData();

        Object.keys(params).forEach(function (key) {
            formData.append(key, params[key]);
        });

        return formData;
    }

    // ===== 集計実行 =====
    async function searchReport() {
        setLoading(true);

        try {
            const params = getSearchParams();
            const formData = createFormData(params);

            const response = await fetch(
                "total_report.cfc?method=getTotalReport&returnformat=json",
                {
                    method: "POST",
                    body: formData
                }
            );

            if (!response.ok) {
                throw new Error("HTTP_ERROR");
            }

            const data = await response.json();

            if (data.status !== 0) {
                await Swal.fire({
                    icon: "warning",
                    title: "エラー",
                    text: data.message || "集計に失敗しました。"
                });
                return;
            }

            renderSummary(data.summary, data.results.length);
            renderTable(data.results);

        } catch (error) {
            await Swal.fire({
                icon: "error",
                title: "通信エラー",
                text: "集計取得中に通信エラーが発生しました。"
            });
        } finally {
            setLoading(false);
        }
    }

    // ===== 条件クリア =====
    clearButton.addEventListener("click", function () {
        document.getElementById("delivery_date_from").value = "";
        document.getElementById("delivery_date_to").value = "";
        document.getElementById("supplier_code").value = "";
        document.getElementById("item_keyword").value = "";
        document.getElementById("status").value = "";
        document.getElementById("report_type").value = "day";

        updateGroupKeyLabel();
        resetDisplay();
    });

    // ===== フォーム送信 =====
    form.addEventListener("submit", async function (event) {
        event.preventDefault();
        await searchReport();
    });

    // ===== 集計区分変更時 =====
    reportType.addEventListener("change", function () {
        updateGroupKeyLabel();
    });

    updateGroupKeyLabel();

    // 初回表示時に自動検索
    searchReport();

function submitExport() {
    const exportForm = document.createElement("form");
    exportForm.method = "POST";
    exportForm.action = "total_report_export.cfm";

    const params = getSearchParams();

    Object.keys(params).forEach(function (key) {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = key;
        input.value = params[key];
        exportForm.appendChild(input);
    });

    document.body.appendChild(exportForm);
    exportForm.submit();
    document.body.removeChild(exportForm);
}

if (exportButton) {
    exportButton.addEventListener("click", function () {
        submitExport();
    });
}

homeButton.addEventListener('click', function(){
  location.href = 'menu.cfm';
});

});