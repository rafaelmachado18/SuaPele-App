import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// IMPORTS DE FUSO HORÁRIO
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'core/app_config.dart';
import 'core/notification_service.dart';
import '/home/telas_home.dart';
import '/analise/telas_analise.dart';
import '/manchas/telas_manchas.dart';
import '/tratamentos/telas_tratamento.dart';
import '/autentificacao/telas_autentificacao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() async {
  // garante carregamento de plugins e componentes
  WidgetsFlutterBinding.ensureInitialized();

  // configura tela cheia e barras transparentes
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // inicializa servico de notificacoes locais
  await NotificationService.init();

  runApp(const SuaPeleApp());
}

class SuaPeleApp extends StatelessWidget {
  const SuaPeleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // forca estilo visual no sistema operacional
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: 'Sua Pele Front',
        debugShowCheckedModeBanner: false,
        // define tema cores e padrao material 3
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91E63),
            primary: const Color(0xFFE91E63),
            secondary: const Color(0xFF2196F3),
            tertiary: const Color(0xFF4CAF50),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFFE91E63).withOpacity(0.1),
          ),
        ),
        // define tela de login como inicial
        home: const TelaLogin(),
      ),
    );
  }
}