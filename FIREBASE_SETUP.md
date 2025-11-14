# Firebase設定手順

このドキュメントでは、Secret Friendsアプリ用のFirebase設定手順を説明します。

## 1. Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例: secret-friends）
4. Google Analyticsの設定（任意）
5. プロジェクトを作成

## 2. iOSアプリの設定

1. Firebase Consoleでプロジェクトを開く
2. 「iOSアプリを追加」をクリック
3. 以下の情報を入力：
   - iOSバンドルID: `io.secretfriends.secretFriends`（またはカスタムID）
   - アプリのニックネーム: Secret Friends iOS
   - App Store ID: （後で追加可能）

4. `GoogleService-Info.plist`をダウンロード
5. ダウンロードしたファイルを`ios/Runner/`ディレクトリに配置
6. Xcodeで追加（ファイルをドラッグ&ドロップ）

### iOSの追加設定

`ios/Runner/Info.plist`を開き、以下を追加：

```xml
<key>NSCameraUsageDescription</key>
<string>QRコードをスキャンするためにカメラを使用します</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>日記メモに画像を添付するために写真ライブラリにアクセスします</string>
```

## 3. Androidアプリの設定

1. Firebase Consoleでプロジェクトを開く
2. 「Androidアプリを追加」をクリック
3. 以下の情報を入力：
   - Androidパッケージ名: `io.secretfriends.secret_friends`（またはカスタムID）
   - アプリのニックネーム: Secret Friends Android
   - デバッグ用の署名証明書SHA-1: （後で追加可能）

4. `google-services.json`をダウンロード
5. ダウンロードしたファイルを`android/app/`ディレクトリに配置

### Androidの追加設定

`android/build.gradle.kts`を開き、以下を追加：

```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.2")
}
```

`android/app/build.gradle.kts`の最後に以下を追加：

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

`android/app/src/main/AndroidManifest.xml`を開き、`<application>`タグ内に以下を追加：

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## 4. Firebase Authentication の設定

1. Firebase Consoleで「Authentication」を選択
2. 「始める」をクリック
3. 「Sign-in method」タブを選択
4. 「匿名」を有効化
5. 「保存」をクリック

## 5. Cloud Firestoreの設定

1. Firebase Consoleで「Firestore Database」を選択
2. 「データベースを作成」をクリック
3. セキュリティルールを選択：
   - テストモードで開始（開発中）
   - 本番モードで開始（リリース時）
4. ロケーションを選択（asia-northeast1を推奨）
5. 「有効にする」をクリック

### セキュリティルール（本番用）

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

## 6. Firebase Storageの設定

1. Firebase Consoleで「Storage」を選択
2. 「始める」をクリック
3. セキュリティルールを確認
4. ロケーションを選択（Firestoreと同じ）
5. 「完了」をクリック

### セキュリティルール（本番用）

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

## 7. パッケージのインストール

プロジェクトルートで以下のコマンドを実行：

```bash
flutter pub get
```

## 8. FlutterFire CLIを使った自動設定（推奨）

上記の手動設定の代わりに、FlutterFire CLIを使用することもできます：

```bash
# Firebase CLIのインストール
npm install -g firebase-tools

# FlutterFire CLIのインストール
dart pub global activate flutterfire_cli

# Firebaseにログイン
firebase login

# プロジェクトの設定
flutterfire configure
```

このコマンドを実行すると、自動的にiOSとAndroidの設定ファイルが生成されます。

## 注意事項

- 本番環境では必ずセキュリティルールを適切に設定してください
- APIキーや設定ファイルをGitにコミットする場合、`.gitignore`に追加することを検討してください
- 匿名認証は一時的なものなので、デバイスを変更するとデータが失われます


