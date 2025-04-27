import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final void Function() onRetry;
  final String errorMessage;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {

  void _retry() {
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}