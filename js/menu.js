document.addEventListener("DOMContentLoaded", function () {
    // ===== 要素取得 =====
    const detailButton = document.getElementById("detail_button");
    const userMenu = document.getElementById("user_menu");
    const arrowIcon = document.getElementById("arrow_icon");
    const logoutButton = document.getElementById("logout-button");

    const addSlipButton = document.getElementById("add_slip_button");
    const slipListButton = document.getElementById("slip_list_button");

    const masterButton = document.getElementById("master_button");
    const masterModal = document.getElementById("master_modal");
    const closeModalButton = document.getElementById("close_modal_button");

    const itemMasterButton = document.getElementById("item-master-button");
    const supplierMasterButton = document.getElementById("supplier-master-button");
    const staffMasterButton = document.getElementById("staff-master-button");

    const adminButton = document.getElementById('admin-button');

    const totalReportButton = document.getElementById('total_report_button');

    // ===== ダッシュボード要素取得 =====
    const todaySlipCount = document.getElementById("today_slip_count");
    const unfixedSlipCount = document.getElementById("unfixed_slip_count");
    const todayTotalQty = document.getElementById("today_total_qty");
    const todayTotalAmount = document.getElementById("today_total_amount");
    const todayDeliveryCount = document.getElementById("today_delivery_count");
    const deletedSlipCount = document.getElementById("deleted_slip_count");
    const recentSlipList = document.getElementById("recent_slip_list");

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

    // ===== 社員マスタ =====
    if (totalReportButton) {
        totalReportButton.addEventListener("click", function () {
            location.href = "total_report.cfm";
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

        if (todayDeliveryCount) {
            todayDeliveryCount.textContent = formatNumber(result.today_delivery_count || 0) + "件";
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
                <div class="info-item">
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
        if (todayDeliveryCount) {
            todayDeliveryCount.textContent = "-";
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