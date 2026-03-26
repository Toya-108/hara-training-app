document.addEventListener('DOMContentLoaded', function () {
    var detailButton = document.getElementById('detail_button');
    var userMenu = document.getElementById('user_menu');
    var masterButton = document.getElementById('master_button');
    var masterModal = document.getElementById('master_modal');
    var closeModalButton = document.getElementById('close_modal_button');
    var logoutButton = document.getElementById('logout-button');
    var itemMasterButton = document.getElementById('item-master-button');
    var supplierMasterButton = document.getElementById('supplier-master-button');
    var staffMasterButton = document.getElementById('staff-master-button');
    var addSlipButton = document.getElementById('add_slip_button');

    detailButton.addEventListener('click', function () {
        if (userMenu.classList.contains('is-open')) {
            userMenu.classList.remove('is-open');
            detailButton.textContent = 'v';
        } else {
            userMenu.classList.add('is-open');
            detailButton.textContent = '∧'
        }
    });

    masterButton.addEventListener('click', function () {
        masterModal.classList.add('is-open');
    });

    closeModalButton.addEventListener('click', function () {
        masterModal.classList.remove('is-open');
    });

    masterModal.addEventListener('click', function (event) {
        if (event.target === masterModal) {
            masterModal.classList.remove('is-open');
        }
    });

    logoutButton.addEventListener('click', function(){
        location.href = 'login.cfm';
    });

    itemMasterButton.addEventListener('click', function(){
        location.href = 'm_item.cfm';
    });

    supplierMasterButton.addEventListener('click', function(){
        location.href = 'm_supplier.cfm';
    });

    staffMasterButton.addEventListener('click', function(){
        location.href = 'm_staff.cfm';
    });


    addSlipButton.addEventListener('click', function(){
        location.href = 'add_slip.cfm';
    });




});