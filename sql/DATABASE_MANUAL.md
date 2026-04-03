# データベース定義書（haradb）

---

## 1. 概要

本書は、`haradb` の主要テーブル定義をまとめたデータベース定義書である。  
対象は、物流・業務管理アプリケーション「Hara LogiApp」で使用しているマスタ系・伝票系・在庫系テーブルとする。  
SQLダンプは Sequel Ace により 2026-04-03 07:28:30 +0000 時点で出力されたものを元にしている。

---

## 2. データベース概要

- DB名：`haradb`
- DB種別：MySQL 8.4.8
- 文字コード：
  - `utf8mb4` 使用テーブルあり
  - `utf8mb3` 使用テーブルあり
- 主な機能分類
  - 管理設定
  - マスタ管理
  - 伝票管理
  - 在庫管理

---

## 3. テーブル一覧

| テーブル名 | 区分 | 概要 |
|-----------|------|------|
| m_admin | マスタ | 会社・センター基本設定 |
| m_delivery_company | マスタ | 配送業者マスタ |
| m_item | マスタ | 商品マスタ |
| m_prefecture | マスタ | 都道府県マスタ |
| m_staff | マスタ | 社員マスタ |
| m_supplier | マスタ | 取引先マスタ |
| t_slip | トラン | 伝票ヘッダ |
| t_slip_detail | トラン | 伝票明細 |
| t_inventory | トラン | 現在庫 |
| t_inventory_history | トラン | 在庫変動履歴 |

---

## 4. ER上の主な関係

- `m_delivery_company` 1 : N `m_supplier`
- `m_supplier` 1 : N `t_slip`
- `t_slip` 1 : N `t_slip_detail`
- `m_item` 1 : N `t_slip_detail`
- `m_item` 1 : 1 `t_inventory`
- `m_item` 1 : N `t_inventory_history`

※ ただし、現行ダンプ上では外部キー制約そのものは未定義であり、アプリケーション側で関連整合性を担保している前提とする。

---

# 5. テーブル定義

---

## 5.1 m_admin

### 概要
会社コード単位で、会社名・センター名・住所・連絡先・伝票確定用パスワード等を保持する管理設定テーブル。

### 主キー
- `company_code`

### カラム定義

| カラム名 | 型 | NULL | PK | 説明 |
|---------|----|------|----|------|
| company_code | varchar(8) | NO | ○ | 会社コード |
| company_name | varchar(60) | YES |  | 会社名 |
| center_name | varchar(60) | YES |  | センター名 |
| postal_code | varchar(8) | YES |  | 郵便番号 |
| address1 | varchar(100) | YES |  | 住所1 |
| address2 | varchar(100) | YES |  | 住所2 |
| tel_no | varchar(20) | YES |  | 電話番号 |
| fax_no | varchar(20) | YES |  | FAX番号 |
| memo | varchar(100) | YES |  | メモ |
| admin_password | varchar(60) | YES |  | 伝票確定等に必要なパスワード |
| create_datetime | datetime | YES |  | 作成日時 |
| create_staff_code | varchar(8) | YES |  | 作成者コード |
| create_staff_name | varchar(80) | YES |  | 作成者名 |
| update_datetime | datetime | YES |  | 更新日時 |
| update_staff_code | varchar(8) | YES |  | 更新者コード |
| update_staff_name | varchar(80) | YES |  | 更新者名 |

---

## 5.2 m_delivery_company

### 概要
配送業者の基本情報を保持するマスタ。

### 主キー
- `delivery_company_code`

### カラム定義

| カラム名 | 型 | NULL | PK | 初期値 | 説明 |
|---------|----|------|----|--------|------|
| delivery_company_code | char(5) | NO | ○ |  | 配送業者コード |
| delivery_company_name | varchar(100) | NO |  |  | 配送業者名 |
| note | varchar(255) | YES |  | NULL | 備考 |
| use_flag | tinyint(1) | NO |  | 1 | 使用区分 |
| create_datetime | datetime | YES |  | NULL | 作成日時 |
| create_staff_code | varchar(20) | YES |  | NULL | 作成者コード |
| create_staff_name | varchar(100) | YES |  | NULL | 作成者名 |
| update_datetime | datetime | YES |  | NULL | 更新日時 |
| update_staff_code | varchar(20) | YES |  | NULL | 更新者コード |
| update_staff_name | varchar(100) | YES |  | NULL | 更新者名 |

### 備考
- `use_flag` は一覧画面上で「使用中 / 停止」に変換して表示する。

---

## 5.3 m_item

### 概要
商品情報を保持するマスタ。

### 主キー
- `item_code`

