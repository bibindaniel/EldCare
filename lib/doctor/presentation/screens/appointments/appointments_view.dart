import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Text('Appointments', style: AppFonts.headline2),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCalendar(),
                _buildAppointmentStats(),
                _buildAppointmentsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Appointment'),
      ),
    );
  }

  Widget _buildCalendar() {
    try {
      return Card(
        margin: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            if (mounted) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            if (mounted) {
              setState(() {
                _focusedDay = focusedDay;
              });
            }
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: kSecondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building calendar: $e');
      return const Card(
        margin: EdgeInsets.all(8),
        child: Center(
          child: Text('Unable to load calendar'),
        ),
      );
    }
  }

  Widget _buildAppointmentStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Today', '8', 'Appointments'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Pending', '3', 'Requests'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: AppFonts.bodyText2),
            Text(count,
                style: AppFonts.headline3.copyWith(color: kPrimaryColor)),
            Text(subtitle, style: AppFonts.bodyText2),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('Patient ${index + 1}'),
            subtitle: Text('10:0${index} AM - Consultation'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
          ),
        );
      },
    );
  }
}
