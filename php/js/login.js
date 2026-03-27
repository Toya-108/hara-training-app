document.addEventListener("DOMContentLoaded", function () {
    const app = Vue.createApp({
        data() {
            return {
                input_form: {
                    staff_code: '',
                    password: ''
                },
                show_password_flag: false,
                loading_flag: false
            };
        },

        methods: {
            login_button_click() {
                if (this.input_form.staff_code === '') {
                    this.show_alert('ユーザー名を入力してください', 'warning');
                    return;
                }

                if (this.input_form.password === '') {
                    this.show_alert('パスワードを入力してください', 'warning');
                    return;
                }

                this.login_process();
            },

            login_process() {
                this.loading_flag = true;

                const form_data = new FormData();
                form_data.append('staff_code', this.input_form.staff_code);
                form_data.append('password', this.input_form.password);

                fetch('api/login_api.php', {
                    method: 'POST',
                    body: form_data
                })
                .then(response => response.json())
                .then(result => {
                    if (Number(result.status) === 1) {
                        location.href = 'menu.php';
                    } else {
                        this.show_alert(result.message, 'error');
                    }
                })
                .catch(() => {
                    this.show_alert('通信エラー', 'error');
                })
                .finally(() => {
                    this.loading_flag = false;
                });
            },

            show_alert(message, icon) {
                Swal.fire({
                    text: message,
                    icon: icon,
                    confirmButtonText: 'OK'
                });
            }
        }
    });

    app.mount('#login_app');
});