import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/connectivity_repository.dart';
import '../services/remote/internet_checker.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final Connectivity _connectivity;
  final InternetChecker _internetChecker;

  ConnectivityRepositoryImpl(this._connectivity, this._internetChecker);
  @override
  Future<bool> get hasInternet async {
    final result = await _connectivity.checkConnectivity();

    //*Si el dispositivo no esta conectado a una red
    if (result == ConnectivityResult.none) {
      return false;
    }
    return _internetChecker.hasInternet();
  }
  //*Comprobar si se tiene conexion a internet

}
