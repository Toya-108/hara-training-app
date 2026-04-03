# 配送業者マスタ一覧（m_delivery_company）

---

## 1. 概要

配送業者マスタの一覧表示・検索・ソート・ページング・新規登録遷移・詳細遷移・CSVエクスポートを行う画面。

本画面では以下を実現する。

* 配送業者情報の検索・絞り込み
* 一覧表示
* 詳細画面への遷移
* 新規登録画面への遷移
* CSVエクスポート
* 一覧状態の保持

---

## 2. 対応ファイル

| 種別    | ファイル名                         |
| ----- | ----------------------------- |
| 画面    | m_delivery_company.cfm        |
| API   | m_delivery_company.cfc        |
| JS    | m_delivery_company.js         |
| CSV出力 | m_delivery_company_export.cfm |

---

## 3. 機能一覧

### 3.1 検索機能

以下の条件で検索可能。

* 配送業者コード
* 配送業者名
* 使用区分

---

### 3.2 Enterキーによる検索実行

検索欄では Enter 押下時にそのまま検索を実行する。

対象項目：

* 配送業者コード
* 配送業者名
* 使用区分

IME変換中は検索しない。

---

### 3.3 一覧表示

表示項目：

* 配送業者コード
* 配送業者名
* 備考
* 使用区分
* 作成日時
* 更新日時

---

### 3.4 使用区分表示

| 値   | 表示  |
| --- | --- |
| 1   | 使用中 |
| その他 | 停止  |

バッジ表示で視覚的に判別する。

---

### 3.5 行クリック → 詳細画面遷移

* 行クリックで詳細画面へ遷移（POST）
* 表示モード：view

保持される内容：

* 検索条件
* ソート条件
* ページ番号

---

### 3.6 新規登録

* ヘッダの「追加」ボタン押下
* display_mode = add で詳細画面へ遷移

---

### 3.7 ソート機能

状態遷移：

未指定 → 昇順 → 降順 → 未指定

対象項目：

* 配送業者コード
* 配送業者名
* 備考
* 使用区分
* 作成日時
* 更新日時

---

### 3.8 ページング

* 1ページ50件
* 操作ボタン

  * 最初
  * 前へ
  * 次へ
  * 最後

---

### 3.9 CSVエクスポート

検索条件・ソート条件を保持したままCSV出力する。

POSTで `m_delivery_company_export.cfm` に送信する。

---

## 4. API仕様

### 4.1 一覧取得API

m_delivery_company.cfc?method=getDeliveryCompanyList

#### リクエスト

```json id="dlvreq01"
{
  "page": 1,
  "pageSize": 50,
  "sortField": "",
  "sortOrder": "",
  "search_delivery_company_code": "",
  "search_delivery_company_name": "",
  "search_use_flag": ""
}
```

#### レスポンス

```json id="dlvres01"
{
  "status": 0,
  "message": "配送業者一覧を取得しました。",
  "results": [],
  "paging": {
    "currentPage": 1,
    "totalPage": 1
  }
}
```

---

### 4.2 互換レスポンス対応

実装上、以下の大文字キー形式にも対応する。

```json id="dlvres02"
{
  "STATUS": 0,
  "MESSAGE": "OK",
  "RESULTS": [],
  "PAGING": {}
}
```

画面側で以下に正規化する。

* STATUS → status
* MESSAGE → message
* RESULTS → results
* PAGING → paging

---

### 4.3 ステータス仕様

| status | 意味      |
| ------ | ------- |
| 0      | 正常      |
| 1      | 異常（エラー） |

---

## 5. 検索仕様

### 5.1 配送業者コード

* 完全一致

---

### 5.2 配送業者名

* 部分一致検索

---

### 5.3 使用区分

| 値   | 条件    |
| --- | ----- |
| 1   | 使用中のみ |
| 0   | 停止のみ  |
| 未指定 | 全件    |

---

## 6. ソート仕様

