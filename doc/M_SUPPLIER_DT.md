# 取引先マスタ詳細（m_supplier_dt）

---

## 1. 概要

取引先マスタの詳細表示・登録・修正・削除を行う画面。

本画面では以下を実現する。

* 取引先情報の表示
* 新規登録
* 編集（更新）
* 削除
* 郵便番号から住所自動入力
* 一覧画面への戻り（状態保持）

---

## 2. 対応ファイル

| 種別  | ファイル名             |
| --- | ----------------- |
| 画面  | m_supplier_dt.cfm |
| API | m_supplier_dt.cfc |
| JS  | m_supplier_dt.js  |

---

## 3. 画面モード

| モード  | 内容   |
| ---- | ---- |
| view | 表示専用 |
| edit | 編集   |
| add  | 新規登録 |

※ `display_mode` により制御

---

## 4. 機能一覧

### 4.1 表示機能

以下の項目を表示する。

* 取引先コード
* 取引先名
* 取引先名カナ
* 郵便番号
* 都道府県
* 住所1
* 住所2
* 電話番号
* FAX番号
* 配送業者
* 備考
* 使用区分

---

### 4.2 新規登録

* display_mode = add
* 初期値は空

---

### 4.3 編集

* display_mode = edit
* supplier_id をキーに更新

---

### 4.4 保存処理

API：

m_supplier_dt.cfc?method=saveSupplier

#### 処理フロー

1. 入力チェック
2. 確認ダイアログ
3. API実行
4. viewモードへ遷移

---

### 4.5 削除処理

API：

m_supplier_dt.cfc?method=deleteSupplier

#### 処理フロー

1. 確認ダイアログ
2. API実行
3. 一覧へ戻る

---

### 4.6 郵便番号自動入力

郵便番号入力時に住所を自動補完する。

API：

m_supplier_dt.cfc?method=lookupZipcode

#### トリガー

* blur時
* Enter押下時

#### 補完項目

* 郵便番号（整形）
* 都道府県コード
* 住所1

---

## 5. API仕様

### 5.1 保存API

m_supplier_dt.cfc?method=saveSupplier

#### リクエスト

```json
{
  "supplier_id": 0,
  "supplier_code": "",
  "supplier_name": "",
  "supplier_name_kana": "",
  "zip_code": "",
  "prefecture_code": "",
  "address1": "",
  "address2": "",
  "tel": "",
  "fax": "",
  "delivery_company_code": "",
  "note": "",
  "use_flag": ""
}
```

#### レスポンス

```json
{
  "status": 0,
  "message": "保存しました。",
  "results": {
    "supplier_code": "SUP001"
  }
}
```

---

### 5.2 削除API

m_supplier_dt.cfc?method=deleteSupplier

#### リクエスト

```json
{
  "supplier_id": 1
}
```

---

### 5.3 郵便番号検索API

m_supplier_dt.cfc?method=lookupZipcode

#### リクエスト

```json
{
  "zip_code": "1234567"
}
```

---

### 5.4 ステータス仕様

| status | 意味      |
| ------ | ------- |
| 0      | 正常      |
| 1      | 異常（エラー） |

---

## 6. 入力項目仕様

| 項目     | 必須 | 備考     |
| ------ | -- | ------ |
| 取引先コード | 必須 | 一意     |
| 取引先名   | 必須 |        |
| 取引先名カナ | 任意 |        |
| 郵便番号   | 任意 | 7桁     |
| 都道府県   | 任意 | select |
| 住所1    | 任意 |        |
| 住所2    | 任意 |        |
| 電話番号   | 任意 |        |
| FAX    | 任意 |        |
| 配送業者   | 任意 |        |
| 備考     | 任意 |        |
| 使用区分   | 任意 | 1=有効   |

---

## 7. バリデーション

以下をチェックする。

* 取引先コード 必須
* 取引先名 必須

エラー時：

* SweetAlert表示
* フォーカス移動

---

## 8. 状態管理

以下を保持する。

* 検索条件
* ソート条件
* ページ番号

hidden項目で管理する。

---

## 9. 主なJS処理

### 初期処理

* モード判定
* イベント登録
* レイアウト制御
* 使用区分表示設定

---

### モード制御

```javascript
function applyModeLayout()
```

* view：入力不可・削除ボタン表示
* edit/add：入力可・削除ボタン非表示

---

### 保存処理

```javascript
async function saveSupplier()
```

---

### 削除処理

```javascript
async function deleteSupplier()
```

---

### 郵便番号検索

```javascript
async function lookupZipcodeAndFill()
```

---

### 画面遷移

```javascript
moveToAdd()
moveToEdit()
moveToListByPost()
```

---

## 10. 画面遷移仕様

### 一覧 → 詳細

* viewモード

---

### 詳細 → 編集

* editモード

---

### 詳細 → 新規

* addモード

---

### 保存後

* viewモードへ遷移

---

### 削除後

* 一覧へ戻る

---

## 11. エラーハンドリング

### API

* status ≠ 0 → エラー
* message表示

---

### 郵便番号検索

* エラー時はアラート表示

---

### 通信エラー

* console.error出力
* エラーダイアログ表示

---

## 12. 注意点

* supplier_id で内部管理
* supplier_code は業務キー
* 郵便番号はハイフン付きに整形
* 削除はviewモードのみ
* addモードでは削除不可
* 使用区分は表示用変換あり

---

## 13. 今後拡張候補

* 郵便番号APIの外部連携
* 入力補助（電話番号フォーマット）
* 配送業者マスタ連携強化
* 重複チェック（コード）
* 権限制御

---
