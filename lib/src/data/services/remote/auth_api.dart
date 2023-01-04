import 'dart:convert';

import '../../../domain/either.dart';
import '../../../domain/enums.dart';
import '../../http/http.dart';

class AuthenticationApi {
  final Http _http;
  // final _apiKey = '6f6a8ae60bfbc11f439583921b9326c1';
  // final _baseUrl = 'https://api.themoviedb.org/3';
  AuthenticationApi(this._http);

  Either<SignInFailure, String> handleFailure(HttpFailure failure) {
    if (failure.statusCode != null) {
      switch (failure.statusCode!) {
        case 401:
          return Either.left(SignInFailure.unauthorized);
        case 404:
          return Either.left(SignInFailure.notFound);
        default:
          return Either.left(SignInFailure.unknown);
      }
    }
    if (failure.exception is NetworkException) {
      Either.left(SignInFailure.network);
    }
    return Either.left(SignInFailure.unknown);
  }

//*Creacion del Token MovieDB
  Future<Either<SignInFailure, String>> createRequestToken() async {
    final result = await _http.request(
      '/authentication/token/new',
      onSuccess: ((responseBody) {
        //*String a map
        //final json = jsonDecode(response.body);
        final json = Map<String, dynamic>.from(jsonDecode(responseBody));
        return json['request_token'] as String;
      }),
    );

    return result.when(
        (failure) => handleFailure(
              failure,
            ), (requestToken) {
      return Either.right(
        //*Recuperamos del map el request token
        requestToken,
      );
    });
  }

//*Crear sesion con usuario y password
  Future<Either<SignInFailure, String>> createSesionWithLogin({
    required String userName,
    required String password,
    required String requestToken,
  }) async {
    final result = await _http.request(
      '/authentication/token/validate_with_login',
      method: HttpMetod.post,
      body: {
        'username': userName,
        'password': password,
        'request_token': requestToken
      },
      onSuccess: (responseBody) {
        final json = Map<String, dynamic>.from(
          jsonDecode(responseBody),
        );
        return json['request_token'] as String;
      },
    );
    return result.when(
      (failure) => handleFailure(failure),
      (newRequestToken) => Either.right(
        newRequestToken,
      ),
    );
  }

//**Crear  Sesion con el token generado */
  Future<Either<SignInFailure, String>> createSesion(
      String requestToken) async {
    final result = await _http
        .request('/authentication/session/new', method: HttpMetod.post, body: {
      'request_token': requestToken,
    }, onSuccess: (responseBody) {
      final json = Map<String, dynamic>.from(
        jsonDecode(
          responseBody,
        ),
      );
      return json['session_id'] as String;
    });
    return result.when(
      (failure) => handleFailure(failure),
      (sessionId) => Either.right(sessionId),
    );
  }
}
