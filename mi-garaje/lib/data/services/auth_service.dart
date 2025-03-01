//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:mi_garaje/data/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get usuarioActual => _auth.currentUser;

  Future<bool> comprobarUsuarioAutenticado() async {
    return _auth.currentUser != null;
  }
  
  Future<String?> signup(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await _auth.currentUser!.updateDisplayName(displayName);

      /*UserMy user = UserMy(
        id: usuarioActual!.uid,
        name: usuarioActual!.displayName!,
        email: usuarioActual!.email!,
        photoURL: usuarioActual!.photoURL,
        creationDate: usuarioActual!.metadata.creationTime!,
        vehicles: [],
      );

      final docRef = await _firestore
        .collection('users')
        .add(user.toMap());

      user.setId(docRef.id);*/

      //TODO Verificar el correo antes de poder acceder
      //await _auth.currentUser!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Existe una cuenta con este correo electrónico.';
      } 
      return 'Error al crear la cuenta. Por favor, inténtalo nuevamente.';
    }
  }

  Future<String?> signin(
      {required String email,
      required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

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

      return null;
    } catch (e) {
      return "Error al iniciar sesión de como invitado.";
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "No ha seleccionado una cuenta de Google.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      return null;
    } catch (e) {
      return "Error al iniciar sesión con Google";
    }
  }

  Future<String?> signOutGoogle() async {
    try {
      await GoogleSignIn().disconnect();

      await _auth.signOut();

      return null;
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  Future<String?> signout() async {
    try {
      await _auth.signOut();
      
      return null;
    } catch (e) {
      return "Error al cerrar sesión";
    }
  }

  Future<String?> linkAnonymousAccount(String email, String password, String displayName) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      await user.linkWithCredential(EmailAuthProvider.credential(email: email, password: password));
        
      await user.updateDisplayName(displayName);

      print("Con exito user: ${FirebaseAuth.instance.currentUser!.toString()}");
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Existe una cuenta con este correo electrónico.';
      } 
      return 'Error al vincular cuenta anónima. Por favor, inténtalo nuevamente.';
    }
  }

  Future<String?> deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
      print("Con exito");
      return null;
    } catch (e) {
      return "***** Error al eliminar cuenta $e";
    }
  }

  Future<String?> updateProfile(String displayName) async {
    try {
      await _auth.currentUser!.updateProfile(displayName: displayName);
      return null;
    } catch (e) {
      return "Error al actualizar el perfil";
    }
  }
}
