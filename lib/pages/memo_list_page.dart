import 'package:flutter/material.dart';
import '../Models/note.dart';
import '../db/database_helper.dart';
import 'memo_edit_page.dart';
import 'category_page.dart';
import 'settings_page.dart';

class MemoListPage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  
  const MemoListPage({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  String _searchKeyword = '';
  String _sortOrder = 'created_at';

  List<Note> _notes = [];
  List<String> _categories = ['すべて'];
  String _selectedCategory = 'すべて';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotesAndCategories();
  }

  Future<void> _loadNotesAndCategories() async {
    setState(() {
      _loading = true;
    });
    // メモ一覧取得
    final noteMaps = await DatabaseHelper.instance.getAllNotes();
    _notes = noteMaps.map((e) => Note.fromMap(e)).toList();

    // カテゴリ一覧取得
    final categoryMaps = await DatabaseHelper.instance.getAllCategories(); // 例: [{'id':1,'name':'生活'}, ...]
    List<String> categories = ['すべて'];
    if (categoryMaps.isNotEmpty) {
      categories.addAll(categoryMaps.map((e) => e['name'] as String).toList());
    }
    setState(() {
      _categories = categories;
      // 新規カテゴリ取得でカテゴリ選択肢が消える場合に備え
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = 'すべて';
      }
      _loading = false;
    });
  }

  List<Note> get _filteredNotes {
    List<Note> filtered = List.from(_notes);
    // カテゴリで絞り込み
    if (_selectedCategory != 'すべて') {
      filtered = filtered.where((note) => note.category == _selectedCategory).toList();
    }
    // 検索キーワードでフィルター
    if (_searchKeyword.isNotEmpty) {
      filtered = filtered.where((note) =>
          note.title.contains(_searchKeyword) ||
          (note.content ?? '').contains(_searchKeyword)
      ).toList();
    }
    // 並び替え
    if (_sortOrder == 'created_at') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortOrder == 'updated_at') {
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else if (_sortOrder == 'is_favorite') {
      filtered.sort((a, b) {
        if (a.isFavorite == b.isFavorite) {
          return b.updatedAt.compareTo(a.updatedAt);
        }
        return (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
      });
    }
    return filtered;
  }

  // お気に入りの更新
  Future<void> _toggleFavorite(Note note) async {
    note.isFavorite = !note.isFavorite;
    await DatabaseHelper.instance.updateNote(note.id!, note.toMap());
    setState(() {});
  }

  // メモの削除
  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${note.title}」を削除しますか？'),
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
      await DatabaseHelper.instance.deleteNote(note.id!);
      _loadNotesAndCategories(); // 一覧を更新
    }
  }

  // 新規・編集終了後更新
  Future<void> _navigateToEdit({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemoEditPage(note: note)),
    );
    // 戻り値: true ならリロード
    if (result == true) {
      _loadNotesAndCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // フォーカスを検索バーに移動したい場合や別画面に遷移も可
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () async {
              // カテゴリ管理画面へ遷移
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryManagerPage()),
              );
              await _loadNotesAndCategories(); // 帰ってきたらカテゴリリロード
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(onThemeChanged: widget.onThemeChanged),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'キーワードを入力',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),
          // 並び替え＋カテゴリドロップダウン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _sortOrder,
                  items: const [
                    DropdownMenuItem(
                      value: 'created_at',
                      child: Text('作成日時'),
                    ),
                    DropdownMenuItem(
                      value: 'updated_at',
                      child: Text('更新日時'),
                    ),
                    DropdownMenuItem(
                      value: 'is_favorite',
                      child: Text('お気に入り'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOrder = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // メモ一覧
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(child: Text('メモがありません'))
                : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        note.isFavorite ? Icons.star : Icons.star_border,
                        color: note.isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleFavorite(note);
                      },
                    ),
                    title: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.content != null)
                          Text(
                            note.content!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (note.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note.category!,
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                            Text(
                              '更新: ${_formatDate(note.updatedAt)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 編集・削除ボタン
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _navigateToEdit(note: note),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('編集'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteNote(note),
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('削除'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToEdit();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // 例: 2024/06/13
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
