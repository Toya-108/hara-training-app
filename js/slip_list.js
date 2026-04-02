let currentPage = 1;
const pageSize = 50;
let totalPage = 1;

let lastTotalCount = 0;

const baseUrl = "/training/hara";
let sortField = "";
let sortOrder = "";

document.addEventListener("DOMContentLoaded", function () {
  bindDatePicker();
  bindSearchEvents();
  bindEnterMoveEvents();
  bindPagingEvents();
  bindSortEvents();
  bindHeaderExportButtonEvent();
  bindBackButtonEvent();
  bindBulkConfirmEvent();
  applyReturnState();
  loadSlipList(currentPage);
});

function bindDatePicker() {
  if (typeof flatpickr === "undefined") {
    console.error("flatpickr が読み込まれていません。");
    return;
  }

  flatpickr(".js-date-picker", {
    locale: "ja",
    dateFormat: "Y-m-d",
    altInput: true,
    altFormat: "Y / m / d",
    allowInput: false,
    disableMobile: true
  });
}

function applyReturnState() {
  const initCurrentPage = document.getElementById("init_current_page");
  const initSortField = document.getElementById("init_sort_field");
  const initSortOrder = document.getElementById("init_sort_order");

  if (initCurrentPage) {
    const page = parseInt(initCurrentPage.value || "1", 10);
    currentPage = page > 0 ? page : 1;
  }

  if (initSortField) {
    sortField = (initSortField.value || "").trim();
  }

  if (initSortOrder) {
    sortOrder = (initSortOrder.value || "").trim();
  }

  updateSortIcons();
}

function bindSearchEvents() {
  const searchBtn = document.getElementById("search_btn");
  const clearBtn = document.getElementById("clear_btn");

  if (searchBtn) {
    searchBtn.addEventListener("click", function () {
      currentPage = 1;
      loadSlipList(currentPage);
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener("click", function () {
      setValue("search_slip_no", "");
      setValue("search_order_date_from", "");
      setValue("search_order_date_to", "");
      setValue("search_delivery_date_from", "");
      setValue("search_delivery_date_to", "");
      setValue("search_supplier_code", "");
      setValue("search_supplier_keyword", "");
      setValue("search_item_keyword", "");
      setValue("search_status", "");

      setValue("return_search_slip_no", "");
      setValue("return_search_order_date_from", "");
      setValue("return_search_order_date_to", "");
      setValue("return_search_delivery_date_from", "");
      setValue("return_search_delivery_date_to", "");
      setValue("return_search_supplier_code", "");
      setValue("return_search_supplier_keyword", "");
      setValue("return_search_item_keyword", "");
      setValue("return_search_status", "");

      sortField = "";
      sortOrder = "";
      resetSortIcons();

      currentPage = 1;
      loadSlipList(currentPage);
    });
  }

  const searchInputs = document.querySelectorAll(
    "#search_slip_no, #search_order_date_from, #search_order_date_to, #search_delivery_date_from, #search_delivery_date_to, #search_supplier_code, #search_supplier_keyword, #search_item_keyword, #search_status"
  );

  searchInputs.forEach(function (input) {
    input.addEventListener("keydown", function (event) {
      if (event.key === "Enter") {
        event.preventDefault();
      }
    });
  });
}

function bindEnterMoveEvents() {
  const searchFields = [
    document.getElementById("search_slip_no"),
    document.getElementById("search_order_date_from"),
    document.getElementById("search_order_date_to"),
    document.getElementById("search_delivery_date_from"),
    document.getElementById("search_delivery_date_to"),
    document.getElementById("search_supplier_code"),
    document.getElementById("search_supplier_keyword"),
    document.getElementById("search_item_keyword"),
    document.getElementById("search_status")
  ].filter(Boolean);

  searchFields.forEach(function (field, index) {
    field.addEventListener("keydown", function (event) {
      if (event.isComposing) {
        return;
      }

      if (event.key === "Enter") {
        event.preventDefault();

        if (index < searchFields.length - 1) {
          searchFields[index + 1].focus();
        }
      }
    });
  });
}

function bindPagingEvents() {
  const firstBtn = document.getElementById("first_page_btn");
  const prevBtn = document.getElementById("prev_page_btn");
  const nextBtn = document.getElementById("next_page_btn");
  const lastBtn = document.getElementById("last_page_btn");

  if (firstBtn) {
    firstBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadSlipList(1);
      }
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadSlipList(currentPage - 1);
      }
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadSlipList(currentPage + 1);
      }
    });
  }

  if (lastBtn) {
    lastBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadSlipList(totalPage);
      }
    });
  }
}

