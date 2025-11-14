# 🔐 認証設定ガイド

## 📋 目次

1. [Firebaseコンソールでの認証設定](#1-firebaseコンソールでの認証設定)
2. [Apple認証の追加設定](#2-apple認証の追加設定)
3. [Google認証の追加設定](#3-google認証の追加設定)
4. [カスタムドメインでのメール送信設定](#4-カスタムドメインでのメール送信設定)
5. [テスト方法](#5-テスト方法)

---

## 1. Firebaseコンソールでの認証設定

### ステップ1: Firebaseコンソールにアクセス

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクトを選択
3. 左メニューから **Authentication** をクリック
4. **Sign-in method** タブを選択

### ステップ2: メール/パスワード認証を有効化

1. **Email/Password** をクリック
2. **有効にする** をONにする
3. **メールリンク（パスワード不要）** もONにする（オプション）
4. **保存** をクリック

### ステップ3: Google認証を有効化

1. **Google** をクリック
2. **有効にする** をON
3. **プロジェクトのサポートメール** を選択（例: your-email@gmail.com）
4. **保存** をクリック

### ステップ4: Apple認証を有効化

1. **Apple** をクリック
2. **有効にする** をON
3. **保存** をクリック

---

## 2. Apple認証の追加設定

### A. Apple Developer Consoleでの設定

1. [Apple Developer](https://developer.apple.com/account) にアクセス
2. **Certificates, Identifiers & Profiles** をクリック
3. **Identifiers** を選択
4. あなたのアプリID（例: `com.example.secret_friends`）をクリック
5. **Capabilities** セクションで **Sign in with Apple** にチェック
6. **Save** をクリック

### B. Xcodeでの設定

1. ターミナルで以下のコマンドを実行してXcodeを開く:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Xcodeで:
   - 左側のプロジェクトナビゲーターから **Runner** を選択
   - **Signing & Capabilities** タブをクリック
   - **+ Capability** ボタンをクリック
   - **Sign in with Apple** を検索して追加
   - Xcodeを閉じる

3. 変更を保存:
   ```bash
   git add ios/Runner.xcodeproj/project.pbxproj
   git commit -m "Add Sign in with Apple capability"
   ```

---

## 3. Google認証の追加設定

### Android設定

Android用の追加設定は **不要** です。`google-services.json` に必要な情報が含まれています。

### iOS設定

1. `ios/Runner/Info.plist` に以下を追加（既に含まれている場合はスキップ）:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Google Sign-In用のReversed Client ID -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

2. `GoogleService-Info.plist` から `REVERSED_CLIENT_ID` を確認:
   ```bash
   grep -A 1 "REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist
   ```

3. 上記の `YOUR_CLIENT_ID` を実際の `REVERSED_CLIENT_ID` に置き換える

---

## 4. カスタムドメインでのメール送信設定

Firebase Authenticationのメール（確認メール、パスワードリセットメール）は、デフォルトでは `noreply@[your-project-id].firebaseapp.com` から送信されます。

### 📧 カスタムドメインを使用するメリット

- **プロフェッショナルな印象**: `noreply@yourdomain.com` から送信
- **信頼性の向上**: ユーザーがメールを開く可能性が高まる
- **ブランディング**: 自社ドメインでメールを送信

### 🚀 設定方法（Firebase Blaze プラン必要）

#### ステップ1: Blazeプランにアップグレード

1. [Firebase Console](https://console.firebase.google.com/) → プロジェクトを選択
2. 左下の **⚙️ 設定** → **使用状況と請求** → **詳細と設定**
3. **プランを変更** → **Blazeプラン** を選択
4. 支払い情報を入力して完了

**💰 料金**: 従量課金制（月$25のクレジット付き）

#### ステップ2: カスタムメールアクションハンドラーを設定

Firebase Authenticationのカスタムドメイン設定には、**Firebase Hosting** と **Cloud Functions** を使用します。

##### 2-1. Firebase Hostingのセットアップ

```bash
# Firebase CLIをインストール（未インストールの場合）
npm install -g firebase-tools

# Firebaseにログイン
firebase login

# Hostingを初期化
firebase init hosting
```

初期化時の設定:
- Public directory: `build/web`
- Configure as single-page app: **Yes**
- Set up automatic builds: **No**

##### 2-2. カスタムドメインを追加

1. [Firebase Console](https://console.firebase.google.com/) → **Hosting**
2. **カスタムドメインを追加** をクリック
3. あなたのドメイン（例: `yourdomain.com`）を入力
4. DNSレコードを追加（Firebaseが提供するレコードをドメインレジストラに追加）:
   - **Aレコード** または **CNAMEレコード**
   - 確認まで数時間〜24時間かかる場合があります

##### 2-3. メールアクションハンドラーのカスタマイズ

1. Firebase Console → **Authentication** → **Templates** タブ
2. テンプレート（メール確認、パスワードリセットなど）を選択
3. **カスタマイズ** をクリック
4. **送信者名** と **送信者メールアドレス** を設定:
   - 送信者名: `LifeLink`
   - 送信者メール: `noreply@yourdomain.com`

5. **アクションURL** をカスタムドメインに変更:
   ```
   https://yourdomain.com/__/auth/action
   ```

##### 2-4. SMTPサーバーの設定（より高度な設定）

より詳細な制御が必要な場合は、以下のサービスを使用してSMTP経由でメールを送信できます:

**推奨サービス:**
- **SendGrid** (無料枠: 100通/日)
- **Mailgun** (無料枠: 5,000通/月)
- **Amazon SES** (従量課金)

**設定手順（SendGrid の例）:**

1. [SendGrid](https://sendgrid.com/) でアカウントを作成
2. **API Key** を作成
3. **Sender Identity** を設定（あなたのドメイン）
4. Cloud Functions で SendGrid を使用してメールを送信:

```javascript
const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');

sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendCustomEmail = functions.https.onCall(async (data, context) => {
  const msg = {
    to: data.email,
    from: 'noreply@yourdomain.com',
    subject: data.subject,
    html: data.html,
  };
  
  await sgMail.send(msg);
  return { success: true };
});
```

5. Firebase Functions をデプロイ:
   ```bash
   firebase deploy --only functions
   ```

#### ステップ3: ドメイン認証（SPF/DKIM設定）

メールの配信率を向上させるため、以下のDNSレコードを追加します:

**SPFレコード（TXTレコード）:**
```
v=spf1 include:_spf.google.com ~all
```

**DKIMレコード:**
SendGrid や Mailgun が提供するDKIMキーをDNSに追加

---

## 5. テスト方法

### メール/パスワード認証のテスト

1. アプリを起動
2. **メールアドレスでログイン** をタップ
3. 下部の **新規登録** をタップ
4. メールアドレスとパスワードを入力
5. 確認メールが届くことを確認
6. メールのリンクをクリックしてアカウントを有効化
7. ログインできることを確認

### Google認証のテスト

1. アプリを起動
2. **Googleでサインイン** をタップ
3. Googleアカウントを選択
4. 権限を許可
5. ニックネーム登録画面またはホーム画面に遷移することを確認

### Apple認証のテスト（iOSのみ）

1. アプリを起動（iOS実機またはシミュレータ）
2. **Appleでサインイン** をタップ
3. Apple IDでサインイン
4. 権限を許可
5. ニックネーム登録画面またはホーム画面に遷移することを確認

### 匿名アカウントのリンク機能のテスト

1. 匿名ログインでアプリを使用
2. **設定** → **プロフィール** に移動
3. **アカウントをリンク** ボタンをタップ（実装が必要）
4. 認証方法を選択（Google、Apple、メール）
5. リンクが成功することを確認
6. データが保持されていることを確認

---

## 🔧 トラブルシューティング

### Google認証が動作しない

- `google-services.json` と `GoogleService-Info.plist` が最新か確認
- Firebase Console でSHA-1フィンガープリントが正しく設定されているか確認（Android）
- `Info.plist` に `REVERSED_CLIENT_ID` が設定されているか確認（iOS）

### Apple認証が動作しない

- Apple Developer で **Sign in with Apple** が有効になっているか確認
- Xcodeで **Sign in with Apple** Capability が追加されているか確認
- iOS 13以降のデバイスを使用しているか確認

### メールが届かない

- 迷惑メールフォルダを確認
- Firebase Console の **Authentication** → **Templates** でメールテンプレートが有効か確認
- カスタムドメインを使用している場合、DNS設定が正しいか確認

---

## 📚 参考リンク

- [Firebase Authentication ドキュメント](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple for Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Hosting カスタムドメイン](https://firebase.google.com/docs/hosting/custom-domain)
- [SendGrid ドキュメント](https://docs.sendgrid.com/)

---

## ✅ 実装チェックリスト

- [ ] Firebase Console で3つの認証方法を有効化
- [ ] Apple Developer で Sign in with Apple を有効化
- [ ] Xcodeで Sign in with Apple Capability を追加
- [ ] Google認証のReversed Client IDを設定（iOS）
- [ ] メール/パスワード認証のテスト
- [ ] Google認証のテスト
- [ ] Apple認証のテスト（iOS実機）
- [ ] カスタムドメインの設定（Blazeプラン必要）
- [ ] SPF/DKIM設定
- [ ] 匿名アカウントのリンク機能の実装とテスト

