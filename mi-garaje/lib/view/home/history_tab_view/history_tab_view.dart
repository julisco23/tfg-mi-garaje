import 'package:flutter/material.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
  });

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text('Historial', style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: Center(
            child: Text(
              'Más información próximamente'
            ),
          ),
        ),
      ],
    ),
  );
}

}
