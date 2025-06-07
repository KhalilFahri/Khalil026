import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/todo.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late Future<List<Todo>> todos;

  Future<List<Todo>> fetchTodos() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  @override
  void initState() {
    super.initState();
    todos = fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: FutureBuilder<List<Todo>>(
        future: todos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final todo = data[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(todo.id.toString())),
                  title: Text(todo.title),
                  trailing: Icon(
                    todo.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: todo.completed ? Colors.green : Colors.grey,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}