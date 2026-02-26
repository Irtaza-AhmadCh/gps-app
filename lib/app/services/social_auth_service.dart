


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class SocialAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//   //     .initialize(
//   //     serverClientId: "639354595481-724r0fjv6punrnm7nunfvf9l643i59o7.apps.googleusercontent.com"
//   //
//   // );


//   // init
//   Future<void> initialize() async {
//     await _googleSignIn.initialize(serverClientId: "82382126611-pe09gmrc2v4t3s117norg0kk9c4ba7b7.apps.googleusercontent.com");
//   }

//   Future<UserCredential?> logInWithGoogle() async {

//     try {
//       await initialize();
//       await signOut();
//       final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.authenticate();
//       if (googleSignInAccount != null) {
//         final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
//         final OAuthCredential credential = GoogleAuthProvider.credential(
//           // accessToken: googleAuth.,
//           idToken: googleAuth.idToken,
//         );
//         final UserCredential userCredential = await _auth.signInWithCredential(credential);
//         return userCredential;
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Failed to log in with Google. Error: $e');
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//     await _googleSignIn.signOut();
//   }

//   User? getCurrentUser() {
//     final User? user = _auth.currentUser;
//     return user;
//   }
// }
