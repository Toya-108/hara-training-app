document.addEventListener("DOMContentLoaded", function () {
    // ===== 要素取得 =====
    const detailButton = document.getElementById("detail_button");
    const userMenu = document.getElementById("user_menu");
    const arrowIcon = document.getElementById("arrow_icon");
    const logoutButton = document.getElementById("logout-button");

    const addSlipButton = document.getElementById("add_slip_button");
    const slipListButton = document.getElementById("slip_list_button");

    const inventoryButton = document.getElementById("inventory_button");

    const masterButton = document.getElementById("master_button");
    const masterModal = document.getElementById("master_modal");
    const closeModalButton = document.getElementById("close_modal_button");

    const itemMasterButton = document.getElementById("item-master-button");
    const supplierMasterButton = document.getElementById("supplier-master-button");
    const staffMasterButton = document.getElementById("staff-master-button");

    const adminButton = document.getElementById("admin_button");
    const totalReportButton = document.getElementById("total_report_button");

    // ===== ダッシュボード要素取得 =====
    const todaySlipCount = document.getElementById("today_slip_count");
    const unfixedSlipCount = document.getElementById("unfixed_slip_count");
    const todayTotalQty = document.getElementById("today_total_qty");
    const todayTotalAmount = document.getElementById("today_total_amount");
    const deletedSlipCount = document.getElementById("deleted_slip_count");
    const recentSlipList = document.getElementById("recent_slip_list");

    const todaySlipCountCard = document.getElementById("today_slip_count_card");
    const unfixedSlipCountCard = document.getElementById("unfixed_slip_count_card");
    const todayTotalQtyCard = document.getElementById("today_total_qty_card");
    const todayTotalAmountCard = document.getElementById("today_total_amount_card");

    // ===== ユーザーメニュー開閉 =====
    if (detailButton && userMenu && arrowIcon) {
        detailButton.addEventListener("click", function (event) {
            event.stopPropagation();

            if (userMenu.classList.contains("is-open")) {
                userMenu.classList.remove("is-open");
                arrowIcon.src = arrowIcon.dataset.down;
            } else {
                userMenu.classList.add("is-open");
                arrowIcon.src = arrowIcon.dataset.up;
            }
        });

        document.addEventListener("click", function (event) {
            if (!userMenu.contains(event.target) && !detailButton.contains(event.target)) {
                userMenu.classList.remove("is-open");
                arrowIcon.src = arrowIcon.dataset.down;
            }
        });
    }

    // ===== ログアウト =====
    if (logoutButton) {
        logoutButton.addEventListener("click", function () {
            location.href = "login.cfm";
        });
    }

    // ===== 伝票登録 =====
    if (addSlipButton) {
        addSlipButton.addEventListener("click", function (event) {
            if (addSlipButton.classList.contains("disabled-button")) {
                event.preventDefault();
                return false;
            }

            location.href = "add_slip.cfm";
        });
    }

    // ===== 伝票一覧 =====
    if (slipListButton) {
        slipListButton.addEventListener("click", function () {
            location.href = "slip_list.cfm";
        });
    }

    // ===== マスタモーダルを開く =====
    if (masterButton && masterModal) {
        masterButton.addEventListener("click", function () {
            masterModal.classList.add("is-open");
        });
    }

    // ===== マスタモーダルを閉じる =====
    if (closeModalButton && masterModal) {
        closeModalButton.addEventListener("click", function () {
            masterModal.classList.remove("is-open");
        });
    }

    // ===== モーダル背景押下で閉じる =====
    if (masterModal) {
        masterModal.addEventListener("click", function (event) {
            if (event.target === masterModal) {
                masterModal.classList.remove("is-open");
            }
        });
    }

    // ===== 商品マスタ =====
    if (itemMasterButton) {
        itemMasterButton.addEventListener("click", function () {
            location.href = "m_item.cfm";
        });
    }

    // ===== 取引先マスタ =====
    if (supplierMasterButton) {
        supplierMasterButton.addEventListener("click", function () {
            location.href = "m_supplier.cfm";
        });
    }

    // ===== 社員マスタ =====
    if (staffMasterButton) {
        staffMasterButton.addEventListener("click", function () {
            location.href = "m_staff.cfm";
        });
    }

    // ===== 基本設定 =====
    if (adminButton) {
        adminButton.addEventListener("click", function () {
            location.href = "admin_setting.cfm";
        });
    }

    // ===== 集計レポートメニュー =====
    if (totalReportButton) {
        totalReportButton.addEventListener("click", function () {
            location.href = "total_report.cfm";
        });
    }

    // ===== 在庫管理メニュー =====
    if (inventoryButton) {
        inventoryButton.addEventListener("click", function () {
            location.href = "inventory.cfm";
        });
    }

    // ===== 今日の日付（yyyy/mm/dd） =====
    function getTodayString() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, "0");
        const day = String(now.getDate()).padStart(2, "0");
        return year + "/" + month + "/" + day;
    }

    // ===== hidden追加 =====
    function appendHidden(form, name, value) {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = name;
        input.value = value;
        form.appendChild(input);
    }

    // ===== 伝票一覧へPOST遷移 =====
    function submitSlipListForm(params) {
        const form = document.createElement("form");
        form.method = "POST";
        form.action = "slip_list.cfm";

        appendHidden(form, "return_search_slip_no", params.return_search_slip_no || "");
        appendHidden(form, "return_search_order_date_from", params.return_search_order_date_from || "");
        appendHidden(form, "return_search_order_date_to", params.return_search_order_date_to || "");
        appendHidden(form, "return_search_delivery_date_from", params.return_search_delivery_date_from || "");
        appendHidden(form, "return_search_delivery_date_to", params.return_search_delivery_date_to || "");
        appendHidden(form, "return_search_supplier_code", params.return_search_supplier_code || "");
        appendHidden(form, "return_search_supplier_keyword", params.return_search_supplier_keyword || "");
        appendHidden(form, "return_search_item_keyword", params.return_search_item_keyword || "");
        appendHidden(form, "return_search_status", params.return_search_status || "");
        appendHidden(form, "return_current_page", params.return_current_page || "1");
        appendHidden(form, "return_sort_field", params.return_sort_field || "");
        appendHidden(form, "return_sort_order", params.return_sort_order || "");

        document.body.appendChild(form);
        form.submit();
    }

    // ===== 伝票詳細へPOST遷移 =====
    function submitSlipDetailForm(slipNo) {
        const form = document.createElement("form");
        form.method = "POST";
        form.action = "slip_list_dt.cfm";

        appendHidden(form, "detail_slip_no", slipNo);
        appendHidden(form, "detail_display_mode", "view");
        appendHidden(form, "return_from_menu", "1");

        appendHidden(form, "return_search_slip_no", "");
        appendHidden(form, "return_search_order_date_from", "");
        appendHidden(form, "return_search_order_date_to", "");
        appendHidden(form, "return_search_delivery_date_from", "");
        appendHidden(form, "return_search_delivery_date_to", "");
        appendHidden(form, "return_search_supplier_code", "");
        appendHidden(form, "return_search_supplier_keyword", "");
        appendHidden(form, "return_search_item_keyword", "");
        appendHidden(form, "return_search_status", "");
        appendHidden(form, "return_current_page", "1");
        appendHidden(form, "return_sort_field", "");
        appendHidden(form, "return_sort_order", "");

        document.body.appendChild(form);
        form.submit();
    }

    // ===== 集計レポートへPOST遷移 =====
    function submitTotalReportForm(dashboardMode) {
        const form = document.createElement("form");
        const today = getTodayString();

        form.method = "POST";
        form.action = "total_report.cfm";

        appendHidden(form, "slip_date_from", today);
        appendHidden(form, "slip_date_to", today);
        appendHidden(form, "delivery_date_from", "");
        appendHidden(form, "delivery_date_to", "");
        appendHidden(form, "supplier_code", "");
        appendHidden(form, "item_keyword", "");
        appendHidden(form, "status", "");
        appendHidden(form, "report_type", "day");
        appendHidden(form, "dashboard_mode", dashboardMode);

        document.body.appendChild(form);
        form.submit();
    }

    // ===== KPIカードクリック =====
    if (todaySlipCountCard) {
        todaySlipCountCard.addEventListener("click", function () {
            const today = getTodayString();

            submitSlipListForm({
                return_search_order_date_from: today,
                return_search_order_date_to: today,
                return_current_page: "1"
            });
        });
    }

    if (unfixedSlipCountCard) {
        unfixedSlipCountCard.addEventListener("click", function () {
            submitSlipListForm({
                return_search_status: "1",
                return_current_page: "1"
            });
        });
    }

    if (todayTotalQtyCard) {
        todayTotalQtyCard.addEventListener("click", function () {
            submitTotalReportForm("qty");
        });
    }

    if (todayTotalAmountCard) {
        todayTotalAmountCard.addEventListener("click", function () {
            submitTotalReportForm("amount");
        });
    }

    // ===== 初期表示時にダッシュボード読み込み =====
    loadDashboard();

    async function loadDashboard() {
        try {
            const response = await fetch("menu.cfc?method=getDashboardData&returnformat=json", {
                method: "GET",
                cache: "no-cache"
            });

            if (!response.ok) {
                throw new Error("ダッシュボードの取得に失敗しました。");
            }

            const data = await response.json();

            if (data.STATUS !== 0 && data.status !== 0) {
                throw new Error(data.MESSAGE || data.message || "ダッシュボードの取得に失敗しました。");
            }

            const result = data.RESULTS || data.results || {};
            setDashboardData(result);

        } catch (error) {
            console.error(error);
            showDashboardError("ダッシュボードの読み込み中にエラーが発生しました。");
        }
    }

    function setDashboardData(result) {
        if (todaySlipCount) {
            todaySlipCount.textContent = formatNumber(result.today_slip_count || 0) + "件";
        }

        if (unfixedSlipCount) {
            unfixedSlipCount.textContent = formatNumber(result.unfixed_slip_count || 0) + "件";
        }

        if (todayTotalQty) {
            todayTotalQty.textContent = formatNumber(result.today_total_qty || 0);
        }

        if (todayTotalAmount) {
            todayTotalAmount.textContent = "¥" + formatNumber(result.today_total_amount || 0);
        }

        if (deletedSlipCount) {
            deletedSlipCount.textContent = formatNumber(result.deleted_slip_count || 0) + "件";
        }

        renderRecentSlipList(result.recent_slips || []);
    }

    function renderRecentSlipList(recentSlips) {
        if (!recentSlipList) {
            return;
        }

        if (!recentSlips || recentSlips.length === 0) {
            recentSlipList.innerHTML = '<p class="empty-text">最近の伝票はありません。</p>';
            return;
        }

        let html = "";

        recentSlips.forEach(function (slip) {
            html += `
                <div class="info-item clickable-item js-recent-slip-row" data-slip-no="${escapeHtml(slip.slip_no || "")}">
                    <div class="info-item-left">
                        <div class="info-main">伝票番号: ${escapeHtml(slip.slip_no || "")}</div>
                        <div class="info-sub">
                            発注日: ${escapeHtml(slip.slip_date || "")}
                            ／ 納品日: ${escapeHtml(slip.delivery_date || "")}
                            ／ 取引先: ${escapeHtml(slip.supplier_name || "")}
                        </div>
                    </div>
                    <div class="status-badge status-${escapeHtml(String(slip.status || ""))}">
                        ${escapeHtml(slip.status_name || "")}
                    </div>
                </div>
            `;
        });

        recentSlipList.innerHTML = html;
        bindRecentSlipEvents();
    }

    function bindRecentSlipEvents() {
        const rows = document.querySelectorAll(".js-recent-slip-row");

        rows.forEach(function (row) {
            row.addEventListener("click", function () {
                const slipNo = row.dataset.slipNo || "";
                if (!slipNo) {
                    return;
                }

                submitSlipDetailForm(slipNo);
            });
        });
    }

    function showDashboardError(message) {
        if (todaySlipCount) {
            todaySlipCount.textContent = "-";
        }
        if (unfixedSlipCount) {
            unfixedSlipCount.textContent = "-";
        }
        if (todayTotalQty) {
            todayTotalQty.textContent = "-";
        }
        if (todayTotalAmount) {
            todayTotalAmount.textContent = "-";
        }
        if (deletedSlipCount) {
            deletedSlipCount.textContent = "-";
        }
        if (recentSlipList) {
            recentSlipList.innerHTML = '<p class="error-text">' + escapeHtml(message) + "</p>";
        }
    }

    function formatNumber(value) {
        return Number(value).toLocaleString();
    }

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }
});