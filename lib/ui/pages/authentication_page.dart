import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/authentication_controller.dart';

// una interfaz muy sencilla en la que podemos crear los tres usuarios (signup)
// y después logearse (login) con cualquiera de las tres

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();

  void signIn() async {
    // aquí creamos los tres usuarios
    await authenticationController.signup('a@a.com', '123456');
    await authenticationController.signup('b@b.com', '123456');
    await authenticationController.signup('c@c.com', '123456');
  }

  void login(String user) {
    // método usado para login
    authenticationController.login(user, '123456');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat App - Autenticación")),
      body: SafeArea(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: signIn,
                          child: const Text("Crear los tres usuarios"),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Antes de crear los usuarios, borrar todos los usuarios del sistema de autenticación y la base de datos de tiempo real de firebase',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      )
                    ]),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () => login('a@a.com'),
                                child: const Text("Ingresar con usuario A")),
                            ElevatedButton(
                                onPressed: () => login('b@b.com'),
                                child: const Text("Ingresar con usuario B")),
                            ElevatedButton(
                                onPressed: () => login('c@c.com'),
                                child: const Text("Ingresar con usuario C")),
                          ]),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

