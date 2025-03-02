import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/shared/constants/mapper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  Future<UserMy?> get currentUser async {
    if (user == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserMy.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id;
  }

  Future<bool> checkUser() async {
    return user != null;
  }

  Future<bool> hasAccount() async {
    return _firestore.collection('users').doc(user!.uid).get().then((doc) {
      return doc.exists;
    });
  }

  Future<void> createUser() async {
    UserMy userMy = UserMapper.fromUser(user!);
    await _firestore.collection('users').doc(userMy.id).set(userMy.toMap());
  }

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

  Future<String?> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();

      createUser();

      return null;
    } catch (e) {
      return "Error al iniciar sesión de como invitado.";
    }
  }

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

  Future<String?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "No ha seleccionado una cuenta de Google.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user!.linkWithCredential(credential);
      print("Cuenta vinculada exitosamente con Google.");

      await _firestore.collection('users').doc(user!.uid).update({
        'name': googleUser.displayName,
        'email': googleUser.email,
        'photoURL': googleUser.photoUrl,
        'isAnonymous': false,
        'isGoogle': true
      });
      print(user.toString());

      print("Documento de usuario actualizado con éxito ${_firestore.collection('users').doc(user!.uid).get().toString()}");
      return null;
    } catch (e) {
      print("Error al vincular cuenta con Google: $e");
      return "Error inesperado al vincular cuenta con Google.";
    }
  }

  Future<String?> signout() async {
    try {
      await _auth.signOut();

      print("Cerrar sesión con éxito");

      return null;
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  Future<String?> signOutGoogle() async {
    try {
      await GoogleSignIn().disconnect();

      return signout();
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  Future<String?> linkAnonymousAccount(
      String email, String password, String displayName) async {
    try {
      await _auth.currentUser!.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password));

      await _auth.currentUser!.updateDisplayName(displayName);

      print("Con exito user: ${FirebaseAuth.instance.currentUser!.toString()}");

      await _firestore.collection('users').doc(user!.uid).update({
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

  Future<void> deleteSubcollectionDocuments(
      CollectionReference collectionRef) async {
    QuerySnapshot snapshot = await collectionRef.get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<String?> deleteUserAccount() async {
    try {
      String userId = _auth.currentUser!.uid;

      await deleteSubcollectionDocuments(
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('vehicles'),
      );

      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      await _auth.currentUser!.delete();

      print("Cuenta eliminada con éxito.");
      return null;
    } catch (e) {
      print("Error al eliminar la cuenta: $e");
      return "Error al eliminar la cuenta.";
    }
  }

  Future<String?> updateProfile(String name, String? photo, bool isPhotoChanged) async {
    try {
        await _firestore.collection('users').doc(user!.uid).update({
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
}
