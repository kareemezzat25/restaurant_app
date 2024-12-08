import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:resturant_app/admin/admin_login.dart';
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
  final ImagePicker _picker = ImagePicker();
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
        print('No authenticated user found.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget showZoomedAvatar(String imageUrl) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SizedBox(
            height: 400,
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  void logout() async {
    await supabase.auth.signOut();
    if (userData?['role'] == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLogin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true; // Show loading while fetching
    });
    await fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (userData?['imageurl'] != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => showZoomedAvatar(
                                        userData?['imageurl'])));
                          }
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: userData?['imageurl'] != null
                              ? NetworkImage(userData!['imageurl'])
                              : const AssetImage('images/anonymous.png')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        userData?['username'] ?? 'No Username',
                        style: const TextStyle(
                          color: Color(0xff2C9CEE),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        userData?['email'] ?? 'No Email',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Username in Card with icon
                    cardrepeat(Icon(Icons.person),
                        userData?['username'] ?? 'No Username'),
                    const SizedBox(height: 8),
                    // Email in Card with icon
                    cardrepeat(
                        Icon(Icons.email), (userData?['email'] ?? 'No Email')),
                    const SizedBox(height: 8),

                    if (userData?['role'] == "user") ...[
                      cardrepeat(Icon(Icons.phone),
                          userData?['phonenumber'] ?? 'No Phone number'),
                      const SizedBox(height: 8),
                      cardrepeat(Icon(Icons.cake),
                          userData?['datebirthday'] ?? 'No Birthdate'),
                      const SizedBox(height: 8),
                    ],
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword(
                                        message: false,
                                      )));
                        },
                        child: cardrepeat(
                            Icon(Icons.lock_reset), "Reset Password")),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2C9CEE)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfileView()),
                          );
                        },
                        child: const Text('Edit Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

Widget cardrepeat(Icon icon, String message) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: icon,
      title: Text(message),
    ),
  );
}
