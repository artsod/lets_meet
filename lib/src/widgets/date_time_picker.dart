import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime) onChanged;
  final bool enabled;

  const DateTimePicker({super.key, required this.onChanged, required this.enabled});

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _dateTime;
  //##Locale myLocale = Localizations.localeOf(this.context); //Implement later

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _showDateTimePicker : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: widget.enabled ? Colors.black : Colors.grey),
            const SizedBox(width: 6),
            Text(_formatDateTime(_dateTime), style: TextStyle(fontSize: 12, color: widget.enabled ? Colors.black : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final date = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2023),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary, //
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary, // button text color
                ),
              ),
            ),
            child: child!,
          );
        }
    );
    if (date != null) {
      final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_dateTime),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );
          }
      );
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _dateTime = dateTime;
        });
        widget.onChanged(dateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    //return DateFormat.yMd(myLocale.languageCode).format(now) //Implement later
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}