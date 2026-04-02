let currentPage = 1;
const pageSize = 50;
let totalPage = 1;

const baseUrl = "/training/hara";
let sortField = "";
let sortOrder = "";

document.addEventListener("DOMContentLoaded", function () {
  initializeSortState();
  bindSearchEvents();
  bindEnterMoveEvents();
  bindPagingEvents();
  bindSortEvents();
  bindHeaderNewButtonEvent();
  bindHeaderExportButtonEvent();
  bindhomeButtonEvent();
  updateSortIcons();
  loadStaffList(currentPage);
});

function bindSearchEvents() {
  const searchBtn = document.getElementById("search_btn");
  const clearBtn = document.getElementById("clear_btn");

  if (searchBtn) {
    searchBtn.addEventListener("click", function () {
      currentPage = 1;
      loadStaffList(currentPage);
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener("click", function () {
      setValue("search_staff_code", "");
      setValue("search_staff_name", "");
      setValue("search_mail_address", "");
      setValue("search_authority_level", "");
      setValue("search_use_flag", "");

      setValue("return_search_staff_code", "");
      setValue("return_search_staff_name", "");
      setValue("return_search_mail_address", "");
      setValue("return_search_authority_level", "");
      setValue("return_search_use_flag", "");

      sortField = "";
      sortOrder = "";
      resetSortIcons();

      currentPage = 1;
      loadStaffList(currentPage);
    });
  }

  const searchInputs = document.querySelectorAll(
    "#search_staff_code, #search_staff_name, #search_mail_address, #search_authority_level, #search_use_flag"
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
    document.getElementById("search_staff_code"),
    document.getElementById("search_staff_name"),
    document.getElementById("search_mail_address"),
    document.getElementById("search_authority_level"),
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
        loadStaffList(1);
      }
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener("click", function () {
      if (currentPage > 1) {
        loadStaffList(currentPage - 1);
      }
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadStaffList(currentPage + 1);
      }
    });
  }

  if (lastBtn) {
    lastBtn.addEventListener("click", function () {
      if (currentPage < totalPage) {
        loadStaffList(totalPage);
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
      loadStaffList(currentPage);
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
    exportStaffCsv();
  });
}

function exportStaffCsv() {
  const params = new URLSearchParams({
    search_staff_code: getValue("search_staff_code"),
    search_staff_name: getValue("search_staff_name"),
    search_mail_address: getValue("search_mail_address"),
    search_authority_level: getValue("search_authority_level"),
    search_use_flag: getValue("search_use_flag"),
    sortField: sortField,
    sortOrder: sortOrder
  });

  window.location.href = "m_staff_export.cfm?" + params.toString();
}

function moveToAddByPost() {
  const form = document.getElementById("master_form");
  if (!form) return;

  setValue("detail_staff_code", "");
  setValue("detail_return_staff_code", "");
  setValue("detail_display_mode", "add");

  setValue("return_search_staff_code", getValue("search_staff_code"));
  setValue("return_search_staff_name", getValue("search_staff_name"));
  setValue("return_search_mail_address", getValue("search_mail_address"));
  setValue("return_search_authority_level", getValue("search_authority_level"));
  setValue("return_search_use_flag", getValue("search_use_flag"));

  setValue("return_sort_field", sortField);
  setValue("return_sort_order", sortOrder);

  form.method = "post";
  form.action = "m_staff_dt.cfm";
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

function loadStaffList(page) {
  const staffTableBody = document.getElementById("staff_table_body");
  const pageStatus = document.getElementById("page_status");
  const pageNumberText = document.getElementById("page_number_text");
  const loadingIndicator = document.getElementById("loading_indicator");

  setValue("return_sort_field", sortField);
  setValue("return_sort_order", sortOrder);

  const requestBody = {
    page: page,
    pageSize: pageSize,
    search_staff_code: getValue("search_staff_code"),
    search_staff_name: getValue("search_staff_name"),
    search_mail_address: getValue("search_mail_address"),
    search_authority_level: getValue("search_authority_level"),
    search_use_flag: getValue("search_use_flag"),
    sortField: sortField,
    sortOrder: sortOrder
  };

  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  if (staffTableBody) {
    staffTableBody.innerHTML = `
      <tr>
        <td colspan="9" class="loading_text">読み込み中です...</td>
      </tr>
    `;
  }

  fetch(baseUrl + "/m_staff.cfc?method=getStaffList&returnformat=json", {
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
      if (!data || Number(data.status) !== 0) {
        throw new Error(data && data.message ? data.message : "社員一覧の取得に失敗しました。");
      }

      const results = data.results || [];
      const paging = data.paging || {};

      currentPage = Number(paging.page || 1);
      totalPage = Number(paging.totalPage || 1);

      renderStaffTable(results);
      updatePagingArea(currentPage, totalPage, Number(paging.totalCount || 0));

      if (pageStatus) {
        pageStatus.textContent = currentPage + " / " + totalPage + " ページ";
      }

      if (pageNumberText) {
        pageNumberText.textContent = currentPage + " / " + totalPage;
      }
    })
    .catch(function (error) {
      console.error("社員一覧取得エラー:", error);

      if (staffTableBody) {
        staffTableBody.innerHTML = `
          <tr>
            <td colspan="9" class="error_text">社員一覧の取得に失敗しました。</td>
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

function renderStaffTable(list) {
  const staffTableBody = document.getElementById("staff_table_body");
  if (!staffTableBody) return;

  if (!list || list.length === 0) {
    staffTableBody.innerHTML = `
      <tr>
        <td colspan="9" class="loading_text">該当データがありません。</td>
      </tr>
    `;
    return;
  }

  let html = "";

  list.forEach(function (row) {
    const authorityInfo = getAuthorityInfo(row.authority_level);
    const useFlagClass = String(row.use_flag) === "1" ? "use_flag_on" : "use_flag_off";
    const useFlagText = String(row.use_flag) === "1" ? "使用中" : "停止";

    html += `
      <tr class="staff_row" data-staff-code="${escapeHtml(row.staff_code || "")}">
        <td>${escapeHtml(row.staff_code || "")}</td>
        <td>${escapeHtml(row.staff_name || "")}</td>
        <td>
          <span class="authority_badge ${authorityInfo.className}">
            ${authorityInfo.label}
          </span>
        </td>
        <td>${escapeHtml(row.mail_address || "")}</td>
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

  staffTableBody.innerHTML = html;
  bindDetailRowEvents();
}

function getAuthorityInfo(authorityLevel) {
  const level = String(authorityLevel || "");

  if (level === "9") {
    return { label: "管理者", className: "authority_admin" };
  }

  if (level === "2") {
    return { label: "責任者", className: "authority_manager" };
  }

  return { label: "一般", className: "authority_general" };
}

function bindDetailRowEvents() {
  const rows = document.querySelectorAll(".staff_row");

  rows.forEach(function (row) {
    row.addEventListener("click", function () {
      moveToDetailByPost(row);
    });
  });
}

function moveToDetailByPost(row) {
  const form = document.getElementById("master_form");
  if (!form) return;

  const staffCode = row.dataset.staffCode || "";

  setValue("detail_staff_code", staffCode);
  setValue("detail_return_staff_code", staffCode);
  setValue("detail_display_mode", "view");

  setValue("return_search_staff_code", getValue("search_staff_code"));
  setValue("return_search_staff_name", getValue("search_staff_name"));
  setValue("return_search_mail_address", getValue("search_mail_address"));
  setValue("return_search_authority_level", getValue("search_authority_level"));
  setValue("return_search_use_flag", getValue("search_use_flag"));

  setValue("return_sort_field", sortField);
  setValue("return_sort_order", sortOrder);

  form.method = "post";
  form.action = "m_staff_dt.cfm";
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

function bindhomeButtonEvent() {
  const homeButton = document.getElementById("home-btn");

  if (homeButton) {
    homeButton.addEventListener("click", function () {
      location.href = "menu.cfm";
    });
  }
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

function initializeSortState() {
  sortField = getValue("return_sort_field");
  sortOrder = getValue("return_sort_order");

  if (sortOrder !== "asc" && sortOrder !== "desc") {
    sortOrder = "";
  }
}