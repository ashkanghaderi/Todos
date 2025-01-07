import 'package:flutter/material.dart';
import 'Detail/TaskDetail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'Database/todo.dart';

void main() async {
  // Ensure widgets are properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and Hive Flutter
  await Hive.initFlutter();

  // Register the adapter for the Todo class
  Hive.registerAdapter(TodoAdapter());

  // Open the Hive box for storing todos
  await Hive.openBox<Todo>('todos');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      theme: ThemeData(
       primaryColor: Colors.blue,
       canvasColor: Colors.orange,
       fontFamily: 'Roboto',
       textTheme: TextTheme(
      headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16.0),
),
      ),
      home: TodoList(),
    );
  }

}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late Box<Todo> _todoBox;

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<Todo>('todos');
  }

  void _addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      details: '',
      completed: false,
    );
    _todoBox.add(newTodo);
  }

  void _deleteTodo(int index) {
    _todoBox.deleteAt(index);
  }

  void _toggleTodoCompletion(int index) {
    final todo = _todoBox.getAt(index);
    if (todo != null) {
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        details: '',
        completed: !todo.completed,
      );
      _todoBox.putAt(index, updatedTodo);
    }
  }

  void _showAddTodoDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Task Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addTodo(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _todoBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No todos yet!'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final todo = box.getAt(index);

              return ListTile(
                title: Text(
                  todo?.title ?? '',
                  style: TextStyle(
                    decoration: (todo?.completed ?? false)
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: (todo?.completed ?? false)
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleTodoCompletion(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTodo(index);
                      },
                    ),
                  ],
                ),
                onTap: () {
                // Navigate to TaskDetail when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetail(todoIndex: index),
                  ),
                );
              } ,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}