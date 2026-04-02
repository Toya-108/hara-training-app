# TOTALREPORT（集計レポート）README

---

## 1. 概要

`total_report` は、伝票データを様々な切り口で集計・表示する画面である。

本画面の役割は以下の通り。

1. 条件を指定してデータを抽出
2. 集計区分に応じてグルーピング
3. サマリー（件数・数量・金額）を表示
4. テーブルで詳細を表示
5. CSVエクスポート

---

## 2. 対象ファイル構成

* total_report.cfm（画面）
* total_report.js（フロント処理）
* total_report.cfc（API）
* total_report_export.cfm（CSV出力）

---

## 3. 画面仕様

### 3.1 検索条件

| 項目      | 内容                    |
| ------- | --------------------- |
| 発注日     | FROM～TO               |
| 納品日     | FROM～TO               |
| 取引先     | プルダウン                 |
| 商品キーワード | 部分一致                  |
| 状態      | 登録 / 確定 / 削除          |
| 集計区分    | 日別 / 取引先別 / 商品別 / 状態別 |

---

### 3.2 ボタン

| ボタン    | 内容     |
| ------ | ------ |
| 🔍 集計  | データ取得  |
| ❌ クリア  | 条件リセット |
| エクスポート | CSV出力  |

---

### 3.3 サマリー

| 項目   | 内容 |
| ---- | -- |
| 伝票数  | 件数 |
| 合計数量 | 数量 |
| 合計金額 | 金額 |
| 集計行数 | 行数 |

---

### 3.4 テーブル

| 列    | 内容       |
| ---- | -------- |
| 集計キー | 区分によって変化 |
| 伝票数  | 件数       |
| 合計数量 | 数量       |
| 合計金額 | 金額       |

---

## 4. 集計区分仕様

| 区分       | group_key |
| -------- | --------- |
| day      | 日付        |
| supplier | 取引先       |
| item     | 商品        |
| status   | 状態        |

JS側で列名を動的変更する。

```javascript id="t1r5p9"
function updateGroupKeyLabel() {
    const value = reportType.value;

    if (value === "day") columnGroupKey.textContent = "日付";
    else if (value === "supplier") columnGroupKey.textContent = "取引先";
    else if (value === "item") columnGroupKey.textContent = "商品";
    else if (value === "status") columnGroupKey.textContent = "状態";
}
```

---

## 5. フロント処理（total_report.js）

### 5.1 初期処理

* flatpickr（日付）
* 初回検索実行
* ヘッダ名更新

```javascript id="m8y4zk"
searchReport();
```

---

### 5.2 検索処理

```javascript id="9z0h3k"
async function searchReport() {
    const params = getSearchParams();
    const formData = createFormData(params);

    const response = await fetch(
        "total_report.cfc?method=getTotalReport&returnformat=json",
        {
            method: "POST",
            body: formData
        }
    );
}
```

---

### 5.3 パラメータ

```json id="u82lka"
{
  "slip_date_from": "",
  "slip_date_to": "",
  "delivery_date_from": "",
  "delivery_date_to": "",
  "supplier_code": "",
  "item_keyword": "",
  "status": "",
  "report_type": "",
  "dashboard_mode": ""
}
```

---

### 5.4 描画処理

#### サマリー

```javascript id="z1pk2n"
renderSummary(data.summary, data.results.length);
```

#### テーブル

```javascript id="0dfqg3"
renderTable(data.results);
```

---

### 5.5 数値フォーマット

```javascript id="9xtv3o"
function formatCurrency(value) {
    return "¥" + Number(value || 0).toLocaleString();
}
```

---

### 5.6 クリア処理

```javascript id="h0kz3a"
clearButton.addEventListener("click", function () {
    document.getElementById("supplier_code").value = "";
    document.getElementById("item_keyword").value = "";
    document.getElementById("status").value = "";
    document.getElementById("report_type").value = "day";
});
```

---

### 5.7 エクスポート

```javascript id="k8v2x1"
exportForm.action = "total_report_export.cfm";
```

---

## 6. API仕様（total_report.cfc）

### 6.1 getTotalReport

#### 処理内容

* 条件に応じて抽出
* GROUP BYで集計
* サマリー算出

#### 戻り値

```json id="v2m9as"
{
  "status": 0,
  "summary": {
    "total_slip_count": 0,
    "total_qty": 0,
    "total_amount": 0
  },
  "results": [
    {
      "group_key": "",
      "slip_count": 0,
      "total_qty": 0,
      "total_amount": 0
    }
  ]
}
```

---

## 7. CSVエクスポート（total_report_export.cfm）

### 7.1 処理内容

* 同条件で再取得
* CSV形式で出力
* ファイル名に日時付与

---

## 8. UX仕様

### 8.1 ローディング

```javascript id="j3m2xk"
setLoading(true);
```

---

### 8.2 エラー

* warning：業務エラー
* error：通信エラー

---

### 8.3 初期表示

```javascript id="x9l3pz"
searchReport();
```

👉 初回ロードで自動検索

---

## 9. 設計思想

* AJAX（fetch + async/await）
* FormDataで送信
* JSONレスポンス
* DOM操作で描画

---

## 10. 注意点

* HTMLエスケープ必須
* 数値はNumber変換
* null対策
* GROUP BYはreport_type依存

---

## 11. 今後の拡張

### 業務系

* 月次・年次集計
* 在庫連動
* 粗利表示

### UX

* ソート機能
* ページング
* 条件保存

---

## 12. まとめ

この画面は

* 分析
* 可視化
* 意思決定

に直結する重要機能である。

そのため、

* 正確性
* 見やすさ
* 操作性

を最優先とする。

---
