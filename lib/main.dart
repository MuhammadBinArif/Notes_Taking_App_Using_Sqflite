import 'package:flutter/material.dart';
import 'package:flutter_notes_taking_app_1/providers/notes_provider.dart';
import 'package:flutter_notes_taking_app_1/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NotesProvider())],
      child: MaterialApp.router(
        title: "Notes App",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ListView.builder(
//               shrinkWrap: true,
//               itemCount: fakeNotes.length,
//               itemBuilder: (context, index) {
//                 NotesModelClass note = fakeNotes[index];
//                 return Container(
//                   margin: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.lightBlue,
//                     borderRadius: BorderRadius.circular(10),
//                   ),

//                   child: ListTile(title: Text(note.title)),
//                 );
//               },
//             ),
