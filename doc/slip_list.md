# slip_list（伝票一覧）README

---

## 1. 概要

`slip_list` は、伝票の一覧表示を行う画面である。

この画面の役割は以下の4つ。

1. 伝票を条件検索して一覧表示する  
2. 一覧をページング・ソートしながら確認する  
3. 一覧行クリックで詳細画面へ遷移する（状態を保持）  
4. 検索条件をもとにCSVエクスポートを行う  

本READMEは以下を目的とする。

- 新規参入者が見ても理解できること  
- AI（ChatGPT等）がこれだけ見れば同じ仕様を再現できること  

---

## 2. 対象ファイル構成

本画面は以下の4ファイルで構成する。

- slip_list.cfm（画面）
- slip_list.cfc（API）
- slip_list.js（制御）
- slip_list_export.cfm（CSV出力）

---

## 3. 表示仕様

### 3.1 一覧表示列

| 項目 | 内容 |
|------|------|
| 伝票番号 | slip_no |
| 発注日 | slip_date |
| 納品日 | delivery_date |
| 取引先 | supplier_code + supplier_name |
| 合計数量 | total_qty |
| 状態 | status |

---

### 3.2 表示しない項目

- 更新日時  
- 詳細ボタン  

※ 行クリックで詳細へ遷移するため不要  

---

### 3.3 取引先表示

取引先は1列で表示する  

例：  
SUP001　山田商事  

---

## 4. 検索仕様

### 4.1 レイアウト

#### 1行目
- 伝票番号  
- 発注日（From / To）  
- 納品日（From / To）  

#### 2行目
- 取引先（ドロップダウン）  
- 取引先あいまい検索（ラベルなし）  
- 商品検索  
- 状態  
- 検索ボタン  
- クリアボタン  

---

### 4.2 各検索項目

#### ■ 伝票番号

t_slip.slip_no LIKE '%入力値%'

---

#### ■ 発注日

t_slip.slip_date >= From  
t_slip.slip_date <= To  

---

#### ■ 納品日

t_slip.delivery_date >= From  
t_slip.delivery_date <= To  

---

#### ■ 取引先（ドロップダウン）

t_slip.supplier_code = 選択値  

取得元：

m_supplier  
WHERE use_flag = 1  
ORDER BY supplier_code ASC  

---

#### ■ 取引先あいまい検索

m_supplier.supplier_name LIKE '%入力値%'  

---

#### ■ 商品検索

EXISTS (
  SELECT 1
  FROM t_slip_detail
  LEFT OUTER JOIN m_item
    ON m_item.item_code = t_slip_detail.item_code
  WHERE t_slip_detail.slip_no = t_slip.slip_no
    AND (
      m_item.item_code = 入力値
      OR m_item.jan_code = 入力値
      OR m_item.item_name LIKE '%入力値%'
      OR m_item.item_name_kana LIKE '%入力値%'
    )
)

---

#### ■ 状態

t_slip.status = 入力値  

| 値 | 内容 |
|----|------|
| 1 | 登録 |
| 2 | 確定 |
| 3 | 削除 |

---

## 5. Enterキー仕様（重要）

この画面では Enter で検索を実行してはいけない。

### 正しい挙動

- Enter → 次の項目へフォーカス移動  
- 最後の項目 → 何もしない  

### NG

- Enterで検索実行  
- form submit  

### 実装

if (event.key === "Enter") {  
  event.preventDefault();  
  次の項目へfocus();  
}  

---

## 6. 日付入力

flatpickrを使用する  

flatpickr(".js-date-picker", {  
  locale: "ja",  
  dateFormat: "Y-m-d",  
  altInput: true,  
  altFormat: "Y / m / d",  
  allowInput: false,  
  disableMobile: true  
});  

---

## 7. ページング

### 件数
1ページ = 50件  

const pageSize = 50;  

---

### ボタン

- TOP  
- Prev  
- Next  
- END  

---

### 表示

1 / 5 ページ（全 200 件）  

---

### 制御

- 1ページ → Prev / TOP 無効  
- 最終ページ → Next / END 無効  

---

## 8. ソート

### 対象列

- 伝票番号  
- 発注日  
- 納品日  
- 取引先  
- 合計数量  
- 状態  

---

### 挙動

なし → asc → desc → なし  

---

## 9. 詳細画面遷移

一覧行クリックで遷移する  

slip_list_dt.cfm  

---

### POSTパラメータ

detail_slip_no  
detail_display_mode = view  

---

## 10. 状態保持（重要）

一覧 → 詳細 → 戻る で状態を保持する  

---

### 保持対象

- 検索条件  
- ページ番号  
- ソート条件  

---

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

---

### 遷移処理

submitPost("slip_list_dt.cfm", {  
  上記すべて  
});  

---

## 11. SQLルール

### エイリアス禁止

NG： t.slip_no  
OK： t_slip.slip_no  

---

### JOIN

LEFT OUTER JOIN で統一  

---

## 12. UIルール

- 検索ボタンは状態のすぐ右  
- 右端に寄せない  
- 2行構成にする  
- 取引先名ラベルは表示しない  
- Enterは検索実行しない  

---

## 13. エクスポート機能

### 概要

検索条件・ソート条件をそのまま使用し、CSVをダウンロードする  

---

### 実行方法

ヘッダのエクスポートボタン押下  

showExportButton = true  

---

### JS処理

window.location.href = "slip_list_export.cfm?パラメータ"  

---

### パラメータ

- 検索条件すべて  
- sortField  
- sortOrder  

---

### CFM処理

1. URLパラメータ取得  
2. filtering生成  
3. SQL生成  
4. CSV作成  
5. download.cfmへ遷移  

---

### 出力内容

#### ヘッダ情報

- 伝票番号  
- 発注日  
- 納品日  
- 状態  
- 状態名  
- 取引先コード  
- 取引先名  
- 合計数量  
- 合計金額  
- 備考  
- 作成・更新情報  

---

#### 明細情報

- 行番号  
- 商品コード  
- JANコード  
- 商品名  
- 数量（qty）  
- 単価（unit_price）  
- 金額（amount）  
- 明細備考  

---

### 出力形式

1明細 = 1行  

---

### 使用テーブル

- t_slip  
- t_slip_detail  
- m_supplier  

---

### JOIN

LEFT OUTER JOIN  

---

### ファイル名

伝票一覧_YYYYMMDD_HHMMSS.csv  

---

### 文字コード

shift_jis  

---

### 出力方式

export_db.expDb を使用  

---

### ダウンロード

download.cfm 経由  

---

### 処理フロー

ボタン押下  
↓  
JSでURL遷移  
↓  
CFMでCSV生成  
↓  
download.cfm  
↓  
ダウンロード  

---

### 注意点

- 件数が多いと重くなる  
- 明細で行数が増える  
- LIKE検索は負荷が高い  

---

## 14. 全体フロー

画面表示  
↓  
検索条件入力  
↓  
検索ボタン押下  
↓  
一覧取得（CFC）  
↓  
一覧表示  
↓  
行クリック  
↓  
詳細画面  
↓  
戻る  
↓  
状態復元  
↓  
エクスポート  

---

## 15. ゴール

このREADMEを見れば  

- 新規メンバーが理解できる  
- AIが同じ画面を再現できる  

状態になっていること  

---

以上