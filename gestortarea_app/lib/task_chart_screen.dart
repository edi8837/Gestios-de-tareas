import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestortarea_app/Service/task_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TaskChartScreen extends StatefulWidget {
  @override
  _TaskChartScreenState createState() => _TaskChartScreenState();
}

class _TaskChartScreenState extends State<TaskChartScreen> {
  final TaskService _taskService = TaskService();
  Map<String, int> _taskStats = {'completed': 0, 'pending': 0, 'deleted': 0};
  bool _isLoading = true;

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _loadStats();

    // Establecer WebSocket para recibir actualizaciones
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:5222/ws'));

    _channel.stream.listen((message) {
      // Aquí deberías manejar el mensaje y actualizar las estadísticas
      print('Mensaje recibido del WebSocket: $message');
      _updateStats(message);
    });
  }

  void _loadStats() async {
    try {
      final stats = await _taskService.getTaskStats();
      setState(() {
        _taskStats = stats ?? {'completed': 0, 'pending': 0, 'deleted': 0};
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estadísticas: $error')),
      );
    }
  }

  // Actualizar estadísticas a través de WebSocket
  void _updateStats(String message) {
    setState(() {
      if (message == 'Tarea completada') {
        _taskStats['completed'] = _taskStats['completed']! + 1;
      } else if (message == 'Tarea pendiente') {
        _taskStats['pending'] = _taskStats['pending']! + 1;
      } else if (message == 'Tarea eliminada') {
        _taskStats['deleted'] = _taskStats['deleted']! + 1;
      }
    });
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            (_taskStats.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label;
              switch (group.x.toInt()) {
                case 0:
                  label = 'Completadas';
                  break;
                case 1:
                  label = 'Pendientes';
                  break;
                case 2:
                  label = 'Eliminadas';
                  break;
                default:
                  label = '';
              }
              return BarTooltipItem(
                '$label: ${rod.toY.round()}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            margin: 8,
            getTitles: (value) =>
                value % 1 == 0 ? value.toInt().toString() : '',
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            margin: 16,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return 'Completadas';
                case 1:
                  return 'Pendientes';
                case 2:
                  return 'Eliminadas';
                default:
                  return '';
              }
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarChartGroup(0, _taskStats['completed']!, Colors.green),
          _buildBarChartGroup(1, _taskStats['pending']!, Colors.orange),
          _buildBarChartGroup(2, _taskStats['deleted']!, Colors.red),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarChartGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y.toDouble(),
          colors: [color],
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _channel.sink.close(); // Cerrar WebSocket cuando la pantalla se cierre
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de Tareas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gráfica ocupa el 80% del ancho
                  Expanded(
                    flex: 4,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildBarChart(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Estadísticas ocupan el 20% del ancho
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildStatItem('Completadas', _taskStats['completed']!,
                            Colors.green),
                        _buildStatItem('Pendientes', _taskStats['pending']!,
                            Colors.orange),
                        _buildStatItem(
                            'Eliminadas', _taskStats['deleted']!, Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

extension on BarChartRodData {
  get toY => null;
}
