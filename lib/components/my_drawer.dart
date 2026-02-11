import 'package:flutter/material.dart';
import '../pages/SettingsPage.dart';
import '../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // get auth service and call sign out
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListTileTheme(
        iconColor: color,
        textColor: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                //logo
                DrawerHeader(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo3.png',
                        width: 250,
                        height: 250,
                      ),
                    )
                ),

                // home list tile
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text("HOME"),
                    leading: Icon(Icons.home),
                    onTap:(){
                      // pop the drawer
                      Navigator.pop(context);
                    },
                  ),
                ),

                // setting list tile
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text("SETTINGS"),
                    leading: Icon(Icons.settings),
                    onTap:(){

                      // pop the drawer
                      Navigator.pop(context);

                      // navigate to settings page
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                    },
                  ),
                ),
              ],

            ),
            // logout list tile
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: ListTile(
                title: const Text("LOGOUT"),
                leading: const Icon(Icons.logout),
                onTap: logout,
              ),
            )
          ],
        ),
      ),
    );
  }
}