function bindSortEvents() {
  const sortButtons = document.querySelectorAll(".sort_btn");

  sortButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      const clickedField = button.dataset.field;
      if (!clickedField) return;

      if (sortField !== clickedField) {
        sortField = clickedField;
        sortOrder = "asc";
      } else {
        if (sortOrder === "") {
          sortOrder = "asc";
        } else if (sortOrder === "asc") {
          sortOrder = "desc";
        } else {
          sortField = "";
          sortOrder = "";
        }
      }

      updateSortIcons();
      currentPage = 1;
      loadSlipList(currentPage);
    });
  });
}

function bindHeaderExportButtonEvent() {
  document.addEventListener("click", function (event) {
    const exportButton = event.target.closest("#export-button");
    if (!exportButton) return;

    event.preventDefault();
    exportSlipCsv();
  });
}

function exportSlipCsv() {
  const params = new URLSearchParams({
    search_slip_no: getValue("search_slip_no"),
    search_order_date_from: getValue("search_order_date_from"),
    search_order_date_to: getValue("search_order_date_to"),
    search_delivery_date_from: getValue("search_delivery_date_from"),
    search_delivery_date_to: getValue("search_delivery_date_to"),
    search_supplier_code: getValue("search_supplier_code"),
    search_supplier_keyword: getValue("search_supplier_keyword"),
    search_item_keyword: getValue("search_item_keyword"),
    search_status: getValue("search_status"),
    sortField: sortField,
    sortOrder: sortOrder
  });

  window.location.href = "slip_list_export.cfm?" + params.toString();
}

function updateSortIcons() {
  const sortButtons = document.querySelectorAll(".sort_btn");

  sortButtons.forEach(function (button) {
    const icon = button.querySelector("img");
    const field = button.dataset.field;

    if (!icon) return;

    if (field === sortField) {
      if (sortOrder === "asc") {
        icon.src = baseUrl + "/image/sort_asc.svg";
        icon.alt = "昇順";
        button.dataset.sort = "asc";
      } else if (sortOrder === "desc") {
        icon.src = baseUrl + "/image/sort_desc.svg";
        icon.alt = "降順";
        button.dataset.sort = "desc";
      } else {
        icon.src = baseUrl + "/image/sort_default.svg";
        icon.alt = "ソート";
        button.dataset.sort = "none";
      }
    } else {
      icon.src = baseUrl + "/image/sort_default.svg";
      icon.alt = "ソート";
      button.dataset.sort = "none";
    }
  });
}

function resetSortIcons() {
  const sortButtons = document.querySelectorAll(".sort_btn");

  sortButtons.forEach(function (button) {
    const icon = button.querySelector("img");
    if (!icon) return;

    icon.src = baseUrl + "/image/sort_default.svg";
    icon.alt = "ソート";
    button.dataset.sort = "none";
  });
}

async function loadSlipList(page) {
  const slipTableBody = document.getElementById("slip_table_body");
  const pageStatus = document.getElementById("page_status");
  const pageNumberText = document.getElementById("page_number_text");
  const loadingIndicator = document.getElementById("loading_indicator");

  const requestBody = {
    page: page,
    pageSize: pageSize,
    search_slip_no: getValue("search_slip_no"),
    search_order_date_from: getValue("search_order_date_from"),
    search_order_date_to: getValue("search_order_date_to"),
    search_delivery_date_from: getValue("search_delivery_date_from"),
    search_delivery_date_to: getValue("search_delivery_date_to"),
    search_supplier_code: getValue("search_supplier_code"),
    search_supplier_keyword: getValue("search_supplier_keyword"),
    search_item_keyword: getValue("search_item_keyword"),
    search_status: getValue("search_status"),
    sortField: sortField,
    sortOrder: sortOrder
  };

  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  if (slipTableBody) {
    slipTableBody.innerHTML = `
      <tr>
        <td colspan="6" class="loading_text">読み込み中です...</td>
      </tr>
    `;
  }

  try {
    const response = await fetch(baseUrl + "/slip_list.cfc?method=getSlipList&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(requestBody)
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      throw new Error(data && data.message ? data.message : "伝票一覧の取得に失敗しました。");
    }

    const results = data.results || [];
    const paging = data.paging || {};

    lastTotalCount = Number(paging.totalCount || 0);

    currentPage = Number(paging.page || 1);
    totalPage = Number(paging.totalPage || 1);

    renderSlipTable(results);
    updatePagingArea(currentPage, totalPage, Number(paging.totalCount || 0));

    if (pageStatus) {
      pageStatus.textContent = currentPage + " / " + totalPage + " ページ（全 " + Number(paging.totalCount || 0) + " 件）";
    }

    if (pageNumberText) {
      pageNumberText.textContent = currentPage + " / " + totalPage;
    }

  } catch (error) {
    console.error("伝票一覧取得エラー:", error);

    if (slipTableBody) {
      slipTableBody.innerHTML = `
        <tr>
          <td colspan="6" class="error_text">伝票一覧の取得に失敗しました。</td>
        </tr>
      `;
    }

    if (pageStatus) {
      pageStatus.textContent = "1 / 1 ページ";
    }

    if (pageNumberText) {
      pageNumberText.textContent = "1 / 1";
    }

  } finally {
    if (loadingIndicator) {
      loadingIndicator.classList.remove("is-visible");
    }
  }
}

