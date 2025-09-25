import 'package:flutter_notes_taking_app_1/screens/home_screen.dart';
import 'package:flutter_notes_taking_app_1/screens/note_detail_screen.dart';
import 'package:flutter_notes_taking_app_1/screens/note_edit_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      // Home screen route
      GoRoute(
        path: "/",
        name: "home",
        builder: (context, state) => const HomeScreen(),
      ),

      // Note detail screen route
      GoRoute(
        path: "/note/:id",
        name: "note_detail",
        builder: (context, state) {
          final id = int.parse(state.pathParameters["id"]!);
          return NoteDetailScreen(noteId: id);
        },
      ),

      // Note edit screen route (for both create and update)
      GoRoute(
        path: "/edit/:id",
        name: "edit_note",
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters["id"] ?? "");
          return NoteEditScreen(noteId: id);
        },
      ),

      // Create new note route
      GoRoute(
        path: "/create",
        name: "create_note",
        builder: (context, state) => const NoteEditScreen(),
      ),
    ],
  );
}
