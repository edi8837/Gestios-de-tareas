import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class WebSocketService {
  WebSocketChannel? _channel;
  final Function(String)?
      onMessageReceived; // Callback para manejar los mensajes recibidos

  // Constructor que acepta un callback para manejar los mensajes
  WebSocketService({this.onMessageReceived});

  // Método para establecer la conexión con el servidor WebSocket
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Escuchar los mensajes entrantes del WebSocket
      _channel!.stream.listen(
        (message) {
          // Cuando se recibe un mensaje, se pasa al callback
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
        },
        onError: (error) {
          // Manejo de errores de conexión
          print('Error en la conexión WebSocket: $error');
        },
        onDone: () {
          // Si la conexión se cierra, puedes manejar la desconexión aquí
          print('Conexión WebSocket cerrada');
        },
      );
    } catch (e) {
      print('Error al conectar al servidor WebSocket: $e');
    }
  }

  // Método para enviar un mensaje al servidor WebSocket
  void send(String message) {
    if (_channel != null && _channel!.sink.closeCode == null) {
      _channel!.sink.add(message); // Enviar mensaje al servidor WebSocket
    } else {
      print('Conexión WebSocket no está abierta');
    }
  }

  // Método para cerrar la conexión WebSocket
  void disconnect() {
    _channel?.sink.close(); // Cerrar la conexión WebSocket
    print('Desconectado del servidor WebSocket');
  }

  // Verificar si la conexión está abierta
  bool isConnected() {
    return _channel != null && _channel!.sink.closeCode == null;
  }
}

extension on WebSocketSink {
  get closeCode => null;
}
