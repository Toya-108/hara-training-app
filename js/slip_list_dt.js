let slipDisplayMode = "view";
const dtBaseUrl = "/training/hara";
let detailRows = [];

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindDatePicker();
  bindEvents();
  loadSlipDetail();
});

function initializeScreenValues() {
  slipDisplayMode = String(getValue("detail_display_mode") || "view").toLowerCase();

  if (slipDisplayMode !== "view" && slipDisplayMode !== "edit") {
    slipDisplayMode = "view";
    setValue("detail_display_mode", "view");
  }
}

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

function bindEvents() {
  const editBtn = document.getElementById("edit-button");
  const saveBtn = document.getElementById("save_btn");
  const cancelBtn = document.getElementById("cancel-button");
  const backBtn = document.getElementById("back-btn");
  const supplierCode = document.getElementById("supplier_code");
  const detailTableBody = document.getElementById("detail_table_body");

  if (editBtn) {
    editBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveToEdit();
    });
  }

  if (saveBtn) {
    saveBtn.addEventListener("click", async function (event) {
      event.preventDefault();
      await saveSlip();
    });
  }

  if (cancelBtn) {
    cancelBtn.addEventListener("click", async function (event) {
      event.preventDefault();
      moveToView();
    });
  }

  if (backBtn) {
    backBtn.addEventListener("click", async function (event) {
      event.preventDefault();

      if (slipDisplayMode === "edit") {
        const result = await Swal.fire({
          title: "一覧へ戻りますか？",
          text: "未保存の変更内容は破棄されます。",
          icon: "question",
          showCancelButton: true,
          confirmButtonText: "戻る",
          cancelButtonText: "画面に残る",
          confirmButtonColor: "#8A8175",
          cancelButtonColor: "#3F5B4B",
          reverseButtons: true
        });

        if (!result.isConfirmed) {
          return;
        }
      }

      if (isFromMenu()) {
        moveToMenu();
      } else {
        moveToListByPost();
      }
    });
  }

  if (supplierCode) {
    supplierCode.addEventListener("change", function () {
      updateSupplierNameDisplay();
    });
  }

  if (detailTableBody) {
    detailTableBody.addEventListener(
      "blur",
      async function (event) {
        if (!event.target.classList.contains("item-code-input")) {
          return;
        }

        await lookupItemByCode(event.target);
      },
      true
    );
  }
}

function isFromMenu() {
  return getValue("return_from_menu") === "1";
}

async function lookupItemByCode(input) {
  const row = input.closest("tr");
  if (!row) return;

  const index = Number(row.dataset.index);
  if (isNaN(index) || !detailRows[index]) return;

  const itemCode = String(input.value || "").trim();
  const janInput = row.querySelector(".jan-code-input");
  const itemNameInput = row.querySelector(".item-name-input");
  const unitPriceInput = row.querySelector(".unit-price-input");

  if (!itemCode) {
    detailRows[index].item_code = "";
    detailRows[index].jan_code = "";
    detailRows[index].item_name = "";
    detailRows[index].unit_price = 0;

    if (janInput) janInput.value = "";
    if (itemNameInput) itemNameInput.value = "";
    if (unitPriceInput) unitPriceInput.value = "";

    updateDetailAmount(index);
    updateTotals();
    return;
  }

  try {
    const response = await fetch(dtBaseUrl + "/slip_list_dt.cfc?method=getItemByCode&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        item_code: itemCode
      })
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      detailRows[index].item_code = itemCode;
      detailRows[index].jan_code = "";
      detailRows[index].item_name = "";
      detailRows[index].unit_price = 0;

      if (janInput) janInput.value = "";
      if (itemNameInput) itemNameInput.value = "";
      if (unitPriceInput) unitPriceInput.value = "";

      await Swal.fire({
        title: "商品が見つかりません",
        text: data && data.message ? data.message : "商品が見つかりません。",
        icon: "warning",
        confirmButtonText: "OK",
        confirmButtonColor: "#3F5B4B"
      });

      updateDetailAmount(index);
      updateTotals();
      return;
    }

    const item = data.results || {};

    detailRows[index].item_code = item.item_code || itemCode;
    detailRows[index].jan_code = item.jan_code || "";
    detailRows[index].item_name = item.item_name || "";
    detailRows[index].unit_price = toNumber(item.gentanka || 0);

    input.value = detailRows[index].item_code;

    if (janInput) janInput.value = detailRows[index].jan_code;
    if (itemNameInput) itemNameInput.value = detailRows[index].item_name;
    if (unitPriceInput) unitPriceInput.value = detailRows[index].unit_price;

    updateDetailAmount(index);
    updateTotals();
  } catch (error) {
    console.error("商品取得エラー:", error);

    await Swal.fire({
      title: "商品取得エラー",
      text: "商品取得に失敗しました。",
      icon: "error",
      confirmButtonText: "OK",
      confirmButtonColor: "#B84A4A"
    });
  }
}

