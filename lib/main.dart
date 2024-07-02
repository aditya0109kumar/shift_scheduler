import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Shift Scheduler')),
        body: Container(
            width: MediaQuery.of(context).size.width - 40,
            height: 405,
            child: RoutingCriteriaCalendarWidget(context: context)));
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  void notifyListeners(CalendarDataSourceAction action, List<dynamic> data) {
    // appointments = data.cast<Appointment>();
    super.notifyListeners(action, data);
  }
}

class RoutingCriteriaCalendarWidget extends StatefulWidget {
  const RoutingCriteriaCalendarWidget({super.key, required this.context});
  final BuildContext context;

  @override
  State<RoutingCriteriaCalendarWidget> createState() =>
      _RoutingCriteriaCalendarWidgetState();
}

class _RoutingCriteriaCalendarWidgetState
    extends State<RoutingCriteriaCalendarWidget> {
  List<Appointment> appointments = [];
  AppointmentDataSource? appointmentDataSource;
  Appointment? _selectedAppointment;

  @override
  void initState() {
    super.initState();
    appointmentDataSource = AppointmentDataSource(appointments);
  }

  @override
  Widget build(BuildContext ctx) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                for (var time in [
                  '12AM',
                  '2AM',
                  '4AM',
                  '6AM',
                  '8AM',
                  '10AM',
                  '12AM',
                  '2PM',
                  '4PM',
                  '6PM',
                  '8PM',
                  '10PM',
                  '12AM ',
                ])
                  Expanded(
                    child: Center(
                      child: Text(
                        time,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      child: Row(
                        children: [
                          for (var day in [
                            'Sun',
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat'
                          ])
                            Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox.expand(
                        child: SfCalendar(
                          view: CalendarView.week,
                          timeSlotViewSettings: const TimeSlotViewSettings(
                            startHour: 00,
                            endHour: 24,
                            timeInterval: Duration(hours: 2),
                            timeFormat: 'h a',
                            timeTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            timeIntervalHeight: 30,
                            timeRulerSize: 0,
                          ),
                          dataSource: appointmentDataSource,
                          onTap: _onCalendarTapped,
                          viewHeaderHeight: 0,
                          headerHeight: 0,
                          viewHeaderStyle: const ViewHeaderStyle(
                            dayTextStyle:
                                TextStyle(color: Colors.black, fontSize: 16),
                            dateTextStyle: TextStyle(color: Colors.transparent),
                          ),
                          viewNavigationMode: ViewNavigationMode.none,
                          showDatePickerButton: false,
                          showNavigationArrow: false,
                          allowDragAndDrop: false,
                          allowAppointmentResize: false,
                          dragAndDropSettings: const DragAndDropSettings(
                            allowScroll: false,
                          ),
                          onDragEnd: _onDragEnd,
                          onAppointmentResizeEnd: _onAppointmentResizeEnd,
                          appointmentBuilder: (context, details) {
                            final Appointment appointment =
                                details.appointments.first;
                            return Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: appointment.color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${appointment.subject}\n${appointment.startTime.hour % 12 == 0 ? 12 : appointment.startTime.hour % 12}${appointment.startTime.hour < 12 ? 'am' : 'pm'} - ${appointment.endTime.hour % 12 == 0 ? 12 : appointment.endTime.hour % 12}${appointment.endTime.hour < 12 ? 'am' : 'pm'}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          selectionDecoration: const BoxDecoration(),
                          initialSelectedDate: null,
                          todayHighlightColor: Colors.transparent,
                          todayTextStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      final DateTime startTime = details.date!;
      final DateTime endTime = startTime.add(Duration(hours: 10));
      final Appointment newAppointment = Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: 'Shift',
        color: Colors.red,
        recurrenceRule: 'FREQ=DAILY;COUNT=1',
      );

      setState(() {
        appointments.add(newAppointment);
        appointmentDataSource!
            .notifyListeners(CalendarDataSourceAction.add, [newAppointment]);
      });
    } else if (details.targetElement == CalendarElement.appointment) {
      _selectedAppointment = details.appointments!.first;
      _showEditDialog();
    }
  }

  void _onDragEnd(AppointmentDragEndDetails details) {
    setState(() {
      final Appointment appointment = details.appointment as Appointment;
      final DateTime newStartTime = details.droppingTime!;
      final DateTime newEndTime = newStartTime
          .add(appointment.endTime.difference(appointment.startTime));
      appointment.startTime = newStartTime;
      appointment.endTime = newEndTime;
      // appointmentDataSource!
      //     .notifyListeners(CalendarDataSourceAction.reset, [appointment]);

      // appointmentDataSource!.appointments!.clear();
      // appointmentDataSource!.appointments!.addAll(appointments);
      appointmentDataSource!
          .notifyListeners(CalendarDataSourceAction.reset, [appointment]);
    });
  }

  void _onAppointmentResizeEnd(AppointmentResizeEndDetails details) {
    setState(() {
      final Appointment appointment = details.appointment;
      appointment.startTime = details.startTime!;
      appointment.endTime = details.endTime!;
      appointmentDataSource!
          .notifyListeners(CalendarDataSourceAction.reset, [appointment]);
    });
  }

  void showCustomDialog(BuildContext context) {
    final TextEditingController subjectController = TextEditingController(
      text: _selectedAppointment?.subject,
    );
    final TextEditingController startTimeController = TextEditingController(
      text: _selectedAppointment?.startTime.toString(),
    );
    final TextEditingController endTimeController = TextEditingController(
      text: _selectedAppointment?.endTime.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Set Working Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name TextField
              const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  // labelText: 'Name',
                  hintText: 'Add shift name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              // Time Pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: [
                        DropdownMenuItem(
                            value: 'Do not Repeat',
                            child: Text('Do not Repeat')),
                        DropdownMenuItem(
                            value: 'Repeat on weekdays',
                            child: Text('Repeat on weekdays')),
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(
                            value: 'Mon - Sat', child: Text('Mon - Sat')),
                      ],
                      onChanged: (value) {
                        // TODO: Handle repeat option
                      },
                      decoration: InputDecoration(
                        labelText: 'Repeat',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: [
                        DropdownMenuItem(
                            value: 'Do not Repeat',
                            child: Text('Do not Repeat')),
                        DropdownMenuItem(
                            value: 'Repeat on weekdays',
                            child: Text('Repeat on weekdays')),
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(
                            value: 'Mon - Sat', child: Text('Mon - Sat')),
                      ],
                      onChanged: (value) {
                        // TODO: Handle repeat option
                      },
                      decoration: InputDecoration(
                        labelText: 'Repeat',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Repeat Dropdown
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                      value: 'Do not Repeat', child: Text('Do not Repeat')),
                  DropdownMenuItem(
                      value: 'Repeat on weekdays',
                      child: Text('Repeat on weekdays')),
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(
                      value: 'Mon - Sat', child: Text('Mon - Sat')),
                ],
                onChanged: (value) {
                  // TODO: Handle repeat option
                },
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 12),
              ),
            ),
            // Delete Button
            TextButton(
              onPressed: () {
                // TODO: Implement Delete action
              },
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 12),
              ),
            ),
            // Save Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Save action
              },
              child: Text(
                'Save',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog() {
    final TextEditingController subjectController = TextEditingController(
      text: _selectedAppointment?.subject,
    );
    final TextEditingController startTimeController = TextEditingController(
      text: _selectedAppointment?.startTime.toString(),
    );
    final TextEditingController endTimeController = TextEditingController(
      text: _selectedAppointment?.endTime.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Working Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
              ),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(
                      value: 'Do not Repeat', child: Text('Do not Repeat')),
                  DropdownMenuItem(
                      value: 'Repeat on weekdays',
                      child: Text('Repeat on weekdays')),
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(
                      value: 'Mon - Sat', child: Text('Mon - Sat')),
                ],
                onChanged: (value) {
                  // TODO: Handle repeat option
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                style: TextStyle(fontSize: 12),
              ),
              // Add checkboxes for days of the week here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedAppointment != null) {
                    int index = appointments.indexOf(_selectedAppointment!);
                    if (index != -1) {
                      appointments[index].subject = subjectController.text;
                      appointments[index].startTime =
                          DateTime.parse(startTimeController.text);
                      appointments[index].endTime =
                          DateTime.parse(endTimeController.text);

                      // Notify listeners of the updated appointment
                      appointmentDataSource!.notifyListeners(
                        CalendarDataSourceAction.reset,
                        [appointments[index]],
                      );
                    }
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedAppointment != null) {
                    appointments.remove(_selectedAppointment);
                    // appointmentDataSource = AppointmentDataSource(appointments);
                    appointmentDataSource!.notifyListeners(
                      CalendarDataSourceAction.remove,
                      [_selectedAppointment!],
                    );
                    _selectedAppointment = null;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
