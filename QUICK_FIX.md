# 🚨 保存できない問題の解決方法

## 原因

Firebaseの以下の設定が完了していません：
1. Authentication（匿名認証）が有効化されていない
2. Firestore Databaseが作成されていない、または
3. Firestoreのインデックスが作成されていない

---

## ✅ 解決手順（5分で完了）

### ステップ1：Firebase Consoleを開く

[https://console.firebase.google.com/](https://console.firebase.google.com/)

プロジェクト「**secret-friends-453ee**」を選択

---

### ステップ2：Authentication（認証）を有効化

1. 左メニュー → 「**構築**」 → 「**Authentication**」
2. 「**始める**」をクリック
3. 「**Sign-in method**」タブを選択
4. 「**匿名**」の行をクリック
5. 「**有効にする**」をオンにする
6. 「**保存**」をクリック

✅ これで匿名ログインが有効になります

---

### ステップ3：Firestore Databaseを作成

1. 左メニュー → 「**構築**」 → 「**Firestore Database**」
2. 「**データベースを作成**」をクリック
3. ロケーション：**asia-northeast1**（東京）を選択
4. セキュリティルール：「**テストモードで開始**」を選択
   - ⚠️ テストモードは開発用です。本番では変更が必要です
5. 「**有効にする**」をクリック

✅ これでデータベースが作成されます

---

### ステップ4：Storageを有効化

1. 左メニュー → 「**構築**」 → 「**Storage**」
2. 「**始める**」をクリック
3. セキュリティルール：デフォルトのまま「**次へ**」
4. ロケーション：**asia-northeast1**（東京）を選択
5. 「**完了**」をクリック

✅ これで画像アップロードができるようになります

---

### ステップ5：Firestoreインデックスを作成

以下の5つのリンクを順番に開いて、「**インデックスを作成**」ボタンをクリック：

#### 1. Workplaces（勤務先）
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Cldwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvd29ya3BsYWNlcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC

#### 2. Shifts（シフト）
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=ClNwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvc2hpZnRzL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGggKBGRhdGUQAhoMCghfX25hbWVfXxAC

#### 3. DiaryMemos（日記メモ）
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Cldwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvZGlhcnlNZW1vcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC

#### 4. Todos（TODO）
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=ClJwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdG9kb3MvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg

#### 5. Friendships（友達）
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Clhwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvZnJpZW5kc2hpcHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg

各リンクを開いたら：
1. 「**インデックスを作成**」ボタンをクリック
2. すべてのインデックスが「**ビルド中**」→「**有効**」になるまで待つ（数分）

---

### ステップ6：アプリを再起動

すべての設定が完了したら、ターミナルで：

```bash
flutter run -d "3E9D0BC9-4D31-4523-A1A1-6D6989DFCCCA"
```

---

## ⚠️ よくある質問

### Q: インデックスのビルドはどれくらいかかる？
**A:** 数秒〜数分です。「有効」になるまで待ってください。

### Q: テストモードは安全？
**A:** 開発中のみ使用してください。本番リリース前に必ずセキュリティルールを設定してください。

### Q: インデックスが必要な理由は？
**A:** Firestoreは複数フィールドでのソート・フィルタにインデックスが必要です。

---

## 🎯 完了すると

- ✅ シフトの登録・編集ができる
- ✅ 日記メモの保存ができる
- ✅ TODOの追加ができる
- ✅ 友達の追加ができる
- ✅ すべてのデータが正常に保存される

---

上記の手順を完了させてから、アプリを再起動してください！
















