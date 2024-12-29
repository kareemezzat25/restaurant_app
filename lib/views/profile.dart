import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:resturant_app/views/editprofile.dart';
import 'package:resturant_app/views/forgetPassword.dart';
import 'package:resturant_app/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('email', user.email!)
            .limit(1)
            .single();
        setState(() {
          userData = response;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchUserData();
  }

  Future<void> logout() async {
    bool? exitConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Are you sure?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Do you want to log out?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (exitConfirmed == true) {
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff2C9CEE),
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (userData?['imageurl'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  showZoomedAvatar(userData!['imageurl']),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: userData?['imageurl'] != null
                            ? NetworkImage(userData!['imageurl'])
                            : const AssetImage('images/anonymous.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData?['username'] ?? 'No Username',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2C9CEE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData?['email'] ?? 'No Email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2C9CEE),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileView(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.person,
          label: 'Username',
          value: userData?['username'] ?? 'No Username',
        ),
        _buildInfoCard(
          icon: Icons.email,
          label: 'Email',
          value: userData?['email'] ?? 'No Email',
        ),
        if (userData?['role'] == 'user') ...[
          _buildInfoCard(
            icon: Icons.badge,
            label: 'User ID',
            value: userData?['user_id'] ?? 'No ID',
          ),
          _buildInfoCard(
            icon: Icons.phone,
            label: 'Phone Number',
            value: userData?['phonenumber'] ?? 'No Phone Number',
          ),
          _buildInfoCard(
            icon: Icons.cake,
            label: 'Date of Birth',
            value: userData?['datebirthday'] ?? 'No Birthdate',
          ),
        ],
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPassword(message: false),
              ),
            );
          },
          child: _buildInfoCard(
            icon: Icons.lock_reset,
            label: 'Reset Password',
            value: 'Change your password',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xff2C9CEE).withOpacity(0.1),
          ),
          child: Icon(icon, color: const Color(0xff2C9CEE)),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget showZoomedAvatar(String imageUrl) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey),
      body: PhotoView(imageProvider: NetworkImage(imageUrl)),
    );
  }
}
