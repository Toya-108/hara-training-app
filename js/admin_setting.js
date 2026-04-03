let displayMode = "view";

document.addEventListener("DOMContentLoaded", function () {
  initializeScreenValues();
  bindHeaderButtons();
  bindEvents();
});

function initializeScreenValues() {
  displayMode = String(getValue("display_mode") || "view").toLowerCase();

  if (displayMode !== "view" && displayMode !== "edit") {
    displayMode = "view";
    setValue("display_mode", "view");
  }
}

function bindHeaderButtons() {
  const homeBtn = document.getElementById("home-btn");
  const editBtn = document.getElementById("edit-button");
  const cancelBtn = document.getElementById("cancel-button");

  if (homeBtn) {
    homeBtn.addEventListener("click", function (event) {
      event.preventDefault();
      location.href = "menu.cfm";
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
      moveToView();
    });
  }
}

function bindEvents() {
  const saveBtn = document.getElementById("save_btn");
  if (saveBtn) {
    saveBtn.addEventListener("click", async function () {
      await saveBasicSetting();
    });
  }
}

function moveToEdit() {
  submitPost("admin_setting.cfm", {
    display_mode: "edit"
  });
}

function moveToView() {
  submitPost("admin_setting.cfm", {
    display_mode: "view"
  });
}

async function saveBasicSetting() {
  const companyCode = getValue("company_code");
  const companyName = getValue("company_name");

  if (!companyCode) {
    await showErrorAlert("会社コードを入力してください。");
    focusTo("company_code");
    return;
  }

  if (!companyName) {
    await showErrorAlert("会社名を入力してください。");
    focusTo("company_name");
    return;
  }

  const confirmResult = await Swal.fire({
    icon: "question",
    title: "保存しますか？",
    text: "基本設定を更新します。",
    showCancelButton: true,
    confirmButtonText: "保存する",
    cancelButtonText: "キャンセル",
    reverseButtons: true,
    confirmButtonColor: "#3F5B4B",
    cancelButtonColor: "#8A8175"
  });

  if (!confirmResult.isConfirmed) {
    return;
  }

  showLoading(true);

  try {
    const response = await fetch("/training/hara/admin_setting.cfc?method=saveBasicSetting&returnformat=json", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        company_code: getValue("company_code"),
        company_name: getValue("company_name"),
        center_name: getValue("center_name"),
        postal_code: getValue("postal_code"),
        address1: getValue("address1"),
        address2: getValue("address2"),
        tel_no: getValue("tel_no"),
        fax_no: getValue("fax_no"),
        memo: getValue("memo", false),
        admin_password: getValue("admin_password", false)
      })
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
      title: "保存完了",
      text: data.message || "保存しました。",
      confirmButtonText: "OK",
      confirmButtonColor: "#3F5B4B"
    });

    submitPost("admin_setting.cfm", {
      display_mode: "view"
    });
  } catch (error) {
    console.error("基本設定保存エラー:", error);
    await showErrorAlert(error.message || "保存に失敗しました。");
    showLoading(false);
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

function showLoading(show) {
  const area = document.getElementById("loading_indicator");
  if (!area) return;

  if (show) {
    area.classList.add("is-visible");
  } else {
    area.classList.remove("is-visible");
  }
}

async function showErrorAlert(message) {
  await Swal.fire({
    icon: "error",
    title: "エラー",
    text: message || "エラーが発生しました。",
    confirmButtonText: "OK",
    confirmButtonColor: "#B84A4A"
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