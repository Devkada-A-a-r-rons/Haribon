import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import './features/common/widgets/nav_bar.dart';
import './features/vehicle-intelligence/vehicle_intelligence_screen.dart';
import './features/smart-trip-planner/smart-trip-planner.dart';
import './features/fuel-and-emissions/fuel-and-emissions.dart';
import './features/home/home_screen.dart';
import './features/chatbot/chatbot_screen.dart';
import './features/settings/settings_screen.dart';
import './features/onboarding/welcome_screen.dart';
import './features/onboarding/onboarding_screen.dart';
import './features/history/history_screen.dart';
import 'package:haribon/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    DevicePreview(
      enabled: true,
      isToolbarVisible: true, 
      defaultDevice: Devices.ios.iPhone13,
      builder: (context) => const MyApp(),
    ),
  );

  // runApp(const MyApp()); // If not using device preview
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final ValueNotifier<String?> currentRouteNotifier = ValueNotifier<String?>(
  null,
);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haribon',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      navigatorObservers: [routeObserver, _RouteNotifierObserver()],
      builder: (context, child) {
        return DevicePreview.appBuilder(context, GlobalShell(child: child));
      },
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget builder;
        switch (settings.name) {
          case '/':
            builder = const WelcomeScreen();
            break;
          case '/onboarding':
            builder = const OnboardingScreen();
            break;
          case '/home':
            builder = const MainScreen();
            break;
          case '/smart-trip-planner':
            builder = const SmartTripPlanner();
            break;
          case '/settings':
            builder = const SettingsScreen();
            break;
          case '/chatbot':
            builder = const ChatbotScreen();
            break;
          default:
            builder = const WelcomeScreen();
        }
        return MaterialPageRoute(
          builder: (context) => builder,
          settings: settings,
        );
      },
    );
  }
}

class _RouteNotifierObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentRouteNotifier.value = route.settings.name;
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentRouteNotifier.value = previousRoute?.settings.name;
    });
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentRouteNotifier.value = newRoute?.settings.name;
    });
  }
}

class GlobalShell extends StatefulWidget {
  final Widget? child;
  const GlobalShell({super.key, this.child});

  @override
  State<GlobalShell> createState() => _GlobalShellState();
}

class _GlobalShellState extends State<GlobalShell> {
  Offset _offset = Offset.zero;
  bool _isInit = false;
  bool _isDragging = false;
  final Size _fabSize = const Size(56, 56);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (!_isInit && size.width > 0 && size.height > 0) {
      _offset = Offset(
        size.width - _fabSize.width - 20,
        size.height - _fabSize.height - 110,
      );
      _isInit = true;
    }
  }

  void _snapToEdge() {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final safeTop = padding.top + 80.0;
    final safeBottom = size.height - padding.bottom - 100.0 - _fabSize.height;
    final safeLeft = 20.0;
    final safeRight = size.width - _fabSize.width - 20.0;

    final dLeft = (_offset.dx - safeLeft).abs();
    final dRight = (_offset.dx - safeRight).abs();
    double newX = dLeft < dRight ? safeLeft : safeRight;
    double newY = _offset.dy.clamp(safeTop, safeBottom);

    setState(() {
      _offset = Offset(newX, newY);
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width == 0 || size.height == 0)
      return widget.child ?? const SizedBox.shrink();

    final padding = MediaQuery.of(context).padding;
    final safeTop = padding.top + 80.0;
    final safeBottom = size.height - padding.bottom - 100.0 - _fabSize.height;
    final safeLeft = 20.0;
    final safeRight = size.width - _fabSize.width - 20.0;

    return ValueListenableBuilder<String?>(
      valueListenable: currentRouteNotifier,
      builder: (context, routeName, _) {
        final name = routeName ?? '/';
        final isExcluded =
            name == '/' || name == '/onboarding' || name == '/chatbot';

        return Stack(
          children: [
            if (widget.child != null) widget.child!,
            if (!isExcluded)
              AnimatedPositioned(
                duration: Duration(milliseconds: _isDragging ? 0 : 300),
                curve: Curves.easeOutCubic,
                left: _offset.dx,
                top: _offset.dy,
                child: GestureDetector(
                  onPanStart: (_) => setState(() => _isDragging = true),
                  onPanUpdate: (details) {
                    setState(() {
                      _offset += details.delta;
                      _offset = Offset(
                        _offset.dx.clamp(safeLeft - 20, safeRight + 20),
                        _offset.dy.clamp(safeTop - 20, safeBottom + 20),
                      );
                    });
                  },
                  onPanEnd: (_) => _snapToEdge(),
                  child: Material(
                    type: MaterialType.transparency,
                    child: FloatingActionButton(
                      heroTag: 'global_chatbot_fab',
                      onPressed: () {
                        navigatorKey.currentState?.pushNamed('/chatbot');
                      },
                      backgroundColor: AppColors.primaryMain,
                      elevation: 8,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Default to Home

  List<Widget> get _screens => [
    const HomeScreen(), // 0 - Home
    const VehicleIntelligenceScreen(), // 1 - Planner
    const SmartTripPlanner(), // 2 - Smart Trip
    const HistoryScreen(), // 3 - History
    const FuelAndEmissionsScreen(), // 4 - Analysis
    const ChatbotScreen(), // 5 - Chatbot (hidden)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CommonNavBar(
        activeIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
