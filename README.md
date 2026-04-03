# 📦 Hara LogiApp - 業務管理システム

---

## 1. 概要

本システムは、物流業務における以下の管理を行う業務アプリケーションである。

* 伝票管理
* 在庫管理
* マスタ管理（商品・取引先・社員・配送業者）
* 集計レポート

本プロジェクトは、以下の設計思想に基づいて構築されている。

* 状態保持（一覧 → 詳細 → 戻る）
* UI/UXの統一
* 明示的で可読性の高い実装
* APIと画面の責務分離

---

## 2. 技術構成

| 項目     | 内容                                |
| ------ | --------------------------------- |
| フロント   | JavaScript（Vanilla / async-await） |
| バックエンド | CFML（CFC）                         |
| DB     | MySQL                             |
| UI     | CSS + SweetAlert2 + Flatpickr     |

---

## 3. ディレクトリ構成

```plaintext
hara/
├── Application.cfc         # アプリケーション設定
├── init.cfm                # 初期化処理
├── header.cfm              # 共通ヘッダ

├── css/                    # スタイル
├── js/                     # 画面ごとのJS
├── image/                  # アイコン・画像

├── com/                    # 共通CFC
│   ├── paging.cfc
│   └── export_db.cfc

├── sh/                     # CSV出力用シェル
│   └── export_db.sh

├── temp/                   # 一時ファイル

├── doc/                    # ★設計書
│   ├── README.md
│   ├── MASTER.md
│   ├── LOGIN.md
│   ├── MENU.md
│   ├── ADMIN.md
│   ├── ADDSLIP.md
│   ├── SLIP.md
│   ├── SLIPLIST.md
│   ├── SLIPLIST_DT.md
│   ├── INVENTORY.md
│   ├── TOTAL_REPORT.md
│   ├── M_ITEM.md
│   ├── M_ITEM_DT.md
│   ├── M_SUPPLIER.md
│   ├── M_SUPPLIER_DT.md
│   ├── M_STAFF.md
│   ├── M_STAFF_DT.md
│   ├── M_DELIVERY_COMPANY.md
│   └── M_DELIVERY_COMPANY_DT.md

├── login.cfm / login.cfc
├── menu.cfm / menu.cfc
├── admin_setting.cfm / cfc

├── add_slip.cfm / cfc
├── slip_list.cfm / cfc
├── slip_list_dt.cfm / cfc
├── slip_list_export.cfm

├── inventory.cfm / cfc

├── total_report.cfm / cfc
├── total_report_export.cfm

├── m_item.cfm / cfc
├── m_item_dt.cfm / cfc
├── m_item_export.cfm

├── m_supplier.cfm / cfc
├── m_supplier_dt.cfm / cfc
├── m_supplier_export.cfm

├── m_staff.cfm / cfc
├── m_staff_dt.cfm / cfc
├── m_staff_export.cfm

├── m_delivery_company.cfm / cfc
├── m_delivery_company_dt.cfm / cfc
├── m_delivery_company_export.cfm

├── download.cfm
└── test.cfm
```

---

## 4. 機能一覧

### 4.1 認証・設定

* ログイン
* 管理者設定

---

### 4.2 伝票管理

* 伝票登録
* 伝票一覧
* 伝票詳細
* 一括確定
* CSV出力

---

### 4.3 在庫管理

* 在庫一覧表示
* 在庫調整
* 在庫サマリー表示

---

### 4.4 マスタ管理

* 商品マスタ
* 取引先マスタ
* 社員マスタ
* 配送業者マスタ

---

### 4.5 集計レポート

* 日別
* 商品別
* 取引先別

---

## 5. 設計ドキュメント

詳細仕様は `doc/` 配下に格納。

---

### ■ 全体設計

* MASTER.md
  → マスタ共通仕様

---

### ■ 伝票関連

* SLIP.md
* SLIPLIST.md
* SLIPLIST_DT.md

---

### ■ 在庫

* INVENTORY.md

---

### ■ マスタ

* M_ITEM.md / M_ITEM_DT.md
* M_SUPPLIER.md / M_SUPPLIER_DT.md
* M_STAFF.md / M_STAFF_DT.md
* M_DELIVERY_COMPANY.md / M_DELIVERY_COMPANY_DT.md

---

### ■ その他

* LOGIN.md
* MENU.md
* ADMIN.md
* TOTAL_REPORT.md

---

## 6. 共通仕様（重要）

### 6.1 APIレスポンス

```json
{
  "status": 0,
  "message": "",
  "results": {},
  "paging": {}
}
```

---

### 6.2 ステータス

| status | 意味  |
| ------ | --- |
| 0      | 正常  |
| 1      | エラー |

---

### 6.3 画面モード

| モード  | 内容 |
| ---- | -- |
| view | 表示 |
| edit | 編集 |
| add  | 新規 |

---

### 6.4 Enterキー挙動（統一）

* Enter → 次項目へ移動
* Shift+Enter → 前へ
* 最後 → 検索ボタン
* IME中は無効
* Enterで検索しない

---

### 6.5 状態保持

* 検索条件
* ソート
* ページ

→ hiddenで管理

---

## 7. 特徴

### 7.1 状態保持重視

一覧 → 詳細 → 戻るで状態維持

---

### 7.2 UI統一

* 全マスタ同一操作
* 同一レイアウト

---

### 7.3 明示的実装

* cfparam未使用
* structKeyExists使用

---

### 7.4 シンプル設計

* helper乱用なし
* 可読性重視

---

## 8. 開発ルール

* APIは必ずJSONで返却
* status=0を成功とする
* SQLはバインド変数使用
* エラーはmessageで返却

---

## 9. 今後拡張

* 在庫履歴管理
* 権限制御
* ワークフロー化
* 一括処理強化
* API共通化

---

## 10. 補足

本システムは、以下を目的として設計されている。

* 業務効率化
* 操作ミス防止
* 拡張性の確保
* 保守性の向上

---
