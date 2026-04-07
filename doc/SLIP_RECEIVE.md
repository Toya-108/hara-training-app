# SLIP_RECEIVE.md

## 1. 機能概要

伝票受信機能は、CSVファイルを読み込み、伝票ヘッダ（t_slip）および伝票明細（t_slip_detail）を一括登録する機能である。
CSVをアップロードすることで、手入力せずに伝票をまとめて登録できる。
また、受信結果および履歴（最大5件）を画面に表示する。

---

## 2. 画面構成

### 2.1 受信エリア

* CSVファイル選択
* 受信開始ボタン
* 結果メッセージ表示

### 2.2 CSVフォーマット説明

CSVの構造を表形式で表示する

### 2.3 受信履歴

* 最新5件表示
* 項目

  * 受信日時
  * 伝票数
  * 明細数
  * 商品数
  * 結果

---

## 3. 使用ファイル

* slip_receive.cfm（画面）
* slip_receive.js（フロント処理）
* slip_receive.cfc（API）
* r_receive（履歴テーブル）

---

## 4. CSVフォーマット

### ヘッダ

slip_no,slip_date,supplier_code,delivery_date,slip_memo,item_code,qty,detail_memo

### サンプル

2604070001,2026-04-07,SUP001,2026-04-08,午前納品,ITEM001,3,冷蔵
2604070001,2026-04-07,SUP001,2026-04-08,午前納品,ITEM002,5,
2604070002,2026-04-07,SUP002,2026-04-09,,ITEM003,2,特売分

---

## 5. 必須項目

* slip_no
* slip_date
* supplier_code
* delivery_date
* item_code
* qty

---

## 6. バリデーション

### 基本チェック

* 必須項目チェック
* 日付形式チェック
* 数値チェック（qty）
* qtyは1以上

### 同一伝票チェック

同一 slip_no 内で以下が一致していること

* slip_date
* supplier_code
* delivery_date

---

## 7. 登録処理

### 処理フロー

1. CSV読み込み
2. ヘッダチェック
3. データ検証
4. 伝票単位でまとめる
5. トランザクション開始
6. 既存データ削除
7. マスタ取得
8. 伝票登録
9. 明細登録
10. 合計更新
11. コミット

---

## 8. マスタ参照

### 取引先

* m_supplier
* use_flag = 1

### 商品

* m_item
* use_flag = 1 または NULL
* gentanka 必須

---

## 9. 金額計算

明細金額 = qty × gentanka
合計金額 = 明細合計

---

## 10. 受信履歴

### 保存タイミング

* 成功時
* 失敗時

必ずどちらも記録する

---

## 11. r_receive テーブル

CREATE TABLE r_receive (
receive_id INT AUTO_INCREMENT PRIMARY KEY,
receive_datetime DATETIME NOT NULL,
slip_count INT DEFAULT 0,
detail_count INT DEFAULT 0,
item_count INT DEFAULT 0,
success_flag TINYINT NOT NULL,
message VARCHAR(500),
create_datetime DATETIME DEFAULT CURRENT_TIMESTAMP
);

---

## 12. JS処理

### 初期処理

* DOM取得
* loadHistory 実行

### 受信処理

1. ファイル未選択チェック
2. 確認ダイアログ
3. API呼び出し
4. 結果表示
5. 履歴再読込

### 履歴取得

* getReceiveHistory 呼び出し
* テーブル描画

---

## 13. 表示仕様

### 成功

* 緑表示

### 失敗

* 赤表示

---

## 14. エラー一覧

### CSV未選択

→ フロントで止める

### CSV構造エラー

→ 必須列不足

### データ不正

* 日付不正
* 数量不正

### マスタ不正

* 商品なし
* 取引先なし

### 履歴エラー

* テーブル未作成
* API未実装

---

## 15. 重要ポイント

### CSS注意

border-collapse: collapse と border-radius を同時に使うと角丸が崩れる

### 対策

* tableに角丸を付けない
* 外側divに角丸を付与
* tableは separate を使用

---

## まとめ

この機能は以下を実現する。

* CSVによる伝票一括登録
* マスタ連携チェック
* トランザクション制御
* 受信履歴管理（最大5件表示）

シンプルだが、実務でそのまま使える構成となっている。
