import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Notas App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      );
}

class Note {
  final String title, content;
  Note(this.title, this.content);

  // Método para convertir la nota a un mapa JSON.
  Map<String, String> toJson() => {'title': title, 'content': content};

  // Constructor para crear una nota a partir de un mapa JSON.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(json['title'], json['content']);
  }
}

class UserProfile {
  final String name, email, imageUrl;
  UserProfile({required this.name, required this.email, required this.imageUrl});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _addNote(Note note) {
    setState(() => _notes.add(note));
    _saveNotes();
  }

  void _updateNote(int index, Note note) {
    setState(() => _notes[index] = note);
    _saveNotes();
  }

  void _deleteNote(int index) {
    setState(() => _notes.removeAt(index));
    _saveNotes();
  }

  // Guarda la lista de notas en SharedPreferences.
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> notesList = _notes.map((note) => note.toJson()).toList();
    await prefs.setString('notes', jsonEncode(notesList));
  }

  // Carga la lista de notas desde SharedPreferences.
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getString('notes');
    if (notesData != null) {
      List<dynamic> notesList = jsonDecode(notesData);
      setState(() {
        _notes = notesList.map((noteMap) => Note.fromJson(noteMap)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle;
    Widget bodyContent;
    if (_selectedIndex == 0) {
      appBarTitle = "Listas";
      bodyContent = _notes.isEmpty
          ? Center(
              child: Text("No hay listas. Agrega una nueva nota en la pestaña 'Notas'."),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.yellow[700]),
                          onPressed: () async {
                            final updatedNote = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNotePage(note: note),
                              ),
                            );
                            if (updatedNote != null && updatedNote is Note)
                              _updateNote(index, updatedNote);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
    } else if (_selectedIndex == 1) {
      appBarTitle = "Notas";
      bodyContent = CreateNoteInline(onNoteCreated: _addNote);
    } else {
      appBarTitle = "Perfiles";
      bodyContent = UserInfoContent();
    }

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listas'),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: 'Notas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfiles'),
        ],
      ),
    );
  }
}

class CreateNoteInline extends StatefulWidget {
  final Function(Note) onNoteCreated;
  const CreateNoteInline({Key? key, required this.onNoteCreated}) : super(key: key);

  @override
  _CreateNoteInlineState createState() => _CreateNoteInlineState();
}

class _CreateNoteInlineState extends State<CreateNoteInline> {
  final _titleController = TextEditingController(text: "Test Note");
  final _contentController = TextEditingController(text: "This is a test note.");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "Título", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: "Contenido", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Error"),
                    content: Text("El campo no debe estar vacío"),
                    actions: [
                      TextButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                );
                return;
              }
              final newNote = Note(_titleController.text, _contentController.text);
              widget.onNoteCreated(newNote);
              _titleController.clear();
              _contentController.clear();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Nota guardada")));
            },
            child: Text("Guardar Nota"),
          ),
        ],
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  final Note note;
  const EditNotePage({Key? key, required this.note}) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Nota")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Título", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Contenido", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final updatedNote = Note(_titleController.text, _contentController.text);
                Navigator.pop(context, updatedNote);
              },
              child: Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoContent extends StatelessWidget {
  final List<UserProfile> profiles = [
    UserProfile(
      name: 'Keury Ramirez',
      email: 'keury03@hotmail.com',
      imageUrl: 'https://via.placeholder.com/150/FF5733?text=KR',
    ),
    UserProfile(
      name: 'VictorS',
      email: 'victors@gmail.com',
      imageUrl: 'https://via.placeholder.com/150/33C1FF?text=VS',
    ),
    UserProfile(
      name: 'ErickDLR',
      email: 'erickdlr@hotmart.com',
      imageUrl: 'https://via.placeholder.com/150/9D33FF?text=ED',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: profiles
            .map(
              (profile) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(profile.imageUrl)),
                  title: Text(profile.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(profile.email),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
