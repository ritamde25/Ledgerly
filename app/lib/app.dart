import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/history_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/auth_screen.dart';
import 'core/db/providers.dart';
import 'core/auth/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return MaterialApp(
      title: 'Ledgerly',
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white, // menu background
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          surface: const Color(0xFFF7F7F7),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF6366F1).withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          elevation: 10,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4F46E5),
                letterSpacing: 0.2,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: Color(0xFF4F46E5),
                size: 26,
              );
            }
            return const IconThemeData(
              color: Color(0xFF6B7280),
              size: 24,
            );
          }),
        ),
      ),
      home: user == null ? const AuthScreen(showSkip: false) : const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    CustomersScreen(),
    InventoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).syncAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    ref.listen(userProvider, (previous, next) {
      if (next != null) {
        ref.read(syncServiceProvider).syncAll();
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Bills',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Customers',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Inventory',
            ),
          ],
        ),
      ),
    );
  }
}
