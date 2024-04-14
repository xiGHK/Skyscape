import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skyscape/services/storage.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAccount extends StatefulWidget {
  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String _profilePicture = '';
  bool _isUsernameEditable = false;
  bool _isPasswordEditable = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = snapshot.data() as Map<String, dynamic>?;
      _usernameController.text = userData?['username'] ?? '';
      setState(() {
        _profilePicture = userData?['profilePicture'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _uploadProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final downloadURL = await StorageService().uploadProfilePicture(
          currentUser.uid,
          pickedFile.path,
        );
        setState(() {
          _profilePicture = downloadURL;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final newUsername = _usernameController.text.trim();
        final newPassword = _passwordController.text.trim();
        final confirmPassword = _confirmPasswordController.text.trim();

        final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final userData = await userRef.get();
        final oldUsername = userData.data()?['username'] ?? '';

        final updateData = <String, dynamic>{};

        if (newUsername != oldUsername) {
          // Check if the new username already exists in the database
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: newUsername)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Username already exists
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Username already taken')),
            );
            return;
          }
          updateData['username'] = newUsername;
        }

        if (_profilePicture.isNotEmpty) {
          updateData['profilePicture'] = _profilePicture;
        }

        if (newPassword.isNotEmpty) {
          if (newPassword == confirmPassword) {
            await currentUser.updatePassword(newPassword);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Passwords do not match')),
            );
            return;
          }
        }

        if (updateData.isNotEmpty) {
          await userRef.update(updateData);
        }
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar( duration: Duration(seconds: 1), content: Text('Profile Updated')),
        );
        Navigator.pop(context);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(style: GoogleFonts.lobster(fontSize: 30), 'Edit Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber[400],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                              color: Colors.amber[400],
                              borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),),
                height: 285,
                //color: Color.fromARGB(215, 248, 245, 90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _uploadProfilePicture,
                      child: CircleAvatar(
                        radius: 110,
                        backgroundImage: _profilePicture.isNotEmpty
                            ? NetworkImage(_profilePicture)
                            : AssetImage('assets/default_profile.jpg') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(style: GoogleFonts.lobster(fontSize: 20),
                      'edit',
                      
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUsernameField(),
                    SizedBox(height: 20),
                    _buildDivider(),
                    SizedBox(height: 20),
                    _buildPasswordField(),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
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

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'USERNAME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  _isUsernameEditable = !_isUsernameEditable;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 7),
        _isUsernameEditable
            ? TextFormField(
                
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "New Username",
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            : Text(
                _usernameController.text,
                style: TextStyle(fontSize: 18),
              ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PASSWORD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  _isPasswordEditable = !_isPasswordEditable;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 7),

        if (!_isPasswordEditable)
          Text(
            '********',
            style: TextStyle(fontSize: 18),
          ),
        if (_isPasswordEditable)
         
          Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[400],
    );
  }
}