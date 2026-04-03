let currentPage = 1;
const pageSize = 50;
let totalPage = 1;

const baseUrl = "/training/hara";
let sortField = "";
let sortOrder = "";

document.addEventListener("DOMContentLoaded", function () {
  initializeListState();
  bindSearchEvents();
  bindEnterMoveEvents();
  bindPagingEvents();
  bindSortEvents();
  bindHeaderNewButtonEvent();
  bindHeaderExportButtonEvent();
  bindHomeButtonEvent();
  updateSortIcons();
  loadSupplierList(currentPage);
});

function initializeListState() {
  if (window.initialSupplierListState) {
    sortField = window.initialSupplierListState.sortField || "";
    sortOrder = window.initialSupplierListState.sortOrder || "";

    const pageValue = Number(window.initialSupplierListState.page || 1);
    if (pageValue > 0) {
      currentPage = pageValue;
    }
  }
}

function bindSearchEvents() {
  const searchBtn = document.getElementById("search_btn");
  const clearBtn = document.getElementById("clear_btn");

  if (searchBtn) {
    searchBtn.addEventListener("click", function () {
      currentPage = 1;
      saveListState();
      loadSupplierList(currentPage);
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener("click", function () {
      setValue("search_supplier_code", "");
      setValue("search_supplier_name", "");
      setValue("search_delivery_company", "");
      setValue("search_use_flag", "");

      setValue("return_search_supplier_code", "");
      setValue("return_search_supplier_name", "");
      setValue("return_search_delivery_company", "");
      setValue("return_search_use_flag", "");

      sortField = "";
      sortOrder = "";
      resetSortIcons();

      currentPage = 1;
      saveListState();
      loadSupplierList(currentPage);
    });
  }

  const searchInputs = document.querySelectorAll(
    "#search_supplier_code, #search_supplier_name, #search_delivery_company, #search_use_flag"
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
    document.getElementById("search_supplier_code"),
    document.getElementById("search_supplier_name"),
    document.getElementById("search_delivery_company"),
    document.getElementById("search_use_flag")
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
        loadSupplierList(1);
      }
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadSupplierList(currentPage - 1);
      }
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadSupplierList(currentPage + 1);
      }
    });
  }

  if (lastBtn) {
    lastBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadSupplierList(totalPage);
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
      saveListState();
      loadSupplierList(currentPage);
    });
  });
}

function bindHeaderNewButtonEvent() {
  document.addEventListener("click", function (event) {
    const addButton = event.target.closest("#add-button");
    if (!addButton) return;

    event.preventDefault();
    moveToAddByPost();
  });
}

function bindHeaderExportButtonEvent() {
  document.addEventListener("click", function (event) {
    const exportButton = event.target.closest("#export-button");
    if (!exportButton) return;

    event.preventDefault();
    exportSupplierCsv();
  });
}

function exportSupplierCsv() {
  const params = new URLSearchParams({
    search_supplier_code: getValue("search_supplier_code"),
    search_supplier_name: getValue("search_supplier_name"),
    search_delivery_company: getValue("search_delivery_company"),
    search_use_flag: getValue("search_use_flag"),
    sortField: sortField,
    sortOrder: sortOrder
  });

  window.location.href = "m_supplier_export.cfm?" + params.toString();
}

