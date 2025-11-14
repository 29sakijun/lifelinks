import 'package:flutter/material.dart';

class AppConstants {
  // アプリ名
  static const String appName = 'LifeLinks';

  // 文字数制限
  static const int maxNicknameLength = 20;
  static const int maxMemoLength = 30;
  static const int maxShiftMemoLength = 200;
  static const int maxDiaryTextLength = 500;

  // カラー
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // 友達のカラーパレット
  static const List<Color> friendColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
  ];

  // 利用規約（仮）
  static const String termsOfService = '''
利用規約

第1条（適用）
本規約は、本アプリの利用に関する条件を定めるものです。

第2条（禁止事項）
ユーザーは以下の行為をしてはなりません。
1. 法令または公序良俗に違反する行為
2. 犯罪行為に関連する行為
3. 本アプリの運営を妨害する行為

第3条（免責事項）
本アプリの利用により生じた損害について、運営者は一切の責任を負いません。

第4条（規約の変更）
運営者は、必要に応じて本規約を変更することができます。
''';

  // プライバシーポリシー（仮）
  static const String privacyPolicy = '''
プライバシーポリシー

1. 収集する情報
本アプリでは、以下の情報を収集します。
- ユーザーが入力した情報（ニックネーム、シフト、日記など）
- 利用状況に関する情報

2. 情報の利用目的
収集した情報は、本アプリの提供・改善のために利用します。

3. 情報の第三者提供
ユーザーの同意なく、第三者に情報を提供することはありません。

4. セキュリティ
適切なセキュリティ対策を講じ、情報の保護に努めます。

5. お問い合わせ
本ポリシーに関するお問い合わせは、アプリ内の設定画面からご連絡ください。
''';
}
