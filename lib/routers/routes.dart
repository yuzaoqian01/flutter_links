import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:web3_links/ui/home/widgets/home_page.dart';
import 'package:web3_links/ui/me/widgets/me_page.dart';
import 'package:web3_links/ui/login/widgets/login.dart';
import 'package:web3_links/ui/me/widgets/user_profile.dart';

// 路由
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  // redirect: (context, state) {
    
  // },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavbar(
          navigationShell:navigationShell
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'home',
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ]
        ),
        StatefulShellBranch(
          routes: [
             GoRoute(
              name: 'me',
              path: '/me',
              builder: (context, state) => const MePage(),
              routes: [
                GoRoute(
                  name: 'profile',
                  path: 'profile',
                  builder: (context, state) => const UserProfile(),
                )
              ]
            ),
          ]
        )
      ]
    )
  ],
);

GoRouter get router => _router;


class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    // appLogger.info('ScaffoldWithNavbar: current path: $path');
    
    // 检查当前路由是否为主路由
    final isMainRoute = path == '/home' || path == '/me';
    
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: isMainRoute
          ? Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (int index) => widget.navigationShell.goBranch(index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '首页'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '我的'
                  )
                ],
              ),
            )
          : null,
    );
  }
}