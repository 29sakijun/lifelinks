# Secret Friends

カレンダー・シフト管理・日記メモ・TODO管理ができる多機能SNSアプリです。友達とQRコードで繋がり、公開設定したコンテンツを共有できます。

## 主な機能

### 📅 カレンダー
- 月間カレンダービューで全ての予定を一覧表示
- シフト、日記メモ、TODOがカレンダー上に表示
- 日付をタップして詳細を確認・追加

### 💼 シフト管理
- 複数の勤務先を登録・管理
- 時給・日給の設定
- 残業手当、深夜手当、休日手当の自動計算
- 締日・給料日の設定
- 手当・天引の記録

### 💰 給料管理
- 勤務先ごとの総勤務時間と給料見込みを表示
- 全勤務先の合計を一目で確認
- 給料日の自動計算

### 📝 日記メモ
- テキスト（500文字まで）と画像（最大10枚）を保存
- 対象日の設定（設定しない場合は作成日に表示）
- 写真の撮影・ギャラリーからの選択

### ✅ TODO管理
- タスクの追加・完了管理
- 締切日時の設定
- 完了タスクの確認

### 👥 友達機能
- QRコードで友達を追加
- 友達ごとにカラー設定
- 公開するコンテンツ（日記メモ・TODO・シフト）を選択
- 友達の公開コンテンツをカレンダーで確認

### 🔍 フィルタ機能
- シフト・日記メモ・TODOで絞り込み
- 公開のみ表示

## セットアップ手順

### 1. 前提条件

- Flutter SDK（最新版）
- Firebase プロジェクト
- iOS開発の場合：Xcode、CocoaPods
- Android開発の場合：Android Studio

### 2. Flutterのインストール

```bash
# Flutterのバージョン確認
flutter --version

# パッケージのインストール
flutter pub get
```

### 3. Firebaseの設定

詳細な手順は `FIREBASE_SETUP.md` を参照してください。

#### 簡易手順：

1. [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
2. iOSアプリを追加し、`GoogleService-Info.plist`を`ios/Runner/`に配置
3. Androidアプリを追加し、`google-services.json`を`android/app/`に配置
4. Firebase Authentication で「匿名」認証を有効化
5. Cloud Firestore を作成
6. Firebase Storage を有効化

#### FlutterFire CLIを使用する場合（推奨）：

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

### 4. アプリの実行

```bash
# iOSシミュレータで実行
flutter run -d ios

# Androidエミュレータで実行
flutter run -d android

# 接続されたデバイスで実行
flutter run
```

## プロジェクト構造

```
lib/
├── constants/          # 定数定義
│   └── app_constants.dart
├── models/            # データモデル
│   ├── user_model.dart
│   ├── workplace_model.dart
│   ├── shift_model.dart
│   ├── diary_memo_model.dart
│   ├── todo_model.dart
│   └── friendship_model.dart
├── providers/         # 状態管理（Provider）
│   ├── auth_provider.dart
│   └── data_provider.dart
├── screens/          # 画面
│   ├── onboarding/   # 初回登録
│   ├── home/         # カレンダー
│   ├── shift/        # シフト管理
│   ├── salary/       # 給料管理
│   ├── diary/        # 日記メモ
│   ├── todo/         # TODO
│   ├── filter/       # フィルタ
│   └── settings/     # 設定
├── services/         # Firebaseサービス
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── utils/            # ユーティリティ
│   ├── date_utils.dart
│   └── salary_calculator.dart
├── widgets/          # 共通ウィジェット
│   ├── add_item_dialog.dart
│   └── calendar_item_card.dart
└── main.dart         # エントリーポイント
```

## 使用パッケージ

### Firebase
- `firebase_core`: Firebase初期化
- `firebase_auth`: 匿名認証
- `cloud_firestore`: データベース
- `firebase_storage`: 画像ストレージ

### UI
- `table_calendar`: カレンダー表示
- `qr_flutter`: QRコード生成
- `mobile_scanner`: QRコードスキャン
- `image_picker`: 画像選択

### その他
- `provider`: 状態管理
- `intl`: 日付フォーマット
- `uuid`: ユニークID生成
- `shared_preferences`: ローカルストレージ

## セキュリティルール

本番環境では、必ずFirebaseのセキュリティルールを設定してください。
詳細は `FIREBASE_SETUP.md` を参照してください。

## 利用規約・プライバシーポリシー

初回起動時に表示される利用規約とプライバシーポリシーは、
`lib/constants/app_constants.dart` で定義されています。
本番環境では、適切な内容に変更してください。

## トラブルシューティング

### iOS
- `pod install`エラーの場合：
  ```bash
  cd ios
  pod repo update
  pod install
  ```

### Android
- Gradleビルドエラーの場合：
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

### Firebase
- 認証エラー：Firebase Consoleで匿名認証が有効化されているか確認
- データベースエラー：Firestoreのセキュリティルールを確認

## ライセンス

このプロジェクトはプライベートプロジェクトです。

## サポート

問題が発生した場合は、以下を確認してください：
1. `FIREBASE_SETUP.md`の手順に従っているか
2. Firebase Consoleの設定が正しいか
3. 必要な権限が全て設定されているか

## 今後の拡張予定

- [ ] プッシュ通知（締切日、給料日のリマインダー）
- [ ] ダークモード対応
- [ ] 他の認証方法の追加（メール、Google）
- [ ] データのエクスポート機能
- [ ] グラフ表示（勤務時間、給料の推移）
