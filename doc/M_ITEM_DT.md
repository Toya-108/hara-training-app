# 商品マスタ詳細（m_item_dt）

---

## 1. 概要

商品マスタの詳細表示・登録・修正・削除を行う画面。

本画面では以下を実現する。

* 商品情報の表示
* 新規登録
* 編集（更新）
* 削除
* 一覧画面への戻り（状態保持）

---

## 2. 対応ファイル

| 種別  | ファイル名         |
| --- | ------------- |
| 画面  | m_item_dt.cfm |
| API | m_item_dt.cfc |
| JS  | m_item_dt.js  |

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

* 商品コード
* JANコード
* 商品名
* 商品名カナ
* 原価
* 売価
* 分類
* 使用区分

---

### 4.2 新規登録

* display_mode = add
* 商品コード未設定状態で入力開始

---

### 4.3 編集

* display_mode = edit
* 商品コードを基準に更新

---

### 4.4 保存処理

API：

m_item_dt.cfc?method=saveItem

#### 処理フロー

1. 入力チェック
2. 確認ダイアログ表示
3. API実行
4. 成功後 viewモードへ遷移

---

### 4.5 削除処理

API：

m_item_dt.cfc?method=deleteItem

#### 処理フロー

1. 確認ダイアログ
2. API実行
3. 一覧へ戻る

---

### 4.6 戻る処理

戻り先は以下で制御。

| return_to | 動作      |
| --------- | ------- |
| list      | 一覧へ戻る   |
| detail    | 元の詳細へ戻る |

---

## 5. API仕様

### 5.1 保存API

m_item_dt.cfc?method=saveItem

#### リクエスト

```json
{
  "old_item_code": "",
  "item_code": "",
  "jan_code": "",
  "item_name": "",
  "item_name_kana": "",
  "gentanka": "",
  "baitanka": "",
  "item_category": "",
  "use_flag": ""
}
```

#### レスポンス

```json
{
  "status": 0,
  "message": "保存しました。",
  "results": {
    "item_code": "ITEM001"
  }
}
```

---

### 5.2 削除API

m_item_dt.cfc?method=deleteItem

#### リクエスト

```json
{
  "item_code": "ITEM001"
}
```

---

### 5.3 ステータス仕様

| status | 意味      |
| ------ | ------- |
| 0      | 正常      |
| 1      | 異常（エラー） |

---

## 6. 入力項目仕様

| 項目     | 必須 | 備考     |
| ------ | -- | ------ |
| 商品コード  | 必須 | 一意     |
| 商品名    | 必須 |        |
| JANコード | 任意 |        |
| 商品名カナ  | 任意 |        |
| 原価     | 任意 | 数値     |
| 売価     | 任意 | 数値     |
| 分類     | 任意 | select |
| 使用区分   | 任意 | 1=有効   |

---

## 7. バリデーション

以下をチェックする。

* 商品コード 必須
* 商品名 必須

エラー時：

* SweetAlertで表示
* フォーカスを該当項目へ移動

---

## 8. 状態管理

以下を保持する。

* 検索条件
* ソート条件
* ページ番号
* 遷移元（一覧 or 詳細）

hidden項目で管理する。

---

## 9. 主なJS処理

### 初期処理

* モード判定
* イベント登録
* レイアウト制御

---

### モード制御

```javascript
function applyModeLayout()
```

* view：入力不可
* edit/add：入力可能

---

### 保存処理

```javascript
async function saveItem()
```

---

### 削除処理

```javascript
async function deleteItem()
```

---

### 画面遷移

```javascript
moveToAdd()
moveToEdit()
moveBack()
moveToListByPost()
```

---

## 10. 画面遷移仕様

### 一覧 → 詳細

* viewモードで表示

---

### 詳細 → 編集

* editモードへ切替

---

### 詳細 → 新規

* addモードで新規入力

---

### 保存後

* viewモードへ戻る

---

### 削除後

* 一覧へ戻る

---

## 11. エラーハンドリング

### APIエラー

* status ≠ 0 の場合エラー
* SweetAlertで表示

---

### 通信エラー

* console.error出力
* エラーダイアログ表示

---

## 12. 注意点

* display_modeで画面状態を制御
* return_toで戻り先制御
* 商品コードは更新時のキー
* 保存後は必ずviewモードへ戻す
* 削除はviewモード時のみ可能

---

## 13. 今後拡張候補

* 重複チェック（商品コード）
* JANコード自動生成
* 原価→売価自動計算
* 入力チェック強化
* 権限制御（編集不可）

---
