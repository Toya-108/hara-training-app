# slip_list_dt（伝票詳細）README

---

## 1. 概要

`slip_list_dt` は、伝票の詳細表示および修正を行う画面である。

この画面の役割は以下の3つ。

1. 伝票のヘッダ情報を表示する  
2. 明細情報を表示・編集する  
3. 修正内容を保存する  

また、一覧画面（slip_list）から遷移してきた場合、  
戻るときに **検索条件・ページング・ソート状態を維持することが必須要件**である。

---

## 2. 対象ファイル構成

本画面は以下の3ファイルで構成する。

- slip_list_dt.cfm（画面）
- slip_list_dt.cfc（API）
- slip_list_dt.js（制御）

---

## 3. 画面モード

本画面は2つのモードを持つ。

| モード | 内容 |
|------|------|
| view | 表示専用 |
| edit | 編集可能 |

### モード制御

detail_display_mode

値：

- view
- edit

---

## 4. ヘッダ表示項目

| 項目 | 内容 |
|------|------|
| 伝票番号 | slip_no |
| 状態 | status |
| 発注日 | slip_date |
| 納品日 | delivery_date |
| 取引先コード | supplier_code |
| 取引先名 | supplier_name |
| 合計数量 | total_qty |
| 合計金額 | total_amount |
| 備考 | memo |
| 作成日時 | create_datetime |
| 更新日時 | update_datetime |

---

## 5. 明細表示項目

| 項目 | 内容 |
|------|------|
| 行番号 | line_no |
| 商品コード | item_code |
| JANコード | jan_code |
| 商品名 | item_name |
| 数量 | qty |
| 単価 | unit_price |
| 金額 | amount |

---

## 6. 表示仕様

### viewモード

- すべてreadonly表示
- inputは使用しない
- テキスト表示のみ

### editモード

編集可能項目：

- 発注日
- 納品日
- 状態
- 取引先コード
- 備考
- 明細（商品コード・数量・単価）

### UI制御

- view-only / edit-only クラスで制御
- edit_mode クラスで切替

---

## 7. 明細編集仕様

### 入力可能

- 商品コード
- 数量
- 単価

### 自動反映

- JANコード
- 商品名
- 金額（qty × unit_price）

### 商品コード入力時

API呼び出し：

slip_list_dt.cfc?method=getItemByCode

### 成功時

- JANコードセット
- 商品名セット
- 単価セット

### 失敗時

- 全項目クリア
- SweetAlertで警告表示

---

## 8. 合計計算

### 合計数量

sum(qty)

### 合計金額

sum(qty × unit_price)

### 更新タイミング

- 数量変更時
- 単価変更時
- 商品変更時

---

## 9. 保存処理

### API

slip_list_dt.cfc?method=saveSlipDetail

### 送信データ

{
  slip_no,
  status,
  slip_date,
  delivery_date,
  supplier_code,
  memo,
  details: [
    {
      item_code,
      qty,
      unit_price
    }
  ]
}

### バリデーション

- 発注日 必須
- 納品日 必須
- 取引先コード 必須
- 明細1件以上 必須

### フロー

確認ダイアログ  
↓  
保存API実行  
↓  
成功メッセージ  
↓  
viewモードへ遷移  

---

## 10. SweetAlert

全メッセージはSweetAlert2で統一

使用箇所：

- エラー
- 確認
- 成功

---

## 11. 戻る動作（重要）

一覧へ戻る際、状態を保持する

### 保持対象

- 検索条件
- ページ番号
- ソート条件

### hidden項目

return_search_slip_no  
return_search_order_date_from  
return_search_order_date_to  
return_search_delivery_date_from  
return_search_delivery_date_to  
return_search_supplier_code  
return_search_supplier_keyword  
return_search_item_keyword  
return_search_status  
return_current_page  
return_sort_field  
return_sort_order  

### 戻り処理

submitPost("slip_list.cfm", {
  上記すべて
});

---

## 12. SQLルール

### エイリアス禁止

NG：
t.slip_no

OK：
t_slip.slip_no

### JOIN

LEFT OUTER JOIN で統一

---

## 13. UIルール

- 保存ボタンは画面下に配置
- スクロールなしでも見える位置
- view/editでUI切替
- 明細はテーブル形式
- 数値は右寄せ

---

## 14. 全体フロー

一覧画面  
↓  
詳細画面（view）  
↓  
編集モード（edit）  
↓  
修正  
↓  
保存  
↓  
一覧へ戻る（状態保持）

---

## 15. ゴール

このREADMEを見れば

- 新規メンバーが理解できる
- AIが同じ画面を再現できる

状態になっていること

---

以上