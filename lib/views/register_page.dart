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
        pincode: '0', // Default value for pincode
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
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final padding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
        : const EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: isDesktop,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            child: Padding(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                      isDesktop: isDesktop,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                      isDesktop: isDesktop,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                      isDesktop: isDesktop,
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
                      isDesktop: isDesktop,
                    ),
                    _buildDateField(isDesktop),
                    const SizedBox(height: 20),
                    _buildRoleDropdown(isDesktop),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                      isDesktop: isDesktop,
                    ),
                    _buildTextField(
                      controller: _cpasswordController,
                      label: 'Confirm Password',
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please confirm your password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _registerUser,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 16 : 12,
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    bool obscureText = false,
    required bool isDesktop,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
        ),
        style: TextStyle(fontSize: isDesktop ? 16 : 14),
        validator: validator,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildDateField(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dobController,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
        ),
        style: TextStyle(fontSize: isDesktop ? 16 : 14),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            _dobController.text = pickedDate.toString().split(' ')[0];
          }
        },
        validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
      ),
    );
  }

  Widget _buildRoleDropdown(bool isDesktop) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Select Role',
        labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
      ),
      style: TextStyle(fontSize: isDesktop ? 16 : 14),
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
    );
  }
}
