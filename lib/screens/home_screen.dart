import 'package:flutter/material.dart';
import 'package:crud/models/user.dart';
import 'package:crud/services/api_service.dart';
import 'package:crud/screens/user_form.dart';
import 'package:crud/widgets/user_tile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final users = await ApiService.getUsers();
      // The API service now returns a List<User>, so we can assign it directly.
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los usuarios: ${e.toString()}')),
      );
    }
  }

  void _addUser() async {
    final newUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (context) => UserForm()),
    );
    if (newUser != null) {
      setState(() {
        _users.add(newUser);
      });
    }
  }

  void _editUser(User user) async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (context) => UserForm(user: user)),
    );
    if (updatedUser != null) {
      setState(() {
        final index = _users.indexWhere((u) => u.id == updatedUser.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });
    }
  }

  void _deleteUser(int id) async {
    try {
      await ApiService.deleteUser(id);
      setState(() {
        _users.removeWhere((user) => user.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return UserTile(
                    user: user,
                    onEdit: () => _editUser(user),
                    onDelete: () => _deleteUser(user.id),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: Icon(Icons.add),
      ),
    );
  }
}