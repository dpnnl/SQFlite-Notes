import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_notes/db/notes_database.dart';
import 'package:sqflite_notes/model/note.dart';
import 'package:sqflite_notes/pages/edit_note_page.dart';
import 'package:sqflite_notes/pages/note_detail_page.dart';
import 'package:sqflite_notes/widgets/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();

    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQFlite Notes', style: TextStyle(fontSize: 24)),
        actions: [
          /* IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: NotesSearchDelegate(),
              );
              refreshNotes();
            },
          ),
          const SizedBox(width: 12), */
        ],
      ),

      // corpo das notas, exibe um texto caso esteja vazio
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : notes.isEmpty
            ? const Text('Sem notas ainda...')
            : Padding(padding: const EdgeInsets.all(8.0), child: buildNotes()),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: colorScheme.surface,
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.edit_outlined),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditNotePage()),
          );

          refreshNotes();
        },
      ),
    );
  }

  // constroi as notas com base no que foi carregado do db
  Widget buildNotes() => MasonryGridView.count(
    itemCount: notes.length,
    crossAxisCount: 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
    itemBuilder: (context, index) {
      final note = notes[index];

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(noteId: note.id!),
            ),
          );

          refreshNotes();
        },
        child: NoteCardWidget(note: note, index: index),
      );
    },
  );
}

// buscar pelas notas, pretendo realizar melhorias, portanto, está oculto no app
class NotesSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // constroi resultados da busca
  @override
  Widget buildResults(BuildContext context) => FutureBuilder<List<Note>>(
    future: NotesDatabase.instance.searchNotes(query),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      List<Note> notes = snapshot.data ?? [];

      if (notes.isEmpty) {
        return const Center(child: Text('Nenhum resultado encontrado.'));
      }

      return SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: List.generate(notes.length, (index) {
            final note = notes[index];
            return StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: NoteCardWidget(note: note, index: index),
            );
          }),
        ),
      );
    },
  );

  @override
  Widget buildSuggestions(BuildContext context) => Container();
}
