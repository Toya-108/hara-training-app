# 伝票詳細（slip_list_dt）

---

## 1. 概要

伝票の詳細表示・編集・保存を行う画面。

本画面では以下を実現する：

* 伝票ヘッダ情報の表示
* 明細の表示
* 編集モード切替
* 明細の編集
* 保存処理
* 一覧画面への戻り（状態保持）

---

## 2. 対応ファイル

| 種別  | ファイル名            |
| --- | ---------------- |
| 画面  | slip_list_dt.cfm |
| API | slip_list_dt.cfc |
| JS  | slip_list_dt.js  |

---

## 3. 画面モード

| モード  | 内容   |
| ---- | ---- |
| view | 表示専用 |
| edit | 編集可能 |

※ `detail_display_mode` で制御

---

## 4. 機能一覧

### 4.1 詳細取得

画面初期表示時に伝票詳細を取得

API：

slip_list_dt.cfc?method=getSlipDetail

---

### 4.2 ヘッダ表示

表示項目：

* 伝票番号
* ステータス
* 発注日
* 納品日
* 取引先コード
* 取引先名
* 合計数量
* 合計金額
* メモ
* 作成日時
* 更新日時

---

### 4.3 明細表示

表示項目：

* 行番号
* 商品コード
* JANコード
* 商品名
* 数量
* 単価
* 金額

---

### 4.4 編集モード

編集可能項目：

* 発注日
* 納品日
* 取引先コード
* メモ
* 明細（数量・単価）

---

### 4.5 商品コード入力補完

商品コード入力後（blur時）に自動取得

API：

slip_list_dt.cfc?method=getItemByCode

取得内容：

* JANコード
* 商品名
* 単価

---

### 4.6 合計計算

リアルタイム更新：

* 明細金額 = 数量 × 単価
* 合計数量
* 合計金額

---

### 4.7 保存処理

API：

slip_list_dt.cfc?method=saveSlipDetail

#### 処理フロー

1. 入力チェック
2. 確認ダイアログ
3. API実行
4. 成功後 viewモードへ

---

### 4.8 一覧へ戻る

* 編集中は確認ダイアログ表示
* 状態を保持して戻る

保持内容：

* 検索条件
* ページ番号
* ソート条件

---

## 5. API仕様

### 5.1 詳細取得

slip_list_dt.cfc?method=getSlipDetail

#### リクエスト

```json
{
  "slip_no": "伝票番号"
}
```

#### レスポンス

```json
{
  "status": 0,
  "header": {},
  "details": []
}
```

---

### 5.2 商品取得

slip_list_dt.cfc?method=getItemByCode

#### リクエスト

```json
{
  "item_code": "商品コード"
}
```

---

### 5.3 保存

slip_list_dt.cfc?method=saveSlipDetail

#### リクエスト

```json
{
  "slip_no": "",
  "status": "",
  "slip_date": "",
  "delivery_date": "",
  "supplier_code": "",
  "memo": "",
  "details": []
}
```

---

## 6. 主なJS処理

### 初期処理

* モード判定
* 日付ピッカー設定
* イベント登録
* 詳細取得

---

### 詳細取得

```javascript
function loadSlipDetail()
```

---

### 明細描画

```javascript
function renderDetailTableView(details)
function renderDetailTableEdit(details)
```

---

### 商品補完

```javascript
async function lookupItemByCode(input)
```

---

### 合計更新

```javascript
function updateTotals()
```

---

### 保存処理

```javascript
async function saveSlip()
```

---

## 7. バリデーション

チェック項目：

* 発注日 必須
* 納品日 必須
* 取引先コード 必須
* 明細 必須

---

## 8. エラーハンドリング

* APIエラー → SweetAlert表示
* 商品未存在 → 警告表示
* 保存失敗 → エラーダイアログ

---

## 9. 注意点

* 編集モード中は戻る時に確認表示
* 商品コード変更で自動補完
* 数値は自動で0変換
* カンマ区切り表示対応
* 状態はPOSTで保持

---
