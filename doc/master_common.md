# マスタ画面 共通設計

## 概要

本ドキュメントは、すべてのマスタ画面に共通する設計ルールを定義する。

---

# 基本思想（最重要）

```text
staff_id = 今表示しているデータ
return_staff_id = 戻るためのデータ
```

この2つは必ず分けること。

---

# 画面遷移ルール

## 一覧 → 詳細

```text
staff_id = 選択ID
return_staff_id = 選択ID
```

---

## 一覧 → 追加

```text
staff_id = ""
return_staff_id = ""
```

---

## 詳細 → 修正

```text
staff_id = 表示ID
return_staff_id = 表示ID
```

---

## 詳細 → 追加

```text
staff_id = ""
return_staff_id = 元の詳細ID
```

---

# 戻り動作

## キャンセル

```text
return_staff_id がある → 詳細へ
return_staff_id がない → 一覧へ
```

---

## 保存後

### 追加時

```text
return_staff_id がない → 一覧へ
return_staff_id がある → 新規データ詳細へ
```

### 修正時

```text
保存後 → 詳細へ
```

---

# hidden構成

## 一覧画面

```html
<input type="hidden" name="staff_id">
<input type="hidden" name="return_staff_id">
<input type="hidden" name="display_mode">
```

---

## 詳細画面

```html
<input type="hidden" id="staff_id">
<input type="hidden" id="return_staff_id">
<input type="hidden" id="display_mode">
```

---

# JS共通処理

## POST遷移

```javascript
function submitPost(action, params) {
  const form = document.createElement("form");
  form.method = "post";
  form.action = action;

  Object.keys(params).forEach(key => {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = key;
    input.value = params[key] || "";
    form.appendChild(input);
  });

  document.body.appendChild(form);
  form.submit();
}
```

---

## ID取得

```javascript
function getReturnId() {
  return getValue("return_staff_id") || getValue("staff_id");
}
```

---

# NGパターン

❌ staff_idだけで制御
→ 戻れなくなる

❌ addでもDB読み込み
→ データが残る

❌ return_xxx_id未使用
→ 遷移崩壊

---

# 共通ルールまとめ

```text
return_xxx_id を必ず使う
add時は必ず初期化
戻り先は return_xxx_id で判断
```

---
