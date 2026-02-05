import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_notes/model/note.dart';

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({Key? key, required this.note, required this.index})
    : super(key: key);

  final Note note;
  final int index;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().format(note.createdTime);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  note.isImportant ? Icons.star : null,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              note.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
