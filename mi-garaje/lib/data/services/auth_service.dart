import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mi_garaje/data/models/family.dart';
import 'package:mi_garaje/data/models/user.dart' as app;
import 'package:mi_garaje/shared/constants/mapper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter de Firebase Auth
  User? get getUser => _auth.currentUser;

  // Getter para obtener el usuario actual
  Future<app.User?> get currentUser async {
    if (getUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(getUser!.uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return app.User.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id;
  }

  // Método para verificar si el usuario tiene cuenta
  Future<bool> hasAccount() async {
    return _firestore.collection('users').doc(getUser!.uid).get().then((doc) {
      return doc.exists;
    });
  }

  // Método para crear un usuario en Firestore
  Future<void> createUser() async {
    app.User user = UserMapper.fromUser(getUser!);
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Método para iniciar sesión con correo y contraseña
  Future<String?> signin(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      print("Iniciar sesión con éxito");

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'Correo o contraseña incorrecta.';
      } else {
        return 'Error al intentar iniciar sesión. Por favor, inténtalo nuevamente.';
      }
    }
  }

  // Método para iniciar sesión con Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "No ha seleccionado una cuenta de Google.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print("Inicio de sesión con Google exitoso.");

      if (!await hasAccount()) {
        createUser();
      }

      return null;
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      return "Error inesperado al iniciar sesión con Google.";
    }
  }

  // Método para registrar un usuario correo y contraseña
  Future<String?> signup(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser!.updateDisplayName(displayName);

      await createUser();

      print("Documento de usuario creado con éxito");

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Existe una cuenta con este correo electrónico.';
      }
      return 'Error al crear la cuenta. Por favor, inténtalo nuevamente.';
    }
  }

  // Método para registrarse con Google
  Future<String?> signupWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "No ha seleccionado una cuenta de Google.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print("Registro con Google exitoso.");

      await createUser();
      return null;
    } catch (e) {
      print("Error al registrar con Google: $e");
      return "Error inesperado al registrar con Google.";
    }
  }

  // Método para iniciar sesión como invitado
  Future<String?> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();

      createUser();

      return null;
    } catch (e) {
      return "Error al iniciar sesión de como invitado.";
    }
  }

  // Método para vincular cuenta anónima con correo y contraseña
  Future<String?> linkAnonymousAccount(
      String email, String password, String displayName) async {
    try {
      await _auth.currentUser!.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password));

      await _auth.currentUser!.updateDisplayName(displayName);

      print("Con exito user: ${FirebaseAuth.instance.currentUser!.toString()}");

      await _firestore.collection('users').doc(getUser!.uid).update({
        'name': displayName,
        'email': email,
        'isAnonymous': false,
      });
      print("Documento de usuario actualizado con éxito");
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Existe una cuenta con este correo electrónico.';
      }
      return 'Error al vincular cuenta anónima. Por favor, inténtalo nuevamente.';
    }
  }

  // Método para vincular cuenta con Google
  Future<String?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "No ha seleccionado una cuenta de Google.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await getUser!.linkWithCredential(credential);
      print("Cuenta vinculada exitosamente con Google.");

      await _firestore.collection('users').doc(getUser!.uid).update({
        'name': googleUser.displayName,
        'email': googleUser.email,
        'photoURL': googleUser.photoUrl,
        'isAnonymous': false,
        'isGoogle': true
      });
      print(getUser.toString());

      print("Documento de usuario actualizado con éxito ${_firestore.collection('users').doc(getUser!.uid).get().toString()}");
      return null;
    } catch (e) {
      print("Error al vincular cuenta con Google: $e");
      return "Error inesperado al vincular cuenta con Google.";
    }
  }

  // Método para cerrar sesión
  Future<String?> signout() async {
    try {
      await _auth.signOut();

      print("Cerrar sesión con éxito");

      return null;
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  // Método para cerrar sesión con Google
  Future<String?> signOutGoogle() async {
    try {
      await GoogleSignIn().disconnect();

      return signout();
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  // Método para eliminar la cuenta de usuario
  Future<String?> deleteUserAccount() async {
    try {
      String userId = _auth.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      await _auth.currentUser!.delete();

      print("Cuenta eliminada con éxito.");
      return null;
    } catch (e) {
      print("Error al eliminar la cuenta: $e");
      return "Error al eliminar la cuenta.";
    }
  }

  // Método para actualizar el perfil de usuario
  Future<String?> updateProfile(String name, String? photo, bool isPhotoChanged) async {
    try {
        await _firestore.collection('users').doc(getUser!.uid).update({
          'name': name,
          'photoURL': photo,
          'isPhotoChanged': isPhotoChanged,
        });
      print("Documento de usuario actualizado con éxito");

      return null;
    } catch (e) {
      return "Error al actualizar el perfil";
    }
  }

  // Método para crear a una familia
  Future<void> convertToFamily(Family family) async {
    app.User user = (await currentUser)!;
    String familyId = _firestore.collection('families').doc().id; 

    await _firestore.collection('families').doc(familyId).set({
      'name': family.name,
      'members': [family.members!.first.id],
      'code': family.code,
      'creationDate': family.creationDate!.toIso8601String(),
    });

    await _firestore.collection('users').doc(user.id).update({
      'idFamily': familyId,
    });

    print("Familia creada con éxito");
  }

  // Método para abandonar la familia
  Future<void> leaveFamily(bool eliminar) async {
    app.User user = (await currentUser)!;

    await _firestore.collection('families').doc(user.idFamily).update({
      'members': FieldValue.arrayRemove([user.id]),
    });

    await _firestore.collection('users').doc(user.id).update({
      'idFamily': null,
    });

    print("Salida de la familia con éxito");

    if (eliminar) {
      await _firestore.collection('families').doc(user.idFamily).delete();
      print("Familia eliminada con éxito");
    }
  }

  // Método para unirse a una familia
  Future<void> joinFamily(String familyCode) async {
    app.User user = (await currentUser)!;

    QuerySnapshot snapshot = await _firestore.collection('families').where('code', isEqualTo: familyCode).get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No se encontró la familia");
    }

    DocumentSnapshot doc = snapshot.docs.first;

    await _firestore.collection('families').doc(doc.id).update({
      'members': FieldValue.arrayUnion([user.id]),
    });

    await _firestore.collection('users').doc(user.id).update({
      'idFamily': doc.id,
    });
  }

  Future<Family> getFamily(String idFamily) async {
    DocumentSnapshot doc = await _firestore.collection('families').doc(idFamily).get();

    Family family = Family.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id;

    List<String> members = List<String>.from(doc.get('members'));

    List<app.User> users = [];
    for (String id in members) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(id).get();
      users.add(app.User.fromMap(userDoc.data() as Map<String, dynamic>)..id = userDoc.id);
    }
    family.addMembers(users);
    return family;
  }


}
