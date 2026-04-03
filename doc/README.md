# 伝票管理アプリケーション（Hara LogiApp）

---

## 1. 概要

本アプリは、物流業務および業務管理を目的としたWebアプリケーションである。

主に以下の業務を対象とする。

* 伝票管理（登録・一覧・詳細・確定・削除）
* 在庫管理
* マスタ管理（商品・取引先・社員・配送業者）
* 集計レポート
* 各種データのエクスポート

---

## 2. 主な機能

### ■ 伝票管理

* 伝票登録（add_slip）
* 伝票一覧（検索・ソート・ページング）
* 伝票詳細（閲覧・修正）
* 一括確定 / 個別確定
* CSVエクスポート

### ■ 在庫管理

* 在庫一覧表示
* 在庫調整
* 伝票確定時に在庫へ反映

### ■ マスタ管理

* 商品マスタ
* 取引先マスタ
* 社員マスタ
* 配送業者マスタ

（一覧・詳細・追加・修正・削除 共通仕様）

### ■ 集計レポート

* 日別集計
* 取引先別集計
* 商品別集計
* CSVエクスポート

### ■ 管理機能

* 管理者設定（admin_setting）
* ダウンロード履歴管理

---

## 3. 技術構成

* ColdFusion（CFML）
* MySQL
* JavaScript（Vanilla）
* SweetAlert2
* Flatpickr（日付UI）
* Shell（CSVエクスポート）

---

## 4. ディレクトリ構成

```text
/
├── Application.cfc        … アプリケーション設定
├── init.cfm               … 初期処理

├── header.cfm             … 共通ヘッダー

├── login.cfm / login.cfc  … ログイン

├── menu.cfm / menu.cfc    … メニュー

├── add_slip.*             … 伝票登録
├── slip_list.*            … 伝票一覧
├── slip_list_dt.*         … 伝票詳細
├── slip_list_export.cfm   … 伝票CSV出力

├── inventory.*            … 在庫管理

├── total_report.*         … 集計レポート
├── total_report_export.cfm

├── m_item.*               … 商品マスタ
├── m_supplier.*           … 取引先マスタ
├── m_staff.*              … 社員マスタ
├── m_delivery_company.*   … 配送業者マスタ

├── admin_setting.*        … 管理者設定

├── com/
│   ├── export_db.cfc      … CSV出力共通処理
│   └── paging.cfc         … ページング処理

├── js/
│   ├── 各画面JS
│   └── validation-common.js（共通バリデーション）

├── css/
│   ├── base.css
│   └── style.css

├── image/                 … アイコン類

├── sh/
│   └── export_db.sh       … CSV出力シェル

├── doc/                   … 各機能README
│   ├── README.md
│   ├── MENU.md
│   ├── ADDSLIP.md
│   ├── slip_list.md
│   ├── slip_list_dt.md
│   ├── TOTAL_REPORT.md
│   ├── ADMIN.md
│   ├── master_common.md
│   ├── m_staff.md
│   └── m_supplier.md

├── temp/                  … 一時ファイル

└── test.cfm               … テスト用
```

---

## 5. アーキテクチャ

本システムは以下の構成で統一する。

### ■ 1画面 = 3ファイル構成

* `.cfm` ：画面（HTML）
* `.cfc` ：API（データ処理）
* `.js`  ：フロント制御

---

### ■ 通信方式

* fetch + async/await を使用
* returnformat=json を利用
* レスポンス形式は統一

```json
{
  "status": 0,
  "message": "",
  "results": {}
}
```

---

### ■ エラーハンドリング

* cfcatch は database のみ使用
* 必ず cflog を出力

---

## 6. UI設計ルール

### ■ header.cfmでボタン制御

各画面で以下のフラグを設定する

* showHomeButton
* showBackButton
* showNewButton
* showEditButton
* showExportButton
* showCancelButton

---

### ■ 表示モード

```text
view / edit / add
```

によって画面制御する

---

### ■ 状態保持

一覧 → 詳細 → 戻る の際は

* 検索条件
* ソート
* ページ番号

を必ず保持すること

---

## 7. 業務フロー（重要）

### ■ 伝票 → 在庫の流れ

1. 伝票登録（status = 1）
2. 伝票確定（status = 2）
3. 在庫へ反映

※未確定状態では在庫に影響しない

---

## 8. エクスポート仕様

* Shell + MySQLでCSV生成
* UTF-8 → CP932変換
* NULLは空文字で出力

---

## 9. 開発ルール（重要）

* cfparamは禁止（structKeyExistsを使用）
* URLではなくFormで値を渡す
* 共通処理はjs / cfcに切り出す
* UIは既存画面に合わせる（統一最優先）

---

## 10. ドキュメント

各機能の詳細は以下を参照

* doc/配下の各.md

---

## 11. 補足

本システムは以下を最優先とする

* 可読性
* 統一性
* 保守性

---
