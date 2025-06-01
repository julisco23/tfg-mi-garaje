import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorScreen extends StatefulWidget {
  final void Function()? onRetry;
  final String errorMessage;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  void _retry() {
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.error)),
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
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }
}
