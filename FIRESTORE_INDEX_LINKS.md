# Firestoreインデックス作成リンク

アプリを起動時に表示されたエラーから、以下のリンクをクリックしてインデックスを作成してください。

## インデックス作成リンク

### 1. Workplaces（勤務先）
```
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Cldwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvd29ya3BsYWNlcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

### 2. Shifts（シフト）
```
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=ClNwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvc2hpZnRzL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGggKBGRhdGUQAhoMCghfX25hbWVfXxAC
```

### 3. DiaryMemos（日記メモ）
```
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Cldwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvZGlhcnlNZW1vcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

### 4. Todos（TODO）
```
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=ClJwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdG9kb3MvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

### 5. Friendships（友達）
```
https://console.firebase.google.com/v1/r/project/secret-friends-453ee/firestore/indexes?create_composite=Clhwcm9qZWN0cy9zZWNyZXQtZnJpZW5kcy00NTNlZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvZnJpZW5kc2hpcHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

## 手順

1. 上記の各リンクをブラウザで開く
2. Firebaseにログイン
3. 「インデックスを作成」ボタンをクリック
4. すべてのインデックスが「ビルド中」→「有効」になるまで待つ（数分かかる場合があります）
5. アプリを再起動: `flutter run -d "3E9D0BC9-4D31-4523-A1A1-6D6989DFCCCA"`

## 注意

- インデックスのビルドには数分かかることがあります
- すべてのインデックスが「有効」になってからアプリを使用してください
- インデックスが有効になる前にアプリを使うとエラーが出ます
















