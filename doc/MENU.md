# 📘 MENU.md（メニュー画面仕様書）

---

## 1. 概要

`menu` は、Hara LogiApp のトップ画面（ホーム画面）である。

この画面の役割は以下の3つ。

1. 各機能へのナビゲーション
2. 当日の業務状況の可視化（ダッシュボード）
3. 最近の伝票へのクイックアクセス

---

## 2. 対象ファイル構成

本画面は以下の3ファイルで構成する。

* menu.cfm（画面）
* menu.cfc（データ取得API）
* menu.js（制御・イベント・描画） 

---

## 3. 画面構成

### 3.1 メニューエリア

以下の6つの主要メニューを配置する。

| ボタン名   | 遷移先               |
| ------ | ----------------- |
| 伝票登録   | add_slip.cfm      |
| 伝票一覧   | slip_list.cfm     |
| 集計レポート | total_report.cfm  |
| 在庫管理   | inventory.cfm     |
| マスタ    | モーダル表示            |
| 基本設定   | admin_setting.cfm |

※ 在庫管理を追加（inventory_button）

---

### 3.2 マスタモーダル

| ボタン名   | 遷移先            |
| ------ | -------------- |
| 商品マスタ  | m_item.cfm     |
| 取引先マスタ | m_supplier.cfm |
| 社員マスタ  | m_staff.cfm    |

---

### 3.3 ユーザーメニュー

* トグル開閉式
* 外側クリックで閉じる
* ログアウト → login.cfm

---

## 4. ダッシュボード仕様

初期表示時にAPIからデータを取得する。

### 4.1 表示項目

| 項目        | 内容      |
| --------- | ------- |
| 今日の伝票数    | 当日登録件数  |
| 未確定伝票数    | ステータス=1 |
| 今日の商品合計数量 | 数量合計    |
| 今日の合計金額   | 金額合計    |
| 削除伝票数     | 当日削除件数  |

---

### 4.2 KPIカードクリック挙動（重要）

#### ■ 今日の伝票数

→ 伝票一覧へ（当日で絞り込み）

```js
submitSlipListForm({
    return_search_order_date_from: today,
    return_search_order_date_to: today
});
```

---

#### ■ 未確定伝票数

→ 未確定のみ表示

```js
submitSlipListForm({
    return_search_status: "1"
});
```

---

#### ■ 今日の商品合計数量

→ 集計レポート（数量モード）

```js
submitTotalReportForm("qty");
```

---

#### ■ 今日の合計金額

→ 集計レポート（金額モード）

```js
submitTotalReportForm("amount");
```

---

## 5. 画面遷移仕様（重要）

### 5.1 通常遷移

```js
location.href = "xxxx.cfm";
```

---

### 5.2 POST遷移（状態保持）

本システムの重要設計。

#### ■ 伝票一覧遷移

```js
submitSlipListForm(params);
```

保持内容：

* 検索条件
* ページ
* ソート

---

#### ■ 伝票詳細遷移

```js
submitSlipDetailForm(slipNo);
```

特徴：

* 戻り先制御あり（return_from_menu）
* 状態リセット

---

#### ■ 集計レポート遷移

```js
submitTotalReportForm(mode);
```

特徴：

* 当日自動セット
* dashboard_modeで表示切替

---

## 6. ダッシュボードデータ取得

```js
fetch("menu.cfc?method=getDashboardData&returnformat=json")
```

* GET通信
* JSON形式
* 非同期（async/await）

---

## 7. データ描画処理

### 7.1 数値フォーマット

```js
Number(value).toLocaleString();
```

* 金額 → ¥付与
* 件数 → 「件」付与

---

### 7.2 最近の伝票描画

```js
renderRecentSlipList(recentSlips);
```

表示内容：

* 伝票番号
* 発注日
* 納品日
* 取引先
* ステータス

---

### 7.3 行クリック

```js
submitSlipDetailForm(slipNo);
```

---

## 8. エラーハンドリング

```js
showDashboardError(message);
```

動作：

* 全項目を「-」表示
* エラーメッセージ表示

---

## 9. UI/UX仕様

* カード型UI
* クリック可能領域を広く
* 状態保持を最優先
* 色設計：

| 要素    | 色       |
| ----- | ------- |
| メイン   | #476C59 |
| 背景    | #F7F1E3 |
| アクセント | #F1D98A |

---

## 10. 設計思想（重要）

この画面の設計は以下を最優先とする。

* 業務の起点（すべてここから始まる）
* 状態を失わない遷移
* 一目で状況がわかるUI
* 迷わない導線

---

## 11. 今後の拡張

* 在庫ダッシュボード追加
* グラフ表示
* アラート通知（未処理・期限切れ）
* 権限制御

---

## 12. 補足

この画面は「業務の入口」であるため、

* 即判断できること
* ワンクリックで遷移できること
* 状態が維持されること

を最重要とする。
