import '../either.dart';
import '../enums.dart';
import '../models/user.dart';

abstract class AuthenticationRepository {
  //*Funciones sin cuerpo
  Future<bool> get isSignedIn;
  Future<User?> getUserData();
  Future<void> signOut();
  Future<Either<SignInFailure, User>> signIn(String userName, String password);
}
