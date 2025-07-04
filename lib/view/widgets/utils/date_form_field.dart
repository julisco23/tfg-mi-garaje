import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onDateSelected;

  const DatePickerField({
    super.key,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _updateTextField();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateTextField();
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  void _updateTextField() {
    _controller.text = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : "";
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: localizations.date,
        hintText: localizations.selectDate,
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (selectedDate == null) {
          return localizations.pleaseSelectDate;
        }
        return null;
      },
    );
  }
}
