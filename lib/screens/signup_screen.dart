import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SignupScreen extends StatefulWidget {
const SignupScreen({super.key});

@override
State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
final nameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();

bool isLoading = false;
bool hidePassword = true;
bool hideConfirmPassword = true;

Future<void> signup() async {
final name = nameController.text.trim();
final email = emailController.text.trim();
final password = passwordController.text.trim();
final confirmPassword = confirmPasswordController.text.trim();


if (name.isEmpty ||
    email.isEmpty ||
    password.isEmpty ||
    confirmPassword.isEmpty) {
  showMessage('Please fill all fields');
  return;
}

if (password != confirmPassword) {
  showMessage('Passwords do not match');
  return;
}

if (password.length < 6) {
  showMessage('Password must be at least 6 characters');
  return;
}

setState(() {
  isLoading = true;
});

try {
  final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = credential.user;

  if (user == null) {
    throw Exception('User creation failed');
  }

  await user.updateDisplayName(name);

  await FirebaseDatabase.instance.ref('users/${user.uid}').set({
    'uid': user.uid,
    'name': name,
    'email': email,
    'createdAt': ServerValue.timestamp,
  });

  if (!mounted) return;

  showMessage('Account created successfully');

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const MainNavigationScreen(),
    ),
    (route) => false,
  );
} on FirebaseAuthException catch (e) {
  String message = 'Sign up failed';

  if (e.code == 'email-already-in-use') {
    message = 'This email is already registered';
  } else if (e.code == 'invalid-email') {
    message = 'Please enter a valid email';
  } else if (e.code == 'weak-password') {
    message = 'Password is too weak';
  } else if (e.code == 'network-request-failed') {
    message = 'Please check your internet connection';
  }

  showMessage(message);
} catch (e) {
  showMessage('Something went wrong');
}

if (mounted) {
  setState(() {
    isLoading = false;
  });
}


}

void showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
backgroundColor: Colors.deepOrange,
),
);
}

@override
void dispose() {
nameController.dispose();
emailController.dispose();
passwordController.dispose();
confirmPasswordController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF080D19),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 20,
),
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 450,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
width: 72,
height: 72,
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.deepOrange.withValues(alpha: 0.25),
blurRadius: 20,
),
],
),
child: ClipOval(
child: Image.asset(
'assets/images/car_logo.jfif',
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return const Icon(
Icons.directions_car,
color: Colors.deepOrange,
size: 40,
);
},
),
),
),
const SizedBox(height: 14),
const Text(
'AutoZone Premium',
style: TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
const Text(
'Create your account',
style: TextStyle(
color: Colors.white60,
fontSize: 14,
),
),
const SizedBox(height: 25),
ClipRRect(
borderRadius: BorderRadius.circular(20),
child: SizedBox(
height: 190,
width: double.infinity,
child: Image.asset(
'assets/images/car_image.jfif',
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return Container(
color: const Color(0xFF111827),
child: const Icon(
Icons.directions_car,
color: Colors.white54,
size: 70,
),
);
},
),
),
),
const SizedBox(height: 25),
_label('Full Name'),
const SizedBox(height: 8),
_textField(
controller: nameController,
hint: 'Enter your name',
icon: Icons.person_outline,
),
const SizedBox(height: 15),
_label('Email'),
const SizedBox(height: 8),
_textField(
controller: emailController,
hint: 'Enter your email',
icon: Icons.email_outlined,
keyboardType: TextInputType.emailAddress,
),
const SizedBox(height: 15),
_label('Password'),
const SizedBox(height: 8),
_textField(
controller: passwordController,
hint: 'Create a password',
icon: Icons.lock_outline,
obscureText: hidePassword,
suffixIcon: IconButton(
onPressed: () {
setState(() {
hidePassword = !hidePassword;
});
},
icon: Icon(
hidePassword
? Icons.visibility_off_outlined
: Icons.visibility_outlined,
color: Colors.white60,
),
),
),
const SizedBox(height: 15),
_label('Confirm Password'),
const SizedBox(height: 8),
_textField(
controller: confirmPasswordController,
hint: 'Confirm your password',
icon: Icons.lock_outline,
obscureText: hideConfirmPassword,
suffixIcon: IconButton(
onPressed: () {
setState(() {
hideConfirmPassword = !hideConfirmPassword;
});
},
icon: Icon(
hideConfirmPassword
? Icons.visibility_off_outlined
: Icons.visibility_outlined,
color: Colors.white60,
),
),
),
const SizedBox(height: 25),
SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton(
onPressed: isLoading ? null : signup,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepOrange,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
: const Text(
'CREATE ACCOUNT',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
),
),
),
),
const SizedBox(height: 18),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'Already have an account? ',
style: TextStyle(
color: Colors.white60,
fontSize: 12,
),
),
TextButton(
onPressed: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const LoginScreen(),
),
);
},
child: const Text(
'Login',
style: TextStyle(
color: Colors.deepOrange,
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
),
],
),
],
),
),
),
),
),
);
}

Widget _label(String text) {
return Align(
alignment: Alignment.centerLeft,
child: Text(
text,
style: const TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
);
}

Widget _textField({
required TextEditingController controller,
required String hint,
required IconData icon,
bool obscureText = false,
TextInputType keyboardType = TextInputType.text,
Widget? suffixIcon,
}) {
return TextField(
controller: controller,
obscureText: obscureText,
keyboardType: keyboardType,
style: const TextStyle(
color: Colors.white,
),
decoration: InputDecoration(
hintText: hint,
hintStyle: const TextStyle(
color: Colors.white54,
),
prefixIcon: Icon(
icon,
color: Colors.white60,
),
suffixIcon: suffixIcon,
filled: true,
fillColor: const Color(0xFF111827),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(13),
borderSide: BorderSide.none,
),
),
);
}
}
