# 🚀 次のステップ

Firebaseの設定が完了しました！アプリを実行する前に、Firebase Consoleでいくつかの設定を行う必要があります。

## 📋 Firebase Consoleでの設定

### 1. Firebase Consoleにアクセス

[https://console.firebase.google.com/](https://console.firebase.google.com/)

プロジェクト: **secret-friends-453ee** を選択

---

### 2. ✅ Authentication（認証）の設定

1. 左メニューから「**構築 > Authentication**」を選択
2. 「**始める**」をクリック
3. 「**Sign-in method**」タブを選択
4. 「**匿名**」の行で「有効にする」をクリック
5. 「**保存**」をクリック

**✨ これで匿名ログインが有効になります**

---

### 3. ✅ Firestore Database（データベース）の設定

1. 左メニューから「**構築 > Firestore Database**」を選択
2. 「**データベースを作成**」をクリック
3. **ロケーションを選択**:
   - 推奨: `asia-northeast1` (東京)
   - または: `asia-northeast2` (大阪)
4. **セキュリティルールを選択**:
   - 開発中: 「**テストモードで開始**」
   - 本番環境: 「**本番モードで開始**」（後でルールを設定）
5. 「**有効にする**」をクリック

**本番用セキュリティルール**（後で設定）:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーデータ
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 勤務先マスター
    match /workplaces/{workplaceId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // シフト
    match /shifts/{shiftId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.sharedWith[request.auth.uid] == true
      );
      allow write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // 日記メモ
    match /diaryMemos/{memoId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.sharedWith[request.auth.uid] == true
      );
      allow write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // TODO
    match /todos/{todoId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.sharedWith[request.auth.uid] == true
      );
      allow write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // 友達関係
    match /friendships/{friendshipId} {
      allow read, write: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.friendId == request.auth.uid
      );
    }
  }
}
```

---

### 4. ✅ Firebase Storage（ストレージ）の設定

1. 左メニューから「**構築 > Storage**」を選択
2. 「**始める**」をクリック
3. **セキュリティルールを確認**:
   - 開発中: デフォルトのルール
   - 本番環境: カスタムルール（後で設定）
4. **ロケーションを選択**: Firestoreと同じロケーションを推奨
5. 「**完了**」をクリック

**本番用セキュリティルール**（後で設定）:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🎯 アプリの実行

上記の設定が完了したら、アプリを実行できます：

```bash
# プロジェクトディレクトリに移動
cd /Users/jun.fukusaki/dev/secretdiary/secret_friends

# iOSシミュレータで実行
flutter run -d ios

# Androidエミュレータで実行
flutter run -d android

# 接続されたデバイスで実行
flutter run
```

---

## 📱 初回起動の流れ

1. **スプラッシュ画面** → 自動的に匿名ログイン
2. **利用規約・プライバシーポリシー確認** → 両方にチェック
3. **ニックネーム登録** → 入力またはスキップ
4. **カレンダー画面（メイン画面）** → アプリ起動完了！

---

## 🔍 トラブルシューティング

### エラー: Firebase認証エラー

**原因**: Authentication（匿名認証）が有効化されていない

**解決策**: Firebase Consoleで匿名認証を有効化

---

### エラー: Firestoreへの書き込みエラー

**原因**: Firestoreが作成されていない、またはセキュリティルールが厳しすぎる

**解決策**: 
1. Firestoreを作成
2. 開発中は「テストモード」を使用

---

### エラー: 画像アップロードエラー

**原因**: Storageが有効化されていない

**解決策**: Firebase ConsoleでStorageを有効化

---

### エラー: iOS/Androidビルドエラー

```bash
# iOS
cd ios
pod install
cd ..

# Android
cd android
./gradlew clean
cd ..

# プロジェクト全体
flutter clean
flutter pub get
```

---

## 🎉 完成！

これで Secret Friends アプリが完全に動作するはずです！

### 主な機能の確認

- [ ] カレンダー表示
- [ ] シフト追加・編集
- [ ] 給料計算
- [ ] 日記メモ（テキスト・画像）
- [ ] TODO管理
- [ ] 友達追加（QRコード）
- [ ] 公開設定

---

## 📝 メモ

- 利用規約・プライバシーポリシーは `lib/constants/app_constants.dart` で編集できます
- 本番リリース前に必ずセキュリティルールを適切に設定してください
- 匿名認証はデバイス変更時にデータが失われるので注意してください
















