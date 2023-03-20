import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onTap;

  const DurationPicker({super.key, required this.initialDuration, required this.onTap});

  @override
  State<StatefulWidget> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {

  late Duration _newDuration = widget.initialDuration;

  Future<void> selectDuration(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _newDuration.inHours, minute: _newDuration.inMinutes % 60),
    );

    setState(() {
      if (time != null) {
        _newDuration = Duration(hours: time.hour, minutes: time.minute);
      } else {
        _newDuration = const Duration(hours:0, minutes: 0);
      }
      widget.onTap(_newDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectDuration(context);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_newDuration.inHours.remainder(24).toString().padLeft(
                  2, '0')}:${(_newDuration.inMinutes.remainder(60))
                  .toString()
                  .padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}