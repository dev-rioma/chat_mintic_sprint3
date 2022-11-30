import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../data/model/message.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/chat_controller.dart';

// Widget con la interfaz del chat
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // controlador para el text input
  late TextEditingController _controller;
  // controlador para el sistema de scroll de la lista
  late ScrollController _scrollController;
  late String remoteUserUid;
  late String remoteEmail;

  // obtenemos los parámetros del sistema de navegación
  dynamic argumentData = Get.arguments;

  // obtenemos las instancias de los controladores
  ChatController chatController = Get.find();
  AuthenticationController authenticationController = Get.find();

  @override
  void initState() {
    super.initState();
    // obtenemos los datos del usuario con el cual se va a iniciar el chat de los argumentos
    remoteUserUid = argumentData[0];
    remoteEmail = argumentData[1];

    // instanciamos los controladores
    _controller = TextEditingController();
    _scrollController = ScrollController();

    // Le pedimos al chatController que se suscriba los chats entre los dos usuarios
    chatController.subscribeToUpdated(remoteUserUid);
  }

  @override
  void dispose() {
    // proceso de limpieza
    _controller.dispose();
    _scrollController.dispose();
    chatController.unsubscribe();
    super.dispose();
  }

  Widget _item(Message element, int posicion, String uid) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      // cambiamos el color dependiendo de quién mandó el usuario
      color: uid == element.senderUid ? Colors.yellow[200] : Colors.grey[300],
      child: ListTile(
        title: Text(
          element.msg,
          textAlign:
              // cambiamos el textAlign dependiendo de quién mandó el usuario
              uid == element.senderUid ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _list() {
    String uid = authenticationController.getUid();
    logInfo('Current user $uid');
    // Escuchamos la lista de mensajes entre los dos usuarios usando el ChatController
    return GetX<ChatController>(builder: (controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      return ListView.builder(
        itemCount: chatController.messages.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          var element = chatController.messages[index];
          return _item(element, index, uid);
        },
      );
    });
  }

  Future<void> _sendMsg(String text) async {
    // enviamos un nuevo mensaje usando el ChatController
    logInfo("Calling _sendMsg with $text");
    await chatController.sendChat(remoteUserUid, text);
  }

  Widget _textInput() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 5.0, top: 5.0),
            child: TextField(
              key: const Key('MsgTextField'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your message',
              ),
              onSubmitted: (value) {
                _sendMsg(_controller.text);
                _controller.clear();
              },
              controller: _controller,
            ),
          ),
        ),
        TextButton(
            key: const Key('sendButton'),
            child: const Text('Send'),
            onPressed: () {
              _sendMsg(_controller.text);
              _controller.clear();
            })
      ],
    );
  }

  _scrollToEnd() async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Scaffold(
        appBar: AppBar(title: Text("Chat with $remoteEmail")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 25.0),
          child: Column(
            children: [Expanded(flex: 4, child: _list()), _textInput()],
          ),
        ));
  }
}
