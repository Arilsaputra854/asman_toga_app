import 'package:asman_toga/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ProfileViewModel>().loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return SafeArea(
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 30),

                // Avatar + Nama
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vm.user?.name ?? "Unknown User",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        vm.user?.email ?? "No email",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // List Menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                              title: const Text("Edit Profile"),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                // TODO: Navigasi ke edit profile
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.lock,
                                color: Colors.green,
                              ),
                              title: const Text("Change Password"),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                // TODO: Navigasi ke ubah password
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.settings,
                                color: Colors.green,
                              ),
                              title: const Text("Settings"),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {},
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text("Logout"),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () => vm.logout(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
