import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/form_validators.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final Color _primaryColor = const Color(0xFF00BFFF); // Bright blue color

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Custom InputDecoration for the text fields to match the image style
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
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
      suffixIcon: suffixIcon,
    );
  }

  // Custom text field widget
  Widget _buildTextField(
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right, // Align text to the right for RTL
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: validator,
        decoration: _inputDecoration(label, suffixIcon: suffixIcon),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Parse birth date
      DateTime? birthDate;
      if (_birthDateController.text.isNotEmpty) {
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          birthDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      final success = await userProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        birthDate: birthDate,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح! تحقق من بريدك الإلكتروني.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to check email screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamed(context, '/verification');
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إنشاء الحساب. حاول مرة أخرى.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop(); // Close the screen
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title
                const Center(
                  child: Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          'الاسم الكامل',
                          controller: _nameController,
                          validator: FormValidators.name,
                        ),
                        _buildTextField(
                          'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: FormValidators.email,
                        ),
                        _buildTextField(
                          'كلمة المرور',
                          isPassword: true,
                          controller: _passwordController,
                          validator: FormValidators.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        _buildTextField(
                          'رقم الهاتف',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          validator: FormValidators.phone,
                        ),
                        _buildTextField(
                          'تاريخ الميلاد',
                          keyboardType: TextInputType.datetime,
                          controller: _birthDateController,
                          validator: (value) => null, // Optional field
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Terms and Conditions Checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Align to the right for RTL
                          children: [
                            // Text is on the right side of the checkbox in RTL
                            const Text(
                              'أوافق على الشروط والأحكام',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _agreedToTerms = newValue ?? false;
                                  });
                                },
                                activeColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Register Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'تسجيل',
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
      title: 'Create Account Screen',
      debugShowCheckedModeBanner: false,
      home: CreateAccountScreen(),
    );
  }
}
*/
