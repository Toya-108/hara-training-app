# 伝票登録画面仕様

## 概要

本画面は、伝票ヘッダ情報と商品明細を1画面でまとめて登録するための画面である。
画面ファイルは `add_slip.cfm`、画面制御は `add_slip.js`、登録APIは `add_slip.cfc` を使用する。
ヘッダには発注日・取引先・納品日・備考を持ち、明細には商品コード・商品名・数量・単価を複数行入力する。

---

## 対象ファイル

* 画面: `add_slip.cfm`
* JS: `add_slip.js`
* API: `add_slip.cfc`

---

## 画面構成

### 1. 伝票基本情報

入力項目は以下。

* 発注日（必須）
* 取引先（必須）
* 納品日（必須）
* 備考

発注日と納品日は flatpickr による日付入力を使用する。
取引先は直接入力ではなく、モーダルから選択する。
実際に送信する値は以下の hidden で保持する。

* `supplier_code`
* `supplier_name`

表示欄には `supplier_display` を使用する。

---

### 2. 商品明細

明細テーブルは複数行入力可能とし、初期表示では1行持つ。
入力項目は以下。

* 商品コード
* 商品名
* 数量
* 単価
* 削除ボタン

「行追加」ボタンで新規行を追加する。
削除ボタン押下時は確認ダイアログを出し、最後の1行は削除不可とする。

---

### 3. 操作ボタン

画面下部に以下のボタンを配置する。

* クリア
* 登録

ヘッダの戻るボタン押下時は `menu.cfm` へ遷移する。

---

## フロントエンド仕様

### 初期化処理

画面読み込み時に以下を実行する。

* 必須チェック初期化
* Enterキー移動設定
* 明細テーブル用 Enterキー移動設定
* 商品コード blur 時の自動補完設定
* flatpickr 初期化
* 取引先モーダル関連イベントのバインド
* 登録処理イベントのバインド

---

### 必須チェック

必須項目は `CommonValidation.setupRequiredValidation(form)` と
`CommonValidation.validateRequiredFields(form)` を使って検証する。

対象は以下。

* 発注日
* 取引先
* 納品日

未入力時は SweetAlert2 で警告を表示し、送信しない。

---

### 明細チェック

登録時はまず `collectDetailList()` で入力済み明細のみ配列化する。
その後 `getDetailErrorMessage()` で明細エラーをチェックする。

検証内容は以下。

* 明細が1行以上あること
* 商品コードが空でないこと
* 商品名が空でないこと
* 数量が空でないこと
* 単価が空でないこと
* 数量が1以上であること
* 単価が0以上であること

1件でも不正があれば SweetAlert2 でメッセージ表示して中断する。

---

### 取引先選択モーダル

取引先はモーダル検索方式とする。
`m_supplier.cfc?method=getSupplierList&returnformat=json` を呼び出し、
検索条件は以下を JSON で送る。

* `search_supplier_code`
* `search_supplier_name`

モーダル内の一覧で「選択」押下時、以下をセットする。

* `supplier_code`
* `supplier_name`
* `supplier_display`

モーダル背景クリックまたは「閉じる」押下で閉じる。

---

### 商品コード自動補完

明細の `item_code` 入力欄 blur 時に
`add_slip.cfc?method=getItemByCode&returnformat=json` を呼び出す。

送信JSON:

* `item_code`

成功時:

* `item_name` を自動入力
* `unit_price` に `gentanka` を自動入力

該当商品なしの場合:

* 商品名と単価をクリア
* SweetAlert2 で警告表示

通信エラー時:

* SweetAlert2 でエラー表示

---

### クリア処理

「クリア」押下時は確認ダイアログを表示し、OK時に以下を実行する。

* `form.reset()`
* メッセージクリア
* エラー表示クリア
* 明細を初期1行へ戻す
* 取引先選択状態をクリア

---

### 登録処理

登録ボタン押下時の流れは以下。

1. 必須チェック
2. 明細収集
3. 明細内容チェック
4. 確認ダイアログ表示
5. `add_slip.cfc?method=saveSlip&returnformat=json` を POST
6. 成功時は画面初期化後に完了ダイアログ表示
7. 失敗時はエラーダイアログ表示

