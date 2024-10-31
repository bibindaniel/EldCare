import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/widgets/medicine_card.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/medicine_deatils.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // _buildHeader(),
          _buildCalendar(),
          _buildTabBar(),
          const SizedBox(
            height: 12,
          ),
          // _buildSearchBar(),
          _buildScheduleList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medicine Schedule', style: AppFonts.headline2),
          SizedBox(height: 10),
          Text('Manage your medications and appointments',
              style: AppFonts.cardSubtitle),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _tabController.index = 0; // Switch to the "Ongoing" tab
        });
        context.read<MedicineBloc>().add(FetchMedicinesForDate(selectedDay));
      },
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: kSecondaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: kPrimaryColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: kSecondaryColor,
        labelColor: kWhiteColor,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Ongoing'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
        ],
        onTap: (index) {
          if (index == 0) {
            context
                .read<MedicineBloc>()
                .add(FetchMedicinesForDate(_selectedDate));
          } else if (index == 1) {
            context.read<MedicineBloc>().add(FetchUpcomingMedicines());
          } else if (index == 2) {
            context.read<MedicineBloc>().add(FetchCompletedMedicines());
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by date (YYYY-MM-DD)',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onSubmitted: (value) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(value);
            setState(() {
              _selectedDate = date;
            });
            context.read<MedicineBloc>().add(FetchMedicinesForDate(date));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Invalid date format. Please use YYYY-MM-DD.')),
            );
          }
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOngoingMedicineList(),
          _buildUpcomingMedicineList(),
          _buildCompletedMedicineList(),
        ],
      ),
    );
  }

  Widget _buildOngoingMedicineList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        if (state is MedicineInitial) {
          context
              .read<MedicineBloc>()
              .add(FetchMedicinesForDate(_selectedDate));
          return const Center(child: CircularProgressIndicator());
        } else if (state is MedicineLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MedicinesLoaded) {
          if (state.medicines.isEmpty) {
            return Center(
                child: Text(
                    'No medicines scheduled for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'));
          }
          return ListView.builder(
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicineDetailPage(medicine: medicine),
                    ),
                  );
                },
                child: MedicineCard(medicine: medicine),
              );
            },
          );
        } else if (state is MedicineError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('Unknown state'));
        }
      },
    );
  }

  Widget _buildUpcomingMedicineList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        if (state is MedicineLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UpcomingMedicinesLoaded) {
          if (state.medicines.isEmpty) {
            return const Center(child: Text('No upcoming medicines'));
          }
          return ListView.builder(
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              return MedicineCard(medicine: medicine);
            },
          );
        } else if (state is MedicineError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          context.read<MedicineBloc>().add(FetchUpcomingMedicines());
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildCompletedMedicineList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        if (state is MedicineLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CompletedMedicinesLoaded) {
          if (state.medicines.isEmpty) {
            return const Center(child: Text('No completed medicines'));
          }
          return ListView.builder(
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              return MedicineCard(medicine: medicine);
            },
          );
        } else if (state is MedicineError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          context.read<MedicineBloc>().add(FetchCompletedMedicines());
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
