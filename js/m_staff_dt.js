let staffId = 0;
let displayMode = "view";

const baseUrl = "/training/hara";
const listUrl = "m_staff.cfm";
const detailUrl = "m_staff_dt.cfm";

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindHeaderButtons();
  bindEvents();
  applyModeLayout();
});

function initializeScreenValues() {
  staffId = Number(getValue("staff_id") || 0);
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
  const currentStaffId = getReturnStaffId();

  submitPost(detailUrl, {
    staff_id: "",
    return_staff_id: currentStaffId,
    display_mode: "add",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag")
  });
}

function moveToEdit() {
  const currentStaffId = getReturnStaffId();

  if (!currentStaffId) {
    showErrorAlert("社員IDが取得できません。");
    return;
  }

  submitPost(detailUrl, {
    staff_id: currentStaffId,
    return_staff_id: currentStaffId,
    display_mode: "edit",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag")
  });
}

function moveToView() {
  const currentStaffId = getReturnStaffId();

  if (!currentStaffId) {
    moveToListByPost();
    return;
  }

  submitPost(detailUrl, {
    staff_id: currentStaffId,
    return_staff_id: currentStaffId,
    display_mode: "view",
    return_search_staff_code: getValue("return_search_staff_code"),
    return_search_staff_name: getValue("return_search_staff_name"),
    return_search_mail_address: getValue("return_search_mail_address"),
    return_search_authority_level: getValue("return_search_authority_level"),
    return_search_use_flag: getValue("return_search_use_flag")
  });
}

function moveToCancel() {
  const currentStaffId = getReturnStaffId();

  if (displayMode === "add" && !currentStaffId) {
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
    search_use_flag: getValue("return_search_use_flag")
  });
}

function getReturnStaffId() {
  const returnStaffId = getValue("return_staff_id");
  if (returnStaffId) {
    return returnStaffId;
  }

  return getValue("staff_id");
}

async function deleteStaff() {
  if (displayMode !== "view") {
    return;
  }

  const currentStaffId = Number(getValue("staff_id") || 0);
  const currentStaffCode = getValue("staff_code");
  const currentStaffName = getValue("staff_name");

  if (currentStaffId <= 0) {
    await showErrorAlert("社員IDが取得できません。");
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
        staff_id: currentStaffId
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
    staff_id: Number(getValue("staff_id") || 0),
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

    const savedStaffId =
      data &&
      data.results &&
      data.results.staff_id
        ? String(data.results.staff_id)
        : "";

    if (displayMode === "add") {
      const returnStaffId = getValue("return_staff_id");

      if (!returnStaffId) {
        moveToListByPost();
        return;
      }
    }

    if (!savedStaffId) {
      moveToListByPost();
      return;
    }

    submitPost(detailUrl, {
      staff_id: savedStaffId,
      return_staff_id: savedStaffId,
      display_mode: "view",
      return_search_staff_code: getValue("return_search_staff_code"),
      return_search_staff_name: getValue("return_search_staff_name"),
      return_search_mail_address: getValue("return_search_mail_address"),
      return_search_authority_level: getValue("return_search_authority_level"),
      return_search_use_flag: getValue("return_search_use_flag")
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