function moveToAddByPost() {
  const form = document.getElementById("master_form");
  if (!form) return;

  setValue("detail_supplier_code", "");
  setValue("detail_display_mode", "add");

  setValue("return_search_supplier_code", getValue("search_supplier_code"));
  setValue("return_search_supplier_name", getValue("search_supplier_name"));
  setValue("return_search_delivery_company", getValue("search_delivery_company"));
  setValue("return_search_use_flag", getValue("search_use_flag"));
  setValue("return_sort_field", sortField);
  setValue("return_sort_order", sortOrder);
  setValue("return_page", currentPage);

  form.method = "post";
  form.action = "m_supplier_dt.cfm";
  form.submit();
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

function loadSupplierList(page) {
  const supplierTableBody = document.getElementById("supplier_table_body");
  const pageStatus = document.getElementById("page_status");
  const pageNumberText = document.getElementById("page_number_text");
  const loadingIndicator = document.getElementById("loading_indicator");

  currentPage = page;
  saveListState();

  const requestBody = {
    page: page,
    pageSize: pageSize,
    search_supplier_code: getValue("search_supplier_code"),
    search_supplier_name: getValue("search_supplier_name"),
    search_delivery_company: getValue("search_delivery_company"),
    search_use_flag: getValue("search_use_flag"),
    sortField: sortField,
    sortOrder: sortOrder
  };

  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  if (supplierTableBody) {
    supplierTableBody.innerHTML = `
      <tr>
        <td colspan="6" class="loading_text">読み込み中です...</td>
      </tr>
    `;
  }

  fetch(baseUrl + "/m_supplier.cfc?method=getSupplierList&returnformat=json", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(requestBody)
  })
    .then(function (response) {
      if (!response.ok) {
        throw new Error("HTTPエラー: " + response.status);
      }
      return response.json();
    })
    .then(function (data) {
      if (!data || Number(data.status) === 1) {
        throw new Error(data && data.message ? data.message : "取引先一覧の取得に失敗しました。");
      }

      const results = data.results || [];
      const paging = data.paging || {};

      currentPage = Number(paging.page || 1);
      totalPage = Number(paging.totalPage || 1);

      renderSupplierTable(results);
      updatePagingArea(currentPage, totalPage, Number(paging.totalCount || 0));
      saveListState();

      if (pageStatus) {
        pageStatus.textContent = currentPage + " / " + totalPage + " ページ";
      }

      if (pageNumberText) {
        pageNumberText.textContent = currentPage + " / " + totalPage;
      }
    })
    .catch(function (error) {
      console.error("取引先一覧取得エラー:", error);

      if (supplierTableBody) {
        supplierTableBody.innerHTML = `
          <tr>
            <td colspan="6" class="error_text">取引先一覧の取得に失敗しました。</td>
          </tr>
        `;
      }

      if (pageStatus) {
        pageStatus.textContent = "1 / 1 ページ";
      }

      if (pageNumberText) {
        pageNumberText.textContent = "1 / 1";
      }
    })
    .finally(function () {
      if (loadingIndicator) {
        loadingIndicator.classList.remove("is-visible");
      }
    });
}

function renderSupplierTable(list) {
  const supplierTableBody = document.getElementById("supplier_table_body");
  if (!supplierTableBody) return;

  if (!list || list.length === 0) {
    supplierTableBody.innerHTML = `
      <tr>
        <td colspan="6" class="loading_text">該当データがありません。</td>
      </tr>
    `;
    return;
  }

  let html = "";

  list.forEach(function (row) {
    const useFlagClass = String(row.use_flag) === "1" ? "use_flag_on" : "use_flag_off";
    const useFlagText = String(row.use_flag) === "1" ? "有効" : "無効";

    html += `
      <tr class="supplier_row" data-supplier-code="${escapeHtml(row.supplier_code || "")}">
        <td>${escapeHtml(row.supplier_code || "")}</td>
        <td>${escapeHtml(row.supplier_name || "")}</td>
        <td>${escapeHtml(row.delivery_company || "")}</td>
        <td>
          <span class="use_flag_badge ${useFlagClass}">
            ${useFlagText}
          </span>
        </td>
        <td>${escapeHtml(row.create_datetime_disp || "")}</td>
        <td>${escapeHtml(row.update_datetime_disp || "")}</td>
      </tr>
    `;
  });

  supplierTableBody.innerHTML = html;
  bindDetailRowEvents();
}

function bindDetailRowEvents() {
  const rows = document.querySelectorAll(".supplier_row");

  rows.forEach(function (row) {
    row.addEventListener("click", function () {
      moveToDetailByPost(row);
    });
  });
}

function moveToDetailByPost(row) {
  const form = document.getElementById("master_form");
  if (!form) return;

  const supplierCode = row.dataset.supplierCode || "";

  setValue("detail_supplier_code", supplierCode);
  setValue("detail_display_mode", "view");

  setValue("return_search_supplier_code", getValue("search_supplier_code"));
  setValue("return_search_supplier_name", getValue("search_supplier_name"));
  setValue("return_search_delivery_company", getValue("search_delivery_company"));
  setValue("return_search_use_flag", getValue("search_use_flag"));
  setValue("return_sort_field", sortField);
  setValue("return_sort_order", sortOrder);
  setValue("return_page", currentPage);

  form.method = "post";
  form.action = "m_supplier_dt.cfm";
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

function bindHomeButtonEvent() {
  const homeButton = document.getElementById("home-btn");
  if (!homeButton) return;

  homeButton.addEventListener("click", function () {
    location.href = "menu.cfm";
  });
}

function saveListState() {
  const sortFieldInput = document.getElementById("return_sort_field");
  const sortOrderInput = document.getElementById("return_sort_order");
  const pageInput = document.getElementById("return_page");

  if (sortFieldInput) {
    sortFieldInput.value = sortField;
  }

  if (sortOrderInput) {
    sortOrderInput.value = sortOrder;
  }

  if (pageInput) {
    pageInput.value = currentPage;
  }
}

function getValue(id) {
  const element = document.getElementById(id);
  return element ? element.value.trim() : "";
}

function setValue(id, value) {
  const element = document.getElementById(id);
  if (element) {
    element.value = value == null ? "" : String(value);
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