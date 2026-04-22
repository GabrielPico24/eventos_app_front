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
    log('🟡 SOCKET CONNECT -> baseUrl: $baseUrl');
    log('🟡 SOCKET CONNECT -> token: $token');

    disconnect();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000)
          .setAuth({
            'token': token,
          })
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      log('🟢 SOCKET CONECTADO: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      log('🔴 SOCKET DESCONECTADO: $reason');
    });

    _socket!.onReconnect((attempt) {
      log('🔁 SOCKET RECONTECTADO en intento: $attempt');
    });

    _socket!.onReconnectAttempt((attempt) {
      log('🔄 SOCKET RECONNECT ATTEMPT: $attempt');
    });

    _socket!.onConnectError((error) {
      log('❌ SOCKET CONNECT ERROR: $error');
    });

    _socket!.onError((error) {
      log('❌ SOCKET ERROR: $error');
    });

    _socket!.on('socket:connected', (data) {
      log('📩 socket:connected => $data');
    });

    _socket!.connect();
  }

  void reconnectWithToken({
    required String baseUrl,
    required String token,
  }) {
    log('🔄 RECONNECT SOCKET WITH NEW TOKEN');

    disconnect();

    connect(
      baseUrl: baseUrl,
      token: token,
    );
  }

  void on(String event, Function(dynamic data) handler) {
    _socket?.off(event);
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    if (_socket != null) {
      log('🔌 CERRANDO SOCKET ANTERIOR...');

      _socket!.off('socket:connected');
      _socket!.off('connect');
      _socket!.off('disconnect');
      _socket!.off('connect_error');
      _socket!.off('error');
      _socket!.off('reconnect');
      _socket!.off('reconnect_attempt');

      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}
