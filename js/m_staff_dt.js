let staffCode = "";
let displayMode = "view";

const baseUrl = "/training/hara";
const listUrl = "m_staff.cfm";
const detailUrl = "m_staff_dt.cfm";

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindHeaderButtons();
  bindEvents();
  applyModeLayout();
  setAuthorityLevel(getValue("authority_level"));
  setUseFlag(getValue("use_flag"));
});

function initializeScreenValues() {
  staffCode = getValue("original_staff_code");
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
  const trashBtn = document.getElementById("trash-button");
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

  if (trashBtn) {
    trashBtn.addEventListener("click", async function (event) {
      event.preventDefault();
      await deleteStaff();
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
      await saveStaff();
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

function moveToAdd() {
  const currentStaffCode = getReturnStaffCode();

  submitPost(detailUrl, {
    staff_code: "",
    return_staff_code: currentStaffCode,
    display_mode: "add",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag"),

    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")
  });
}

function moveToEdit() {
  const currentStaffCode = getReturnStaffCode();

  if (!currentStaffCode) {
    showErrorAlert("社員コードが取得できません。");
    return;
  }

  submitPost(detailUrl, {
    staff_code: currentStaffCode,
    return_staff_code: currentStaffCode,
    display_mode: "edit",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag"),

    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")  });
}

function moveToView() {
  const currentStaffCode = getReturnStaffCode();

  if (!currentStaffCode) {
    moveToListByPost();
    return;
  }

  submitPost(detailUrl, {
    staff_code: currentStaffCode,
    return_staff_code: currentStaffCode,
    display_mode: "view",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag"),

    return_sort_field: getValue("return_sort_field"),
    return_sort_order: getValue("return_sort_order")
  });
}

function moveToCancel() {
  const currentStaffCode = getReturnStaffCode();

  if (displayMode === "add" && !currentStaffCode) {
    moveToListByPost();
    return;
  }

  moveToView();
}

function moveToListByPost() {
  submitPost(listUrl, {
    search_staff_code: getValue("return_search_staff_code"),
    search_staff_name: getValue("return_search_staff_name"),
    search_mail_address: getValue("return_search_mail_address"),
    search_authority_level: getValue("return_search_authority_level"),
    search_use_flag: getValue("return_search_use_flag"),

    sort_field: getValue("return_sort_field"),
    sort_order: getValue("return_sort_order")
  });
}

function getReturnStaffCode() {
  const returnStaffCode = getValue("return_staff_code");
  if (returnStaffCode) {
    return returnStaffCode;
  }

  return getValue("original_staff_code");
}

async function deleteStaff() {
  if (displayMode !== "view") {
    return;
  }

  const currentOriginalStaffCode = getValue("original_staff_code");
  const currentStaffCode = getValue("staff_code");
  const currentStaffName = getValue("staff_name");

  if (!currentOriginalStaffCode) {
    await showErrorAlert("社員コードが取得できません。");
    return;
  }

  const confirmResult = await Swal.fire({
    icon: "warning",
    title: "削除しますか？",
    text: `社員コード: ${currentStaffCode} ${currentStaffName}`,
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
    const response = await fetch(baseUrl + "/m_staff_dt.cfc?method=deleteStaff&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        staff_code: currentOriginalStaffCode
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
    console.error("社員削除エラー:", error);
    await showErrorAlert(error.message || "削除に失敗しました。");
    showLoading(false);
  }
}

async function saveStaff() {
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
    original_staff_code: getValue("original_staff_code"),
    staff_code: getValue("staff_code"),
    staff_name: getValue("staff_name"),
    staff_kana: getValue("staff_kana"),
    login_password: getValue("login_password"),
    login_password_confirm: getValue("login_password_confirm"),
    authority_level: getValue("authority_level"),
    mail_address: getValue("mail_address"),
    tel_no: getValue("tel_no"),
    use_flag: getValue("use_flag"),
    note: getValue("note", false)
  };

  showLoading(true);

  try {
    const response = await fetch(baseUrl + "/m_staff_dt.cfc?method=saveStaff&returnformat=json", {
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

    const savedStaffCode =
      data &&
      data.results &&
      data.results.staff_code
        ? String(data.results.staff_code)
        : "";

    if (!savedStaffCode) {
      moveToListByPost();
      return;
    }

    submitPost(detailUrl, {
      staff_code: savedStaffCode,
      return_staff_code: savedStaffCode,
      display_mode: "view",
      return_search_staff_code: getValue("return_search_staff_code"),
      return_search_staff_name: getValue("return_search_staff_name"),
      return_search_mail_address: getValue("return_search_mail_address"),
      return_search_authority_level: getValue("return_search_authority_level"),
      return_search_use_flag: getValue("return_search_use_flag"),

      return_sort_field: getValue("return_sort_field"),
      return_sort_order: getValue("return_sort_order")
    });
  } catch (error) {
    console.error("社員保存エラー:", error);
    await showErrorAlert(error.message || "保存に失敗しました。");
    showLoading(false);
  }
}

function validateForm() {
  const staffCode = getValue("staff_code");
  const staffName = getValue("staff_name");
  const loginPassword = getValue("login_password");
  const loginPasswordConfirm = getValue("login_password_confirm");

  if (!staffCode) {
    focusTo("staff_code");
    return "社員コードを入力してください。";
  }

  if (!staffName) {
    focusTo("staff_name");
    return "社員名を入力してください。";
  }

  if (displayMode === "add" && !loginPassword) {
    focusTo("login_password");
    return "新規登録時はパスワードを入力してください。";
  }

  if (displayMode === "add" && !loginPasswordConfirm) {
    focusTo("login_password_confirm");
    return "新規登録時はパスワード確認を入力してください。";
  }

  if ((loginPassword || loginPasswordConfirm) && loginPassword !== loginPasswordConfirm) {
    focusTo("login_password_confirm");
    return "パスワード確認が一致しません。";
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

function setAuthorityLevel(level) {
    const el = document.getElementById("authority_level_disp");
    if (!el) return;

    let text = "";
    if (level == "9") text = "管理者";
    if (level == "1") text = "一般";

    el.textContent = text;

    el.classList.remove("auth-9", "auth-1");
    el.classList.add("auth-" + level);
}

function setUseFlag(flag) {
    const el = document.getElementById("use_flag_disp");
    if (!el) return;

    let text = "";
    if (flag == "1") text = "使用中";
    if (flag == "0") text = "停止";

    el.textContent = text;

    el.classList.remove("use-1", "use-0");
    el.classList.add("use-" + flag);
}