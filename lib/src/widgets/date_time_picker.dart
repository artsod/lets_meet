import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime) onChanged;

  const DateTimePicker({super.key, required this.onChanged});

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _dateTime;
  final Color _color = Colors.orange.shade700;
  //Locale myLocale = Localizations.localeOf(this.context); //Implement later

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDateTimePicker,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 6),
            Text(_formatDateTime(_dateTime), style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2023),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: _color, //
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: _color, // button text color
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
                    primary: _color,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(_color)),
                  ),
                  timePickerTheme: TimePickerThemeData(
                      dialHandColor: _color,
                      dialBackgroundColor: Colors.white,
                      hourMinuteTextColor: _color,
                      entryModeIconColor: _color,
                      inputDecorationTheme: const InputDecorationTheme(
                        enabledBorder: InputBorder.none,
                        filled: true,
                      )
                  )
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