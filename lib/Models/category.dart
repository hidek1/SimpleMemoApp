// Categoryモデル: カテゴリデータ構造
class Category {
  final int? id;
  String name;

  Category({
    this.id,
    required this.name,
  });

  // DB用：MapからCategoryを生成
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] ?? '',
    );
  }

  // DB用：CategoryをMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
