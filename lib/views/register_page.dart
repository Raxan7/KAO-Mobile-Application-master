import 'package:flutter/material.dart';
import '../services/api_service.dart'; // For interacting with the API
import 'login_page.dart'; // For redirecting to login page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ApiService apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  bool isLoading = false;

  // Role selection
  String _selectedRole = 'user'; // Default role

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Prepare user data
      final result = await apiService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        phonenum: _phoneController.text,
        address: _addressController.text,
        pincode: _pincodeController.text,
        dob: _dobController.text,
        pass: _passwordController.text,
        cpass: _cpasswordController.text,
        role: _selectedRole, // Pass the selected role to the API
      );

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );

        _formKey.currentState!.reset(); // Reset the form fields

        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                validator: (value) => value!.isEmpty ? 'Please enter your pincode' : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2101),
                  );
                  _dobController.text = pickedDate.toString().split(' ')[0];
                                },
                validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
              ),
              const SizedBox(height: 20),
              // Role dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Select Role'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'dalali', child: Text('Dalali')),
                  DropdownMenuItem(value: 'hotelier', child: Text('Hotelier')),
                  DropdownMenuItem(value: 'worker', child: Text('Worker')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
              ),
              TextFormField(
                controller: _cpasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerUser,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
