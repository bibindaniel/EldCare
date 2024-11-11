import 'package:flutter/material.dart';
import 'package:eldcare/admin/repository/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Elderly Users'),
              Tab(text: 'Pharmacists'),
              Tab(text: 'Delivery Guys'),
              Tab(text: 'Blocked Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UserListView(userType: 'elderly'),
            _UserListView(userType: 'pharmacist'),
            _UserListView(userType: 'delivery'),
            _BlockedUsersListView(),
          ],
        ),
      ),
    );
  }
}

class _UserListView extends StatelessWidget {
  final String userType;
  final UserRepository _repository = UserRepository();

  _UserListView({required this.userType});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsersByType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(
              user: user,
              userType: userType,
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _getUsersByType() {
    switch (userType) {
      case 'elderly':
        return _repository.getElderlyUsers();
      case 'pharmacist':
        return _repository.getPharmacists();
      case 'delivery':
        return _repository.getDeliveryGuys();
      default:
        throw Exception('Invalid user type');
    }
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final String userType;

  const _UserCard({required this.user, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => _showUserDetailsDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildUserAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (user.isVerified)
                          const Icon(Icons.verified,
                              color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'No email',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          user.phone ?? 'No phone',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[200],
      child: user.profileImageUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.profileImageUrl!,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            )
          : const Icon(Icons.person, size: 40),
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    _buildUserAvatar(),
                    const SizedBox(height: 16),
                    Text(
                      user.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Verified User',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailItem('Email', user.email, Icons.email),
                    _buildDetailItem('Phone', user.phone, Icons.phone),
                    _buildDetailItem(
                        'Age', user.age?.toString(), Icons.calendar_today),
                    if (userType == 'elderly') ...[
                      _buildDetailItem(
                          'Blood Type', user.bloodType, Icons.bloodtype),
                    ] else if (userType == 'pharmacist') ...[
                      // _buildDetailItem(
                      //     'License Number', user.licenseNumber, Icons.badge),
                    ],
                    const Divider(),
                    _buildDetailItem(
                        'House', user.houseName, Icons.house_outlined),
                    _buildDetailItem('Street', user.street, Icons.route),
                    _buildDetailItem('City', user.city, Icons.location_city),
                    _buildDetailItem('State', user.state, Icons.map),
                    _buildDetailItem('Postal Code', user.postalCode,
                        Icons.local_post_office),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (userType != 'blocked')
                      ElevatedButton.icon(
                        onPressed: () {
                          _showBlockDialog(context, user);
                        },
                        icon: const Icon(Icons.block),
                        label: const Text('Block User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    if (userType == 'blocked')
                      ElevatedButton.icon(
                        onPressed: () {
                          _unblockUser(context, user.id);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Unblock User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value ?? 'Not provided',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController reasonController = TextEditingController();
        return AlertDialog(
          title: const Text('Block User'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Reason for blocking'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _blockUser(context, user, reasonController.text);
              },
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
  }

  void _blockUser(BuildContext context, dynamic user, String reason) async {
    try {
      // Update user status in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'isBlocked': true, 'blockReason': reason});

      // Send email to user with the reason
      await _sendBlockEmail(user.email, reason);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully')),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error blocking user: $e')),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _sendBlockEmail(String email, String reason) async {
    final String emailUsername = dotenv.env['EMAIL_USERNAME'] ?? '';
    final String emailPassword = dotenv.env['EMAIL_PASSWORD'] ?? '';

    if (emailUsername.isEmpty || emailPassword.isEmpty) {
      print('Email credentials are not set. Please check your .env file.');
      return;
    }

    final smtpServer = gmail(emailUsername, emailPassword);

    final message = Message()
      ..from = Address(emailUsername, 'EldCare Admin')
      ..recipients.add(email)
      ..subject = 'Account Blocked'
      ..text =
          'Your account has been blocked for the following reason: $reason';

    try {
      final sendReport = await send(message, smtpServer);
      print('Block email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Error sending block email: ${e.toString()}');
    }
  }

  void _unblockUser(BuildContext context, String userId) async {
    try {
      // Update user status in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isBlocked': false, 'blockReason': FieldValue.delete()});

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked successfully')),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unblocking user: $e')),
      );
    }
  }
}

class _BlockedUsersListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isBlocked', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final blockedUsers = snapshot.data!.docs;

        if (blockedUsers.isEmpty) {
          return const Center(child: Text('No blocked users'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: blockedUsers.length,
          itemBuilder: (context, index) {
            final userData = blockedUsers[index].data() as Map<String, dynamic>;
            return _BlockedUserCard(
              userId: blockedUsers[index].id,
              userData: userData,
            );
          },
        );
      },
    );
  }
}

class _BlockedUserCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const _BlockedUserCard({
    required this.userId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  child: userData['profileImageUrl'] != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userData['profileImageUrl'],
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          ),
                        )
                      : const Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData['email'] ?? 'No email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Block Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['blockReason'] ?? 'No reason provided',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _unblockUser(context),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unblock User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _unblockUser(BuildContext context) async {
    try {
      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Unblock'),
          content: const Text('Are you sure you want to unblock this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unblock'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Update user status in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isBlocked': false,
        'blockReason': FieldValue.delete(),
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error unblocking user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
