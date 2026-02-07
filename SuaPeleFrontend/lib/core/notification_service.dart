import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// --- CALLBACK DE BACKGROUND ---
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  debugPrint("Notificação em background clicada: ${details.payload}");
}

// Servico de NOtificacao
class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint("Erro ao obter fuso horário: $e");
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("Usuário clicou na notificação: ${details.payload}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> exibirNotificacaoImediata({
    required String titulo,
    required String corpo,
  }) async {
    try {
      final int id = Random().nextInt(100000);
      const androidDetails = AndroidNotificationDetails(
        'channel_feedback_user', 'Feedback do Sistema',
        channelDescription: 'Confirmações de ações realizadas no app',
        importance: Importance.max, priority: Priority.high,
      );
      await _notificationsPlugin.show(id, titulo, corpo, const NotificationDetails(android: androidDetails));
    } catch (e) {
      debugPrint("Erro notificação imediata: $e");
    }
  }

  static Future<void> agendarLembreteCustomizado({
    required int id,
    required String titulo,
    required String corpo,
    required String horario,
    DateTime? dataExata, // Para Consultas
    int? intervaloDias,  // Para Fotos
  }) async {
    try {
      final partes = horario.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);

      final agora = tz.TZDateTime.now(tz.local);
      late tz.TZDateTime dataAgendada;

      if (dataExata != null) {
        // Consulta
        dataAgendada = tz.TZDateTime(
            tz.local, dataExata.year, dataExata.month, dataExata.day, hora, minuto
        );
      } else if (intervaloDias != null) {
        // Foto que repete
        dataAgendada = tz.TZDateTime(
            tz.local, agora.year, agora.month, agora.day, 12, 0
        ).add(Duration(days: intervaloDias));
      } else {
        // Remedio que repete diariamente
        dataAgendada = tz.TZDateTime(
            tz.local, agora.year, agora.month, agora.day, hora, minuto
        );
        if (dataAgendada.isBefore(agora)) {
          dataAgendada = dataAgendada.add(const Duration(days: 1));
        }
      }

      await _notificationsPlugin.zonedSchedule(
        id, titulo, corpo, dataAgendada,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lembretes_saude_v2', 'Alertas de Saúde',
            importance: Importance.max, priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

        matchDateTimeComponents: dataExata != null ? null : DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Erro no agendamento: $e");
    }
  }}