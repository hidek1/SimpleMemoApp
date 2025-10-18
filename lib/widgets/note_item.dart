import 'package:flutter/material.dart';
import '../Models/note.dart';

/// メモ一覧用アイテムウィジェット
class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const NoteItem({
    Key? key,
    required this.note,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                note.isFavorite ? Icons.star : Icons.star_border,
                color: note.isFavorite ? Colors.amber : Colors.grey,
              ),
              tooltip: 'お気に入り切替',
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.category != null && note.category!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 2),
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
            if (note.content != null && note.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  note.content!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '更新: ${_formatDate(note.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '作成: ${_formatDate(note.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    // 例: 2024/06/14
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

