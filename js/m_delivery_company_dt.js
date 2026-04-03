document.addEventListener("DOMContentLoaded", function () {
    var masterForm = document.getElementById("master_form");

    var originalDeliveryCompanyCode = document.getElementById("original_delivery_company_code");
    var deliveryCompanyCode = document.getElementById("delivery_company_code");
    var deliveryCompanyName = document.getElementById("delivery_company_name");
    var useFlag = document.getElementById("use_flag");
    var note = document.getElementById("note");

    var returnDeliveryCompanyCode = document.getElementById("return_delivery_company_code");
    var displayMode = document.getElementById("display_mode");
    var sourcePage = document.getElementById("source_page");
    var sourceDeliveryCompanyCode = document.getElementById("source_delivery_company_code");

    var returnPage = document.getElementById("return_page");
    var returnSortField = document.getElementById("return_sort_field");
    var returnSortOrder = document.getElementById("return_sort_order");
    var returnSearchDeliveryCompanyCode = document.getElementById("return_search_delivery_company_code");
    var returnSearchDeliveryCompanyName = document.getElementById("return_search_delivery_company_name");
    var returnSearchUseFlag = document.getElementById("return_search_use_flag");

    var messageArea = document.getElementById("message_area");
    var loadingArea = document.getElementById("loading_area");
    var saveBtn = document.getElementById("save_btn");

    function showMessage(message, type) {
        messageArea.textContent = message;
        messageArea.classList.remove("message_success", "message_error", "is-show");

        if (type === "success") {
            messageArea.classList.add("message_success");
        } else {
            messageArea.classList.add("message_error");
        }

        messageArea.classList.add("is-show");
    }

    function showLoading(isShow) {
        if (isShow) {
            loadingArea.classList.add("is-show");
        } else {
            loadingArea.classList.remove("is-show");
        }
    }

    function setUseFlagBadge() {
        var useFlagDisp = document.getElementById("use_flag_disp");
        if (!useFlagDisp) {
            return;
        }

        if (!useFlag) {
            return;
        }

        if (String(useFlag.value) === "1") {
            useFlagDisp.textContent = "使用中";
            useFlagDisp.classList.remove("use_off");
            useFlagDisp.classList.add("use_on");
        } else {
            useFlagDisp.textContent = "停止";
            useFlagDisp.classList.remove("use_on");
            useFlagDisp.classList.add("use_off");
        }
    }

    function appendHidden(form, name, value) {
        var input = document.createElement("input");
        input.type = "hidden";
        input.name = name;
        input.value = value;
        form.appendChild(input);
    }

    function createPostForm(action) {
        var form = document.createElement("form");
        form.method = "post";
        form.action = action;

        appendHidden(form, "return_page", returnPage.value);
        appendHidden(form, "return_sort_field", returnSortField.value);
        appendHidden(form, "return_sort_order", returnSortOrder.value);

        appendHidden(form, "return_search_delivery_company_code", returnSearchDeliveryCompanyCode.value);
        appendHidden(form, "return_search_delivery_company_name", returnSearchDeliveryCompanyName.value);
        appendHidden(form, "return_search_use_flag", returnSearchUseFlag.value);

        return form;
    }

    function moveToList() {
        var form = createPostForm("./m_delivery_company.cfm");
        document.body.appendChild(form);
        form.submit();
    }

    function moveToView(targetCode, sourcePageValue, sourceDeliveryCompanyCodeValue) {
        var form = createPostForm("./m_delivery_company_dt.cfm");

        appendHidden(form, "delivery_company_code", targetCode);
        appendHidden(form, "return_delivery_company_code", targetCode);
        appendHidden(form, "display_mode", "view");
        appendHidden(form, "source_page", sourcePageValue || "list");
        appendHidden(form, "source_delivery_company_code", sourceDeliveryCompanyCodeValue || "");

        document.body.appendChild(form);
        form.submit();
    }

    function moveToAddFromDetail() {
        var form = createPostForm("./m_delivery_company_dt.cfm");

        appendHidden(form, "delivery_company_code", "");
        appendHidden(form, "return_delivery_company_code", "");
        appendHidden(form, "display_mode", "add");
        appendHidden(form, "source_page", "detail");
        appendHidden(form, "source_delivery_company_code", originalDeliveryCompanyCode.value || returnDeliveryCompanyCode.value || "");

        document.body.appendChild(form);
        form.submit();
    }

    function moveToEdit() {
        var form = createPostForm("./m_delivery_company_dt.cfm");

        appendHidden(form, "delivery_company_code", originalDeliveryCompanyCode.value);
        appendHidden(form, "return_delivery_company_code", originalDeliveryCompanyCode.value);
        appendHidden(form, "display_mode", "edit");
        appendHidden(form, "source_page", sourcePage.value || "list");
        appendHidden(form, "source_delivery_company_code", sourceDeliveryCompanyCode.value || "");

        document.body.appendChild(form);
        form.submit();
    }

    function cancelAction() {
        if (displayMode.value === "add") {
            if (sourcePage.value === "detail" && sourceDeliveryCompanyCode.value !== "") {
                moveToView(sourceDeliveryCompanyCode.value, "detail", sourceDeliveryCompanyCode.value);
            } else {
                moveToList();
            }
            return;
        }

        if (displayMode.value === "edit") {
            moveToView(originalDeliveryCompanyCode.value, sourcePage.value || "list", sourceDeliveryCompanyCode.value || "");
        }
    }

    async function saveDeliveryCompany() {
      var code = deliveryCompanyCode.value.trim();
      var name = deliveryCompanyName.value.trim();

      if (code === "") {
          showMessage("配送業者コードを入力してください。", "error");
          deliveryCompanyCode.focus();
          return;
      }

      if (name === "") {
          showMessage("配送業者名を入力してください。", "error");
          deliveryCompanyName.focus();
          return;
      }

      var confirmMessage = "";
      if (displayMode.value === "add") {
          confirmMessage = "登録します。よろしいですか？";
      } else {
          confirmMessage = "更新します。よろしいですか？";
      }

      var confirmResult = await Swal.fire({
          icon: "question",
          title: "確認",
          text: confirmMessage,
          showCancelButton: true,
          confirmButtonText: "はい",
          cancelButtonText: "キャンセル",
          reverseButtons: true
      });

      if (!confirmResult.isConfirmed) {
          return;
      }

      showLoading(true);

      try {
          var response = await fetch("./m_delivery_company_dt.cfc?method=saveDeliveryCompany&returnformat=json", {
              method: "POST",
              headers: {
                  "Content-Type": "application/json"
              },
              body: JSON.stringify({
                  original_delivery_company_code: originalDeliveryCompanyCode.value,
                  delivery_company_code: code,
                  delivery_company_name: name,
                  use_flag: useFlag.value,
                  note: note.value
              })
          });

          var data = await response.json();

          if (data.status !== undefined) {
              data.status = data.status;
              data.message = data.message;
              data.results = data.results;
          }

          if (data.status !== 0) {
              showMessage(data.message || "保存に失敗しました。", "error");
              return;
          }

          await Swal.fire({
              icon: "success",
              title: "完了",
              text: data.message || "保存しました。",
              confirmButtonText: "OK"
          });

          var savedCode = "";
          if (data.results && data.results.delivery_company_code) {
              savedCode = data.results.delivery_company_code;
          } else {
              savedCode = code;
          }

          moveToView(savedCode, sourcePage.value || "list", sourceDeliveryCompanyCode.value || "");
      } catch (error) {
          showMessage("保存中にエラーが発生しました。", "error");
      } finally {
          showLoading(false);
      }
  }

    async function deleteDeliveryCompany() {
        if (!originalDeliveryCompanyCode.value) {
            showMessage("配送業者コードが不正です。", "error");
            return;
        }

        var result = await Swal.fire({
            icon: "warning",
            title: "削除確認",
            text: "この配送業者を削除します。よろしいですか？",
            showCancelButton: true,
            confirmButtonText: "削除する",
            cancelButtonText: "キャンセル",
            reverseButtons: true
        });

        if (!result.isConfirmed) {
            return;
        }

        showLoading(true);

        try {
            var response = await fetch("./m_delivery_company_dt.cfc?method=deleteDeliveryCompany&returnformat=json", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    delivery_company_code: originalDeliveryCompanyCode.value
                })
            });

            var data = await response.json();

            if (data.status !== undefined) {
                data.status = data.status;
                data.message = data.message;
            }

            if (data.status !== 0) {
                showMessage(data.message || "削除に失敗しました。", "error");
                return;
            }

            await Swal.fire({
                icon: "success",
                title: "完了",
                text: data.message || "削除しました。",
                confirmButtonText: "OK"
            });

            moveToList();
        } catch (error) {
            showMessage("削除中にエラーが発生しました。", "error");
        } finally {
            showLoading(false);
        }
    }

    if (saveBtn) {
        saveBtn.addEventListener("click", saveDeliveryCompany);
    }

    var backButton = document.getElementById("back-btn");
    if (backButton) {
        backButton.addEventListener("click", function () {
            moveToList();
        });
    }

    var cancelButton = document.getElementById("cancel-button");
    if (cancelButton) {
        cancelButton.addEventListener("click", function () {
            cancelAction();
        });
    }

    var editButton = document.getElementById("edit-button");
    if (editButton) {
        editButton.addEventListener("click", function () {
            moveToEdit();
        });
    }

    var newButton = document.getElementById("add-button");
    if (newButton) {
        newButton.addEventListener("click", function () {
            moveToAddFromDetail();
        });
    }

    var trashButton = document.getElementById("trash-button");
    if (trashButton) {
        trashButton.addEventListener("click", function () {
            deleteDeliveryCompany();
        });
    }

    setUseFlagBadge();

    if (useFlag) {
        useFlag.addEventListener("change", setUseFlagBadge);
    }
});