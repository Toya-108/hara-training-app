# 伝票一覧（slip_list）

---

## 1. 概要

伝票の一覧表示・検索・ソート・ページング・一括確定・CSV出力を行う画面。

本画面では以下を実現する：

* 伝票の検索・絞り込み
* 一覧表示
* 詳細画面への遷移
* 一括確定処理
* CSVエクスポート

---

## 2. 対応ファイル

| 種別    | ファイル名                |
| ----- | -------------------- |
| 画面    | slip_list.cfm        |
| API   | slip_list.cfc        |
| JS    | slip_list.js         |
| CSV出力 | slip_list_export.cfm |

---

## 3. 機能一覧

### 3.1 検索機能

以下の条件で検索可能

* 伝票番号
* 発注日（From / To）
* 納品日（From / To）
* 取引先コード
* 取引先名（あいまい検索）
* 商品（JAN / 名称）
* ステータス（登録 / 確定 / 削除）

---

### 3.2 Enterキーによるフォーカス移動

* Enter押下で次の検索項目へ移動
* 最後の項目で検索実行
* IME変換中は無視

---

### 3.3 一覧表示

表示項目：

* 伝票番号
* 発注日
* 納品日
* 取引先（コード + 名称）
* 合計数量
* ステータス

ステータス表示：

| 値 | 表示 |
| - | -- |
| 1 | 登録 |
| 2 | 確定 |
| 3 | 削除 |

---

### 3.4 行クリック → 詳細画面遷移

* 行クリックで詳細画面へ遷移
* POST送信で値を引き継ぐ

保持される内容：

* 検索条件
* ページ番号
* ソート条件

---

### 3.5 ソート機能

* カラムクリックでソート
* 状態遷移：

未指定 → 昇順 → 降順 → 未指定

---

### 3.6 ページング

* 1ページ50件
* 操作ボタン

  * 最初
  * 前へ
  * 次へ
  * 最後

---

### 3.7 CSVエクスポート

検索条件を保持したままCSV出力

```javascript
window.location.href = "slip_list_export.cfm?" + params.toString();
```

---

### 3.8 一括確定機能

検索結果に対して一括確定を実行

#### 処理フロー

1. 対象件数チェック
2. パスワード入力
3. 確認ダイアログ
4. API実行
5. 再検索

#### 対象条件

* ステータス = 登録のみ

#### 実行API

slip_list.cfc?method=bulkConfirmSlips

---

## 4. API仕様

### 4.1 一覧取得

slip_list.cfc?method=getSlipList

#### リクエスト

```json
{
  "page": 1,
  "pageSize": 50,
  "search_slip_no": "",
  "search_order_date_from": "",
  "search_order_date_to": "",
  "search_delivery_date_from": "",
  "search_delivery_date_to": "",
  "search_supplier_code": "",
  "search_supplier_keyword": "",
  "search_item_keyword": "",
  "search_status": "",
  "sortField": "",
  "sortOrder": ""
}
```

#### レスポンス

```json
{
  "status": 0,
  "results": [],
  "paging": {
    "page": 1,
    "totalPage": 10,
    "totalCount": 500
  }
}
```

---

### 4.2 一括確定

slip_list.cfc?method=bulkConfirmSlips

#### リクエスト

```json
{
  "password": "xxxx",
  "search_slip_no": "",
  "search_order_date_from": "",
  "search_order_date_to": "",
  "search_delivery_date_from": "",
  "search_delivery_date_to": "",
  "search_supplier_code": "",
  "search_supplier_keyword": "",
  "search_item_keyword": "",
  "search_status": ""
}
```

---

## 5. 状態保持（重要）

一覧 → 詳細 → 戻る時に保持される：

* 検索条件
* ページ番号
* ソート条件

hidden項目で管理する。

---

## 6. 主なJS処理

### 初期処理

* 日付ピッカー設定
* イベントバインド
* 状態復元
* データ取得

---

### データ取得

```javascript
async function loadSlipList(page)
```

* API呼び出し
* テーブル描画
* ページング更新

---

### テーブル描画

```javascript
function renderSlipTable(list)
```

---

### 詳細遷移

```javascript
function moveToDetailByPost(slipNo)
```

---

### 一括確定

```javascript
async function bulkConfirmSlips()
```

---

## 7. エラーハンドリング

* APIエラー時
  → テーブルにエラーメッセージ表示

* 一括確定失敗時
  → SweetAlertで通知

---

## 8. 注意点

* Enterキーで検索実行しない（誤操作防止）
* IME変換中のEnterは無視
* ソートは3段階制御
* 一括確定はパスワード必須

---

## 9. 今後拡張候補

* チェックボックス選択による部分確定
* 複数条件ソート
* CSV出力項目の選択
* 無限スクロール対応

---
