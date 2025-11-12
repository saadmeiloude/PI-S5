import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class FormValidators {
  // Generic required field validator
  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!EmailValidator.validate(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // Phone number validation (Mauritania format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // Mauritania phone number regex (+222)
    final phoneRegex = RegExp(r'^(222|00222|\+222)?[2-4][0-9]{7}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف موريتاني صحيح (مثال: +222 12345678)';
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  // Password confirmation validation
  static String? passwordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  // Date validation (for birth date)
  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تاريخ الميلاد مطلوب';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final age = now.difference(date).inDays ~/ 365;

      if (age < 0 || age > 120) {
        return 'يرجى إدخال تاريخ ميلاد صحيح';
      }
    } catch (e) {
      return 'يرجى إدخال تاريخ صحيح (YYYY-MM-DD)';
    }

    return null;
  }

  // Generic minimum length validator
  static String? minLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    if (value.length < length) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $length أحرف على الأقل';
    }
    return null;
  }

  // Generic maximum length validator
  static String? maxLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty values
    }
    if (value.length > length) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $length أحرف على الأكثر';
    }
    return null;
  }
}

class AppForm {
  // Email input field with validation
  static Widget emailField({
    required TextEditingController controller,
    String? labelText = 'البريد الإلكتروني',
    String? hintText = 'أدخل بريدك الإلكتروني',
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.right,
      validator: FormValidators.email,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  // Phone number input field with validation
  static Widget phoneField({
    required TextEditingController controller,
    String? labelText = 'رقم الهاتف',
    String? hintText = '32816779',
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.right,
      validator: FormValidators.phone,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  // Password input field with validation
  static Widget passwordField({
    required TextEditingController controller,
    String? labelText = 'كلمة المرور',
    String? hintText = 'أدخل كلمة المرور',
    bool obscureText = true,
    void Function(String)? onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          validator: FormValidators.password,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 15.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFF00BFFF),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  // Toggle obscureText
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Name input field with validation
  static Widget nameField({
    required TextEditingController controller,
    String? labelText = 'الاسم الكامل',
    String? hintText = 'أدخل اسمك الكامل',
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      validator: FormValidators.name,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}
