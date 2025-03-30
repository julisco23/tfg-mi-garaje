import 'package:flutter/material.dart';

class MiTextFormField extends StatelessWidget {
  const MiTextFormField({
    super.key,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  })  : _controller = controller,
        _labelText = labelText,
        _hintText = hintText;

  final TextEditingController _controller;
  final String _labelText;
  final String _hintText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool obscureText;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: Theme.of(context).primaryColor,
      cursorErrorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: _labelText,

        hintText: _hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      validator: validator
    );
  }
}


