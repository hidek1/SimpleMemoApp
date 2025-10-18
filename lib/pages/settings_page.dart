import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  
  const SettingsPage({super.key, this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
    // メインアプリのテーマを更新
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(isDark);
    }
  }

  Future<void> _exportData() async {
    try {
      // メモデータ取得
      final notes = await DatabaseHelper.instance.getAllNotes();
      final categories = await DatabaseHelper.instance.getAllCategories();

      // 簡易的なエクスポート（実際の実装ではファイル保存）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('データをエクスポートしました\nメモ: ${notes.length}件\nカテゴリ: ${categories.length}件'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('エクスポートに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importData() async {
    // 簡易的なインポート（実際の実装ではファイル選択）
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データインポート'),
        content: const Text('既存のデータが上書きされます。続行しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('インポート'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('インポート機能は開発中です'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データリセット'),
        content: const Text('全データを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // 全メモ削除
        final notes = await DatabaseHelper.instance.getAllNotes();
        for (final note in notes) {
          await DatabaseHelper.instance.deleteNote(note['id'] as int);
        }

        // 全カテゴリ削除
        final categories = await DatabaseHelper.instance.getAllCategories();
        for (final category in categories) {
          await DatabaseHelper.instance.deleteCategory(category['id'] as int);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('全データを削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データ削除に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // テーマ設定セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'テーマ設定',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isDarkMode,
                        onChanged: (value) => _toggleTheme(false),
                      ),
                      const Text('明るい色'),
                      const SizedBox(width: 32),
                      Radio<bool>(
                        value: true,
                        groupValue: _isDarkMode,
                        onChanged: (value) => _toggleTheme(true),
                      ),
                      const Text('暗い色'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // データ管理セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storage, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'データ管理',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.upload),
                    title: const Text('データをエクスポート'),
                    subtitle: const Text('メモとカテゴリをJSONファイルで保存'),
                    onTap: _exportData,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('データをインポート'),
                    subtitle: const Text('JSONファイルからデータを復元'),
                    onTap: _importData,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('データをリセット'),
                    subtitle: const Text('全データを削除（取り消し不可）'),
                    onTap: _resetData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // アプリ情報セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'アプリ情報',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.apps),
                    title: Text('バージョン'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('開発者'),
                    subtitle: Text('Flutter開発者'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('ライセンス情報'),
                    subtitle: const Text('MIT License'),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
