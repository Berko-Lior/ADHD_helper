import 'package:flutter/foundation.dart';

@immutable
class Constants {
  static const accountExistsWithDifferentCredential =
      'account-exists-with-different-credential';
  static const googleCom = 'google.com';
  static const emailScope = 'email';
  
  // A private constractor so no one can initialaized this class.
  const Constants._();
}
