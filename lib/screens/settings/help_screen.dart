import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'アプリの使い方',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '友達の追加方法',
            icon: Icons.person_add,
            color: Colors.purple,
            content: _buildAddFriendHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'プロフィール画像の設定',
            icon: Icons.account_circle,
            color: Colors.indigo,
            content: _buildProfileImageHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'カレンダーマーカーの見方',
            icon: Icons.calendar_today,
            color: Colors.blue,
            content: _buildCalendarMarkerHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '友達セクションの並び替え',
            icon: Icons.swap_vert,
            color: Colors.green,
            content: _buildReorderHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '未読マークについて',
            icon: Icons.notifications,
            color: Colors.red,
            content: _buildUnreadHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'TODOの表示について',
            icon: Icons.check_box,
            color: Colors.orange,
            content: _buildTodoHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '公開TODOの共同管理',
            icon: Icons.people,
            color: Colors.teal,
            content: _buildSharedTodoHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '給料管理機能',
            icon: Icons.monetization_on,
            color: Colors.amber,
            content: _buildSalaryHelp(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '画像の拡大表示',
            icon: Icons.zoom_in,
            color: Colors.cyan,
            content: _buildImageZoomHelp(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [content],
      ),
    );
  }

  Widget _buildAddFriendHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QRコードを使って友達を追加できます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '📱 友達を追加する手順',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '設定画面から「マイプロフィール」を開く'),
        const SizedBox(height: 8),
        _buildStep('2', '自分のQRコードが表示されます'),
        const SizedBox(height: 8),
        _buildStep('3', '友達に自分のQRコードを読み取ってもらう'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '📷 友達のQRコードを読み取る',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '設定画面から「友達リスト」を開く'),
        const SizedBox(height: 8),
        _buildStep('2', '右上のQRコードスキャンアイコンをタップ'),
        const SizedBox(height: 8),
        _buildStep('3', 'カメラで友達のQRコードを読み取る'),
        const SizedBox(height: 8),
        _buildStep('4', '友達が追加されます'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '友達追加は双方向で自動的に行われます。お互いにQRコードを読み合う必要があります。',
                  style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '友達を追加後、友達リストから公開設定を変更できます。日記メモ・TODO・シフトの公開/非公開を個別に設定できます。',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'プロフィール画像を設定すると、友達にもあなたの画像が表示されます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '📸 プロフィール画像の設定方法',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '設定画面から「マイプロフィール」を開く'),
        const SizedBox(height: 8),
        _buildStep('2', 'プロフィール画像の上にあるカメラアイコンをタップ'),
        const SizedBox(height: 8),
        _buildStep('3', '「ギャラリーから選択」または「カメラで撮影」を選択'),
        const SizedBox(height: 8),
        _buildStep('4', '画像を選択または撮影すると自動的にアップロードされます'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.indigo[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'プロフィール画像を設定すると、友達のスマホでもあなたの画像が表示されるようになります。',
                  style: TextStyle(fontSize: 12, color: Colors.indigo[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.sync, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '画像の変更は即座に友達の画面にも反映されます。',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarMarkerHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カレンダーの日付の下に表示される小さな丸は、その日の投稿の種類を示しています。',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildMarkerExample('🔵 青色の丸', 'シフトの投稿があります', Colors.blue),
        const SizedBox(height: 8),
        _buildMarkerExample('🟠 オレンジ色の丸', '日記メモの投稿があります', Colors.orange),
        const SizedBox(height: 8),
        _buildMarkerExample('🟢 緑色の丸', 'TODOの投稿があります', Colors.green),
        const SizedBox(height: 8),
        _buildMarkerExample('🔴 赤色の丸', '友達の未読投稿があります', Colors.red),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📌 表示例',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildMarkerPattern('🔵', 'シフトのみ'),
              _buildMarkerPattern('🔵🟠', 'シフト + 日記メモ'),
              _buildMarkerPattern('🔵🟠🟢', '全種類の投稿'),
              _buildMarkerPattern('🔵🟠🟢🔴', '全種類 + 友達の未読投稿'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🔵🟠🟢のマーカーは自分の投稿のみに反応します。友達の投稿は赤色のマーカーでのみ表示されます。',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReorderHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('友達セクションの表示順を変更できます。', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        _buildStep('1', '設定画面から「友達リスト」を開く'),
        const SizedBox(height: 8),
        _buildStep('2', '左側のドラッグハンドル（≡）を長押し'),
        const SizedBox(height: 8),
        _buildStep('3', '上下にドラッグして並び替え'),
        const SizedBox(height: 8),
        _buildStep('4', '指を離すと自動的に保存される'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '並び替えた順番は、カレンダーの友達セクションの表示順にも反映されます。',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '友達の新しい投稿を見逃さないように、未読マークが表示されます。',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildUnreadExample('🔴 セクションの赤丸', '友達のセクションタイトルの右側に表示されます。'),
        const SizedBox(height: 8),
        _buildUnreadExample('[NEW] 投稿のバッジ', '未読の投稿に「NEW」バッジが表示されます。'),
        const SizedBox(height: 8),
        _buildUnreadExample('🔴 カレンダーの赤マーカー', '友達の未読投稿がある日に赤いマーカーが表示されます。'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '投稿をタップして開くと、自動的に既読になります。セクションを展開しただけでは既読になりません。',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodoHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TODOは登録日から締切日まで連続してカレンダーに表示されます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '例：1月1日に登録、1月3日が締切のTODO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                '→ 1月1日、2日、3日の全てに表示されます',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '締切を設定しない場合は、登録した日のみに表示されます。',
                  style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '📝 サブタスク機能',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const Text('TODOに複数のサブタスクを追加できます。', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        _buildStep('1', 'TODO編集画面で「サブタスク - 追加」ボタンをタップ'),
        const SizedBox(height: 8),
        _buildStep('2', 'サブタスクのタイトルを入力'),
        const SizedBox(height: 8),
        _buildStep('3', '必要な数だけ追加ボタンで追加'),
        const SizedBox(height: 8),
        _buildStep('4', '各サブタスクのチェックボックスで完了管理'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'サブタスクの進捗（例：2/3完了）がカレンダーリストに表示されます。',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkerExample(String marker, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(description, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildMarkerPattern(String pattern, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(pattern, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(description, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildUnreadExample(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildSharedTodoHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '公開したTODOは友達と一緒に管理できます。お互いにタスクの完了状態を変更できます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '✅ メインタスクの完了管理',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '友達の公開TODOをタップして開く'),
        const SizedBox(height: 8),
        _buildStep('2', '右上のチェックアイコンをタップ'),
        const SizedBox(height: 8),
        _buildStep('3', 'TODOが完了/未完了に切り替わります'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '友達が完了にしたTODOも、あなたが未完了に戻すことができます。',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '📝 サブタスクの共同管理',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '友達の公開TODOを開く'),
        const SizedBox(height: 8),
        _buildStep('2', 'サブタスクをタップ'),
        const SizedBox(height: 8),
        _buildStep('3', 'そのサブタスクが完了/未完了に切り替わります'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'サブタスクもメインタスクと同じように、誰でも完了状態を変更できます。',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '💡 活用例',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '例：「引っ越し準備」TODO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text('・サブタスク1: 「段ボール購入」', style: TextStyle(fontSize: 12)),
              const Text('・サブタスク2: 「食器を梱包」', style: TextStyle(fontSize: 12)),
              const Text('・サブタスク3: 「本を梱包」', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              const Text(
                '→ 友達が「段ボール購入」を完了にしてくれたら、あなたはすぐに気づけます！',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '公開設定をOFFにすると、友達はTODOを見ることも編集することもできなくなります。',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'シフトの給料を月毎に管理し、見込み給料を確認できます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '💰 給料管理の使い方',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', 'カレンダー画面の右上の給料アイコンをタップ'),
        const SizedBox(height: 8),
        _buildStep('2', '現在の月の給料見込みが表示されます'),
        const SizedBox(height: 8),
        _buildStep('3', '左右の矢印で月を変更できます'),
        const SizedBox(height: 8),
        _buildStep('4', '勤務先ごとの詳細も確認できます'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.calculate, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '時給・日給・手当・天引きを考慮した正確な給料見込みを計算します。',
                  style: TextStyle(fontSize: 12, color: Colors.amber[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.timeline, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '勤務先ごとに締日・給料日の設定も表示されるため、実際の支払い予定も把握できます。',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageZoomHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日記メモの画像をタップすると、拡大表示できます。',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '🔍 画像拡大機能の使い方',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildStep('1', '日記メモの画像をタップ'),
        const SizedBox(height: 8),
        _buildStep('2', '全画面で画像が表示されます'),
        const SizedBox(height: 8),
        _buildStep('3', 'ピンチでズームイン・ズームアウト'),
        const SizedBox(height: 8),
        _buildStep('4', '左右スワイプで複数画像を切り替え'),
        const SizedBox(height: 8),
        _buildStep('5', '画面外をタップまたは戻るボタンで閉じる'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.cyan[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.cyan[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '友達の日記メモの画像も同様に拡大表示できます。',
                  style: TextStyle(fontSize: 12, color: Colors.cyan[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '複数の画像がある場合は、スワイプで簡単に切り替えできます。',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
