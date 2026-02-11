import 'package:flutter/material.dart';
import 'package:slient_chat/components/my_textfield.dart';
import '../components/my_button.dart';
import '../services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {

  // email and password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  // tap to go to register page
  final void Function()? onTap;


  RegisterPage({super.key, this.onTap});

  // resgister user method
  void register(BuildContext context) async {

    // get auth service instance
    final _auth = AuthService();

    // password match => create user
    if (_pwController.text == _confirmPwController.text){
      try {
        await _auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
      } catch (e) {
        showDialog(context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            )
        );
      }
    }

    // password don't match => tell user to fix
    else {
      showDialog(context: context,
          builder: (context) => const AlertDialog(
            title: Text("Passwords don't match!"),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
          Image.asset(
          'assets/images/logo3.png',
          width: 250,
          height: 250,
        ),


            // well come back message
            Text(
                "Let's create an account for you!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                )
            ),
            SizedBox(height: 16),
            // email textfield
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            SizedBox(height: 10),
            // password textfield
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            SizedBox(height: 10),
            // confirm password textfield
            MyTextField(
              hintText: "Confirm password",
              obscureText: true,
              controller: _confirmPwController,
            ),
            SizedBox(height: 25),

            // login button
            MyButton(
                onTap: () => register(context),
                text: "Register"
            ),
            SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account ?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text("Login now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}