送信JSONの構造は以下。

```json
{
  "slip_date": "",
  "supplier_code": "",
  "supplier_name": "",
  "delivery_date": "",
  "memo": "",
  "detail_list": [
    {
      "item_code": "",
      "item_name": "",
      "qty": "",
      "unit_price": ""
    }
  ]
}
```

---

## バックエンド仕様

### saveSlip

`add_slip.cfc` の `saveSlip` で伝票登録を行う。

#### 入力

* `slip_date`
* `supplier_code`
* `supplier_name`
* `delivery_date`
* `memo`
* `detail_list`

#### 必須チェック

以下をサーバー側でも検証する。

* 発注日
* 取引先コード
* 取引先名
* 納品日
* 明細1件以上
* `session.staffCode`
* `session.staffName`

#### 採番

伝票番号は以下の形式で採番する。

```text
YYMMDD + 4桁連番
```

例:

```text
2603260001
```

採番方法:

1. 発注日から `yymmdd` を作成
2. `t_slip` から同日 prefix の最大 `slip_no` を取得
3. 末尾4桁を +1 して新しい伝票番号を生成

#### 登録処理

`cftransaction isolation="serializable"` 内で以下を実行する。

1. `t_slip` にヘッダ登録
2. `detail_list` をループし `t_slip_detail` に明細登録

ヘッダ登録項目:

* `slip_no`
* `slip_date`
* `supplier_code`
* `supplier_name`
* `delivery_date`
* `status`
* `memo`
* 作成/更新日時
* 作成/更新者コード
* 作成/更新者名

明細登録項目:

* `slip_no`
* `line_no`
* `item_code`
* `item_name`
* `qty`
* `unit_price`
* 作成/更新日時
* 作成/更新者コード
* 作成/更新者名

#### ステータス値

ヘッダ登録時は `status = 1` を設定している。

#### 戻り値

成功時:

* `status = 0`
* `message = "伝票を登録しました。伝票番号：XXXX"`

失敗時:

* `status = 1`
* `message = エラーメッセージ`

---

### getItemByCode

商品コードから商品情報を取得する。

#### 入力

* `item_code`

#### 検索先

* `m_item`

#### 取得項目

* `item_code`
* `item_name`
* `gentanka`

#### 戻り値

成功時:

* `status = 0`
* `results.item_code`
* `results.item_name`
* `results.gentanka`

商品なし/失敗時:

* `status = 1`
* `message = エラーメッセージ`

---

## 使用ライブラリ

* `validation-common.js`
* `sweetalert2.all.min.js`
* `flatpickr.min.js`
* `ja.js`

---

## 注意点

### 1. ステータス値の扱い

`saveSlip` / `getItemByCode` は成功時 `status = 0` を返す。
一方で、取引先モーダルの `getSupplierList` 側は JS 上で `status === 1` を成功として扱っているため、
他APIと成功/失敗の値が異なる可能性がある。
APIごとのステータス定義は統一するか、READMEに必ず明記すること。

### 2. 戻るボタン

ヘッダの戻るボタンは現在 `menu.cfm` に固定遷移している。
一覧・詳細のような return系制御ではないため、必要に応じて今後統一方針を検討する。

### 3. 明細入力型

初期行テンプレートと `resetItemRows()` のテンプレートで
`qty` / `unit_price` の input type が一部異なっているため、必要に応じて統一すること。

### 4. サーバー側検証

現在の `saveSlip` は明細ごとに必須チェックを実施しているが、
数値型チェックは主にフロント側寄りである。
厳密にする場合は、サーバー側でも数量1以上・単価0以上を追加で検証すること。

---

## この画面の実装パターン名

この画面はマスタ詳細画面とは別の、以下のパターンとして扱う。

```text
ヘッダ + 明細行 + モーダル選択 + 一括保存型入力画面
```

今後、発注・入荷・出荷などの伝票系画面を作る場合は、本仕様を共通テンプレートとして流用する。
