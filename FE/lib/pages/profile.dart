import 'package:farmwise_app/logic/api/accounts.dart';
import 'package:farmwise_app/logic/api/farms.dart';
import 'package:farmwise_app/logic/api/notifications.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  SharedPreferences? prefs;

  Future<void> testFarmAPI() async {
    print('Testing Farm API');
    final farmlist = await getFarms();
    final created = await createFarm(
      location: (-7.78, 110.34),
      name: 'My Farm',
      type: 'Jagung',
      ioID: null,
    );
    final newlist = await getFarms();
    assert(farmlist.response!.length < newlist.response!.length);
    final myf = await updateFarmDetails(
      fID: created.response!.fID,
      name: 'My Farm Updated',
    );
    final lasto = await getFarmDetails(fID: myf.response!.fID);
    assert(lasto.response!.name != created.response!.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with image
            Container(
              color: Colors.green,
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        // Profile Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color:
                                Colors
                                    .white, // Optional: untuk menghindari warna background aneh
                          ),
                          child: ClipOval(
                            child: SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child:
                                    currentUser != null
                                        ? currentUser!.getImageWidget()
                                        : const Icon(
                                          Icons.account_circle,
                                          size: 120,
                                          color: Colors.grey,
                                        ),
                              ),
                            ),
                          ),
                        ),
                        // Camera Icon for edit
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                print('Change profile photo');
                                // Implement photo picker functionality here
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            currentUser!.username,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentUser!.email,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // Profile options
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Pengaturan Akun',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // const SizedBox(height: 15),

                  // Profile Settings
                  // _buildProfileOption(
                  //   icon: Icons.person_outline,
                  //   title: 'Edit Nama',
                  //   subtitle: 'Ganti nama profile Anda',
                  //   onTap: () async {
                  //     currentUser =
                  //         (await updateUser(
                  //           username: '${currentUser!.username}A',
                  //         )).response!;
                  //     print('Username updated');
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder:
                  //             (context) =>
                  //                 const DummyEditScreen(title: 'Edit Nama'),
                  //       ),
                  //     );
                  //   },
                  // ),

                  // _buildProfileOption(
                  //   icon: Icons.lock_outline,
                  //   title: 'Ganti Password',
                  //   subtitle: 'Ubah password akun Anda',
                  //   onTap: () async {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder:
                  //             (context) => const DummyEditScreen(
                  //               title: 'Ganti Password',
                  //             ),
                  //       ),
                  //     );
                  //   },
                  // // ),
                  // const SizedBox(height: 30),
                  const Text(
                    'Farm Setting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildProfileOption(
                    icon: Icons.eco,
                    title: 'Manage Your Farm',
                    subtitle: 'Add or edit your farm',
                    onTap: () {
                      // await testFarmAPI();
                      context.go('/managefarm');
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Application Setting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // _buildProfileOption(
                  //   icon: Icons.settings_accessibility,
                  //   title: 'Aksesibilitas',
                  //   subtitle: 'Atur kemudahan akses pada perangkat',
                  //   onTap: () async {
                  //     // final fID = (await getFarms()).response![0].fID;
                  //     // final curr = await getWeatherCurrent(fID: fID);
                  //     // final fore = await getWeatherForecast(fID: fID);
                  //     // final aler = await getWeatherAlert(fID: fID);
                  //     // if (curr.statusCode == 200 &&
                  //     //     fore.statusCode == 200 &&
                  //     //     aler.statusCode == 200) {
                  //     //   print('SUCCESS');
                  //     // } else {
                  //     //   print('THERE ARE ERRORS');
                  //     //   print(curr.err);
                  //     //   print(fore.err);
                  //     //   print(aler.err);
                  //     // }
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return LocationPicker();
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),

                  // Notification Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notification',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Activate your notification from App',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: notificationsEnabled ?? false,
                          activeColor: Colors.green,
                          onChanged: (value) async {
                            if (prefs == null) {
                              prefs = await SharedPreferences.getInstance();
                            }

                            try {
                              if (!(await requestNotificationPermission())) {
                                print('Notification is not permitted');
                                return;
                              }
                              final token =
                                  await FirebaseMessaging.instance.getToken();
                              if (value == true) {
                                await registerNotification(token: token!);
                                prefs!.setBool('notificationsEnabled', true);
                              } else {
                                await unregisterNotification(token: token!);
                                prefs!.setBool('notificationsEnabled', false);
                              }
                            } catch (err) {
                              print('Server Down');
                            }
                            // final all = await getNotifications();
                            // final unread = await getNotifications(
                            //   unreadOnly: true,
                            // );
                            // assert(
                            //   unread.response!.length < all.response!.length,
                            // );
                            // final first = await getNotificationsDetail(
                            //   nID: all.response![0].nID,
                            // );
                            // await readNotifications(
                            //   nIDs: [
                            //     all.response![2].nID,
                            //     all.response![0].nID,
                            //   ],
                            // );
                            // final firstRead = await getNotificationsDetail(
                            //   nID: all.response![0].nID,
                            // );
                            // assert(
                            //   first.response!.lastRead == null &&
                            //       firstRead.response!.lastRead != null,
                            // );

                            setState(() {
                              notificationsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        context.go('/splashscreen');
                        await signOut();
                        print('Signed out');
                        // Implement logout functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    iconColor != null
                        ? iconColor.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? Colors.green, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

// Dummy screen for demonstration purposes
class DummyEditScreen extends StatelessWidget {
  final String title;

  const DummyEditScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Halaman $title')),
    );
  }
}
