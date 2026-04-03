# 在庫管理画面（inventory）

---

## 1. 概要

商品の在庫情報の一覧表示・検索・ソート・ページング・在庫調整を行う画面。

本画面では以下を実現する。

* 在庫一覧の表示
* 在庫検索・絞り込み
* 在庫状況の可視化
* 在庫数の調整（増減）
* 安全在庫の設定
* 在庫サマリー表示

---

## 2. 対応ファイル

| 種別  | ファイル名         |
| --- | ------------- |
| 画面  | inventory.cfm |
| API | inventory.cfc |
| JS  | inventory.js  |

---

## 3. 機能一覧

### 3.1 検索機能

以下の条件で検索可能。

* 商品コード
* JANコード
* 商品名（キーワード）
* 商品分類
* 在庫ステータス
* 在庫数（From / To）
* 安全在庫以下のみ

---

### 3.2 一覧表示

表示項目：

* 商品コード
* JANコード
* 商品名
* 分類
* 現在庫数
* 安全在庫数
* 在庫ステータス
* 更新日時
* 調整ボタン

---

### 3.3 在庫ステータス判定

| 条件         | 表示   |
| ---------- | ---- |
| 在庫数 ≤ 0    | 在庫ゼロ |
| 在庫数 ≤ 安全在庫 | 不足   |
| その他        | 通常   |

---

### 3.4 在庫数表示スタイル

| 状態   | クラス        |
| ---- | ---------- |
| 在庫ゼロ | zero-stock |
| 不足   | low-stock  |
| 通常   | なし         |

---

### 3.5 サマリー表示

画面上部に以下を表示。

* 商品数
* 総在庫数
* 不足商品数

---

### 3.6 ソート機能

状態遷移：

昇順 ⇔ 降順

対象項目：

* 商品コード
* 在庫数
* 更新日時 など

---

### 3.7 ページング

* 1ページ10件
* 前へ / 次へ
* 最大±2ページ表示

---

### 3.8 在庫調整（モーダル）

一覧の「調整」ボタンまたは行クリックでモーダルを表示。

---

## 4. 在庫調整機能

### 4.1 入力項目

* 商品コード（hidden）
* 調整種別（増加 / 減少）
* 調整数量
* 安全在庫数
* 理由

---

### 4.2 処理内容

* 在庫数の増減
* 安全在庫の更新
* 更新理由の保存

---

### 4.3 処理フロー

1. 入力チェック
2. 確認ダイアログ
3. API実行
4. 成功時モーダル閉じる
5. 一覧再取得

---

## 5. API仕様

### 5.1 在庫一覧取得

inventory.cfc?method=getInventoryList

#### リクエスト

```json id="invreq01"
{
  "item_code": "",
  "jan_code": "",
  "keyword": "",
  "item_category": "",
  "stock_status": "",
  "qty_from": "",
  "qty_to": "",
  "safety_stock_only": "",
  "page": 1,
  "page_size": 10,
  "sort_column": "",
  "sort_order": ""
}
```

---

#### レスポンス

```json id="invres01"
{
  "status": 0,
  "results": {
    "rows": [],
    "summary": {
      "item_count": 100,
      "total_qty": 5000,
      "low_stock_count": 10
    },
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_count": 100
    }
  }
}
```

---

### 5.2 在庫更新

inventory.cfc?method=saveInventoryAdjustment

#### リクエスト

```json id="invreq02"
{
  "item_code": "",
  "change_type": "1",
  "change_qty": "",
  "safety_stock_qty": "",
  "reason": ""
}
```

---

### 5.3 ステータス仕様

| status | 意味 |
| ------ | -- |
| 0      | 正常 |
| 1      | 異常 |

---

## 6. 検索仕様

### 6.1 キーワード検索

以下に部分一致。

* 商品名

---

### 6.2 商品分類

| 値 | 表示  |
| - | --- |
| 1 | 食品  |
| 2 | 雑貨  |
| 3 | 日用品 |
| 4 | 衣料  |
| 5 | 小物  |

---

### 6.3 在庫ステータス

| 値    | 条件         |
| ---- | ---------- |
| 在庫ゼロ | qty ≤ 0    |
| 不足   | qty ≤ 安全在庫 |
| 通常   | その他        |

---

### 6.4 安全在庫以下

* safety_stock_only = 1 の場合のみ抽出

---

## 7. 主なJS処理

### 初期処理

```javascript id="invjs01"
initialize()
```

* イベント登録
* 初回一覧取得

---

### 検索状態管理

```javascript id="invjs02"
updateSearchStateFromForm()
```

---

### 一覧取得

```javascript id="invjs03"
async function loadInventoryList()
```

主な処理：

* API呼び出し
* 一覧描画
* サマリー更新
* ページング更新

---

### 一覧描画

```javascript id="invjs04"
function renderList(rows)
```

---

### サマリー表示

```javascript id="invjs05"
function renderSummary(summary)
```

---

### ページング

```javascript id="invjs06"
function renderPagination(paginationInfo)
```

---

### モーダル制御

```javascript id="invjs07"
function openAdjustModal(row)
function closeAdjustModal()
```

---

### 在庫更新

```javascript id="invjs08"
async function saveInventoryAdjustment()
```

---

### ステータス判定

```javascript id="invjs09"
function getStockStatusLabel(row)
```

---

## 8. バリデーション

以下をチェックする。

* 数量 必須
* 数量 数値
* 安全在庫 数値

エラー時：

* SweetAlert表示
* 入力欄フォーカス

---

## 9. 表示仕様

### 9.1 数値表示

* カンマ区切り（toLocaleString）

---

### 9.2 HTMLエスケープ

* XSS対策としてエスケープ処理あり

---

### 9.3 モーダル

* 背景クリックで閉じる
* 明細クリックで開く

---

## 10. エラーハンドリング

### API

* status ≠ 0 → エラー表示

---

### 通信エラー

* console.error出力
* SweetAlert表示

---

## 11. 注意点

* 在庫調整はモーダル内で完結
* 調整後は必ず一覧再取得
* 数量は整数のみ
* 検索状態は内部stateで管理
* APIはFormDataで送信

---

## 12. 今後拡張候補

* 履歴管理（在庫変動ログ）
* 入出庫連携
* 発注点管理
* 自動補充アラート
* CSV出力
* バーコードスキャン対応

---
