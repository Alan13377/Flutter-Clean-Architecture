import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../domain/either.dart';

class Http {
  final String _baseUrl;
  final String _apiKey;
  final Client _client;

  Http({
    required Client client,
    required String baseUrl,
    required String apiKey,
  })  : _client = client,
        _baseUrl = baseUrl,
        _apiKey = apiKey;

  Future<Either<HttpFailure, R>> request<R>(
    String path, {
    required R Function(String responseBody) onSuccess,
    HttpMetod method = HttpMetod.get,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Map<String, dynamic> body = const {},
    bool useApiKey = true,
  }) async {
    Map<String, dynamic> logs = {};
    StackTrace? stackTrace;
    //*Si la api requiere una key siempre la manda
    try {
      if (useApiKey) {
        queryParameters = {...queryParameters, 'api_key': _apiKey};
      }

      //*Parseamos la url base y concatenamos el path
      Uri url = Uri.parse(
        path.startsWith('http') ? path : '$_baseUrl$path',
      );

      if (queryParameters.isNotEmpty) {
        url = url.replace(
          queryParameters: {...queryParameters},
        );
      }
      //*Header por defecto Content-Type
      headers = {
        'Content-Type': 'application/json',
        ...headers,
      };

      //*Respuestas de la API
      late final Response response;
      //*Convertimos el body en un string
      final bodyString = jsonEncode(body);
      logs = {
        'url': url.toString(),
        'method': method.name,
        'body': body,
      };

      switch (method) {
        case HttpMetod.get:
          response = await _client.get(url);
          break;
        case HttpMetod.post:
          response =
              await _client.post(url, headers: headers, body: bodyString);
          break;
        case HttpMetod.put:
          response = await _client.put(url, headers: headers, body: bodyString);
          break;
        case HttpMetod.patch:
          response =
              await _client.patch(url, headers: headers, body: bodyString);
          break;
        case HttpMetod.delete:
          response =
              await _client.delete(url, headers: headers, body: bodyString);
          break;
      }
//*Si la peticion es exitosa retornamon el string response.body
      final statusCode = response.statusCode;
      logs = {
        ...logs,
        'startTime': DateTime.now().toString(),
        'statusCode': statusCode,
        'responseBody': response.body
      };
      if (statusCode >= 200 && statusCode < 300) {
        return Either.right(onSuccess(response.body));
      }

      //*Si la respuesta es erronea retormanos el status code
      return Either.left(
        HttpFailure(statusCode: statusCode),
      );
    } catch (e, s) {
      stackTrace = s;
      logs = {
        ...logs,
        'exception': e.runtimeType,
      };
      //*Errores por conexion
      if (e is SocketException || e is ClientException) {
        logs = {...logs, 'exception': 'NetworkException'};
        return Either.left(
          HttpFailure(
            exception: NetworkException(),
          ),
        );
      }

      //*Error externo
      return Either.left(
        HttpFailure(
          exception: e,
        ),
      );
    } finally {
      if (kDebugMode) {
        logs = {...logs, 'endTime': DateTime.now().toString()};
        print(''' 
            --------------
           ${const JsonEncoder.withIndent(' ').convert(logs)}
            --------------
        ''');
        print(stackTrace);
      }
    }
  }
}

class HttpFailure {
  final int? statusCode;
  final Object? exception;

  HttpFailure({this.statusCode, this.exception});
}

//*Errores por conexion
class NetworkException {}

enum HttpMetod {
  get,
  post,
  put,
  patch,
  delete,
}
