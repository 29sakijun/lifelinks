import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          '利用規約',
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
                '利用規約',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '第1条（適用）',
                content:
                    '本利用規約（以下「本規約」といいます。）は、LifeLink（以下「当アプリ」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下「ユーザー」といいます。）には、本規約に従って、本サービスをご利用いただきます。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第2条（利用登録）',
                content:
                    '本サービスにおいては、登録希望者が本規約に同意の上、当アプリの定める方法によって利用登録を申請し、当アプリがこれを承認することによって、利用登録が完了するものとします。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第3条（ユーザーIDおよびパスワードの管理）',
                content:
                    'ユーザーは、自己の責任において、本サービスのユーザーIDおよびパスワードを適切に管理するものとします。ユーザーは、いかなる場合にも、ユーザーIDおよびパスワードを第三者に譲渡または貸与し、もしくは第三者と共用することはできません。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第4条（禁止事項）',
                content:
                    'ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。\n\n• 法令または公序良俗に違反する行為\n• 犯罪行為に関連する行為\n• 本サービスの内容等、本サービスに含まれる著作権、商標権ほか知的財産権を侵害する行為\n• 当アプリ、ほかのユーザー、またはその他第三者のサーバーまたはネットワークの機能を破壊したり、妨害したりする行為\n• 本サービスによって得られた情報を商業的に利用する行為\n• 当アプリのサービスの運営を妨害するおそれのある行為\n• 不正アクセスをし、またはこれを試みる行為\n• 他のユーザーに関する個人情報等を収集または蓄積する行為\n• 不正な目的を持って本サービスを利用する行為\n• 本サービスの他のユーザーまたはその他の第三者に不利益、損害、不快感を与える行為\n• 他のユーザーに成りすます行為\n• 当アプリが許諾しない本サービス上での宣伝、広告、勧誘、または営業行為\n• 面識のない異性との出会いを目的とした行為\n• 当アプリのサービスに関連して、反社会的勢力に対して直接または間接に利益を供与する行為\n• その他、当アプリが不適切と判断する行為',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第5条（本サービスの提供の停止等）',
                content:
                    '当アプリは、以下のいずれかの事由があると判断した場合、ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができるものとします。\n\n• 本サービスにかかるコンピュータシステムの保守点検または更新を行う場合\n• 地震、落雷、火災、停電または天災などの不可抗力により、本サービスの提供が困難となった場合\n• コンピュータまたは通信回線等が事故により停止した場合\n• その他、当アプリが本サービスの提供が困難と判断した場合',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第6条（利用制限および登録抹消）',
                content:
                    '当アプリは、ユーザーが以下のいずれかに該当する場合には、事前の通知なく、ユーザーに対して、本サービスの全部もしくは一部の利用を制限し、またはユーザーとしての登録を抹消することができるものとします。\n\n• 本規約のいずれかの条項に違反した場合\n• 登録事項に虚偽の事実があることが判明した場合\n• 決済手段として当該ユーザーが届け出たクレジットカードが利用停止となった場合\n• 料金等の支払債務の不履行があった場合\n• 当アプリからの連絡に対し、一定期間返答がない場合\n• 本サービスについて、最終の利用から一定期間利用がない場合\n• その他、当アプリが本サービスの利用を適当でないと判断した場合',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第7条（退会）',
                content: 'ユーザーは、当アプリの定める退会手続により、本サービスから退会できるものとします。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第8条（保証の否認および免責事項）',
                content:
                    '当アプリは、本サービスに事実上または法律上の瑕疵（安全性、信頼性、正確性、完全性、有効性、特定の目的への適合性、セキュリティなどに関する欠陥、エラーやバグ、権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n\n当アプリは、本サービスに起因してユーザーに生じたあらゆる損害について、当アプリの故意又は重過失による場合を除き、一切の責任を負いません。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第9条（サービス内容の変更等）',
                content:
                    '当アプリは、ユーザーに通知することなく、本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし、これによってユーザーに生じた損害について一切の責任を負いません。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第10条（利用規約の変更）',
                content:
                    '当アプリは、必要と判断した場合には、ユーザーに通知することなくいつでも本規約を変更することができるものとします。なお、本規約の変更後、本サービスの利用を開始した場合には、当該ユーザーは変更後の規約に同意したものとみなします。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第11条（個人情報の取扱い）',
                content:
                    '当アプリは、本サービスの利用によって取得する個人情報については、当アプリ「プライバシーポリシー」に従い適切に取り扱うものとします。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第12条（通知または連絡）',
                content:
                    'ユーザーと当アプリとの間の通知または連絡は、当アプリの定める方法によって行うものとします。当アプリは、ユーザーから、当アプリが別途定める方式に従った変更届け出がない限り、現在登録されている連絡先が有効なものとみなして当該連絡先へ通知または連絡を行い、これらは、発信時にユーザーへ到達したものとみなします。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第13条（権利義務の譲渡の禁止）',
                content:
                    'ユーザーは、当アプリの書面による事前の承諾なく、利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し、または担保に供することはできません。',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: '第14条（準拠法・裁判管轄）',
                content:
                    '本規約の解釈にあたっては、日本法を準拠法とします。本サービスに関して紛争が生じた場合には、当アプリの本店所在地を管轄する裁判所を専属的合意管轄とします。',
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
