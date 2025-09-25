import 'package:flutter/material.dart';
import 'package:flutter_notes_taking_app_1/providers/notes_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final note = notesProvider.notes.firstWhere(
          (note) => note.id == widget.noteId,
          orElse: () => throw Exception("Note not found"),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text("Note Details"),
            actions: [
              IconButton(
                onPressed: () => context.go("/edit/${note.id}"),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.012),
                Text(
                  "Updated: ${DateFormat('MMM dd, yyyy - HH:mm').format(note.updatedAt)}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      note.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
