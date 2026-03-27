let currentPage = 1;
const pageSize = 50;
let totalPage = 1;

let isLoading = false;

const baseUrl = "/training/hara";
let sortField = "";
let sortOrder = "";

document.addEventListener("DOMContentLoaded", function () {
  bindPagingEvents();
  bindSortEvents();
  bindSearchEvents();
  bindEnterMoveEvents();
  bindHeaderButtons();
  loadItemList(currentPage);
});

function bindHeaderButtons() {
  const homeBtn = document.getElementById("home-btn");
  const addBtn = document.getElementById("add-button");
  const exportBtn = document.getElementById("export-button");

  if (homeBtn) {
    homeBtn.addEventListener("click", function () {
      location.href = "menu.cfm";
    });
  }

  if (addBtn) {
    addBtn.addEventListener("click", function () {
      moveToAddByPost();
    });
  }

  if (exportBtn) {
    exportBtn.addEventListener("click", function () {
      exportItemCsv();
    });
  }
}

function exportItemCsv() {
  const params = new URLSearchParams({
    search_product_code: getValue("search_product_code"),
    search_jan_code: getValue("search_jan_code"),
    search_product_name: getValue("search_product_name"),
    sortField: sortField,
    sortOrder: sortOrder
  });

  window.location.href = "m_item_export.cfm?" + params.toString();
}

function bindPagingEvents() {
  const firstBtn = document.getElementById("first_page_btn");
  const prevBtn = document.getElementById("prev_page_btn");
  const nextBtn = document.getElementById("next_page_btn");
  const lastBtn = document.getElementById("last_page_btn");

  if (firstBtn) {
    firstBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadItemList(1);
      }
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadItemList(currentPage - 1);
      }
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadItemList(currentPage + 1);
      }
    });
  }

  if (lastBtn) {
    lastBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadItemList(totalPage);
      }
    });
  }
}

function bindSortEvents() {
  const sortButtons = document.querySelectorAll(".sort_btn");

  sortButtons.forEach(function (btn) {
    btn.addEventListener("click", function () {
      const field = this.dataset.field;
      const current = this.dataset.sort || "none";
      let next = "none";

      if (current === "none") {
        next = "asc";
      } else if (current === "asc") {
        next = "desc";
      } else {
        next = "none";
      }

      resetSortButtons();

      this.dataset.sort = next;

      if (next === "asc") {
        this.innerHTML = `<img src="${baseUrl}/image/sort_asc.svg" alt="昇順">`;
        this.classList.add("active");
        sortField = field;
        sortOrder = "asc";
      } else if (next === "desc") {
        this.innerHTML = `<img src="${baseUrl}/image/sort_desc.svg" alt="降順">`;
        this.classList.add("active");
        sortField = field;
        sortOrder = "desc";
      } else {
        this.innerHTML = `<img src="${baseUrl}/image/sort_default.svg" alt="未ソート">`;
        this.classList.remove("active");
        sortField = "";
        sortOrder = "";
      }

      currentPage = 1;
      loadItemList(currentPage);
    });
  });
}

function resetSortButtons() {
  const sortButtons = document.querySelectorAll(".sort_btn");

  sortButtons.forEach(function (btn) {
    btn.dataset.sort = "none";
    btn.classList.remove("active");
    btn.innerHTML = `<img src="${baseUrl}/image/sort_default.svg" alt="未ソート">`;
  });
}

