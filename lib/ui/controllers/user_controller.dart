import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../data/model/app_user.dart';
import 'authentication_controller.dart';

// Controlador usado para manejar los usuarios del chat
class UserController extends GetxController {
  // lista en la que se almacenan los uaurios, la misma es observada por la UI
  var _users = <AppUser>[].obs;

  final databaseRef = FirebaseDatabase.instance.ref();

  late StreamSubscription<DatabaseEvent> newEntryStreamSubscription;

  late StreamSubscription<DatabaseEvent> updateEntryStreamSubscription;

  // devolvemos a la UI todos los usuarios excepto el que está logeado en el sistema
  // esa lista será usada para la pantalla en la que listan los usuarios con los que se
  // puede comenzar una conversación
  get users {
    AuthenticationController authenticationController = Get.find();
    return _users
        .where((entry) => entry.uid != authenticationController.getUid())
        .toList();
  }

  get allUsers => _users;

  // método para comenzar a escuchar cambios en la "tabla" userList de la base de
  // datos
  void start() {
    _users.clear();

    newEntryStreamSubscription =
        databaseRef.child("userList").onChildAdded.listen(_onEntryAdded);

    updateEntryStreamSubscription =
        databaseRef.child("userList").onChildChanged.listen(_onEntryChanged);
  }

  // método para dejar de escuchar cambios
  void stop() {
    newEntryStreamSubscription.cancel();
    updateEntryStreamSubscription.cancel();
  }

  // cuando obtenemos un evento con un nuevo usuario lo agregamos a _users
  _onEntryAdded(DatabaseEvent event) {
    final json = event.snapshot.value as Map<dynamic, dynamic>;
    _users.add(AppUser.fromJson(event.snapshot, json));
  }

  // cuando obtenemos un evento con un usuario modificado lo reemplazamos en _users
  // usando el key como llave
  _onEntryChanged(DatabaseEvent event) {
    var oldEntry = _users.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    final json = event.snapshot.value as Map<dynamic, dynamic>;
    _users[_users.indexOf(oldEntry)] = AppUser.fromJson(event.snapshot, json);
  }

  // método para crear un nuevo usuario
  Future<void> createUser(email, uid) async {
    logInfo("Creating user in realTime for $email and $uid");
    try {
      await databaseRef
          .child('userList')
          .push()
          .set({'email': email, 'uid': uid});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }
}
