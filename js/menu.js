document.addEventListener("DOMContentLoaded", function () {
    const detailButton = document.getElementById("detail_button");
    const userMenu = document.getElementById("user_menu");
    const arrowIcon = detailButton ? detailButton.querySelector(".arrow-icon") : null;
    const logoutButton = document.getElementById("logout-button");

    const addSlipButton = document.getElementById("add_slip_button");
    const masterButton = document.getElementById("master_button");
    const masterModal = document.getElementById("master_modal");
    const closeModalButton = document.getElementById("close_modal_button");

    const itemMasterButton = document.getElementById("item-master-button");
    const supplierMasterButton = document.getElementById("supplier-master-button");
    const staffMasterButton = document.getElementById("staff-master-button");

    const slipListButton = document.getElementById('slip_list_button');

    if (detailButton && userMenu && arrowIcon) {
        detailButton.addEventListener("click", function () {
            if (userMenu.classList.contains("is-open")) {
                userMenu.classList.remove("is-open");
                arrowIcon.src = arrowIcon.dataset.down;
                arrowIcon.classList.remove("arrow-up-icon");
                arrowIcon.classList.add("arrow-down-icon");
            } else {
                userMenu.classList.add("is-open");
                arrowIcon.src = arrowIcon.dataset.up;
                arrowIcon.classList.remove("arrow-down-icon");
                arrowIcon.classList.add("arrow-up-icon");
            }
        });
    }

    if (logoutButton) {
        logoutButton.addEventListener("click", function () {
            location.href = "login.cfm";
        });
    }

    if (addSlipButton) {
        addSlipButton.addEventListener("click", function () {
            location.href = "add_slip.cfm";
        });
    }

    if (slipListButton) {
        slipListButton.addEventListener("click", function () {
            location.href = "slip_list.cfm";
        });
    }

    if (masterButton && masterModal) {
        masterButton.addEventListener("click", function (e) {
            if (masterButton.classList.contains("disabled-button")) {
                e.preventDefault();
                e.stopPropagation();
                return;
            }

            masterModal.classList.add("is-open");
        });
    }

    if (closeModalButton && masterModal) {
        closeModalButton.addEventListener("click", function () {
            masterModal.classList.remove("is-open");
        });
    }

    if (masterModal) {
        masterModal.addEventListener("click", function (e) {
            if (e.target === masterModal) {
                masterModal.classList.remove("is-open");
            }
        });
    }

    if (itemMasterButton) {
        itemMasterButton.addEventListener("click", function () {
            location.href = "m_item.cfm";
        });
    }

    if (supplierMasterButton) {
        supplierMasterButton.addEventListener("click", function () {
            location.href = "m_supplier.cfm";
        });
    }

    if (staffMasterButton) {
        staffMasterButton.addEventListener("click", function () {
            location.href = "m_staff.cfm";
        });
    }
});