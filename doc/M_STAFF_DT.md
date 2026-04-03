# 社員マスタ詳細（m_staff_dt）

---

## 1. 概要

社員マスタの詳細表示・登録・修正・削除を行う画面。

本画面では以下を実現する。

* 社員情報の表示
* 新規登録
* 編集（更新）
* 削除
* パスワード管理
* 一覧画面への戻り（状態保持）

---

## 2. 対応ファイル

| 種別  | ファイル名          |
| --- | -------------- |
| 画面  | m_staff_dt.cfm |
| API | m_staff_dt.cfc |
| JS  | m_staff_dt.js  |

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

* 社員コード
* 社員名
* 社員名カナ
* メールアドレス
* 電話番号
* 権限区分
* 使用区分
* 備考

---

### 4.2 新規登録

* display_mode = add
* パスワード入力必須

---

### 4.3 編集

* display_mode = edit
* パスワード変更は任意

---

### 4.4 保存処理

API：

m_staff_dt.cfc?method=saveStaff

#### 処理フロー

1. 入力チェック
2. 確認ダイアログ
3. API実行
4. viewモードへ遷移

---

### 4.5 削除処理

API：

m_staff_dt.cfc?method=deleteStaff

#### 処理フロー

1. 確認ダイアログ
2. API実行
3. 一覧へ戻る

---

## 5. API仕様

### 5.1 保存API

m_staff_dt.cfc?method=saveStaff

#### リクエスト

```json id="ksy2mq"
{
  "original_staff_code": "",
  "staff_code": "",
  "staff_name": "",
  "staff_kana": "",
  "login_password": "",
  "login_password_confirm": "",
  "authority_level": "",
  "mail_address": "",
  "tel_no": "",
  "use_flag": "",
  "note": ""
}
```

#### レスポンス

```json id="0t7uxg"
{
  "status": 0,
  "message": "保存しました。",
  "results": {
    "staff_code": "001"
  }
}
```

---

### 5.2 削除API

m_staff_dt.cfc?method=deleteStaff

#### リクエスト

```json id="xgj84q"
{
  "staff_code": "001"
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

| 項目      | 必須     | 備考    |
| ------- | ------ | ----- |
| 社員コード   | 必須     | 一意    |
| 社員名     | 必須     |       |
| 社員名カナ   | 任意     |       |
| メールアドレス | 任意     |       |
| 電話番号    | 任意     |       |
| パスワード   | 条件付き必須 | 新規時必須 |
| パスワード確認 | 条件付き必須 | 一致必須  |
| 権限区分    | 任意     |       |
| 使用区分    | 任意     |       |
| 備考      | 任意     |       |

---

## 7. バリデーション

以下をチェックする。

### 必須チェック

* 社員コード
* 社員名

---

### パスワードチェック

#### 新規登録時

* パスワード必須
* パスワード確認必須
* 一致チェック

#### 編集時

* 入力された場合のみ一致チェック

---

### エラー時

* SweetAlert表示
* フォーカス移動

---

## 8. 状態管理

以下を保持する。

* 検索条件
* ソート条件

hidden項目で管理する。

---

## 9. 主なJS処理

### 初期処理

* モード判定
* イベント登録
* レイアウト制御
* 権限・使用区分表示設定

---

### モード制御

```javascript id="r8r6cx"
function applyModeLayout()
```

* view：入力不可
* edit/add：入力可

---

### 保存処理

```javascript id="m7sn2j"
async function saveStaff()
```

---

### 削除処理

```javascript id="k8qzjz"
async function deleteStaff()
```

---

### 画面遷移

```javascript id="p8vwr4"
moveToAdd()
moveToEdit()
moveToView()
moveToListByPost()
```

---

### 権限表示変換

```javascript id="xskdzp"
function setAuthorityLevel(level)
```

---

### 使用区分表示

```javascript id="a8tzht"
function setUseFlag(flag)
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

### 通信エラー

* console.error出力
* ダイアログ表示

---

## 12. 注意点

* original_staff_codeで更新対象管理
* パスワードは新規時必須
* 削除はviewモードのみ
* addモードでは削除不可
* 権限・使用区分は表示変換あり

---

## 13. 今後拡張候補

* パスワード強度チェック
* メールアドレスバリデーション強化
* 権限による画面制御
* ログイン連携
* 操作履歴管理

---
