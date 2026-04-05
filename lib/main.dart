import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'screens/panel_detail_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const TraceabilityApp());
}

class TraceabilityApp extends StatefulWidget {
  const TraceabilityApp({super.key});

  @override
  State<TraceabilityApp> createState() => _TraceabilityAppState();
}

class _TraceabilityAppState extends State<TraceabilityApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was closed
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      _handleDeepLink(appLink);
    }

    // Handle links when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Expected: .../panel.html?Panel Sr No=PNL123
    // Handling potential space in query param name
    String? panelId = uri.queryParameters['Panel Sr No'] ?? uri.queryParameters['id'];
    
    if (panelId != null) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => PanelDetailScreen(panelId: panelId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'NewEn Traceability',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NewEn Traceability")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Welcome to Panel Traceability System",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Scan a QR code on an industrial panel to view its details and report.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // In a real app, you might have a "Scan Now" button that opens an in-app scanner
              // But per requirements, the app is launched via the system QR scanner (Deep Link)
              const Text(
                "Waiting for QR Scan...",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
