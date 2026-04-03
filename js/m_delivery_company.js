document.addEventListener("DOMContentLoaded", function () {
    var masterForm = document.getElementById("master_form");

    var searchDeliveryCompanyCode = document.getElementById("search_delivery_company_code");
    var searchDeliveryCompanyName = document.getElementById("search_delivery_company_name");
    var searchUseFlag = document.getElementById("search_use_flag");

    var searchBtn = document.getElementById("search_btn");
    var clearBtn = document.getElementById("clear_btn");
    var homeBtn = document.getElementById('home-btn');

    var exportButton = document.getElementById("export-button");

    var pageStatus = document.getElementById("page_status");
    var pageNumberText = document.getElementById("page_number_text");
    var firstPageBtn = document.getElementById("first_page_btn");
    var prevPageBtn = document.getElementById("prev_page_btn");
    var nextPageBtn = document.getElementById("next_page_btn");
    var lastPageBtn = document.getElementById("last_page_btn");

    var loadingIndicator = document.getElementById("loading_indicator");
    var deliveryCompanyTableBody = document.getElementById("delivery_company_table_body");

    var returnPage = document.getElementById("return_page");
    var returnSortField = document.getElementById("return_sort_field");
    var returnSortOrder = document.getElementById("return_sort_order");

    var returnSearchDeliveryCompanyCode = document.getElementById("return_search_delivery_company_code");
    var returnSearchDeliveryCompanyName = document.getElementById("return_search_delivery_company_name");
    var returnSearchUseFlag = document.getElementById("return_search_use_flag");

    var detailDeliveryCompanyCode = document.getElementById("detail_delivery_company_code");
    var detailReturnDeliveryCompanyCode = document.getElementById("detail_return_delivery_company_code");
    var detailDisplayMode = document.getElementById("detail_display_mode");
    var detailSourcePage = document.getElementById("detail_source_page");
    var detailSourceDeliveryCompanyCode = document.getElementById("detail_source_delivery_company_code");

    var currentPage = parseInt(returnPage.value || "1", 10);
    var pageSize = 50;
    var totalPage = 1;
    var sortField = returnSortField.value || "";
    var sortOrder = returnSortOrder.value || "";

    var sortButtons = document.querySelectorAll(".sort_btn");

    if (homeBtn) {
      homeBtn.addEventListener('click', function () {
        location.href = 'menu.cfm';
      });
    }


    function showLoading(isShow) {
        if (isShow) {
            loadingIndicator.classList.add("is-visible");
        } else {
            loadingIndicator.classList.remove("is-visible");
        }
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

    function getUseFlagBadge(useFlag) {
        if (String(useFlag) === "1") {
            return '<span class="use_flag_badge use_flag_on">使用中</span>';
        }
        return '<span class="use_flag_badge use_flag_off">停止</span>';
    }

    function updateSortIcons() {
        sortButtons.forEach(function (button) {
            var field = button.dataset.field;
            var img = button.querySelector("img");

            if (field === sortField && sortOrder === "asc") {
                img.src = "./image/sort_asc.svg";
            } else if (field === sortField && sortOrder === "desc") {
                img.src = "./image/sort_desc.svg";
            } else {
                img.src = "./image/sort_default.svg";
            }
        });
    }

    function updatePagingButtons() {
        pageStatus.textContent = currentPage + " / " + totalPage + " ページ";
        pageNumberText.textContent = currentPage + " / " + totalPage;

        firstPageBtn.disabled = currentPage <= 1;
        prevPageBtn.disabled = currentPage <= 1;
        nextPageBtn.disabled = currentPage >= totalPage;
        lastPageBtn.disabled = currentPage >= totalPage;
    }

    function restoreSearchConditionsFromHidden() {
        searchDeliveryCompanyCode.value = returnSearchDeliveryCompanyCode.value || "";
        searchDeliveryCompanyName.value = returnSearchDeliveryCompanyName.value || "";
        searchUseFlag.value = returnSearchUseFlag.value || "";
    }

    function syncReturnHiddenValues() {
        returnPage.value = currentPage;
        returnSortField.value = sortField;
        returnSortOrder.value = sortOrder;

        returnSearchDeliveryCompanyCode.value = searchDeliveryCompanyCode.value;
        returnSearchDeliveryCompanyName.value = searchDeliveryCompanyName.value;
        returnSearchUseFlag.value = searchUseFlag.value;
    }

    function buildSearchParams() {
        return {
            page: currentPage,
            pageSize: pageSize,
            sortField: sortField,
            sortOrder: sortOrder,
            search_delivery_company_code: searchDeliveryCompanyCode.value,
            search_delivery_company_name: searchDeliveryCompanyName.value,
            search_use_flag: searchUseFlag.value
        };
    }

    async function loadDeliveryCompanyList() {
        syncReturnHiddenValues();
        showLoading(true);

        deliveryCompanyTableBody.innerHTML = "";

        try {
            var response = await fetch("./m_delivery_company.cfc?method=getDeliveryCompanyList&returnformat=json", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(buildSearchParams())
            });

            var data = await response.json();

            if (data.status !== undefined) {
                data.status = data.status;
                data.message = data.message;
                data.results = data.results;
                data.paging = data.paging;
            }

            if (data.status !== 0) {
                deliveryCompanyTableBody.innerHTML = '<tr><td colspan="6" class="error_text">' + escapeHtml(data.message || "一覧取得に失敗しました。") + "</td></tr>";
                totalPage = 1;
                updatePagingButtons();
                return;
            }

            var results = data.results || [];
            var paging = data.paging || {};

            currentPage = parseInt(paging.currentPage || currentPage || 1, 10);
            totalPage = parseInt(paging.totalPage || 1, 10);

            updatePagingButtons();

            if (results.length === 0) {
                deliveryCompanyTableBody.innerHTML = '<tr><td colspan="6" class="error_text">データがありません。</td></tr>';
                return;
            }

            var html = "";

            results.forEach(function (row) {
                html += ''
                    + '<tr class="delivery_company_row" data-delivery-company-code="' + escapeHtml(row.delivery_company_code) + '">'
                    + '    <td>' + escapeHtml(row.delivery_company_code) + "</td>"
                    + '    <td>' + escapeHtml(row.delivery_company_name) + "</td>"
                    + '    <td>' + escapeHtml(row.note || "") + "</td>"
                    + '    <td>' + getUseFlagBadge(row.use_flag) + "</td>"
                    + '    <td>' + escapeHtml(row.create_datetime_disp || "") + "</td>"
                    + '    <td>' + escapeHtml(row.update_datetime_disp || "") + "</td>"
                    + "</tr>";
            });

            deliveryCompanyTableBody.innerHTML = html;

            bindRowClick();
        } catch (error) {
            deliveryCompanyTableBody.innerHTML = '<tr><td colspan="6" class="error_text">一覧取得中にエラーが発生しました。</td></tr>';
            totalPage = 1;
            updatePagingButtons();
        } finally {
            syncReturnHiddenValues();
            updateSortIcons();
            showLoading(false);
        }
    }

    function moveToDetail(deliveryCompanyCode) {
        syncReturnHiddenValues();

        detailDeliveryCompanyCode.value = deliveryCompanyCode;
        detailReturnDeliveryCompanyCode.value = deliveryCompanyCode;
        detailDisplayMode.value = "view";
        detailSourcePage.value = "list";
        detailSourceDeliveryCompanyCode.value = "";

        masterForm.action = "./m_delivery_company_dt.cfm";
        masterForm.submit();
    }

    function moveToAdd() {
        syncReturnHiddenValues();

        detailDeliveryCompanyCode.value = "";
        detailReturnDeliveryCompanyCode.value = "";
        detailDisplayMode.value = "add";
        detailSourcePage.value = "list";
        detailSourceDeliveryCompanyCode.value = "";

        masterForm.action = "./m_delivery_company_dt.cfm";
        masterForm.submit();
    }

    if(exportButton){
      exportButton.addEventListener("click", function(){
        exportDeliveryCompanyList();
      });
    }

    function exportDeliveryCompanyList() {
        syncReturnHiddenValues();

        var exportForm = document.createElement("form");
        exportForm.method = "post";
        exportForm.action = "./m_delivery_company_export.cfm";

        function appendHidden(name, value) {
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = name;
            input.value = value;
            exportForm.appendChild(input);
        }

        appendHidden("search_delivery_company_code", searchDeliveryCompanyCode.value);
        appendHidden("search_delivery_company_name", searchDeliveryCompanyName.value);
        appendHidden("search_use_flag", searchUseFlag.value);
        appendHidden("sort_field", sortField);
        appendHidden("sort_order", sortOrder);

        document.body.appendChild(exportForm);
        exportForm.submit();
        document.body.removeChild(exportForm);
    }    

    function bindRowClick() {
        var rows = document.querySelectorAll(".delivery_company_row");

        rows.forEach(function (row) {
            row.addEventListener("click", function () {
                moveToDetail(row.dataset.deliveryCompanyCode);
            });
        });
    }

    searchBtn.addEventListener("click", async function () {
        currentPage = 1;
        await loadDeliveryCompanyList();
    });

    clearBtn.addEventListener("click", async function () {
        searchDeliveryCompanyCode.value = "";
        searchDeliveryCompanyName.value = "";
        searchUseFlag.value = "";
        currentPage = 1;
        sortField = "";
        sortOrder = "";
        await loadDeliveryCompanyList();
    });

    firstPageBtn.addEventListener("click", async function () {
        if (currentPage <= 1) {
            return;
        }
        currentPage = 1;
        await loadDeliveryCompanyList();
    });

    prevPageBtn.addEventListener("click", async function () {
        if (currentPage <= 1) {
            return;
        }
        currentPage -= 1;
        await loadDeliveryCompanyList();
    });

    nextPageBtn.addEventListener("click", async function () {
        if (currentPage >= totalPage) {
            return;
        }
        currentPage += 1;
        await loadDeliveryCompanyList();
    });

    lastPageBtn.addEventListener("click", async function () {
        if (currentPage >= totalPage) {
            return;
        }
        currentPage = totalPage;
        await loadDeliveryCompanyList();
    });

    sortButtons.forEach(function (button) {
        button.addEventListener("click", async function () {
            var clickedField = button.dataset.field;

            if (sortField !== clickedField) {
                sortField = clickedField;
                sortOrder = "asc";
            } else if (sortOrder === "asc") {
                sortOrder = "desc";
            } else {
                sortField = "";
                sortOrder = "";
            }

            currentPage = 1;
            await loadDeliveryCompanyList();
        });
    });

    // Enterキーで次の項目へ移動
    var searchInputs = [
        searchDeliveryCompanyCode,
        searchDeliveryCompanyName,
        searchUseFlag
    ];

    searchInputs.forEach(function (element, index) {
        element.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.isComposing) {
                event.preventDefault();

                // 次の要素へフォーカス
                var nextIndex = index + 1;

                if (nextIndex < searchInputs.length) {
                    searchInputs[nextIndex].focus();
                } else {
                    // 最後の項目なら検索ボタンへフォーカス（好みで）
                    searchBtn.focus();
                }
            }
        });
    });

    var newButton = document.getElementById("add-button");

    if (newButton) {
        newButton.addEventListener("click", function () {
            moveToAdd();
        });
    }
    
    restoreSearchConditionsFromHidden();
    updateSortIcons();
    loadDeliveryCompanyList();
});