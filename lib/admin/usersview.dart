import 'package:flutter/material.dart';
import 'package:resturant_app/views/history.dart';
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

  void filterUsers(
      {String? username, String? email, String? gender, String? userId}) {
    setState(() {
      filteredUsers = users.where((user) {
        final matchUsername = username == null ||
            (user['username']?.toLowerCase() ?? '')
                .contains(username.toLowerCase());
        final matchEmail = email == null ||
            (user['email']?.toLowerCase() ?? '').contains(email.toLowerCase());
        final matchGender = gender == null ||
            (user['gender']?.toLowerCase() ?? '') == gender.toLowerCase();
        final matchUserId = userId == null ||
            (user['user_id']?.toString() ?? '').contains(userId);
        return matchUsername && matchEmail && matchGender && matchUserId;
      }).toList();
    });
  }

  void showAddMoneyDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Money for ${user['username'] ?? 'User'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text('Do you want to add money to this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showEnterAmountDialog(user);
              },
              child: const Text('Add Money'),
            ),
          ],
        );
      },
    );
  }

  void showEnterAmountDialog(Map<String, dynamic> user) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enter Amount for ${user['username'] ?? 'User'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount != null && amount > 0) {
                  try {
                    final currentWallet = user['wallet'] ?? 0.0;

                    final updatedWallet = currentWallet + amount;
                    print("updatedWallet:$updatedWallet");

                    await supabase.from('users').update(
                        {'wallet': updatedWallet}).eq('email', user['email']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Successfully added $amount to ${user['username']}\'s wallet.'),
                      ),
                    );

                    setState(() {
                      user['wallet'] = updatedWallet;
                    });
                  } catch (error) {
                    print('Error updating wallet: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Failed to update wallet. Please try again.'),
                      ),
                    );
                  }
                } else {
                  // Show an error if the amount is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid amount')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showFilterSheet() {
    String? userId;
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
                  labelText: "User ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  userId = value.trim();
                  filterUsers(
                      username: username,
                      email: email,
                      gender: gender,
                      userId: userId);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  username = value.trim();
                  filterUsers(
                      username: username,
                      email: email,
                      gender: gender,
                      userId: userId);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  email = value.trim();
                  filterUsers(
                      username: username,
                      email: email,
                      gender: gender,
                      userId: userId);
                },
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
                onChanged: (value) {
                  gender = value;
                  filterUsers(
                      username: username,
                      email: email,
                      gender: gender,
                      userId: userId);
                },
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
        setState(() {
          fetchUsers();
        });
        return false; // Allows going back
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
                        const Text(
                          'No users found',
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
                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return History(
                            userEmail: user['email'],
                          );
                        })),
                        child: Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          'User ID: ${user['user_id'] ?? 'None'}'),
                                      const SizedBox(height: 4),
                                      Text(
                                          'Gender: ${user['gender'] ?? 'None'}'),
                                    ],
                                  ),
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
}
