import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/motion.dart';
import 'home_screen.dart';

/// The round icon on cream, like the iOS launch screen and the Android 12
/// splash, so starting up looks like one calm screen: nothing to read.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 450),
    vsync: this,
  );
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reduceMotion(context)) {
        _controller.value = 1;
      } else {
        unawaited(_controller.forward());
      }
      unawaited(_initializeApp());
    });
  }

  Future<void> _initializeApp() async {
    final appProvider = context.read<AppProvider>();

    await Future.wait([
      appProvider.init(),
      // Brief, so a child is colouring within a second or two.
      Future.delayed(const Duration(milliseconds: 600)),
    ]);

    if (mounted) {
      unawaited(Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E6),
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ScaleTransition(
            scale: _scale,
            child: ClipOval(
              child: Image.asset('assets/images/app_icon.png', width: 160, height: 160, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
