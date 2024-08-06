// import 'package:eldcare/pharmacy/blocs/bloc/pharmacist_profile_bloc.dart';
// import 'package:eldcare/pharmacy/model/pharmacist.dart';
// import 'package:eldcare/pharmacy/presentation/profile/profilecompletionpage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class PharmacistProfilePage extends StatelessWidget {
//   const PharmacistProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pharmacist Profile')),
//       body: BlocConsumer<PharmacistProfileBloc, PharmacistProfileState>(
//         listener: (context, state) {
//           if (state is PharmacistProfileError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is PharmacistProfileLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is PharmacistProfileLoaded) {
//             final profile = state.profile;
//             return _buildProfileContent(profile, context);
//           } else {
//             return const Center(child: Text('Failed to load profile'));
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildProfileContent(PharmacistProfile profile, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Age: ${profile.age ?? 'N/A'}', style: _profileTextStyle),
//           Text('Phone: ${profile.phone ?? 'N/A'}', style: _profileTextStyle),
//           Text('House Name: ${profile.houseName ?? 'N/A'}',
//               style: _profileTextStyle),
//           Text('Street: ${profile.street ?? 'N/A'}', style: _profileTextStyle),
//           Text('City: ${profile.city ?? 'N/A'}', style: _profileTextStyle),
//           Text('State: ${profile.state ?? 'N/A'}', style: _profileTextStyle),
//           Text('Postal Code: ${profile.postalCode ?? 'N/A'}',
//               style: _profileTextStyle),
//           Text('License Number: ${profile.licenseNumber ?? 'N/A'}',
//               style: _profileTextStyle),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const PharmacistProfileCompletionPage(),
//                 ),
//               );
//             },
//             child: const Text('Edit Profile'),
//           ),
//         ],
//       ),
//     );
//   }

//   TextStyle get _profileTextStyle => const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       );
// }
