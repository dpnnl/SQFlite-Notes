import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_notes/db/notes_database.dart';
import 'package:sqflite_notes/model/note.dart';
import 'package:sqflite_notes/pages/edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({Key? key, required this.noteId}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    note = await NotesDatabase.instance.readNote(widget.noteId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(actions: [editButton(), deleteButton()]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                        note.isImportant
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.yMMMd().format(note.createdTime),
                    style: TextStyle(
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(note.description),
                ],
              ),
            ),
    );
  }

  // opção para editar nota, atualizando no db
  Widget editButton() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)),
        );

        refreshNote();
      },
    );
  }

  // apagar nota, exibe um dialogo antes
  Widget deleteButton() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.delete_forever_outlined, color: colorScheme.primary),
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apagar nota'),
            content: const Text(
              'Você tem certeza que deseja apagar esta nota?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Apagar'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await NotesDatabase.instance.delete(widget.noteId);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
