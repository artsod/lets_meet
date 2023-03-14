import 'package:flutter/material.dart';

//This duration picker isn't perfect, but for now it's ok. Change it later (especially to select from something other than clock)
class DurationPicker {
  Duration duration = const Duration(hours: 0, minutes: 0);

  Future<Duration> selectDuration(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: duration.inHours, minute: duration.inMinutes % 60),
    );

    if (time != null) {
      duration = Duration(hours: time.hour, minutes: time.minute);
    } else {
      duration = const Duration(hours:0, minutes: 0);
    }
    return duration;
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => selectDuration(context),
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
              '${duration.inHours.remainder(24).toString().padLeft(2, '0')}:${(duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}