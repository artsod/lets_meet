import 'dart:async';

class AuthService {
  Future<bool> isLoggedIn() async {
    // Simulating a delay of 5 seconds
    await Future.delayed(Duration(seconds: 3));

    // Return false to indicate that the user is not logged in
    return false;
  }
}