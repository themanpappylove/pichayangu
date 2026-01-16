import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  int _selectedIndex = 0;
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = api.getCurrentUser();
  }

  void _logout() async {
    await api.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardTab(),
      const _ClientsTab(),
      const _RecoveryTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Text(user != null ? 'Picha Yangu — ${user.username}' : 'Picha Yangu');
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.restore), label: 'Recovery'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome to Picha Yangu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Organize and manage your media files seamlessly across web and mobile.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/clients'),
                  icon: const Icon(Icons.people),
                  label: const Text('Manage Clients'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Client>>(
          future: api.getClients(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${snapshot.data!.length} Clients', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...snapshot.data!.take(3).map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${c.name}'),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ClientsTab extends StatelessWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Manage Clients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/clients'),
            child: const Text('Go to Clients'),
          ),
        ],
      ),
    );
  }
}

class _RecoveryTab extends StatelessWidget {
  const _RecoveryTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Recovery Vault', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/recovery'),
            child: const Text('View Recovery Vault'),
          ),
        ],
      ),
    );
  }
}
