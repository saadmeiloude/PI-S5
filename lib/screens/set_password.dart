import 'package:flutter/material.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final Color _primaryColor = const Color(0xFF00BFFF); // Bright blue color
  double _passwordStrength =
      0.5; // Placeholder for password strength (0.0 to 1.0)

  // Custom InputDecoration for the text fields to match the image style
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: Colors.grey.shade100, // Light grey background for the field
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18.0,
        horizontal: 15.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none, // No border line
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: _primaryColor,
          width: 1.5,
        ), // Highlight on focus
      ),
    );
  }

  // Function to simulate password strength calculation (for demonstration)
  void _checkPasswordStrength(String password) {
    // Simple logic: longer password = stronger
    double strength = password.length / 10.0;
    if (strength > 1.0) strength = 1.0;
    setState(() {
      _passwordStrength = strength;
    });
  }

  // Custom text field widget
  Widget _buildPasswordField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        textAlign: TextAlign.right, // Align text to the right for RTL
        obscureText: true,
        decoration: _inputDecoration(label),
        onChanged: (value) {
          if (label == 'كلمة المرور الجديدة') {
            _checkPasswordStrength(value);
          }
        },
      ),
    );
  }

  // Widget for the password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    Color strengthColor;
    if (_passwordStrength < 0.3) {
      strengthColor = Colors.red;
    } else if (_passwordStrength < 0.7) {
      strengthColor = Colors.orange;
    } else {
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قوة كلمة المرور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set the entire screen to RTL
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'تعيين كلمة المرور',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // New Password Field
                    _buildPasswordField('كلمة المرور الجديدة'),
                    const SizedBox(height: 5),

                    // Confirm New Password Field
                    _buildPasswordField('تأكيد كلمة المرور الجديدة'),
                    const SizedBox(height: 20),

                    // Password Strength Indicator
                    _buildPasswordStrengthIndicator(),
                  ],
                ),
              ),
            ),

            // Save Button (Fixed at the bottom)
            Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 30.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/password_changed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use this screen in main.dart
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Set Password Screen',
      debugShowCheckedModeBanner: false,
      home: SetPasswordScreen(),
    );
  }
}
*/
