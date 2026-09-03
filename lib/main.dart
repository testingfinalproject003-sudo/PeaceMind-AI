import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/audio_call_provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/daily_routine_provider.dart';
import 'providers/routine_provider.dart';
import 'screens/auth_gate.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web par network WebSocket timing issue fix
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: true,
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PeaceMindApp());
}

class PeaceMindApp extends StatelessWidget {
  const PeaceMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    // RoutineProvider pehle banao taake AuthProvider user ke
    // login/logout par usko bindUser() se sync kar sake.
    final routineProvider = RoutineProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: routineProvider),

        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(routineProvider: routineProvider)..loadUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioCallProvider(routineProvider: routineProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => DailyRoutineProvider(routineProvider: routineProvider),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PeaceMind AI',

        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFE0F7FA),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: Brightness.light,
          ),
        ),
        routes: {'/chat': (context) => const ChatScreen()},
        home: const AuthGate(),
      ),
    );
  }
}
