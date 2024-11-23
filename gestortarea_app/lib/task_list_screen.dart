import 'package:flutter/material.dart';
import 'package:gestortarea_app/Service/task_service.dart';
import 'package:gestortarea_app/task.dart';
import 'package:gestortarea_app/task_chart_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // Importar WebSocketChannel

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse(
        'ws://localhost:5222/ws'), // Asegúrate de que esta URL sea correcta
  );

  late List<Task> _tasks =
      []; // Cambiado a lista mutable para actualizaciones en tiempo real

  @override
  void initState() {
    super.initState();

    // Cargar las tareas inicialmente
    _loadTasks();

    // Escuchar los mensajes del servidor WebSocket
    _channel.stream.listen((message) {
      print('Mensaje recibido del servidor: $message');

      // Aquí asumimos que el servidor envía un mensaje con la nueva tarea agregada
      // Si el mensaje es un JSON o una cadena, debes ajustar este parsing según la respuesta
      if (message.contains("Nueva tarea agregada")) {
        _loadTasks(); // Recargar las tareas desde el servidor
      }
    });
  }

  // Método para cargar las tareas desde el servidor
  Future<void> _loadTasks() async {
    final tasks = await TaskService().getTasks();
    setState(() {
      _tasks = tasks; // Actualiza la lista de tareas en el estado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestor de Tareas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskChartScreen()),
              );
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                Task task = _tasks[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  tileColor:
                      task.isCompleted ? Colors.green.shade100 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: task.isCompleted
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    task.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      SizedBox(
                          height:
                              5), // Espaciado entre la descripción y las fechas
                      Text(
                        'Inicio: ${task.startDate?.split(' ')[0]}', // Mostrar fecha de inicio
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        'Fin: ${task.endDate?.split(' ')[0]}', // Mostrar fecha de fin
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await TaskService().completeTask(task.id);
                          setState(() {
                            task.isCompleted = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tarea completada')));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await TaskService().deleteTask(task.id);
                          setState(() {
                            _tasks.removeAt(
                                index); // Elimina la tarea de la lista local
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tarea Eliminada')));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Agregar Tarea',
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  // Mostrar el diálogo para agregar tarea
  void _showAddTaskDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _startDateController = TextEditingController();
    final _endDateController = TextEditingController();

    DateTime? _startDate;
    DateTime? _endDate;

    void _selectDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            _startDate = picked;
            _startDateController.text = '${picked.toLocal()}'.split(' ')[0];
          } else {
            _endDate = picked;
            _endDateController.text = '${picked.toLocal()}'.split(' ')[0];
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Center(
                child: Text(
                  'Agregar nueva tarea',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la tarea',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15), // Espaciado entre campos
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4, // Área de texto
                      decoration: InputDecoration(
                        labelText: 'Descripción de la tarea',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Mostrar la fecha de inicio seleccionada
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            labelText: 'Fecha de inicio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onTap: () => _selectDate(context, true),
                          readOnly:
                              true, // Para evitar que el usuario edite directamente
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            labelText: 'Fecha de fin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onTap: () => _selectDate(context, false),
                          readOnly:
                              true, // Para evitar que el usuario edite directamente
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        _startDate == null ||
                        _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Por favor, completa todos los campos')),
                      );
                      return;
                    }

                    // Crear la nueva tarea
                    Task newTask = Task(
                      id: 0, // Será generado por el backend
                      name: _nameController.text,
                      description: _descriptionController.text,
                      startDate: _startDate.toString(),
                      endDate: _endDate.toString(),
                    );
                    print(newTask.toJson());
                    // Agregar la tarea al backend
                    await TaskService().addTask(newTask);
                    SnackBar(content: Text('Tarea Agregada'));
                    // Enviar un mensaje al WebSocket
                    _channel.sink.add('Nueva tarea agregada: ${newTask.name}');

                    // Recargar las tareas automáticamente
                    _loadTasks();

                    Navigator.pop(context); // Cerrar el diálogo
                  },
                  child: Text(
                    'Agregar',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Cerrar la conexión WebSocket cuando la pantalla se destruya
    _channel.sink.close();
    super.dispose();
  }
}
