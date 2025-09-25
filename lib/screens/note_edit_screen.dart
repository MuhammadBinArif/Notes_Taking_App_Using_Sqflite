import 'package:flutter/material.dart';
import 'package:flutter_notes_taking_app_1/models/note.dart';
import 'package:flutter_notes_taking_app_1/providers/notes_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoteEditScreen extends StatefulWidget {
  final int? noteId;
  const NoteEditScreen({super.key, this.noteId});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    _isEditing = widget.noteId != null;
    if (_isEditing) {
      _loadNote();
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      final note = notesProvider.notes.firstWhere(
        (note) => note.id == widget.noteId,
        orElse: () => throw Exception("Note not found"),
      );
      _titleController.text = note.title;
      _contentController.text = note.content;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error loading note")));
        context.go("/");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      final now = DateTime.now();
      final note = Note(
        id: widget.noteId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: _isEditing
            ? notesProvider.notes
                  .firstWhere(
                    (n) => n.id == widget.noteId,
                    orElse: () => throw Exception("Note not found"),
                  )
                  .createdAt
            : now,
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await notesProvider.updateNote(note);
      } else {
        await notesProvider.addNote(note);
      }

      if (mounted) {
        context.go("/");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving note: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Note" : "New Note"),
        actions: [
          if (!_isLoading)
            TextButton(onPressed: _saveNote, child: const Text("Save")),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.03),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: "Start writing...",
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter some content";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
