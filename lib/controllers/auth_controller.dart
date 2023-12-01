import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signup(String email, String password) async {
    try {
      UserCredential authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    return authResult.user;
    } catch(e) {
      return null;
    }
  }

  Future<User?> signin(String email, String password) async {
    try {
      UserCredential authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return authResult.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> getUser() async {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> updatePasswordFirebase({ email, oldPassword, newPassword }) async {
    var cred = EmailAuthProvider.credential(email: email, password: oldPassword);

    var currentUser = _firebaseAuth.currentUser;
    await currentUser!.reauthenticateWithCredential(cred).then((value) {
      currentUser.updatePassword(newPassword);
    }).catchError((error) {
      return null;
    });
  }

  Future<void> deleteUserFirebase() async {
    User? user =  _firebaseAuth.currentUser;
    await user!.delete();
  } 
}