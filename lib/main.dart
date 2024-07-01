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
  String _selectedRecurrence = 'Once a week';

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
                          allowDragAndDrop: true,
                          allowAppointmentResize: true,
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

    _selectedRecurrence = 'Once a week'; // Default value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  DropdownButton<String>(
                    value: _selectedRecurrence,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRecurrence = newValue!;
                      });
                    },
                    items: <String>[
                      'Once a week',
                      'Repeat on weekdays',
                      'Mon to Sat',
                      'Everyday'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
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
                    _saveAppointment(
                      subjectController.text,
                      DateTime.parse(startTimeController.text),
                      DateTime.parse(endTimeController.text),
                      _selectedRecurrence,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    _deleteAppointment();
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveAppointment(
      String subject, DateTime startTime, DateTime endTime, String recurrence) {
    setState(() {
      if (_selectedAppointment != null) {
        appointments.remove(_selectedAppointment);
      }

      String recurrenceRule;
      switch (recurrence) {
        case 'Once a week':
          recurrenceRule = 'FREQ=WEEKLY;COUNT=1';
          break;
        case 'Repeat on weekdays':
          recurrenceRule = 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR';
          break;
        case 'Mon to Sat':
          recurrenceRule = 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA';
          break;
        case 'Everyday':
          recurrenceRule = 'FREQ=DAILY';
          break;
        default:
          recurrenceRule = 'FREQ=WEEKLY;COUNT=1';
      }

      Appointment newAppointment = Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        color: Colors.blue,
        recurrenceRule: recurrenceRule,
      );

      appointments.add(newAppointment);
      appointmentDataSource!
          .notifyListeners(CalendarDataSourceAction.reset, appointments);
    });
  }

  void _deleteAppointment() {
    setState(() {
      if (_selectedAppointment != null) {
        appointments.remove(_selectedAppointment);
        appointmentDataSource!.notifyListeners(
          CalendarDataSourceAction.remove,
          [_selectedAppointment!],
        );
        _selectedAppointment = null;
      }
    });
  }
}
