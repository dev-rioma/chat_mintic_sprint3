import 'package:f_chat_template/ui/controllers/chat_controller.dart';
import 'package:f_chat_template/ui/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../data/model/app_user.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/user_controller.dart';

// Widget donde se presentan los usuarios con los que se puede comenzar un chat
class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // obtenemos la instancia de los controladores
  AuthenticationController authenticationController = Get.find();
  ChatController chatController = Get.find();
  UserController userController = Get.find();

  @override
  void initState() {
    // le decimos al userController que se suscriba a los streams
    userController.start();
    super.initState();
  }

  @override
  void dispose() {
    // le decimos al userController que se cierre los streams
    userController.stop();
    super.dispose();
  }

  _logout() async {
    try {
      await authenticationController.logout();
    } catch (e) {
      logError(e);
    }
  }

  Widget _item(AppUser element) {
    // Widget usado en la lista de los usuarios
    // mostramos el correo y uid
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        onTap: () {
          Get.to(() => const ChatPage(), arguments: [
            element.uid,
            element.email,
          ]);
        },
        title: Text(
          element.email,
        ),
        subtitle: Text(element.uid),
      ),
    );
  }

  Widget _list() {
    // Un widget con La lista de los usuarios con una validación para cuándo la misma este vacia
    // la lista de usuarios la obtenemos del userController
    return GetX<UserController>(builder: (controller) {
      if (userController.users.length == 0) {
        return const Center(
          child: Text('No users'),
        );
      }
      return ListView.builder(
        itemCount: userController.users.length,
        itemBuilder: (context, index) {
          var element = userController.users[index];
          return _item(element);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat App ${authenticationController.userEmail()}"),
          actions: [
            // botón para crear unos chats para arrancar el demo
            IconButton(
                onPressed: () {
                  chatController.initializeChats();
                },
                icon: const Icon(Icons.play_circle_outlined)),
            // botón para cerrar la sesión con el usuario
            IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  _logout();
                }),
          ],
        ),
        body: _list());
  }
}
