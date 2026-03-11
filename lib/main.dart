import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/user.dart';
import 'screens/user_form_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CRUD API",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  loadUsers() async {
    users = await ApiService.getUsers();
    setState(() {});
  }

  void _navigateToForm({User? user}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(user: user),
      ),
    );

    if (result != null && result is String) {
      if (user != null) {
        // Modo Edición
        _editUser(user, result);
      } else {
        // Modo Creación
        _addUser(result);
      }
    }
  }

  _addUser(String name) async {
    try {
      // La API simulada devuelve un objeto, pero lo creamos localmente para tener control del ID.
      final tempUser = await ApiService.createUser(name);
      setState(() {
        final maxId = users.fold<int>(0, (max, u) => u.id > max ? u.id : max);
        final newUser = User(id: maxId + 1, name: tempUser.name);
        users.add(newUser);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al crear usuario: $e")));
    }
  }

  _editUser(User user, String newName) async {
    try {
      await ApiService.updateUser(user.id, newName);
      setState(() {
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = User(id: user.id, name: newName);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al actualizar usuario: $e")));
    }
  }

  deleteUser(int id) async {
    try {
      await ApiService.deleteUser(id);
      setState(() {
        users.removeWhere((user) => user.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al eliminar usuario: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD API Flutter"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _navigateToForm(user: user),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteUser(user.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}