let supplierId = 0;
let displayMode = "view";

const baseUrl = "/training/hara";
const listUrl = "m_supplier.cfm";
const detailUrl = "m_supplier_dt.cfm";

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindHeaderButtons();
  bindEvents();
  bindDeleteButton();
  bindZipcodeAutoFill();
  applyModeLayout();
  setUseFlag(getValue("use_flag"));
});

function initializeScreenValues() {
  supplierId = Number(getValue("supplier_id") || 0);
  displayMode = String(getValue("display_mode") || "view").toLowerCase();

  if (displayMode !== "view" && displayMode !== "edit" && displayMode !== "add") {
    displayMode = "view";
    setValue("display_mode", "view");
  }
}

function bindHeaderButtons() {
  const backBtn = document.getElementById("back-btn");
  const addBtn = document.getElementById("add-button");
  const editBtn = document.getElementById("edit-button");
  const cancelBtn = document.getElementById("cancel-button");

  if (backBtn) {
    backBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveToListByPost();
    });
  }

  if (addBtn) {
    addBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveToAdd();
    });
  }

  if (editBtn) {
    editBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveToEdit();
    });
  }

  if (cancelBtn) {
    cancelBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveToCancel();
    });
  }
}

function bindEvents() {
  const saveBtn = document.getElementById("save_btn");
  if (saveBtn) {
    saveBtn.addEventListener("click", async function () {
      await saveSupplier();
    });
  }
}

function applyModeLayout() {
  const card = document.getElementById("dt_card");
  const saveBtn = document.getElementById("save_btn");
  const deleteBtn = document.getElementById("trash-button");

  if (displayMode === "view") {
    if (card) card.classList.add("view_mode");
    if (saveBtn) saveBtn.style.display = "none";
    if (deleteBtn) deleteBtn.style.display = "";
    setModeBadge("表示");
  } else if (displayMode === "edit") {
    if (card) card.classList.remove("view_mode");
    if (saveBtn) saveBtn.style.display = "";
    if (deleteBtn) deleteBtn.style.display = "none";
    setModeBadge("修正");
  } else if (displayMode === "add") {
    if (card) card.classList.remove("view_mode");
    if (saveBtn) saveBtn.style.display = "";
    if (deleteBtn) deleteBtn.style.display = "none";
    setModeBadge("追加");
  }
}