| sortField             | 対象      |
| --------------------- | ------- |
| delivery_company_code | 配送業者コード |
| delivery_company_name | 配送業者名   |
| note                  | 備考      |
| use_flag              | 使用区分    |
| create_datetime       | 作成日時    |
| update_datetime       | 更新日時    |

未指定時：

* 配送業者コード昇順

---

## 7. 一覧表示仕様

### 7.1 データなし

* 「データがありません。」を表示

---

### 7.2 読み込み中

* 「読み込み中です...」を表示

---

### 7.3 エラー時

* エラーメッセージをテーブル表示

---

## 8. 状態保持

以下を保持する。

* 検索条件
* ソート条件
* ページ番号

hidden項目で管理する。

保持対象：

* return_page
* return_sort_field
* return_sort_order
* return_search_delivery_company_code
* return_search_delivery_company_name
* return_search_use_flag

---

## 9. 主なJS処理

### 初期処理

* 要素取得
* ホームボタンイベント登録
* 検索イベント登録
* ページングイベント登録
* ソートイベント登録
* 新規登録イベント登録
* エクスポートイベント登録
* ソート状態反映
* 一覧取得

---

### 一覧取得

```javascript id="dlvjs01"
async function loadDeliveryCompanyList()
```

主な処理：

* hidden項目へ状態同期
* ローディング表示
* API呼び出し
* レスポンス正規化
* 一覧描画
* ページング更新

---

### 一覧描画

```javascript id="dlvjs02"
function bindRowClick()
```

一覧HTML生成後、行クリックイベントを付与する。

---

### 詳細遷移

```javascript id="dlvjs03"
function moveToDetail(deliveryCompanyCode)
```

POSTで `m_delivery_company_dt.cfm` へ遷移する。

---

### 新規登録遷移

```javascript id="dlvjs04"
function moveToAdd()
```

POSTで `m_delivery_company_dt.cfm` に `display_mode=add` を付けて遷移する。

---

### エクスポート

```javascript id="dlvjs05"
function exportDeliveryCompanyList()
```

検索条件とソート条件を hidden 付きのPOSTフォームで `m_delivery_company_export.cfm` に送信する。

---

### 使用区分バッジ変換

```javascript id="dlvjs06"
function getUseFlagBadge(useFlag)
```

* 1 → 使用中
* その他 → 停止

---

## 10. エクスポート仕様

### 10.1 ファイル名

`配送業者マスタ_yyyymmdd_HHmmss.csv`

---

### 10.2 出力条件

以下を引き継ぐ。

* 配送業者コード
* 配送業者名
* 使用区分
* ソート条件

---

### 10.3 出力項目

* 配送業者コード
* 配送業者名
* 備考
* 使用区分
* 作成日時
* 作成者コード
* 作成者名
* 更新日時
* 更新者コード
* 更新者名

---

### 10.4 使用区分変換

| 値   | 出力  |
| --- | --- |
| 1   | 使用中 |
| その他 | 停止  |

---

### 10.5 NULL値

* 空文字で出力

---

### 10.6 出力処理

1. パラメータ取得
2. WHERE句生成
3. ORDER BY生成
4. CSV生成
5. ダウンロード処理

---

## 11. エラーハンドリング

### API

* status = 1 → エラー
* message返却

---

### 画面

* 一覧取得失敗時はテーブルにエラーメッセージ表示
* ページ表示は 1 / 1 に戻す
* ローディングは finally で解除する

---

## 12. 注意点

* status = 0 が正常
* 大文字レスポンス形式にも対応している
* Enterで即検索する仕様
* ソートは3段階制御
* エクスポートはPOST送信
* 一覧状態は hidden 項目へ同期してから遷移する

---

## 13. 今後拡張候補

* 使用区分以外の絞り込み追加
* 備考検索
* CSV出力項目選択
* 一括更新
* 他マスタとの参照状況表示

---
