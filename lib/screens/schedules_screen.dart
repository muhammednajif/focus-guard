import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/app_service.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  late Box scheduleBox;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    scheduleBox = await Hive.openBox('schedules');
    setState(() {
      isLoading = false;
    });
  }

  void _syncToNative() {
    final List<Map<dynamic, dynamic>> schedules = [];
    for (int i = 0; i < scheduleBox.length; i++) {
      schedules.add(scheduleBox.getAt(i) as Map<dynamic, dynamic>);
    }
    AppService.updateSchedules(schedules);
  }

  Future<void> _showScheduleDialog({int? index}) async {
    Map<dynamic, dynamic> schedule = index != null
        ? Map<dynamic, dynamic>.from(scheduleBox.getAt(index) as Map<dynamic, dynamic>)
        : {
            'name': 'New Schedule',
            'startHour': 9,
            'startMinute': 0,
            'endHour': 17,
            'endMinute': 0,
            'enabled': true,
          };

    final nameController = TextEditingController(text: schedule['name'] as String);
    TimeOfDay startTime = TimeOfDay(hour: schedule['startHour'] as int, minute: schedule['startMinute'] as int);
    TimeOfDay endTime = TimeOfDay(hour: schedule['endHour'] as int, minute: schedule['endMinute'] as int);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(index == null ? "Add Schedule" : "Edit Schedule"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Schedule Name"),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text("Start Time"),
                    trailing: Text(startTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: startTime);
                      if (time != null) setDialogState(() => startTime = time);
                    },
                  ),
                  ListTile(
                    title: const Text("End Time"),
                    trailing: Text(endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: endTime);
                      if (time != null) setDialogState(() => endTime = time);
                    },
                  ),
                ],
              ),
              actions: [
                if (index != null)
                  TextButton(
                    onPressed: () {
                      scheduleBox.deleteAt(index);
                      _syncToNative();
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    schedule['name'] = nameController.text.trim().isEmpty ? "Schedule" : nameController.text.trim();
                    schedule['startHour'] = startTime.hour;
                    schedule['startMinute'] = startTime.minute;
                    schedule['endHour'] = endTime.hour;
                    schedule['endMinute'] = endTime.minute;

                    if (index == null) {
                      scheduleBox.add(schedule);
                    } else {
                      scheduleBox.putAt(index, schedule);
                    }
                    _syncToNative();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Schedules"),
      ),
      body: scheduleBox.isEmpty
          ? const Center(child: Text("No schedules set. Tap + to create one."))
          : ListView.builder(
              itemCount: scheduleBox.length,
              itemBuilder: (context, index) {
                final schedule = scheduleBox.getAt(index) as Map<dynamic, dynamic>;
                final start = TimeOfDay(hour: schedule['startHour'] as int, minute: schedule['startMinute'] as int);
                final end = TimeOfDay(hour: schedule['endHour'] as int, minute: schedule['endMinute'] as int);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(schedule['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${start.format(context)} - ${end.format(context)}'),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: schedule['enabled'] as bool,
                      onChanged: (val) {
                        schedule['enabled'] = val;
                        scheduleBox.putAt(index, schedule);
                        _syncToNative();
                        setState(() {});
                      },
                    ),
                    onTap: () => _showScheduleDialog(index: index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}