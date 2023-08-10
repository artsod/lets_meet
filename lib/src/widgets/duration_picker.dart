import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onTap;
  final bool enabled;

  const DurationPicker({super.key, required this.initialDuration, required this.onTap, required this.enabled});

  @override
  State<StatefulWidget> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {

  late Duration _newDuration = widget.initialDuration;
  late int _selectedHours = _newDuration.inHours.remainder(24);
  late int _selectedMinutes = _newDuration.inMinutes.remainder(60);

  Future<TimeOfDay?> showDurationPicker(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    return showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Meeting duration'),
          content: StatefulBuilder(
              builder: (context, SBsetState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NumberPicker(
                      value: _selectedHours,
                      minValue: 0,
                      maxValue: 24,
                      selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 30),
                      itemWidth: 50,
                      onChanged: (value) {
                        setState(() => _selectedHours = value);
                        SBsetState(() => _selectedHours = value);
                      },
                    ),
                    const Text('h'),
                    const SizedBox(width: 20),
                    NumberPicker(
                      value: _selectedMinutes,
                      minValue: 0,
                      maxValue: 55,
                      step: 5,
                      selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 30),
                      itemWidth: 50,
                      onChanged: (value) {
                        setState(() => _selectedMinutes = value);
                        SBsetState(() => _selectedMinutes = value);
                      },
                    ),
                    const Text('min'),
                  ],
                );
              }
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(TimeOfDay(
                  hour: _selectedHours,
                  minute: _selectedMinutes,
                ));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectDuration(BuildContext context) async {
    final TimeOfDay? time = await showDurationPicker(context);

    setState(() {
      if (time != null) {
        _newDuration = Duration(hours: time.hour, minutes: time.minute);
      }
      widget.onTap(_newDuration);
    });
    print(_newDuration.toString());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? () {selectDuration(context);} : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.more_time, size: 16, color: widget.enabled ? Colors.black : Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${_newDuration.inHours.remainder(24).toString().padLeft(2)}h '
              '${(_newDuration.inMinutes.remainder(60)).toString().padLeft(2)}min',
              style: TextStyle(fontSize: 12, color: widget.enabled ? Colors.black : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
