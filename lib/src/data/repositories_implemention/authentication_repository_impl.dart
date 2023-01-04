import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/remote/auth_api.dart';

const _key = 'sessionKey';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FlutterSecureStorage _secureStorage;
  final AuthenticationApi _authenticationApi;

  AuthenticationRepositoryImpl(this._secureStorage, this._authenticationApi);
  @override
  Future<User?> getUserData() {
    return Future.value(
      User(),
    );
  }

  @override
  Future<bool> get isSignedIn async {
    final sessionId = await _secureStorage.read(key: _key);
    return sessionId != null;
  }

  @override
  Future<Either<SignInFailure, User>> signIn(
      String userName, String password) async {
    //*Llamamos a la clase de Autenticacion
    final requestTokenResult = await _authenticationApi.createRequestToken();
    return requestTokenResult.when(
      (failure) => Either.left(failure),
      (requestToken) async {
        final loginResult = await _authenticationApi.createSesionWithLogin(
          userName: userName,
          password: password,
          requestToken: requestToken,
        );

        return loginResult.when((
          failure,
        ) async {
          return Either.left(
            failure,
          );
        }, (
          newRequestToken,
        ) async {
          final sessionResult = await _authenticationApi.createSesion(
            newRequestToken,
          );
          return sessionResult.when(
              (failure) async => Either.left(
                    failure,
                  ), (
            sessionId,
          ) async {
            await _secureStorage.write(
              key: _key,
              value: sessionId,
            );
            return Either.right(
              User(),
            );
          });
        });
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _key);
  }
}
