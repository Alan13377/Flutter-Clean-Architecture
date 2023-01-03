import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../routes/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  Future<void> _init() async {
    final injector = Injector.of(context);
    final connectivityRepository = injector.connectivityRepository;

    final hasInternet = await connectivityRepository.hasInternet;
    print("✔️$hasInternet");

    //*Si se tiene conexion a internet
    if (hasInternet) {
      final authenticationRepository = injector.authenticationRepository;
      final isSignedIn = await authenticationRepository.isSignedIn;
      //*Si esta logueado obtener datos del user
      if (isSignedIn) {
        final user = await authenticationRepository.getUserData();
        if (mounted) {
          //*Si se recupero el usuario navegar al home
          if (user != null) {
            _goTo(Routes.home);
            //*Si el user es null navegar al signIn
          } else if (user == null) {
            _goTo(Routes.signIn);
          }
        }
      } else if (mounted) {
        _goTo(Routes.signIn);
      }
    } else {
      _goTo(Routes.offline);
    }
  }

  //*Future para navegacion
  void _goTo(String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
