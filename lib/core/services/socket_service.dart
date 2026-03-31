import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  io.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected == true;

  void connect({
    required String baseUrl,
    required String token,
  }) {
    log('🟡 Intentando conectar socket...');
    log('🟡 baseUrl: $baseUrl');
    log('🟡 token enviado: $token');

    if (_socket != null) {
      disconnect();
    }

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setAuth({
            'token': token,
          })
          .build(),
    );

    _socket!.onConnect((_) {
      log('✅ Socket conectado: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      log('❌ Socket desconectado: $reason');
    });

    _socket!.onConnectError((error) {
      log('⚠️ Socket connect error: $error');
    });

    _socket!.onError((error) {
      log('⚠️ Socket error: $error');
    });

    _socket!.on('socket:connected', (data) {
      log('📩 socket:connected => $data');
    });

    _socket!.connect();
  }

  void on(String event, Function(dynamic data) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}