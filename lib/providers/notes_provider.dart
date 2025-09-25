import 'package:flutter/foundation.dart';
import 'package:flutter_notes_taking_app_1/models/note.dart';
import 'package:flutter_notes_taking_app_1/services/database_service.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  final DatabaseService _databaseService = DatabaseService();

  // Load all notes from database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _databaseService.getNotes();
    } catch (error) {
      if (kDebugMode) {
        print("Error loading notes: $error");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    try {
      final id = await _databaseService.insertNote(note);
      final newNote = note.copyWith(id: id);
      _notes.insert(0, newNote);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print("Error adding note: @error");
      }
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await _databaseService.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error updating note: $error");
      }
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      await _databaseService.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print("Error deleting note: $error");
      }
      rethrow;
    }
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return notes;
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