function moveToAdd() {
  submitPost(detailUrl, {
    supplier_code: "",
    return_supplier_code: "",
    display_mode: "add",
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_name: getValue("return_search_supplier_name"),
    return_search_delivery_company: getValue("return_search_delivery_company"),
    return_search_use_flag: getValue("return_search_use_flag"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order"),
    return_page: getValue("return_page")
  });
}

function moveToEdit() {
  const supplierCode = getReturnSupplierCode();

  if (!supplierCode) {
    showErrorAlert("取引先コードが取得できません。");
    return;
  }

  submitPost(detailUrl, {
    supplier_code: supplierCode,
    return_supplier_code: supplierCode,
    display_mode: "edit",
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_name: getValue("return_search_supplier_name"),
    return_search_delivery_company: getValue("return_search_delivery_company"),
    return_search_use_flag: getValue("return_search_use_flag"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order"),
    return_page: getValue("return_page")
  });
}

function moveToView() {
  const supplierCode = getReturnSupplierCode();

  if (!supplierCode) {
    moveToListByPost();
    return;
  }

  submitPost(detailUrl, {
    supplier_code: supplierCode,
    return_supplier_code: supplierCode,
    display_mode: "view",
    return_search_supplier_code: getValue("return_search_supplier_code"),
    return_search_supplier_name: getValue("return_search_supplier_name"),
    return_search_delivery_company: getValue("return_search_delivery_company"),
    return_search_use_flag: getValue("return_search_use_flag"),
    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order"),
    return_page: getValue("return_page")
  });
}

function moveToCancel() {
  moveToView();
}

function moveToListByPost() {
  submitPost(listUrl, {
    search_supplier_code: getValue("return_search_supplier_code"),
    search_supplier_name: getValue("return_search_supplier_name"),
    search_delivery_company: getValue("return_search_delivery_company"),
    search_use_flag: getValue("return_search_use_flag"),
    sort_field: getValue("return_sort_field"),
    sort_order: getValue("return_sort_order"),
    page: getValue("return_page")
  });
}

function getReturnSupplierCode() {
  const returnSupplierCode = getValue("return_supplier_code");
  if (returnSupplierCode) {
    return returnSupplierCode;
  }

  return getValue("supplier_code");
}

async function saveSupplier() {
  if (displayMode !== "edit" && displayMode !== "add") {
    return;
  }

  const validationMessage = validateForm();
  if (validationMessage) {
    await showErrorAlert(validationMessage);
    return;
  }

  const confirmTitle = displayMode === "add" ? "登録しますか？" : "保存しますか？";
  const confirmText = displayMode === "add"
    ? "入力内容で新しく登録します。"
    : "入力内容で更新します。";

  const confirmResult = await Swal.fire({
    icon: "question",
    title: confirmTitle,
    text: confirmText,
    showCancelButton: true,
    confirmButtonText: "はい",
    cancelButtonText: "キャンセル",
    reverseButtons: true
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  const payload = {
    supplier_id: Number(getValue("supplier_id") || 0),
    supplier_code: getValue("supplier_code"),
    supplier_name: getValue("supplier_name"),
    supplier_name_kana: getValue("supplier_name_kana"),
    zip_code: getValue("zip_code"),
    prefecture_code: getValue("prefecture_code"),
    address1: getValue("address1"),
    address2: getValue("address2"),
    tel: getValue("tel"),
    fax: getValue("fax"),
    delivery_company_code: getValue("delivery_company_code"),
    note: getValue("note", false),
    use_flag: getValue("use_flag")
  };

  showLoading(true);

  try {
    const response = await fetch(baseUrl + "/m_supplier_dt.cfc?method=saveSupplier&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      throw new Error(data && data.message ? data.message : "保存に失敗しました。");
    }

    await Swal.fire({
      icon: "success",
      title: "完了",
      text: data.message || "保存しました。",
      confirmButtonText: "OK"
    });

    const savedSupplierCode =
      data &&
      data.results &&
      data.results.supplier_code
        ? String(data.results.supplier_code)
        : getValue("supplier_code");

    if (!savedSupplierCode) {
      throw new Error("保存後の取引先コードが取得できません。");
    }

    submitPost(detailUrl, {
      supplier_code: savedSupplierCode,
      return_supplier_code: savedSupplierCode,
      display_mode: "view",
      return_search_supplier_code: getValue("return_search_supplier_code"),
      return_search_supplier_name: getValue("return_search_supplier_name"),
      return_search_delivery_company: getValue("return_search_delivery_company"),
      return_search_use_flag: getValue("return_search_use_flag"),
      return_sort_field: getValue("return_sort_field"),
      return_sort_order: getValue("return_sort_order"),
      return_page: getValue("return_page")
    });
  } catch (error) {
    console.error("取引先保存エラー:", error);
    await showErrorAlert(error.message || "保存に失敗しました。");
    showLoading(false);
  }
}

function validateForm() {
  const supplierCode = getValue("supplier_code");
  const supplierName = getValue("supplier_name");

  if (!supplierCode) {
    focusTo("supplier_code");
    return "取引先コードを入力してください。";
  }

  if (!supplierName) {
    focusTo("supplier_name");
    return "取引先名を入力してください。";
  }

  return "";
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

function setModeBadge(text) {
  const badge = document.getElementById("mode_badge");
  if (badge) {
    badge.textContent = text;
  }
}

function showLoading(show) {
  const area = document.getElementById("loading_area");
  if (!area) return;

  if (show) {
    area.classList.add("is-show");
  } else {
    area.classList.remove("is-show");
  }
}

async function showErrorAlert(message) {
  await Swal.fire({
    icon: "error",
    title: "エラー",
    text: message || "エラーが発生しました。",
    confirmButtonText: "OK"
  });
}

function getValue(id, trimFlag = true) {
  const element = document.getElementById(id);
  if (!element) return "";

  const value = element.value == null ? "" : String(element.value);
  return trimFlag ? value.trim() : value;
}

function setValue(id, value) {
  const element = document.getElementById(id);
  if (element) {
    element.value = value == null ? "" : value;
  }
}

function focusTo(id) {
  const element = document.getElementById(id);
  if (element) {
    element.focus();
  }
}

function bindZipcodeAutoFill() {
  const zipInput = document.getElementById("zip_code");
  if (!zipInput) return;

  zipInput.addEventListener("blur", async function () {
    await lookupZipcodeAndFill(false);
  });

  zipInput.addEventListener("keydown", async function (event) {
    if (event.key === "Enter") {
      event.preventDefault();
      await lookupZipcodeAndFill(true);
    }
  });
}

async function lookupZipcodeAndFill(showSuccessMessage) {
  if (displayMode !== "edit" && displayMode !== "add") {
    return;
  }

  const zipCode = getValue("zip_code");
  const normalizedZip = normalizeZipCode(zipCode);

  if (!normalizedZip || normalizedZip.length !== 7) {
    return;
  }

  try {
    const response = await fetch(baseUrl + "/m_supplier_dt.cfc?method=lookupZipcode&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        zip_code: normalizedZip
      })
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      throw new Error(data && data.message ? data.message : "住所取得に失敗しました。");
    }

    const results = data.results || {};

    if (results.zip_code) {
      setValue("zip_code", formatZipCode(results.zip_code));
    }

    if (results.prefecture_code) {
      setSelectValue("prefecture_code", results.prefecture_code);
    }

    if (results.address1) {
      setValue("address1", results.address1);
    }

    if (showSuccessMessage) {
      await Swal.fire({
        icon: "success",
        title: "住所を取得しました",
        text: "都道府県と住所1を自動入力しました。",
        confirmButtonText: "OK"
      });
    }
  } catch (error) {
    console.error("郵便番号検索エラー:", error);

    await Swal.fire({
      icon: "error",
      title: "郵便番号検索エラー",
      text: error.message || "郵便番号から住所を取得できませんでした。",
      confirmButtonText: "OK"
    });
  }
}

function normalizeZipCode(value) {
  if (value == null) return "";
  return String(value).replace(/[^0-9]/g, "");
}

function formatZipCode(value) {
  const zip = normalizeZipCode(value);
  if (zip.length === 7) {
    return zip.slice(0, 3) + "-" + zip.slice(3);
  }
  return value == null ? "" : String(value);
}

function setSelectValue(id, value) {
  const element = document.getElementById(id);
  if (!element) return;
  element.value = value == null ? "" : String(value);
}

function bindDeleteButton() {
  const deleteBtn = document.getElementById("trash-button");
  if (!deleteBtn) return;

  deleteBtn.addEventListener("click", async function () {
    await deleteSupplier();
  });
}

async function deleteSupplier() {
  if (displayMode === "add") {
    await showErrorAlert("追加画面では削除できません。");
    return;
  }

  const currentSupplierId = Number(getValue("supplier_id") || 0);
  const currentSupplierCode = getValue("supplier_code");
  const currentSupplierName = getValue("supplier_name");

  if (currentSupplierId <= 0) {
    await showErrorAlert("取引先IDが取得できません。");
    return;
  }

  const confirmResult = await Swal.fire({
    icon: "warning",
    title: "削除しますか？",
    text: `取引先コード: ${currentSupplierCode || ""} ${currentSupplierName || ""}`,
    showCancelButton: true,
    confirmButtonText: "削除する",
    cancelButtonText: "キャンセル",
    reverseButtons: true
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  showLoading(true);

  try {
    const response = await fetch(baseUrl + "/m_supplier_dt.cfc?method=deleteSupplier&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        supplier_id: currentSupplierId
      })
    });

    if (!response.ok) {
      throw new Error("HTTPエラー: " + response.status);
    }

    const data = await response.json();

    if (!data || Number(data.status) !== 0) {
      throw new Error(data && data.message ? data.message : "削除に失敗しました。");
    }

    await Swal.fire({
      icon: "success",
      title: "完了",
      text: data.message || "削除しました。",
      confirmButtonText: "OK"
    });

    moveToListByPost();
  } catch (error) {
    console.error("取引先削除エラー:", error);
    await showErrorAlert(error.message || "削除に失敗しました。");
    showLoading(false);
  }
}

function setUseFlag(flag) {
    const el = document.getElementById("use_flag_disp");
    if (!el) return;

    let text = "";
    if (flag == "1") text = "有効";
    if (flag == "0") text = "無効";

    el.textContent = text;

    el.classList.remove("use-1", "use-0");
    el.classList.add("use-" + flag);
}