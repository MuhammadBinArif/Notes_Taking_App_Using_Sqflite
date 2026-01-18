import 'package:flutter/material.dart';
import 'package:flutter_notes_taking_app_1/providers/notes_provider.dart';
import 'package:flutter_notes_taking_app_1/widgets/note_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              leading: Icon(Icons.search),
              hintText: "Search notes...",
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Notes List
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = _searchQuery.isEmpty
                    ? notesProvider.notes
                    : notesProvider.searchNotes(_searchQuery);

                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.note, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No notes yet!\nTap + to create your first note.'
                              : 'No notes found for "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(
                      note: note,

                      onDelete: () => _deleteNote(note.id!),
                      onTap: () => context.go("/notes/${note.id}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go("/create"),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteNote(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop,
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NotesProvider>(context, listen: false).deleteNote(id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
