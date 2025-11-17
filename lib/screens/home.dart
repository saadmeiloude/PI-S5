import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;

    // Define the primary color (a bright blue)
    const Color primaryColor = Color(0xFF00BFFF); // A bright blue color

    // Define the text style for the main title
    const TextStyle titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.2,
    );

    // Define the text style for the description
    const TextStyle descriptionStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF757575),
      height: 1.6,
      fontWeight: FontWeight.w400,
    );

    // Define the text style for the social sign-up links
    const TextStyle socialLinkStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    // Helper function to create a custom button
    Widget buildButton({
      required String text,
      required Color backgroundColor,
      required Color textColor,
      required VoidCallback onPressed,
      double verticalPadding = 18.0,
    }) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: backgroundColor == Colors.white
                  ? const BorderSide(color: Color(0xFFE0E0E0), width: 1.0)
                  : BorderSide.none,
            ),
            elevation: backgroundColor == Colors.white
                ? 2.0
                : 0, // Subtle shadow for white buttons
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      );
    }

    // Placeholder for the image. In a real app, this would be an Image.asset or Image.network
    // For this example, we'll use a Container with a fixed height and a background color
    // to represent the space and aspect ratio of the image.
    Widget buildImagePlaceholder() {
      return Container(
        width: size.width,
        height: size.height * 0.45, // Slightly taller for better proportion
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Light cyan
              Color(0xFFB2DFDB), // Light teal
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 80, color: Colors.teal.shade700),
              const SizedBox(height: 16),
              Text(
                'Your Health Journey Starts Here',
                style: TextStyle(
                  color: Colors.teal.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Image Section (Placeholder)
            // NOTE: To use the actual image, you would need to add it to your Flutter project's assets folder
            // and replace this placeholder with: Image.asset('assets/pasted_file_HkR7VK_home.jpg')
            buildImagePlaceholder(),
            Image.asset('assets/Medicine-hom.png'),

            // 2. Content Section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Title
                  const Text(
                    'Your Health, Simplified',
                    style: titleStyle,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Find trusted doctors, book appointments, and manage your health records all in one place.',
                    style: descriptionStyle,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 48),

                  // "Get Started" Button (Primary Blue)
                  buildButton(
                    text: 'Get Started',
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_account');
                    },
                  ),
                  const SizedBox(height: 20),

                  // "Log In" Button (White/Light Grey)
                  buildButton(
                    text: 'Log In',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  const SizedBox(height: 48),

                  // Social Sign-up Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "Sign up with Google" Link
                      TextButton.icon(
                        onPressed: () {
                          // Action for Sign up with Google
                          print('Sign up with Google pressed');
                        },
                        icon: Icon(
                          Icons.g_mobiledata,
                          color: Colors.red.shade600,
                          size: 24,
                        ),
                        label: const Text('Google', style: socialLinkStyle),
                      ),
                      const SizedBox(width: 24),
                      // "Sign up with Facebook" Link
                      TextButton.icon(
                        onPressed: () {
                          // Action for Sign up with Facebook
                          print('Sign up with Facebook pressed');
                        },
                        icon: Icon(
                          Icons.facebook,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        label: const Text('Facebook', style: socialLinkStyle),
                      ),
                    ],
                  ),
                ],
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
      title: 'Health App Onboarding',
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}
*/
