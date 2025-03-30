import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function()? onInit;

  const SplashScreen({super.key, this.onInit});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _executeOnInit();
  }

  Future<void> _executeOnInit() async {
    if (widget.onInit != null) {
      await widget.onInit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
