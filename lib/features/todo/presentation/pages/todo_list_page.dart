import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const LoadTodosEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todoList),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TodoBloc>().add(const LoadTodosEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noTodos,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return TodoItem(
                  todo: todo,
                  onToggle: () {
                    context.read<TodoBloc>().add(ToggleTodoEvent(todo.id));
                  },
                  onEdit: () {
                    _showTodoDialog(context, todo: todo);
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, todo);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTodoDialog(BuildContext context, {Todo? todo}) {
    showDialog(
      context: context,
      builder: (context) => TodoDialog(todo: todo),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Todo todo) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTodo),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
              Navigator.of(context).pop();
            },
            child: Text(l10n.deleteTodo),
          ),
        ],
      ),
    );
  }
}

class TodoDialog extends StatefulWidget {
  final Todo? todo;

  const TodoDialog({super.key, this.todo});

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.todo != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editTodo : l10n.addTodo),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.todoTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.todoDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _saveTodo,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.todo != null) {
        // Update existing todo
        final updatedTodo = widget.todo!.copyWith(
          title: title,
          description: description,
          updatedAt: DateTime.now(),
        );
        context.read<TodoBloc>().add(UpdateTodoEvent(updatedTodo));
      } else {
        // Create new todo
        final newTodo = Todo(
          id: const Uuid().v4(),
          title: title,
          description: description,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        context.read<TodoBloc>().add(AddTodoEvent(newTodo));
      }

      Navigator.of(context).pop();
    }
  }
}
