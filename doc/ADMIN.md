# 📘 ADMIN.md（基本設定画面仕様書）

---

## 1. 概要

`admin_setting` は、Hara LogiApp の基本設定を管理する画面である。

この画面の役割は以下の2つ。

1. 会社情報・拠点情報の登録・更新
2. システムの基本設定の管理

---

## 2. 対象ファイル構成

本画面は以下の3ファイルで構成する。

- admin_setting.cfm（画面）
- admin_setting.cfc（API）
- admin_setting.js（制御・入力チェック・保存処理）

---

## 3. 画面構成

### 3.1 入力項目

| 項目 | ID |
|------|----|
| 会社コード | company_code |
| 会社名 | company_name |
| センター名 | center_name |
| 郵便番号 | postal_code |
| 住所1 | address1 |
| 住所2 | address2 |
| 電話番号 | tel_no |
| FAX番号 | fax_no |
| メモ | memo |
| 管理者パスワード | admin_password |

---

### 3.2 ヘッダーボタン

| ボタン | ID | 内容 |
|--------|----|------|
| 戻る | back-btn | メニューへ戻る |
| 修正 | edit-button | 編集モードへ |
| キャンセル | cancel-button | 表示モードへ |

---

### 3.3 保存ボタン

| ボタン | ID |
|--------|----|
| 保存 | save_btn |

---

## 4. 表示モード

本画面は以下の2モードを持つ。

| モード | 内容 |
|--------|------|
| view | 表示専用 |
| edit | 編集可能 |

---

## 5. 処理フロー

1. 画面表示（viewモード）
2. 修正ボタン押下 → editモードへ
3. 入力
4. 保存ボタン押下
5. 確認ダイアログ表示
6. API通信
7. 成功 → viewモードへ戻る
8. 失敗 → エラー表示

---

## 6. JavaScript仕様

### 6.1 初期処理

- display_modeを取得
- view / edit の判定

---

### 6.2 モード制御

moveToEdit()

- editモードへ遷移

moveToView()

- viewモードへ遷移

---

### 6.3 画面遷移

submitPost("admin_setting.cfm", { display_mode: "edit" });

submitPost("admin_setting.cfm", { display_mode: "view" });

---

### 6.4 入力チェック

チェック内容：

- 会社コード必須
- 会社名必須

不正時：

- SweetAlert2でエラー表示
- 該当項目へフォーカス

---

### 6.5 保存処理

fetch("/training/hara/admin_setting.cfc?method=saveBasicSetting&returnformat=json")

送信内容：

- company_code
- company_name
- center_name
- postal_code
- address1
- address2
- tel_no
- fax_no
- memo
- admin_password

---

### 6.6 確認ダイアログ

保存前に確認を表示：

- 「保存しますか？」
- OK / キャンセル

---

### 6.7 成功時処理

- 成功メッセージ表示
- viewモードへ戻る

---

### 6.8 エラー処理

- エラーメッセージ表示
- コンソール出力

---

### 6.9 ローディング制御

showLoading(true)

- ローディング表示

showLoading(false)

- 非表示

---

## 7. API仕様（admin_setting.cfc）

メソッド：

saveBasicSetting

---

### リクエスト

JSON形式で送信

- company_code
- company_name
- center_name
- postal_code
- address1
- address2
- tel_no
- fax_no
- memo
- admin_password

---

### レスポンス

成功時：

{
    "status": 0,
    "message": "保存しました。"
}

失敗時：

{
    "status": 1,
    "message": "エラーメッセージ"
}

---

## 8. ユーザー操作仕様

### 8.1 初期表示

- viewモードで表示

---

### 8.2 編集

- 修正ボタン押下でeditモードへ

---

### 8.3 保存

- 保存ボタン押下
- 確認ダイアログ表示
- OKで保存

---

### 8.4 キャンセル

- 編集内容を破棄してviewへ戻る

---

### 8.5 戻る

- メニュー画面へ遷移

---

## 9. UI/UX仕様

- 入力フォームは縦並び
- 必須項目は明確に表示
- ボタンは緑ベース（#3F5B4B）
- SweetAlert2で統一されたUI

---

## 10. 設計方針

本画面は以下を重視する。

- シンプルで分かりやすい入力画面
- モード切替による誤操作防止
- confirm付き保存処理
- async / awaitによる非同期通信

---

## 11. 補足

基本設定はシステム全体に影響するため、

- 誤入力防止
- 明確な確認処理
- 安全な更新処理

を最優先とする。

パスワードは、伝票の一括確定をするのに使用される。(用途は増える可能性あり)  
また、パスワードはBcryingによるハッシュ化を行った後、データベースに挿入される。