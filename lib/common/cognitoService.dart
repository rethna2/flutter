import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class CognitoService {
  static CognitoUserPool userPool = CognitoUserPool(
    'ap-south-1_YUhDUX1LL',
    '2ti7rhnj96i5fnf8fi27n1jf04',
  );

  static Future<Map> updateSession() async {
    return {'error': true};
    CognitoUser? user = await userPool.getCurrentUser();
    if (user != null) {
      CognitoUserSession? session = await user.getSession();
      CognitoRefreshToken? refreshToken = session?.getRefreshToken();
      if (refreshToken != null) {
        CognitoUserSession? newSession =
            await user.refreshSession(refreshToken);
        String? token = session?.getIdToken().getJwtToken() ?? '';
        return {'token': token};
      }
    }
    return {'error': true};
  }

  static Future<Map> login(email, password) async {
    final cognitoUser = CognitoUser(email, userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    try {
      CognitoUserSession? session =
          await cognitoUser.authenticateUser(authDetails);
      return {
        'error': false,
        'token': session?.getIdToken().getJwtToken() ?? ''
      };
    } on CognitoClientException catch (e) {
      print('CognitoClientException = ${e.toString()}');
      print('CognitoClientException = ${e.message}');
      return {'error': true, 'message': e.message ?? 'Signup Failed!'};
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<String> signup(email, password) async {
    try {
      var data = await userPool.signUp(email, password);
      return 'success';
    } on CognitoClientException catch (e) {
      return e.message ?? 'Signup Failed!';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> resendConfirmationCode(email) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);
      var data = await cognitoUser.resendConfirmationCode();
      return 'success';
    } on CognitoClientException catch (e) {
      return e.message ?? 'Signup Failed!';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> confirmRegistration(otp, email, password) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);
      var data = await cognitoUser.confirmRegistration(otp);
      await login(email, password);
      return 'success';
    } on CognitoClientException catch (e) {
      return e.message ?? 'Signup Failed!';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> forgetPassword(email) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);
      var data = await cognitoUser.forgotPassword();
      return 'success';
    } on CognitoClientException catch (e) {
      return e.message ?? 'forgetPassword Failed!';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> confirmPassword(otp, email, password) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);
      var data = await cognitoUser.confirmPassword(otp, password);
      await login(email, password);
      return 'success';
    } on CognitoClientException catch (e) {
      return e.message ?? 'confirmPassword Failed!';
    } catch (e) {
      return e.toString();
    }
  }
}