### カラム定義

| カラム名 | 型 | NULL | PK | 説明 |
|---------|----|------|----|------|
| item_code | varchar(8) | NO | ○ | 商品コード |
| jan_code | varchar(16) | NO |  | JANコード |
| item_name | varchar(200) | YES |  | 商品名 |
| item_name_kana | varchar(60) | YES |  | 商品名カナ |
| item_category | tinyint | YES |  | 1:食品 2:雑貨 3:日用品 4:衣料 5:小物 |
| gentanka | decimal(8,2) | YES |  | 原価 |
| baitanka | int | YES |  | 売価 |
| use_flag | tinyint | YES |  | 0:無効 1:有効 |
| memo | varchar(100) | YES |  | メモ |
| create_datetime | datetime | YES |  | 作成日時 |
| create_staff_code | varchar(8) | YES |  | 作成者コード |
| create_staff_name | varchar(80) | YES |  | 作成者名 |
| update_datetime | datetime | YES |  | 更新日時 |
| update_staff_code | varchar(8) | YES |  | 更新者コード |
| update_staff_name | varchar(80) | YES |  | 更新者名 |

---

## 5.4 m_prefecture

### 概要
都道府県の初期データを保持するマスタ。

### 主キー
- `prefecture_code`

### カラム定義

| カラム名 | 型 | NULL | PK | 初期値 | 説明 |
|---------|----|------|----|--------|------|
| prefecture_code | char(2) | NO | ○ |  | 都道府県コード |
| prefecture_name | varchar(20) | NO |  |  | 都道府県名 |
| note | varchar(255) | YES |  | NULL | 備考 |
| use_flag | tinyint(1) | NO |  | 1 | 使用区分 |
| create_datetime | datetime | NO |  | CURRENT_TIMESTAMP | 作成日時 |
| create_staff_code | varchar(20) | NO |  | SYSTEM | 作成者コード |
| create_staff_name | varchar(100) | NO |  | SYSTEM | 作成者名 |
| update_datetime | datetime | YES |  | NULL | 更新日時 |
| update_staff_code | varchar(20) | YES |  | NULL | 更新者コード |
| update_staff_name | varchar(100) | YES |  | NULL | 更新者名 |

---

## 5.5 m_staff

### 概要
ログイン・権限管理に使用する社員マスタ。

### 主キー
- `staff_code`

### ユニークキー
- `uq_m_staff_staff_code (staff_code)`

### インデックス
- `idx_m_staff_use_flag (use_flag)`
- `idx_m_staff_authority_level (authority_level)`

### カラム定義

| カラム名 | 型 | NULL | PK | 説明 |
|---------|----|------|----|------|
| staff_code | varchar(20) | NO | ○ | ログイン用ユーザーコード |
| staff_name | varchar(100) | NO |  | スタッフ名 |
| staff_kana | varchar(100) | YES |  | スタッフ名カナ |
| login_password_hash | varchar(255) | YES |  | ログインパスワードハッシュ |
| authority_level | tinyint | YES |  | 権限レベル 1:一般 2:責任者 9:管理者 |
| mail_address | varchar(255) | YES |  | メールアドレス |
| tel_no | varchar(20) | YES |  | 電話番号 |
| last_login_datetime | datetime | YES |  | 最終ログイン日時 |
| password_update_datetime | datetime | YES |  | パスワード更新日時 |
| use_flag | tinyint | YES |  | 使用可否 1:使用中 0:停止 |
| note | varchar(255) | YES |  | 備考 |
| create_datetime | datetime | YES |  | 登録日時 |
| create_staff_code | varchar(20) | YES |  | 登録者コード |
| create_staff_name | varchar(100) | YES |  | 登録者名 |
| update_datetime | datetime | YES |  | 更新日時 |
| update_staff_code | varchar(20) | YES |  | 更新者コード |
| update_staff_name | varchar(100) | YES |  | 更新者名 |

---

## 5.6 m_supplier

### 概要
取引先情報を保持するマスタ。

### 主キー
- `supplier_id`

### ユニークキー
- `uq_supplier_code (supplier_code)`

### カラム定義

