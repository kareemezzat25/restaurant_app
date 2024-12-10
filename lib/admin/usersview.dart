import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Usersview extends StatefulWidget {
  const Usersview({Key? key}) : super(key: key);

  @override
  State<Usersview> createState() => _UsersviewState();
}

class _UsersviewState extends State<Usersview> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('role', 'user')
          .order('username');

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        filteredUsers = users;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterUsers(String? username, String? email, String? gender) {
    setState(() {
      filteredUsers = users.where((user) {
        final matchUsername = username == null ||
                user['username']
                    ?.toLowerCase()
                    .contains(username.toLowerCase()) ??
            false;
        final matchEmail = email == null ||
                user['email']?.toLowerCase().contains(email.toLowerCase()) ??
            false;
        final matchGender = gender == null ||
            user['gender']?.toLowerCase() == gender.toLowerCase();
        return matchUsername && matchEmail && matchGender;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      filteredUsers = users;
    });
  }

  void showFilterSheet() {
    String? username;
    String? email;
    String? gender;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => username = value.trim(),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => email = value.trim(),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text("Male")),
                  DropdownMenuItem(value: 'Female', child: Text("Female")),
                ],
                onChanged: (value) => gender = value,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text("Reset",
                        style: TextStyle(color: Color(0xff2C9CEE))),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2C9CEE)),
                    onPressed: () {
                      filterUsers(username, email, gender);
                      Navigator.pop(context);
                    },
                    child: const Text("Apply",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        resetFilters();
        return false; // Prevents app exit
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Users',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
                size: 28,
              ),
              onPressed: showFilterSheet,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/nouserfound.jpg",
                          width: MediaQuery.of(context).size.width / 2,
                          height: 150,
                        ),
                        Text(
                          ' No users found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        color: const Color.fromARGB(255, 217, 233, 242),
                        elevation: 10,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: user['imageurl'] != null &&
                                        user['imageurl'].isNotEmpty
                                    ? NetworkImage(user['imageurl'])
                                    : const AssetImage('images/anonymous.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['username'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user['email'] ?? 'No email provided',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${user['gender'] ?? 'N/A'}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${user['phonenumber'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
