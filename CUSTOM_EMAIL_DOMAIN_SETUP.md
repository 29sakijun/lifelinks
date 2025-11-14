# 📧 カスタムドメインでのメール送信設定ガイド

Firebase Authenticationのメールをカスタムドメイン（例: `noreply@yourdomain.com`）から送信する方法です。

---

## 📋 前提条件

### 必須
- ✅ カスタムドメインを所有している
- ✅ Firebase Blazeプラン（従量課金制）にアップグレード
- ✅ SMTPサービスのアカウント（SendGrid、Mailgun、Amazon SES など）

### 料金
- **Firebase Blazeプラン**: 月$25の無料クレジット付き（超過分のみ課金）
- **SendGrid**: 無料枠 100通/日
- **Mailgun**: 無料枠 5,000通/月
- **Amazon SES**: $0.10/1,000通（超低コスト）

---

## 🚀 方法1: Firebase Email Extension（推奨・簡単）

### ステップ1: Firebase Blazeプランへアップグレード

1. [Firebase Console](https://console.firebase.google.com/) → プロジェクトを選択
2. 左下の **⚙️ 設定** → **使用状況と請求**
3. **詳細と設定** → **プランを変更**
4. **Blazeプラン（従量課金制）** を選択
5. 支払い情報を入力

### ステップ2: Trigger Email Extension をインストール

1. Firebase Console → **Extensions** → **拡張機能を探す**
2. **Trigger Email** を検索してインストール
3. 以下を設定：
   - **SMTP接続文字列**: SendGridやMailgunの設定
   - **デフォルトの差出人メールアドレス**: `noreply@yourdomain.com`
   - **デフォルトの差出人名**: `LifeLink`

### ステップ3: SMTPサービスの設定（SendGridの例）

1. [SendGrid](https://sendgrid.com/) でアカウント作成
2. **Settings** → **API Keys** → **Create API Key**
3. **Full Access** を選択してキーを作成
4. API Keyをコピー（`SG.xxxxx...`）
5. **Sender Authentication** → **Single Sender Verification**
6. あなたのメールアドレス（`noreply@yourdomain.com`）を登録
7. 確認メールが届くのでリンクをクリック

### ステップ4: SMTP接続文字列を作成

```
smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:465
```

例：
```
smtps://apikey:SG.abc123xyz789@smtp.sendgrid.net:465
```

### ステップ5: Firebase Extensionに設定

1. Firebase Console → **Extensions** → **Trigger Email**
2. **SMTP接続文字列** に上記の文字列を入力
3. **デフォルトの差出人**: `noreply@yourdomain.com`
4. **有効化**

---

## 🚀 方法2: Cloud Functions で独自実装（高度）

### ステップ1: Cloud Functions をセットアップ

```bash
npm install -g firebase-tools
firebase login
firebase init functions
```

### ステップ2: SendGrid パッケージをインストール

```bash
cd functions
npm install @sendgrid/mail
```

### ステップ3: functions/index.js を編集

```javascript
const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');

// SendGrid API Key を設定
sgMail.setApiKey(functions.config().sendgrid.key);

// メール送信関数
exports.sendVerificationEmail = functions.auth.user().onCreate(async (user) => {
  const msg = {
    to: user.email,
    from: 'noreply@yourdomain.com',
    fromname: 'LifeLink',
    subject: 'メールアドレスの確認',
    html: `
      <h2>メールアドレスの確認</h2>
      <p>${user.email} さん、LifeLink へようこそ！</p>
      <p>以下のリンクをクリックしてメールアドレスを確認してください：</p>
      <a href="${verificationLink}">メールアドレスを確認</a>
    `,
  };

  try {
    await sgMail.send(msg);
    console.log('確認メール送信成功');
  } catch (error) {
    console.error('メール送信エラー:', error);
  }
});
```

### ステップ4: SendGrid API Key を設定

```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
```

### ステップ5: デプロイ

```bash
firebase deploy --only functions
```

---

## 🔐 DNS設定（メール到達率向上）

カスタムドメインからメールを送信する場合、以下のDNSレコードを追加してください：

### SPFレコード（TXTレコード）

SendGridの場合：
```
v=spf1 include:sendgrid.net ~all
```

### DKIMレコード

SendGridの場合：
1. SendGrid → **Settings** → **Sender Authentication**
2. **Domain Authentication** をクリック
3. ドメインを入力してDNSレコードを取得
4. DNSプロバイダーに以下のレコードを追加：
   - CNAME: `em1234._domainkey.yourdomain.com`
   - CNAME: `s1._domainkey.yourdomain.com`
   - CNAME: `s2._domainkey.yourdomain.com`

### DMARCレコード（オプション）

```
v=DMARC1; p=none; rua=mailto:dmarc@yourdomain.com
```

---

## 📧 Firebase Console でのメールテンプレート設定

### カスタムドメインを使用する場合

1. Firebase Console → **Authentication** → **Templates**
2. **メールアドレスの確認** を選択
3. **カスタマイズ**
4. **送信者名**: `LifeLink`
5. **送信者メール**: `noreply@yourdomain.com`（※ Cloud Functions使用時）
6. **アクションURL**: `https://yourdomain.com/__/auth/action`

---

## 🧪 テスト方法

### 1. メール送信テスト

```bash
# SendGrid APIでテスト
curl -X POST https://api.sendgrid.com/v3/mail/send \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "personalizations": [{
      "to": [{"email": "test@example.com"}]
    }],
    "from": {"email": "noreply@yourdomain.com"},
    "subject": "テストメール",
    "content": [{"type": "text/plain", "value": "これはテストです"}]
  }'
```

### 2. Firebase Authenticationでテスト

1. アプリで新規登録
2. メールが `noreply@yourdomain.com` から届くことを確認
3. 迷惑メールフォルダも確認

---

## ⚠️ 注意事項

### 1. **Blazeプランは必須**
カスタムメール送信にはCloud Functionsが必要です。

### 2. **DNS設定の反映時間**
SPF/DKIM設定後、反映まで最大48時間かかることがあります。

### 3. **送信制限**
- SendGrid無料枠: 100通/日
- Mailgun無料枠: 5,000通/月
- Amazon SES: 無制限（従量課金）

### 4. **Sender Authentication**
SendGridやMailgunでは、送信元メールアドレスの確認が必要です。

---

## 📚 推奨サービス比較

| サービス | 無料枠 | 料金 | 使いやすさ | DNS設定 |
|---------|--------|------|-----------|---------|
| **SendGrid** | 100通/日 | $19.95/月〜 | ⭐⭐⭐⭐⭐ | 必要 |
| **Mailgun** | 5,000通/月 | $35/月〜 | ⭐⭐⭐⭐ | 必要 |
| **Amazon SES** | 無制限 | $0.10/1,000通 | ⭐⭐⭐ | 必要 |
| **Postmark** | - | $15/月〜 | ⭐⭐⭐⭐⭐ | 必要 |

### 推奨
**個人/スタートアップ**: SendGrid（無料枠で十分）
**ビジネス**: Amazon SES（コスト効率が良い）
**エンタープライズ**: Postmark（高い到達率）

---

## 🎯 簡単な方法（今すぐできる）

Blazeプランへのアップグレードやコード変更が不要な場合：

### Firebase Console で送信者名のみ変更

1. Firebase Console → **Authentication** → **Templates**
2. **メールアドレスの確認** を選択
3. **送信者名** を変更: `LifeLink`
4. **保存**

これだけでも、以下のようにメールの見た目が改善されます：

**Before**: `noreply@your-project.firebaseapp.com`
**After**: `LifeLink <noreply@your-project.firebaseapp.com>`

---

## 🆘 トラブルシューティング

### メールが届かない

1. **迷惑メールフォルダを確認**
2. **SPF/DKIMレコードを確認**: `dig TXT yourdomain.com`
3. **SendGrid/MailgunのログをIGN**: Delivery → Activity
4. **Firebase Functions のログを確認**: `firebase functions:log`

### DNS設定が反映されない

```bash
# SPFレコードを確認
dig TXT yourdomain.com

# DKIMレコードを確認
dig TXT em1234._domainkey.yourdomain.com
```

### SendGrid APIキーが無効

1. SendGrid → **Settings** → **API Keys**
2. 新しいキーを作成（Full Access）
3. Firebase Functions の設定を更新

---

## 📝 次のステップ

1. ✅ Firebase Blazeプランへアップグレード
2. ✅ SendGridアカウント作成
3. ✅ API Key取得
4. ✅ Sender Authentication
5. ✅ DNS設定（SPF/DKIM）
6. ✅ Firebase Extensionインストール または Cloud Functions実装
7. ✅ テスト送信

---

**取得したドメインは何ですか？** 

ドメインを教えていただければ、具体的な設定例を作成します！

