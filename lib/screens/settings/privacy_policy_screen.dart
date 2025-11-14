import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'プライバシーポリシー',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'プライバシーポリシー',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '1. はじめに',
                content:
                    'LifeLink（以下「当アプリ」といいます。）は、ユーザーの個人情報の保護に関して、以下のとおりプライバシーポリシー（以下「本ポリシー」といいます。）を定めます。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '2. 収集する情報',
                content:
                    '当アプリは、以下の情報を収集する場合があります：\n\n• アカウント情報：メールアドレス、ニックネーム、プロフィール画像\n• 投稿内容：シフト、日記メモ、TODOの内容\n• 友達関係：友達リスト、公開設定\n• 利用状況：アプリの利用履歴、エラーログ\n• デバイス情報：端末の種類、OS情報、アプリバージョン',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '3. 情報の利用目的',
                content:
                    '収集した情報は、以下の目的で利用します：\n\n• アプリサービスの提供・運営\n• ユーザー認証・アカウント管理\n• 友達機能の提供\n• 投稿内容の保存・表示\n• カレンダー機能の提供\n• 給料計算機能の提供\n• サービス改善・新機能開発\n• サポート対応\n• 不正利用の防止',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '4. 情報の保存・管理',
                content:
                    '当アプリは、Firebase（Google Cloud Platform）を使用して情報を保存・管理します。Firebaseは、業界標準のセキュリティ対策を講じたクラウドサービスです。\n\n• データは暗号化されて保存されます\n• アクセス制御により、適切な権限を持つ者のみがアクセス可能です\n• 定期的なバックアップにより、データの安全性を確保しています',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '5. 情報の共有・開示',
                content:
                    '当アプリは、以下の場合を除き、ユーザーの個人情報を第三者と共有・開示することはありません：\n\n• ユーザーの同意がある場合\n• 法令に基づく場合\n• 裁判所、警察等の公的機関からの要請がある場合\n• ユーザーまたは第三者の生命、身体または財産の保護のために必要がある場合\n• 当アプリの権利、財産またはサービスを保護するために必要がある場合',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '6. 友達との情報共有',
                content:
                    '当アプリでは、ユーザーが設定した公開範囲に基づいて、友達と以下の情報を共有します：\n\n• 公開設定されたシフト情報\n• 公開設定された日記メモ\n• 公開設定されたTODO\n• プロフィール画像\n• ニックネーム\n\nこれらの情報は、友達のスマートフォンにも表示されます。公開設定は、いつでも変更可能です。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '7. データの削除',
                content:
                    'ユーザーは、以下の方法でデータを削除できます：\n\n• アカウント削除：設定画面からアカウントを削除することで、すべての個人情報が削除されます\n• 個別データ削除：各投稿（シフト、日記メモ、TODO）は個別に削除可能です\n• 友達関係の解除：友達リストから友達を削除することで、その友達との情報共有が停止されます',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '8. セキュリティ対策',
                content:
                    '当アプリは、ユーザーの個人情報を保護するため、以下のセキュリティ対策を講じています：\n\n• SSL/TLS暗号化による通信の保護\n• Firebase Authenticationによる安全な認証\n• アクセスログの監視\n• 定期的なセキュリティ監査\n• データベースの暗号化',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '9. クッキー・トラッキング技術',
                content:
                    '当アプリは、サービス改善のため、以下の技術を使用する場合があります：\n\n• Firebase Analytics：利用状況の分析\n• Crashlytics：アプリのクラッシュ情報の収集\n\nこれらの情報は、個人を特定できない形で収集され、サービス改善にのみ使用されます。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '10. 未成年者の個人情報',
                content:
                    '当アプリは、未成年者の個人情報についても、本ポリシーに従って適切に取り扱います。未成年者が当アプリを利用する場合は、保護者の同意を得ることを推奨します。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '11. プライバシーポリシーの変更',
                content:
                    '当アプリは、必要に応じて本ポリシーを変更する場合があります。変更があった場合は、アプリ内で通知します。重要な変更については、事前に通知します。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '12. お問い合わせ',
                content: '個人情報の取り扱いに関するお問い合わせは、アプリ内の「アプリの使い方」画面からご連絡ください。',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '制定日：2024年1月1日\n最終更新日：2024年1月1日',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