| カラム名 | 型 | NULL | PK | 説明 |
|---------|----|------|----|------|
| supplier_id | int | NO | ○ | 取引先ID（AUTO_INCREMENT） |
| supplier_code | varchar(20) | NO |  | 取引先コード |
| supplier_name | varchar(100) | NO |  | 取引先名 |
| supplier_name_kana | varchar(100) | YES |  | 取引先名カナ |
| zip_code | varchar(10) | YES |  | 郵便番号 |
| prefecture_code | char(2) | YES |  | 都道府県コード |
| address1 | varchar(100) | YES |  | 住所1（市区町村） |
| address2 | varchar(100) | YES |  | 住所2（番地・建物） |
| tel | varchar(20) | YES |  | 電話番号 |
| fax | varchar(20) | YES |  | FAX番号 |
| delivery_company_code | char(5) | NO |  | 配送業者コード |
| note | text | YES |  | 備考 |
| use_flag | tinyint | YES |  | 使用フラグ（1:有効 0:無効） |
| create_datetime | datetime | YES |  | 作成日時 |
| create_staff_code | varchar(20) | YES |  | 作成者コード |
| create_staff_name | varchar(100) | YES |  | 作成者名 |
| update_datetime | datetime | YES |  | 更新日時 |
| update_staff_code | varchar(20) | YES |  | 更新者コード |
| update_staff_name | varchar(100) | YES |  | 更新者名 |

### 備考
- アプリ上の業務キーは `supplier_code`
- DB内部キーは `supplier_id`

---

## 5.7 t_slip

### 概要
伝票ヘッダを保持するトランザクションテーブル。

### 主キー
- `slip_no`

### 主な管理項目
- 発注日
- 納品日
- 取引先コード
- 取引先名（履歴保持）
- ステータス
- 合計数量
- 合計金額
- 確定日時
- 削除日時
- メモ
- 作成者 / 更新者情報

### ステータス
| 値 | 意味 |
|----|------|
| 1 | 登録 |
| 2 | 確定 |
| 3 | 削除 |

---

## 5.8 t_slip_detail

### 概要
伝票明細を保持するトランザクションテーブル。

### 主キー
- `(slip_no, line_no)`

### インデックス
- `idx_item_code (item_code)`
- `idx_jan_code (jan_code)`

### 主な項目
- 伝票番号
- 明細番号
- 商品コード
- JANコード
- 商品名（履歴保持）
- 数量
- 単価
- メモ
- 作成者 / 更新者情報

---

## 5.9 t_inventory

### 概要
商品ごとの現在庫を保持するテーブル。

### 主キー
- `item_code`

### カラム定義

| カラム名 | 型 | NULL | PK | 説明 |
|---------|----|------|----|------|
| item_code | varchar(20) | NO | ○ | 商品コード |
| current_qty | int | NO |  | 現在庫数 |
| safety_stock_qty | int | NO |  | 安全在庫数 |
| last_in_datetime | datetime | YES |  | 最終入庫日時 |
| last_out_datetime | datetime | YES |  | 最終出庫日時 |
| note | varchar(255) | YES |  | 備考 |
| create_datetime | datetime | NO |  | 作成日時 |
| create_staff_code | varchar(20) | NO |  | 作成者コード |
| create_staff_name | varchar(100) | NO |  | 作成者名 |
| update_datetime | datetime | NO |  | 更新日時 |
| update_staff_code | varchar(20) | NO |  | 更新者コード |
| update_staff_name | varchar(100) | NO |  | 更新者名 |

---

## 5.10 t_inventory_history

### 概要
在庫変動履歴を保持するテーブル。

### 主キー
- `history_no`

### 主な項目
- 商品コード
- 変更種別
- 変更前在庫数
- 変更数量
- 変更後在庫数
- 理由
- 作成日時
- 作成者コード
- 作成者名

### change_type
| 値 | 意味 |
|----|------|
| 1 | 加算 |
| 2 | 減算 |
| 3 | 直接設定 |

---

## 6. 業務上の関連

### 6.1 伝票と取引先
- `t_slip.supplier_code` により取引先を特定する

### 6.2 伝票と商品
- `t_slip_detail.item_code` により商品を特定する

### 6.3 伝票確定と在庫反映
- 伝票確定時、`t_slip_detail` の数量を集計し、`t_inventory.current_qty` に加算する
- 同時に `t_inventory_history` へ履歴を登録する

### 6.4 取引先と配送業者
- `m_supplier.delivery_company_code` により配送業者マスタと紐づく

---

## 7. 注意点

- SQLダンプ上では外部キー制約は未定義
- 一部テーブルで `utf8mb3`、一部で `utf8mb4` が混在している
- 監査項目（create/update 系）は全テーブルで概ね共通方針
- `supplier_id` のような内部IDと `supplier_code` のような業務コードが併存するテーブルがある

---

## 8. 今後の整備候補

- 外部キー制約の明示
- 文字コードの統一（utf8mb4 へ寄せる）
- 命名規則の統一
- DB設計書をテーブル単位ファイルへ分割
- ER図とのリンク付け