function moveToEdit() {
  const slipNo = getValue("detail_slip_no");

  if (!slipNo) {
    Swal.fire({
      title: "伝票番号エラー",
      text: "伝票番号が取得できません。",
      icon: "error",
      confirmButtonText: "OK",
      confirmButtonColor: "#B84A4A"
    });
    return;
  }

  submitPost("slip_list_dt.cfm", {
    detail_slip_no: slipNo,
    detail_display_mode: "edit",
    return_from_menu: getValue("return_from_menu"),
    return_search_slip_no: getValue("return_search_slip_no"),
    return_search_order_date_from: getValue("return_search_order_date_from"),
    return_search_order_date_to: getValue("return_search_order_date_to"),
    return_search_delivery_date_from: getValue("return_search_delivery_date_from"),
    return_search_delivery_date_to: getValue("return_search_delivery_date_to"),
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_keyword: getValue("return_search_supplier_keyword"),
    return_search_item_keyword: getValue("return_search_item_keyword"),
    return_search_status: getValue("return_search_status"),
    return_current_page: getValue("return_current_page"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")
  });
}

function moveToView() {
  const slipNo = getValue("detail_slip_no");

  if (!slipNo) {
    if (isFromMenu()) {
      moveToMenu();
    } else {
      moveToListByPost();
    }
    return;
  }

  submitPost("slip_list_dt.cfm", {
    detail_slip_no: slipNo,
    detail_display_mode: "view",
    return_from_menu: getValue("return_from_menu"),
    return_search_slip_no: getValue("return_search_slip_no"),
    return_search_order_date_from: getValue("return_search_order_date_from"),
    return_search_order_date_to: getValue("return_search_order_date_to"),
    return_search_delivery_date_from: getValue("return_search_delivery_date_from"),
    return_search_delivery_date_to: getValue("return_search_delivery_date_to"),
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_keyword: getValue("return_search_supplier_keyword"),
    return_search_item_keyword: getValue("return_search_item_keyword"),
    return_search_status: getValue("return_search_status"),
    return_current_page: getValue("return_current_page"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")
  });
}

function moveToMenu() {
  location.href = "menu.cfm";
}

function moveToListByPost() {
  submitPost("slip_list.cfm", {
    return_search_slip_no: getValue("return_search_slip_no"),
    return_search_order_date_from: getValue("return_search_order_date_from"),
    return_search_order_date_to: getValue("return_search_order_date_to"),
    return_search_delivery_date_from: getValue("return_search_delivery_date_from"),
    return_search_delivery_date_to: getValue("return_search_delivery_date_to"),
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_keyword: getValue("return_search_supplier_keyword"),
    return_search_item_keyword: getValue("return_search_item_keyword"),
    return_search_status: getValue("return_search_status"),
    return_current_page: getValue("return_current_page"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")
  });
}

function loadSlipDetail() {
  const slipNo = getValue("detail_slip_no");
  const loadingIndicator = document.getElementById("loading_indicator");

  if (!slipNo) {
    renderEmptyHeader();
    renderEmptyDetailTable();
    return;
  }

  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  fetch(dtBaseUrl + "/slip_list_dt.cfc?method=getSlipDetail&returnformat=json", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      slip_no: slipNo
    })
  })
    .then(function (response) {
      if (!response.ok) {
        throw new Error("HTTPエラー: " + response.status);
      }
      return response.json();
    })
    .then(function (data) {
      if (!data || Number(data.status) !== 0) {
        throw new Error(data && data.message ? data.message : "伝票詳細の取得に失敗しました。");
      }

      renderHeader(data.header || {});
      detailRows = data.details || [];

      if (slipDisplayMode === "edit") {
        renderDetailTableEdit(detailRows);
      } else {
        renderDetailTableView(detailRows);
      }

      updateTotals();
    })
    .catch(async function (error) {
      console.error("伝票詳細取得エラー:", error);
      renderEmptyHeader();
      renderErrorDetailTable();

      await Swal.fire({
        title: "取得失敗",
        text: error.message || "伝票詳細の取得に失敗しました。",
        icon: "error",
        confirmButtonText: "OK",
        confirmButtonColor: "#B84A4A"
      });
    })
    .finally(function () {
      if (loadingIndicator) {
        loadingIndicator.classList.remove("is-visible");
      }
    });
}

