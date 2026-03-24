# hara-training-app

# 商品マスタ一覧画面 仕様書

## ■ 対象ファイル
- m_item.cfm（画面）
- m_item.js（フロント制御）
- m_item.cfc（API）

---

## ■ 画面概要
商品マスタ（m_item）を一覧表示する画面。

以下の機能を持つ：
- 検索
- ソート（単一列）
- ページング
- 非同期通信（fetch）

画面初期表示時に自動で一覧取得を実行する。

---

## ■ 検索項目

| 項目名 | id | 検索方法 |
|--------|----|----------|
| 商品コード | search_product_code | 完全一致 |
| JAN | search_jan_code | 完全一致 |
| 商品名 | search_product_name | 部分一致（商品名 + カナ） |

※商品名は `item_name` と `item_name_kana` の両方に対して LIKE 検索

---

## ■ ボタン仕様

### 検索ボタン
- id: search_btn
- 押下時：
  - currentPage = 1
  - executeSearch() 実行

### クリアボタン
- id: clear_btn
- 押下時：
  - 検索条件を全て空にする
  - ソート初期化
  - currentPage = 1
  - executeSearch() 実行

---

## ■ Enterキー仕様（重要）

### IME対策（必須）
```js
if (e.isComposing || e.keyCode === 229) return;
```

### 動作
- Shift + Enter → 前項目へ
- Enter → 次項目へ
- 最後の項目で Enter → 検索ボタンにフォーカス（検索は実行しない）

※必要に応じて「最後で検索実行」に変更可

---

## ■ 一覧テーブル

### カラム構成

| 表示名 | DB項目 | 備考 |
|--------|--------|------|
| 商品コード | item_code | |
| JAN | jan_code | |
| 商品名 | item_name | |
| 商品名(カナ) | item_name_kana | |
| 原価 | gentanka | 右寄せ・数値整形 |

---

## ■ ソート仕様

### 状態遷移
none → asc → desc → none

### 制御
- 単一列のみ有効
- 他列はリセット

### data-field → DB対応

| data-field | DBカラム |
|------------|----------|
| item_code | item_code |
| jan_code | jan_code |
| item_name | item_name |
| item_category | item_name_kana |
| cost_price | gentanka |

※命名ズレあり（現行仕様）

---

## ■ ページング仕様

- 1ページ = 50件固定

### ボタン
- TOP → 1ページ目
- Prev → 前ページ
- Next → 次ページ
- END → 最終ページ

### 表示形式
1 / 10 ページ（全100件）

---

## ■ API仕様

### エンドポイント
m_item.cfc?method=getItemList&returnformat=json

### リクエスト
```json
{
  "page": 1,
  "pageSize": 50,
  "sortField": "",
  "sortOrder": "",
  "search_product_code": "",
  "search_jan_code": "",
  "search_product_name": ""
}
```

### レスポンス
```json
{
  "status": 1,
  "message": "",
  "results": [
    {
      "item_code": "0001",
      "jan_code": "1234567890123",
      "item_name": "商品A",
      "item_name_kana": "ショウヒンエー",
      "gentanka": 123.45
    }
  ],
  "paging": {
    "page": 1,
    "pageSize": 50,
    "totalCount": 100,
    "totalPage": 2,
    "hasPrev": false,
    "hasNext": true
  }
}
```

---

## ■ SQL仕様

### 件数取得
```sql
SELECT COUNT(*) AS total_count
FROM m_item
WHERE 1=1
  [filtering]
```

### 一覧取得
```sql
SELECT
  item_code,
  jan_code,
  item_name_kana,
  item_name,
  gentanka
FROM m_item
WHERE 1=1
  [filtering]
ORDER BY [orderBy]
LIMIT [offset], [pageSize]
```

### ページ計算
offset = (page - 1) * pageSize

---

## ■ 検索条件SQL

### 商品コード
item_code = '値'

### JAN
jan_code = '値'

### 商品名
(item_name LIKE '%値%' OR item_name_kana LIKE '%値%')

---

## ■ 表示仕様

### 原価
- 小数点2桁固定
- カンマ区切り

### HTMLエスケープ
- &, <, >, ", ' をエスケープ

### 表示状態
- 通信中 → 読み込み中です...
- 0件 → データがありません。
- エラー → 商品一覧の取得に失敗しました。

---

## ■ ローディング制御

通信中は以下を無効化：
- 検索ボタン
- クリアボタン
- ページングボタン
- ソートボタン
- 入力欄

---

## ■ APIエラー時

- status = 0
- message = "商品一覧の取得中にエラーが発生しました。"

---

## ■ 注意点（重要）

- executeSearch() は1つだけにする（重複定義禁止）
- ソートは常に単一列
- 未ソートでも DB側は item_code ASC
- Enterで検索しない仕様（誤検索防止）
- fetchで非同期更新（画面遷移なし）
- filteringは文字列連結（現仕様）※セキュリティ改善余地あり
- sleep(100) が入っている場合あり（意図確認）

---

## ■ 再利用ルール（超重要）

次回別マスタを作る場合は以下だけ変更すればよい：

- テーブル名
- カラム構成
- 検索項目
- ソート対象
- SQLのWHERE条件
- API名

それ以外の構造（検索・ページング・ソート・fetch）は流用すること

---

## ■ ChatGPT再現用プロンプト

以下README仕様に従い、ColdFusion + JSで一覧画面を作成してください。

要件：
- 初期表示で検索実行
- fetchでCFC呼び出し
- ページング（50件）
- 単一列ソート
- Enterキー制御（IME考慮）
- ローディング制御
- テーブル内メッセージ表示
- JSON形式：status, message, results, paging

READMEの仕様を忠実に再現してください。