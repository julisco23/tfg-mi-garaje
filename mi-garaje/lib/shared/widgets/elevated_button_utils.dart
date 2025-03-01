import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';

class MiButton extends StatelessWidget {
  const MiButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.side = BorderSide.none,
    this.imagen,
    this.icon,
  });

  final String text;
  final Function onPressed;
  final dynamic backgroundColor;
  final dynamic side;
  final String? imagen;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: side,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagen != null) ...[
              Image.asset(
                imagen!,
                width: 24,
                height: 24,
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
            ],
            if (icon != null) ...[
              Icon(icon, color: Colors.blue),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: backgroundColor == Colors.blue
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
