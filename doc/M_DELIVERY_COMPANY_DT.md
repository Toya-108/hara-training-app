# 配送業者マスタ詳細（m_delivery_company_dt）

---

## 1. 概要

配送業者マスタの詳細表示・登録・修正・削除を行う画面。

本画面では以下を実現する。

* 配送業者情報の表示
* 新規登録
* 編集（更新）
* 削除
* 一覧画面への戻り
* 詳細画面起点の追加から元画面へ戻る制御

---

## 2. 対応ファイル

| 種別  | ファイル名                     |
| --- | ------------------------- |
| 画面  | m_delivery_company_dt.cfm |
| API | m_delivery_company_dt.cfc |
| JS  | m_delivery_company_dt.js  |

---

## 3. 画面モード

| モード  | 内容   |
| ---- | ---- |
| view | 表示専用 |
| edit | 編集   |
| add  | 新規登録 |

※ `display_mode` により制御する。

---

## 4. 機能一覧

### 4.1 表示機能

以下の項目を表示する。

* 配送業者コード
* 配送業者名
* 使用区分
* 備考

---

### 4.2 新規登録

* `display_mode = add`
* 一覧画面からの追加に対応
* 詳細画面からの追加にも対応

---

### 4.3 編集

* `display_mode = edit`
* 元の配送業者コードを保持したまま更新する

---

### 4.4 保存処理

API：

m_delivery_company_dt.cfc?method=saveDeliveryCompany

#### 処理フロー

1. 入力チェック
2. 確認ダイアログ表示
3. API実行
4. 保存後にviewモードへ遷移

---

### 4.5 削除処理

API：

m_delivery_company_dt.cfc?method=deleteDeliveryCompany

#### 処理フロー

1. 削除確認ダイアログ
2. API実行
3. 一覧へ戻る

---

### 4.6 戻り先制御

`source_page` と `source_delivery_company_code` により戻り先を制御する。

| source_page | 動作      |
| ----------- | ------- |
| list        | 一覧へ戻る   |
| detail      | 元の詳細へ戻る |

---

### 4.7 使用区分表示

| 値   | 表示  |
| --- | --- |
| 1   | 使用中 |
| その他 | 停止  |

表示用バッジを切り替える。

---

## 5. API仕様

### 5.1 保存API

m_delivery_company_dt.cfc?method=saveDeliveryCompany

#### リクエスト

```json id="dlvdtreq01"
{
  "original_delivery_company_code": "",
  "delivery_company_code": "",
  "delivery_company_name": "",
  "use_flag": "",
  "note": ""
}
```

#### レスポンス

```json id="dlvdtres01"
{
  "status": 0,
  "message": "保存しました。",
  "results": {
    "delivery_company_code": "DC001"
  }
}
```

---

### 5.2 削除API

m_delivery_company_dt.cfc?method=deleteDeliveryCompany

#### リクエスト

```json id="dlvdtreq02"
{
  "delivery_company_code": "DC001"
}
```

---

### 5.3 互換レスポンス対応

実装上、以下の大文字キー形式にも対応する。

```json id="dlvdtres02"
{
  "STATUS": 0,
  "MESSAGE": "OK",
  "RESULTS": {}
}
```

画面側で以下に正規化する。

* STATUS → status
* MESSAGE → message
* RESULTS → results

---

### 5.4 ステータス仕様

| status | 意味      |
| ------ | ------- |
| 0      | 正常      |
| 1      | 異常（エラー） |

---

## 6. 入力項目仕様

| 項目      | 必須 | 備考     |
| ------- | -- | ------ |
| 配送業者コード | 必須 | 一意     |
| 配送業者名   | 必須 |        |
| 使用区分    | 任意 | 1=使用中  |
| 備考      | 任意 | 複数行入力可 |

---

## 7. バリデーション

以下をチェックする。

* 配送業者コード 必須
* 配送業者名 必須

エラー時：

* 画面上部のメッセージエリアに表示
* 該当項目へフォーカスを移動

---

## 8. 状態管理

以下を保持する。

* ページ番号
* ソート条件
* 検索条件
* 遷移元画面
* 遷移元配送業者コード

hidden項目で管理する。

保持対象：

* return_page
* return_sort_field
* return_sort_order
* return_search_delivery_company_code
* return_search_delivery_company_name
* return_search_use_flag
* source_page
* source_delivery_company_code
* return_delivery_company_code

---

## 9. 主なJS処理

### 初期処理

* 要素取得
* 使用区分バッジ初期表示
* 各ボタンイベント登録

---

### メッセージ表示

```javascript id="dlvdtjs01"
function showMessage(message, type)
```

成功・失敗メッセージを画面内に表示する。

---

### ローディング表示

```javascript id="dlvdtjs02"
function showLoading(isShow)
```

保存・削除処理中のローディング表示を切り替える。

---

### 使用区分バッジ表示

```javascript id="dlvdtjs03"
function setUseFlagBadge()
```

* 1 → 使用中
* その他 → 停止

---

### 一覧戻り

```javascript id="dlvdtjs04"
function moveToList()
```

POSTで `m_delivery_company.cfm` に戻る。

---

### view遷移

```javascript id="dlvdtjs05"
function moveToView(targetCode, sourcePageValue, sourceDeliveryCompanyCodeValue)
```

保存後やキャンセル時にviewモードへ戻す。

---

### add遷移

```javascript id="dlvdtjs06"
function moveToAddFromDetail()
```

詳細画面から add モードへ遷移する。

---

### edit遷移

```javascript id="dlvdtjs07"
function moveToEdit()
```

現在のコードを保持して edit モードへ遷移する。

---

### キャンセル処理

```javascript id="dlvdtjs08"
function cancelAction()
```

* add かつ一覧起点 → 一覧へ戻る
* add かつ詳細起点 → 元の詳細へ戻る
* edit → 元のviewへ戻る

---

### 保存処理

```javascript id="dlvdtjs09"
async function saveDeliveryCompany()
```

主な処理：

* 必須チェック
* 確認ダイアログ
* API呼び出し
* 大文字レスポンス吸収
* 保存成功後にviewへ遷移

---

### 削除処理

```javascript id="dlvdtjs10"
async function deleteDeliveryCompany()
```

主な処理：

* コード存在チェック
* 確認ダイアログ
* API呼び出し
* 削除成功後に一覧へ戻る

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

* 対象コードのviewモードへ遷移

---

### 削除後

* 一覧へ戻る

---

### キャンセル時

* add：起点に応じて一覧または元の詳細へ戻る
* edit：元のviewへ戻る

---

## 11. エラーハンドリング

### 保存時

* status = 1 の場合はメッセージエリアに表示
* 通信エラー時は「保存中にエラーが発生しました。」を表示

---

### 削除時

* status = 1 の場合はメッセージエリアに表示
* 通信エラー時は「削除中にエラーが発生しました。」を表示

---

### 画面表示

* 一部エラーは SweetAlert ではなく画面上部メッセージエリアで表示する

---

## 12. 注意点

* `original_delivery_company_code` を更新対象の識別に使用する
* 大文字レスポンス形式にも対応している
* add画面のキャンセル時は遷移元に応じて戻り先が変わる
* 使用区分はselect値変更時に表示バッジも更新する
* エラーメッセージは画面内表示とダイアログ表示が混在しない設計になっている

---

## 13. 今後拡張候補

* コード重複チェック強化
* 使用区分の変更履歴管理
* 参照中データがある場合の削除制御
* 権限制御
* 入力チェック共通化

---
