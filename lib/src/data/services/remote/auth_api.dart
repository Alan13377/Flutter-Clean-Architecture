import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../../domain/either.dart';
import '../../../domain/enums.dart';

class AuthenticationApi {
  final Client _client;
  final _apiKey = '6f6a8ae60bfbc11f439583921b9326c1';
  final _baseUrl = 'https://api.themoviedb.org/3';
  AuthenticationApi(this._client);

//*Creacion del Token MovieDB
  Future<String?> createRequestToken() async {
    try {
      //*La respuesta regresa como string
      final response = await _client.get(
        Uri.parse('$_baseUrl/authentication/token/new?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        //*String a map
        //final json = jsonDecode(response.body);
        final json = Map<String, dynamic>.from(jsonDecode(response.body));
        return json['request_token'];
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

//*Crear sesion con usuario y password
  Future<Either<SignInFailure, String>> createSesionWithLogin(
      {required String userName,
      required String password,
      required String requestToken}) async {
    try {
      final response = await _client.post(
        Uri.parse(
            '$_baseUrl/authentication/token/validate_with_login?api_key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},

        //*Convertir a String
        body: jsonEncode(
          {
            'username': userName,
            'password': password,
            'request_token': requestToken
          },
        ),
      );
      //*Respuesta de la solicitud
      switch (response.statusCode) {
        case 200:
          final json = Map<String, dynamic>.from(
            jsonDecode(response.body),
          );
          final newRequestToken = json['request_token'] as String;
          return Either.right(newRequestToken);

        case 401:
          return Either.left(SignInFailure.unauthorized);
        case 404:
          return Either.left(SignInFailure.notFound);
        default:
          Either.left(SignInFailure.unknown);
      }
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }
    }
    return Either.left(SignInFailure.unknown);
  }

//**Crear  Sesion con el token generado */
  Future<Either<SignInFailure, String>> createSesion(
      String requestToken) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/authentication/session/new?api_key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            'request_token': requestToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = Map<String, dynamic>.from(
          jsonDecode(
            response.body,
          ),
        );
        final sessionId = json['session_id'] as String;
        return Either.right(sessionId);
      }
      return Either.left(SignInFailure.unknown);
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }
      return Either.left(SignInFailure.unknown);
    }
  }
}
