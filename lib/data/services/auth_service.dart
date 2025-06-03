import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mi_garaje/data/models/family.dart';
import 'package:mi_garaje/data/models/user.dart' as app;
import 'package:mi_garaje/shared/utils/mapper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter de Firebase Auth
  User? get getUser => _auth.currentUser;

  // Getter para obtener el usuario actual
  Future<app.User?> get currentUser async {
    if (getUser == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(getUser!.uid).get();

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
  Future<void> signin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('Correo o contraseña incorrecta.');
      } else {
        throw Exception(
            'Error al intentar iniciar sesión. Por favor, inténtalo nuevamente.');
      }
    } catch (_) {
      throw Exception('Ha ocurrido un error inesperado.');
    }
  }

  // Método para iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("No ha seleccionado una cuenta de Google.");
    }

    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (!await hasAccount()) {
        await createUser();
      }
    } catch (e) {
      throw Exception("Error inesperado al iniciar sesión con Google.");
    }
  }

  // Método para registrar un usuario correo y contraseña
  Future<void> signup(String email, String password, String displayName) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser!.updateDisplayName(displayName);
      await createUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Existe una cuenta con este correo electrónico.');
      }
      throw Exception(
          'Error al crear la cuenta. Por favor, inténtalo nuevamente.');
    } catch (_) {
      throw Exception('Ha ocurrido un error inesperado al registrarse.');
    }
  }

  // Método para iniciar sesión como invitado
  Future<void> signUpAnonymously() async {
    try {
      await _auth.signInAnonymously();
      await createUser();
    } catch (e) {
      throw Exception("Error al iniciar sesión como invitado.");
    }
  }

  // Método para vincular cuenta anónima con correo y contraseña
  Future<void> linkAnonymousAccount(
      String email, String password, String displayName) async {
    try {
      await _auth.currentUser!.linkWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

      await _auth.currentUser!.updateDisplayName(displayName);

      await _firestore.collection('users').doc(getUser!.uid).update({
        'name': displayName,
        'email': email,
        'isAnonymous': false,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Existe una cuenta con este correo electrónico.');
      }
      throw Exception(
          'Error al vincular cuenta anónima. Por favor, inténtalo nuevamente.');
    } catch (e) {
      throw Exception('Error inesperado al vincular cuenta anónima.');
    }
  }

  // Método para vincular cuenta con Google
  Future<void> linkWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("No ha seleccionado una cuenta de Google.");
    }

    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await getUser!.linkWithCredential(credential);

      await _firestore.collection('users').doc(getUser!.uid).update({
        'name': googleUser.displayName,
        'photoURL': googleUser.photoUrl,
        'isAnonymous': false,
        'isGoogle': true,
      });
    } on FirebaseAuthException catch (e) {
      await GoogleSignIn().signOut();
      if (e.code == 'credential-already-in-use') {
        throw Exception(
            'Esta cuenta de Google ya está vinculada a otro usuario.');
      } else {
        throw Exception('Error inesperado al vincular cuenta con Google.');
      }
    } catch (e) {
      await GoogleSignIn().signOut();
      throw Exception('Error inesperado al vincular cuenta con Google.');
    }
  }

  // Método para cerrar sesión
  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Error al cerrar sesión");
    }
  }

  // Método para cerrar sesión con Google
  Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      throw Exception("Error al cerrar sesión");
    }
  }

  // Método para eliminar la cuenta de usuario
  Future<void> deleteUserAccount() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .delete();

      await _auth.currentUser!.delete();
    } catch (e) {
      throw Exception("Error al eliminar la cuenta.");
    }
  }

  // Método para actualizar el perfil de usuario
  Future<void> updateProfile(
      String name, String? photo, bool isPhotoChanged, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'photoURL': photo,
        'isPhotoChanged': isPhotoChanged,
      });
    } catch (e) {
      throw Exception("Error al actualizar el perfil");
    }
  }

  // Método para crear a una familia
  Future<String> convertToFamily(Family family, String userId) async {
    try {
      String familyId = _firestore.collection('families').doc().id;

      await _firestore.collection('families').doc(familyId).set({
        'members': [family.members!.first.id],
        'code': family.code,
        'creationDate': family.creationDate!.toIso8601String(),
      });

      await _firestore.collection('users').doc(userId).update({
        'idFamily': familyId,
      });

      return familyId;
    } catch (e) {
      throw Exception('Error al convertir el usuario en familia.');
    }
  }

  // Método para abandonar la familia
  Future<void> leaveFamily(
      bool eliminar, String userId, String familyId) async {
    await _firestore.collection('families').doc(familyId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    await _firestore.collection('users').doc(userId).update({
      'idFamily': null,
    });

    if (eliminar) {
      await _firestore.collection('families').doc(familyId).delete();
    }
  }

  // Método para unirse a una familia
  Future<void> joinFamily(String familyCode, String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('families')
          .where('code', isEqualTo: familyCode)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No se encontró la familia");
      }

      DocumentSnapshot doc = snapshot.docs.first;

      await _firestore.collection('families').doc(doc.id).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'idFamily': doc.id,
      });
    } catch (e) {
      throw Exception("Error al unirse a la familia.");
    }
  }

  // Método para obtener la familia del usuario
  Future<Family> getFamily(String idFamily) async {
    DocumentSnapshot doc =
        await _firestore.collection('families').doc(idFamily).get();

    Family family = Family.fromMap(doc.data() as Map<String, dynamic>)
      ..id = doc.id;

    List<String> members = List<String>.from(doc.get('members'));

    List<app.User> users = [];
    for (String id in members) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(id).get();
      users.add(app.User.fromMap(userDoc.data() as Map<String, dynamic>)
        ..id = userDoc.id);
    }
    family.addMembers(users);
    return family;
  }
}
