import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'src/data/repositories_implemention/authentication_repository_impl.dart';
import 'src/data/repositories_implemention/connectivity_implementation.dart';
import 'src/data/services/remote/internet_checker.dart';
import 'src/domain/repositories/authentication_repository.dart';
import 'src/domain/repositories/connectivity_repository.dart';
import 'src/myapp.dart';

void main() {
  runApp(
    //*Injectar los repositorios
    Injector(
      //*Implementacion de los repositorios
      connectivityRepository: ConnectivityRepositoryImpl(
        Connectivity(),
        InternetChecker(),
      ),
      authenticationRepository: AuthenticationRepositoryImpl(
        const FlutterSecureStorage(),
      ),
      child: const MyApp(),
    ),
  );
}

//*Recuperar los repositorios
class Injector extends InheritedWidget {
  final ConnectivityRepository connectivityRepository;
  final AuthenticationRepository authenticationRepository;

  const Injector({
    super.key,
    required Widget child,
    required this.connectivityRepository,
    required this.authenticationRepository,
  }) : super(child: child);
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static Injector of(BuildContext context) {
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(injector != null, "Injector could not be found");
    return injector!;
  }
}
