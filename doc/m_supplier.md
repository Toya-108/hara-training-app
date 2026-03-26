# 取引先マスタ仕様

## 概要

取引先情報を管理するマスタ

---

## 項目一覧

* 取引先コード（必須）
* 取引先名（必須）
* カナ
* 郵便番号
* 住所
* 電話番号
* 配送業者
* 使用区分
* 備考

---

## 特記事項

### 郵便番号検索

* 郵便番号から住所自動入力

---

### 配送業者

* m_delivery_company を参照

---

## 画面仕様

### 一覧

* セレクト検索あり

---

### 詳細

* view / edit / add モード切替あり

---

## API

### 保存

```text
m_supplier_dt.cfc?method=saveSupplier
```

---

### 削除

```text
m_supplier_dt.cfc?method=deleteSupplier
```

---

## 注意点

* 郵便番号はフォーマットチェック
* return_supplier_id を必ず維持する

---
