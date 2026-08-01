class InvalidCredentialsException implements Exception {
  String? message;
  InvalidCredentialsException() : message = 'Invalid login credentials';
}

class EmailAlreadyExistsException implements Exception {
  String? message;
  EmailAlreadyExistsException() : message = 'Email is already registered';
}
