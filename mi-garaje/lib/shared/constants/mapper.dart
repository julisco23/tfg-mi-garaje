import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_garaje/data/models/user.dart';

class UserMapper {
  // Método para crear un objeto UserMy desde un objeto User de Firebase
  static UserMy fromUser(User user) {
    return UserMy(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      isAnonymous: user.isAnonymous,
      isGoogle: user.providerData.isEmpty ? false : user.providerData[0].providerId == 'google.com',
      creationDate: user.metadata.creationTime!,
      isPhotoChanged: !(user.providerData.isEmpty ? false : user.providerData[0].providerId == 'google.com'),
    );
  }
}
