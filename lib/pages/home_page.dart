import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firestore/models/todo.dart';
import 'package:flutter_firestore/services/database_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: _addTodoButton(),
    );
  }

  Widget _addTodoButton() {
    return FloatingActionButton(
      onPressed: _displayTextInputDialog,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add todo"),
          content: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(hintText: 'Todo.....'),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Todo todo = Todo(
                  task: textEditingController.text,
                  isDone: false,
                  createdOn: Timestamp.now(),
                  updatedOn: Timestamp.now(),
                );
                _databaseService.addTodo(todo);
                Navigator.of(context).pop();
                textEditingController.clear();
              },
              color: Theme.of(context).colorScheme.primary,
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        'TODO',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          messagesListView(),
        ],
      ),
    );
  }

  Widget messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(
              child: Text(
                "Add a todo",
              ),
            );
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index].data();
              String todoId = todos[index].id;
              print(todo);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  title: Text(todo.task),
                  subtitle: Text(
                    DateFormat("dd-MM-yyyy h:mm a").format(
                      todo.updatedOn.toDate(),
                    ),
                  ),
                  trailing: Checkbox(
                    onChanged: (value) {
                      Todo updatedTodo = todo.copyWith(
                          isDone: !todo.isDone, updatedOn: Timestamp.now());
                      _databaseService.updateTodo(todoId, updatedTodo);
                    },
                    value: todo.isDone,
                  ),
                  onLongPress: () {
                    _databaseService.deleteTodo(todoId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