function renderHeader(header) {
  setText("slip_no_disp", header.slip_no || "");
  setStatus(header.status);
  setText("slip_date_disp", formatDateDisplay(header.slip_date));
  setText("delivery_date_disp", formatDateDisplay(header.delivery_date));
  setText("supplier_code_disp", header.supplier_code || "");
  setText("supplier_name_disp", header.supplier_name || "");
  setText("total_qty_disp", formatNumber(header.total_qty || 0));
  setText("total_amount_disp", formatNumber(header.total_amount || 0));
  setText("memo_disp", header.memo || "");
  setText("create_datetime_disp", header.create_datetime_disp || "");
  setText("update_datetime_disp", header.update_datetime_disp || "");

  setValue("slip_no", header.slip_no || "");
  setValue("status", header.status || "1");
  setValue("slip_date", header.slip_date || "");
  setValue("delivery_date", header.delivery_date || "");
  setValue("supplier_code", header.supplier_code || "");
  setValue("memo", header.memo || "");

  updateSupplierNameDisplay();
}

function renderEmptyHeader() {
  setText("slip_no_disp", "");
  setText("status_disp", "");
  setText("slip_date_disp", "");
  setText("delivery_date_disp", "");
  setText("supplier_code_disp", "");
  setText("supplier_name_disp", "");
  setText("total_qty_disp", "0");
  setText("total_amount_disp", "0");
  setText("memo_disp", "");
  setText("create_datetime_disp", "");
  setText("update_datetime_disp", "");

  setValue("slip_no", "");
  setValue("status", "1");
  setValue("slip_date", "");
  setValue("delivery_date", "");
  setValue("supplier_code", "");
  setValue("memo", "");
}

function renderDetailTableView(details) {
  const tbody = document.getElementById("detail_table_body");
  if (!tbody) return;

  if (!details || details.length === 0) {
    renderEmptyDetailTable();
    return;
  }

  let html = "";

  details.forEach(function (row, index) {
    html += `
      <tr>
        <td class="align-center">${index + 1}</td>
        <td class="align-center">${escapeHtml(row.item_code || "")}</td>
        <td class="align-center">${escapeHtml(row.jan_code || "")}</td>
        <td>${escapeHtml(row.item_name || "")}</td>
        <td class="align-right">${formatNumber(row.qty || 0)}</td>
        <td class="align-right">${formatNumber(row.unit_price || 0)}</td>
        <td class="align-right">${formatNumber(row.amount || 0)}</td>
      </tr>
    `;
  });

  tbody.innerHTML = html;
}

