import 'package:flutter/material.dart';
import '../widgets/buttons/common_button.dart';
import '../widgets/common_textfield_view.dart';
import '../utils/validators.dart';
import '../services/api_service.dart'; // Import the ApiService
// Import the registration page
import '../services/user_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_page.dart'; // Import Google Sign-In package

class LoginPage extends StatefulWidget {
  final String? redirectPage; // Parameter for redirecting to a specific page

  const LoginPage({super.key, this.redirectPage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _errorEmail;
  final TextEditingController _emailController = TextEditingController();
  String? _errorPassword;
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  // Instance of GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final padding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
        : const EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Login'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop) const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/images/splash_icon.png',
                      width: isDesktop ? 150 : 100,
                      height: isDesktop ? 150 : 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Login with email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  CommonTextFieldView(
                    controller: _emailController,
                    errorText: _errorEmail,
                    titleText: 'Your Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    isDesktop: isDesktop,
                    onChanged: (String txt) {
                      setState(() => _errorEmail = null);
                    },
                  ),
                  CommonTextFieldView(
                    controller: _passwordController,
                    errorText: _errorPassword,
                    titleText: 'Password',
                    hintText: 'Enter your password',
                    isObscureText: true,
                    isDesktop: isDesktop,
                    onChanged: (String txt) {
                      setState(() => _errorPassword = null);
                    },
                  ),
                  _forgotPasswordUI(isDesktop),
                  CommonButton(
                    buttonText: 'Login',
                    isDesktop: isDesktop,
                    onTap: () async {
                      if (_validateInputs()) {
                        try {
                          final response = await apiService.loginUser(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (response['success']) {
                            await _handleLoginSuccess(response);
                          } else {
                            setState(() {
                              _errorPassword = response['message'];
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _errorPassword = 'An error occurred. Please try again.';
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Register here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14,
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
    );
  }

  Widget _forgotPasswordUI(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            // Navigate to Forgot Password screen
          },
          child: Text(
            'Forgot your password?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Retrieve user details from Google Account
        String displayName = googleUser.displayName ?? 'User';
        String email = googleUser.email;
        String googleId = googleUser.id;
        String profilePic = googleUser.photoUrl ?? '';

        // Send the data to your backend for login/registration
        final response = await apiService.loginWithGoogle(email, googleId, displayName, profilePic);
        if (response['success']) {
          await _handleLoginSuccess(response);
        } else {
          setState(() {
            _errorPassword = response['message'];
          });
        }
      }
    } catch (error) {
      // print('Google sign-in failed: $error');
      setState(() {
        _errorPassword = 'Google sign-in failed. Please try again.';
      });
    }
  }


  Future<void> _handleLoginSuccess(Map<String, dynamic> response) async {
    String token = response['token'] ?? '';
    String name = response['name'] ?? 'User';
    String email = _emailController.text.trim();
    String role = response['role'] ?? 'user';
    String userId = (response['userId'] ?? '').toString();
    String phonenum = response['phonenum'] ?? '';
    String address = response['address'] ?? '';

    await UserPreferences().saveUserDetails(
      token: token,
      name: name,
      email: email,
      role: role,
      userId: userId,
      phonenum: phonenum,
      address: address,
    );

    // Save user session for switching
    await UserPreferences().saveUserSession(userId, name, email, token, role);

    // Navigate based on role
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else if (role == 'hotelier') {
      Navigator.pushReplacementNamed(context, '/hotelierDashboard');
    } else if (role == 'worker') {
      Navigator.pushReplacementNamed(context, '/workerDashboard');
    } else if (role == 'dalali') {
      Navigator.pushReplacementNamed(context, '/dalaliDashboard');
    } else if (role == 'user') {
      Navigator.pushReplacementNamed(context, '/propertyListScreen');
    }
  }


  bool _validateInputs() {
    bool isValid = true;

    final emailError = Validators.validateEmail(_emailController.text.trim());
    if (emailError != null) {
      _errorEmail = emailError;
      isValid = false;
    } else {
      _errorEmail = null;
    }

    final passwordError = Validators.validatePassword(_passwordController.text.trim());
    if (passwordError != null) {
      _errorPassword = passwordError;
      isValid = false;
    } else {
      _errorPassword = null;
    }

    setState(() {});
    return isValid;
  }
}
