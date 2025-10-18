import 'package:flutter/material.dart';
import '../Models/note.dart';
import '../db/database_helper.dart';

class MemoEditPage extends StatefulWidget {
  final Note? note; // nullなら新規，非nullなら編集

  const MemoEditPage({super.key, this.note});

  @override
  State<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedCategory;
  bool _isFavorite = false;

  List<String> _categories = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _loadCategories().then((_) {
      if (widget.note != null) {
        _titleController.text = widget.note!.title;
        _contentController.text = widget.note!.content ?? '';
        _selectedCategory = widget.note!.category;
        _isFavorite = widget.note!.isFavorite;
      }
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> _loadCategories() async {
    // DBからカテゴリ一覧を取得
    final dbCategories = await DatabaseHelper.instance.getAllCategories();
    setState(() {
      _categories = dbCategories.isEmpty 
          ? ['その他'] 
          : dbCategories.map((cat) => cat['name'] as String).toList();
    });
    // 新規時には初期カテゴリをセット
    if (widget.note == null && _selectedCategory == null && _categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveMemo() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }
    final now = DateTime.now();

    if (widget.note == null) {
      // 新規作成
      Note newNote = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isFavorite: _isFavorite,
        createdAt: now,
        updatedAt: now,
      );
      await DatabaseHelper.instance.insertNote(newNote.toMap());
    } else {
      // 既存メモ編集
      Note updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isFavorite: _isFavorite,
        createdAt: widget.note!.createdAt,
        updatedAt: now,
      );
      await DatabaseHelper.instance.updateNote(updatedNote.id!, updatedNote.toMap());
    }
    if (mounted) Navigator.pop(context, true); // true=更新したことを示す
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'メモ編集' : '新規メモ'),
        actions: [
          ElevatedButton(
            onPressed: _saveMemo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
            child: const Text('保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル入力
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'タイトルを入力',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // カテゴリ選択
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'カテゴリ選択',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 本文入力
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'メモ内容を入力',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // お気に入り
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.star : Icons.star_border,
                          color: _isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                      ),
                      const Text('お気に入り'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
