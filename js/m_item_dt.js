let displayMode = "view";

const baseUrl = "/training/hara";
const listUrl = "m_item.cfm";
const detailUrl = "m_item_dt.cfm";

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindHeaderButtons();
  bindEvents();
  applyModeLayout();
});

function initializeScreenValues() {
  displayMode = String(getValue("display_mode") || "view").toLowerCase();

  if (displayMode !== "view" && displayMode !== "edit" && displayMode !== "add") {
    displayMode = "view";
    setValue("display_mode", "view");
  }

  const returnTo = String(getValue("return_to") || "list").toLowerCase();
  if (returnTo !== "list" && returnTo !== "detail") {
    setValue("return_to", "list");
  }
}

function bindHeaderButtons() {
  const backBtn = document.getElementById("back-btn");
  const addBtn = document.getElementById("add-button");
  const editBtn = document.getElementById("edit-button");
  const trashBtn = document.getElementById("trash-button");
  const cancelBtn = document.getElementById("cancel-button");

  if (backBtn) {
    backBtn.addEventListener("click", function (event) {
      event.preventDefault();
      moveBack();
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

  if (trashBtn) {
    trashBtn.addEventListener("click", async function (event) {
      event.preventDefault();
      await deleteItem();
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
      await saveItem();
    });
  }
}

function applyModeLayout() {
  const card = document.getElementById("dt_card");
  const saveBtn = document.getElementById("save_btn");

  if (displayMode === "view") {
    if (card) card.classList.add("view_mode");
    if (saveBtn) saveBtn.style.display = "none";
    setModeBadge("表示");
  } else if (displayMode === "edit") {
    if (card) card.classList.remove("view_mode");
    if (saveBtn) saveBtn.style.display = "";
    setModeBadge("修正");
  } else if (displayMode === "add") {
    if (card) card.classList.remove("view_mode");
    if (saveBtn) saveBtn.style.display = "";
    setModeBadge("追加");
  }
}

function getReturnTo() {
  const value = String(getValue("return_to") || "list").toLowerCase();
  return value === "detail" ? "detail" : "list";
}

function getCurrentItemCode() {
  const currentCode = getValue("item_code");
  if (currentCode) {
    return currentCode;
  }

  const inputCode = getValue("input_item_code");
  if (inputCode) {
    return inputCode;
  }

  return "";
}

function getOriginItemCode() {
  return getValue("return_item_code");
}

function moveBack() {
  if (getReturnTo() === "detail" && getOriginItemCode()) {
    moveToOriginDetail();
    return;
  }

  moveToListByPost();
}

function moveToAdd() {
  const currentItemCode = getCurrentItemCode();

  submitPost(detailUrl, {
    item_code: "",
    return_item_code: currentItemCode,
    display_mode: "add",
    return_to: "detail",
    return_url: detailUrl,
    return_search_product_code: getValue("return_search_product_code"),
    return_search_jan_code: getValue("return_search_jan_code"),
    return_search_product_name: getValue("return_search_product_name")
  });
}

function moveToEdit() {
  const currentItemCode = getCurrentItemCode();

  if (!currentItemCode) {
    showErrorAlert("商品コードが取得できません。");
    return;
  }

  submitPost(detailUrl, {
    item_code: currentItemCode,
    return_item_code: getOriginItemCode(),
    display_mode: "edit",
    return_to: getReturnTo(),
    return_url: getValue("return_url"),
    return_search_product_code: getValue("return_search_product_code"),
    return_search_jan_code: getValue("return_search_jan_code"),
    return_search_product_name: getValue("return_search_product_name")
  });
}

function moveToCurrentView() {
  const currentItemCode = getCurrentItemCode();

  if (!currentItemCode) {
    moveBack();
    return;
  }

  submitPost(detailUrl, {
    item_code: currentItemCode,
    return_item_code: getOriginItemCode(),
    display_mode: "view",
    return_to: getReturnTo(),
    return_url: getValue("return_url"),
    return_search_product_code: getValue("return_search_product_code"),
    return_search_jan_code: getValue("return_search_jan_code"),
    return_search_product_name: getValue("return_search_product_name")
  });
}

function moveToOriginDetail() {
  const originItemCode = getOriginItemCode();

  if (!originItemCode) {
    moveToListByPost();
    return;
  }

  submitPost(detailUrl, {
    item_code: originItemCode,
    return_item_code: "",
    display_mode: "view",
    return_to: "list",
    return_url: listUrl,
    return_search_product_code: getValue("return_search_product_code"),
    return_search_jan_code: getValue("return_search_jan_code"),
    return_search_product_name: getValue("return_search_product_name")
  });
}

function moveToCancel() {
  if (displayMode === "edit") {
    moveToCurrentView();
    return;
  }

  if (displayMode === "add") {
    if (getReturnTo() === "detail" && getOriginItemCode()) {
      moveToOriginDetail();
      return;
    }

    moveToListByPost();
  }
}

function moveToListByPost() {
  submitPost(listUrl, {
    search_product_code: getValue("return_search_product_code"),
    search_jan_code: getValue("return_search_jan_code"),
    search_product_name: getValue("return_search_product_name")
  });
}

async function saveItem() {
  if (displayMode !== "edit" && displayMode !== "add") {
    return;
  }

  const validationMessage = validateForm();
  if (validationMessage) {
    await showErrorAlert(validationMessage);
    return;
  }

  const confirmResult = await Swal.fire({
    icon: "question",
    title: displayMode === "add" ? "登録しますか？" : "保存しますか？",
    text: displayMode === "add" ? "入力内容で新しく登録します。" : "入力内容で更新します。",
    showCancelButton: true,
    confirmButtonText: "はい",
    cancelButtonText: "キャンセル",
    reverseButtons: true
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  const payload = {
    old_item_code: getValue("item_code"),
    item_code: getValue("input_item_code"),
    jan_code: getValue("jan_code"),
    item_name: getValue("item_name"),
    item_name_kana: getValue("item_name_kana"),
    gentanka: getValue("gentanka"),
    baitanka: getValue("baitanka"),
    item_category: getValue("item_category"),
    use_flag: getValue("use_flag")
  };

  showLoading(true);

  try {
    const response = await fetch(baseUrl + "/m_item_dt.cfc?method=saveItem&returnformat=json", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
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

    const savedItemCode = data && data.results && data.results.item_code
      ? String(data.results.item_code)
      : getValue("input_item_code");

    if (!savedItemCode) {
      moveBack();
      return;
    }

    submitPost(detailUrl, {
      item_code: savedItemCode,
      return_item_code: getOriginItemCode(),
      display_mode: "view",
      return_to: getReturnTo(),
      return_url: getValue("return_url"),
      return_search_product_code: getValue("return_search_product_code"),
      return_search_jan_code: getValue("return_search_jan_code"),
      return_search_product_name: getValue("return_search_product_name")
    });
  } catch (error) {
    console.error("商品保存エラー:", error);
    await showErrorAlert(error.message || "保存に失敗しました。");
    showLoading(false);
  }
}

async function deleteItem() {
  if (displayMode !== "view") {
    return;
  }

  const currentItemCode = getValue("item_code");
  const currentItemName = getValue("item_name");

  if (!currentItemCode) {
    await showErrorAlert("商品コードが取得できません。");
    return;
  }

  const confirmResult = await Swal.fire({
    icon: "warning",
    title: "削除しますか？",
    text: `商品コード: ${currentItemCode} ${currentItemName}`,
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
    const response = await fetch(baseUrl + "/m_item_dt.cfc?method=deleteItem&returnformat=json", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        item_code: currentItemCode
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

    moveBack();
  } catch (error) {
    console.error("商品削除エラー:", error);
    await showErrorAlert(error.message || "削除に失敗しました。");
    showLoading(false);
  }
}

function validateForm() {
  if (!getValue("input_item_code")) {
    focusTo("input_item_code");
    return "商品コードを入力してください。";
  }

  if (!getValue("item_name")) {
    focusTo("item_name");
    return "商品名を入力してください。";
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