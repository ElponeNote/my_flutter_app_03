import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/post_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'utils/dummy_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final ThemeMode _themeMode = ThemeMode.dark;

  late final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final tabs = ['/home', '/search', '/post', '/activity', '/profile'];
          final currentIndex = tabs.indexOf(state.matchedLocation);
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavBar(
              currentIndex: currentIndex < 0 ? 0 : currentIndex,
              onTap: (idx) => context.go(tabs[idx]),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/post',
            pageBuilder: (context, state) => NoTransitionPage(
              child: PostScreen(
                onPost: (post) async {
                  await ref.read(postsProvider.notifier).addPost(post);
                  if (!context.mounted) return;
                  context.go('/home');
                },
              ),
            ),
          ),
          GoRoute(
            path: '/activity',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ActivityScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Thread SNS',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: _themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
