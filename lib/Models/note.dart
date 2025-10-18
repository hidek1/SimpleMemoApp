// Noteモデル: メモ（ノート）データ構造
class Note {
  final int? id;
  String title;
  String? content;
  String? category;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    this.content,
    this.category,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // DB用：MapからNoteを生成
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      content: map['content'],
      category: map['category'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // DB用：NoteをMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