function renderSlipTable(list) {
  const slipTableBody = document.getElementById("slip_table_body");
  if (!slipTableBody) return;

  if (!list || list.length === 0) {
    slipTableBody.innerHTML = `
      <tr>
        <td colspan="6" class="loading_text">該当データがありません。</td>
      </tr>
    `;
    return;
  }

  let html = "";

  list.forEach(function (row) {
    const statusInfo = getStatusInfo(row.status);

    html += `
      <tr class="slip_row" data-slip-no="${escapeHtml(row.slip_no || "")}">
        <td class="align-center">${escapeHtml(row.slip_no || "")}</td>
        <td class="align-center">${escapeHtml(row.slip_date_disp || "")}</td>
        <td class="align-center">${escapeHtml(row.delivery_date_disp || "")}</td>
        <td>${escapeHtml(row.supplier_disp || "")}</td>
        <td class="align-right">${escapeHtml(String(row.total_qty ?? ""))}</td>
        <td class="align-center">
          <span class="status-badge ${statusInfo.className}">
            ${statusInfo.label}
          </span>
        </td>
      </tr>
    `;
  });

  slipTableBody.innerHTML = html;
  bindDetailRowEvents();
}

function getStatusInfo(status) {
  const value = String(status || "");

  if (value === "2") {
    return { label: "確定", className: "status-2" };
  }

  if (value === "3") {
    return { label: "削除", className: "status-3" };
  }

  return { label: "登録", className: "status-1" };
}

function bindDetailRowEvents() {
  const rows = document.querySelectorAll(".slip_row");

  rows.forEach(function (row) {
    row.addEventListener("click", function () {
      moveToDetailByPost(row.dataset.slipNo || "");
    });
  });
}

function moveToDetailByPost(slipNo) {
  const form = document.getElementById("master_form");
  if (!form) return;

  setValue("detail_slip_no", slipNo);
  setValue("detail_display_mode", "view");

  setValue("return_search_slip_no", getValue("search_slip_no"));
  setValue("return_search_order_date_from", getValue("search_order_date_from"));
  setValue("return_search_order_date_to", getValue("search_order_date_to"));
  setValue("return_search_delivery_date_from", getValue("search_delivery_date_from"));
  setValue("return_search_delivery_date_to", getValue("search_delivery_date_to"));
  setValue("return_search_supplier_code", getValue("search_supplier_code"));
  setValue("return_search_supplier_keyword", getValue("search_supplier_keyword"));
  setValue("return_search_item_keyword", getValue("search_item_keyword"));
  setValue("return_search_status", getValue("search_status"));

  appendOrSetHidden(form, "return_current_page", currentPage);
  appendOrSetHidden(form, "return_sort_field", sortField);
  appendOrSetHidden(form, "return_sort_order", sortOrder);

  form.method = "post";
  form.action = "slip_list_dt.cfm";
  form.submit();
}

function updatePagingArea(current, total, totalCount) {
  const firstBtn = document.getElementById("first_page_btn");
  const prevBtn = document.getElementById("prev_page_btn");
  const nextBtn = document.getElementById("next_page_btn");
  const lastBtn = document.getElementById("last_page_btn");
  const pageStatus = document.getElementById("page_status");

  if (firstBtn) firstBtn.disabled = current <= 1;
  if (prevBtn) prevBtn.disabled = current <= 1;
  if (nextBtn) nextBtn.disabled = current >= total;
  if (lastBtn) lastBtn.disabled = current >= total;

  if (pageStatus) {
    pageStatus.textContent = current + " / " + total + " ページ（全 " + totalCount + " 件）";
  }
}

