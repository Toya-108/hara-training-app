document.addEventListener("DOMContentLoaded", function () {
    var fileInput = document.getElementById("csv_file");
    var receiveButton = document.getElementById("receive_button");
    var resultArea = document.getElementById("receive_result");
    var historyBody = document.getElementById("receive_history_body");
    var homeBtn = document.getElementById("home-btn");

    if (!fileInput || !receiveButton || !resultArea) {
        return;
    }

    function showResult(message, isSuccess) {
        resultArea.textContent = message;
        resultArea.className = "receive-result";

        if (isSuccess) {
            resultArea.classList.add("is-success");
        } else {
            resultArea.classList.add("is-error");
        }
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

    async function loadHistory() {
        if (!historyBody) {
            return;
        }

        historyBody.innerHTML = "<tr><td colspan='5' class='history-empty'>読み込み中です...</td></tr>";

        try {
            var response = await fetch("./slip_receive.cfc?method=getReceiveHistory&returnformat=json", {
                method: "GET"
            });

            var result = await response.json();

            if (result.status !== 0) {
                historyBody.innerHTML = "<tr><td colspan='5' class='history-empty'>履歴の取得に失敗しました。</td></tr>";
                return;
            }

            if (!result.results || result.results.length === 0) {
                historyBody.innerHTML = "<tr><td colspan='5' class='history-empty'>履歴はまだありません。</td></tr>";
                return;
            }

            var html = "";

            result.results.forEach(function (row) {
                var statusText = Number(row.success_flag) === 1 ? "成功" : "失敗";
                var statusClass = Number(row.success_flag) === 1 ? "history-success" : "history-error";

                html += ""
                    + "<tr>"
                    + "<td>" + escapeHtml(row.receive_datetime) + "</td>"
                    + "<td>" + escapeHtml(row.slip_count) + "</td>"
                    + "<td>" + escapeHtml(row.detail_count) + "</td>"
                    + "<td>" + escapeHtml(row.item_count) + "</td>"
                    + "<td class='" + statusClass + "'>" + statusText + "</td>"
                    + "</tr>";
            });

            historyBody.innerHTML = html;

        } catch (error) {
            historyBody.innerHTML = "<tr><td colspan='5' class='history-empty'>履歴の取得中にエラーが発生しました。</td></tr>";
        }
    }

    receiveButton.addEventListener("click", async function () {
        var file = fileInput.files[0];

        if (!file) {
            await Swal.fire({
                icon: "warning",
                title: "CSVファイル未選択",
                text: "CSVファイルを選択してください。",
                confirmButtonText: "OK"
            });
            return;
        }

        var confirmResult = await Swal.fire({
            icon: "question",
            title: "伝票受信確認",
            text: "選択したCSVファイルを受信します。よろしいですか？",
            showCancelButton: true,
            confirmButtonText: "はい",
            cancelButtonText: "キャンセル",
            reverseButtons: true
        });

        if (!confirmResult.isConfirmed) {
            return;
        }

        receiveButton.disabled = true;
        resultArea.className = "receive-result";
        resultArea.textContent = "";

        try {
            var formData = new FormData();
            formData.append("csv_file", file);

            var response = await fetch("./slip_receive.cfc?method=importSlipCsv&returnformat=json", {
                method: "POST",
                body: formData
            });

            var result = await response.json();

            if (result.status === 0) {
                showResult(result.message, true);

                await Swal.fire({
                    icon: "success",
                    title: "受信完了",
                    text: result.message,
                    confirmButtonText: "OK"
                });

                fileInput.value = "";
                await loadHistory();
            } else {
                showResult(result.message, false);

                await Swal.fire({
                    icon: "error",
                    title: "受信失敗",
                    text: result.message,
                    confirmButtonText: "OK"
                });

                await loadHistory();
            }
        } catch (error) {
            showResult("伝票受信中に通信エラーが発生しました。", false);

            await Swal.fire({
                icon: "error",
                title: "通信エラー",
                text: "伝票受信中に通信エラーが発生しました。",
                confirmButtonText: "OK"
            });

            await loadHistory();
        } finally {
            receiveButton.disabled = false;
        }
    });

    if (homeBtn) {
        homeBtn.addEventListener("click", function () {
            location.href = "menu.cfm";
        });
    }

    loadHistory();
});