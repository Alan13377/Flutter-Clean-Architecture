import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../domain/enums.dart';
import '../../../routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String _userName = '';
  String _password = '';
  bool _fetching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          //*Bloquar el formulario
          child: AbsorbPointer(
            absorbing: _fetching,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(hintText: 'User Name'),
                  onChanged: (text) {
                    setState(
                      () {
                        _userName = text.trim().toLowerCase();
                      },
                    );
                  },
                  validator: (text) {
                    //*Eliminar espacios al inicio y final y pasar a minusculas
                    text = text?.toLowerCase() ?? '';
                    if (text.isEmpty) {
                      return 'Campo Vacio';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(hintText: 'Contraseña'),
                  onChanged: (text) {
                    setState(() {
                      //*Remplazar los espacios en blanco con un string vacio
                      _password = text.replaceAll(' ', '');
                    });
                  },
                  validator: (text) {
                    //*Eliminar espacios al inicio y final y pasar a minusculas
                    text = text?.replaceAll(' ', '') ?? '';
                    if (text.length < 4) {
                      return 'Contraseña demasiado Corta';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  if (_fetching) {
                    return const CircularProgressIndicator();
                  }
                  return MaterialButton(
                    onPressed: () {
                      final isValid = Form.of(context)!.validate();
                      if (isValid) {
                        _submit(context);
                      }
                    },
                    color: Colors.blue,
                    child: const Text('Sign In'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _fetching = true;
    });

    final result = await Injector.of(context)
        .authenticationRepository
        .signIn(_userName, _password);

    if (!mounted) {
      return;
    }
    result.when((failure) {
      setState(() {
        _fetching = false;
      });
      final message = {
        SignInFailure.notFound: 'No se encontro el usuario',
        SignInFailure.unauthorized: 'Contraseña Invalida',
        SignInFailure.unknown: 'Error del Sistema',
        SignInFailure.network: 'Error NetWork'
      }[failure];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message!),
        ),
      );
    }, (user) {
      Navigator.pushReplacementNamed(context, Routes.home);
    });
  }
}
