import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/media_screen.dart';
import 'screens/file_detail_screen.dart';
import 'screens/recovery_vault_screen.dart';

void main() {
  runApp(const PichaYanguApp());
}

class PichaYanguApp extends StatelessWidget {
  const PichaYanguApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picha Yangu',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/recovery': (context) => const RecoveryVaultScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/projects') {
          final clientId = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => ProjectsScreen(clientId: clientId));
        } else if (settings.name == '/media') {
          final projectId = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => MediaScreen(projectId: projectId));
        } else if (settings.name == '/file_detail') {
          final fileId = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => FileDetailScreen(fileId: fileId));
        }
        return null;
      },
    );
  }
}