function bindSearchEvents() {
  const searchBtn = document.getElementById("search_btn");
  const clearBtn = document.getElementById("clear_btn");

  if (searchBtn) {
    searchBtn.addEventListener("click", function () {
      executeSearch();
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener("click", function () {
      clearSearchConditions();
      executeSearch();
    });
  }
}

function bindEnterMoveEvents() {
  const inputs = document.querySelectorAll(
    "#search_product_code, #search_jan_code, #search_product_name"
  );

  const searchButton = document.getElementById("search_btn");

  inputs.forEach(function (input, index) {
    input.addEventListener("keydown", function (e) {
      if (e.isComposing || e.keyCode === 229) {
        return;
      }

      if (e.key === "Enter") {
        e.preventDefault();

        if (e.shiftKey && index > 0) {
          inputs[index - 1].focus();
        } else if (index < inputs.length - 1) {
          inputs[index + 1].focus();
        } else if (searchButton) {
          searchButton.focus();
        }
      }
    });
  });
}

function executeSearch() {
  currentPage = 1;
  loadItemList(currentPage);
}

function clearSearchConditions() {
  const productCode = document.getElementById("search_product_code");
  const janCode = document.getElementById("search_jan_code");
  const productName = document.getElementById("search_product_name");

  if (productCode) productCode.value = "";
  if (janCode) janCode.value = "";
  if (productName) productName.value = "";
}

async function loadItemList(page) {
  if (isLoading) {
    return;
  }

  setLoadingState(true);
  renderLoadingRow();

  const requestInfo = createRequestInfo(page);

  try {
    const response = await fetch(requestInfo.cfcUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(requestInfo.requestBody)
    });

    if (!response.ok) {
      throw new Error("通信に失敗しました。 status: " + response.status);
    }

    const responseData = await response.json();

    renderItemTable(responseData);
    updatePagingInfo(responseData);
  } catch (error) {
    console.error("商品一覧取得エラー:", error);
    renderErrorRow("商品一覧の取得に失敗しました。");
  } finally {
    setLoadingState(false);
  }
}

function createRequestInfo(page) {
  const productCode = document.getElementById("search_product_code");
  const janCode = document.getElementById("search_jan_code");
  const productName = document.getElementById("search_product_name");

  return {
    cfcUrl: "m_item.cfc?method=getItemList&returnformat=json",
    requestBody: {
      page: page,
      pageSize: pageSize,
      sortField: sortField,
      sortOrder: sortOrder,
      search_product_code: productCode ? productCode.value.trim() : "",
      search_jan_code: janCode ? janCode.value.trim() : "",
      search_product_name: productName ? productName.value.trim() : ""
    }
  };
}

function renderItemTable(responseData) {
  const tableBody = document.getElementById("item_table_body");

  if (!tableBody) {
    return;
  }

  tableBody.innerHTML = "";

  if (!responseData || responseData.status !== 1) {
    const message = responseData && responseData.message
      ? responseData.message
      : "データ取得に失敗しました。";

    renderErrorRow(message);
    return;
  }

  const itemList = responseData.results || [];

  if (itemList.length === 0) {
    tableBody.innerHTML = `
      <tr>
        <td colspan="5" class="loading_text">データがありません。</td>
      </tr>
    `;
    return;
  }

  let html = "";

  itemList.forEach(function (item) {
    html += `
      <tr class="item_row" data-item-code="${escapeHtml(item.item_code)}" style="cursor:pointer;">
        <td>${escapeHtml(item.item_code)}</td>
        <td>${escapeHtml(item.jan_code || "")}</td>
        <td>${escapeHtml(item.item_name || "")}</td>
        <td>${escapeHtml(item.create_datetime || "")}</td>
        <td>${escapeHtml(item.update_datetime || "")}</td>
      </tr>
    `;
  });

  tableBody.innerHTML = html;

  const rows = tableBody.querySelectorAll(".item_row");
  rows.forEach(function (row) {
    row.addEventListener("click", function () {
      moveToDetailByPost(this.dataset.itemCode);
    });
  });
}

function updatePagingInfo(responseData) {
  if (!responseData || !responseData.paging) {
    return;
  }

  currentPage = Number(responseData.paging.page || 1);
  totalPage = Number(responseData.paging.totalPage || 1);

  const pageStatus = document.getElementById("page_status");
  const pageNumberText = document.getElementById("page_number_text");
  const firstBtn = document.getElementById("first_page_btn");
  const prevBtn = document.getElementById("prev_page_btn");
  const nextBtn = document.getElementById("next_page_btn");
  const lastBtn = document.getElementById("last_page_btn");

  if (pageStatus) {
    pageStatus.textContent = currentPage + " / " + totalPage + " ページ";
  }

  if (pageNumberText) {
    pageNumberText.textContent = currentPage + " / " + totalPage;
  }

  if (firstBtn) {
    firstBtn.disabled = (currentPage <= 1);
  }

  if (prevBtn) {
    prevBtn.disabled = !responseData.paging.hasPrev;
  }

  if (nextBtn) {
    nextBtn.disabled = !responseData.paging.hasNext;
  }

  if (lastBtn) {
    lastBtn.disabled = (currentPage >= totalPage);
  }
}

function renderLoadingRow() {
  const tableBody = document.getElementById("item_table_body");
  if (!tableBody) return;

  tableBody.innerHTML = `
    <tr>
      <td colspan="5" class="loading_text">読み込み中です...</td>
    </tr>
  `;
}

function renderErrorRow(message) {
  const tableBody = document.getElementById("item_table_body");
  if (!tableBody) return;

  tableBody.innerHTML = `
    <tr>
      <td colspan="5" class="error_text">${escapeHtml(message)}</td>
    </tr>
  `;
}

function moveToDetailByPost(itemCode) {
  const form = document.createElement("form");
  form.method = "post";
  form.action = "m_item_dt.cfm";
  form.style.display = "none";

  const params = {
    item_code: itemCode,
    return_item_code: itemCode,
    display_mode: "view",
    return_search_product_code: getValue("search_product_code"),
    return_search_jan_code: getValue("search_jan_code"),
    return_search_product_name: getValue("search_product_name")
  };

  Object.keys(params).forEach(function (key) {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = key;
    input.value = params[key] == null ? "" : String(params[key]);
    form.appendChild(input);
  });

  document.body.appendChild(form);
  form.submit();
}

function moveToAddByPost() {
  const form = document.createElement("form");
  form.method = "post";
  form.action = "m_item_dt.cfm";
  form.style.display = "none";

  const params = {
    item_code: "",
    return_item_code: "",
    display_mode: "add",
    return_search_product_code: getValue("search_product_code"),
    return_search_jan_code: getValue("search_jan_code"),
    return_search_product_name: getValue("search_product_name")
  };

  Object.keys(params).forEach(function (key) {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = key;
    input.value = params[key] == null ? "" : String(params[key]);
    form.appendChild(input);
  });

  document.body.appendChild(form);
  form.submit();
}

function getValue(id, trimFlag = true) {
  const element = document.getElementById(id);
  if (!element) return "";

  const value = element.value == null ? "" : String(element.value);
  return trimFlag ? value.trim() : value;
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

function setLoadingState(flag) {
  isLoading = flag;

  const loadingIndicator = document.getElementById("loading_indicator");

  const buttonIds = [
    "search_btn",
    "clear_btn",
    "first_page_btn",
    "prev_page_btn",
    "next_page_btn",
    "last_page_btn",
    "export-button"
  ];

  buttonIds.forEach(function (id) {
    const button = document.getElementById(id);
    if (button) {
      button.disabled = flag;
    }
  });

  const sortButtons = document.querySelectorAll(".sort_btn");
  sortButtons.forEach(function (btn) {
    if (flag) {
      btn.style.pointerEvents = "none";
      btn.style.opacity = "0.5";
    } else {
      btn.style.pointerEvents = "";
      btn.style.opacity = "";
    }
  });

  const searchInputs = document.querySelectorAll(
    "#search_product_code, #search_jan_code, #search_product_name"
  );

  searchInputs.forEach(function (input) {
    input.disabled = flag;
  });

  if (loadingIndicator) {
    if (flag) {
      loadingIndicator.classList.add("is-visible");
    } else {
      loadingIndicator.classList.remove("is-visible");
    }
  }
}