import 'package:eldcare/auth/presentation/widgets/medicine_card.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:intl/intl.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_bloc.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_event.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_state.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is RoleSelectionNeeded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    RoleSelectionScreen(userId: state.user.uid),
              ),
            );
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, navigationState) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: kPrimaryColor,
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 15,
                  ),
                ),
                title: const Text(
                  'Hey, John',
                  style: AppFonts.headline3,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active,
                      color: kWhiteColor,
                    ),
                    onPressed: () {
                      // Add notification action here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: _getSelectedScreen(navigationState.currentItem),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddMedicinePage()));
                },
                backgroundColor: kSecondaryColor,
                child: const Icon(Icons.add),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 10,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MaterialButton(
                            minWidth: 40,
                            onPressed: () {
                              context
                                  .read<NavigationBloc>()
                                  .add(NavigateToHome());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home,
                                  color: navigationState.currentItem ==
                                          NavigationItem.home
                                      ? kPrimaryColor
                                      : Colors.grey,
                                ),
                                Text('Home'),
                              ],
                            ),
                          ),
                          MaterialButton(
                            minWidth: 40,
                            onPressed: () {
                              context
                                  .read<NavigationBloc>()
                                  .add(NavigateToSchedule());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: navigationState.currentItem ==
                                          NavigationItem.schedule
                                      ? kPrimaryColor
                                      : Colors.grey,
                                ),
                                Text('Schedule'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MaterialButton(
                            minWidth: 40,
                            onPressed: () {
                              context
                                  .read<NavigationBloc>()
                                  .add(NavigateToAppointment());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: navigationState.currentItem ==
                                          NavigationItem.appointment
                                      ? kPrimaryColor
                                      : Colors.grey,
                                ),
                                Text('Appointment'),
                              ],
                            ),
                          ),
                          MaterialButton(
                            minWidth: 40,
                            onPressed: () {
                              context
                                  .read<NavigationBloc>()
                                  .add(NavigateToProfile());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: navigationState.currentItem ==
                                          NavigationItem.profile
                                      ? kPrimaryColor
                                      : Colors.grey,
                                ),
                                Text('Profile'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getSelectedScreen(NavigationItem item) {
    switch (item) {
      case NavigationItem.home:
        return _buildHomeContent();
      case NavigationItem.schedule:
        return Center(child: Text('Schedule Screen'));
      case NavigationItem.appointment:
        return Center(child: Text('Appointment Screen'));

      case NavigationItem.profile:
        return Center(child: Text('Profile Screen'));
    }
  }

  Widget _buildHomeContent() {
    return Container(
      color: kPrimaryColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Create a New Schedule',
                    style: AppFonts.headline3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      backgroundColor: kWhiteColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Add your button action here
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              Lottie.asset(
                'assets/animations/medical.json',
                width: 100,
                height: 100,
              )
            ],
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: index == 0 ? kPrimaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: index == 0 ? kWhiteColor : kBlackColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                color: index == 0 ? kWhiteColor : kBlackColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "To Take",
                  style: AppFonts.headline3Dark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: MedicineCard(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Upcoming Events",
                  style: AppFonts.headline3Dark,
                ),
                const SizedBox(height: 10),
                const Card(
                  color: kPrimaryColor,
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.medical_services,
                              size: 36, color: kThridColor),
                          title: Text('Dr. Smith Appointment',
                              style:
                                  TextStyle(fontSize: 18, color: kWhiteColor)),
                          subtitle: Text('July 16, 10:00 AM',
                              style:
                                  TextStyle(fontSize: 16, color: kWhiteColor)),
                        ),
                        ListTile(
                          leading: Icon(Icons.local_shipping,
                              size: 36, color: kSecondaryColor),
                          title: Text('Medication Delivery',
                              style:
                                  TextStyle(fontSize: 18, color: kWhiteColor)),
                          subtitle: Text('July 15, 2:00 PM',
                              style:
                                  TextStyle(fontSize: 16, color: kWhiteColor)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
