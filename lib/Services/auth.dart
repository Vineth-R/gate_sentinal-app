import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gate_sentinal/Pages/home.dart';
import 'package:gate_sentinal/Services/database.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get current user
  Future<User?> getCurrentUser() async {
    return await auth.currentUser;
  }

  // Google Sign In
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (userDetails != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        "id": userDetails.uid
      };
      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
  }

  // Apple Sign In
  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AppleIdCredential appleIdCredential = result.credential!;
        final oAuthCredential = OAuthProvider('apple.com');
        final credential = oAuthCredential.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!));
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;

        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        return firebaseUser;

      case AuthorizationStatus.error:
        throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString());

      case AuthorizationStatus.cancelled:
        throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
      }
  }

  // Future<UserCredential> signInWithFacebook(BuildContext context) async {
  //   try {
  //     final LoginResult loginResult = await FacebookAuth.instance.login();

  //     if (loginResult.status == LoginStatus.success) {
  //       final OAuthCredential facebookAuthCredential =
  //           FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
  //       return await auth.signInWithCredential(facebookAuthCredential);
  //     } else {
  //       throw Exception('Facebook login failed: ${loginResult.message}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Error logging in with Facebook: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     rethrow;
  //   }
  // }
}
