# 物流・業務管理アプリケーション

## 概要

本アプリは、物流および業務管理を目的としたWebアプリケーションです。
各種マスタ（社員・取引先など）を中心に構成されています。

---

## 主な機能

* 社員マスタ管理
* 取引先マスタ管理
* 各種マスタの一覧・詳細・追加・修正・削除

---

## 技術構成

* ColdFusion（CFML）
* MySQL
* JavaScript（Vanilla）
* SweetAlert2

---

## マスタ画面の設計について

本アプリのマスタ画面はすべて共通設計で構築しています。

詳細は以下を参照してください。

* 共通仕様
  → `docs/master-common.md`

* 社員マスタ仕様
  → `docs/m_staff.md`

* 取引先マスタ仕様
  → `docs/m_supplier.md`

---

## ディレクトリ構成

```text
/
├── m_staff.cfm
├── m_staff_dt.cfm
├── m_staff_dt.cfc
├── js/
│   ├── m_staff.js
│   ├── m_staff_dt.js
├── docs/
```

---

## 開発ルール（重要）

* マスタ画面はすべて共通設計に従うこと
* 画面遷移は `return_xxx_id` を必ず使用すること
* header.cfm にボタンを集約すること

---

## 注意事項

本プロジェクトでは以下を厳守してください。

* `staff_id` と `return_staff_id` を混同しない
* add時は必ず画面を初期化する
* 一覧・詳細の遷移はPOSTで統一する

---
