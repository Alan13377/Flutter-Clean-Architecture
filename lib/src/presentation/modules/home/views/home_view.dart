import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text("Home View"),
          ),
          TextButton(
              onPressed: () async {
                await Injector.of(context).authenticationRepository.signOut();

                Navigator.pushReplacementNamed(context, Routes.signIn);
              },
              child: const Text("Sign out"))
        ],
      ),
    );
  }
}
