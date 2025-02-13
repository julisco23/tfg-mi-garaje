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
  })  : _controller = controller,
        _labelText = labelText,
        _hintText = hintText;

  final TextEditingController _controller;
  final String _labelText;
  final String _hintText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
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


