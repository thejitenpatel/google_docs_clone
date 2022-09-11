import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
  );
});

final userProvider = StateProvider<UserModel?>((ref) {
  return null;
});

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  AuthRepository({required GoogleSignIn googleSignIn, required Client client})
      : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> signInWithGoole() async {
    ErrorModel errorModel =
        ErrorModel(error: "Something wen't wrong", data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName!,
          uid: '',
          profilePic: user.photoUrl!,
          token: '',
        );

        var res = await _client.post(
          Uri.parse(
            "$host/api/signup",
          ),
          body: userAcc.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        switch (res.statusCode) {
          case 200:
            final newUser =
                userAcc.copyWith(uid: jsonDecode(res.body)['user']['_id']);
            errorModel = ErrorModel(error: null, data: newUser);
            break;
        }
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }
}
