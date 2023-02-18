import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/screens/commom/confirmation_dialog.dart';

import '../../services/auth_service.dart';
import '../commom/exception_dialog.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final AuthService service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(32),
        decoration:
            BoxDecoration(border: Border.all(width: 8), color: Colors.white),
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.bookmark,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const Text(
                    "Simple Journal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(thickness: 2),
                  ),
                  const Text("Entre ou Registre-se"),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      label: Text("E-mail"),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _passController,
                    decoration: const InputDecoration(label: Text("Senha")),
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 16,
                    obscureText: true,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        tryLogin(context);
                      },
                      child: const Text("Continuar")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void tryLogin(BuildContext context) async {
    String email = _emailController.text;
    String password = _passController.text;

    service.login(email: email, password: password).then((token) {
      Navigator.pushReplacementNamed(context, 'home');
    }).catchError((error) {
      showConfirmationDialog(
        context,
        title: "Usuário ainda não existe",
        content: "Deseja criar um novo usuário com email $email?",
        affirmativeOption: "Criar",
      ).then((value) async {
        if (value) {
          service.register(email: email, password: password).then((token) {
            Navigator.pushReplacementNamed(context, 'home');
          });
        }
      });
    }, test: (error) => error is UserNotFoundException).catchError((error) {
      HttpException exception = error as HttpException;
      showExceptionDialog(context, content: exception.message);
    }, test: (error) => error is HttpException);
  }
}

/*

amonmenezes2@gmail.com
123321
 */