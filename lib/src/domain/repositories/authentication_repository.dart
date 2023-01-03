import '../models/user.dart';

abstract class AuthenticationRepository {
  //*Funciones sin cuerpo
  Future<bool> get isSignedIn;
  Future<User?> getUserData();
}
