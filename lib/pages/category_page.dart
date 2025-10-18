import 'package:flutter/material.dart';
import '../Models/category.dart';

class CategoryManagerPage extends StatefulWidget {
  const CategoryManagerPage({super.key});

  @override
  State<CategoryManagerPage> createState() => _CategoryManagerPageState();
}

class _CategoryManagerPageState extends State<CategoryManagerPage> {
  // 仮データ。本来はDBから取得
  final List<Category> _categories = [
    Category(id: 1, name: '生活'),
    Category(id: 2, name: '仕事'),
    Category(id: 3, name: 'その他'),
  ];

  final _controller = TextEditingController();

  void _addCategory() {
    String name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリ名を入力してください')),
      );
      return;
    }
    setState(() {
      final int newId = _categories.isNotEmpty
          ? (_categories.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1
          : 1;
      _categories.add(Category(id: newId, name: name));
      _controller.clear();
    });
  }

  void _editCategory(Category category) async {
    final editingController = TextEditingController(text: category.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリ名を編集'),
        content: TextField(
          controller: editingController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '新しいカテゴリ名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, editingController.text.trim()),
            child: const Text('保存'),
          )
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        category.name = result;
      });
    }
  }

  void _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${category.name}」を削除しますか？'),
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
      setState(() {
        _categories.remove(category);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリ管理'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 新規カテゴリ追加
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'カテゴリ名を入力',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // カテゴリ一覧
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    child: ListTile(
                      title: Text(category.name),
                      leading: const Icon(Icons.label),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCategory(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
