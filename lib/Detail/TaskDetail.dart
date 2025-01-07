import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_flutter_application_1/Database/todo.dart';

class TaskDetail extends StatefulWidget {
  final int todoIndex; // The index of the todo in the Hive box

  const TaskDetail({super.key, required this.todoIndex});

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late Box<Todo> _todoBox;
  late Todo _todo;
  late TextEditingController _titleController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<Todo>('todos');
    _todo = _todoBox.getAt(widget.todoIndex)!;

    // Initialize controllers with the current task data
    _titleController = TextEditingController(text: _todo.title);
    _detailsController = TextEditingController(text: _todo.details ?? '');
  }

  void _saveChanges() {
    final updatedTodo = Todo(
      id: _todo.id,
      title: _titleController.text,
      completed: _todo.completed,
      details: _detailsController.text,
    );

    _todoBox.putAt(widget.todoIndex, updatedTodo); // Update in the Hive box
    Navigator.pop(context); // Return to the previous screen
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges, // Save changes when the save button is pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed:',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _todo.completed,
                  onChanged: (value) {
                    setState(() {
                      _todo = Todo(
                        id: _todo.id,
                        title: _todo.title,
                        completed: value,
                        details: _detailsController.text,
                      );
                      _todoBox.putAt(widget.todoIndex, _todo); // Update in Hive
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}