function renderDetailTableEdit(details) {
  const tbody = document.getElementById("detail_table_body");
  if (!tbody) return;

  if (!details || details.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="7" class="empty-row">明細がありません。</td>
      </tr>
    `;
    return;
  }

  let html = "";

  details.forEach(function (row, index) {
    const qty = Number(row.qty || 0);
    const unitPrice = Number(row.unit_price || 0);
    const amount = qty * unitPrice;

    html += `
      <tr data-index="${index}">
        <td class="align-center">${index + 1}</td>
        <td>
          <input type="text" class="form-control item-code-input" data-index="${index}" value="${escapeHtml(row.item_code || "")}">
        </td>
        <td>
          <input type="text" class="form-control jan-code-input" data-index="${index}" value="${escapeHtml(row.jan_code || "")}" readonly>
        </td>
        <td>
          <input type="text" class="form-control item-name-input" data-index="${index}" value="${escapeHtml(row.item_name || "")}" readonly>
        </td>
        <td>
          <input type="text" class="form-control qty-input align-right" data-index="${index}" value="${escapeHtml(qty)}">
        </td>
        <td>
          <input type="text" class="form-control unit-price-input align-right" data-index="${index}" value="${escapeHtml(unitPrice)}">
        </td>
        <td>
          <input type="text" class="form-control amount-input align-right" data-index="${index}" value="${formatNumber(amount)}" readonly>
        </td>
      </tr>
    `;
  });

  tbody.innerHTML = html;
  bindDetailTableEvents();
}

function bindDetailTableEvents() {
  document.querySelectorAll(".qty-input").forEach(function (input) {
    input.addEventListener("input", function () {
      const index = Number(input.dataset.index);
      detailRows[index].qty = toNumber(input.value);
      updateDetailAmount(index);
      updateTotals();
    });
  });

  document.querySelectorAll(".unit-price-input").forEach(function (input) {
    input.addEventListener("input", function () {
      const index = Number(input.dataset.index);
      detailRows[index].unit_price = toNumber(input.value);
      updateDetailAmount(index);
      updateTotals();
    });
  });
}

function updateDetailAmount(index) {
  const row = detailRows[index];
  if (!row) return;

  row.amount = toNumber(row.qty) * toNumber(row.unit_price);

  const tbody = document.getElementById("detail_table_body");
  if (!tbody) return;

  const targetRow = tbody.querySelector(`tr[data-index="${index}"]`);
  if (!targetRow) return;

  const amountInput = targetRow.querySelector(".amount-input");
  if (amountInput) {
    amountInput.value = formatNumber(row.amount);
  }
}

function updateSupplierNameDisplay() {
  const supplierCode = getValue("supplier_code");
  const supplierMap = window.slipListDtMaster && window.slipListDtMaster.supplierMap ? window.slipListDtMaster.supplierMap : {};
  setText("supplier_name_disp", supplierMap[supplierCode] || "");
}

function updateTotals() {
  let totalQty = 0;
  let totalAmount = 0;

  detailRows.forEach(function (row) {
    totalQty += toNumber(row.qty);
    totalAmount += toNumber(row.qty) * toNumber(row.unit_price);
  });

  setText("total_qty_disp", formatNumber(totalQty));
  setText("total_amount_disp", formatNumber(totalAmount));
  updateSupplierNameDisplay();
}

async function saveSlip() {
  const slipNo = getValue("detail_slip_no");
  const loadingIndicator = document.getElementById("loading_indicator");

  if (!slipNo) {
    await Swal.fire({
      title: "伝票番号エラー",
      text: "伝票番号が取得できません。",
      icon: "error",
      confirmButtonText: "OK",
      confirmButtonColor: "#B84A4A"
    });
    return;
  }

  const requestBody = {
    slip_no: slipNo,
    display_mode: getValue("detail_display_mode"),
    status: getValue("status"),
    slip_date: getValue("slip_date"),
    delivery_date: getValue("delivery_date"),
    supplier_code: getValue("supplier_code"),
    memo: getValue("memo"),
    details: detailRows
  };

  if (!requestBody.slip_date) {
    await Swal.fire({
      title: "入力内容を確認してください",
      text: "発注日を入力してください。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  if (!requestBody.delivery_date) {
    await Swal.fire({
      title: "入力内容を確認してください",
      text: "納品日を入力してください。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  if (!requestBody.supplier_code) {
    await Swal.fire({
      title: "入力内容を確認してください",
      text: "取引先コードを選択してください。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  if (!detailRows.length) {
    await Swal.fire({
      title: "明細を確認してください",
      text: "明細がありません。",
      icon: "warning",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });
    return;
  }

  const confirmResult = await Swal.fire({
    title: "この内容で伝票を保存しますか？",
    icon: "question",
    showCancelButton: true,
    confirmButtonText: "保存する",
    cancelButtonText: "戻る",
    confirmButtonColor: "#3F5B4B",
    cancelButtonColor: "#8A8175",
    reverseButtons: true
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  if (loadingIndicator) {
    loadingIndicator.classList.add("is-visible");
  }

  try {
    const response = await fetch(dtBaseUrl + "/slip_list_dt.cfc?method=saveSlipDetail&returnformat=json", {
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
      throw new Error(data && data.message ? data.message : "保存に失敗しました。");
    }

    await Swal.fire({
      title: "保存完了",
      text: data.message || "保存しました。",
      icon: "success",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });

    submitPost("slip_list_dt.cfm", {
      detail_slip_no: slipNo,
      detail_display_mode: "view",
      return_from_menu: getValue("return_from_menu"),
      return_search_slip_no: getValue("return_search_slip_no"),
      return_search_order_date_from: getValue("return_search_order_date_from"),
      return_search_order_date_to: getValue("return_search_order_date_to"),
      return_search_delivery_date_from: getValue("return_search_delivery_date_from"),
      return_search_delivery_date_to: getValue("return_search_delivery_date_to"),
      return_search_supplier_code: getValue("return_search_supplier_code"),
      return_search_supplier_keyword: getValue("return_search_supplier_keyword"),
      return_search_item_keyword: getValue("return_search_item_keyword"),
      return_search_status: getValue("return_search_status"),
      return_current_page: getValue("return_current_page"),
      return_sort_field: getValue("return_sort_field"),
      return_sort_order: getValue("return_sort_order")
    });
  } catch (error) {
    console.error("伝票保存エラー:", error);

    await Swal.fire({
      title: "保存失敗",
      text: error.message || "保存に失敗しました。",
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

function renderEmptyDetailTable() {
  const tbody = document.getElementById("detail_table_body");
  if (!tbody) return;

  tbody.innerHTML = `
    <tr>
      <td colspan="7" class="empty-row">明細がありません。</td>
    </tr>
  `;
}

function renderErrorDetailTable() {
  const tbody = document.getElementById("detail_table_body");
  if (!tbody) return;

  tbody.innerHTML = `
    <tr>
      <td colspan="7" class="empty-row">伝票詳細の取得に失敗しました。</td>
    </tr>
  `;
}

function getStatusLabel(status) {
  const value = String(status || "");
  if (value === "2") return "確定";
  if (value === "3") return "削除";
  return value === "1" ? "登録" : "";
}

function formatDateDisplay(value) {
  if (!value) return "";
  return String(value).replace(/-/g, "/");
}

function toNumber(value) {
  if (value == null) return 0;
  const normalized = String(value).replace(/,/g, "").trim();
  if (normalized === "") return 0;
  const num = Number(normalized);
  return isNaN(num) ? 0 : num;
}

function formatNumber(value) {
  const num = Number(value || 0);
  return num.toLocaleString("ja-JP");
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

function setText(id, value) {
  const element = document.getElementById(id);
  if (element) {
    element.textContent = value == null ? "" : value;
  }
}

function submitPost(action, params) {
  const form = document.createElement("form");
  form.method = "post";
  form.action = action;
  form.style.display = "none";

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

function setStatus(status) {
  const el = document.getElementById("status_disp");

  let text = "";
  if (status == "1") text = "登録";
  if (status == "2") text = "確定";
  if (status == "3") text = "削除";

  el.textContent = text;
  el.classList.remove("status-1", "status-2", "status-3");
  el.classList.add("status-" + status);
}