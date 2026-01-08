import 'dart:async';
import 'dart:convert';

import 'package:eschool_saas_staff/data/models/chatMessage.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketSettingState {}

class SocketConnectSuccess extends SocketSettingState {}

class SocketConnectFailure extends SocketSettingState {}

class SocketMessageReceived extends SocketSettingState {
  final String from;
  final String to;
  final ChatMessage message;

  SocketMessageReceived({
    required this.from,
    required this.to,
    required this.message,
  });
}

class SocketSettingCubit extends Cubit<SocketSettingState> {
  SocketSettingCubit() : super(SocketSettingState());

  late Uri wsUrl;
  late WebSocketChannel channel;
  int _currentUserId = 0;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  StreamSubscription<dynamic>? streamSubscription;

  Future<void> init({required int userId}) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _currentUserId = userId;

    wsUrl = Uri.parse(socketUrl);

    try {
      // connect to socket
      channel = IOWebSocketChannel.connect(
        wsUrl,
        pingInterval: socketPingInterval,
      );

      // listen to socket events when it is ready
      await channel.ready;
      _isConnecting = false;
      _reconnectAttempts = 0;
      emit(SocketConnectSuccess());

      /// Register user with socket to listen to user messages (with user id)
      channel.sink.add(json.encode({
        "command": SocketEvent.register.name,
        "userId": userId,
      }));

      streamSubscription = channel.stream.listen(
        (event) {
          try {
            final eventMap = json.decode(event) as Map<String, dynamic>;

            if (eventMap["command"] == SocketEvent.message.name) {
              if (eventMap['to'].toString() == userId.toString()) {
                emit(
                  SocketMessageReceived(
                    from: eventMap['from'].toString(),
                    to: eventMap['to'].toString(),
                    message: ChatMessage.fromJson(
                        eventMap['message'] as Map<String, dynamic>),
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint("Error parsing socket message: $e");
          }
        },
        onError: (error) {
          debugPrint("Socket stream error: $error");
          _handleReconnect();
        },
        onDone: () {
          debugPrint("Socket connection closed");
          _handleReconnect();
        },
      );
    } catch (error) {
      _isConnecting = false;
      emit(SocketConnectFailure());
      debugPrint("Socket init error: $error");
      _handleReconnect();
    }
  }

  void _handleReconnect() {
    if (_isConnecting) return;

    // Clear previous subscription
    streamSubscription?.cancel();

    // Exponential backoff: 2s, 4s, 8s, 16s, max 30s
    _reconnectAttempts++;
    int delaySeconds = (1 << _reconnectAttempts).clamp(2, 30);

    debugPrint(
        "Attempting to reconnect in $delaySeconds seconds... (Attempt $_reconnectAttempts)");

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      init(userId: _currentUserId);
    });
  }

  void sendMessage({
    required int userId,
    required int receiverId,
    required ChatMessage message,
  }) async {
    try {
      channel.sink.add(
        json.encode({
          "command": SocketEvent.message.name,
          "from": userId,
          "to": receiverId,
          "message": message.toJson(),
        }),
      );
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Future<void> close() async {
    _reconnectTimer?.cancel();
    streamSubscription?.cancel();
    await channel.sink.close();
    super.close();
  }
}
