import 'package:flutter/material.dart';

// Pages
import 'splashScreen.dart';
import 'pages/bannerPage.dart';
import 'pages/profile.dart';
import 'pages/registerPage.dart';
import 'homePage2.dart';
import 'pages/loginPage.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/banner': (context) => const BannerPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage2(),
        '/profile': (context) => const ProfileInfo(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/register') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RegisterPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }
}