function bindBackButtonEvent() {
  const homeButton = document.getElementById("home-btn");

  if (homeButton) {
    homeButton.addEventListener("click", function () {
      location.href = "menu.cfm";
    });
  }
}

function appendOrSetHidden(form, name, value) {
  if (!form) return;

  let element = form.querySelector(`input[name="${name}"]`);
  if (!element) {
    element = document.createElement("input");
    element.type = "hidden";
    element.name = name;
    form.appendChild(element);
  }

  element.value = value == null ? "" : String(value);
}

function getValue(id) {
  const element = document.getElementById(id);
  return element ? element.value.trim() : "";
}

function setValue(id, value) {
  const element = document.getElementById(id);
  if (element) {
    element.value = value == null ? "" : value;
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

function bindBulkConfirmEvent() {
  const bulkConfirmBtn = document.getElementById("bulk_confirm_btn");
  if (!bulkConfirmBtn) return;

  bulkConfirmBtn.addEventListener("click", async function () {
    await bulkConfirmSlips();
  });
}

async function bulkConfirmSlips() {
  const searchStatus = getValue("search_status");

  if (lastTotalCount <= 0) {
    await Swal.fire({
      title: "対象なし",
      text: "一括確定の対象となる伝票がありません。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  if (searchStatus === "2") {
    await Swal.fire({
      title: "対象なし",
      text: "検索条件が「確定」になっているため、一括確定の対象がありません。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  if (searchStatus === "3") {
    await Swal.fire({
      title: "対象なし",
      text: "検索条件が「削除」になっているため、一括確定の対象がありません。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  const passwordResult = await Swal.fire({
    title: "一括確定",
    html: "一括確定を実行するには<br>パスワードを入力してください。",
    input: "password",
    inputLabel: "パスワード",
    inputPlaceholder: "パスワードを入力",
    inputAttributes: {
      autocapitalize: "off",
      autocorrect: "off"
    },
    showCancelButton: true,
    confirmButtonText: "確認へ進む",
    cancelButtonText: "キャンセル",
    confirmButtonColor: "#3F5B4B",
    cancelButtonColor: "#8A8175",
    reverseButtons: true,
    inputValidator: function (value) {
      if (!value) {
        return "パスワードを入力してください。";
      }
      return null;
    }
  });

  if (!passwordResult.isConfirmed) {
    return;
  }

  const password = String(passwordResult.value || "");

  const confirmResult = await Swal.fire({
    title: "検索結果を一括確定しますか？",
    html:
      "現在の検索条件に一致する<br>" +
      "<strong>登録状態の伝票のみ</strong> を一括確定します。<br><br>" +
      "対象件数: <strong>" + escapeHtml(String(lastTotalCount)) + "件</strong>",
    icon: "question",
    showCancelButton: true,
    confirmButtonText: "一括確定する",
    cancelButtonText: "戻る",
    confirmButtonColor: "#3F5B4B",
    cancelButtonColor: "#8A8175",
    reverseButtons: true
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  const loadingIndicator = document.getElementById("loading_indicator");
  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  try {
    const requestBody = {
      password: password,
      search_slip_no: getValue("search_slip_no"),
      search_order_date_from: getValue("search_order_date_from"),
      search_order_date_to: getValue("search_order_date_to"),
      search_delivery_date_from: getValue("search_delivery_date_from"),
      search_delivery_date_to: getValue("search_delivery_date_to"),
      search_supplier_code: getValue("search_supplier_code"),
      search_supplier_keyword: getValue("search_supplier_keyword"),
      search_item_keyword: getValue("search_item_keyword"),
      search_status: getValue("search_status")
    };

    const response = await fetch(baseUrl + "/slip_list.cfc?method=bulkConfirmSlips&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(requestBody)
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      throw new Error(data && data.message ? data.message : "一括確定に失敗しました。");
    }

    await Swal.fire({
      title: "一括確定完了",
      text: data.message || "一括確定が完了しました。",
      icon: "success",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });

    loadSlipList(currentPage);
  } catch (error) {
    console.error("一括確定エラー:", error);

    await Swal.fire({
      title: "一括確定失敗",
      text: error.message || "一括確定に失敗しました。",
      icon: "error",
      confirmButtonText: "OK",
      confirmButtonColor: "#B84A4A"
    });
  } finally {
    if (loadingIndicator) {
      loadingIndicator.classList.remove("is-visible");
    }
  }
}