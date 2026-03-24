let currentPage = 1;
const pageSize = 50;
let totalPage = 1;
const backButton = document.getElementById('back-btn');

const baseUrl = "/training/hara";
let sortField = "";
let sortOrder = ""; // "asc" or "desc"

document.addEventListener("DOMContentLoaded", function () {
  bindSearchEvents();
  bindEnterMoveEvents();
  bindPagingEvents();
  bindSortEvents();
  loadSupplierList(currentPage);
});

function bindSearchEvents() {
  const searchBtn = document.getElementById("search_btn");
  const clearBtn = document.getElementById("clear_btn");

  if (searchBtn) {
    searchBtn.addEventListener("click", function () {
      currentPage = 1;
      loadSupplierList(currentPage);
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener("click", function () {
      const searchSupplierCode = document.getElementById("search_supplier_code");
      const searchSupplierName = document.getElementById("search_supplier_name");
      const searchDeliveryCompany = document.getElementById("search_delivery_company");
      const searchUseFlag = document.getElementById("search_use_flag");

      if (searchSupplierCode) searchSupplierCode.value = "";
      if (searchSupplierName) searchSupplierName.value = "";
      if (searchDeliveryCompany) searchDeliveryCompany.value = "";
      if (searchUseFlag) searchUseFlag.value = "";

      sortField = "";
      sortOrder = "";
      resetSortIcons();

      currentPage = 1;
      loadSupplierList(currentPage);
    });
  }

  // Enterで検索しない
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
      // 日本語変換中のEnterは無視
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
      loadSupplierList(currentPage);
    });
  });
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

  const searchSupplierCode = getValue("search_supplier_code");
  const searchSupplierName = getValue("search_supplier_name");
  const searchDeliveryCompany = getValue("search_delivery_company");
  const searchUseFlag = getValue("search_use_flag");

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

  const requestBody = {
    page: page,
    pageSize: pageSize,
    search_supplier_code: searchSupplierCode,
    search_supplier_name: searchSupplierName,
    search_delivery_company: searchDeliveryCompany,
    search_use_flag: searchUseFlag,
    sortField: sortField,
    sortOrder: sortOrder
  };

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
      if (!data || Number(data.status) !== 1) {
        throw new Error(data && data.message ? data.message : "取引先一覧の取得に失敗しました。");
      }

      const results = data.results || [];
      const paging = data.paging || {};

      currentPage = Number(paging.page || 1);
      totalPage = Number(paging.totalPage || 1);

      renderSupplierTable(results);
      updatePagingArea(currentPage, totalPage, Number(paging.totalCount || 0));

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
      <tr>
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

function getValue(id) {
  const element = document.getElementById(id);
  return element ? element.value.trim() : "";
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

backButton.addEventListener('click', function(){
  location.href = 'menu.cfm';
})